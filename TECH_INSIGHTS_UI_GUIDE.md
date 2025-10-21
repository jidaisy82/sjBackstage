# Tech Insights 화면 보는 방법

Tech Insights는 **3가지 위치**에서 확인할 수 있습니다:

## 📍 1. Entity 페이지 내 Tech Insights 탭 (가장 일반적)

각 카탈로그 엔티티(Component, Resource 등)의 상세 페이지에 Tech Insights 탭이 추가됩니다.

**예시:**
- Catalog → Resources → **tech-blog-database** 클릭
- 상단 탭에서 **"Tech Insights"** 클릭
- → DB 상태 Scorecard 확인

**위치:**
```
http://localhost:3000/catalog/default/resource/tech-blog-database/tech-insights
```

---

## 📍 2. Entity Overview에 Scorecard 카드 (요약 정보)

Entity의 Overview 페이지에 Scorecard 요약 카드가 표시됩니다.

**예시:**
- Catalog → Resources → **tech-blog-database** 클릭
- Overview 탭에서 **"데이터베이스 상태 점검"** 카드 확인
- → 간단한 점검 결과 표시

**위치:**
```
http://localhost:3000/catalog/default/resource/tech-blog-database
```

---

## 📍 3. Tech Insights 전용 대시보드 (전체 시스템)

모든 엔티티의 Tech Insights를 한눈에 볼 수 있는 대시보드입니다.

**예시:**
- 왼쪽 사이드바에서 **"Tech Insights"** 메뉴 클릭
- → 전체 시스템의 Scorecard 현황 확인

**위치:**
```
http://localhost:3000/tech-insights
```

---

## 🚨 현재 상태: 프론트엔드 설정 필요

현재는 **백엔드만 설정**되어 있어서 화면에 아무것도 표시되지 않습니다.

프론트엔드 설정을 완료하려면 다음 작업이 필요합니다:

### ✅ 이미 완료됨
- [x] 프론트엔드 패키지 설치
- [x] 백엔드 Fact Retriever 구현

### ⏳ 남은 작업
- [ ] EntityPage.tsx에 Tech Insights 탭 추가
- [ ] EntityPage.tsx에 Scorecard 카드 추가
- [ ] Root.tsx에 사이드바 메뉴 추가
- [ ] Tech Insights 대시보드 페이지 생성 (선택사항)

---

## 🛠️ 빠른 설정 가이드

지금 바로 Tech Insights 화면을 보려면 아래 3개 파일만 수정하면 됩니다!

### 파일 1: Entity 페이지에 탭 추가

**파일:** `packages/app/src/components/catalog/EntityPage.tsx`

현재 파일을 열어서 다음 내용을 추가하세요:

1. **Import 추가 (파일 상단)**
```tsx
import {
  EntityTechInsightsScorecardCard,
  EntityTechInsightsScorecardContent,
} from '@backstage-community/plugin-tech-insights';
```

2. **Resource 페이지 찾기**
`resourcePage` 또는 `defaultEntityPage`를 찾아서 다음을 추가:

```tsx
// Overview 탭에 Scorecard 카드 추가
<EntityLayout.Route path="/" title="Overview">
  <Grid container spacing={3}>
    {/* 기존 내용 유지 */}
    
    {/* 👇 이 부분 추가 */}
    <Grid item xs={12} md={6}>
      <EntityTechInsightsScorecardCard
        title="데이터베이스 상태 점검"
        description="DB 연결, 응답 시간, 디스크 사용률 모니터링"
      />
    </Grid>
  </Grid>
</EntityLayout.Route>

{/* 👇 새 탭 추가 */}
<EntityLayout.Route path="/tech-insights" title="Tech Insights">
  <EntityTechInsightsScorecardContent
    title="기술 품질 점검"
    description="데이터베이스 상태에 대한 상세 인사이트"
  />
</EntityLayout.Route>
```

### 파일 2: 사이드바 메뉴 추가

**파일:** `packages/app/src/components/Root/Root.tsx`

1. **Import 추가 (파일 상단)**
```tsx
import AssessmentIcon from '@material-ui/icons/Assessment';
```

2. **사이드바에 메뉴 추가**
```tsx
<SidebarItem icon={AssessmentIcon} to="tech-insights" text="Tech Insights" />
```

### 파일 3: Tech Insights 대시보드 페이지 (선택사항)

**파일 생성:** `packages/app/src/components/techInsights/TechInsightsDashboard.tsx`

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

그리고 `packages/app/src/App.tsx`에 라우트 추가:

```tsx
import { TechInsightsDashboard } from './components/techInsights/TechInsightsDashboard';

<Route path="/tech-insights" element={<TechInsightsDashboard />} />
```

---

## 🎯 설정 후 확인 방법

### 1. 백엔드 실행
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn workspace backend start
```

### 2. 프론트엔드 실행
```bash
# 다른 터미널에서
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn workspace app start
```

### 3. 브라우저에서 확인

#### ✅ 위치 1: Entity 페이지
1. http://localhost:3000 접속
2. Catalog 메뉴 클릭
3. Resources → tech-blog-database 클릭
4. **"Tech Insights" 탭** 확인

#### ✅ 위치 2: Overview 카드
1. 같은 페이지 Overview 탭에서
2. **"데이터베이스 상태 점검"** 카드 확인

#### ✅ 위치 3: 전용 대시보드
1. 왼쪽 사이드바에서 **"Tech Insights"** 메뉴 클릭
2. 전체 Scorecard 현황 확인

---

## 📊 예상 화면

### Entity 페이지 Tech Insights 탭
```
┌─────────────────────────────────────────┐
│ tech-blog-database                      │
├─────────────────────────────────────────┤
│ Overview | Tech Insights | Docs | ...   │  ← 탭 추가됨
├─────────────────────────────────────────┤
│                                         │
│ 기술 품질 점검                            │
│ 데이터베이스 상태에 대한 상세 인사이트      │
│                                         │
│ ┌────────────────────────────────────┐ │
│ │ ✅ DB 연결 상태                     │ │
│ │ PASS - 데이터베이스 연결됨          │ │
│ └────────────────────────────────────┘ │
│                                         │
│ ┌────────────────────────────────────┐ │
│ │ ✅ DB 응답 시간                     │ │
│ │ PASS - 120ms < 200ms               │ │
│ └────────────────────────────────────┘ │
│                                         │
│ ┌────────────────────────────────────┐ │
│ │ ✅ DB 디스크 사용률                 │ │
│ │ PASS - 45.5% < 80%                 │ │
│ └────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

### Overview 페이지 Scorecard 카드
```
┌─────────────────────────────────────────┐
│ tech-blog-database - Overview           │
├─────────────────────────────────────────┤
│ ┌──────────────┐  ┌──────────────────┐ │
│ │ About        │  │ 데이터베이스      │ │
│ │              │  │ 상태 점검         │ │
│ │ PostgreSQL   │  │                  │ │
│ │ Database     │  │ ✅ 3/3 Checks   │ │
│ │              │  │ PASSED           │ │
│ └──────────────┘  └──────────────────┘ │
└─────────────────────────────────────────┘
```

### Tech Insights 대시보드
```
┌─────────────────────────────────────────┐
│ Tech Insights                           │
│ 시스템 전체의 기술 품질과 모범 사례      │
├─────────────────────────────────────────┤
│ Filters: [All] [Passed] [Failed]        │
├─────────────────────────────────────────┤
│                                         │
│ tech-blog-database                      │
│ ✅ 3/3 checks passed                    │
│ Last checked: 2 minutes ago             │
│                                         │
│ tech-blog-api-server                    │
│ ⚠️ 2/3 checks passed                    │
│ Last checked: 5 minutes ago             │
│                                         │
└─────────────────────────────────────────┘
```

---

## 🔗 다음 단계

1. **지금 바로**: EntityPage.tsx 수정하여 탭 추가
2. **그 다음**: Root.tsx 수정하여 메뉴 추가
3. **선택사항**: 전용 대시보드 페이지 생성

상세한 코드는 `tech_insights_plugin.md`의 **Section 1.4**를 참고하세요!

---

**작성일**: 2025-10-21  
**작성자**: Platform Team

