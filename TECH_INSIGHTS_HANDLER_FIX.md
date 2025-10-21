# Tech Insights Handler 수정

## 발견된 에러 (새로운 진전!)

이전의 "Undefined column(s)" 에러가 **완전히 사라졌습니다!** ✅

새로운 에러들:

### 1. `ctx.entityFilter is not a function`
```
Failed to check DB status: TypeError: ctx.entityFilter is not a function
```

**원인**: `FactRetrieverContext`에는 `entityFilter()` 메서드가 없습니다.

**해결**: 공식 문서에 따르면 `CatalogClient`를 사용해서 엔티티를 조회해야 합니다.

### 2. `Called end on pool more than once`
```
Failed to retrieve facts for retriever tech-blog-db-status-retriever 
Called end on pool more than once
```

**원인**: `pool.end()`를 try 블록과 catch 블록에서 모두 호출했습니다.

**해결**: `finally` 블록에서 한 번만 호출하도록 수정했습니다.

## 공식 문서 예제

[Tech Insights Backend README](https://github.com/backstage/community-plugins/blob/main/workspaces/tech-insights/plugins/tech-insights-backend/README.md)의 공식 예제:

```typescript
handler: async ctx => {
  const { discovery, config, logger, auth } = ctx;

  const { token } = await auth.getPluginRequestToken({
    onBehalfOf: await auth.getOwnServiceCredentials(),
    targetPluginId: 'catalog',
  });

  const catalogClient = new CatalogClient({
    discoveryApi: discovery,
  });
  
  const entities = await catalogClient.getEntities(
    {
      filter: [{ kind: 'component' }],
    },
    { token },
  );

  return entities.items.map(it => {
    return {
      entity: {
        namespace: it.metadata.namespace,
        kind: it.kind,
        name: it.metadata.name,
      },
      facts: {
        examplenumberfact: 2,
      },
    };
  });
}
```

## 수정 내용

### 1. Import 추가

```typescript
import { CatalogClient } from '@backstage/catalog-client';
```

### 2. Handler 함수 수정

**Before:**
```typescript
async handler(ctx: FactRetrieverContext): Promise<TechInsightFact[]> {
  const { logger } = ctx;
  
  // ... DB 연결 로직 ...
  
  // ❌ 잘못된 방식
  const entities = await ctx.entityFilter({
    kind: 'Resource',
    'metadata.name': 'tech-blog-database',
  });
}
```

**After:**
```typescript
async handler(ctx: FactRetrieverContext): Promise<TechInsightFact[]> {
  const { logger, discovery, auth } = ctx;

  // ✅ 공식 문서 방식: CatalogClient 사용
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

  // ... DB 연결 로직 ...
}
```

### 3. Pool 관리 개선

**Before:**
```typescript
try {
  // ... DB 로직 ...
  await pool.end();  // ❌ try 블록에서 호출
  return facts;
} catch (error) {
  await pool.end();  // ❌ catch 블록에서도 호출 (중복!)
  return errorFacts;
}
```

**After:**
```typescript
let dbConnectionStatus = false;
let dbResponseTime = -1;
let dbConnectionCount = 0;
let dbDiskUsage = 0;

try {
  // ... DB 로직 ...
  dbConnectionStatus = true;
} catch (error) {
  logger.error(`Failed to check DB status: ${error}`);
} finally {
  // ✅ finally 블록에서 한 번만 호출
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
```

## 설치된 패키지

```bash
yarn add @backstage/catalog-client
```

## 전체 수정된 파일

`/packages/backend/src/plugins/tech-insights/factRetrievers/dbStatusRetriever.ts`:

```typescript
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
```

## 실행 방법

Backstage를 재시작하세요:

```bash
yarn start
```

## 예상 로그

```
[backend] tech-insights info Initializing DB Status Fact Retriever...
[backend] tech-insights info DB Status Fact Retriever registered: tech-blog-db-status-retriever v0.1.0
[backend] tech-insights info DB Status Fact Retriever handler started
[backend] tech-insights info Successfully checked DB status: 15ms, 36 connections, 5.26% disk usage
```

## 진전 사항

✅ **"Undefined column(s)" 에러 완전히 해결!**
✅ **"ctx.entityFilter is not a function" 수정 완료**
✅ **"Called end on pool more than once" 수정 완료**

이제 Fact Retriever가 정상적으로 작동해야 합니다!

