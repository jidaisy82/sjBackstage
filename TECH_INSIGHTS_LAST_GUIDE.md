# Tech Insights 플러그인 최종 설치 가이드

## 📋 목차
1. [개요](#개요)
2. [아키텍처](#아키텍처)
3. [설치 및 설정](#설치-및-설정)
4. [파일 구조](#파일-구조)
5. [실행 방법](#실행-방법)
6. [확인 방법](#확인-방법)
7. [수집 데이터 및 체크 항목](#수집-데이터-및-체크-항목)

---

## 개요

Tech Insights는 Backstage의 공식 플러그인으로, 시스템의 기술 품질과 모범 사례 준수 현황을 자동으로 모니터링하고 측정하는 기능을 제공합니다.

### 주요 기능
- **Fact Retriever**: PostgreSQL 데이터베이스 상태를 주기적으로 수집
- **Scorecard**: 수집된 데이터를 기반으로 자동 품질 체크
- **Dashboard**: Entity 페이지 및 전용 대시보드에서 결과 시각화

### 모니터링 대상
- Tech Blog 프로젝트의 PostgreSQL 데이터베이스 (`tech-blog-database`)

---

## 아키텍처

```
┌─────────────────────────────────────────────────┐
│ Backstage Frontend (Port 3000)                  │
│                                                 │
│ ├─ Entity Page (Tech Insights 탭)              │
│ ├─ Overview Card (Scorecard 요약)               │
│ └─ Tech Insights Dashboard                      │
└─────────────────┬───────────────────────────────┘
                  │ REST API
┌─────────────────▼───────────────────────────────┐
│ Backstage Backend (Port 7007)                   │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ Tech Insights Backend Plugin                │ │
│ │ @backstage-community/plugin-tech-insights-  │ │
│ │ backend                                     │ │
│ └──────────────────┬──────────────────────────┘ │
│                    │                             │
│ ┌──────────────────▼──────────────────────────┐ │
│ │ JSON Rules Engine Module                   │ │
│ │ - app-config.yaml에서 checks 로드          │ │
│ │ - Fact 데이터에 대해 규칙 평가             │ │
│ └──────────────────┬──────────────────────────┘ │
│                    │                             │
│ ┌──────────────────▼──────────────────────────┐ │
│ │ DB Status Fact Retriever (커스텀)          │ │
│ │ - PostgreSQL 연결 및 메트릭 수집           │ │
│ │ - 매 1분마다 자동 실행                     │ │
│ └────────────────────────────────────────────┘ │
└─────────────────┬───────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────┐
│ PostgreSQL Database (tech-blog-database)        │
└─────────────────────────────────────────────────┘
```

---

## 설치 및 설정

### 1. 패키지 설치

#### 백엔드 패키지
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend

yarn add @backstage-community/plugin-tech-insights-backend
yarn add @backstage-community/plugin-tech-insights-backend-module-jsonfc
yarn add @backstage-community/plugin-tech-insights-node
yarn add @backstage-community/plugin-tech-insights-common
yarn add @backstage/catalog-client
yarn add pg
```

#### 프론트엔드 패키지
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/app

yarn add @backstage-community/plugin-tech-insights
yarn add @backstage-community/plugin-tech-insights-common
```

### 2. 백엔드 설정

#### 2.1 백엔드 플러그인 등록

**파일**: `/packages/backend/src/index.ts`

```typescript
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

// ... 기존 플러그인들 ...

// Tech Insights 플러그인 추가
backend.add(import('@backstage-community/plugin-tech-insights-backend'));
backend.add(import('@backstage-community/plugin-tech-insights-backend-module-jsonfc'));

// Tech Insights Fact Retriever 모듈 추가
backend.add(import('./plugins/tech-insights'));

backend.start();
```

#### 2.2 Fact Retriever 모듈 생성

**파일**: `/packages/backend/src/plugins/tech-insights/index.ts`

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
        
        // DB 상태 Fact Retriever 생성
        const dbStatusRetriever = new DatabaseStatusFactRetriever(config);
        
        // FactRetriever 객체를 직접 등록
        // cadence는 app-config.yaml에서 설정
        factRetrievers.addFactRetrievers({
          dbStatusFactRetriever: dbStatusRetriever,
        });
        
        logger.info(`DB Status Fact Retriever registered: ${dbStatusRetriever.id} v${dbStatusRetriever.version}`);
      },
    });
  },
});
```

#### 2.3 Fact Retriever 구현

**파일**: `/packages/backend/src/plugins/tech-insights/factRetrievers/dbStatusRetriever.ts`

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
  readonly version = '0.2.0';
  readonly title = 'Tech Blog Database Status';
  readonly description = 'Tech Blog PostgreSQL 데이터베이스 상태 모니터링';
  
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

    // Catalog에서 tech-blog-database 리소스 찾기
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

      // 3. 스토리지 정보
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
        lastChecked: new Date().toISOString(),
        dbConnectionCount,
        activeConnections,
        idleConnections,
        dbDiskUsage,
        dbSizeMB,
        cacheHitRatio,
        longestQueryDuration,
        tableCount,
        indexCount,
        commitRatio,
        lockCount,
        deadTupleRatio,
      },
    }));

    return facts;
  }
}
```

#### 2.4 app-config.yaml 설정

**파일**: `/app-config.yaml`

파일 끝에 다음 내용 추가:

```yaml
# Tech Insights configuration
techInsights:
  factRetrievers:
    dbStatusFactRetriever:  # 코드의 key와 일치
      cadence: '*/1 * * * *'  # 매 분마다 실행
      lifecycle:
        timeToLive: { hours: 24 }
  
  factChecker:
    checks:
      # 1. DB 연결 상태
      db-connection-active:
        type: json-rules-engine
        name: DB 연결 상태
        description: 데이터베이스가 정상적으로 연결되어 있는지 확인
        factIds:
          - tech-blog-db-status-retriever  # Fact Retriever의 id
        rule:
          conditions:
            all:
              - fact: dbConnectionStatus
                operator: equal
                value: true
      
      # 2. DB 응답 시간
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
      
      # 3. 활성 연결 수
      db-active-connections-normal:
        type: json-rules-engine
        name: 활성 연결 수
        description: 활성 연결 수가 50개 이하인지 확인
        factIds:
          - tech-blog-db-status-retriever
        rule:
          conditions:
            all:
              - fact: activeConnections
                operator: lessThanInclusive
                value: 50
      
      # 4. 유휴 연결 수
      db-idle-connections-normal:
        type: json-rules-engine
        name: 유휴 연결 수
        description: 유휴 연결 수가 20개 이하인지 확인
        factIds:
          - tech-blog-db-status-retriever
        rule:
          conditions:
            all:
              - fact: idleConnections
                operator: lessThanInclusive
                value: 20
      
      # 5. DB 디스크 사용률
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
      
      # 6. DB 크기
      db-size-normal:
        type: json-rules-engine
        name: DB 크기
        description: DB 크기가 10GB(10240MB) 이하인지 확인
        factIds:
          - tech-blog-db-status-retriever
        rule:
          conditions:
            all:
              - fact: dbSizeMB
                operator: lessThanInclusive
                value: 10240
      
      # 7. 캐시 히트율
      db-cache-hit-ratio-good:
        type: json-rules-engine
        name: 캐시 히트율
        description: 캐시 히트율이 90% 이상인지 확인
        factIds:
          - tech-blog-db-status-retriever
        rule:
          conditions:
            all:
              - fact: cacheHitRatio
                operator: greaterThanInclusive
                value: 90
      
      # 8. 최장 쿼리 실행 시간
      db-longest-query-duration-normal:
        type: json-rules-engine
        name: 최장 쿼리 실행 시간
        description: 가장 오래 실행 중인 쿼리가 30초(30000ms) 이하인지 확인
        factIds:
          - tech-blog-db-status-retriever
        rule:
          conditions:
            all:
              - fact: longestQueryDuration
                operator: lessThanInclusive
                value: 30000
      
      # 9. 트랜잭션 커밋 비율
      db-commit-ratio-good:
        type: json-rules-engine
        name: 트랜잭션 커밋 비율
        description: 트랜잭션 커밋 비율이 95% 이상인지 확인
        factIds:
          - tech-blog-db-status-retriever
        rule:
          conditions:
            all:
              - fact: commitRatio
                operator: greaterThanInclusive
                value: 95
      
      # 10. Dead tuple 비율
      db-dead-tuple-ratio-low:
        type: json-rules-engine
        name: Dead Tuple 비율
        description: Dead tuple 비율이 10% 이하인지 확인
        factIds:
          - tech-blog-db-status-retriever
        rule:
          conditions:
            all:
              - fact: deadTupleRatio
                operator: lessThanInclusive
                value: 10
```

### 3. 프론트엔드 설정

#### 3.1 Entity Page 수정

**파일**: `/packages/app/src/components/catalog/EntityPage.tsx`

파일 상단에 import 추가:

```tsx
import {
  EntityTechInsightsScorecardCard,
  EntityTechInsightsScorecardContent,
} from '@backstage-community/plugin-tech-insights';
```

Resource 페이지에 Tech Insights 추가 (기존 코드 찾아서 수정):

```tsx
const resourcePage = (
  <EntityLayout>
    <EntityLayout.Route path="/" title="Overview">
      <Grid container spacing={3} alignItems="stretch">
        {entityWarningContent}
        <Grid item md={6}>
          <EntityAboutCard variant="gridItem" />
        </Grid>
        <Grid item md={4} xs={12}>
          <EntityLinksCard />
        </Grid>
        
        {/* Tech Insights Scorecard 카드 추가 */}
        <Grid item md={6} xs={12}>
          <EntityTechInsightsScorecardCard
            title="데이터베이스 상태 점검"
            description="DB 연결, 응답 시간, 디스크 사용률 모니터링"
          />
        </Grid>
      </Grid>
    </EntityLayout.Route>

    {/* Tech Insights 전용 탭 추가 */}
    <EntityLayout.Route path="/tech-insights" title="Tech Insights">
      <EntityTechInsightsScorecardContent
        title="리소스 품질 점검"
        description="리소스 상태에 대한 상세 인사이트"
      />
    </EntityLayout.Route>

    <EntityLayout.Route path="/docs" title="Docs">
      {techdocsContent}
    </EntityLayout.Route>
  </EntityLayout>
);
```

Component 페이지에도 동일하게 추가:

```tsx
const serviceEntityPage = (
  <EntityLayout>
    {/* ... 기존 Overview 탭 ... */}
    
    {/* Tech Insights 탭 추가 */}
    <EntityLayout.Route path="/tech-insights" title="Tech Insights">
      <EntityTechInsightsScorecardContent
        title="기술 품질 점검"
        description="컴포넌트의 기술적 품질과 모범 사례 준수 현황"
      />
    </EntityLayout.Route>
  </EntityLayout>
);
```

#### 3.2 Tech Insights 대시보드 생성

**파일**: `/packages/app/src/components/techInsights/TechInsightsDashboard.tsx`

```tsx
import { Grid } from '@material-ui/core';
import {
  Header,
  Page,
  Content,
  InfoCard,
} from '@backstage/core-components';

export const TechInsightsDashboard = () => {
  return (
    <Page themeId="tool">
      <Header
        title="Tech Insights"
        subtitle="시스템 전체의 기술 품질과 모범 사례 준수 현황"
      />
      <Content>
        <Grid container spacing={3}>
          <Grid item xs={12}>
            <InfoCard title="Tech Insights Overview">
              <p>
                Tech Insights는 시스템의 기술 품질과 모범 사례 준수 현황을 모니터링합니다.
                각 엔티티의 상세 정보는 Catalog에서 확인하실 수 있습니다.
              </p>
              <p>
                <strong>주요 기능:</strong>
              </p>
              <ul>
                <li>데이터베이스 연결 상태 모니터링</li>
                <li>응답 시간 측정 (목표: 200ms 이하)</li>
                <li>디스크 사용률 추적 (목표: 80% 이하)</li>
                <li>활성/유휴 연결 수 추적</li>
                <li>캐시 히트율 모니터링</li>
                <li>트랜잭션 커밋 비율 추적</li>
              </ul>
              <p>
                <strong>확인 방법:</strong><br />
                Catalog → Resources → tech-blog-database → Tech Insights 탭
              </p>
            </InfoCard>
          </Grid>
        </Grid>
      </Content>
    </Page>
  );
};
```

#### 3.3 App.tsx에 라우트 추가

**파일**: `/packages/app/src/App.tsx`

Import 추가:

```tsx
import { TechInsightsDashboard } from './components/techInsights/TechInsightsDashboard';
```

라우트 추가:

```tsx
const routes = (
  <FlatRoutes>
    {/* 기존 라우트들 */}
    <Route path="/tech-insights" element={<TechInsightsDashboard />} />
  </FlatRoutes>
);
```

#### 3.4 사이드바 메뉴 추가

**파일**: `/packages/app/src/components/Root/Root.tsx`

Import 추가:

```tsx
import AssessmentIcon from '@material-ui/icons/Assessment';
```

사이드바에 메뉴 추가:

```tsx
<SidebarItem icon={AssessmentIcon} to="tech-insights" text="Tech Insights" />
```

---

## 파일 구조

설정 완료 후 최종 파일 구조:

```
rnd-backstage/
├── app-config.yaml                                    ✅ Tech Insights 설정 추가
│
├── packages/
│   ├── backend/
│   │   ├── package.json                               ✅ 백엔드 패키지 설치
│   │   └── src/
│   │       ├── index.ts                               ✅ 플러그인 등록
│   │       └── plugins/
│   │           └── tech-insights/
│   │               ├── index.ts                       ✅ Fact Retriever 모듈
│   │               └── factRetrievers/
│   │                   └── dbStatusRetriever.ts       ✅ DB 상태 Fact Retriever
│   │
│   └── app/
│       ├── package.json                               ✅ 프론트엔드 패키지 설치
│       └── src/
│           ├── App.tsx                                ✅ 라우트 추가
│           ├── components/
│           │   ├── catalog/
│           │   │   └── EntityPage.tsx                 ✅ Tech Insights 탭 추가
│           │   ├── Root/
│           │   │   └── Root.tsx                       ✅ 사이드바 메뉴 추가
│           │   └── techInsights/
│           │       └── TechInsightsDashboard.tsx      ✅ 대시보드 페이지
│
└── 문서/
    ├── tech_insights_plugin.md                        📖 초기 가이드
    ├── TECH_INSIGHTS_SETUP_COMPLETE.md                📖 백엔드 설정 완료
    ├── TECH_INSIGHTS_FIX.md                           📖 404 에러 수정
    ├── TECH_INSIGHTS_FINAL_FIX.md                     📖 최종 수정
    ├── TECH_INSIGHTS_OFFICIAL_FIX.md                  📖 공식 문서 기반 수정
    ├── TECH_INSIGHTS_HANDLER_FIX.md                   📖 Handler 수정
    ├── TECH_INSIGHTS_COMPLETE.md                      📖 설정 완료
    ├── TECH_INSIGHTS_DASHBOARD_EXTENDED.md            📖 대시보드 확장
    ├── TECH_INSIGHTS_UI_GUIDE.md                      📖 UI 가이드
    ├── SETUP_STATUS.md                                📖 설정 상태
    └── TECH_INSIGHTS_LAST_GUIDE.md                    📖 최종 통합 가이드 (이 문서)
```

---

## 실행 방법

### 1. 통합 실행 (권장)

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# 백엔드 + 프론트엔드 동시 실행
yarn start
```

### 2. 개별 실행

#### 백엔드만 실행
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

yarn workspace backend start

# 백엔드 API 확인
curl http://localhost:7007/healthcheck
```

#### 프론트엔드만 실행
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

yarn workspace app start
```

---

## 확인 방법

### 1. 백엔드 로그 확인

백엔드 실행 시 다음 로그가 표시되어야 합니다:

```
[backend] tech-insights info Initializing DB Status Fact Retriever...
[backend] tech-insights info DB Status Fact Retriever registered: tech-blog-db-status-retriever v0.2.0
[backend] tech-insights info DB Status Fact Retriever handler started
[backend] tech-insights info DB Status: 15ms, Connections: 36 (active: 5, idle: 31), Size: 45.20MB, Cache Hit: 95.30%, Tables: 25, Indexes: 48
```

### 2. 브라우저에서 확인

#### 2.1 Entity 페이지 Tech Insights 탭

**접속 URL**: 
```
http://localhost:3000/catalog/default/resource/tech-blog-database
```

**확인 항목**:
- 상단 탭에 "Tech Insights" 탭이 추가되어 있는지 확인
- 탭 클릭 시 10개 체크 항목의 Scorecard 결과 확인

**예상 화면**:
```
┌─────────────────────────────────────────┐
│ tech-blog-database                      │
├─────────────────────────────────────────┤
│ Overview | Tech Insights | Docs | ...   │  ← Tech Insights 탭
├─────────────────────────────────────────┤
│ 리소스 품질 점검                         │
│ 리소스 상태에 대한 상세 인사이트          │
│                                         │
│ ✅ DB 연결 상태: PASS                   │
│ ✅ DB 응답 시간: PASS (15ms)            │
│ ✅ 활성 연결 수: PASS (5개)             │
│ ⚠️  유휴 연결 수: FAIL (31개 > 20개)    │
│ ✅ DB 디스크 사용률: PASS (5.26%)       │
│ ✅ DB 크기: PASS (45.2MB)               │
│ ✅ 캐시 히트율: PASS (95.3%)            │
│ ✅ 최장 쿼리: PASS (1250ms)             │
│ ✅ 커밋 비율: PASS (99.8%)              │
│ ✅ Dead Tuple: PASS (2.3%)              │
└─────────────────────────────────────────┘
```

#### 2.2 Entity Overview 페이지 Scorecard 카드

**접속 URL**: 
```
http://localhost:3000/catalog/default/resource/tech-blog-database
```

**확인 항목**:
- Overview 탭 (기본 탭)
- "데이터베이스 상태 점검" 카드가 표시되는지 확인
- 요약된 체크 결과 (예: 9/10 Checks PASSED)

**예상 화면**:
```
┌─────────────────────────────────────────┐
│ About                                   │
│ Tech Blog PostgreSQL 데이터베이스       │
│ ...                                     │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ 데이터베이스 상태 점검                   │
│ DB 연결, 응답 시간, 디스크 사용률        │
│ 모니터링                                │
│                                         │
│ 9/10 Checks Passed                      │
│ 1 Warning                               │
└─────────────────────────────────────────┘
```

#### 2.3 Tech Insights 대시보드

**접속 URL**: 
```
http://localhost:3000/tech-insights
```

**확인 항목**:
- 왼쪽 사이드바에 "Tech Insights" 메뉴 추가 여부
- 대시보드 개요 페이지 표시

### 3. API 엔드포인트 확인

```bash
# Tech Insights Health Check
curl http://localhost:7007/api/tech-insights/health

# Checks 목록
curl http://localhost:7007/api/tech-insights/checks

# Facts 목록
curl http://localhost:7007/api/tech-insights/facts
```

---

## 수집 데이터 및 체크 항목

### 수집되는 데이터 (15개 지표)

#### 기본 상태 (3개)
1. **dbConnectionStatus** (boolean) - 데이터베이스 연결 상태
2. **dbResponseTime** (integer, ms) - 데이터베이스 응답 시간
3. **lastChecked** (datetime) - 마지막 체크 시간

#### 연결 정보 (3개)
4. **dbConnectionCount** (integer) - 전체 연결 수
5. **activeConnections** (integer) - 활성 연결 수
6. **idleConnections** (integer) - 유휴 연결 수

#### 스토리지 정보 (2개)
7. **dbDiskUsage** (number, %) - 디스크 사용률
8. **dbSizeMB** (number, MB) - DB 크기

#### 성능 지표 (2개)
9. **cacheHitRatio** (number, %) - 캐시 히트율
10. **longestQueryDuration** (integer, ms) - 최장 쿼리 실행 시간

#### 데이터베이스 구조 (2개)
11. **tableCount** (integer) - 테이블 개수
12. **indexCount** (integer) - 인덱스 개수

#### 트랜잭션 정보 (1개)
13. **commitRatio** (number, %) - 트랜잭션 커밋 비율

#### 락 정보 (1개)
14. **lockCount** (integer) - 현재 락 개수

#### 유지보수 지표 (1개)
15. **deadTupleRatio** (number, %) - Dead tuple 비율

### 자동 체크 항목 (10개)

| Check ID | 체크 이름 | 조건 | 우선순위 |
|----------|-----------|------|----------|
| `db-connection-active` | DB 연결 상태 | `dbConnectionStatus == true` | 🔴 High |
| `db-response-time-healthy` | DB 응답 시간 | `dbResponseTime ≤ 200ms` | 🔴 High |
| `db-active-connections-normal` | 활성 연결 수 | `activeConnections ≤ 50` | 🔴 High |
| `db-idle-connections-normal` | 유휴 연결 수 | `idleConnections ≤ 20` | 🟡 Medium |
| `db-disk-usage-normal` | DB 디스크 사용률 | `dbDiskUsage ≤ 80%` | 🔴 High |
| `db-size-normal` | DB 크기 | `dbSizeMB ≤ 10240 (10GB)` | 🟢 Low |
| `db-cache-hit-ratio-good` | 캐시 히트율 | `cacheHitRatio ≥ 90%` | 🟡 Medium |
| `db-longest-query-duration-normal` | 최장 쿼리 실행 시간 | `longestQueryDuration ≤ 30000ms (30초)` | 🟡 Medium |
| `db-commit-ratio-good` | 트랜잭션 커밋 비율 | `commitRatio ≥ 95%` | 🟢 Low |
| `db-dead-tuple-ratio-low` | Dead Tuple 비율 | `deadTupleRatio ≤ 10%` | 🟡 Medium |

### Fact Retriever 실행 주기

- **Cadence**: 매 1분마다 (`*/1 * * * *`)
- **TTL**: 24시간 (1일간 데이터 보관)
- **Target**: `tech-blog-database` Resource

---

## 핵심 매칭 포인트

Tech Insights가 정상적으로 작동하려면 다음 항목들이 정확히 일치해야 합니다:

| 항목 | app-config.yaml | 코드 | 설명 |
|------|-----------------|------|------|
| Fact Retriever Key | `dbStatusFactRetriever` | `factRetrievers.addFactRetrievers({ dbStatusFactRetriever: ... })` | 등록 키 |
| Fact Retriever ID | `tech-blog-db-status-retriever` (factIds) | `readonly id = 'tech-blog-db-status-retriever'` | FactRetriever 식별자 |
| Fact 이름 | `dbConnectionStatus`, `dbResponseTime` 등 | `schema: { dbConnectionStatus: {...}, ...}` | Fact 스키마 |
| Entity 이름 | - | `metadata.name: 'tech-blog-database'` | 대상 리소스 |

---

## 문제 해결

### 백엔드가 시작되지 않는 경우

1. **PostgreSQL 연결 확인**
   ```bash
   docker exec docker.postgres psql -U postgres -d backstage -c "SELECT 1;"
   ```

2. **환경 변수 확인**
   ```bash
   cat .env | grep POSTGRES
   ```

3. **포트 충돌 확인**
   ```bash
   lsof -i :7007
   ```

### Tech Insights 탭이 보이지 않는 경우

1. 브라우저 캐시 삭제 (Cmd+Shift+R)
2. 프론트엔드 재시작
3. 개발자 도구 콘솔에서 에러 확인

### Scorecard 데이터가 없는 경우

1. 백엔드가 실행 중인지 확인
2. Fact Retriever 실행 대기 (최대 1분) 또는 백엔드 재시작
3. 백엔드 로그에서 "DB Status Fact Retriever handler started" 확인

---

## 요약

### 설치 패키지

**백엔드**:
- `@backstage-community/plugin-tech-insights-backend`
- `@backstage-community/plugin-tech-insights-backend-module-jsonfc`
- `@backstage-community/plugin-tech-insights-node`
- `@backstage-community/plugin-tech-insights-common`
- `@backstage/catalog-client`
- `pg`

**프론트엔드**:
- `@backstage-community/plugin-tech-insights`
- `@backstage-community/plugin-tech-insights-common`

### 수정된 파일

**백엔드**:
1. `/packages/backend/src/index.ts` - 플러그인 등록
2. `/packages/backend/src/plugins/tech-insights/index.ts` - Fact Retriever 모듈
3. `/packages/backend/src/plugins/tech-insights/factRetrievers/dbStatusRetriever.ts` - DB 상태 수집

**프론트엔드**:
1. `/packages/app/src/components/catalog/EntityPage.tsx` - Tech Insights 탭 추가
2. `/packages/app/src/components/techInsights/TechInsightsDashboard.tsx` - 대시보드 페이지
3. `/packages/app/src/App.tsx` - 라우트 추가
4. `/packages/app/src/components/Root/Root.tsx` - 사이드바 메뉴 추가

**설정**:
1. `/app-config.yaml` - Tech Insights 설정 추가

### 접속 URL

- **메인 페이지**: http://localhost:3000
- **Tech Insights 대시보드**: http://localhost:3000/tech-insights
- **tech-blog-database Resource**: http://localhost:3000/catalog/default/resource/tech-blog-database
- **Tech Insights 탭**: http://localhost:3000/catalog/default/resource/tech-blog-database/tech-insights

---

**작성일**: 2025-01-23  
**작성자**: Platform Team  
**상태**: Tech Insights 설정 완료 ✅  
**버전**: v2.0.0 (최종 통합 버전)

