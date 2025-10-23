# Backstage Software Template 가이드 v3.0

## 목차
1. [개요](#개요)
2. [Tech Blog 기술 스택 분석](#tech-blog-기술-스택-분석)
3. [Software Template 설계](#software-template-설계)
4. [Template 구현 가이드](#template-구현-가이드)
5. [사용 예시](#사용-예시)
6. [Backstage Template 흐름](#backstage-template-흐름)

---

## 개요

### Software Template이란?
Backstage Software Template(Scaffolder)는 새로운 프로젝트나 서비스를 일관된 구조와 Best Practice를 기반으로 자동 생성하는 기능입니다. 이를 통해:
- 표준화된 프로젝트 구조 유지
- 개발 시작 시간 단축
- 일관된 코드 품질 보장
- 반복적인 설정 작업 자동화
- **기술 스택별 선택적 구성**

### 목표
RND-NX 모노레포 내 tech-blog 프로젝트를 기반으로 한 **개별 기술 스택 Template**을 설계하여, 개발자가 필요한 기술만 선택해서 프로젝트를 구성할 수 있도록 합니다. 기존 데이터베이스를 연동하여 PostgreSQL 데이터를 조회하는 간단한 화면까지 포함합니다.

---

## Tech Blog 기술 스택 분석

### 1. 프로젝트 구조

Tech Blog는 다음 3개의 주요 프로젝트로 구성됩니다:

```
apps/tech-blog/
├── api-server/          # NestJS 백엔드 서버
├── user-client/         # React 프론트엔드 클라이언트
└── api-server-test/     # E2E 테스트 프로젝트
```

### 2. 기술 스택 분류

#### Backend 기술 스택
- **NestJS** (^11.2.5): Node.js 백엔드 프레임워크
- **Prisma** (^6.1.0): ORM (Object-Relational Mapping)
- **PostgreSQL**: 데이터베이스
- **Nestia**: Type-safe API SDK 자동 생성
- **TypeScript** (5.8.3): 정적 타입 시스템
- **JWT**: 인증 토큰
- **bcrypt**: 비밀번호 해싱

#### Frontend 기술 스택
- **React** (19.1.1): UI 라이브러리
- **Vite** (7.1.4): 빌드 도구
- **TypeScript** (5.8.3): 정적 타입 시스템
- **TailwindCSS** (3.4.17): CSS 프레임워크
- **Radix UI**: UI 컴포넌트 라이브러리
- **shadcn/ui**: TailwindCSS + Radix UI 기반 컴포넌트
- **Zustand** (5.0.7): 상태 관리
- **React Hook Form** (7.62.0): 폼 상태 관리

#### API 통신 기술 스택
- **@nestia/fetcher** (8.0.7): Type-safe API 클라이언트
- **Axios** (1.11.0): HTTP 클라이언트
- **Typia** (9.7.2): 런타임 타입 검증

#### Testing 기술 스택
- **Jest**: 테스트 프레임워크
- **ts-jest**: TypeScript Jest 변환기
- **E2E Testing**: 통합 테스트

---

## Software Template 설계

### 1. Template 목표

tech-blog의 기술 스택을 **개별적으로 선택 가능한 Template**으로 분리하여:
- **기술 스택별 독립적 구성**
- **기존 PostgreSQL 데이터베이스 연동**
- **선택적 조합 가능**
- **개발자 맞춤형 프로젝트 구성**

### 2. Template 분류

#### A. Tech Blog 기반 Template (Test)
```
catalog/templates/
├── backend-nestjs-prisma (test)/     # NestJS + Prisma 백엔드
├── frontend-react-vite (test)/       # React + Vite 프론트엔드
├── api-nestia (test)/                # Nestia API 생성
├── database-postgresql (test)/       # PostgreSQL 연동
└── testing-jest-e2e (test)/          # Jest 테스트
```

#### B. 일반 기술 스택 Template
```
catalog/templates/
├── backend-nestjs/                   # NestJS 백엔드
├── backend-spring-boot/              # Spring Boot 백엔드
├── backend-fastapi/                  # Python FastAPI 백엔드
├── frontend-react/                   # React 프론트엔드
├── frontend-vue/                     # Vue 프론트엔드
├── frontend-angular/                 # Angular 프론트엔드
├── database-mongodb/                 # MongoDB 연동
├── database-mysql/                   # MySQL 연동
├── api-graphql/                      # GraphQL API
├── api-rest/                         # REST API
├── testing-cypress/                  # Cypress 테스트
├── testing-playwright/               # Playwright 테스트
├── infrastructure-terraform/          # Terraform 인프라
├── infrastructure-docker/             # Docker 컨테이너
├── monitoring-prometheus/             # Prometheus 모니터링
├── logging-elasticsearch/             # Elasticsearch 로깅
└── ci-cd-github-actions/             # GitHub Actions CI/CD
```

### 3. Template Parameters 설계

#### A. Tech Blog Template Parameters

**Backend NestJS + Prisma (test)**
```yaml
parameters:
  - title: 프로젝트 기본 정보
    required:
      - projectName
      - description
      - owner
    properties:
      projectName:
        title: 프로젝트 이름
        type: string
        description: 프로젝트 식별자
        pattern: '^[a-z][a-z0-9-]*$'
        
      description:
        title: 프로젝트 설명
        type: string
        
      owner:
        title: 소유자
        type: string
        ui:field: OwnerPicker

  - title: 데이터베이스 설정
    properties:
      databaseUrl:
        title: PostgreSQL 연결 URL
        type: string
        description: 기존 PostgreSQL 데이터베이스 연결 문자열
        default: postgresql://username:password@localhost:5432/existing_db
        ui:field: Secret

  - title: 인증 설정
    properties:
      enableJWT:
        title: JWT 인증 활성화
        type: boolean
        default: true
        
      enableBcrypt:
        title: 비밀번호 해싱 (bcrypt)
        type: boolean
        default: true

  - title: 저장소 위치
    required:
      - repoUrl
    properties:
      repoUrl:
        title: Repository Location
        type: string
        ui:field: RepoUrlPicker
```

**Frontend React + Vite (test)**
```yaml
parameters:
  - title: 프로젝트 기본 정보
    required:
      - projectName
      - description
      - owner
    properties:
      projectName:
        title: 프로젝트 이름
        type: string
        
      description:
        title: 프로젝트 설명
        type: string
        
      owner:
        title: 소유자
        type: string
        ui:field: OwnerPicker

  - title: UI 설정
    properties:
      enableDarkMode:
        title: 다크모드 지원
        type: boolean
        default: true
        
      uiLibrary:
        title: UI 컴포넌트 라이브러리
        type: string
        enum:
          - radix-ui
          - mui
          - ant-design
        enumNames:
          - Radix UI (shadcn/ui)
          - Material UI
          - Ant Design
        default: radix-ui

  - title: 상태 관리
    properties:
      stateManagement:
        title: 상태 관리 라이브러리
        type: string
        enum:
          - zustand
          - redux
          - context
        enumNames:
          - Zustand
          - Redux Toolkit
          - React Context
        default: zustand

  - title: API 연동
    properties:
      apiClient:
        title: API 클라이언트
        type: string
        enum:
          - nestia
          - axios
          - fetch
        enumNames:
          - Nestia (Type-safe)
          - Axios
          - Fetch API
        default: nestia

  - title: 저장소 위치
    required:
      - repoUrl
    properties:
      repoUrl:
        title: Repository Location
        type: string
        ui:field: RepoUrlPicker
```

#### B. 일반 기술 스택 Template Parameters

**Backend Spring Boot**
```yaml
parameters:
  - title: 프로젝트 기본 정보
    required:
      - projectName
      - description
      - owner
    properties:
      projectName:
        title: 프로젝트 이름
        type: string
        
      description:
        title: 프로젝트 설명
        type: string
        
      owner:
        title: 소유자
        type: string
        ui:field: OwnerPicker

  - title: Spring Boot 설정
    properties:
      springVersion:
        title: Spring Boot 버전
        type: string
        enum:
          - "3.2.x"
          - "3.1.x"
          - "2.7.x"
        default: "3.2.x"
        
      javaVersion:
        title: Java 버전
        type: string
        enum:
          - "17"
          - "11"
          - "8"
        default: "17"

  - title: 데이터베이스 설정
    properties:
      databaseType:
        title: 데이터베이스 타입
        type: string
        enum:
          - postgresql
          - mysql
          - h2
        default: postgresql
        
      enableJPA:
        title: JPA 활성화
        type: boolean
        default: true

  - title: 보안 설정
    properties:
      enableSecurity:
        title: Spring Security 활성화
        type: boolean
        default: true
        
      enableOAuth2:
        title: OAuth2 활성화
        type: boolean
        default: false

  - title: 저장소 위치
    required:
      - repoUrl
    properties:
      repoUrl:
        title: Repository Location
        type: string
        ui:field: RepoUrlPicker
```

**Frontend Vue**
```yaml
parameters:
  - title: 프로젝트 기본 정보
    required:
      - projectName
      - description
      - owner
    properties:
      projectName:
        title: 프로젝트 이름
        type: string
        
      description:
        title: 프로젝트 설명
        type: string
        
      owner:
        title: 소유자
        type: string
        ui:field: OwnerPicker

  - title: Vue 설정
    properties:
      vueVersion:
        title: Vue 버전
        type: string
        enum:
          - "3.x"
          - "2.x"
        default: "3.x"
        
      buildTool:
        title: 빌드 도구
        type: string
        enum:
          - vite
          - webpack
        default: vite

  - title: UI 프레임워크
    properties:
      uiFramework:
        title: UI 프레임워크
        type: string
        enum:
          - vuetify
          - quasar
          - element-plus
          - ant-design-vue
        enumNames:
          - Vuetify
          - Quasar
          - Element Plus
          - Ant Design Vue
        default: vuetify

  - title: 상태 관리
    properties:
      stateManagement:
        title: 상태 관리
        type: string
        enum:
          - pinia
          - vuex
          - none
        enumNames:
          - Pinia
          - Vuex
          - 없음
        default: pinia

  - title: 저장소 위치
    required:
      - repoUrl
    properties:
      repoUrl:
        title: Repository Location
        type: string
        ui:field: RepoUrlPicker
```

### 4. Template 파일 구조

#### A. Tech Blog Template 구조

**Backend NestJS + Prisma (test)**
```
catalog/templates/backend-nestjs-prisma-test/
├── template.yaml
├── skeleton/
│   ├── src/
│   │   ├── app.module.ts.hbs
│   │   ├── main.ts.hbs
│   │   └── modules/
│   │       ├── posts/
│   │       │   ├── posts.controller.ts.hbs
│   │       │   ├── posts.service.ts.hbs
│   │       │   ├── posts.module.ts.hbs
│   │       │   └── dto/
│   │       │       ├── create-post.dto.ts.hbs
│   │       │       └── update-post.dto.ts.hbs
│   │       ├── categories/
│   │       │   ├── categories.controller.ts.hbs
│   │       │   ├── categories.service.ts.hbs
│   │       │   └── categories.module.ts.hbs
│   │       └── users/
│   │           ├── users.controller.ts.hbs
│   │           ├── users.service.ts.hbs
│   │           └── users.module.ts.hbs
│   ├── prisma/
│   │   ├── schema.prisma.hbs
│   │   └── seed.ts.hbs
│   ├── package.json.hbs
│   ├── nestia.config.ts.hbs
│   ├── tsconfig.json
│   └── catalog-info.yaml.hbs
```

**Frontend React + Vite (test)**
```
catalog/templates/frontend-react-vite-test/
├── template.yaml
├── skeleton/
│   ├── src/
│   │   ├── components/
│   │   │   ├── ui/                    # shadcn/ui 컴포넌트
│   │   │   ├── PostCard.tsx.hbs
│   │   │   ├── Layout.tsx.hbs
│   │   │   └── ThemeProvider.tsx.hbs  # (conditional: enableDarkMode)
│   │   ├── pages/
│   │   │   ├── Home.tsx.hbs           # PostgreSQL 데이터 조회
│   │   │   ├── PostDetail.tsx.hbs
│   │   │   └── CreatePost.tsx.hbs
│   │   ├── hooks/
│   │   │   └── usePosts.ts.hbs
│   │   ├── lib/
│   │   │   ├── api/
│   │   │   └── utils.ts.hbs
│   │   ├── stores/
│   │   │   └── postStore.ts.hbs
│   │   ├── App.tsx.hbs
│   │   └── main.tsx.hbs
│   ├── package.json.hbs
│   ├── vite.config.ts.hbs
│   ├── tailwind.config.js.hbs
│   └── catalog-info.yaml.hbs
```

#### B. 일반 기술 스택 Template 구조

**Backend Spring Boot**
```
catalog/templates/backend-spring-boot/
├── template.yaml
├── skeleton/
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   └── com/
│   │   │   │       └── {{values.projectName}}/
│   │   │   │           ├── {{values.projectName}}Application.java.hbs
│   │   │   │           ├── controller/
│   │   │   │           ├── service/
│   │   │   │           ├── repository/
│   │   │   │           └── entity/
│   │   │   └── resources/
│   │   │       ├── application.yml.hbs
│   │   │       └── application-{{env}}.yml.hbs
│   │   └── test/
│   │       └── java/
│   │           └── com/
│   │               └── {{values.projectName}}/
│   │                   └── {{values.projectName}}ApplicationTests.java.hbs
│   ├── pom.xml.hbs
│   ├── Dockerfile.hbs
│   └── catalog-info.yaml.hbs
```

**Frontend Vue**
```
catalog/templates/frontend-vue/
├── template.yaml
├── skeleton/
│   ├── src/
│   │   ├── components/
│   │   │   ├── HelloWorld.vue.hbs
│   │   │   └── PostCard.vue.hbs
│   │   ├── views/
│   │   │   ├── HomeView.vue.hbs
│   │   │   └── AboutView.vue.hbs
│   │   ├── router/
│   │   │   └── index.js.hbs
│   │   ├── stores/
│   │   │   └── counter.js.hbs
│   │   ├── App.vue.hbs
│   │   └── main.js.hbs
│   ├── package.json.hbs
│   ├── vite.config.js.hbs
│   └── catalog-info.yaml.hbs
```

### 5. Template Actions (Steps)

#### A. Tech Blog Template Actions

**Backend NestJS + Prisma (test)**
```yaml
steps:
  - id: fetch-base
    name: Fetch Backend Template
    action: fetch:template
    input:
      url: ./skeleton
      values:
        projectName: ${{ parameters.projectName }}
        description: ${{ parameters.description }}
        owner: ${{ parameters.owner }}
        databaseUrl: ${{ parameters.databaseUrl }}
        enableJWT: ${{ parameters.enableJWT }}
        enableBcrypt: ${{ parameters.enableBcrypt }}

  - id: publish
    name: Publish to GitHub
    action: publish:github
    input:
      description: ${{ parameters.description }}
      repoUrl: ${{ parameters.repoUrl }}
      defaultBranch: develop
      protectDefaultBranch: false
      repoVisibility: private

  - id: register-catalog
    name: Register in Catalog
    action: catalog:register
    input:
      repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
      catalogInfoPath: '/catalog-info.yaml'

  - id: setup-env
    name: Setup Environment Variables
    action: fs:write
    input:
      path: .env
      content: |
        DATABASE_URL="${{ parameters.databaseUrl }}"
        JWT_SECRET="your-jwt-secret-key-change-this"
        NODE_ENV="local"
        PORT=3000

output:
  links:
    - title: Repository
      url: ${{ steps['publish'].output.remoteUrl }}
    - title: Backend Component
      icon: catalog
      entityRef: ${{ steps['register-catalog'].output.entityRef }}
    - title: API Documentation
      url: http://localhost:3000/api/swagger
      icon: docs
```

**Frontend React + Vite (test)**
```yaml
steps:
  - id: fetch-base
    name: Fetch Frontend Template
    action: fetch:template
    input:
      url: ./skeleton
      values:
        projectName: ${{ parameters.projectName }}
        description: ${{ parameters.description }}
        owner: ${{ parameters.owner }}
        enableDarkMode: ${{ parameters.enableDarkMode }}
        uiLibrary: ${{ parameters.uiLibrary }}
        stateManagement: ${{ parameters.stateManagement }}
        apiClient: ${{ parameters.apiClient }}

  - id: publish
    name: Publish to GitHub
    action: publish:github
    input:
      description: ${{ parameters.description }}
      repoUrl: ${{ parameters.repoUrl }}
      defaultBranch: develop
      protectDefaultBranch: false
      repoVisibility: private

  - id: register-catalog
    name: Register in Catalog
    action: catalog:register
    input:
      repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
      catalogInfoPath: '/catalog-info.yaml'

output:
  links:
    - title: Repository
      url: ${{ steps['publish'].output.remoteUrl }}
    - title: Frontend Component
      icon: catalog
      entityRef: ${{ steps['register-catalog'].output.entityRef }}
    - title: Frontend Application
      url: http://localhost:5173
      icon: web
```

#### B. 일반 기술 스택 Template Actions

**Backend Spring Boot**
```yaml
steps:
  - id: fetch-base
    name: Fetch Spring Boot Template
    action: fetch:template
    input:
      url: ./skeleton
      values:
        projectName: ${{ parameters.projectName }}
        description: ${{ parameters.description }}
        owner: ${{ parameters.owner }}
        springVersion: ${{ parameters.springVersion }}
        javaVersion: ${{ parameters.javaVersion }}
        databaseType: ${{ parameters.databaseType }}
        enableJPA: ${{ parameters.enableJPA }}
        enableSecurity: ${{ parameters.enableSecurity }}
        enableOAuth2: ${{ parameters.enableOAuth2 }}

  - id: publish
    name: Publish to GitHub
    action: publish:github
    input:
      description: ${{ parameters.description }}
      repoUrl: ${{ parameters.repoUrl }}
      defaultBranch: develop
      protectDefaultBranch: false
      repoVisibility: private

  - id: register-catalog
    name: Register in Catalog
    action: catalog:register
    input:
      repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
      catalogInfoPath: '/catalog-info.yaml'

output:
  links:
    - title: Repository
      url: ${{ steps['publish'].output.remoteUrl }}
    - title: Backend Component
      icon: catalog
      entityRef: ${{ steps['register-catalog'].output.entityRef }}
    - title: API Documentation
      url: http://localhost:8080/swagger-ui.html
      icon: docs
```

---

## Template 구현 가이드

### Step 1: Template 디렉토리 생성

```bash
# Tech Blog Template들
mkdir -p catalog/templates/backend-nestjs-prisma-test
mkdir -p catalog/templates/frontend-react-vite-test
mkdir -p catalog/templates/api-nestia-test
mkdir -p catalog/templates/database-postgresql-test
mkdir -p catalog/templates/testing-jest-e2e-test

# 일반 기술 스택 Template들
mkdir -p catalog/templates/backend-spring-boot
mkdir -p catalog/templates/backend-fastapi
mkdir -p catalog/templates/frontend-vue
mkdir -p catalog/templates/frontend-angular
mkdir -p catalog/templates/database-mongodb
mkdir -p catalog/templates/api-graphql
mkdir -p catalog/templates/testing-cypress
mkdir -p catalog/templates/infrastructure-terraform
mkdir -p catalog/templates/ci-cd-github-actions
```

### Step 2: Template 등록

```yaml
# app-config.yaml
catalog:
  locations:
    # Tech Blog Template들
    - type: file
      target: ../../catalog/templates/backend-nestjs-prisma-test/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/frontend-react-vite-test/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/api-nestia-test/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/database-postgresql-test/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/testing-jest-e2e-test/template.yaml
      rules:
        - allow: [Template]
    
    # 일반 기술 스택 Template들
    - type: file
      target: ../../catalog/templates/backend-spring-boot/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/backend-fastapi/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/frontend-vue/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/frontend-angular/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/database-mongodb/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/api-graphql/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/testing-cypress/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/infrastructure-terraform/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/ci-cd-github-actions/template.yaml
      rules:
        - allow: [Template]
```

### Step 3: Template 테스트

1. Backstage 재시작
```bash
yarn dev
```

2. Backstage UI에서 확인
   - `/create` 페이지 방문
   - Template 목록 확인:
     ```
     Tech Blog Templates:
     - Backend NestJS + Prisma (test)
     - Frontend React + Vite (test)
     - API Nestia (test)
     - Database PostgreSQL (test)
     - Testing Jest + E2E (test)
     
     General Templates:
     - Backend Spring Boot
     - Backend FastAPI
     - Frontend Vue
     - Frontend Angular
     - Database MongoDB
     - API GraphQL
     - Testing Cypress
     - Infrastructure Terraform
     - CI/CD GitHub Actions
     ```

---

## 사용 예시

### 예시 1: Tech Blog 백엔드만 생성

**선택한 Template**: `Backend NestJS + Prisma (test)`

**입력 파라미터**:
```yaml
projectName: company-blog-api
description: 회사 블로그 백엔드 API
owner: group:backend-team
databaseUrl: postgresql://username:password@localhost:5432/company_blog_db
enableJWT: true
enableBcrypt: true
repoUrl: https://github.com/company/company-blog-api
```

**생성되는 구조**:
```
company-blog-api/
├── src/
│   ├── modules/
│   │   ├── posts/          # 게시물 CRUD
│   │   ├── categories/    # 카테고리 관리
│   │   └── users/          # 사용자 관리
│   ├── prisma/
│   │   └── schema.prisma   # User, Post, Category 모델
│   └── app.module.ts
├── package.json
├── nestia.config.ts
└── catalog-info.yaml
```

### 예시 2: Tech Blog 프론트엔드만 생성

**선택한 Template**: `Frontend React + Vite (test)`

**입력 파라미터**:
```yaml
projectName: company-blog-frontend
description: 회사 블로그 프론트엔드
owner: group:frontend-team
enableDarkMode: true
uiLibrary: radix-ui
stateManagement: zustand
apiClient: nestia
repoUrl: https://github.com/company/company-blog-frontend
```

**생성되는 구조**:
```
company-blog-frontend/
├── src/
│   ├── components/
│   │   ├── PostCard.tsx    # 게시물 카드
│   │   └── Layout.tsx      # 레이아웃
│   ├── pages/
│   │   ├── Home.tsx        # PostgreSQL 데이터 조회
│   │   ├── PostDetail.tsx  # 게시물 상세
│   │   └── CreatePost.tsx  # 게시물 작성
│   ├── hooks/
│   │   └── usePosts.ts     # 게시물 데이터 훅
│   └── stores/
│       └── postStore.ts    # Zustand 상태 관리
├── package.json
├── vite.config.ts
└── catalog-info.yaml
```

### 예시 3: Spring Boot 백엔드 생성

**선택한 Template**: `Backend Spring Boot`

**입력 파라미터**:
```yaml
projectName: user-service
description: 사용자 관리 서비스
owner: group:backend-team
springVersion: "3.2.x"
javaVersion: "17"
databaseType: postgresql
enableJPA: true
enableSecurity: true
enableOAuth2: false
repoUrl: https://github.com/company/user-service
```

**생성되는 구조**:
```
user-service/
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   └── com/
│   │   │       └── userservice/
│   │   │           ├── UserServiceApplication.java
│   │   │           ├── controller/
│   │   │           ├── service/
│   │   │           ├── repository/
│   │   │           └── entity/
│   │   └── resources/
│   │       └── application.yml
│   └── test/
├── pom.xml
├── Dockerfile
└── catalog-info.yaml
```

### 예시 4: Vue 프론트엔드 생성

**선택한 Template**: `Frontend Vue`

**입력 파라미터**:
```yaml
projectName: admin-dashboard
description: 관리자 대시보드
owner: group:frontend-team
vueVersion: "3.x"
buildTool: vite
uiFramework: vuetify
stateManagement: pinia
repoUrl: https://github.com/company/admin-dashboard
```

**생성되는 구조**:
```
admin-dashboard/
├── src/
│   ├── components/
│   │   ├── HelloWorld.vue
│   │   └── PostCard.vue
│   ├── views/
│   │   ├── HomeView.vue
│   │   └── AboutView.vue
│   ├── router/
│   │   └── index.js
│   ├── stores/
│   │   └── counter.js
│   └── App.vue
├── package.json
├── vite.config.js
└── catalog-info.yaml
```

---

## Backstage Template 흐름

### 1. Template 선택 및 실행 과정

```mermaid
graph TD
    A[개발자가 Backstage UI 접속] --> B[/create 페이지 방문]
    B --> C[Template 목록 확인]
    C --> D{원하는 Template 선택}
    D --> E[파라미터 입력 폼 표시]
    E --> F[필수 파라미터 입력]
    F --> G[선택적 파라미터 입력]
    G --> H[Create 버튼 클릭]
    H --> I[Backstage 서버에서 Template 처리]
    I --> J[fetch:template 액션 실행]
    J --> K[skeleton 파일들 처리]
    K --> L[Handlebars 템플릿 변수 치환]
    L --> M[publish:github 액션 실행]
    M --> N[GitHub 저장소 생성]
    N --> O[생성된 코드 푸시]
    O --> P[catalog:register 액션 실행]
    P --> Q[Backstage Catalog에 컴포넌트 등록]
    Q --> R[결과 페이지 표시]
    R --> S[생성된 저장소 링크 제공]
```

### 2. Template 분류 및 선택 전략

#### A. Tech Blog Template (Test) 사용 시나리오
```
시나리오 1: 백엔드만 필요
├── Backend NestJS + Prisma (test) 선택
└── PostgreSQL 기존 DB 연동

시나리오 2: 프론트엔드만 필요
├── Frontend React + Vite (test) 선택
└── PostgreSQL 데이터 조회 화면 포함

시나리오 3: 전체 시스템 필요
├── Backend NestJS + Prisma (test) 선택
├── Frontend React + Vite (test) 선택
├── API Nestia (test) 선택
├── Database PostgreSQL (test) 선택
└── Testing Jest + E2E (test) 선택
```

#### B. 일반 기술 스택 Template 사용 시나리오
```
시나리오 1: Java 백엔드
├── Backend Spring Boot 선택
├── Database PostgreSQL 선택
└── CI/CD GitHub Actions 선택

시나리오 2: Python 백엔드
├── Backend FastAPI 선택
├── Database MongoDB 선택
└── Infrastructure Terraform 선택

시나리오 3: Vue 프론트엔드
├── Frontend Vue 선택
├── API GraphQL 선택
└── Testing Cypress 선택
```

### 3. Template 조합 전략

#### A. 단일 Template 사용
- **목적**: 특정 기술 스택만 필요할 때
- **예시**: 백엔드만, 프론트엔드만, 데이터베이스만
- **장점**: 빠른 생성, 간단한 구성

#### B. 다중 Template 조합
- **목적**: 전체 시스템 구성이 필요할 때
- **예시**: 백엔드 + 프론트엔드 + 데이터베이스 + 테스트
- **장점**: 완전한 시스템, 일관된 구조

#### C. 점진적 Template 적용
- **목적**: 단계별로 시스템을 구축할 때
- **예시**: 1단계(백엔드) → 2단계(프론트엔드) → 3단계(테스트)
- **장점**: 점진적 개발, 유연한 구성

### 4. Template 관리 전략

#### A. 버전 관리
```yaml
# Template 버전 관리
metadata:
  name: backend-nestjs-prisma-test
  title: Backend NestJS + Prisma (test)
  version: "1.0.0"
  description: |
    NestJS + Prisma 기반 백엔드 Template
    - PostgreSQL 연동
    - JWT 인증
    - Type-safe API
```

#### B. 의존성 관리
```yaml
# Template 간 의존성
dependencies:
  - frontend-react-vite-test: "1.0.0"
  - api-nestia-test: "1.0.0"
  - database-postgresql-test: "1.0.0"
```

#### C. 업데이트 전략
```yaml
# Template 업데이트
updates:
  - version: "1.1.0"
    changes:
      - "NestJS 버전 업데이트"
      - "Prisma 스키마 개선"
      - "새로운 모듈 추가"
```

---

## 개발자 가이드

### 1. Template 선택 가이드

#### A. Tech Blog Template (Test) 선택 기준
```
백엔드가 필요하다면:
├── Backend NestJS + Prisma (test)
└── PostgreSQL 기존 DB 연동

프론트엔드가 필요하다면:
├── Frontend React + Vite (test)
└── PostgreSQL 데이터 조회 화면 포함

API 생성이 필요하다면:
├── API Nestia (test)
└── Type-safe API 자동 생성

데이터베이스 연동이 필요하다면:
├── Database PostgreSQL (test)
└── 기존 PostgreSQL 연동 설정

테스트가 필요하다면:
├── Testing Jest + E2E (test)
└── Jest 테스트 환경 설정
```

#### B. 일반 기술 스택 Template 선택 기준
```
Java 백엔드가 필요하다면:
├── Backend Spring Boot
└── Spring Boot + JPA + Security

Python 백엔드가 필요하다면:
├── Backend FastAPI
└── FastAPI + SQLAlchemy + Pydantic

Vue 프론트엔드가 필요하다면:
├── Frontend Vue
└── Vue 3 + Vite + Pinia

Angular 프론트엔드가 필요하다면:
├── Frontend Angular
└── Angular + TypeScript + RxJS

MongoDB가 필요하다면:
├── Database MongoDB
└── MongoDB + Mongoose

GraphQL API가 필요하다면:
├── API GraphQL
└── GraphQL + Apollo Server

Cypress 테스트가 필요하다면:
├── Testing Cypress
└── Cypress E2E 테스트

Terraform 인프라가 필요하다면:
├── Infrastructure Terraform
└── Terraform + AWS/GCP

GitHub Actions CI/CD가 필요하다면:
├── CI/CD GitHub Actions
└── GitHub Actions 워크플로우
```

### 2. 생성 후 개발 단계

#### A. Tech Blog Template 사용 시
```bash
# 1. 저장소 클론
git clone https://github.com/company/project-name.git
cd project-name

# 2. 의존성 설치
pnpm install

# 3. 환경 변수 설정
cp .env.example .env
# DATABASE_URL 수정

# 4. 데이터베이스 설정
npx prisma generate
npx prisma migrate dev --name init
npx prisma db seed

# 5. 개발 서버 실행
pnpm dev
```

#### B. 일반 기술 스택 Template 사용 시
```bash
# Spring Boot
./mvnw spring-boot:run

# FastAPI
pip install -r requirements.txt
uvicorn main:app --reload

# Vue
npm install
npm run dev

# Angular
npm install
ng serve
```

### 3. Template 확장 가이드

#### A. 새로운 Template 추가
```bash
# 1. Template 디렉토리 생성
mkdir -p catalog/templates/new-template

# 2. template.yaml 작성
# 3. skeleton 파일들 생성
# 4. app-config.yaml에 등록
# 5. 테스트
```

#### B. 기존 Template 수정
```bash
# 1. Template 파일 수정
# 2. 버전 업데이트
# 3. 변경사항 테스트
# 4. 배포
```

---

## 다음 단계

### 1. Template 확장
- **새로운 기술 스택**: Go, Rust, Kotlin, Swift
- **새로운 프레임워크**: Next.js, Nuxt.js, SvelteKit
- **새로운 데이터베이스**: Redis, Elasticsearch, InfluxDB
- **새로운 인프라**: Kubernetes, Docker Swarm, Nomad

### 2. Template 통합
- **마이크로서비스**: 여러 서비스를 하나의 Template으로
- **풀스택**: 백엔드 + 프론트엔드 통합 Template
- **인프라**: 인프라 + 애플리케이션 통합 Template

### 3. Template 자동화
- **의존성 자동 설치**: 생성 후 자동으로 의존성 설치
- **환경 설정 자동화**: 환경 변수 자동 설정
- **테스트 자동 실행**: 생성 후 자동으로 테스트 실행

### 4. Template 모니터링
- **사용량 추적**: 어떤 Template이 많이 사용되는지
- **성공률 모니터링**: Template 생성 성공률
- **피드백 수집**: 사용자 피드백 수집 및 개선

---

## 참고 자료

### Backstage 공식 문서
- [Software Templates](https://backstage.io/docs/features/software-templates/)
- [Writing Templates](https://backstage.io/docs/features/software-templates/writing-templates)
- [Builtin Actions](https://backstage.io/docs/features/software-templates/builtin-actions)

### RND-NX 관련 문서
- [Tech Blog Architecture](../../apps/tech-blog/README.md)
- [Nx Workspace Guide](./nx/workspace-guide.md)
- [Backend Development Guide](../be/)

### 기술 스택 문서
- [NestJS Documentation](https://docs.nestjs.com/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Nestia Documentation](https://nestia.io/)
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vite.dev/)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)
- [Spring Boot Documentation](https://spring.io/projects/spring-boot)
- [Vue Documentation](https://vuejs.org/)
- [Angular Documentation](https://angular.io/)

---

## 버전 히스토리

- **v3.0** (2025-10-23): 개별 기술 스택 Template으로 분리
  - Tech Blog 기술 스택을 개별 Template으로 분리
  - 일반 기술 스택 Template 추가
  - 선택적 조합 가능한 Template 구조
  - 기존 PostgreSQL 데이터베이스 연동
  - Template 분류 및 선택 전략 추가

---

## 기여 가이드

Template 개선 제안 또는 버그 리포트는 다음 채널로:
- GitHub Issues: [RND-NX Issues](https://github.com/VntgCorp/RND-NX/issues)
- Slack: #rnd-nx-support
- Email: platform-team@vntg.com

---

**작성자**: Platform Team  
**최종 수정**: 2025-10-23  
**문서 상태**: Draft
