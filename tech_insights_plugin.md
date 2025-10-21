# Backstage 플러그인 추가 가이드

## 목차
1. [Tech Insights 플러그인으로 DB 상태 모니터링](#1-tech-insights-플러그인으로-db-상태-모니터링)
2. [일반적인 플러그인 추가 절차](#2-일반적인-플러그인-추가-절차)

---

## 1. Tech Insights 플러그인으로 DB 상태 모니터링

### 1.1 개요

**Tech Insights**는 Backstage의 공식 플러그인으로, 엔지니어링 조직의 기술 품질과 모범 사례 준수를 측정하고 추적하는 데 사용됩니다.

**주요 기능:**
- 📊 **Scorecards**: 엔티티의 기술적 품질을 점수화
- 🔍 **Fact Retrievers**: 다양한 소스에서 데이터 수집
- ✅ **Checks**: 모범 사례 준수 여부 자동 확인
- 📈 **Trends**: 시간에 따른 품질 개선 추적

**사용 사례:**
- 데이터베이스 상태 모니터링 (연결, 응답 시간, 크기 등)
- API 문서화 준수 확인
- 보안 패치 적용 여부 확인
- 코드 품질 메트릭 추적

---

### 1.2 설치

#### 프론트엔드 플러그인 설치

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# App 디렉토리로 이동
cd packages/app

# Tech Insights 프론트엔드 플러그인 설치
yarn add @backstage-community/plugin-tech-insights
yarn add @backstage-community/plugin-tech-insights-common
```

#### 백엔드 플러그인 설치

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# Backend 디렉토리로 이동
cd packages/backend

# Tech Insights 백엔드 플러그인 설치
yarn add @backstage-community/plugin-tech-insights-backend
yarn add @backstage-community/plugin-tech-insights-node
```

---

### 1.3 백엔드 설정

#### Step 1: 백엔드 플러그인 등록

**파일**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend/src/index.ts`

```typescript
import { createBackend } from '@backstage/backend-defaults';

const backend = createBackend();

// ... 기존 플러그인들 ...

// Tech Insights 플러그인 추가
backend.add(import('@backstage-community/plugin-tech-insights-backend'));

backend.start();
```

#### Step 2: Fact Retriever 구현 (DB 상태 모니터링)

**파일 생성**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend/src/plugins/tech-insights/factRetrievers/dbStatusRetriever.ts`

```typescript
import {
  FactRetriever,
  FactRetrieverContext,
  FactRetrieverRegistration,
  TechInsightFact,
} from '@backstage-community/plugin-tech-insights-node';
import { Config } from '@backstage/config';

/**
 * DB 상태를 확인하는 Fact Retriever
 */
export class DatabaseStatusFactRetriever implements FactRetriever {
  readonly id = 'tech-blog-db-status-retriever';
  readonly version = '0.1.0';
  readonly title = 'Tech Blog Database Status';
  readonly description = 'Tech Blog PostgreSQL 데이터베이스 상태 모니터링';

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
    const { discovery, logger, entityFilter } = ctx;

    // 데이터베이스 설정 가져오기
    const dbConfig = this.config.getConfig('backend.database');
    const dbHost = dbConfig.getString('connection.host');
    const dbPort = dbConfig.getNumber('connection.port');
    const dbName = dbConfig.getString('connection.database');

    logger.info(`Checking DB status for ${dbHost}:${dbPort}/${dbName}`);

    try {
      // 실제 DB 상태 확인 로직
      const startTime = Date.now();
      
      // TODO: 실제 DB 연결 및 쿼리 실행
      // 예시: const client = await pool.connect();
      // const result = await client.query('SELECT 1');
      
      const responseTime = Date.now() - startTime;

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
          dbConnectionCount: 10, // TODO: 실제 값으로 교체
          dbDiskUsage: 45.5, // TODO: 실제 값으로 교체
          lastChecked: new Date().toISOString(),
        },
      }));

      return facts;
    } catch (error) {
      logger.error(`Failed to check DB status: ${error}`);
      
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

/**
 * Fact Retriever 팩토리 함수
 */
export const createDatabaseStatusFactRetriever = (
  config: Config,
): FactRetrieverRegistration => {
  return {
    factRetriever: new DatabaseStatusFactRetriever(config),
    cadence: '*/30 * * * *', // 30분마다 실행
  };
};
```

#### Step 3: Fact Retriever 등록

**파일 수정**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend/src/index.ts`

```typescript
import { createBackend } from '@backstage/backend-defaults';
import { techInsightsFactRetrieversExtensionPoint } from '@backstage-community/plugin-tech-insights-node';
import { createDatabaseStatusFactRetriever } from './plugins/tech-insights/factRetrievers/dbStatusRetriever';

const backend = createBackend();

// Tech Insights 플러그인 추가 및 Fact Retriever 등록
backend.add(import('@backstage-community/plugin-tech-insights-backend'));
backend.add(
  createBackendModule({
    pluginId: 'tech-insights',
    moduleId: 'db-status-retriever',
    register(env) {
      env.registerInit({
        deps: {
          techInsights: techInsightsFactRetrieversExtensionPoint,
          config: coreServices.rootConfig,
        },
        async init({ techInsights, config }) {
          techInsights.addFactRetrievers(
            createDatabaseStatusFactRetriever(config),
          );
        },
      });
    },
  })(),
);

backend.start();
```

#### Step 4: Check (검증 규칙) 정의

**파일 생성**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend/src/plugins/tech-insights/checks/dbStatusChecks.ts`

```typescript
import { CheckResult } from '@backstage-community/plugin-tech-insights-common';

/**
 * DB 상태 체크 정의
 */
export const dbStatusChecks = [
  {
    id: 'db-connection-active',
    type: 'json-rules-engine',
    name: 'DB 연결 상태',
    description: '데이터베이스가 정상적으로 연결되어 있는지 확인',
    factIds: ['tech-blog-db-status-retriever'],
    rule: {
      conditions: {
        all: [
          {
            fact: 'dbConnectionStatus',
            operator: 'equal',
            value: true,
          },
        ],
      },
    },
  },
  {
    id: 'db-response-time-healthy',
    type: 'json-rules-engine',
    name: 'DB 응답 시간',
    description: '데이터베이스 응답 시간이 200ms 이하인지 확인',
    factIds: ['tech-blog-db-status-retriever'],
    rule: {
      conditions: {
        all: [
          {
            fact: 'dbResponseTime',
            operator: 'lessThanInclusive',
            value: 200,
          },
        ],
      },
    },
  },
  {
    id: 'db-disk-usage-normal',
    type: 'json-rules-engine',
    name: 'DB 디스크 사용률',
    description: '디스크 사용률이 80% 이하인지 확인',
    factIds: ['tech-blog-db-status-retriever'],
    rule: {
      conditions: {
        all: [
          {
            fact: 'dbDiskUsage',
            operator: 'lessThanInclusive',
            value: 80,
          },
        ],
      },
    },
  },
];
```

---

### 1.4 프론트엔드 설정

#### Step 1: Entity Page에 Tech Insights 탭 추가

**파일 수정**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/app/src/components/catalog/EntityPage.tsx`

```tsx
import {
  EntityTechInsightsScorecardCard,
  EntityTechInsightsScorecardContent,
} from '@backstage-community/plugin-tech-insights';

// Resource 엔티티 페이지에 Tech Insights 추가
const resourcePage = (
  <EntityLayout>
    <EntityLayout.Route path="/" title="Overview">
      <Grid container spacing={3}>
        {entityWarningContent}
        <Grid item xs={12}>
          <EntityAboutCard variant="gridItem" />
        </Grid>
        
        {/* Tech Insights Scorecard 카드 추가 */}
        <Grid item xs={12} md={6}>
          <EntityTechInsightsScorecardCard
            title="데이터베이스 상태 점검"
            description="DB 연결, 응답 시간, 디스크 사용률 모니터링"
          />
        </Grid>
        
        <Grid item xs={12}>
          <EntityHasSystemsCard variant="gridItem" />
        </Grid>
      </Grid>
    </EntityLayout.Route>
    
    {/* Tech Insights 전용 탭 추가 */}
    <EntityLayout.Route path="/tech-insights" title="Tech Insights">
      <EntityTechInsightsScorecardContent
        title="기술 품질 점검"
        description="데이터베이스 상태에 대한 상세 인사이트"
      />
    </EntityLayout.Route>
    
    <EntityLayout.Route path="/docs" title="Docs">
      <EntityTechdocsContent />
    </EntityLayout.Route>
  </EntityLayout>
);

// Component (Service) 페이지에도 추가 가능
const serviceEntityPage = (
  <EntityLayout>
    {/* 기존 탭들 */}
    
    <EntityLayout.Route path="/tech-insights" title="Tech Insights">
      <EntityTechInsightsScorecardContent
        title="서비스 품질 점검"
        description="API 문서화, 테스트 커버리지, 보안 점검"
      />
    </EntityLayout.Route>
  </EntityLayout>
);
```

#### Step 2: Tech Insights 대시보드 페이지 추가 (선택사항)

**파일 생성**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/app/src/components/techInsights/TechInsightsDashboard.tsx`

```tsx
import React from 'react';
import { Grid } from '@material-ui/core';
import {
  Header,
  Page,
  Content,
} from '@backstage/core-components';
import {
  ScorecardsList,
  TechInsightsScorecardsFilters,
} from '@backstage-community/plugin-tech-insights';

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
            <TechInsightsScorecardsFilters />
          </Grid>
          <Grid item xs={12}>
            <ScorecardsList
              title="전체 Scorecards"
              description="모든 엔티티의 기술 품질 점수"
            />
          </Grid>
        </Grid>
      </Content>
    </Page>
  );
};
```

**파일 수정**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/app/src/App.tsx`

```tsx
import { TechInsightsDashboard } from './components/techInsights/TechInsightsDashboard';

const routes = (
  <FlatRoutes>
    {/* 기존 라우트들 */}
    
    <Route path="/tech-insights" element={<TechInsightsDashboard />} />
  </FlatRoutes>
);
```

#### Step 3: 사이드바 메뉴에 추가

**파일 수정**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/app/src/components/Root/Root.tsx`

```tsx
import AssessmentIcon from '@material-ui/icons/Assessment';

export const Root = ({ children }: PropsWithChildren<{}>) => (
  <SidebarPage>
    <Sidebar>
      {/* 기존 메뉴들 */}
      
      <SidebarItem icon={AssessmentIcon} to="tech-insights" text="Tech Insights" />
      
      <SidebarDivider />
      <SidebarSpace />
      <SidebarDivider />
      {/* Settings 등 */}
    </Sidebar>
    {children}
  </SidebarPage>
);
```

---

### 1.5 실행 및 확인

#### Step 1: 백엔드 빌드 및 실행

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# 백엔드 실행
yarn workspace backend start
```

#### Step 2: 프론트엔드 실행

```bash
# 다른 터미널에서
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# 프론트엔드 실행
yarn workspace app start
```

#### Step 3: 확인

1. **브라우저 접속**: http://localhost:3000

2. **Tech Insights 대시보드 확인**:
   - 왼쪽 사이드바에서 "Tech Insights" 클릭
   - 전체 시스템의 Scorecard 현황 확인

3. **Resource 페이지에서 확인**:
   - Catalog → Resources → tech-blog-database 선택
   - "Tech Insights" 탭 클릭
   - DB 상태 점검 결과 확인

4. **Scorecard 결과 예시**:
   ```
   ✅ DB 연결 상태: PASS (연결됨)
   ✅ DB 응답 시간: PASS (120ms < 200ms)
   ✅ DB 디스크 사용률: PASS (45.5% < 80%)
   ```

---

### 1.6 고급 설정

#### 실제 PostgreSQL 연결

**파일 수정**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend/src/plugins/tech-insights/factRetrievers/dbStatusRetriever.ts`

```typescript
import { Pool } from 'pg';

export class DatabaseStatusFactRetriever implements FactRetriever {
  // ... 기존 코드 ...

  async handler(ctx: FactRetrieverContext): Promise<TechInsightFact[]> {
    const dbConfig = this.config.getConfig('backend.database');
    
    // PostgreSQL 연결 풀 생성
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

      // 연결 상태 확인
      await client.query('SELECT 1');
      const responseTime = Date.now() - startTime;

      // 활성 연결 수 확인
      const connectionResult = await client.query(
        'SELECT count(*) FROM pg_stat_activity'
      );
      const connectionCount = parseInt(connectionResult.rows[0].count, 10);

      // 디스크 사용률 확인
      const diskResult = await client.query(`
        SELECT 
          pg_database_size(current_database()) as size,
          pg_database_size(current_database()) * 100.0 / 
          pg_tablespace_size('pg_default') as usage_percent
      `);
      const diskUsage = parseFloat(diskResult.rows[0].usage_percent);

      client.release();
      await pool.end();

      return [{
        entity: {
          namespace: 'default',
          kind: 'Resource',
          name: 'tech-blog-database',
        },
        facts: {
          dbConnectionStatus: true,
          dbResponseTime: responseTime,
          dbConnectionCount: connectionCount,
          dbDiskUsage: diskUsage,
          lastChecked: new Date().toISOString(),
        },
      }];
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

#### 알림 설정 (선택사항)

Check가 실패할 때 Slack이나 이메일로 알림을 보낼 수 있습니다.

```typescript
// packages/backend/src/plugins/tech-insights/alerts/dbAlerts.ts

import { CheckResult } from '@backstage-community/plugin-tech-insights-common';

export const setupDatabaseAlerts = (results: CheckResult[]) => {
  results.forEach(result => {
    if (!result.passed) {
      // Slack 알림
      sendSlackNotification({
        channel: '#db-alerts',
        text: `⚠️ DB 상태 점검 실패: ${result.check.name}`,
        attachments: [{
          color: 'danger',
          fields: [{
            title: 'Check',
            value: result.check.description,
            short: false,
          }],
        }],
      });
    }
  });
};
```

---

## 2. 일반적인 플러그인 추가 절차

### 2.1 플러그인 검색 및 선택

**공식 플러그인 목록**: https://backstage.io/plugins

**커뮤니티 플러그인**: 
- https://github.com/backstage/backstage/tree/master/plugins
- https://github.com/backstage/community-plugins

### 2.2 플러그인 설치 패턴

대부분의 Backstage 플러그인은 다음 패턴을 따릅니다:

```bash
# 프론트엔드 플러그인
cd packages/app
yarn add @backstage/plugin-{plugin-name}

# 백엔드 플러그인
cd packages/backend
yarn add @backstage/plugin-{plugin-name}-backend
```

### 2.3 권장 플러그인 목록

#### 개발 도구

| 플러그인 | 설명 | 패키지 |
|---------|------|--------|
| **Kubernetes** | K8s 클러스터 통합 | `@backstage/plugin-kubernetes` |
| **GitHub Actions** | CI/CD 파이프라인 가시성 | `@backstage/plugin-github-actions` |
| **SonarQube** | 코드 품질 모니터링 | `@backstage/plugin-sonarqube` |

#### 모니터링

| 플러그인 | 설명 | 패키지 |
|---------|------|--------|
| **Grafana** | Grafana 대시보드 통합 | `@backstage/plugin-grafana` |
| **Prometheus** | Prometheus 메트릭 | `@backstage/plugin-prometheus` |
| **Datadog** | Datadog APM 통합 | `@roadiehq/backstage-plugin-datadog` |

#### Nx 특화

| 플러그인 | 설명 | 패키지 |
|---------|------|--------|
| **Nx** | Nx 프로젝트 그래프 시각화 | `@nx-tools/backstage-plugin-nx` |

---

### 2.4 플러그인 통합 체크리스트

플러그인을 추가할 때 다음 사항을 확인하세요:

- [ ] 플러그인 설치 (`yarn add`)
- [ ] 프론트엔드 라우트 추가 (`App.tsx`)
- [ ] 백엔드 플러그인 등록 (`index.ts`)
- [ ] 환경 변수 설정 (`.env`, `app-config.yaml`)
- [ ] Entity Page에 통합 (`EntityPage.tsx`)
- [ ] 사이드바 메뉴 추가 (`Root.tsx`)
- [ ] 권한 설정 (필요시)
- [ ] 문서화

---

## 참고 자료

- [Backstage 공식 문서](https://backstage.io/docs)
- [Tech Insights 플러그인 문서](https://backstage.io/docs/features/tech-insights/)
- [Backstage 플러그인 마켓플레이스](https://backstage.io/plugins)
- [Community Plugins](https://github.com/backstage/community-plugins)

---

**작성일**: 2025-10-21  
**작성자**: Platform Team

