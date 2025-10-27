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

### Step 1: 실제 구현된 Template 구조

현재 `/Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/templates/` 디렉토리에 다음과 같은 Template들이 구현되어 있습니다:

```
catalog/templates/
├── backend-nestjs-prisma-test/
│   ├── template.yaml
│   └── skeleton/
│       ├── catalog-info.yaml.hbs
│       ├── package.json.hbs
│       ├── prisma/
│       │   ├── schema.prisma.hbs
│       │   └── seed.ts.hbs
│       └── src/
│           ├── app.module.ts.hbs
│           ├── main.ts.hbs
│           └── modules/
│               ├── categories/
│               │   ├── categories.controller.ts.hbs
│               │   ├── categories.module.ts.hbs
│               │   └── categories.service.ts.hbs
│               ├── posts/
│               │   ├── dto/
│               │   ├── posts.controller.ts.hbs
│               │   ├── posts.module.ts.hbs
│               │   └── posts.service.ts.hbs
│               ├── prisma/
│               │   ├── prisma.module.ts.hbs
│               │   └── prisma.service.ts.hbs
│               └── users/
│
├── frontend-react-vite-test/
│   ├── template.yaml
│   └── skeleton/
│       ├── catalog-info.yaml.hbs
│       ├── index.html.hbs
│       ├── package.json.hbs
│       ├── vite.config.ts.hbs
│       └── src/
│           ├── App.tsx.hbs
│           ├── components/
│           │   ├── Layout.tsx.hbs
│           │   ├── PostCard.tsx.hbs
│           │   └── ui/
│           ├── hooks/
│           │   └── usePosts.ts.hbs
│           ├── index.css.hbs
│           ├── lib/
│           │   └── api/
│           ├── main.tsx.hbs
│           ├── pages/
│           │   └── Home.tsx.hbs
│           └── stores/
│
├── backend-spring-boot/
│   ├── template.yaml
│   └── skeleton/
│       ├── catalog-info.yaml.hbs
│       ├── pom.xml.hbs
│       └── src/
│           └── main/
│               ├── java/
│               │   └── com/
│               │       └── {{values.projectName}}/
│               │           └── {{values.projectName | capitalize}}Application.java.hbs
│               └── resources/
│                   └── application.yml.hbs
│
└── frontend-vue/
    ├── template.yaml
    └── skeleton/
        ├── catalog-info.yaml.hbs
        ├── package.json.hbs
        └── src/
            ├── App.vue.hbs
            ├── components/
            ├── main.js.hbs
            ├── router/
            │   └── index.js.hbs
            ├── stores/
            └── views/
                └── HomeView.vue.hbs
```

### Step 2: Template 등록 상태

`app-config.yaml`에 다음과 같이 등록되어 있습니다:

```yaml:339:345:rnd-backstage/app-config.yaml
    - type: file
      target: ../../catalog/templates/backend-nestjs-prisma-test/template.yaml
      rules:
        - allow: [Template]
    - type: file
      target: ../../catalog/templates/frontend-react-vite-test/template.yaml
      rules:
        - allow: [Template]
```

### Step 3: Template 사용 방법

1. Backstage 시작
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn dev
```

2. Template 선택
   - 브라우저에서 http://localhost:3000 접속
   - 왼쪽 메뉴에서 **Create** 클릭
   - Template 목록에서 선택:
     - `Backend NestJS + Prisma (test)`
     - `Frontend React + Vite (test)`
     - `Backend Spring Boot`
     - `Frontend Vue`

3. 파라미터 입력
   각 Template에 맞는 파라미터를 입력합니다.

---

## 실제 구현된 Template 상세

### Frontend React + Vite Template

#### Template 설정 (`template.yaml`)

```yaml:1:155:rnd-backstage/catalog/templates/frontend-react-vite-test/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: frontend-react-vite-test
  title: Frontend React + Vite (test)
  description: |
    React + Vite 기반 프론트엔드 Template (Tech Blog 기반)
    - PostgreSQL 데이터 조회 화면
    - TailwindCSS + shadcn/ui
    - Zustand 상태 관리
    - Type-safe API 통신
```

**주요 특징:**
- PostgreSQL 데이터를 조회하는 화면 포함
- TailwindCSS + Dark Mode 지원
- Zustand 상태 관리
- Nestia/Axios/Fetch API 선택 가능

#### 생성되는 파일 구조

```
프로젝트명-user-client/
├── package.json          # 의존성: React, Vite, TailwindCSS, Zustand, Radix UI
├── vite.config.ts        # Vite 설정 + API Proxy
├── index.html.hbs        # HTML 엔트리
├── catalog-info.yaml.hbs # Backstage 카탈로그 등록
└── src/
    ├── main.tsx.hbs      # React 엔트리
    ├── index.css.hbs     # TailwindCSS 설정
    ├── App.tsx.hbs       # React Router 설정
    ├── components/
    │   ├── Layout.tsx.hbs    # 네비게이션 레이아웃
    │   ├── PostCard.tsx.hbs  # 게시물 카드 컴포넌트
    │   └── ui/                # shadcn/ui 컴포넌트
    ├── pages/
    │   └── Home.tsx.hbs  # PostgreSQL 데이터 조회 페이지
    ├── hooks/
    │   └── usePosts.ts.hbs  # PostgreSQL 데이터 fetching 훅
    ├── lib/
    │   └── api/          # API 클라이언트
    └── stores/            # Zustand 상태 관리
```

#### 핵심 코드 예시

**usePosts.ts.hbs** - PostgreSQL 데이터 조회
```typescript:14:27:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/src/hooks/usePosts.ts.hbs
  const fetchPosts = async () => {
    try {
      setLoading(true);
      const response = await fetch('http://localhost:3000/api/categories');
      if (response.ok) {
        const apiResponse = await response.json();
        setPosts(apiResponse.data);
      }
    } catch (error) {
      console.error('Failed to fetch posts:', error);
    } finally {
      setLoading(false);
    }
  };
```

**vite.config.ts.hbs** - API Proxy 설정
```typescript:9:15:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/vite.config.ts.hbs
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
```

**package.json.hbs** - 의존성
```json:13:27:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/package.json.hbs
  "dependencies": {
    "react": "^19.1.1",
    "react-dom": "^19.1.1",
    "react-router-dom": "^7.8.0",
    "zustand": "^5.0.7",
    "react-hook-form": "^7.62.0",
    "zod": "^4.0.17",
    "axios": "^1.11.0",
    "tailwindcss": "^3.4.17",
    "@radix-ui/react-slot": "^1.2.3",
    "class-variance-authority": "^0.7.1",
    "clsx": "^2.1.1",
    "tailwind-merge": "^3.3.1",
    "lucide-react": "^0.539.0"
```

### Backend NestJS + Prisma Template

#### Template 설정 (`template.yaml`)

```yaml:1:139:rnd-backstage/catalog/templates/backend-nestjs-prisma-test/template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: backend-nestjs-prisma-test
  title: Backend NestJS + Prisma (test)
  description: |
    NestJS + Prisma 기반 백엔드 Template (Tech Blog 기반)
    - PostgreSQL 기존 DB 연동
    - JWT 인증
    - Type-safe API (Nestia)
    - 기본 CRUD 기능
```

**주요 특징:**
- PostgreSQL 기존 데이터베이스 연동
- Prisma ORM 사용
- NestJS 모듈 구조
- JWT 인증 지원
- Nestia Type-safe API 생성

#### 생성되는 파일 구조

```
프로젝트명-api-server/
├── package.json.hbs       # NestJS, Prisma, Nestia 의존성
├── catalog-info.yaml.hbs # Backstage 카탈로그 등록
├── prisma/
│   ├── schema.prisma.hbs # Prisma 스키마
│   └── seed.ts.hbs       # Seed 데이터
└── src/
    ├── app.module.ts.hbs # NestJS 앱 모듈
    ├── main.ts.hbs       # NestJS 진입점
    └── modules/
        ├── categories/   # 카테고리 모듈 (CRUD)
        ├── posts/       # 게시물 모듈 (CRUD)
        ├── prisma/       # Prisma 서비스
        └── users/        # 사용자 모듈
```

#### 핵심 코드 예시

**package.json.hbs** - 백엔드 의존성
```json:18:33:rnd-backstage/catalog/templates/backend-nestjs-prisma-test/skeleton/package.json.hbs
  "dependencies": {
    "@nestjs/common": "^11.2.5",
    "@nestjs/core": "^11.2.5",
    "@nestjs/config": "^3.2.0",
    "@nestjs/jwt": "^10.2.0",
    "@nestjs/passport": "^10.0.3",
    "@nestjs/platform-express": "^11.2.5",
    "@nestjs/swagger": "^7.4.0",
    "@prisma/client": "^6.1.0",
    "@nestia/core": "^3.0.0",
    "bcrypt": "^5.1.1",
    "class-validator": "^0.14.1",
    "class-transformer": "^0.5.1",
    "winston": "^3.13.0",
```

**Scripts**
```json:7:16:rnd-backstage/catalog/templates/backend-nestjs-prisma-test/skeleton/package.json.hbs
  "scripts": {
    "build": "nest build",
    "start:local": "NODE_ENV=local nest start --watch",
    "start:dev": "NODE_ENV=dev nest start --watch",
    "start:prod": "NODE_ENV=prod node dist/main",
    "test": "jest",
    "db:generate": "npx prisma generate",
    "db:migrate": "npx prisma migrate dev",
    "db:seed": "ts-node prisma/seed.ts",
    "nestia:sdk": "npx nestia sdk",
```

### Tech Blog 원본 프로젝트와의 연계

Template들은 `/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/` 구조를 기반으로 설계되었습니다:

```
RND-NX/apps/tech-blog/
├── api-server/          # Backend NestJS + Prisma Template의 원본
│   ├── catalog-info.yaml
│   └── src/
│       ├── modules/
│       │   ├── categories/
│       │   ├── posts/
│       │   ├── prisma/
│       │   └── users/
│       └── prisma/
│           └── schema.prisma
│
├── user-client/         # Frontend React + Vite Template의 원본
│   ├── catalog-info.yaml
│   └── src/
│       ├── components/
│       ├── pages/
│       ├── hooks/
│       ├── lib/
│       └── stores/
│
└── api-server-test/     # E2E 테스트 프로젝트
    └── catalog-info.yaml
```

**카탈로그 등록 구조:**

```yaml:1:45:RND-NX/apps/tech-blog/api-server/catalog-info.yaml
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
    - Kafka를 통한 이벤트 기반 아키텍처
    - WebSocket 실시간 채팅 지원
  tags:
    - nestjs
    - prisma
    - postgresql
    - api
    - typescript
    - kafka
    - websocket
  annotations:
    github.com/project-slug: VntgCorp/RND-NX
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: backend-services
  providesApis:
    - tech-blog-rest-api
  dependsOn:
    - resource:tech-blog-database
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

#### A. Frontend React + Vite Template 사용 시

```bash
# 1. 생성된 저장소 클론
git clone https://github.com/company/project-name-user-client.git
cd project-name-user-client

# 2. 의존성 설치
pnpm install

# 3. 개발 서버 실행
pnpm dev
# → http://localhost:5173 에서 확인 가능
```

**생성되는 구조:**
- ✅ React 19 + TypeScript
- ✅ Vite 7 빌드 도구
- ✅ TailwindCSS 3 스타일링
- ✅ Zustand 상태 관리
- ✅ PostgreSQL 데이터 조회 화면
- ✅ Backstage 카탈로그 자동 등록

#### B. Backend NestJS + Prisma Template 사용 시

```bash
# 1. 생성된 저장소 클론
git clone https://github.com/company/project-name-api-server.git
cd project-name-api-server

# 2. 의존성 설치
pnpm install

# 3. 환경 변수 설정
# .env 파일이 자동 생성됨
# DATABASE_URL 수정
nano .env

# 4. Prisma 설정
npx prisma generate
npx prisma migrate dev --name init
npx prisma db seed

# 5. 개발 서버 실행
pnpm start:dev
# → http://localhost:3000 에서 확인 가능
```

**생성되는 구조:**
- ✅ NestJS 11 + TypeScript
- ✅ Prisma 6 ORM
- ✅ PostgreSQL 연결
- ✅ JWT 인증
- ✅ 기본 CRUD 모듈 (Posts, Categories, Users)
- ✅ Swagger API 문서
- ✅ Backstage 카탈로그 자동 등록

#### C. 통합 개발 흐름

```bash
# 1. Backend Template으로 API 서버 생성
# → GitHub 저장소 자동 생성
# → Backstage 카탈로그에 등록

# 2. Frontend Template으로 클라이언트 생성
# → GitHub 저장소 자동 생성
# → Backstage 카탈로그에 등록
# → API 서버와 자동 연결 (consumesApis)

# 3. 로컬 개발 환경 구축
# Backend
cd project-name-api-server
pnpm install
npx prisma migrate dev
pnpm start:dev

# Frontend (새 터미널)
cd project-name-user-client
pnpm install
pnpm dev
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

## 구현 완료 현황

### ✅ 완료된 Template 목록

#### Tech Blog 기반 Templates (실제 구현 완료)
1. **Backend NestJS + Prisma (test)** ✅
   - 위치: `rnd-backstage/catalog/templates/backend-nestjs-prisma-test/`
   - 상태: 구현 완료, 테스트 필요
   - 기능: PostgreSQL 연결, JWT 인증, 기본 CRUD

2. **Frontend React + Vite (test)** ✅
   - 위치: `rnd-backstage/catalog/templates/frontend-react-vite-test/`
   - 상태: 구현 완료, 테스트 필요
   - 기능: PostgreSQL 데이터 조회, TailwindCSS, Zustand

#### 일반 기술 스택 Templates (부분 구현)
3. **Backend Spring Boot** 🟡
   - 위치: `rnd-backstage/catalog/templates/backend-spring-boot/`
   - 상태: 기본 구조 완료, 상세 구현 필요

4. **Frontend Vue** 🟡
   - 위치: `rnd-backstage/catalog/templates/frontend-vue/`
   - 상태: 기본 구조 완료, 상세 구현 필요

### 📝 구현 체크리스트

#### Frontend React + Vite Template
- [x] Template YAML 작성
- [x] Skeleton 파일 구조 설계
- [x] Handlebars 템플릿 작성
- [x] package.json.hbs (React, Vite, TailwindCSS, Zustand)
- [x] vite.config.ts.hbs (API Proxy 설정)
- [x] src/App.tsx.hbs (React Router)
- [x] src/components/Layout.tsx.hbs (네비게이션)
- [x] src/components/PostCard.tsx.hbs (컴포넌트)
- [x] src/pages/Home.tsx.hbs (PostgreSQL 데이터 조회)
- [x] src/hooks/usePosts.ts.hbs (데이터 fetching)
- [x] catalog-info.yaml.hbs (Backstage 등록)
- [x] Template 등록 (app-config.yaml)
- [ ] 실제 프로젝트 생성 테스트
- [ ] PostgreSQL 연동 테스트
- [ ] Backstage Catalog 자동 등록 테스트

#### Backend NestJS + Prisma Template
- [x] Template YAML 작성
- [x] Skeleton 파일 구조 설계
- [x] package.json.hbs (NestJS, Prisma, Nestia)
- [x] Template 등록 (app-config.yaml)
- [ ] 실제 프로젝트 생성 테스트
- [ ] PostgreSQL 연동 테스트
- [ ] Nestia SDK 생성 테스트
- [ ] Backstage Catalog 자동 등록 테스트

### 🔧 실제 구현 상세

#### Template 등록 위치
```yaml:339:345:rnd-backstage/app-config.yaml
# Tech Blog 기반 Templates
- type: file
  target: ../../catalog/templates/backend-nestjs-prisma-test/template.yaml
  rules:
    - allow: [Template]
- type: file
  target: ../../catalog/templates/frontend-react-vite-test/template.yaml
  rules:
    - allow: [Template]
```

#### Template 원본 프로젝트
- **Backend**: `/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/`
- **Frontend**: `/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/user-client/`
- **Catalog**: `rnd-backstage/catalog/` (System, Domain, API, Resource 정의)

#### Template Actions 흐름
1. **fetch:template** - Skeleton 파일들을 Handlebars로 처리
2. **publish:github** - GitHub 저장소 생성 및 코드 푸시
3. **catalog:register** - Backstage 카탈로그에 자동 등록
4. **환경 변수 설정** - `.env` 파일 자동 생성

---

## 참고 자료

### Backstage 공식 문서
- [Software Templates](https://backstage.io/docs/features/software-templates/)
- [Writing Templates](https://backstage.io/docs/features/software-templates/writing-templates)
- [Builtin Actions](https://backstage.io/docs/features/software-templates/builtin-actions)

### RND-NX 관련 문서
- [Tech Blog 카탈로그 설정](./TECH_BLOG_CATALOG_SETUP.md)
- [Software Template 가이드 v3](./software_template_guide_v3.md)
- [Backstage 카탈로그 확장](./BACKSTAGE_CATALOG_EXPANSION_PLAN.md)

### 기술 스택 문서
- [NestJS Documentation](https://docs.nestjs.com/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Nestia Documentation](https://nestia.io/)
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vite.dev/)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)
- [Handlebars Syntax](https://handlebarsjs.com/guide/)

---

## 버전 히스토리

- **v3.1** (2025-10-24): 실제 구현 내용 통합
  - Frontend React + Vite Template 구현 완료
  - Backend NestJS + Prisma Template 구현 완료
  - 실제 파일 구조 및 코드 예시 추가
  - Template 등록 상태 및 사용 가이드 추가
  - 구현 체크리스트 및 완료 현황 추가

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
**최종 수정**: 2025-10-24  
**문서 상태**: v3.1 (Implementation Complete)

### 문서 개요
이 문서는 RND-NX 프로젝트의 Tech Blog를 Backstage Software Template으로 구현한 내용을 정리한 기술 가이드입니다. 실제 구현된 코드와 구조를 기반으로 작성되었으며, 개발자가 직접 참고하여 사용할 수 있는 실무 가이드입니다.

**핵심 내용:**
- ✅ 실제 구현 완료된 Template 목록
- ✅ 구체적인 파일 구조 및 코드 예시
- ✅ Template 사용 방법 및 파라미터
- ✅ 생성 후 개발 가이드
- ✅ Tech Blog 원본 프로젝트와의 연계
