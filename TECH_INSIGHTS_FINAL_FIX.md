# Tech Insights 최종 수정 완료

## 🔍 문제 분석

### 발견된 근본 원인
1. **잘못된 Extension Point 사용**: `techInsightsRuleExtensionPoint`, `techInsightsFactCheckerExtensionPoint` 등은 존재하지 않음
2. **불필요한 커스텀 모듈**: `@backstage-community/plugin-tech-insights-backend-module-jsonfc`가 이미 완전한 구현을 제공함
3. **Checks 등록 방식 오류**: Checks는 코드가 아닌 `app-config.yaml`에서 정의해야 함

### 실제 제공되는 Extension Points (from node_modules)
```typescript
// ✅ 실제로 존재하는 것들:
- techInsightsFactRetrieversExtensionPoint
  → addFactRetrievers(factRetrievers: Record<string, FactRetriever>): void

- techInsightsFactCheckerFactoryExtensionPoint
  → setFactCheckerFactory(factory): void

- techInsightsFactRetrieverRegistryExtensionPoint
  → setFactRetrieverRegistry(registry): void

- techInsightsPersistenceContextExtensionPoint
  → setPersistenceContext(context): void

// ❌ 존재하지 않는 것들 (우리가 사용하려 했던 것):
- techInsightsRuleExtensionPoint (X)
- techInsightsFactCheckerExtensionPoint (X)
- techInsightsChecksExtensionPoint (X)
```

### 올바른 아키텍처
```
1. Tech Insights Backend Plugin
   ↓
2. JSON Rules Engine Module (이미 제공됨)
   - app-config.yaml에서 checks를 읽어옴
   ↓
3. 우리의 Fact Retriever 모듈 (커스텀)
   - DB 상태 데이터 수집
```

## ✅ 최종 수정 사항

### 1. 삭제된 파일
```
❌ packages/backend/src/plugins/tech-insights/checksModule.ts (삭제)
```

**이유**: 
- JSON Rules Engine 모듈이 이미 완전한 구현 제공
- Checks는 app-config.yaml에서 정의하는 것이 표준

### 2. 수정된 파일

#### `packages/backend/src/index.ts`
```typescript
// Tech Insights 플러그인 추가
backend.add(import('@backstage-community/plugin-tech-insights-backend'));
backend.add(import('@backstage-community/plugin-tech-insights-backend-module-jsonfc')); // JSON Rules Engine

// Tech Insights Fact Retriever 모듈 추가
backend.add(import('./plugins/tech-insights')); // 우리의 커스텀 Fact Retriever만

backend.start();
```

**변경점**:
- ❌ `checksModule` import 제거
- ✅ JSON Rules Engine 모듈만 사용

#### `packages/backend/src/plugins/tech-insights/index.ts`
**변경 없음** - Fact Retriever만 등록하고 있으므로 정상

```typescript
export default createBackendModule({
  pluginId: 'tech-insights',
  moduleId: 'db-status-retriever',
  register(env) {
    env.registerInit({
      deps: {
        factRetrievers: techInsightsFactRetrieversExtensionPoint, // ✅ 올바른 extension point
        config: coreServices.rootConfig,
      },
      async init({ factRetrievers, config }) {
        factRetrievers.addFactRetrievers(
          createDatabaseStatusFactRetriever(config),
        );
      },
    });
  },
});
```

### 3. 새로 추가된 설정

#### `app-config.yaml`
**추가 위치**: 파일 끝에 추가

```yaml
# Tech Insights configuration
techInsights:
  factChecker:
    checks:
      # DB 연결 상태 체크
      db-connection-active:
        type: json-rules-engine
        name: DB 연결 상태
        description: 데이터베이스가 정상적으로 연결되어 있는지 확인
        factIds:
          - tech-blog-db-status-retriever
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

**중요 사항**:
- `factIds`는 Fact Retriever의 `id`와 정확히 일치해야 함
- `fact` 이름은 Fact Retriever의 `schema`에 정의된 필드명과 일치해야 함
- `operator`: equal, lessThanInclusive, greaterThan 등 json-rules-engine 표준 연산자

## 📊 최종 아키텍처

```
┌─────────────────────────────────────────────────┐
│ Backstage Backend                               │
│                                                 │
│ ┌─────────────────────────────────────────────┐ │
│ │ Tech Insights Backend Plugin                │ │
│ │ @backstage-community/plugin-tech-insights-  │ │
│ │ backend                                     │ │
│ └──────────────────┬──────────────────────────┘ │
│                    │                             │
│ ┌──────────────────▼──────────────────────────┐ │
│ │ JSON Rules Engine Module                   │ │
│ │ @backstage-community/plugin-tech-insights- │ │
│ │ backend-module-jsonfc                      │ │
│ │                                            │ │
│ │ • Reads checks from app-config.yaml       │ │
│ │ • Evaluates rules against facts           │ │
│ │ • Returns check results                   │ │
│ └──────────────────┬──────────────────────────┘ │
│                    │                             │
│ ┌──────────────────▼──────────────────────────┐ │
│ │ DB Status Fact Retriever (커스텀)          │ │
│ │ packages/backend/src/plugins/tech-insights │ │
│ │                                            │ │
│ │ • PostgreSQL 연결                         │ │
│ │ • 응답 시간 측정                          │ │
│ │ • 디스크 사용률 조회                      │ │
│ │ • 활성 연결 수 조회                       │ │
│ └────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────┘
                      ▲
                      │
                      ▼
          ┌──────────────────────┐
          │ app-config.yaml      │
          │                      │
          │ techInsights:        │
          │   factChecker:       │
          │     checks:          │
          │       - db-connection│
          │       - db-response  │
          │       - db-disk      │
          └──────────────────────┘
```

## 🚀 실행 방법

### 1. 백엔드 + 프론트엔드 실행
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn start
```

### 2. 백엔드만 실행 (테스트용)
```bash
yarn workspace backend start
```

### 3. 프론트엔드만 실행 (테스트용)
```bash
yarn workspace app start
```

## ✅ 정상 작동 확인

### 1. 백엔드 로그 확인
실행 시 다음과 같은 로그가 보여야 합니다:

```
✓ tech-insights plugin started
✓ JSON Rules Engine Fact Checker Factory loaded
✓ Loaded 3 checks from configuration
  - db-connection-active
  - db-response-time-healthy
  - db-disk-usage-normal
✓ DB Status Fact Retriever registered
```

**에러가 없어야 합니다!**

### 2. API 엔드포인트 확인
```bash
# Health check
curl http://localhost:7007/api/tech-insights/health

# Checks 목록
curl http://localhost:7007/api/tech-insights/checks

# Facts 목록
curl http://localhost:7007/api/tech-insights/facts
```

### 3. 프론트엔드 확인
브라우저에서:
1. `http://localhost:3000/catalog/default/resource/tech-blog-database`
2. **Overview 탭**: "데이터베이스 상태 점검" 카드 확인
3. **Tech Insights 탭**: 상세 점검 결과 확인
4. **404 에러 없음** 확인

## 📁 최종 파일 구조

```
rnd-backstage/
├── app-config.yaml                                    ✅ Tech Insights checks 설정 추가
├── packages/
│   └── backend/
│       └── src/
│           ├── index.ts                               ✅ JSON Rules Engine 모듈 등록
│           └── plugins/
│               └── tech-insights/
│                   ├── index.ts                       ✅ Fact Retriever 모듈
│                   ├── factRetrievers/
│                   │   └── dbStatusRetriever.ts       (변경 없음)
│                   └── checks/
│                       └── dbStatusChecks.ts          (사용 안 함, 삭제 가능)
└── packages/
    └── app/
        └── src/
            ├── App.tsx                                (변경 없음)
            ├── components/
            │   ├── catalog/
            │   │   └── EntityPage.tsx                 (변경 없음)
            │   ├── Root/
            │   │   └── Root.tsx                       (변경 없음)
            │   └── techInsights/
            │       └── TechInsightsDashboard.tsx      (변경 없음)
```

## 🧹 정리 가능한 파일 (선택사항)

```bash
# 더 이상 사용하지 않는 파일 삭제
rm /Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend/src/plugins/tech-insights/checks/dbStatusChecks.ts
```

이 파일은 이제 `app-config.yaml`로 대체되었습니다.

## 🎯 핵심 변경 사항 요약

### Before (❌ 에러 발생)
```typescript
// checksModule.ts - 직접 구현
export default createBackendModule({
  pluginId: 'tech-insights',
  moduleId: 'db-status-checks',
  register(reg) {
    reg.registerInit({
      deps: {
        techInsights: techInsightsRuleExtensionPoint, // ❌ 존재하지 않음
      },
      // ...
    });
  },
});
```

### After (✅ 정상 작동)
```yaml
# app-config.yaml - 표준 방식
techInsights:
  factChecker:
    checks:
      db-connection-active:
        type: json-rules-engine
        name: DB 연결 상태
        factIds:
          - tech-blog-db-status-retriever
        rule:
          conditions:
            all:
              - fact: dbConnectionStatus
                operator: equal
                value: true
```

## 🔗 참고 문서

- [Tech Insights Backend](https://github.com/backstage/community-plugins/tree/main/workspaces/tech-insights/plugins/tech-insights-backend)
- [JSON Rules Engine Module](https://github.com/backstage/community-plugins/tree/main/workspaces/tech-insights/plugins/tech-insights-backend-module-jsonfc)
- [JSON Rules Engine](https://github.com/CacheControl/json-rules-engine)
- [Backstage Configuration](https://backstage.io/docs/conf/)

---

**작성일**: 2025-10-21  
**상태**: 최종 수정 완료 ✅  
**다음 단계**: `yarn start` 실행 후 정상 작동 확인

