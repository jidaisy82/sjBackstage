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

## 11. 문제 해결 및 FAQ

### 11.1 일반적인 문제

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

## 13. 변경 이력

| 버전 | 날짜 | 작성자 | 변경 내용 |
|------|------|--------|----------|
| 1.0.0 | 2025-10-21 | AI Assistant | 초기 문서 작성 |

---

## 14. 승인

| 역할 | 이름 | 서명 | 날짜 |
|------|------|------|------|
| 작성자 | | | 2025-10-21 |
| 검토자 | | | |
| 승인자 | | | |

---

**문서 끝**

