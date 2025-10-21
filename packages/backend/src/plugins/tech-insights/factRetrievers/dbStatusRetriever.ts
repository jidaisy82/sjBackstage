import {
  FactRetriever,
  FactRetrieverContext,
  TechInsightFact,
} from '@backstage-community/plugin-tech-insights-node';
import { Config } from '@backstage/config';
import { Pool } from 'pg';
import { CatalogClient } from '@backstage/catalog-client';

/**
 * DB 상태를 확인하는 Fact Retriever
 */
export class DatabaseStatusFactRetriever implements FactRetriever {
  readonly id = 'tech-blog-db-status-retriever';
  readonly version = '0.2.0';  // 스키마 변경으로 버전 업데이트
  readonly title = 'Tech Blog Database Status';
  readonly description = 'Tech Blog PostgreSQL 데이터베이스 상태 모니터링';
  
  // EntityFilter: 이 Fact Retriever가 처리하는 엔티티 타입 정의
  readonly entityFilter = [
    { 
      kind: 'Resource',
      'metadata.name': 'tech-blog-database'
    }
  ];

  readonly schema = {
    // 기본 상태
    dbConnectionStatus: {
      type: 'boolean',
      description: '데이터베이스 연결 상태',
    },
    dbResponseTime: {
      type: 'integer',
      description: '데이터베이스 응답 시간(ms)',
    },
    lastChecked: {
      type: 'datetime',
      description: '마지막 체크 시간',
    },
    
    // 연결 정보
    dbConnectionCount: {
      type: 'integer',
      description: '전체 연결 수',
    },
    activeConnections: {
      type: 'integer',
      description: '활성 연결 수',
    },
    idleConnections: {
      type: 'integer',
      description: '유휴 연결 수',
    },
    
    // 스토리지 정보
    dbDiskUsage: {
      type: 'number',
      description: '디스크 사용률(%)',
    },
    dbSizeMB: {
      type: 'number',
      description: 'DB 크기(MB)',
    },
    
    // 성능 지표
    cacheHitRatio: {
      type: 'number',
      description: '캐시 히트율(%)',
    },
    longestQueryDuration: {
      type: 'integer',
      description: '최장 쿼리 실행 시간(ms)',
    },
    
    // 데이터베이스 구조
    tableCount: {
      type: 'integer',
      description: '테이블 개수',
    },
    indexCount: {
      type: 'integer',
      description: '인덱스 개수',
    },
    
    // 트랜잭션 정보
    commitRatio: {
      type: 'number',
      description: '트랜잭션 커밋 비율(%)',
    },
    
    // 락 정보
    lockCount: {
      type: 'integer',
      description: '현재 락 개수',
    },
    
    // 유지보수 지표
    deadTupleRatio: {
      type: 'number',
      description: 'Dead tuple 비율(%)',
    },
  };

  private config: Config;

  constructor(config: Config) {
    this.config = config;
  }

  async handler(ctx: FactRetrieverContext): Promise<TechInsightFact[]> {
    const { logger, discovery, auth } = ctx;

    logger.info('DB Status Fact Retriever handler started');

    // Catalog에서 tech-blog-database 리소스 찾기 (공식 문서 방식)
    const { token } = await auth.getPluginRequestToken({
      onBehalfOf: await auth.getOwnServiceCredentials(),
      targetPluginId: 'catalog',
    });

    const catalogClient = new CatalogClient({
      discoveryApi: discovery,
    });

    const entities = await catalogClient.getEntities(
      {
        filter: [
          { kind: 'Resource', 'metadata.name': 'tech-blog-database' }
        ],
      },
      { token },
    );

    if (entities.items.length === 0) {
      logger.warn('No tech-blog-database resource found in catalog');
      return [];
    }

    // 데이터베이스 설정 가져오기
    const dbConfig = this.config.getConfig('backend.database');
    
    const pool = new Pool({
      host: dbConfig.getString('connection.host'),
      port: dbConfig.getNumber('connection.port'),
      user: dbConfig.getString('connection.user'),
      password: dbConfig.getString('connection.password'),
      database: dbConfig.getString('connection.database'),
    });

    // 초기값 설정
    let dbConnectionStatus = false;
    let dbResponseTime = -1;
    let dbConnectionCount = 0;
    let activeConnections = 0;
    let idleConnections = 0;
    let dbDiskUsage = 0;
    let dbSizeMB = 0;
    let cacheHitRatio = 0;
    let longestQueryDuration = 0;
    let tableCount = 0;
    let indexCount = 0;
    let commitRatio = 0;
    let lockCount = 0;
    let deadTupleRatio = 0;

    try {
      const startTime = Date.now();
      const client = await pool.connect();

      // 1. 연결 테스트 및 응답 시간
      await client.query('SELECT 1');
      dbResponseTime = Date.now() - startTime;
      dbConnectionStatus = true;

      // 2. 연결 정보 (전체, 활성, 유휴)
      const connectionResult = await client.query(`
        SELECT 
          count(*) as total_connections,
          count(*) FILTER (WHERE state = 'active') as active_connections,
          count(*) FILTER (WHERE state = 'idle') as idle_connections
        FROM pg_stat_activity
        WHERE datname = current_database()
      `);
      dbConnectionCount = parseInt(connectionResult.rows[0].total_connections, 10);
      activeConnections = parseInt(connectionResult.rows[0].active_connections, 10);
      idleConnections = parseInt(connectionResult.rows[0].idle_connections, 10);

      // 3. 스토리지 정보 (디스크 사용률, DB 크기)
      const diskResult = await client.query(`
        SELECT 
          pg_database_size(current_database()) as size,
          pg_database_size(current_database()) / 1024.0 / 1024.0 as size_mb,
          pg_database_size(current_database()) * 100.0 / 
          NULLIF(pg_tablespace_size('pg_default'), 0) as usage_percent
      `);
      dbSizeMB = diskResult.rows[0].size_mb 
        ? parseFloat(diskResult.rows[0].size_mb) 
        : 0;
      dbDiskUsage = diskResult.rows[0].usage_percent 
        ? parseFloat(diskResult.rows[0].usage_percent) 
        : 0;

      // 4. 캐시 히트율
      const cacheResult = await client.query(`
        SELECT 
          COALESCE(
            sum(heap_blks_hit) / NULLIF(sum(heap_blks_hit) + sum(heap_blks_read), 0) * 100,
            0
          ) as cache_hit_ratio
        FROM pg_statio_user_tables
      `);
      cacheHitRatio = parseFloat(cacheResult.rows[0].cache_hit_ratio) || 0;

      // 5. 최장 쿼리 실행 시간
      const queryDurationResult = await client.query(`
        SELECT 
          COALESCE(
            EXTRACT(EPOCH FROM MAX(now() - query_start)) * 1000,
            0
          ) as longest_duration
        FROM pg_stat_activity
        WHERE state != 'idle' 
          AND query_start IS NOT NULL
          AND datname = current_database()
      `);
      longestQueryDuration = Math.round(parseFloat(queryDurationResult.rows[0].longest_duration) || 0);

      // 6. 테이블 개수
      const tableCountResult = await client.query(`
        SELECT count(*) as count 
        FROM pg_tables 
        WHERE schemaname = 'public'
      `);
      tableCount = parseInt(tableCountResult.rows[0].count, 10);

      // 7. 인덱스 개수
      const indexCountResult = await client.query(`
        SELECT count(*) as count 
        FROM pg_indexes 
        WHERE schemaname = 'public'
      `);
      indexCount = parseInt(indexCountResult.rows[0].count, 10);

      // 8. 트랜잭션 커밋 비율
      const txResult = await client.query(`
        SELECT 
          xact_commit,
          xact_rollback,
          COALESCE(
            ROUND(xact_commit::numeric / NULLIF(xact_commit + xact_rollback, 0) * 100, 2),
            0
          ) as commit_ratio
        FROM pg_stat_database 
        WHERE datname = current_database()
      `);
      commitRatio = parseFloat(txResult.rows[0].commit_ratio) || 0;

      // 9. 락 개수
      const lockResult = await client.query(`
        SELECT count(*) as count FROM pg_locks
      `);
      lockCount = parseInt(lockResult.rows[0].count, 10);

      // 10. Dead tuple 비율
      const deadTupleResult = await client.query(`
        SELECT 
          COALESCE(
            ROUND(
              sum(n_dead_tup)::numeric / NULLIF(sum(n_live_tup), 0) * 100,
              2
            ),
            0
          ) as dead_tuple_ratio
        FROM pg_stat_user_tables
      `);
      deadTupleRatio = parseFloat(deadTupleResult.rows[0].dead_tuple_ratio) || 0;

      client.release();

      logger.info(
        `DB Status: ${dbResponseTime}ms, ` +
        `Connections: ${dbConnectionCount} (active: ${activeConnections}, idle: ${idleConnections}), ` +
        `Size: ${dbSizeMB.toFixed(2)}MB, ` +
        `Cache Hit: ${cacheHitRatio.toFixed(2)}%, ` +
        `Tables: ${tableCount}, Indexes: ${indexCount}`
      );
    } catch (error) {
      logger.error(`Failed to check DB status: ${error}`);
    } finally {
      // pool.end()를 finally 블록에서 한 번만 호출
      await pool.end();
    }

    // 모든 엔티티에 대해 Fact 반환
    const facts: TechInsightFact[] = entities.items.map(entity => ({
      entity: {
        namespace: entity.metadata.namespace || 'default',
        kind: entity.kind,
        name: entity.metadata.name,
      },
      facts: {
        // 기본 상태
        dbConnectionStatus,
        dbResponseTime,
        lastChecked: new Date().toISOString(),
        
        // 연결 정보
        dbConnectionCount,
        activeConnections,
        idleConnections,
        
        // 스토리지 정보
        dbDiskUsage,
        dbSizeMB,
        
        // 성능 지표
        cacheHitRatio,
        longestQueryDuration,
        
        // 데이터베이스 구조
        tableCount,
        indexCount,
        
        // 트랜잭션 정보
        commitRatio,
        
        // 락 정보
        lockCount,
        
        // 유지보수 지표
        deadTupleRatio,
      },
    }));

    return facts;
  }
}


