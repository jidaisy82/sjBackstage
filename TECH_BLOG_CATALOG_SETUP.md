# Tech Blog Backstage 카탈로그 설정 완료

## 개요
RND-NX 프로젝트의 `tech-blog` 폴더를 Backstage에서 관리할 수 있도록 설정했습니다.

## 생성된 파일 구조

### 1. RND-NX 프로젝트 (Component 정의)

```
/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/
├── api-server/
│   └── catalog-info.yaml              ✅ 새로 생성 (Backend Service)
├── user-client/
│   └── catalog-info.yaml              ✅ 새로 생성 (Frontend Application)
└── api-server-test/
    └── catalog-info.yaml              ✅ 새로 생성 (Test Suite)
```

### 2. rnd-backstage 프로젝트 (System/Domain/API/Resource 정의)

```
/Users/seojiwon/VNTG_PROJECT/rnd-backstage/
├── catalog/                           ✅ 새로 생성
│   ├── systems/
│   │   └── rnd-nx-framework.yaml     ✅ System 정의
│   ├── domains/
│   │   └── all-domains.yaml          ✅ 4개 Domain 정의
│   ├── apis/
│   │   └── tech-blog-rest-api.yaml   ✅ API 정의
│   └── resources/
│       └── tech-blog-database.yaml   ✅ Database Resource 정의
├── examples/
│   └── org.yaml                       ✅ 업데이트 (팀 구조 추가)
└── app-config.yaml                    ✅ 업데이트 (catalog locations 추가)
```

## Backstage 카탈로그 구조

```
System: rnd-nx-framework
│
├── Domain: backend-services
│   ├── Component: tech-blog-api-server (Service)
│   │   ├── providesApis: tech-blog-rest-api
│   │   └── dependsOn: tech-blog-database
│   └── Component: tech-blog-api-server-test (Test)
│       ├── consumesApis: tech-blog-rest-api
│       └── dependsOn: tech-blog-api-server
│
├── Domain: frontend-applications
│   └── Component: tech-blog-user-client (Website)
│       └── consumesApis: tech-blog-rest-api
│
├── API: tech-blog-rest-api
│   └── definition: http://localhost:3001/api-docs-json
│
└── Resource: tech-blog-database (PostgreSQL)
```

## 조직 구조 (Teams)

- **platform-team**: 플랫폼 엔지니어링 팀 (최상위)
  - **backend-team**: 백엔드 팀
    - 소유: tech-blog-api-server, tech-blog-api-server-test
  - **frontend-team**: 프론트엔드 팀
    - 소유: tech-blog-user-client
  - **design-team**: 디자인 시스템 팀
  - **devops-team**: DevOps 팀

## 실행 방법

### 1. Backstage 시작

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn dev
```

### 2. 브라우저에서 확인

http://localhost:3000

- **Catalog** 메뉴에서 다음을 확인:
  - Systems: `rnd-nx-framework`
  - Domains: `backend-services`, `frontend-applications`, `shared-libraries`, `infrastructure`
  - Components: `tech-blog-api-server`, `tech-blog-user-client`, `tech-blog-api-server-test`
  - APIs: `tech-blog-rest-api`
  - Resources: `tech-blog-database`

### 3. 의존성 그래프 확인

각 컴포넌트 페이지에서 **Dependencies** 탭을 클릭하면:
- tech-blog-user-client → tech-blog-rest-api → tech-blog-api-server → tech-blog-database
- 의존성 관계가 시각적으로 표시됩니다.

## 주요 파일 내용

### tech-blog-api-server/catalog-info.yaml
- **Type**: service
- **Owner**: backend-team
- **Provides**: tech-blog-rest-api
- **Depends On**: tech-blog-database
- **기술 스택**: NestJS, Prisma, PostgreSQL, Kafka, WebSocket

### tech-blog-user-client/catalog-info.yaml
- **Type**: website
- **Owner**: frontend-team
- **Consumes**: tech-blog-rest-api
- **기술 스택**: React, Vite, TailwindCSS, Zustand, Lexical

### tech-blog-api-server-test/catalog-info.yaml
- **Type**: service
- **Lifecycle**: experimental
- **Owner**: backend-team
- **Consumes**: tech-blog-rest-api
- **Depends On**: tech-blog-api-server

## app-config.yaml 경로 설명

모든 경로는 `packages/backend/` 기준 상대 경로입니다:

| Target 경로 | 실제 파일 위치 |
|------------|--------------|
| `../../catalog/systems/rnd-nx-framework.yaml` | `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/systems/rnd-nx-framework.yaml` |
| `../../../RND-NX/apps/tech-blog/api-server/catalog-info.yaml` | `/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/catalog-info.yaml` |

## 문제 해결

### 카탈로그가 표시되지 않는 경우

1. **파일 경로 확인**
   ```bash
   # Backstage 루트에서
   cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
   ls -la catalog/systems/
   ls -la ../RND-NX/apps/tech-blog/api-server/
   ```

2. **YAML 문법 검증**
   - [YAML Validator](https://www.yamllint.com/)에서 각 파일 검증

3. **Backstage 로그 확인**
   ```bash
   yarn dev
   # 콘솔에서 catalog 관련 오류 확인
   ```

4. **브라우저 확인**
   - http://localhost:3000/catalog
   - **Unprocessed Entities** 섹션에서 오류 확인

### API 정의가 표시되지 않는 경우

- `tech-blog-api-server`가 실행 중인지 확인:
  ```bash
  curl http://localhost:3001/api-docs-json
  ```
- 서버가 실행되지 않으면 API 정의를 로드할 수 없습니다.

### 의존성 그래프가 표시되지 않는 경우

- Component 이름이 정확히 일치하는지 확인
  - `dependsOn: [resource:tech-blog-database]` (resource: 접두사 필수)
  - `consumesApis: [tech-blog-rest-api]` (API 이름만)

## 다음 단계

### 1. TechDocs 추가 (선택사항)
각 컴포넌트 디렉토리에 `docs/` 폴더와 `mkdocs.yml` 추가

### 2. 다른 컴포넌트 추가
RND-NX의 다른 앱/라이브러리도 동일한 방식으로 추가 가능:
```yaml
# app-config.yaml에 추가
- type: file
  target: ../../../RND-NX/libs/be/auth/catalog-info.yaml
  rules:
    - allow: [Component]
```

### 3. GitHub 통합 (프로덕션)
로컬 파일 대신 GitHub URL로 전환:
```yaml
- type: url
  target: https://github.com/vntg/RND-NX/blob/main/apps/tech-blog/api-server/catalog-info.yaml
```

### 4. 플러그인 추가
- `@backstage/plugin-kubernetes`: K8s 통합
- `@backstage/plugin-grafana`: 모니터링
- `@nx-tools/backstage-plugin-nx`: Nx 프로젝트 그래프

## 참고 문서

- Backstage 공식 문서: https://backstage.io/docs
- bs_sw_arc.md: 전체 아키텍처 설계 문서
- role_auth_guide.md: 권한 관리 가이드

## 작성일
2025-10-21

