# Tech Insights 공식 문서 기반 수정

## 문제점 분석

공식 문서([Tech Insights Backend README](https://github.com/backstage/community-plugins/blob/main/workspaces/tech-insights/plugins/tech-insights-backend/README.md))를 검토한 결과, 우리 코드에서 다음 문제점들을 발견했습니다:

### 1. FactRetriever 등록 방식 오류

**잘못된 방식 (우리 코드):**
```typescript
// ❌ FactRetrieverRegistration (cadence 포함 래퍼)을 전달
const dbStatusRetriever = createDatabaseStatusFactRetriever(config);
factRetrievers.addFactRetrievers({
  'dbStatusFactRetriever': dbStatusRetriever,  // { factRetriever, cadence } 객체
});
```

**올바른 방식 (공식 문서):**
```typescript
// ✅ FactRetriever 객체를 직접 전달
const dbStatusRetriever = new DatabaseStatusFactRetriever(config);
factRetrievers.addFactRetrievers({
  dbStatusFactRetriever: dbStatusRetriever,  // FactRetriever 객체
});
```

### 2. Cadence 설정 중복

**문제:**
- 코드에서 `cadence: '* * * * *'` 설정
- `app-config.yaml`에서도 `cadence: '*/1 * * * *'` 설정
- **충돌 발생!**

**해결:**
- ✅ `app-config.yaml`에만 cadence 설정
- ✅ 코드에서는 FactRetriever 객체만 등록

### 3. EntityFilter 누락

**추가된 내용:**
```typescript
readonly entityFilter = [
  { 
    kind: 'Resource',
    'metadata.name': 'tech-blog-database'
  }
];
```

## 수정 사항

### 1. `/packages/backend/src/plugins/tech-insights/index.ts`

```typescript
import { createBackendModule } from '@backstage/backend-plugin-api';
import { 
  techInsightsFactRetrieversExtensionPoint,
} from '@backstage-community/plugin-tech-insights-node';
import { coreServices } from '@backstage/backend-plugin-api';
import { DatabaseStatusFactRetriever } from './factRetrievers/dbStatusRetriever';

/**
 * Tech Insights 모듈 - DB 상태 모니터링 Fact Retriever 등록
 */
export default createBackendModule({
  pluginId: 'tech-insights',
  moduleId: 'db-status-retriever',
  register(env) {
    env.registerInit({
      deps: {
        factRetrievers: techInsightsFactRetrieversExtensionPoint,
        config: coreServices.rootConfig,
        logger: coreServices.logger,
      },
      async init({ factRetrievers, config, logger }) {
        logger.info('Initializing DB Status Fact Retriever...');
        
        // DB 상태 Fact Retriever 생성 (FactRetriever 객체)
        const dbStatusRetriever = new DatabaseStatusFactRetriever(config);
        
        // FactRetriever 객체를 직접 등록 (공식 문서 방식)
        // cadence는 app-config.yaml의 techInsights.factRetrievers.dbStatusFactRetriever.cadence에서 설정
        factRetrievers.addFactRetrievers({
          dbStatusFactRetriever: dbStatusRetriever,  // app-config.yaml의 key와 일치
        });
        
        logger.info(`DB Status Fact Retriever registered: ${dbStatusRetriever.id} v${dbStatusRetriever.version}`);
      },
    });
  },
});
```

### 2. `/packages/backend/src/plugins/tech-insights/factRetrievers/dbStatusRetriever.ts`

**변경점:**
1. `FactRetrieverRegistration` import 제거
2. `createDatabaseStatusFactRetriever()` 팩토리 함수 제거
3. `entityFilter` 추가

```typescript
import {
  FactRetriever,
  FactRetrieverContext,
  TechInsightFact,
} from '@backstage-community/plugin-tech-insights-node';
import { Config } from '@backstage/config';
import { Pool } from 'pg';

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
    const { logger } = ctx;

    logger.info('DB Status Fact Retriever handler started');

    // 데이터베이스 설정 가져오기
    const dbConfig = this.config.getConfig('backend.database');
    
    const pool = new Pool({
      host: dbConfig.getString('connection.host'),
      port: dbConfig.getNumber('connection.port'),
      user: dbConfig.getString('connection.user'),
      password: dbConfig.getString('connection.password'),
      database: dbConfig.getString('connection.database'),
    });

    try {
      const startTime = Date.now();
      const client = await pool.connect();

      // 연결 테스트
      await client.query('SELECT 1');
      const responseTime = Date.now() - startTime;

      // 활성 연결 수 조회
      const connectionResult = await client.query(
        'SELECT count(*) FROM pg_stat_activity'
      );
      const connectionCount = parseInt(connectionResult.rows[0].count, 10);

      // 디스크 사용률 조회
      const diskResult = await client.query(`
        SELECT 
          pg_database_size(current_database()) as size,
          pg_database_size(current_database()) * 100.0 / 
          NULLIF(pg_tablespace_size('pg_default'), 0) as usage_percent
      `);
      const diskUsage = diskResult.rows[0].usage_percent 
        ? parseFloat(diskResult.rows[0].usage_percent) 
        : 0;

      client.release();
      await pool.end();

      // Catalog에서 tech-blog-database 리소스 찾기
      const entities = await ctx.entityFilter({
        kind: 'Resource',
        'metadata.name': 'tech-blog-database',
      });

      const facts: TechInsightFact[] = entities.map(entity => ({
        entity: {
          namespace: entity.metadata.namespace || 'default',
          kind: entity.kind,
          name: entity.metadata.name,
        },
        facts: {
          dbConnectionStatus: true,
          dbResponseTime: responseTime,
          dbConnectionCount: connectionCount,
          dbDiskUsage: diskUsage,
          lastChecked: new Date().toISOString(),
        },
      }));

      logger.info(
        `Successfully checked DB status: ${responseTime}ms, ${connectionCount} connections, ${diskUsage.toFixed(2)}% disk usage`
      );
      return facts;
    } catch (error) {
      logger.error(`Failed to check DB status: ${error}`);
      await pool.end();
      
      return [{
        entity: {
          namespace: 'default',
          kind: 'Resource',
          name: 'tech-blog-database',
        },
        facts: {
          dbConnectionStatus: false,
          dbResponseTime: -1,
          dbConnectionCount: 0,
          dbDiskUsage: 0,
          lastChecked: new Date().toISOString(),
        },
      }];
    }
  }
}
```

## 데이터베이스 테이블 상태

### 현재 상태: ✅ 모든 마이그레이션 완료

```sql
-- fact_schemas 테이블
Table "public.fact_schemas"
    Column    |       Type        | Nullable | 
--------------+-------------------+----------+
 id           | character varying | not null | 
 version      | character varying | not null | 
 entityFilter | text              |          | 
 schema       | text              | not null | 
Indexes:
    "fact_schemas_pkey" PRIMARY KEY (id, version)
    "fact_schema_id_idx" btree (id)

-- facts 테이블
Table "public.facts"
  Column   |              Type              | Nullable | Default 
-----------+--------------------------------+----------+-------------------
 id        | character varying              | not null | 
 version   | character varying              | not null | 
 timestamp | timestamp(0) without time zone | not null | CURRENT_TIMESTAMP
 entity    | character varying              | not null | 
 facts     | text                           | not null | 
Indexes:
    "fact_id_entity_idx" btree (id, entity)
    "fact_id_idx" btree (id)
    "facts_latest_idx" btree (id, entity, timestamp DESC)
Foreign-key constraints:
    "facts_id_version_fkey" FOREIGN KEY (id, version) REFERENCES fact_schemas(id, version)
```

### 적용된 마이그레이션:
1. ✅ `202109061111_fact_schemas.js` - fact_schemas 테이블 생성
2. ✅ `202109061212_facts.js` - facts 테이블 생성
3. ✅ `2022060100821_facts_timestamp_precision.js` - timestamp precision 수정
4. ✅ `20230213170839_latest-facts-index.js` - latest-facts 인덱스 추가
5. ✅ `20230925145017_increase_filter_fact_schemas_size.js` - entityFilter TEXT로 변경

## app-config.yaml 설정

```yaml
techInsights:
  factRetrievers:
    dbStatusFactRetriever:  # 코드의 key와 일치해야 함!
      cadence: '*/1 * * * *'  # 매 분마다 실행
      lifecycle:
        timeToLive: { hours: 24 }
  
  factChecker:
    checks:
      # DB 연결 상태 체크
      db-connection-active:
        type: json-rules-engine
        name: DB 연결 상태
        description: 데이터베이스가 정상적으로 연결되어 있는지 확인
        factIds:
          - tech-blog-db-status-retriever  # FactRetriever의 id와 일치!
        rule:
          conditions:
            all:
              - fact: dbConnectionStatus
                operator: equal
                value: true
      
      # DB 응답 시간 체크
      db-response-time-healthy:
        type: json-rules-engine
        name: DB 응답 시간
        description: 데이터베이스 응답 시간이 200ms 이하인지 확인
        factIds:
          - tech-blog-db-status-retriever
        rule:
          conditions:
            all:
              - fact: dbResponseTime
                operator: lessThanInclusive
                value: 200
      
      # DB 디스크 사용률 체크
      db-disk-usage-normal:
        type: json-rules-engine
        name: DB 디스크 사용률
        description: 디스크 사용률이 80% 이하인지 확인
        factIds:
          - tech-blog-db-status-retriever
        rule:
          conditions:
            all:
              - fact: dbDiskUsage
                operator: lessThanInclusive
                value: 80
```

## 핵심 매칭 포인트

| 항목 | `app-config.yaml` | 코드 | 설명 |
|------|-------------------|------|------|
| Fact Retriever Key | `dbStatusFactRetriever` | `factRetrievers.addFactRetrievers({ dbStatusFactRetriever: ... })` | 등록 키 |
| Fact Retriever ID | `tech-blog-db-status-retriever` (factIds) | `readonly id = 'tech-blog-db-status-retriever'` | FactRetriever 식별자 |
| Fact 이름 | `dbConnectionStatus`, `dbResponseTime` 등 | `schema: { dbConnectionStatus: {...}, ...}` | Fact 스키마 |

## 실행 방법

```bash
# Backstage 재시작
yarn start
```

## 예상 로그

```
[backend] tech-insights info Initializing DB Status Fact Retriever...
[backend] tech-insights info DB Status Fact Retriever registered: tech-blog-db-status-retriever v0.1.0
[backend] tech-insights info DB Status Fact Retriever handler started
[backend] tech-insights info Successfully checked DB status: 15ms, 36 connections, 5.26% disk usage
```

## 확인 사항

1. ✅ `packages/backend/src/index.ts`에 모듈 등록:
   ```typescript
   backend.add(import('./plugins/tech-insights'));
   ```

2. ✅ `package.json`에 필수 패키지 설치:
   - `@backstage-community/plugin-tech-insights-backend`
   - `@backstage-community/plugin-tech-insights-backend-module-jsonfc`
   - `@backstage-community/plugin-tech-insights-node`
   - `pg` (PostgreSQL driver)

3. ✅ 환경 변수 설정 (`.env`):
   ```bash
   POSTGRES_HOST=localhost
   POSTGRES_PORT=5432
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=post1234
   POSTGRES_DB=backstage
   ```

## 다음 단계

1. Backstage 재시작
2. `http://localhost:3000/catalog/default/resource/tech-blog-database` 접속
3. "Tech Insights" 탭 확인
4. "데이터베이스 상태 점검" 카드 확인

만약 여전히 "Undefined column(s)" 에러가 발생하면, Tech Insights Backend 플러그인의 버그 또는 새 백엔드 시스템과의 호환성 문제로 판단하고 커스텀 대시보드 솔루션으로 전환할 것을 권장합니다.

