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
  readonly version = '0.1.0';
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
    dbConnectionStatus: {
      type: 'boolean',
      description: '데이터베이스 연결 상태',
    },
    dbResponseTime: {
      type: 'integer',
      description: '데이터베이스 응답 시간(ms)',
    },
    dbConnectionCount: {
      type: 'integer',
      description: '활성 연결 수',
    },
    dbDiskUsage: {
      type: 'number',
      description: '디스크 사용률(%)',
    },
    lastChecked: {
      type: 'datetime',
      description: '마지막 체크 시간',
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

    let dbConnectionStatus = false;
    let dbResponseTime = -1;
    let dbConnectionCount = 0;
    let dbDiskUsage = 0;

    try {
      const startTime = Date.now();
      const client = await pool.connect();

      // 연결 테스트
      await client.query('SELECT 1');
      dbResponseTime = Date.now() - startTime;

      // 활성 연결 수 조회
      const connectionResult = await client.query(
        'SELECT count(*) FROM pg_stat_activity'
      );
      dbConnectionCount = parseInt(connectionResult.rows[0].count, 10);

      // 디스크 사용률 조회
      const diskResult = await client.query(`
        SELECT 
          pg_database_size(current_database()) as size,
          pg_database_size(current_database()) * 100.0 / 
          NULLIF(pg_tablespace_size('pg_default'), 0) as usage_percent
      `);
      dbDiskUsage = diskResult.rows[0].usage_percent 
        ? parseFloat(diskResult.rows[0].usage_percent) 
        : 0;

      client.release();
      dbConnectionStatus = true;

      logger.info(
        `Successfully checked DB status: ${dbResponseTime}ms, ${dbConnectionCount} connections, ${dbDiskUsage.toFixed(2)}% disk usage`
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
        dbConnectionStatus,
        dbResponseTime,
        dbConnectionCount,
        dbDiskUsage,
        lastChecked: new Date().toISOString(),
      },
    }));

    return facts;
  }
}


