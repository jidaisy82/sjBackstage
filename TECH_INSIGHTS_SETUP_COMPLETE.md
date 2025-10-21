# Tech Insights 플러그인 설치 완료

## ✅ 완료된 작업

### 1. 백엔드 설정 (Step 2-4)

#### 설치된 패키지
```bash
@backstage-community/plugin-tech-insights-backend
@backstage-community/plugin-tech-insights-node
@backstage-community/plugin-tech-insights-common
```

#### 생성된 파일

**1. Fact Retriever 구현**
```
/Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend/src/plugins/tech-insights/
├── factRetrievers/
│   └── dbStatusRetriever.ts          ✅ DB 상태 모니터링 Fact Retriever
├── checks/
│   └── dbStatusChecks.ts             ✅ DB 상태 체크 정의
└── index.ts                          ✅ Tech Insights 모듈 등록
```

**2. 백엔드 플러그인 등록**
- `packages/backend/src/index.ts` 업데이트 ✅

#### 구현된 기능

**Fact Retriever (dbStatusRetriever.ts)**
- DB 연결 상태 확인 (`dbConnectionStatus`)
- DB 응답 시간 측정 (`dbResponseTime`)
- 활성 연결 수 추적 (`dbConnectionCount`)
- 디스크 사용률 모니터링 (`dbDiskUsage`)
- 마지막 체크 시간 기록 (`lastChecked`)
- 30분마다 자동 실행 (cron: `*/30 * * * *`)

**Check 규칙 (dbStatusChecks.ts)**
1. **DB 연결 상태**: 데이터베이스가 정상 연결되어 있는지
2. **DB 응답 시간**: 응답 시간이 200ms 이하인지
3. **DB 디스크 사용률**: 디스크 사용률이 80% 이하인지

### 2. 프론트엔드 설정 준비

#### 설치된 패키지
```bash
@backstage-community/plugin-tech-insights
@backstage-community/plugin-tech-insights-common
```

---

## 🔜 다음 단계 (프론트엔드 설정)

아직 완료하지 않은 프론트엔드 설정을 진행해야 합니다:

### Step 1: Entity Page에 Tech Insights 탭 추가

**파일**: `packages/app/src/components/catalog/EntityPage.tsx`

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
      </Grid>
    </EntityLayout.Route>
    
    {/* Tech Insights 전용 탭 추가 */}
    <EntityLayout.Route path="/tech-insights" title="Tech Insights">
      <EntityTechInsightsScorecardContent
        title="기술 품질 점검"
        description="데이터베이스 상태에 대한 상세 인사이트"
      />
    </EntityLayout.Route>
  </EntityLayout>
);
```

### Step 2: Tech Insights 대시보드 페이지 추가 (선택사항)

**파일 생성**: `packages/app/src/components/techInsights/TechInsightsDashboard.tsx`

### Step 3: 사이드바 메뉴에 추가

**파일**: `packages/app/src/components/Root/Root.tsx`

```tsx
import AssessmentIcon from '@material-ui/icons/Assessment';

<SidebarItem icon={AssessmentIcon} to="tech-insights" text="Tech Insights" />
```

---

## 🧪 테스트 방법

### 백엔드 실행

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn workspace backend start
```

### 로그 확인

백엔드 실행 시 다음 로그가 표시되어야 합니다:

```
[tech-insights] Registering fact retriever: tech-blog-db-status-retriever
[tech-insights] Scheduled fact retrieval every 30 minutes
```

### DB 상태 확인

30분 후 또는 수동으로 Fact Retriever를 실행하면:

```
[tech-insights] Checking DB status for localhost:5432/backstage
[tech-insights] DB status check completed successfully
```

---

## 📊 예상 결과

Tech Insights가 정상적으로 동작하면 다음 정보를 수집합니다:

```json
{
  "entity": {
    "namespace": "default",
    "kind": "Resource",
    "name": "tech-blog-database"
  },
  "facts": {
    "dbConnectionStatus": true,
    "dbResponseTime": 120,
    "dbConnectionCount": 10,
    "dbDiskUsage": 45.5,
    "lastChecked": "2025-10-21T10:30:00.000Z"
  }
}
```

### Scorecard 결과

```
✅ DB 연결 상태: PASS (연결됨)
✅ DB 응답 시간: PASS (120ms < 200ms)
✅ DB 디스크 사용률: PASS (45.5% < 80%)
```

---

## 🔧 고급 설정 (선택사항)

### 실제 PostgreSQL 연결

현재는 모의 데이터를 사용하고 있습니다. 실제 DB 연결을 원하시면:

**파일 수정**: `packages/backend/src/plugins/tech-insights/factRetrievers/dbStatusRetriever.ts`

```typescript
import { Pool } from 'pg';

// handler 메서드 내부
const pool = new Pool({
  host: dbConfig.getString('connection.host'),
  port: dbConfig.getNumber('connection.port'),
  user: dbConfig.getString('connection.user'),
  password: dbConfig.getString('connection.password'),
  database: dbConfig.getString('connection.database'),
});

const client = await pool.connect();
await client.query('SELECT 1');
const responseTime = Date.now() - startTime;

// 활성 연결 수
const connectionResult = await client.query(
  'SELECT count(*) FROM pg_stat_activity'
);
const connectionCount = parseInt(connectionResult.rows[0].count, 10);

// 디스크 사용률
const diskResult = await client.query(`
  SELECT 
    pg_database_size(current_database()) as size,
    pg_database_size(current_database()) * 100.0 / 
    pg_tablespace_size('pg_default') as usage_percent
`);
const diskUsage = parseFloat(diskResult.rows[0].usage_percent);

client.release();
await pool.end();
```

### pg 패키지 설치

```bash
cd packages/backend
yarn add pg
```

---

## 📝 체크리스트

### 완료된 항목
- [x] 백엔드 플러그인 설치
- [x] Fact Retriever 구현 (DB 상태 모니터링)
- [x] Check 규칙 정의
- [x] 백엔드 플러그인 등록
- [x] Tech Insights 모듈 생성
- [x] 프론트엔드 플러그인 설치

### 남은 작업
- [ ] Entity Page에 Tech Insights 탭 추가
- [ ] Tech Insights 대시보드 페이지 생성 (선택사항)
- [ ] 사이드바 메뉴 추가
- [ ] 실제 PostgreSQL 연결 구현 (선택사항)
- [ ] 알림 설정 (선택사항)
- [ ] 프론트엔드/백엔드 통합 테스트

---

## 🚀 다음 작업

프론트엔드 설정을 완료하려면 다음 명령어를 실행하세요:

```bash
# 가이드 문서 확인
cat /Users/seojiwon/VNTG_PROJECT/rnd-backstage/tech_insights_plugin.md

# 또는 Step 1.4부터 수동으로 진행
```

---

## 📚 참고 문서

- **상세 가이드**: `tech_insights_plugin.md`
- **Backstage 공식 문서**: https://backstage.io/docs/features/tech-insights/
- **카탈로그 설정**: `TECH_BLOG_CATALOG_SETUP.md`

---

**작성일**: 2025-10-21  
**작성자**: Platform Team  
**상태**: 백엔드 설정 완료 (프론트엔드 설정 대기 중)

