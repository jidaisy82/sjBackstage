# Backstage 소프트웨어 카탈로그 아키텍처 설계서

# 설계 가이드
1. 전체 시스템 아키텍처
- RND-NX와 rnd-backstage 프로젝트 개요
- System → Domain → Component 계층 구조
2. 카탈로그 엔티티 설계
- System 레벨: rnd-nx-framework
- Domain 레벨:
  - Backend Services
  - Frontend Applications
  - Shared Libraries
  - Infrastructure
- Component 레벨:
  - 백엔드 서비스 (tech-blog-api-server, 각종 라이브러리)
  - 프론트엔드 앱 (tech-blog-user-client, ui-test-app)
  - 디자인 시스템 (design-tokens, ui-component)
  - 테스트 컴포넌트
3. 조직 구조
- platform-team, backend-team, frontend-team, design-team, devops-team
- 권한 매트릭스
4. 파일 구조 및 등록 방법
- catalog-info.yaml 배치 위치
- app-config.yaml 설정 방법
5. TechDocs 통합
- 기술 문서화 구조 및 우선순위
6. 소프트웨어 템플릿
-NestJS Microservice 템플릿
-React Component Library 템플릿
7. 플러그인 및 통합
- 권장 플러그인 목록
- GitHub, Kubernetes 통합 구성
8. 구현 로드맵
- 12주 단계별 구현 계획
9. 모니터링 및 보안
- 메트릭 정의
- RBAC 정책
- 감사 로그



## 문서 개요

### 목적
본 문서는 Backstage를 활용하여 RND-NX 모노레포 프로젝트를 효과적으로 관리하기 위한 소프트웨어 카탈로그 구조를 설계합니다.

### 범위
- RND-NX 프로젝트의 애플리케이션, 라이브러리, 인프라 컴포넌트 카탈로그화
- 팀 조직 구조 및 권한 관리
- 개발 워크플로우 및 문서 통합

### 대상 독자
- 개발팀 리더 및 아키텍트
- DevOps 엔지니어
- 백엔드/프론트엔드 개발자

---

## 1. 전체 시스템 아키텍처

### 1.1 프로젝트 개요

#### RND-NX 프로젝트
- **타입**: Nx 모노레포 기반 차세대 프레임워크
- **패키지 매니저**: pnpm v10.14.0
- **Node.js**: v22.17.0
- **Nx**: v21.4.0
- **주요 기술 스택**:
  - 백엔드: NestJS, Prisma, PostgreSQL, Kafka
  - 프론트엔드: React, Vite, TailwindCSS, Storybook
  - 인프라: Docker, Kubernetes, Terraform, Ansible

#### rnd-backstage 프로젝트
- **타입**: Backstage 개발자 포털
- **목적**: RND-NX 프로젝트의 중앙 관리 및 가시성 제공
- **인증**: Google OAuth
- **데이터베이스**: PostgreSQL

### 1.2 카탈로그 계층 구조

```
Systems (시스템)
  └── Domains (도메인)
       └── Components (컴포넌트)
            ├── APIs
            ├── Resources
            └── Dependencies
```

---

## 2. 카탈로그 엔티티 개념 및 계층 구조

### 2.1 엔티티 타입 개요

Backstage 카탈로그는 다음과 같은 계층적 엔티티 타입으로 구성됩니다:

#### 계층 구조
```
System (시스템)
  ↓ 포함
Domain (도메인)
  ↓ 포함
Component (컴포넌트) ← API를 providesApis/consumesApis → API (인터페이스)
  ↓ 의존
Resource (리소스)
```

#### 엔티티 타입별 역할

| 엔티티 타입 | 역할 | 파일 위치 | 관리 주체 |
|-----------|------|---------|----------|
| **System** | 전체 시스템/프로젝트 정의 | `rnd-backstage/catalog/systems/` | 플랫폼 팀 |
| **Domain** | 기능적 영역 그룹 | `rnd-backstage/catalog/domains/` | 플랫폼 팀 |
| **API** | 인터페이스 명세 | `rnd-backstage/catalog/apis/` | 플랫폼 팀 |
| **Resource** | 인프라 리소스 | `rnd-backstage/catalog/resources/` | DevOps 팀 |
| **Component** | 실제 구현 코드 | `RND-NX/**/catalog-info.yaml` | 각 컴포넌트 소유 팀 |
| **User** | 개별 사용자 | `rnd-backstage/examples/org.yaml` | 플랫폼 팀 |
| **Group** | 팀/조직 | `rnd-backstage/examples/org.yaml` | 플랫폼 팀 |

### 2.2 파일 배치 전략

#### Backstage 전용 파일 (rnd-backstage 프로젝트)
**목적**: 시스템 전체 구조와 공유 리소스 정의  
**특징**: 중앙 집중식 관리, 플랫폼 팀 책임

```
/Users/seojiwon/VNTG_PROJECT/rnd-backstage/
├── catalog/
│   ├── systems/
│   │   └── rnd-nx-framework.yaml       # System 정의
│   ├── domains/
│   │   └── all-domains.yaml            # Domain 정의 (모든 도메인)
│   ├── apis/
│   │   └── tech-blog-rest-api.yaml     # API 정의
│   └── resources/
│       ├── tech-blog-database.yaml     # Database
│       ├── kafka-cluster.yaml          # Message Broker
│       └── observability-stack.yaml    # Monitoring
└── examples/
    └── org.yaml                         # 조직 구조 (User, Group)
```

#### RND-NX Component 파일 (RND-NX 프로젝트)
**목적**: 실제 코드와 함께 컴포넌트 정의  
**특징**: 분산 관리, 각 팀이 자신의 컴포넌트 책임

```
/Users/seojiwon/VNTG_PROJECT/RND-NX/
├── apps/
│   └── tech-blog/
│       ├── api-server/
│       │   └── catalog-info.yaml       # Backend Component
│       └── user-client/
│           └── catalog-info.yaml       # Frontend Component
└── libs/
    ├── be/
    │   ├── auth/
    │   │   └── catalog-info.yaml       # Backend Library
    │   └── prisma/
    │       └── catalog-info.yaml       # Backend Library
    └── ui-component/
        └── catalog-info.yaml           # Frontend Library
```

### 2.3 엔티티 간 관계 정의

```yaml
# Component가 API를 제공
spec:
  providesApis:
    - tech-blog-rest-api

# Component가 API를 소비
spec:
  consumesApis:
    - tech-blog-rest-api

# Component가 Resource/Component에 의존
spec:
  dependsOn:
    - resource:tech-blog-database
    - component:be-auth-library
```

---

## 3. 조직 구조 및 권한 관리

이 섹션에서는 팀 구조와 권한을 정의합니다. 이 설정은 컴포넌트의 `owner` 필드에서 참조됩니다.

### 3.1 조직 구조 파일 작성

**파일 위치**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/examples/org.yaml`  
**관리 주체**: 플랫폼 팀  
**목적**: 사용자 및 팀 정의

```yaml
---
# 개별 사용자 정의
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: jidaisy
  annotations:
    backstage.io/managed-by-location: 'file:./org.yaml'
spec:
  profile:
    displayName: Ji Won Seo
    email: jidaisy@vntgcorp.com
    picture: https://avatars.githubusercontent.com/u/xxxxx
  memberOf: 
    - platform-team
    - backend-team

---
# 최상위 팀 - Platform Team
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: platform-team
  description: 플랫폼 엔지니어링 팀
spec:
  type: team
  profile:
    displayName: Platform Engineering Team
    email: platform@vntgcorp.com
    picture: https://example.com/team-logo.png
  children:
    - backend-team
    - frontend-team
    - design-team
    - devops-team

---
# Backend Team
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: backend-team
spec:
  type: team
  profile:
    displayName: Backend Team
    email: backend@vntgcorp.com
  parent: platform-team
  children: []

---
# Frontend Team
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: frontend-team
spec:
  type: team
  profile:
    displayName: Frontend Team
    email: frontend@vntgcorp.com
  parent: platform-team
  children: []

---
# Design Team
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: design-team
spec:
  type: team
  profile:
    displayName: Design System Team
    email: design@vntgcorp.com
  parent: platform-team
  children: []

---
# DevOps Team
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: devops-team
spec:
  type: team
  profile:
    displayName: DevOps Team
    email: devops@vntgcorp.com
  parent: platform-team
  children: []
```

### 3.2 사용자 권한 매트릭스

| 역할 | 권한 | 대상 컴포넌트 |
|------|------|--------------|
| platform-team | 읽기/쓰기/관리 | 모든 컴포넌트 |
| backend-team | 읽기/쓰기 | Backend Services, Shared Libraries (BE) |
| frontend-team | 읽기/쓰기 | Frontend Applications, Shared Libraries (FE) |
| design-team | 읽기/쓰기 | Design System Components |
| devops-team | 읽기/쓰기 | Infrastructure, Resources |
| guests | 읽기 전용 | 문서 및 API 명세 |

---

## 4. YAML 파일 작성 및 배치 가이드

이 섹션에서는 각 엔티티 타입별로 YAML 파일을 작성하고 올바른 위치에 배치하는 방법을 설명합니다.

### 4.1 Backstage 전용 YAML 파일 (시스템 레벨)

이 파일들은 rnd-backstage 프로젝트 내에 위치하며 플랫폼 팀이 중앙에서 관리합니다.

#### 4.1.1 System 정의

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/systems/rnd-nx-framework.yaml`

**목적**: 전체 RND-NX 프레임워크를 하나의 System으로 정의

**YAML 내용**:
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: rnd-nx-framework
  description: 차세대 통합 개발 프레임워크 - Nx 모노레포 기반
  tags:
    - nx
    - monorepo
    - enterprise
    - framework
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/techdocs-ref: url:https://github.com/vntg/RND-NX
  links:
    - url: https://github.com/vntg/RND-NX
      title: GitHub Repository
      icon: github
    - url: https://nx.dev
      title: Nx Documentation
      icon: docs
spec:
  owner: group:platform-team
  domain: engineering
```

#### 4.1.2 Domain 정의

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/domains/all-domains.yaml`

**목적**: 4개의 주요 도메인 정의 (Backend, Frontend, Shared Libraries, Infrastructure)

**YAML 내용**:
```yaml
---
# Domain 1: Backend Services
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: backend-services
  description: 백엔드 API 서버 및 마이크로서비스 도메인
  tags:
    - backend
    - api
    - microservices
spec:
  owner: group:backend-team

---
# Domain 2: Frontend Applications
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: frontend-applications
  description: 사용자 대면 프론트엔드 애플리케이션 도메인
  tags:
    - frontend
    - react
    - web
spec:
  owner: group:frontend-team

---
# Domain 3: Shared Libraries
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: shared-libraries
  description: 재사용 가능한 공유 라이브러리 도메인
  tags:
    - library
    - shared
    - reusable
spec:
  owner: group:platform-team

---
# Domain 4: Infrastructure
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: infrastructure
  description: 인프라 및 DevOps 리소스 도메인
  tags:
    - infrastructure
    - devops
    - resources
spec:
  owner: group:devops-team
```

#### 4.1.3 API 정의

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/apis/tech-blog-rest-api.yaml`

**목적**: Tech Blog API 인터페이스 정의 (구현과 분리된 명세)

**YAML 내용**:
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: tech-blog-rest-api
  description: Tech Blog RESTful API - 게시글, 댓글, 사용자 관리
  tags:
    - rest
    - openapi
    - nestjs
  links:
    - url: http://localhost:3001/api-docs
      title: API Documentation (Swagger)
      icon: docs
    - url: http://localhost:3001/api-docs-json
      title: OpenAPI Spec (JSON)
      icon: code
spec:
  type: openapi
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  # OpenAPI 스펙을 실행 중인 서버에서 가져오기
  definition:
    $text: http://localhost:3001/api-docs-json
```

**참고**: 이 API는 `tech-blog-api-server` Component에서 `providesApis`로 제공되고, `tech-blog-user-client` Component에서 `consumesApis`로 소비됩니다.

#### 4.1.4 Resource 정의

**파일 경로 1**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/resources/tech-blog-database.yaml`

```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: tech-blog-database
  description: Tech Blog PostgreSQL 데이터베이스
  tags:
    - postgresql
    - database
    - production
  annotations:
    backstage.io/managed-by-location: 'file:./tech-blog-database.yaml'
  links:
    - url: https://grafana.example.com/d/postgres-overview
      title: Database Monitoring Dashboard
      icon: dashboard
spec:
  type: database
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  dependsOn: []
```

**파일 경로 2**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/resources/kafka-cluster.yaml`

```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: kafka-cluster
  description: Kafka 메시징 클러스터 - 이벤트 스트리밍 및 비동기 통신
  tags:
    - kafka
    - messaging
    - event-streaming
spec:
  type: message-broker
  lifecycle: production
  owner: group:devops-team
  system: rnd-nx-framework
```

**파일 경로 3**: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/resources/observability-stack.yaml`

```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: observability-stack
  description: Loki-Grafana 로깅 및 모니터링 스택
  tags:
    - monitoring
    - logging
    - loki
    - grafana
spec:
  type: monitoring
  lifecycle: production
  owner: group:devops-team
  system: rnd-nx-framework
```

### 4.2 RND-NX Component YAML 파일 (구현 레벨)

이 파일들은 RND-NX 프로젝트 내 각 컴포넌트 디렉토리에 위치하며 각 팀이 관리합니다.

#### 4.2.1 Backend Service Component

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/catalog-info.yaml`

**목적**: Tech Blog API 서버 구현체 정의

**관계**:
- `providesApis`: tech-blog-rest-api (Backstage catalog/apis/에 정의됨)
- `dependsOn`: tech-blog-database (Resource), be-auth-library, be-prisma-library (Components)

**YAML 내용**:
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: tech-blog-api-server
  description: |
    Tech Blog NestJS API 서버
    - Prisma ORM을 사용한 PostgreSQL 연동
    - JWT 기반 인증/인가
    - RESTful API 제공
  tags:
    - nestjs
    - prisma
    - postgresql
    - api
    - typescript
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/apps/tech-blog/api-server
    backstage.io/techdocs-ref: dir:.
  links:
    - url: http://localhost:3001
      title: Local Development Server
      icon: web
    - url: http://localhost:3001/api-docs
      title: Swagger API Documentation
      icon: docs
spec:
  type: service
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: backend-services
  providesApis:
    - tech-blog-rest-api
  consumesApis: []
  dependsOn:
    - resource:tech-blog-database
    - component:be-auth-library
    - component:be-prisma-library
    - component:be-common-library
```

#### 4.2.2 Frontend Application Component

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/user-client/catalog-info.yaml`

**목적**: Tech Blog 사용자 클라이언트 정의

**관계**:
- `consumesApis`: tech-blog-rest-api (백엔드 API 사용)
- `dependsOn`: ui-component-library, design-tokens-library

**YAML 내용**:
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: tech-blog-user-client
  description: |
    Tech Blog React 사용자 클라이언트
    - Vite 기반 빌드
    - TailwindCSS 스타일링
    - React Router v6
  tags:
    - react
    - vite
    - frontend
    - tailwindcss
    - typescript
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/apps/tech-blog/user-client
    backstage.io/techdocs-ref: dir:.
  links:
    - url: http://localhost:5173
      title: Local Development Server
      icon: web
spec:
  type: website
  lifecycle: production
  owner: group:frontend-team
  system: rnd-nx-framework
  domain: frontend-applications
  providesApis: []
  consumesApis:
    - tech-blog-rest-api
  dependsOn:
    - component:ui-component-library
    - component:design-tokens-library
```

#### 4.2.3 Backend Library Component

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/RND-NX/libs/be/auth/catalog-info.yaml`

**목적**: 인증 라이브러리 정의

**YAML 내용**:
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-auth-library
  description: |
    API 서버 공용 인증 라이브러리
    - JWT 토큰 생성 및 검증
    - Passport.js 전략 (JWT, Local)
    - NestJS Guards
    - 인증/인가 데코레이터
  tags:
    - library
    - authentication
    - jwt
    - nestjs
    - passport
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/be/auth
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: shared-libraries
  providesApis: []
  consumesApis: []
  dependsOn: []
  subcomponentOf: rnd-nx-framework
```

#### 4.2.4 UI Component Library

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/RND-NX/libs/ui-component/catalog-info.yaml`

**목적**: 재사용 가능한 React 컴포넌트 라이브러리

**관계**:
- `dependsOn`: design-tokens-library (디자인 토큰 사용)

**YAML 내용**:
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ui-component-library
  description: |
    재사용 가능한 React 컴포넌트 라이브러리
    - Storybook으로 문서화
    - Tailwind CSS 스타일링
    - TypeScript 타입 정의
    - 디자인 토큰 통합
  tags:
    - react
    - components
    - storybook
    - design-system
    - typescript
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/ui-component
    backstage.io/techdocs-ref: dir:.
  links:
    - url: http://localhost:6006
      title: Storybook
      icon: dashboard
spec:
  type: library
  lifecycle: production
  owner: group:frontend-team
  system: rnd-nx-framework
  domain: shared-libraries
  providesApis: []
  consumesApis: []
  dependsOn:
    - component:design-tokens-library
```

#### 4.2.5 Design Tokens Library

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/RND-NX/libs/design-tokens/catalog-info.yaml`

**목적**: Figma 디자인 토큰 처리

**YAML 내용**:
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: design-tokens-library
  description: |
    Figma 디자인 토큰 처리 및 CSS 변수 생성
    - Figma API 연동
    - 디자인 토큰 파싱
    - CSS 변수 생성
    - 타입 정의 생성
  tags:
    - design-system
    - figma
    - tokens
    - css
    - typescript
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/design-tokens
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:design-team
  system: rnd-nx-framework
  domain: shared-libraries
  providesApis: []
  consumesApis: []
  dependsOn: []
```

#### 4.2.6 Backend Swagger Library

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/RND-NX/libs/be/swagger/catalog-info.yaml`

**목적**: Swagger/OpenAPI 문서 자동 생성 라이브러리

**YAML 내용**:
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-swagger-library
  description: |
    Swagger/OpenAPI 문서 자동 생성 라이브러리
    - NestJS Swagger 통합
    - API 문서 자동 생성
    - OpenAPI 스펙 생성
  tags:
    - library
    - swagger
    - openapi
    - documentation
    - nestjs
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/be/swagger
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: shared-libraries
  providesApis: []
  consumesApis: []
  dependsOn: []
```

#### 4.2.7 Backend Users Library

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/RND-NX/libs/be/users/catalog-info.yaml`

**목적**: 사용자 관리 공통 라이브러리

**YAML 내용**:
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-users-library
  description: |
    사용자 관리 공통 라이브러리
    - 사용자 CRUD 작업
    - 사용자 프로필 관리
    - 사용자 쿼리/커맨드 서비스
  tags:
    - library
    - users
    - user-management
    - nestjs
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/be/users
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: shared-libraries
  providesApis: []
  consumesApis: []
  dependsOn:
    - component:be-prisma-library
```

#### 4.2.8 Shared Library (Frontend/Backend 공통)

**파일 경로**: `/Users/seojiwon/VNTG_PROJECT/RND-NX/libs/shared/catalog-info.yaml`

**목적**: 프론트엔드/백엔드 공통 유틸리티 라이브러리

**YAML 내용**:
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: shared-library
  description: |
    프론트엔드/백엔드 공통 유틸리티 라이브러리
    - DI (의존성 주입) 유틸리티
    - HTTP 클라이언트
    - 공통 타입 정의
    - Repository 패턴
    - 서비스 레이어
  tags:
    - library
    - shared
    - utilities
    - typescript
    - fullstack
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/shared
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:platform-team
  system: rnd-nx-framework
  domain: shared-libraries
  providesApis: []
  consumesApis: []
  dependsOn: []
```

### 4.3 파일 배치 전체 구조

#### 4.3.1 RND-NX 프로젝트 구조

```
/Users/seojiwon/VNTG_PROJECT/RND-NX/
├── apps/
│   ├── tech-blog/
│   │   ├── api-server/
│   │   │   └── catalog-info.yaml       ← Backend Service
│   │   ├── user-client/
│   │   │   └── catalog-info.yaml       ← Frontend App
│   │   └── api-server-test/
│   │       └── catalog-info.yaml       ← Test Suite
│   └── ui_test/
│       └── catalog-info.yaml           ← UI Test App
└── libs/
    ├── be/
    │   ├── auth/
    │   │   └── catalog-info.yaml       ← 인증 라이브러리
    │   ├── common/
    │   │   └── catalog-info.yaml       ← 공통 기능 라이브러리
    │   ├── kafka-core/
    │   │   └── catalog-info.yaml       ← Kafka 통합 라이브러리
    │   ├── prisma/
    │   │   └── catalog-info.yaml       ← Prisma ORM 라이브러리
    │   ├── swagger/
    │   │   └── catalog-info.yaml       ← Swagger 문서 라이브러리
    │   ├── users/
    │   │   └── catalog-info.yaml       ← 사용자 관리 라이브러리
    │   └── websocket/
    │       └── catalog-info.yaml       ← WebSocket 라이브러리
    ├── design-tokens/
    │   └── catalog-info.yaml           ← 디자인 토큰 라이브러리
    ├── ui-component/
    │   └── catalog-info.yaml           ← UI 컴포넌트 라이브러리
    └── shared/
        └── catalog-info.yaml           ← 공통 유틸리티 라이브러리
```

#### 4.3.2 rnd-backstage 프로젝트 구조

```
/Users/seojiwon/VNTG_PROJECT/rnd-backstage/
├── app-config.yaml                   # 메인 설정 파일 (루트)
├── app-config.local.yaml             # 로컬 개발 설정 (루트)
├── app-config.production.yaml        # 프로덕션 설정 (루트)
├── backstage.json                    # Backstage 버전 정보
├── package.json                      # 의존성 관리
├── packages/
│   ├── app/                          # 프론트엔드 애플리케이션
│   │   ├── package.json
│   │   ├── public/
│   │   │   └── index.html
│   │   └── src/
│   │       ├── App.tsx
│   │       ├── apis.ts               # API 설정
│   │       └── components/
│   │           ├── catalog/
│   │           │   └── EntityPage.tsx
│   │           └── Root/
│   │               └── Root.tsx
│   └── backend/                      # 백엔드 서버
│       ├── package.json
│       ├── Dockerfile
│       └── src/
│           └── index.ts              # 백엔드 진입점
├── plugins/                          # 커스텀 플러그인 (선택사항)
│   └── README.md
├── examples/                         # 예시 카탈로그 파일들
│   ├── org.yaml                      # 조직 구조 (Users, Groups)
│   ├── entities.yaml                 # 예시 엔티티들
│   └── template/
│       ├── template.yaml             # 소프트웨어 템플릿
│       └── content/
│           └── catalog-info.yaml
├── catalog/                          # 카탈로그 정의 파일들 (생성 필요)
│   ├── systems/
│   │   └── rnd-nx-framework.yaml    # System 정의
│   ├── domains/
│   │   ├── backend-services.yaml    # Backend Domain
│   │   ├── frontend-applications.yaml
│   │   ├── shared-libraries.yaml
│   │   └── infrastructure.yaml
│   ├── apis/
│   │   └── tech-blog-rest-api.yaml  # API 정의
│   ├── resources/
│   │   ├── tech-blog-database.yaml  # Resource 정의
│   │   ├── kafka-cluster.yaml
│   │   └── observability-stack.yaml
│   └── all.yaml                      # 전체 카탈로그 통합 (선택사항)
├── templates/                        # 소프트웨어 템플릿 (생성 필요)
│   ├── nestjs-microservice/
│   │   ├── template.yaml
│   │   └── skeleton/
│   │       └── [템플릿 파일들]
│   └── react-component-library/
│       ├── template.yaml
│       └── skeleton/
│           └── [템플릿 파일들]
└── docs/                             # 프로젝트 문서
    └── README.md
```

#### 4.1.3 주요 파일 설명

##### Backstage 설정 파일들 (루트 위치)

**app-config.yaml**
- 위치: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/app-config.yaml`
- 목적: Backstage의 메인 설정 파일
- 내용: 카탈로그 위치, 인증 설정, 통합 설정, 백엔드 설정

**app-config.local.yaml**
- 위치: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/app-config.local.yaml`
- 목적: 로컬 개발 환경 전용 설정
- 내용: 로컬 데이터베이스 연결, 개발 모드 설정
- 주의: `.gitignore`에 포함하여 커밋하지 않음

**app-config.production.yaml**
- 위치: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/app-config.production.yaml`
- 목적: 프로덕션 환경 설정
- 내용: 프로덕션 데이터베이스, 보안 설정

##### 카탈로그 파일들

**examples/org.yaml**
- 위치: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/examples/org.yaml`
- 목적: 조직 구조 정의 (Users, Groups)
- 참조: `app-config.yaml`의 `catalog.locations`에서 참조됨

**catalog/ 디렉토리 (생성 필요)**
- 위치: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/`
- 목적: RND-NX와 분리된 Backstage 전용 카탈로그 정의
- 내용: System, Domain, API, Resource 정의 파일들

##### 애플리케이션 구조

**packages/app/**
- Backstage 프론트엔드 React 애플리케이션
- 사용자가 접근하는 UI

**packages/backend/**
- Backstage 백엔드 Node.js 서버
- 카탈로그 처리, API 제공, 플러그인 실행

#### 4.1.4 통합 디렉토리 구조

```
/Users/seojiwon/VNTG_PROJECT/
├── RND-NX/                           # 개발 프로젝트
│   ├── catalog-info.yaml
│   ├── apps/
│   │   └── [각 앱의 catalog-info.yaml]
│   └── libs/
│       └── [각 라이브러리의 catalog-info.yaml]
│
└── rnd-backstage/                    # Backstage 포털
    ├── app-config.yaml               ← 메인 설정 (여기서 RND-NX 참조)
    ├── app-config.local.yaml
    ├── app-config.production.yaml
    ├── packages/
    │   ├── app/                      ← 프론트엔드
    │   └── backend/                  ← 백엔드
    ├── examples/
    │   └── org.yaml                  ← 조직 구조
    ├── catalog/                      ← Backstage 전용 카탈로그
    │   ├── systems/
    │   ├── domains/
    │   ├── apis/
    │   └── resources/
    └── templates/                    ← 프로젝트 템플릿
        ├── nestjs-microservice/
        └── react-component-library/
```

### 4.2 Backstage 카탈로그 등록 설정

#### 4.2.1 설정 파일 위치 및 역할

Backstage 카탈로그 등록은 **rnd-backstage 프로젝트 루트**에 위치한 `app-config.yaml` 파일에서 관리됩니다.

**파일 경로:**
```
/Users/seojiwon/VNTG_PROJECT/rnd-backstage/app-config.yaml
```

**역할:**
- RND-NX 프로젝트의 컴포넌트들을 Backstage 카탈로그에 등록
- 외부 카탈로그 파일들(System, Domain, API 등)의 위치 지정
- 조직 구조(Users, Groups) 파일 참조
- 카탈로그 규칙 및 검증 설정

**설정 우선순위:**
1. `app-config.yaml` - 기본 설정 (모든 환경에서 공통)
2. `app-config.local.yaml` - 로컬 개발 환경 오버라이드
3. `app-config.production.yaml` - 프로덕션 환경 오버라이드

#### 4.2.2 app-config.yaml 전체 구조

**파일 위치:** `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/app-config.yaml`

**목적**: Backstage의 모든 설정을 관리하는 메인 설정 파일

**전체 YAML 구조**:

```yaml
# Backstage 애플리케이션 기본 설정
app:
  title: RND-NX Backstage Portal
  baseUrl: http://localhost:3000

# 조직 정보
organization:
  name: VNTG

# 백엔드 설정
backend:
  # 서비스 간 인증을 위한 시크릿
  auth:
    keys:
      - secret: ${BACKEND_SECRET}
    externalAccess:
      - type: static
        options:
          token: ${EXTERNAL_SECRET}
          subject: admin-curl-access
        accessRestrictions:
          - plugin: catalog
  
  baseUrl: http://localhost:7007
  listen:
    port: 7007
  
  # CORS 설정
  cors:
    origin: http://localhost:3000
    methods: [GET, HEAD, PATCH, POST, PUT, DELETE]
    credentials: true
  
  # 데이터베이스 설정
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}

# GitHub 통합
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}

# 프록시 설정 (필요시)
proxy:
  # 예시: 외부 API 프록시
  # '/api':
  #   target: 'https://api.example.com'
  #   changeOrigin: true

# TechDocs 설정
techdocs:
  builder: 'local'
  generator:
    runIn: 'docker'
  publisher:
    type: 'local'

# 인증 설정
auth:
  autologout:
    enabled: true
    idleTimeoutMinutes: 30
    promptBeforeIdleSeconds: 10
    useWorkerTimers: true
    logoutIfDisconnected: true
  
  environment: development
  
  providers:
    google:
      development:
        clientId: ${AUTH_GOOGLE_CLIENT_ID}
        clientSecret: ${AUTH_GOOGLE_CLIENT_SECRET}
        sessionDuration: { hours: 24 }
        additionalScopes:
          - openid
          - profile
          - email
        signIn:
          resolvers:
            - resolver: emailMatchingUserEntityAnnotation
            - resolver: emailMatchingUserEntityProfileEmail

# Scaffolder 설정 (템플릿 기반 프로젝트 생성)
scaffolder:
  # 템플릿 관련 설정

# ========================================
# 카탈로그 설정 (가장 중요!)
# ========================================
catalog:
  import:
    entityFilename: catalog-info.yaml
    pullRequestBranchName: backstage-integration
  
  # 허용할 엔티티 타입
  rules:
    - allow: [Component, System, API, Resource, Location, Domain, Group, User]
  
  # 카탈로그 파일 위치 정의
  locations:
    # ===== Backstage 내부 카탈로그 =====
    
    # System 정의
    - type: file
      target: ../../catalog/systems/rnd-nx-framework.yaml
      rules:
        - allow: [System]
    
    # Domain 정의
    - type: file
      target: ../../catalog/domains/all-domains.yaml
      rules:
        - allow: [Domain]
    
    # API 정의
    - type: file
      target: ../../catalog/apis/tech-blog-rest-api.yaml
      rules:
        - allow: [API]
    
    # Resource 정의
    - type: file
      target: ../../catalog/resources/tech-blog-database.yaml
      rules:
        - allow: [Resource]
    
    - type: file
      target: ../../catalog/resources/kafka-cluster.yaml
      rules:
        - allow: [Resource]
    
    - type: file
      target: ../../catalog/resources/observability-stack.yaml
      rules:
        - allow: [Resource]
    
    # 조직 구조 (Users, Groups)
    - type: file
      target: ../../examples/org.yaml
      rules:
        - allow: [User, Group]
    
    # ===== RND-NX 프로젝트 컴포넌트 =====
    
    # Backend Services
    - type: file
      target: ../RND-NX/apps/tech-blog/api-server/catalog-info.yaml
      rules:
        - allow: [Component]
    
    # Frontend Applications
    - type: file
      target: ../RND-NX/apps/tech-blog/user-client/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: file
      target: ../RND-NX/apps/ui_test/catalog-info.yaml
      rules:
        - allow: [Component]
    
    # Backend Libraries (개별 지정 - 명시적 관리)
    - type: file
      target: ../RND-NX/libs/be/auth/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: file
      target: ../RND-NX/libs/be/common/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: file
      target: ../RND-NX/libs/be/kafka-core/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: file
      target: ../RND-NX/libs/be/prisma/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: file
      target: ../RND-NX/libs/be/swagger/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: file
      target: ../RND-NX/libs/be/users/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: file
      target: ../RND-NX/libs/be/websocket/catalog-info.yaml
      rules:
        - allow: [Component]
    
    # Frontend/Design Libraries
    - type: file
      target: ../RND-NX/libs/design-tokens/catalog-info.yaml
      rules:
        - allow: [Component]
    
    - type: file
      target: ../RND-NX/libs/ui-component/catalog-info.yaml
      rules:
        - allow: [Component]
    
    # Shared Library
    - type: file
      target: ../RND-NX/libs/shared/catalog-info.yaml
      rules:
        - allow: [Component]
    
    # 테스트 프로젝트
    - type: file
      target: ../RND-NX/apps/tech-blog/api-server-test/catalog-info.yaml
      rules:
        - allow: [Component]
    
    # ===== 예시 카탈로그 (선택사항) =====
    
    # Backstage 기본 예시
    - type: file
      target: ../../examples/entities.yaml
    
    # 템플릿
    - type: file
      target: ../../examples/template/template.yaml
      rules:
        - allow: [Template]

# Kubernetes 통합 (선택사항)
kubernetes:
  # Kubernetes 클러스터 설정

# 권한 설정
permission:
  enabled: true
  # RBAC 정책 정의
```

#### 4.2.3 app-config.yaml 주요 섹션 설명

**1. app 섹션**
```yaml
app:
  title: RND-NX Backstage Portal  # 브라우저 탭 제목
  baseUrl: http://localhost:3000  # 프론트엔드 URL
```

**2. backend 섹션**
```yaml
backend:
  baseUrl: http://localhost:7007  # 백엔드 API URL
  listen:
    port: 7007                     # 백엔드 포트
  database:
    client: pg                     # PostgreSQL 사용
    connection:
      host: ${POSTGRES_HOST}       # 환경 변수 사용
```

**3. integrations 섹션**
```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}       # GitHub Personal Access Token
```

**4. auth 섹션**
```yaml
auth:
  providers:
    google:
      development:
        clientId: ${AUTH_GOOGLE_CLIENT_ID}
        clientSecret: ${AUTH_GOOGLE_CLIENT_SECRET}
```

**5. catalog 섹션 (핵심!)**
```yaml
catalog:
  locations:
    # Backstage 내부 파일
    - type: file
      target: ../../catalog/systems/rnd-nx-framework.yaml
    
    # RND-NX 프로젝트 파일
    - type: file
      target: ../RND-NX/apps/tech-blog/api-server/catalog-info.yaml
```

#### 4.2.3 경로 설명 및 주의사항

**상대 경로 기준점**

모든 `target` 경로는 **Backstage 백엔드가 실행되는 위치**를 기준으로 합니다.

```
실행 위치: /Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend/
```

따라서:
- `../RND-NX/catalog-info.yaml`는 `/Users/seojiwon/VNTG_PROJECT/RND-NX/catalog-info.yaml`를 의미
- `../../catalog/all.yaml`는 `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/all.yaml`를 의미
- `../../examples/org.yaml`는 `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/examples/org.yaml`를 의미

**경로 변환 예시:**

| catalog locations의 target | 실제 파일 절대 경로 |
|---------------------------|-------------------|
| `../RND-NX/catalog-info.yaml` | `/Users/seojiwon/VNTG_PROJECT/RND-NX/catalog-info.yaml` |
| `../RND-NX/apps/tech-blog/api-server/catalog-info.yaml` | `/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/catalog-info.yaml` |
| `../RND-NX/libs/**/catalog-info.yaml` | `/Users/seojiwon/VNTG_PROJECT/RND-NX/libs/` 하위 모든 `catalog-info.yaml` |
| `../../catalog/all.yaml` | `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/all.yaml` |
| `../../examples/org.yaml` | `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/examples/org.yaml` |

**주의사항:**

1. **백엔드 실행 위치 기준**
   - `yarn dev` 또는 `yarn start` 실행 시 백엔드는 `packages/backend/`에서 실행됩니다
   - 경로는 항상 이 위치를 기준으로 계산됩니다

2. **Glob 패턴 지원**
   - `**/catalog-info.yaml`와 같은 glob 패턴 사용 가능
   - 디렉토리 구조가 깊어도 자동으로 찾아줍니다

3. **파일 존재 확인**
   - Backstage 시작 시 모든 `target` 파일이 존재하는지 확인합니다
   - 파일이 없으면 경고 로그가 출력됩니다

4. **동적 업데이트**
   - 파일이 변경되면 Backstage가 자동으로 감지하여 카탈로그를 업데이트합니다
   - 개발 모드에서는 즉시 반영, 프로덕션에서는 설정된 주기마다 업데이트

#### 4.2.4 디렉토리 생성 체크리스트

Backstage를 처음 설정할 때 다음 디렉토리들을 생성해야 합니다:

**rnd-backstage 프로젝트 내:**
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# 카탈로그 디렉토리 생성
mkdir -p catalog/systems
mkdir -p catalog/domains
mkdir -p catalog/apis
mkdir -p catalog/resources

# 템플릿 디렉토리 생성
mkdir -p templates/nestjs-microservice/skeleton
mkdir -p templates/react-component-library/skeleton
```

**RND-NX 프로젝트 내:**
```bash
cd /Users/seojiwon/VNTG_PROJECT/RND-NX

# 루트에 catalog-info.yaml 생성 (System 정의)
touch catalog-info.yaml

# 각 컴포넌트에 catalog-info.yaml 생성
touch apps/tech-blog/api-server/catalog-info.yaml
touch apps/tech-blog/user-client/catalog-info.yaml
touch libs/be/auth/catalog-info.yaml
# ... 기타 컴포넌트들
```

### 4.3 YAML 파일 작성 가이드

이 섹션에서는 Backstage 카탈로그에 사용되는 각 YAML 파일의 구체적인 작성 방법을 설명합니다.

#### 4.3.1 RND-NX와 Backstage YAML 파일 간의 관계

```
┌─────────────────────────────────────────────────────────────────────┐
│                     Backstage 카탈로그 구조                            │
│                                                                     │
│  ┌────────────────────────────────────────────────────────┐         │
│  │  rnd-backstage/catalog/                                │         │
│  │  (Backstage 전용 정의 - 상위 레벨)                         │         │
│  │                                                       │         │
│  │  ├── systems/rnd-nx-framework.yaml ──────┐            │         │
│  │  │   System 정의                          │            │         │
│  │  │                                        ▼           │         │
│  │  ├── domains/backend-services.yaml       관계          │         │
│  │  │   Domain 정의                          정의          │         │
│  │  │                                       │            │         │
│  │  ├── apis/tech-blog-rest-api.yaml        │            │         │
│  │  │   API 정의                             │            │         │
│  │  │                                       │            │         │
│  │  └── resources/tech-blog-database.yaml   │            │         │
│  │      Resource 정의                        │            │         │
│  └──────────────────────────────────────────┼────────────┘         │
│                                             │                      │
│                                             │                      │
│  ┌──────────────────────────────────────────┼────────────┐         │
│  │  RND-NX/                                 │            │         │
│  │  (실제 코드와 함께 위치 - 컴포넌트 레벨)          │            │         │
│  │                                           ▼           │         │
│  │  ├── apps/tech-blog/api-server/          참조          │         │
│  │  │   catalog-info.yaml ◄─────────────────┘            │         │
│  │  │   Component 정의                                    │         │
│  │  │   (providesApis: tech-blog-rest-api)               │         │
│  │  │   (dependsOn: tech-blog-database)                  │         │
│  │  │                                                    │         │
│  │  └── libs/be/auth/catalog-info.yaml                   │         │
│  │      Component 정의                                    │         │
│  └───────────────────────────────────────────────────────┘         │
│                                                                    │
│  app-config.yaml이 모든 파일을 참조하여 통합 카탈로그 구성                   │
└────────────────────────────────────────────────────────────────────┘
```

**관계 설명:**

1. **Backstage 전용 YAML (rnd-backstage/catalog/)**
   - **목적**: 시스템 전체 구조와 공유 리소스 정의
   - **위치**: Backstage 프로젝트 내부
   - **관리**: 플랫폼 팀이 중앙에서 관리
   - **내용**: System, Domain, API 인터페이스, Resource

2. **RND-NX YAML (RND-NX/**/catalog-info.yaml)**
   - **목적**: 실제 구현 컴포넌트 정의
   - **위치**: 코드와 같은 디렉토리
   - **관리**: 각 컴포넌트 소유 팀이 관리
   - **내용**: Component (Service, Website, Library)

3. **연결 메커니즘**
   - RND-NX의 Component가 Backstage의 API/Resource를 **참조**
   - `providesApis`: 어떤 API를 제공하는지
   - `consumesApis`: 어떤 API를 사용하는지
   - `dependsOn`: 어떤 Resource나 Component에 의존하는지

#### 4.3.2 Backstage 전용 YAML 파일 작성

##### System 정의 (rnd-backstage/catalog/systems/rnd-nx-framework.yaml)

```yaml
---
# System: 최상위 엔티티, 전체 프레임워크를 대표
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: rnd-nx-framework
  description: 차세대 통합 개발 프레임워크 - Nx 모노레포 기반
  tags:
    - nx
    - monorepo
    - enterprise
    - framework
  annotations:
    # GitHub 저장소 연결
    github.com/project-slug: vntg/RND-NX
    # 문서 위치 (선택사항)
    backstage.io/techdocs-ref: url:https://github.com/vntg/RND-NX
  links:
    - url: https://github.com/vntg/RND-NX
      title: GitHub Repository
      icon: github
    - url: https://nx.dev
      title: Nx Documentation
      icon: docs
spec:
  owner: group:platform-team
  domain: engineering
```

##### Domain 정의 (rnd-backstage/catalog/domains/backend-services.yaml)

```yaml
---
# Domain: 기능적 영역별 그룹
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: backend-services
  description: 백엔드 API 서버 및 마이크로서비스 도메인
  tags:
    - backend
    - api
    - microservices
spec:
  owner: group:backend-team

---
# 하나의 파일에 여러 Domain 정의 가능
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: frontend-applications
  description: 사용자 대면 프론트엔드 애플리케이션 도메인
  tags:
    - frontend
    - react
    - web
spec:
  owner: group:frontend-team

---
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: shared-libraries
  description: 재사용 가능한 공유 라이브러리 도메인
  tags:
    - library
    - shared
    - reusable
spec:
  owner: group:platform-team

---
apiVersion: backstage.io/v1alpha1
kind: Domain
metadata:
  name: infrastructure
  description: 인프라 및 DevOps 리소스 도메인
  tags:
    - infrastructure
    - devops
    - resources
spec:
  owner: group:devops-team
```

##### API 정의 (rnd-backstage/catalog/apis/tech-blog-rest-api.yaml)

```yaml
---
# API: 인터페이스 정의 (구현과 분리)
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: tech-blog-rest-api
  description: Tech Blog RESTful API - 게시글, 댓글, 사용자 관리
  tags:
    - rest
    - openapi
    - nestjs
  links:
    - url: http://localhost:3001/api-docs
      title: API Documentation (Swagger)
      icon: docs
    - url: http://localhost:3001/api-docs-json
      title: OpenAPI Spec (JSON)
      icon: code
spec:
  type: openapi
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  # OpenAPI 스펙 정의 (3가지 방법)
  definition:
    # 방법 1: URL에서 가져오기 (권장)
    $text: http://localhost:3001/api-docs-json
    
    # 방법 2: 파일에서 가져오기
    # $text: ./openapi.yaml
    
    # 방법 3: 직접 정의
    # openapi: "3.0.0"
    # info:
    #   title: Tech Blog API
    #   version: 1.0.0
    # paths:
    #   /posts:
    #     get:
    #       summary: Get all posts
```

##### Resource 정의 (rnd-backstage/catalog/resources/tech-blog-database.yaml)

```yaml
---
# Resource: 물리적/논리적 인프라 리소스
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: tech-blog-database
  description: Tech Blog PostgreSQL 데이터베이스
  tags:
    - postgresql
    - database
    - production
  annotations:
    # 데이터베이스 연결 정보는 민감 정보이므로 직접 기재하지 않음
    backstage.io/managed-by-location: 'file:./tech-blog-database.yaml'
  links:
    - url: https://grafana.example.com/d/postgres-overview
      title: Database Monitoring Dashboard
      icon: dashboard
spec:
  type: database
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  dependsOn: []  # 다른 리소스에 의존하지 않음

---
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: kafka-cluster
  description: Kafka 메시징 클러스터 - 이벤트 스트리밍 및 비동기 통신
  tags:
    - kafka
    - messaging
    - event-streaming
spec:
  type: message-broker
  lifecycle: production
  owner: group:devops-team
  system: rnd-nx-framework

---
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: observability-stack
  description: Loki-Grafana 로깅 및 모니터링 스택
  tags:
    - monitoring
    - logging
    - loki
    - grafana
spec:
  type: monitoring
  lifecycle: production
  owner: group:devops-team
  system: rnd-nx-framework
```

##### 통합 카탈로그 (rnd-backstage/catalog/all.yaml)

```yaml
---
# 선택사항: 모든 Backstage 전용 엔티티를 한 파일에 모을 수도 있음
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: rnd-nx-catalog
  description: RND-NX 프레임워크 카탈로그 통합
spec:
  type: file
  targets:
    - ./systems/rnd-nx-framework.yaml
    - ./domains/*.yaml
    - ./apis/*.yaml
    - ./resources/*.yaml
```

#### 

##### 백엔드 서비스 Component (RND-NX/apps/tech-blog/api-server/catalog-info.yaml)

```yaml
---
# Component: 실제 구현체 (서비스)
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: tech-blog-api-server
  description: |
    Tech Blog NestJS API 서버
    - Prisma ORM을 사용한 PostgreSQL 연동
    - JWT 기반 인증/인가
    - RESTful API 제공
  tags:
    - nestjs
    - prisma
    - postgresql
    - api
    - typescript
  annotations:
    # GitHub 저장소 경로
    github.com/project-slug: vntg/RND-NX
    # 이 컴포넌트의 소스 코드 경로
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/apps/tech-blog/api-server
    # TechDocs 문서 위치
    backstage.io/techdocs-ref: dir:.
  links:
    - url: http://localhost:3001
      title: Local Development Server
      icon: web
    - url: http://localhost:3001/api-docs
      title: Swagger API Documentation
      icon: docs
    - url: https://github.com/vntg/RND-NX/tree/main/apps/tech-blog/api-server
      title: Source Code
      icon: github
spec:
  type: service
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: backend-services
  
  # 이 서비스가 제공하는 API (Backstage catalog/apis/에 정의된 것 참조)
  providesApis:
    - tech-blog-rest-api
  
  # 이 서비스가 사용하는 API (없음)
  consumesApis: []
  
  # 이 서비스가 의존하는 리소스/컴포넌트
  dependsOn:
    - resource:tech-blog-database      # Backstage catalog/resources/에 정의됨
    - component:be-auth-library        # RND-NX/libs/be/auth/에 정의됨
    - component:be-prisma-library      # RND-NX/libs/be/prisma/에 정의됨
    - component:be-common-library      # RND-NX/libs/be/common/에 정의됨
```

##### 프론트엔드 애플리케이션 Component (RND-NX/apps/tech-blog/user-client/catalog-info.yaml)

```yaml
---
# Component: 프론트엔드 애플리케이션
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: tech-blog-user-client
  description: |
    Tech Blog React 사용자 클라이언트
    - Vite 기반 빌드
    - TailwindCSS 스타일링
    - React Router v6
  tags:
    - react
    - vite
    - frontend
    - tailwindcss
    - typescript
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/apps/tech-blog/user-client
    backstage.io/techdocs-ref: dir:.
  links:
    - url: http://localhost:5173
      title: Local Development Server
      icon: web
    - url: https://github.com/vntg/RND-NX/tree/main/apps/tech-blog/user-client
      title: Source Code
      icon: github
spec:
  type: website
  lifecycle: production
  owner: group:frontend-team
  system: rnd-nx-framework
  domain: frontend-applications
  
  # 프론트엔드는 API를 제공하지 않음
  providesApis: []
  
  # 프론트엔드가 사용하는 API
  consumesApis:
    - tech-blog-rest-api              # 백엔드 API 사용
  
  # 프론트엔드가 의존하는 라이브러리
  dependsOn:
    - component:ui-component-library
    - component:design-tokens-library
```

##### 공유 라이브러리 Component (RND-NX/libs/be/auth/catalog-info.yaml)

```yaml
---
# Component: 공유 라이브러리
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-auth-library
  description: |
    API 서버 공용 인증 라이브러리
    - JWT 토큰 생성 및 검증
    - Passport.js 전략 (JWT, Local)
    - NestJS Guards
    - 인증/인가 데코레이터
  tags:
    - library
    - authentication
    - jwt
    - nestjs
    - passport
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/be/auth
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: shared-libraries
  
  # 라이브러리는 API를 제공하지 않음 (내부 사용)
  providesApis: []
  consumesApis: []
  
  # 이 라이브러리의 의존성
  dependsOn: []
  
  # 선택사항: 이 라이브러리가 시스템의 일부임을 명시
  subcomponentOf: rnd-nx-framework
```

##### UI 컴포넌트 라이브러리 (RND-NX/libs/ui-component/catalog-info.yaml)

```yaml
---
# Component: UI 컴포넌트 라이브러리
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ui-component-library
  description: |
    재사용 가능한 React 컴포넌트 라이브러리
    - Storybook으로 문서화
    - Tailwind CSS 스타일링
    - TypeScript 타입 정의
    - 디자인 토큰 통합
  tags:
    - react
    - components
    - storybook
    - design-system
    - typescript
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/ui-component
    backstage.io/techdocs-ref: dir:.
  links:
    - url: http://localhost:6006
      title: Storybook
      icon: dashboard
    - url: https://github.com/vntg/RND-NX/tree/main/libs/ui-component
      title: Source Code
      icon: github
spec:
  type: library
  lifecycle: production
  owner: group:frontend-team
  system: rnd-nx-framework
  domain: shared-libraries
  
  providesApis: []
  consumesApis: []
  
  # 디자인 토큰 라이브러리에 의존
  dependsOn:
    - component:design-tokens-library
```

##### 디자인 토큰 라이브러리 (RND-NX/libs/design-tokens/catalog-info.yaml)

```yaml
---
# Component: 디자인 토큰 라이브러리
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: design-tokens-library
  description: |
    Figma 디자인 토큰 처리 및 CSS 변수 생성
    - Figma API 연동
    - 디자인 토큰 파싱
    - CSS 변수 생성
    - 타입 정의 생성
  tags:
    - design-system
    - figma
    - tokens
    - css
    - typescript
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/design-tokens
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:design-team
  system: rnd-nx-framework
  domain: shared-libraries
  
  providesApis: []
  consumesApis: []
  dependsOn: []  # 최하위 의존성
```

##### 백엔드 공통 라이브러리 (RND-NX/libs/be/common/catalog-info.yaml)

```yaml
---
# Component: 백엔드 공통 라이브러리
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-common-library
  description: |
    백엔드 공통 유틸리티 라이브러리
    - 공통 예외 처리
    - 공통 데코레이터
    - 유틸리티 함수
    - 공통 인터페이스 및 타입
    - 상수 및 Enum
  tags:
    - library
    - utilities
    - nestjs
    - typescript
    - common
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/be/common
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: shared-libraries
  
  providesApis: []
  consumesApis: []
  dependsOn: []
  
  subcomponentOf: rnd-nx-framework
```

##### Prisma ORM 라이브러리 (RND-NX/libs/be/prisma/catalog-info.yaml)

```yaml
---
# Component: Prisma ORM 라이브러리
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-prisma-library
  description: |
    Prisma ORM 통합 라이브러리
    - Prisma Client 설정 및 제공
    - 데이터베이스 스키마 관리
    - 마이그레이션 도구
    - 트랜잭션 헬퍼
    - 데이터베이스 연결 풀링
  tags:
    - library
    - prisma
    - orm
    - database
    - postgresql
    - nestjs
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/be/prisma
    backstage.io/techdocs-ref: dir:.
  links:
    - url: https://www.prisma.io/docs
      title: Prisma Documentation
      icon: docs
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: shared-libraries
  
  providesApis: []
  consumesApis: []
  
  # Prisma는 데이터베이스에 의존
  dependsOn:
    - resource:tech-blog-database
  
  subcomponentOf: rnd-nx-framework
```

##### Kafka 코어 라이브러리 (RND-NX/libs/be/kafka-core/catalog-info.yaml)

```yaml
---
# Component: Kafka 코어 라이브러리
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-kafka-core-library
  description: |
    Kafka 메시징 통합 라이브러리
    - KafkaJS 래퍼
    - Producer/Consumer 설정
    - 토픽 관리
    - 메시지 직렬화/역직렬화
    - 재시도 및 에러 핸들링
    - 이벤트 드리븐 아키텍처 지원
  tags:
    - library
    - kafka
    - messaging
    - event-driven
    - microservices
    - nestjs
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/be/kafka-core
    backstage.io/techdocs-ref: dir:.
  links:
    - url: https://kafka.js.org/docs/getting-started
      title: KafkaJS Documentation
      icon: docs
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: shared-libraries
  
  providesApis: []
  consumesApis: []
  
  # Kafka 클러스터에 의존
  dependsOn:
    - resource:kafka-cluster
  
  subcomponentOf: rnd-nx-framework
```

##### WebSocket 라이브러리 (RND-NX/libs/be/websocket/catalog-info.yaml)

```yaml
---
# Component: WebSocket 라이브러리
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-websocket-library
  description: |
    WebSocket 실시간 통신 라이브러리
    - Socket.io 통합
    - 실시간 메시지 전송
    - 룸/네임스페이스 관리
    - 인증 및 권한 검증
    - 이벤트 핸들러
  tags:
    - library
    - websocket
    - realtime
    - socket.io
    - nestjs
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/be/websocket
    backstage.io/techdocs-ref: dir:.
  links:
    - url: https://socket.io/docs/v4/
      title: Socket.io Documentation
      icon: docs
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: shared-libraries
  
  providesApis: []
  consumesApis: []
  
  # 인증 라이브러리에 의존
  dependsOn:
    - component:be-auth-library
  
  subcomponentOf: rnd-nx-framework
```

##### Swagger API 문서화 라이브러리 (RND-NX/libs/be/swagger/catalog-info.yaml)

```yaml
---
# Component: Swagger API 문서화 라이브러리
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-swagger-library
  description: |
    Swagger/OpenAPI 통합 라이브러리
    - Swagger UI 설정
    - OpenAPI 스펙 자동 생성
    - API 데코레이터
    - DTO 문서화
    - 인증 스키마 설정
  tags:
    - library
    - swagger
    - openapi
    - api-documentation
    - nestjs
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/be/swagger
    backstage.io/techdocs-ref: dir:.
  links:
    - url: https://swagger.io/docs/
      title: Swagger Documentation
      icon: docs
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: shared-libraries
  
  providesApis: []
  consumesApis: []
  dependsOn: []
  
  subcomponentOf: rnd-nx-framework
```

##### 사용자 관리 라이브러리 (RND-NX/libs/be/users/catalog-info.yaml)

```yaml
---
# Component: 사용자 관리 라이브러리
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-users-library
  description: |
    사용자 관리 공통 라이브러리
    - 사용자 CRUD 로직
    - 사용자 프로필 관리
    - 사용자 권한 검증
    - 사용자 검색 및 필터링
    - 공통 사용자 DTO 및 Entity
  tags:
    - library
    - users
    - user-management
    - nestjs
    - typescript
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/be/users
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: shared-libraries
  
  providesApis: []
  consumesApis: []
  
  # Prisma와 Auth에 의존
  dependsOn:
    - component:be-prisma-library
    - component:be-auth-library
    - component:be-common-library
  
  subcomponentOf: rnd-nx-framework
```

##### 공유 라이브러리 (RND-NX/libs/shared/catalog-info.yaml)

```yaml
---
# Component: 공유 라이브러리
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: shared-library
  description: |
    프론트엔드/백엔드 공유 라이브러리
    - 공통 타입 정의
    - 공통 상수
    - 공통 인터페이스
    - 검증 스키마
    - 유틸리티 함수
  tags:
    - library
    - shared
    - typescript
    - fullstack
    - utilities
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/libs/shared
    backstage.io/techdocs-ref: dir:.
spec:
  type: library
  lifecycle: production
  owner: group:platform-team
  system: rnd-nx-framework
  domain: shared-libraries
  
  providesApis: []
  consumesApis: []
  dependsOn: []  # 최하위 의존성
  
  subcomponentOf: rnd-nx-framework
```

##### API 서버 테스트 프로젝트 (RND-NX/apps/tech-blog/api-server-test/catalog-info.yaml)

```yaml
---
# Component: API 서버 테스트 프로젝트
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: tech-blog-api-server-test
  description: |
    Tech Blog API 서버 통합 테스트 프로젝트
    - E2E 테스트
    - API 통합 테스트
    - 부하 테스트
    - 성능 테스트
  tags:
    - testing
    - e2e
    - integration-test
    - jest
    - typescript
  annotations:
    github.com/project-slug: vntg/RND-NX
    backstage.io/source-location: url:https://github.com/vntg/RND-NX/tree/main/apps/tech-blog/api-server-test
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
  lifecycle: experimental
  owner: group:backend-team
  system: rnd-nx-framework
  domain: backend-services
  
  providesApis: []
  
  # 테스트 대상 API를 소비
  consumesApis:
    - tech-blog-rest-api
  
  # 테스트 대상 서비스에 의존
  dependsOn:
    - component:tech-blog-api-server
```

#### 4.3.4 조직 구조 YAML (rnd-backstage/examples/org.yaml)

```yaml
---
# User: 개별 사용자
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: jidaisy
  annotations:
    backstage.io/managed-by-location: 'file:./org.yaml'
spec:
  profile:
    displayName: Ji Won Seo
    email: jidaisy@vntgcorp.com
    picture: https://avatars.githubusercontent.com/u/xxxxx
  memberOf: 
    - platform-team
    - backend-team

---
# Group: 팀/그룹
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: platform-team
  description: 플랫폼 엔지니어링 팀
spec:
  type: team
  profile:
    displayName: Platform Engineering Team
    email: platform@vntgcorp.com
    picture: https://example.com/team-logo.png
  # 하위 팀들
  children:
    - backend-team
    - frontend-team
    - design-team
    - devops-team

---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: backend-team
spec:
  type: team
  profile:
    displayName: Backend Team
    email: backend@vntgcorp.com
  parent: platform-team
  children: []

---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: frontend-team
spec:
  type: team
  profile:
    displayName: Frontend Team
    email: frontend@vntgcorp.com
  parent: platform-team
  children: []

---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: design-team
spec:
  type: team
  profile:
    displayName: Design System Team
    email: design@vntgcorp.com
  parent: platform-team
  children: []

---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: devops-team
spec:
  type: team
  profile:
    displayName: DevOps Team
    email: devops@vntgcorp.com
  parent: platform-team
  children: []
```

#### 4.3.5 YAML 작성 모범 사례

##### 필수 필드
```yaml
# 모든 엔티티의 필수 필드
apiVersion: backstage.io/v1alpha1  # 버전 (고정)
kind: Component                     # 엔티티 타입
metadata:
  name: my-component               # 고유 식별자 (소문자, 하이픈)
spec:
  type: service                    # 컴포넌트 타입
  lifecycle: production            # 생명주기
  owner: group:backend-team        # 소유자
```

##### 네이밍 규칙
```yaml
# 좋은 예
name: tech-blog-api-server
name: be-auth-library
name: ui-component-library

# 나쁜 예
name: TechBlogAPIServer          # 대문자 사용 금지
name: tech_blog_api_server       # 언더스코어 대신 하이픈
name: api-server                 # 너무 일반적
```

##### 태그 사용
```yaml
tags:
  - nestjs            # 기술 스택
  - api               # 유형
  - production        # 환경
  - critical          # 중요도
```

##### 링크 추가
```yaml
links:
  - url: https://github.com/org/repo
    title: Source Code
    icon: github
  - url: https://api.example.com/docs
    title: API Documentation
    icon: docs
  - url: https://grafana.example.com
    title: Monitoring Dashboard
    icon: dashboard
```

#### 4.3.6 의존성 관계 표현 방법

```yaml
# Component A가 Component B를 사용하는 경우
# Component A의 catalog-info.yaml
spec:
  dependsOn:
    - component:component-b        # 다른 컴포넌트
    - resource:database-a          # 리소스

# Component A가 API를 제공하는 경우
spec:
  providesApis:
    - my-rest-api                  # API 이름

# Component A가 API를 사용하는 경우
spec:
  consumesApis:
    - external-api                 # API 이름
```

#### 4.3.7 검증 체크리스트

카탈로그 YAML 파일 작성 후 다음을 확인하세요:

- [ ] YAML 문법이 유효한가? (온라인 YAML validator 사용)
- [ ] `name`이 고유하고 규칙을 따르는가?
- [ ] `owner`가 존재하는 Group/User를 참조하는가?
- [ ] `dependsOn`, `providesApis`, `consumesApis`의 참조가 정확한가?
- [ ] 필수 필드가 모두 포함되어 있는가?
- [ ] `system`과 `domain`이 올바르게 설정되어 있는가?
- [ ] 태그가 의미있고 일관성 있게 사용되었는가?

---

## 5. 기술 문서 통합 (TechDocs)

### 5.1 TechDocs 설정

각 컴포넌트에 대한 기술 문서는 다음 구조를 따릅니다:

```
component-directory/
├── catalog-info.yaml
├── README.md
├── docs/
│   ├── index.md              # 메인 문서
│   ├── getting-started.md    # 시작 가이드
│   ├── architecture.md       # 아키텍처
│   ├── api-reference.md      # API 레퍼런스
│   └── development.md        # 개발 가이드
└── mkdocs.yml                # MkDocs 설정
```

### 5.2 MkDocs 템플릿

```yaml
site_name: '[Component Name] Documentation'
site_description: '[Component Description]'

nav:
  - Home: index.md
  - Getting Started: getting-started.md
  - Architecture: architecture.md
  - API Reference: api-reference.md
  - Development: development.md

theme:
  name: material
  palette:
    primary: indigo
    accent: indigo

plugins:
  - techdocs-core
```

### 5.3 주요 컴포넌트 문서화 우선순위

1. **High Priority**:
   - tech-blog-api-server
   - tech-blog-user-client
   - ui-component-library
   - design-tokens-library

2. **Medium Priority**:
   - be-auth-library
   - be-common-library
   - be-kafka-core-library
   - be-prisma-library

3. **Low Priority**:
   - be-websocket-library
   - ui-test-app
   - tech-blog-api-server-test

---

## 6. 소프트웨어 템플릿 (Scaffolder)

### 6.1 템플릿 정의

#### Template: NestJS Microservice
```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: nestjs-microservice-template
  title: NestJS Microservice
  description: Nx 통합 NestJS 마이크로서비스 생성
  tags:
    - recommended
    - nestjs
    - microservice
spec:
  owner: group:backend-team
  type: service
  parameters:
    - title: 서비스 정보
      required:
        - name
        - description
      properties:
        name:
          title: 서비스 이름
          type: string
          description: 마이크로서비스 이름 (예: user-service)
        description:
          title: 설명
          type: string
          description: 서비스에 대한 간단한 설명
        owner:
          title: 소유자
          type: string
          description: 팀 또는 개인
          ui:field: OwnerPicker
          ui:options:
            catalogFilter:
              kind: Group
  steps:
    - id: fetch-base
      name: Fetch Base Template
      action: fetch:template
      input:
        url: ./skeleton
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}
    
    - id: publish
      name: Publish to GitHub
      action: publish:github:pull-request
      input:
        repoUrl: github.com?repo=RND-NX&owner=vntg
        branchName: add-${{ parameters.name }}
        title: Add ${{ parameters.name }} microservice
        description: Auto-generated microservice from Backstage template
    
    - id: register
      name: Register Component
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: '/apps/${{ parameters.name }}/catalog-info.yaml'
  
  output:
    links:
      - title: Repository
        url: ${{ steps.publish.output.remoteUrl }}
      - title: Open in Catalog
        icon: catalog
        entityRef: ${{ steps.register.output.entityRef }}
```

#### Template: React Component Library
```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: react-component-library-template
  title: React Component Library
  description: Nx 통합 React 컴포넌트 라이브러리 생성
  tags:
    - recommended
    - react
    - library
spec:
  owner: group:frontend-team
  type: library
  parameters:
    - title: 라이브러리 정보
      required:
        - name
        - description
      properties:
        name:
          title: 라이브러리 이름
          type: string
          description: 컴포넌트 라이브러리 이름
        description:
          title: 설명
          type: string
        owner:
          title: 소유자
          type: string
          ui:field: OwnerPicker
  steps:
    - id: fetch-base
      name: Fetch Base Template
      action: fetch:template
      input:
        url: ./skeleton-react-lib
        values:
          name: ${{ parameters.name }}
          description: ${{ parameters.description }}
    
    - id: publish
      name: Create Pull Request
      action: publish:github:pull-request
      input:
        repoUrl: github.com?repo=RND-NX&owner=vntg
        branchName: add-lib-${{ parameters.name }}
        title: Add ${{ parameters.name }} library
    
    - id: register
      name: Register Component
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: '/libs/${{ parameters.name }}/catalog-info.yaml'
  
  output:
    links:
      - title: Repository
        url: ${{ steps.publish.output.remoteUrl }}
      - title: Open in Catalog
        icon: catalog
        entityRef: ${{ steps.register.output.entityRef }}
```

---

## 7. 플러그인 및 통합

### 7.1 권장 플러그인

#### 7.1.1 코어 플러그인
- **@backstage/plugin-catalog**: 소프트웨어 카탈로그
- **@backstage/plugin-techdocs**: 기술 문서화
- **@backstage/plugin-scaffolder**: 프로젝트 템플릿

#### 7.1.2 개발 도구 플러그인
- **@backstage/plugin-kubernetes**: K8s 클러스터 통합
- **@backstage/plugin-github-actions**: CI/CD 파이프라인 가시성
- **@backstage/plugin-sonarqube**: 코드 품질 모니터링

#### 7.1.3 모니터링 플러그인
- **@backstage/plugin-grafana**: Grafana 대시보드 통합
- **@backstage/plugin-prometheus**: Prometheus 메트릭

#### 7.1.4 Nx 특화 플러그인
- **@nx-tools/backstage-plugin-nx**: Nx 프로젝트 그래프 시각화
  - 의존성 그래프 표시
  - 프로젝트 간 관계 파악
  - 영향 분석 (affected projects)

### 7.2 통합 구성

#### GitHub 통합
```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
      apps:
        - appId: ${GITHUB_APP_ID}
          privateKey: ${GITHUB_APP_PRIVATE_KEY}
          webhookSecret: ${GITHUB_WEBHOOK_SECRET}
          clientId: ${GITHUB_CLIENT_ID}
          clientSecret: ${GITHUB_CLIENT_SECRET}
```

#### Kubernetes 통합
```yaml
kubernetes:
  serviceLocatorMethod:
    type: 'multiTenant'
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - url: ${K8S_CLUSTER_URL}
          name: production
          authProvider: 'serviceAccount'
          serviceAccountToken: ${K8S_SA_TOKEN}
          caData: ${K8S_CA_DATA}
```

---

## 8. 구현 로드맵

### Phase 1: 기본 설정 (Week 1-2)
- [ ] Backstage 초기 설정 완료
- [ ] PostgreSQL 데이터베이스 구성
- [ ] Google OAuth 인증 설정
- [ ] 조직 구조 (Groups, Users) 정의

### Phase 2: 카탈로그 구조화 (Week 3-4)
- [ ] System 및 Domain 정의
- [ ] 주요 컴포넌트 catalog-info.yaml 작성
  - [ ] tech-blog-api-server
  - [ ] tech-blog-user-client
  - [ ] be-auth-library
  - [ ] ui-component-library
  - [ ] design-tokens-library
- [ ] API 및 Resource 정의
- [ ] 의존성 그래프 검증

### Phase 3: 문서화 (Week 5-6)
- [ ] TechDocs 설정
- [ ] 주요 컴포넌트 문서 작성
  - [ ] 아키텍처 문서
  - [ ] 시작 가이드
  - [ ] API 레퍼런스
- [ ] README 및 개발 가이드 통합

### Phase 4: 템플릿 개발 (Week 7-8)
- [ ] NestJS Microservice 템플릿
- [ ] React Component Library 템플릿
- [ ] Shared Library 템플릿
- [ ] 템플릿 테스트 및 검증

### Phase 5: 플러그인 통합 (Week 9-10)
- [ ] GitHub Actions 플러그인
- [ ] Kubernetes 플러그인
- [ ] Nx 프로젝트 그래프 플러그인
- [ ] Grafana 모니터링 통합

### Phase 6: 자동화 및 최적화 (Week 11-12)
- [ ] CI/CD 파이프라인 통합
- [ ] 자동 카탈로그 업데이트
- [ ] 권한 정책 최적화
- [ ] 성능 모니터링 및 튜닝

---

## 9. 모니터링 및 메트릭

### 9.1 추적할 메트릭

#### 개발자 경험 메트릭
- 카탈로그 검색 빈도
- 문서 조회 횟수
- 템플릿 사용 빈도
- 평균 프로젝트 생성 시간

#### 시스템 건강성 메트릭
- 컴포넌트 업데이트 빈도
- 문서 최신성 (last updated)
- 의존성 그래프 깊이
- 비활성 컴포넌트 수

#### 협업 메트릭
- 팀별 컴포넌트 소유 분포
- 크로스팀 의존성 수
- API 재사용 비율

### 9.2 대시보드 구성

```yaml
# Grafana Dashboard for Backstage
dashboard:
  title: "RND-NX Platform Health"
  panels:
    - title: "Total Components"
      query: "count(backstage_catalog_entities{kind='Component'})"
    
    - title: "Components by Team"
      query: "sum by (owner) (backstage_catalog_entities{kind='Component'})"
    
    - title: "Documentation Coverage"
      query: "sum(backstage_techdocs_pages) / sum(backstage_catalog_entities{kind='Component'})"
    
    - title: "Template Usage"
      query: "rate(backstage_scaffolder_task_total[1h])"
```

---

## 10. 보안 및 거버넌스

### 10.1 접근 제어 정책

#### RBAC 정책 예시
```yaml
permission:
  enabled: true
  policy:
    - permission: catalog.entity.create
      allow:
        - group: platform-team
        - group: backend-team
        - group: frontend-team
    
    - permission: catalog.entity.delete
      allow:
        - group: platform-team
    
    - permission: catalog.entity.read
      allow:
        - group: guests
        - group: developers
        - group: admins
    
    - permission: scaffolder.action.execute
      allow:
        - group: backend-team
        - group: frontend-team
```

### 10.2 감사 로그

```yaml
# 감사 추적 대상
audit:
  events:
    - entity.create
    - entity.update
    - entity.delete
    - template.execute
    - user.login
    - user.logout
  
  storage:
    type: postgresql
    retention: 90days
```

### 10.3 컴플라이언스

#### 카탈로그 검증 규칙
- 모든 컴포넌트는 owner 필수
- 모든 서비스는 최소 1개의 API 정의 필요
- 모든 프로덕션 컴포넌트는 README.md 필수
- lifecycle이 'deprecated'인 컴포넌트는 대체 컴포넌트 링크 필수

---

## 11. 멀티 레포지토리 관리 전략

### 11.1 개요

Backstage는 **단일 포털에서 여러 독립적인 레포지토리를 통합 관리**할 수 있도록 설계되었습니다. 
현재 문서는 RND-NX 레포지토리를 예시로 설명하고 있지만, 동일한 방식으로 다른 레포지토리들도 추가할 수 있습니다.

#### 왜 멀티 레포 관리가 중요한가?

현대 조직에서는 다음과 같은 이유로 여러 레포지토리를 운영합니다:

1. **기술 스택 분리**: 백엔드(Java/Spring), 프론트엔드(React), 모바일(Swift/Kotlin), 인프라(Terraform)
2. **팀 분리**: 각 팀이 독립적인 레포지토리에서 작업
3. **라이프사이클 분리**: 신규 프로젝트 vs 레거시 시스템
4. **보안/권한 관리**: 민감한 코드를 별도 레포에 격리

**문제점**: 
- 프로젝트가 많아질수록 전체 시스템을 파악하기 어려움
- 서비스 간 의존성 관계가 불명확
- 각 프로젝트의 소유자, 문서, API 스펙을 찾기 어려움
- 중복된 작업이나 라이브러리가 발생

**Backstage 솔루션**:
- **단일 진실의 원천(Single Source of Truth)**: 모든 소프트웨어 자산을 한곳에서 조회
- **자동 검색(Discovery)**: 새로운 레포가 추가되면 자동으로 카탈로그에 등록
- **관계 시각화**: 서로 다른 레포의 컴포넌트 간 의존성을 그래프로 표시
- **통합 검색**: 수십~수백 개의 레포에서 필요한 서비스나 API를 즉시 검색

### 11.2 멀티 레포 구조 예시

```
회사/조직
├── rnd-backstage/          # Backstage 포털 (단일)
│   └── catalog/            # 중앙 카탈로그 정의
│       ├── systems/
│       ├── domains/
│       └── resources/
│
├── RND-NX/                 # 프로젝트 1 (차세대 프레임워크)
│   ├── apps/
│   ├── libs/
│   └── catalog-info.yaml
│
├── legacy-erp/             # 프로젝트 2 (레거시 ERP)
│   ├── backend/
│   │   └── catalog-info.yaml
│   └── frontend/
│       └── catalog-info.yaml
│
├── mobile-app/             # 프로젝트 3 (모바일 앱)
│   ├── ios/
│   │   └── catalog-info.yaml
│   └── android/
│       └── catalog-info.yaml
│
└── infra-terraform/        # 프로젝트 4 (인프라 코드)
    └── catalog-info.yaml
```

### 11.3 다른 레포지토리 추가 방법

#### 11.3.1 단계별 가이드

**Step 1: 추가할 레포지토리에 catalog-info.yaml 작성**

예시: `legacy-erp` 레포지토리

```yaml
# /path/to/legacy-erp/catalog-info.yaml
---
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: legacy-erp-system
  description: 레거시 ERP 시스템
  tags:
    - erp
    - legacy
    - java
spec:
  owner: group:erp-team
  domain: enterprise-applications

---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: legacy-erp-backend
  description: ERP 백엔드 서버 (Spring Boot)
  tags:
    - java
    - spring-boot
    - erp
  annotations:
    github.com/project-slug: vntg/legacy-erp
    backstage.io/source-location: url:https://github.com/vntg/legacy-erp/tree/main/backend
spec:
  type: service
  lifecycle: production
  owner: group:erp-team
  system: legacy-erp-system
  providesApis:
    - legacy-erp-rest-api
  dependsOn:
    - resource:erp-oracle-database
```

**Step 2: rnd-backstage의 app-config.yaml에 경로 추가**

```yaml
# /Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend/app-config.yaml
catalog:
  locations:
    # ===== 기존 RND-NX 프로젝트 =====
    - type: file
      target: ../RND-NX/catalog-info.yaml
    
    - type: file
      target: ../RND-NX/apps/tech-blog/api-server/catalog-info.yaml
    
    # ... (기존 RND-NX 엔트리들)
    
    # ===== 새로운 레포지토리 추가 =====
    
    # Legacy ERP 시스템
    - type: file
      target: ../legacy-erp/catalog-info.yaml
      rules:
        - allow: [System, Component, API, Resource]
    
    - type: file
      target: ../legacy-erp/backend/catalog-info.yaml
    
    - type: file
      target: ../legacy-erp/frontend/catalog-info.yaml
    
    # Mobile App 프로젝트
    - type: file
      target: ../mobile-app/catalog-info.yaml
    
    # Terraform 인프라
    - type: file
      target: ../infra-terraform/catalog-info.yaml
    
    # ===== GitHub 통합 (선택사항) =====
    # GitHub 저장소를 직접 참조할 수도 있습니다
    - type: url
      target: https://github.com/vntg/another-project/blob/main/catalog-info.yaml
      rules:
        - allow: [Component, API]
```

**Step 3: 조직 구조에 팀 추가 (필요시)**

```yaml
# rnd-backstage/examples/org.yaml
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: erp-team
  description: 레거시 ERP 유지보수 팀
spec:
  type: team
  profile:
    displayName: ERP Team
    email: erp@vntgcorp.com
  parent: engineering
  children: []

---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: mobile-team
  description: 모바일 앱 개발 팀
spec:
  type: team
  profile:
    displayName: Mobile Team
    email: mobile@vntgcorp.com
  parent: engineering
  children: []
```

**Step 4: Backstage 재시작**

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn dev
```

### 11.4 레포지토리 위치별 관리 전략

Backstage는 레포지토리의 위치와 관계없이 카탈로그에 등록할 수 있습니다. 
각 방법마다 장단점이 있으므로, 조직의 상황에 맞는 전략을 선택하세요.

#### 11.4.1 로컬 레포지토리 (권장)

**설명:**
로컬 파일 시스템에 모든 레포지토리를 클론하고, 상대 경로로 참조하는 방식입니다.
개발 환경에서 가장 효율적이며, 실시간 동기화가 가능합니다.

**장점:**
- ⚡ **빠른 동기화**: 네트워크 지연 없이 즉시 카탈로그 업데이트
- 🔄 **실시간 반영**: 파일 변경 시 자동 감지 (watch mode)
- 🧪 **로컬 테스트**: 프로덕션 배포 전 로컬에서 검증 가능
- 🔒 **오프라인 작업**: 인터넷 연결 없이도 Backstage 사용 가능
- 🐛 **디버깅 용이**: 로컬 파일을 직접 수정하며 테스트 가능

**단점:**
- 💾 디스크 공간 사용 (모든 레포를 클론해야 함)
- 🔄 정기적인 git pull 필요
- 🖥️ 로컬 환경에만 적용 (팀원 각자 설정 필요)

**사용 시나리오:**
- 개발 환경 (`yarn dev`)
- 소규모 팀 (5-10개 레포)
- 자주 변경되는 카탈로그 구조를 테스트할 때

**구조:**
```
/Users/seojiwon/VNTG_PROJECT/
├── rnd-backstage/          # Backstage 포털
├── RND-NX/                 # 프로젝트 1
├── legacy-erp/             # 프로젝트 2
├── mobile-app/             # 프로젝트 3
└── infra-terraform/        # 프로젝트 4
```

**app-config.yaml 설정:**
```yaml
catalog:
  locations:
    # 상대 경로 사용 (packages/backend/가 기준)
    - type: file
      target: ../RND-NX/catalog-info.yaml
    - type: file
      target: ../legacy-erp/catalog-info.yaml
    - type: file
      target: ../mobile-app/catalog-info.yaml
    
    # Glob 패턴으로 여러 파일 한번에
    - type: file
      target: ../RND-NX/apps/**/catalog-info.yaml
    - type: file
      target: ../RND-NX/libs/**/catalog-info.yaml
```

**설정 후 확인:**
```bash
# Backstage 실행
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn dev

# 브라우저에서 확인
# http://localhost:3000/catalog
# - 모든 레포의 컴포넌트가 표시되는지 확인
# - 파일을 수정하고 자동 업데이트되는지 확인
```

#### 11.4.2 GitHub URL 참조

**설명:**
GitHub에 호스팅된 레포지토리의 파일을 URL로 직접 참조하는 방식입니다.
로컬에 클론하지 않고도 원격 레포지토리의 카탈로그를 가져올 수 있습니다.

**장점:**
- 🌐 **로컬 클론 불필요**: 디스크 공간 절약, 설정 간단
- 🌍 **원격 팀 협업**: 다른 지역/팀의 레포지토리도 즉시 통합
- 📌 **최신 상태 유지**: 항상 GitHub의 main/master 브랜치를 참조
- 🚀 **빠른 시작**: 설정 파일만 수정하면 즉시 사용 가능
- 🔐 **권한 관리 용이**: GitHub의 권한 시스템 활용

**단점:**
- ⏱️ **동기화 지연**: 설정된 주기(예: 30분)마다 업데이트
- 🌐 **네트워크 의존성**: 인터넷 연결 필수
- 📊 **API 제한**: GitHub API rate limit (인증 시 5,000회/시간)
- 🐛 **디버깅 어려움**: 문제 발생 시 로컬에서 직접 수정 불가
- 🔒 **Private 레포**: Personal Access Token 필요

**사용 시나리오:**
- 프로덕션 환경
- 대규모 팀 (10개 이상 레포)
- 외부 팀이나 다른 조직의 레포를 통합할 때
- 레포지토리를 로컬에 클론하기 어려운 경우

**app-config.yaml 설정:**
```yaml
catalog:
  locations:
    # GitHub URL로 직접 참조
    - type: url
      target: https://github.com/vntg/RND-NX/blob/main/catalog-info.yaml
      rules:
        - allow: [Component, System, API, Resource]
    
    - type: url
      target: https://github.com/vntg/legacy-erp/blob/main/catalog-info.yaml
    
    # 특정 브랜치 지정 가능
    - type: url
      target: https://github.com/vntg/mobile-app/blob/develop/catalog-info.yaml
    
    # Glob 패턴으로 여러 파일 참조
    - type: url
      target: https://github.com/vntg/data-platform/blob/main/*/catalog-info.yaml

# GitHub 인증 설정 (Private 레포용)
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}  # Personal Access Token
      # 필요한 권한: repo (전체 저장소 액세스)
```

**GitHub Token 생성 방법:**
```bash
# 1. GitHub 웹사이트에서:
# Settings → Developer settings → Personal access tokens → Generate new token
# 필요한 권한: repo (Full control of private repositories)

# 2. 환경 변수로 설정:
echo "GITHUB_TOKEN=ghp_xxxxxxxxxxxx" >> .env

# 3. Backstage 재시작
yarn dev
```

**주의사항:**
- GitHub API rate limit를 초과하지 않도록 주의
- Token을 코드에 직접 넣지 말고 환경 변수 사용
- 정기적인 Token 갱신 필요 (만료 기간 설정)

#### 11.4.3 GitHub Discovery (자동 검색)

**설명:**
GitHub Organization의 모든 레포지토리를 자동으로 스캔하여 `catalog-info.yaml` 파일을 찾아 등록하는 방식입니다.
**가장 강력하고 확장 가능한 방법**으로, 대규모 조직에 적합합니다.

**핵심 개념:**
Backstage가 GitHub Organization을 주기적으로 스캔하여:
1. 모든 레포지토리를 검색
2. 각 레포에서 `catalog-info.yaml` 파일을 찾음
3. 자동으로 카탈로그에 등록
4. 새로운 레포가 추가되면 자동 검색

**장점:**
- 🤖 **완전 자동화**: 새 레포 추가 시 수동 설정 불필요
- 📈 **확장성**: 수백 개의 레포지토리도 관리 가능
- 🔄 **자동 동기화**: 설정된 주기마다 자동 업데이트
- 🎯 **필터링**: 특정 레포만 선택적으로 포함/제외 가능
- 🏢 **조직 레벨 관리**: Organization 전체를 한번에 관리
- 📋 **표준화**: 모든 레포가 동일한 규칙으로 등록됨

**단점:**
- ⚙️ **초기 설정 복잡**: 세밀한 필터 설정 필요
- 🐢 **초기 스캔 시간**: 레포가 많으면 첫 스캔이 오래 걸림
- 📊 **API 사용량**: Organization 전체 스캔으로 많은 API 호출
- 🔍 **디버깅 어려움**: 자동화로 인한 문제 추적 어려움
- 💰 **비용**: 대규모 Organization의 경우 GitHub API 비용

**사용 시나리오:**
- 대규모 조직 (20개 이상 레포)
- 지속적으로 새로운 프로젝트가 생성되는 환경
- 표준화된 카탈로그 구조를 강제하고 싶을 때
- DevOps 팀이 중앙에서 모든 레포를 관리할 때

**app-config.yaml 설정:**
```yaml
catalog:
  locations:
    # 기본 방법: GitHub Organization 전체 스캔
    - type: github-discovery
      target: https://github.com/vntg
      rules:
        - allow: [Component, System, API, Resource, Template]
  
  providers:
    github:
      # Provider 이름 (여러 Organization 관리 시 구분용)
      vntgOrg:
        organization: 'vntg'              # GitHub Organization 이름
        catalogPath: '/catalog-info.yaml'  # 검색할 파일 경로
        
        # 필터 설정
        filters:
          branch: 'main'                   # 특정 브랜치만 스캔
          repository: '.*'                 # 정규식: 모든 레포
          
          # 특정 레포만 포함
          # repository: '^(RND-NX|legacy-erp|mobile-app)$'
          
          # 특정 레포 제외
          # repository: '^(?!.*-archived).*$'  # -archived로 끝나는 레포 제외
          
          # 여러 조건
          # repository:
          #   - '^frontend-.*'   # frontend-로 시작하는 레포
          #   - '^backend-.*'    # backend-로 시작하는 레포
        
        # 자동 동기화 스케줄
        schedule:
          frequency: { minutes: 30 }       # 30분마다 스캔
          timeout: { minutes: 3 }          # 스캔 타임아웃
          initialDelay: { seconds: 15 }    # 시작 후 15초 대기

# GitHub 인증 (필수)
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
      # Organization 스캔을 위해서는 다음 권한 필요:
      # - repo: Private 레포 액세스
      # - read:org: Organization 정보 읽기
```

**고급 설정 예시:**

```yaml
# 여러 Organization 관리
catalog:
  providers:
    github:
      # 메인 Organization
      mainOrg:
        organization: 'vntg'
        catalogPath: '/catalog-info.yaml'
        filters:
          branch: 'main'
          repository: '.*'
        schedule:
          frequency: { minutes: 30 }
      
      # 외부 파트너 Organization
      partnerOrg:
        organization: 'partner-company'
        catalogPath: '/backstage/catalog-info.yaml'  # 다른 경로
        filters:
          branch: 'production'
          repository: '^public-.*'  # public-로 시작하는 것만
        schedule:
          frequency: { hours: 2 }  # 2시간마다 (덜 자주)
      
      # 개인 레포 (자신의 계정)
      personalRepos:
        organization: 'seojiwon'  # GitHub 사용자 이름
        catalogPath: '/catalog-info.yaml'
        filters:
          branch: 'main'
        schedule:
          frequency: { hours: 6 }  # 6시간마다
```

**필터링 패턴 예시:**

```yaml
filters:
  # 1. 특정 프리픽스만
  repository: '^(frontend-|backend-|infra-).*'
  
  # 2. 특정 서픽스 제외
  repository: '^(?!.*-archived$).*'
  
  # 3. 특정 단어 포함
  repository: '.*-service$'  # -service로 끝나는 것만
  
  # 4. 여러 브랜치
  branch: '(main|master|production)'
  
  # 5. 특정 레포 명시적 나열
  repository: '^(RND-NX|tech-blog|mobile-app)$'
```

**동작 흐름:**

```
1. Backstage 시작
   ↓
2. 15초 대기 (initialDelay)
   ↓
3. GitHub Organization 스캔 시작
   ↓
4. 모든 레포지토리 목록 가져오기
   ↓
5. 필터 적용 (branch, repository)
   ↓
6. 각 레포에서 catalog-info.yaml 검색
   ↓
7. 발견된 파일을 카탈로그에 등록
   ↓
8. 30분 대기
   ↓
9. 3단계로 돌아가서 반복
```

**모니터링 및 디버깅:**

```bash
# Backstage 로그 확인
yarn dev

# 로그에서 다음을 확인:
# [catalog] GitHub provider 'vntgOrg' discovered 42 repositories
# [catalog] Processed 127 catalog entities
# [catalog] Failed to process 3 entities (errors will be shown)

# 실패한 엔티티 확인
# http://localhost:3000/catalog?filters[kind]=location
# - Unprocessed Entities 섹션에서 오류 확인
```

**비용 고려사항:**

| Organization 크기 | 레포 수 | API 호출/시간 | 권장 주기 |
|-----------------|--------|-------------|----------|
| 소규모 | 1-20 | ~100 | 15분 |
| 중규모 | 20-100 | ~500 | 30분 |
| 대규모 | 100-500 | ~2,500 | 1시간 |
| 초대규모 | 500+ | ~10,000+ | 2-4시간 |

**참고:** GitHub API rate limit은 인증된 요청 기준 5,000회/시간입니다.

### 11.5 실전 예시: 3개 레포지토리 통합

#### 시나리오
- **RND-NX**: 차세대 프레임워크 (NestJS, React)
- **legacy-erp**: 레거시 ERP (Spring Boot, Angular)
- **data-platform**: 데이터 플랫폼 (Python, Airflow)

#### app-config.yaml 통합 설정

```yaml
# /Users/seojiwon/VNTG_PROJECT/rnd-backstage/app-config.yaml

catalog:
  rules:
    - allow: [Component, System, API, Resource, Location, Template, Domain, Group, User]
  
  locations:
    # ===== Backstage 내부 카탈로그 =====
    - type: file
      target: ../../catalog/all.yaml
    
    - type: file
      target: ../../examples/org.yaml
    
    # ===== RND-NX 프레임워크 =====
    - type: file
      target: ../RND-NX/catalog-info.yaml  # System 정의
    
    - type: file
      target: ../RND-NX/apps/**/catalog-info.yaml
    
    - type: file
      target: ../RND-NX/libs/**/catalog-info.yaml
    
    # ===== Legacy ERP =====
    - type: file
      target: ../legacy-erp/catalog-info.yaml  # System 정의
    
    - type: file
      target: ../legacy-erp/backend/catalog-info.yaml
    
    - type: file
      target: ../legacy-erp/frontend/catalog-info.yaml
    
    # ===== Data Platform =====
    - type: file
      target: ../data-platform/catalog-info.yaml  # System 정의
    
    - type: file
      target: ../data-platform/airflow/dags/**/catalog-info.yaml
    
    - type: file
      target: ../data-platform/pipelines/**/catalog-info.yaml
```

#### 카탈로그 구조

```
Backstage 카탈로그
│
├── System: rnd-nx-framework
│   ├── Domain: backend-services
│   │   ├── Component: tech-blog-api-server
│   │   └── Component: be-auth-library
│   └── Domain: frontend-applications
│       └── Component: tech-blog-user-client
│
├── System: legacy-erp-system
│   ├── Domain: erp-backend
│   │   └── Component: legacy-erp-backend
│   └── Domain: erp-frontend
│       └── Component: legacy-erp-frontend
│
└── System: data-platform-system
    ├── Domain: data-pipelines
    │   ├── Component: user-analytics-pipeline
    │   └── Component: sales-etl-pipeline
    └── Domain: orchestration
        └── Component: airflow-scheduler
```

### 11.6 크로스 레포지토리 의존성 관리

**핵심 개념:**
Backstage의 가장 강력한 기능 중 하나는 **서로 다른 레포지토리의 컴포넌트 간 의존성을 표현하고 시각화**할 수 있다는 점입니다.

#### 왜 중요한가?

마이크로서비스 아키텍처나 멀티 레포 환경에서는:
- 서비스 A(레포1)가 서비스 B(레포2)의 API를 호출
- 프론트엔드(레포3)가 백엔드(레포4)의 API를 사용
- 공통 라이브러리(레포5)를 여러 프로젝트에서 참조

이러한 **크로스 레포 의존성을 관리하지 않으면**:
- 어떤 서비스가 어떤 API를 사용하는지 파악 어려움
- API 변경 시 영향받는 서비스를 찾기 어려움
- 시스템 전체 아키텍처를 이해하기 어려움
- 장애 발생 시 원인 추적 어려움

#### Backstage의 의존성 표현 방법

Backstage는 3가지 관계 타입으로 의존성을 표현합니다:

| 관계 타입 | 설명 | 사용 예시 |
|----------|------|----------|
| `dependsOn` | 다른 컴포넌트나 리소스에 의존 | 서비스가 데이터베이스에 의존 |
| `consumesApis` | 다른 컴포넌트의 API를 사용 | 프론트엔드가 백엔드 API 호출 |
| `providesApis` | 자신이 제공하는 API 정의 | 백엔드 서비스가 REST API 제공 |

#### 실전 예시 1: RND-NX 서비스 → Data Platform API

**시나리오:**
- RND-NX 레포의 `analytics-service`가 
- Data Platform 레포의 `analytics-api`를 호출하고
- Data Platform 레포의 `data-warehouse` 데이터베이스를 사용

**RND-NX/apps/analytics-service/catalog-info.yaml:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: analytics-service
  description: 분석 서비스 (Data Platform API 사용)
  tags:
    - analytics
    - nestjs
    - cross-repo-dependency
  annotations:
    github.com/project-slug: vntg/RND-NX
spec:
  type: service
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework  # 자신이 속한 System
  
  # ✅ 다른 레포지토리의 API를 소비
  consumesApis:
    - data-platform-analytics-api  # data-platform 레포에서 정의
  
  # ✅ 다른 레포지토리의 리소스에 의존
  dependsOn:
    - resource:data-warehouse      # data-platform 레포에서 정의
    - component:be-auth-library    # 같은 레포의 컴포넌트도 가능
```

**data-platform/catalog-info.yaml:**
```yaml
# API 정의 (다른 레포에서 참조 가능)
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: data-platform-analytics-api  # ← RND-NX에서 이 이름으로 참조
  description: 데이터 플랫폼 분석 API
  tags:
    - analytics
    - data
    - openapi
spec:
  type: openapi
  lifecycle: production
  owner: group:data-team
  system: data-platform-system
  definition:
    $text: https://data-platform.internal/api/openapi.json

---
# Resource 정의 (다른 레포에서 참조 가능)
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: data-warehouse  # ← RND-NX에서 이 이름으로 참조
  description: 중앙 데이터 웨어하우스 (BigQuery)
  tags:
    - database
    - bigquery
    - data-warehouse
spec:
  type: database
  lifecycle: production
  owner: group:data-team
  system: data-platform-system
```

**Backstage에서 보이는 의존성 그래프:**
```
┌─────────────────────────────────────────┐
│ System: rnd-nx-framework                │
│                                         │
│  ┌──────────────────────────┐           │
│  │ analytics-service        │           │
│  │ (RND-NX 레포)            │           │
│  └──────────┬───────┬───────┘           │
│             │       │                   │
└─────────────┼───────┼───────────────────┘
              │       │
    consumesApis     dependsOn
              │       │
┌─────────────▼───────▼───────────────────┐
│ System: data-platform-system            │
│                                         │
│  ┌─────────────────────┐                │
│  │ analytics-api       │                │
│  │ (data-platform 레포)│                │
│  └─────────────────────┘                │
│                                         │
│  ┌─────────────────────┐                │
│  │ data-warehouse      │                │
│  │ (data-platform 레포)│                │
│  └─────────────────────┘                │
└─────────────────────────────────────────┘
```

#### 실전 예시 2: 프론트엔드 → 백엔드 → 데이터베이스

**시나리오:**
- Frontend 레포의 `user-dashboard`가
- Backend 레포의 `user-api`를 호출하고
- Backend는 `user-database`에 의존

**frontend/apps/user-dashboard/catalog-info.yaml:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: user-dashboard
  description: 사용자 대시보드 (React)
spec:
  type: website
  lifecycle: production
  owner: group:frontend-team
  system: user-management-system
  
  # 백엔드 API 사용
  consumesApis:
    - user-rest-api  # backend 레포에서 정의
  
  # UI 라이브러리 의존
  dependsOn:
    - component:design-system-library  # 같은 레포 또는 다른 레포
```

**backend/apps/user-service/catalog-info.yaml:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: user-service
  description: 사용자 관리 서비스 (NestJS)
spec:
  type: service
  lifecycle: production
  owner: group:backend-team
  system: user-management-system
  
  # 자신이 제공하는 API
  providesApis:
    - user-rest-api  # frontend가 이것을 소비
  
  # 데이터베이스 의존
  dependsOn:
    - resource:user-database  # infra 레포에서 정의
```

**infra/databases/catalog-info.yaml:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: user-database
  description: 사용자 정보 데이터베이스 (PostgreSQL)
spec:
  type: database
  lifecycle: production
  owner: group:devops-team
  system: user-management-system
```

**backend/apis/catalog-info.yaml:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: user-rest-api
  description: 사용자 관리 REST API
spec:
  type: openapi
  lifecycle: production
  owner: group:backend-team
  system: user-management-system
  definition:
    $text: https://api.example.com/users/openapi.json
```

#### 의존성 그래프 시각화

Backstage에서 컴포넌트 페이지를 열면 다음과 같은 정보를 볼 수 있습니다:

**"Dependencies" 탭:**
- 📊 시각적 그래프로 의존성 표시
- ⬆️ 이 컴포넌트가 의존하는 것들 (Depends On)
- ⬇️ 이 컴포넌트에 의존하는 것들 (Dependency Of)
- 🔗 크로스 레포 의존성도 동일하게 표시

**"API" 탭:**
- 제공하는 API 목록 (Provides)
- 사용하는 API 목록 (Consumes)
- API 스펙 문서 링크

#### 의존성 추적의 실무 활용

**1. 영향 분석 (Impact Analysis)**
```
Q: user-database를 업그레이드하면 어떤 서비스가 영향받나?

A: Backstage에서 user-database 페이지 열기
   → "Dependency Of" 섹션 확인
   → user-service가 의존함을 확인
   → user-service 페이지 열기
   → "Dependency Of" 섹션 확인
   → user-dashboard가 API를 사용함을 확인
   
결론: user-database → user-service → user-dashboard 순서로 영향
```

**2. 장애 추적 (Incident Tracking)**
```
Q: user-dashboard에서 에러가 발생. 원인은?

A: Backstage에서 user-dashboard 페이지 열기
   → "Dependencies" 탭 확인
   → user-rest-api를 사용함을 확인
   → user-service 페이지 확인
   → user-database에 의존함을 확인
   → Monitoring 링크로 각 컴포넌트 상태 확인
   
결론: 의존성 체인을 따라 장애 원인 추적 가능
```

**3. 마이그레이션 계획 (Migration Planning)**
```
Q: legacy-system을 새 시스템으로 마이그레이션. 어떤 서비스를 먼저?

A: Backstage에서 의존성 그래프 분석
   → 가장 많이 의존받는 컴포넌트 파악
   → 의존성이 없는 말단 컴포넌트부터 마이그레이션
   
결론: Bottom-up 마이그레이션 계획 수립
```

### 11.7 모범 사례

#### ✅ DO: 권장 사항

1. **각 레포지토리는 독립적인 catalog-info.yaml 유지**
   - 레포지토리가 Backstage 없이도 자체 문서화되어 있어야 함

2. **공통 System/Domain은 Backstage 레포에서 정의**
   - `rnd-backstage/catalog/systems/`에 상위 레벨 정의
   - 각 레포는 Component 레벨만 관리

3. **GitHub Discovery 사용 (대규모 조직)**
   - 10개 이상의 레포지토리가 있다면 자동 검색 권장

4. **팀별로 Group 먼저 정의**
   - 모든 Component의 owner가 유효한 Group이어야 함

5. **네이밍 컨벤션 유지**
   - 레포지토리 이름을 System 이름에 반영
   - 예: `legacy-erp` 레포 → `legacy-erp-system` System

#### ❌ DON'T: 피해야 할 것

1. **중복된 System 정의 금지**
   - 하나의 System은 한 곳에서만 정의

2. **절대 경로 사용 금지**
   - 상대 경로나 URL 사용

3. **순환 의존성 생성 금지**
   - Component A → B → C → A

4. **민감 정보 포함 금지**
   - 데이터베이스 비밀번호, API 키 등

### 11.8 FAQ

**Q: 레포지토리를 추가할 때마다 Backstage를 재시작해야 하나요?**

A: 아니요. `app-config.yaml`만 변경하면 자동으로 재로드됩니다. 
개발 모드(`yarn dev`)에서는 즉시 반영되며, 프로덕션에서는 설정된 주기(예: 30분)마다 자동으로 업데이트됩니다.

**Q: GitHub Private 레포지토리도 추가할 수 있나요?**

A: 네, GitHub Personal Access Token을 `app-config.yaml`에 설정하면 됩니다:
```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}  # .env 파일에서 관리
```

**Q: 다른 Git 플랫폼(GitLab, Bitbucket)도 지원하나요?**

A: 네, Backstage는 GitLab, Bitbucket, Azure DevOps 등을 모두 지원합니다:
```yaml
integrations:
  gitlab:
    - host: gitlab.com
      token: ${GITLAB_TOKEN}
  
  bitbucket:
    - host: bitbucket.org
      username: ${BITBUCKET_USERNAME}
      appPassword: ${BITBUCKET_APP_PASSWORD}
```

**Q: 수백 개의 레포지토리가 있는데 모두 추가해야 하나요?**

A: 아니요. 단계적으로 추가하는 것을 권장합니다:
1. **Phase 1**: 핵심 프로젝트 5-10개
2. **Phase 2**: 활발히 개발 중인 프로젝트
3. **Phase 3**: GitHub Discovery로 자동 확장

---

## 12. 문제 해결 및 FAQ

### 12.1 일반적인 문제

#### Q1: 컴포넌트가 카탈로그에 나타나지 않습니다.
**A**: 다음을 확인하세요:
1. `catalog-info.yaml` 파일이 올바른 위치에 있는지
2. YAML 문법이 유효한지 (validator 사용)
3. `app-config.yaml`의 locations에 경로가 등록되어 있는지
4. Backstage를 재시작했는지

#### Q2: 의존성 그래프가 표시되지 않습니다.
**A**: 
1. `dependsOn`, `consumesApis`, `providesApis` 필드가 올바르게 설정되어 있는지 확인
2. 참조하는 컴포넌트의 이름이 정확한지 확인
3. 순환 의존성이 없는지 확인

#### Q3: TechDocs가 생성되지 않습니다.
**A**:
1. `mkdocs.yml` 파일이 존재하는지 확인
2. `techdocs-core` 플러그인이 설치되어 있는지 확인
3. Docker가 실행 중인지 확인 (builder: 'local', runIn: 'docker')

### 11.2 성능 최적화

#### 느린 카탈로그 로딩
- 카탈로그 새로고침 주기 조정
- 불필요한 locations 제거
- 데이터베이스 인덱스 최적화

#### 메모리 사용량 증가
- TechDocs 캐시 정리
- 로그 로테이션 설정
- Node.js 메모리 제한 조정

---

## 12. 참고 자료

### 12.1 공식 문서
- [Backstage 공식 문서](https://backstage.io/docs)
- [Nx 공식 문서](https://nx.dev)
- [Backstage 카탈로그 모델](https://backstage.io/docs/features/software-catalog/)
- [TechDocs 가이드](https://backstage.io/docs/features/techdocs/)

### 12.2 내부 문서
- RND-NX README: `/Users/seojiwon/VNTG_PROJECT/RND-NX/README.md`
- 아키텍처 결정 기록: `/Users/seojiwon/VNTG_PROJECT/RND-NX/docs/adr/`
- PRD 문서: `/Users/seojiwon/VNTG_PROJECT/RND-NX/docs/prd/`

### 12.3 커뮤니티 리소스
- [Backstage Discord](https://discord.gg/backstage)
- [GitHub Discussions](https://github.com/backstage/backstage/discussions)

---

## 13. 요약: 멀티 레포 관리 핵심 원칙

### 핵심 개념

✅ **단일 Backstage, 다수 레포지토리**
- `rnd-backstage` 하나로 조직의 모든 프로젝트 관리 가능
- 각 레포지토리는 독립적으로 `catalog-info.yaml` 유지
- Backstage의 `app-config.yaml`에 경로만 추가

✅ **3가지 통합 방법**
1. **로컬 파일** (`type: file`): 빠르고 실시간, 로컬 개발 환경에 적합
2. **GitHub URL** (`type: url`): 원격 레포, 로컬 클론 불필요
3. **GitHub Discovery**: 대규모 조직, 자동 검색 및 동기화

✅ **크로스 레포 의존성 지원**
- 서로 다른 레포지토리의 컴포넌트 간 의존성 표현 가능
- `dependsOn`, `consumesApis`, `providesApis`로 관계 정의

### 실무 적용 예시

```yaml
# rnd-backstage/app-config.yaml
catalog:
  locations:
    # 프로젝트 1: RND-NX
    - type: file
      target: ../RND-NX/catalog-info.yaml
    
    # 프로젝트 2: Legacy ERP
    - type: file
      target: ../legacy-erp/catalog-info.yaml
    
    # 프로젝트 3: Mobile App
    - type: url
      target: https://github.com/vntg/mobile-app/blob/main/catalog-info.yaml
    
    # 자동 검색: 모든 GitHub 레포
    - type: github-discovery
      target: https://github.com/vntg
```

### 시작 가이드

1. 새 레포에 `catalog-info.yaml` 작성
2. `rnd-backstage/app-config.yaml`에 경로 추가
3. 팀 정의 (필요시)
4. Backstage 재시작 (개발 모드는 자동 반영)

---

## 14. 변경 이력

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|----------|
| 1.0.0 | 2025-10-21 | AI Assistant | 초기 문서 작성 |
| 1.1.0 | 2025-10-21 | AI Assistant | 멀티 레포지토리 관리 전략 섹션 추가 |

---

## 15. 승인

| 역할 | 이름 | 서명 | 날짜 |
|------|------|------|------|
| 작성자 | | | 2025-10-21 |
| 검토자 | | | |
| 승인자 | | | |

---

**문서 끝**

