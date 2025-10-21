# Tech Insights 404 에러 수정

## 🐛 발견된 문제

1. **404 Not Found 에러**: Tech Insights API 엔드포인트가 제대로 등록되지 않음
2. **Overview 탭에 Scorecard 카드 미표시**: 백엔드 API가 동작하지 않아 데이터 없음
3. **백엔드 시작 에러**: "Cannot read properties of undefined (reading 'id')"

## 🔧 수정 내용

### 1. Tech Insights 모듈 구조 재설계

**문제**: Checks를 Fact Retriever와 함께 등록하려 했으나 새 Backstage 백엔드 시스템에서는 별도 등록 필요

**해결**: Fact Retriever와 Checks를 별도 모듈로 분리

#### 수정된 파일 구조
```
packages/backend/src/plugins/tech-insights/
├── factRetrievers/
│   └── dbStatusRetriever.ts          (변경 없음)
├── checks/
│   └── dbStatusChecks.ts             (변경 없음)
├── index.ts                           ✅ 수정 (Fact Retriever만 등록)
└── checksModule.ts                    ✅ 새로 생성 (Checks 등록)
```

### 2. `index.ts` 수정

**변경 사항**: Checks 등록 제거, Fact Retriever만 등록

```typescript
import { createBackendModule } from '@backstage/backend-plugin-api';
import { techInsightsFactRetrieversExtensionPoint } from '@backstage-community/plugin-tech-insights-node';
import { coreServices } from '@backstage/backend-plugin-api';
import { createDatabaseStatusFactRetriever } from './factRetrievers/dbStatusRetriever';

export default createBackendModule({
  pluginId: 'tech-insights',
  moduleId: 'db-status-retriever',
  register(env) {
    env.registerInit({
      deps: {
        factRetrievers: techInsightsFactRetrieversExtensionPoint,
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

### 3. `checksModule.ts` 생성

**신규 파일**: Checks를 JSON Rules Engine으로 등록

```typescript
import { createBackendModule } from '@backstage/backend-plugin-api';
import { techInsightsRuleExtensionPoint } from '@backstage-community/plugin-tech-insights-node';
import { JsonRulesEngineFactCheckerFactory } from '@backstage-community/plugin-tech-insights-backend-module-jsonfc';

export default createBackendModule({
  pluginId: 'tech-insights',
  moduleId: 'db-status-checks',
  register(reg) {
    reg.registerInit({
      deps: {
        techInsights: techInsightsRuleExtensionPoint,
      },
      async init({ techInsights }) {
        const factCheckerFactory = new JsonRulesEngineFactCheckerFactory({
          checks: [
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
            // ... 나머지 checks
          ],
          logger: console,
        });

        techInsights.addFactCheckers(factCheckerFactory);
      },
    });
  },
});
```

### 4. `backend/src/index.ts` 수정

**변경 사항**: JSON Rules Engine 모듈 및 Checks 모듈 추가

```typescript
// Tech Insights 플러그인 추가
backend.add(import('@backstage-community/plugin-tech-insights-backend'));
backend.add(import('@backstage-community/plugin-tech-insights-backend-module-jsonfc')); // ✅ 추가

// Tech Insights Fact Retriever 모듈 추가
backend.add(import('./plugins/tech-insights'));
backend.add(import('./plugins/tech-insights/checksModule')); // ✅ 추가

backend.start();
```

## 📦 필요한 패키지 설치

JSON Rules Engine 모듈이 이미 설치되어 있는지 확인:

```bash
yarn workspace backend list --pattern @backstage-community/plugin-tech-insights-backend-module-jsonfc
```

만약 없다면 설치:

```bash
yarn workspace backend add @backstage-community/plugin-tech-insights-backend-module-jsonfc
```

## 🚀 실행 방법

프로젝트 루트에서:

```bash
yarn start
```

이 명령어는 백엔드와 프론트엔드를 모두 실행합니다.

## ✅ 확인 사항

### 1. 백엔드 정상 시작 확인

터미널에서 다음 로그가 보여야 합니다:

```
✓ Tech Insights backend plugin started
✓ DB Status Fact Retriever registered
✓ DB Status Checks registered
```

에러가 없어야 합니다.

### 2. API 엔드포인트 확인

브라우저나 curl로 확인:

```bash
curl http://localhost:7007/api/tech-insights/health
```

### 3. 프론트엔드 확인

1. `http://localhost:3000/catalog/default/resource/tech-blog-database` 접속
2. **Overview 탭**에 "데이터베이스 상태 점검" 카드 확인
3. **Tech Insights 탭** 클릭하여 상세 점검 결과 확인

## 🎯 예상 결과

### Overview 탭
```
┌─────────────────────────────────────┐
│ About                               │
├─────────────────────────────────────┤
│ Tech Blog PostgreSQL 데이터베이스   │
│ ...                                 │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ 데이터베이스 상태 점검               │
├─────────────────────────────────────┤
│ DB 연결, 응답 시간, 디스크 사용률    │
│ 모니터링                            │
│                                     │
│ ✅ 3/3 Checks Passed               │
└─────────────────────────────────────┘
```

### Tech Insights 탭
```
┌─────────────────────────────────────┐
│ 리소스 품질 점검                     │
│ 리소스 상태에 대한 상세 인사이트      │
├─────────────────────────────────────┤
│ ✅ DB 연결 상태: PASS               │
│ ✅ DB 응답 시간: PASS (120ms)       │
│ ✅ DB 디스크 사용률: PASS (45%)     │
└─────────────────────────────────────┘
```

## 🐛 여전히 에러가 발생한다면

### 1. JSON Rules Engine 패키지 설치 확인

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn workspace backend add @backstage-community/plugin-tech-insights-backend-module-jsonfc
```

### 2. 캐시 및 빌드 파일 삭제

```bash
yarn clean
rm -rf node_modules/.cache
```

### 3. 의존성 재설치

```bash
yarn install
```

### 4. 재시작

```bash
yarn start
```

## 📝 변경된 파일 목록

```
✅ packages/backend/src/plugins/tech-insights/index.ts
✅ packages/backend/src/plugins/tech-insights/checksModule.ts (새로 생성)
✅ packages/backend/src/index.ts
```

## 🔗 관련 문서

- [Tech Insights Backend](https://github.com/backstage/community-plugins/tree/main/workspaces/tech-insights/plugins/tech-insights-backend)
- [JSON Rules Engine](https://github.com/backstage/community-plugins/tree/main/workspaces/tech-insights/plugins/tech-insights-backend-module-jsonfc)
- [Backstage New Backend System](https://backstage.io/docs/backend-system/)

---

**작성일**: 2025-10-21  
**상태**: 수정 완료 ✅  
**다음 단계**: `yarn start` 실행 후 확인

