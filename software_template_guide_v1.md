# Backstage Software Template 가이드 v1.0

## 목차
1. [개요](#개요)
2. [Tech Blog 프로젝트 분석](#tech-blog-프로젝트-분석)
3. [Software Template 설계](#software-template-설계)
4. [Template 구현 가이드](#template-구현-가이드)
5. [사용 예시](#사용-예시)

---

## 개요

### Software Template이란?
Backstage Software Template(Scaffolder)는 새로운 프로젝트나 서비스를 일관된 구조와 Best Practice를 기반으로 자동 생성하는 기능입니다. 이를 통해:
- 표준화된 프로젝트 구조 유지
- 개발 시작 시간 단축
- 일관된 코드 품질 보장
- 반복적인 설정 작업 자동화

### 목표
RND-NX 모노레포 내 tech-blog 프로젝트를 기반으로 한 Software Template을 설계하여, 유사한 풀스택 블로그/CMS 애플리케이션을 빠르게 생성할 수 있도록 합니다.

---

## Tech Blog 프로젝트 분석

### 1. 프로젝트 구조

Tech Blog는 다음 3개의 주요 프로젝트로 구성됩니다:

```
apps/tech-blog/
├── api-server/          # NestJS 백엔드 서버
├── user-client/         # React 프론트엔드 클라이언트
└── api-server-test/     # E2E 테스트 프로젝트
```

### 2. API Server (Backend) 기술 스택

#### 핵심 프레임워크 & 라이브러리
- **NestJS** (^11.2.5): Node.js 백엔드 프레임워크
- **Prisma** (^6.1.0): ORM (Object-Relational Mapping)
- **PostgreSQL**: 데이터베이스
- **Nestia**: Type-safe API SDK 자동 생성
- **TypeScript** (5.8.3): 정적 타입 시스템

#### 주요 기능 모듈
```typescript
src/
├── modules/
│   ├── categories/      # 카테고리 관리
│   ├── comments/        # 댓글 시스템
│   ├── departments/     # 부서/조직 관리
│   ├── likes/          # 좋아요 기능
│   ├── notifications/   # 알림 시스템
│   ├── posts/          # 게시물 CRUD
│   └── tags/           # 태그 시스템
└── infrastructures/
    └── kafka/          # 이벤트 기반 메시징
```

#### 인증/인가
- **JWT (JSON Web Token)**: 인증 토큰
- **Passport**: 인증 미들웨어
- **bcrypt**: 비밀번호 해싱
- **Refresh Token**: 토큰 갱신 메커니즘

#### 실시간 통신
- ~~**WebSocket** (Socket.io): 실시간 채팅~~ (제외)
- ~~**Kafka**: 비동기 이벤트 처리~~ (제외)

#### API 문서화
- **Nestia Swagger**: 자동 API 문서 생성
- Swagger UI Path: `/api/swagger`

#### 데이터베이스 스키마 (Prisma)

주요 모델:
```prisma
- User: 사용자 관리
- Post: 게시물 (status: DRAFT/PUBLISHED, visibility: PUBLIC/PRIVATE)
- Comment: 댓글 (계층형 구조 지원)
- Like: 좋아요
- Category: 카테고리
- Tag: 태그
- Department: 부서
- Notification: 알림
- RefreshToken: 리프레시 토큰
```

#### Nx 빌드 타겟
```json
{
  "build": "nest build",
  "serve:local": "NODE_ENV=local nest start --watch",
  "serve:dev": "NODE_ENV=dev nest start --watch",
  "serve:staging": "NODE_ENV=staging nest start --watch",
  "serve:prod": "NODE_ENV=prod node dist/main",
  "test": "jest",
  "test:e2e": "jest --config ./test/jest-e2e.json",
  "db:generate": "npx prisma generate",
  "db:migrate": "npx prisma migrate dev",
  "db:seed": "ts-node prisma/seed.ts",
  "nestia:sdk": "npx nestia sdk",
  "nestia:swagger": "npx nestia swagger",
  "docker:up": "make -C docker all-up",
  "docker:down": "make -C docker all-down"
}
```

#### 의존성 라이브러리
```typescript
// 내부 라이브러리 (libs/)
libs-be-common
libs-be-auth
libs-be-prisma
libs-be-users
libs-be-swagger

// 외부 라이브러리 (주요)
@nestjs/common, @nestjs/core, @nestjs/config
@nestjs/jwt, @nestjs/passport, @nestjs/platform-express
@prisma/client
bcrypt
class-validator, class-transformer
winston (로깅)
helmet (보안)
typia (런타임 타입 검증)
```

### 3. User Client (Frontend) 기술 스택

#### 핵심 프레임워크 & 라이브러리
- **React** (19.1.1): UI 라이브러리
- **Vite** (7.1.4): 빌드 도구
- **TypeScript** (5.8.3): 정적 타입 시스템
- **React Router DOM** (7.8.0): 클라이언트 라우팅

#### UI/UX 라이브러리
- **TailwindCSS** (3.4.17): 유틸리티 기반 CSS 프레임워크
- **Radix UI**: 접근성 높은 UI 컴포넌트 라이브러리
  - alert-dialog, avatar, checkbox, dropdown-menu
  - label, radio-group, select, slot, tooltip
- **shadcn/ui**: TailwindCSS + Radix UI 기반 컴포넌트
- **Lucide React**: 아이콘 라이브러리
- **next-themes**: 다크모드 지원

#### 상태 관리
- **Zustand** (5.0.7): 경량 상태 관리
- **React Hook Form** (7.62.0): 폼 상태 관리
- **Zod** (4.0.17): 스키마 검증
- **@tanstack/react-query** (5.85.0): 서버 상태 관리

#### API 통신
- **@nestia/fetcher** (8.0.7): Type-safe API 클라이언트
- **Axios** (1.11.0): HTTP 클라이언트
- **Typia** (9.7.2): 런타임 타입 검증

#### 에디터
- **Lexical Editor** (@lexical/react, @lexical/rich-text): 
  - 고급 텍스트 에디터
  - 블로그 포스트 작성에 사용

#### 보안
- **crypto-js** (4.2.0): 암호화 유틸리티

#### Nx 빌드 타겟
```json
{
  "build": "tsc && vite build",
  "serve": "vite --force",
  "dev": "vite",
  "preview": "vite preview",
  "lint": "eslint . --ext ts,tsx",
  "type-check": "tsc --noEmit",
  "sync-tokens": "node sync-design-tokens.js"
}
```

#### 주요 디렉토리 구조
```
src/
├── api/                    # Nestia 자동 생성 SDK
│   ├── functional/         # API 엔드포인트별 함수
│   └── structures/         # DTO 타입 정의
├── components/
│   ├── blocks/            # 에디터 블록 컴포넌트
│   ├── editor/            # 에디터 UI
│   └── ui/                # shadcn/ui 컴포넌트
├── hooks/                 # 커스텀 훅
├── lib/
│   ├── api/               # API 어댑터
│   └── utils.ts           # 유틸리티 함수
├── pages/                 # 페이지 컴포넌트
└── stores/                # Zustand 상태 관리
```

### 4. API Server Test 기술 스택

#### 테스트 프레임워크
- **Jest**: 테스트 프레임워크
- **ts-jest**: TypeScript Jest 변환기
- **dotenv**: 환경변수 관리

#### 테스트 타입
```
src/
├── setup/          # 초기 설정 테스트
├── api/            # API 통합 테스트
├── health/         # 헬스체크 테스트
└── regression/     # 회귀 테스트
```

#### Nx 타겟
```json
{
  "test": "jest",
  "test:setup": "jest setup/",
  "test:api": "jest api/",
  "test:health": "jest health/",
  "test:regression": "jest regression/",
  "test:watch": "jest --watch",
  "test:coverage": "jest --coverage"
}
```

### 5. 공통 인프라

#### Database
- **PostgreSQL**: 기존 데이터베이스 서버 연동
- **Prisma ORM**: 데이터베이스 스키마 관리 및 마이그레이션

#### 환경 설정
- **다중 환경 지원**: local, dev, staging, prod
- **NODE_ENV**: 환경별 설정 분기

#### Nx 태그 시스템
```typescript
// API Server
tags: ["layer:app", "group:tech-blog", "platform:nest", "type:api-server", "type:be"]

// User Client
tags: ["layer:app", "type:fe", "platform:react", "group:tech-blog"]

// Test
tags: ["layer:app", "type:backend", "platform:nest", "group:tech-blog"]
```

---

## Software Template 설계

### 1. Template 목표

tech-blog를 기반으로 다음과 같은 프로젝트를 자동 생성:
- **풀스택 블로그/CMS 시스템**
- **NestJS + React 조합**
- **Nx 모노레포 통합**
- **Type-safe API 통신 (Nestia)**
- **PostgreSQL + Prisma ORM**

### 2. Template Parameters (사용자 입력)

Backstage UI에서 사용자에게 받을 입력 값:

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
        description: 프로젝트 식별자 (예: my-blog, cms-system)
        pattern: '^[a-z][a-z0-9-]*$'
        ui:autofocus: true
        
      description:
        title: 프로젝트 설명
        type: string
        description: 프로젝트에 대한 간단한 설명
        
      owner:
        title: 소유자
        type: string
        description: 팀 또는 소유자 (예: group:backend-team)
        ui:field: OwnerPicker
        ui:options:
          allowedKinds:
            - Group
            - User

  - title: 백엔드 설정
    properties:
      databaseUrl:
        title: 데이터베이스 연결 URL
        type: string
        description: PostgreSQL 데이터베이스 연결 문자열
        default: postgresql://username:password@localhost:5432/tech_blog_db
        ui:field: Secret

  - title: 프론트엔드 설정
    properties:
      enableDarkMode:
        title: 다크모드 지원
        type: boolean
        default: true
        
      enableEditor:
        title: Lexical 에디터 포함
        type: boolean
        description: 고급 텍스트 에디터 포함 여부
        default: true
        
      uiLibrary:
        title: UI 컴포넌트 라이브러리
        type: string
        enum:
          - radix-ui
          - mui
        enumNames:
          - Radix UI (shadcn/ui)
          - Material UI
        default: radix-ui

  - title: 배포 설정
    properties:
      environments:
        title: 환경 설정
        type: array
        items:
          type: string
          enum:
            - local
            - dev
            - staging
            - prod
        default: [local, dev, staging, prod]
        
      enableDocker:
        title: Docker 설정 포함
        type: boolean
        description: Docker Compose 설정 파일 포함 여부 (선택적)
        default: false
        
      enableCI:
        title: GitHub Actions CI/CD
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
        ui:options:
          allowedHosts:
            - github.com
```

### 3. Template 파일 구조

Template 파일은 다음과 같이 구성됩니다:

```
catalog/templates/tech-blog-fullstack/
├── template.yaml                    # Template 정의 파일
├── skeleton/                        # 템플릿 파일들
│   ├── apps/
│   │   └── ${{values.projectName}}/
│   │       ├── api-server/
│   │       │   ├── src/
│   │       │   │   ├── app.module.ts.hbs
│   │       │   │   ├── main.ts.hbs
│   │       │   │   └── modules/
│   │       │   │       ├── posts/
│   │       │   │       ├── comments/
│   │       │   │       ├── categories/
│   │       │   │       ├── tags/
│   │       │   │       └── likes/
│   │       │   ├── prisma/
│   │       │   │   ├── schema.prisma.hbs
│   │       │   │   └── seed.ts.hbs
│   │       │   ├── docker/
│   │       │   │   ├── docker-compose.app.yml.hbs
│   │       │   │   └── Dockerfile
│   │       │   ├── package.json.hbs
│   │       │   ├── nestia.config.ts.hbs
│   │       │   ├── tsconfig.json
│   │       │   └── catalog-info.yaml.hbs
│   │       │
│   │       ├── user-client/
│   │       │   ├── src/
│   │       │   │   ├── components/
│   │       │   │   │   ├── ui/            # shadcn/ui 컴포넌트
│   │       │   │   │   ├── editor/        # (conditional: enableEditor)
│   │       │   │   │   ├── ThemeProvider.tsx  # (conditional: enableDarkMode)
│   │       │   │   │   └── Layout.tsx
│   │       │   │   ├── pages/
│   │       │   │   ├── hooks/
│   │       │   │   ├── stores/
│   │       │   │   └── lib/
│   │       │   ├── package.json.hbs
│   │       │   ├── vite.config.ts.hbs
│   │       │   ├── tailwind.config.js.hbs
│   │       │   └── catalog-info.yaml.hbs
│   │       │
│   │       └── api-server-test/
│   │           ├── src/
│   │           ├── package.json.hbs
│   │           └── catalog-info.yaml.hbs
│   │
│   ├── .github/
│   │   └── workflows/
│   │       └── ci.yml.hbs              # (conditional: enableCI)
│   │
│   └── README.md.hbs
```

### 4. Template Actions (Steps)

```yaml
steps:
  # 1. Template 파일 가져오기
  - id: fetch-base
    name: Fetch Base Template
    action: fetch:template
    input:
      url: ./skeleton
      values:
        projectName: ${{ parameters.projectName }}
        description: ${{ parameters.description }}
        owner: ${{ parameters.owner }}
        databaseUrl: ${{ parameters.databaseUrl }}
        enableDarkMode: ${{ parameters.enableDarkMode }}
        enableEditor: ${{ parameters.enableEditor }}
        uiLibrary: ${{ parameters.uiLibrary }}
        enableDocker: ${{ parameters.enableDocker }}
        enableCI: ${{ parameters.enableCI }}

  # 2. GitHub 저장소 생성 및 코드 푸시
  - id: publish
    name: Publish to GitHub
    action: publish:github
    input:
      description: ${{ parameters.description }}
      repoUrl: ${{ parameters.repoUrl }}
      defaultBranch: develop
      protectDefaultBranch: false
      repoVisibility: private

  # 3. Nx Workspace에 프로젝트 등록
  - id: register-nx-project
    name: Register in Nx Workspace
    action: fs:write
    input:
      path: ${{ parameters.repoUrl }}/nx.json
      content: |
        {
          "projects": {
            "${{ parameters.projectName }}-api-server": "apps/${{ parameters.projectName }}/api-server",
            "${{ parameters.projectName }}-user-client": "apps/${{ parameters.projectName }}/user-client",
            "${{ parameters.projectName }}-api-server-test": "apps/${{ parameters.projectName }}/api-server-test"
          }
        }

  # 4. Catalog에 Component 등록
  - id: register-catalog
    name: Register Components in Catalog
    action: catalog:register
    input:
      repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
      catalogInfoPath: '/apps/${{ parameters.projectName }}/api-server/catalog-info.yaml'
      
  - id: register-catalog-client
    name: Register Client in Catalog
    action: catalog:register
    input:
      repoContentsUrl: ${{ steps['publish'].output.repoContentsUrl }}
      catalogInfoPath: '/apps/${{ parameters.projectName }}/user-client/catalog-info.yaml'

  # 5. 의존성 설치 (선택적)
  - id: install-dependencies
    name: Install Dependencies
    action: run:shell
    input:
      command: |
        cd apps/${{ parameters.projectName }}/api-server && pnpm install
        cd ../user-client && pnpm install

  # 6. Prisma 초기화
  - id: setup-database
    name: Setup Database
    action: run:shell
    input:
      command: |
        cd apps/${{ parameters.projectName }}/api-server
        npx prisma generate
        npx prisma migrate dev --name init

output:
  links:
    - title: Repository
      url: ${{ steps['publish'].output.remoteUrl }}
    - title: API Server Component
      icon: catalog
      entityRef: ${{ steps['register-catalog'].output.entityRef }}
    - title: User Client Component
      icon: catalog
      entityRef: ${{ steps['register-catalog-client'].output.entityRef }}
    - title: API Documentation
      url: http://localhost:3000/api/swagger
      icon: docs
```

### 5. 조건부 파일 생성

Handlebars 템플릿을 사용하여 조건부로 파일 생성:

#### 환경 변수 설정 (databaseUrl 사용)
```typescript
// apps/{{projectName}}/api-server/.env.hbs
DATABASE_URL="{{ values.databaseUrl }}"
JWT_SECRET="your-jwt-secret-key"
NODE_ENV="local"
```

#### Lexical Editor (enableEditor=true일 때만)
```typescript
// apps/{{projectName}}/user-client/src/components/editor/EditorComponent.tsx.hbs
{{#if values.enableEditor}}
import { LexicalComposer } from '@lexical/react/LexicalComposer';
import { RichTextPlugin } from '@lexical/react/LexicalRichTextPlugin';

export function EditorComponent() {
  // ...
}
{{/if}}
```

---

## Template 구현 가이드

### Step 1: Template 디렉토리 생성

```bash
# Backstage 프로젝트 루트에서
mkdir -p catalog/templates/tech-blog-fullstack
cd catalog/templates/tech-blog-fullstack
```

### Step 2: template.yaml 작성

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: tech-blog-fullstack
  title: Tech Blog Full-Stack Application
  description: |
    NestJS + React 기반 풀스택 블로그/CMS 시스템을 생성합니다.
    - Type-safe API (Nestia)
    - PostgreSQL + Prisma ORM
    - WebSocket 실시간 기능
    - Kafka 이벤트 시스템
    - TailwindCSS + shadcn/ui
    - Nx 모노레포 통합
  tags:
    - nestjs
    - react
    - fullstack
    - blog
    - cms
    - nx
    - typescript
  links:
    - url: https://github.com/VntgCorp/RND-NX/tree/develop/apps/tech-blog
      title: 참조 프로젝트
      icon: github
      
spec:
  owner: group:platform-team
  type: application
  
  parameters:
    # (위에서 정의한 parameters 섹션 삽입)
  
  steps:
    # (위에서 정의한 steps 섹션 삽입)
  
  output:
    # (위에서 정의한 output 섹션 삽입)
```

### Step 3: Skeleton 파일 생성

#### 3.1 API Server Package.json Template
```json
// skeleton/apps/${{values.projectName}}/api-server/package.json.hbs
{
  "name": "${{ values.projectName }}-api-server",
  "version": "0.0.1",
  "description": "${{ values.description }}",
  "private": true,
  "scripts": {
    "build": "nest build",
    "start:local": "NODE_ENV=local nest start --watch",
    "start:dev": "NODE_ENV=dev nest start --watch",
    "start:prod": "NODE_ENV=prod node dist/main",
    "test": "jest",
    "db:generate": "npx prisma generate",
    "db:migrate": "npx prisma migrate dev",
    "nestia:sdk": "npx nestia sdk",
    "nestia:swagger": "npx nestia swagger"
  },
  "dependencies": {
    "@nestjs/common": "catalog:backend",
    "@nestjs/core": "catalog:backend",
    "@nestjs/config": "catalog:backend",
    "@nestjs/jwt": "catalog:backend",
    "@nestjs/passport": "catalog:backend",
    "@prisma/client": "catalog:backend",
    "@nestia/core": "catalog:backend",
    "bcrypt": "catalog:backend",
    "class-validator": "catalog:backend",
    "class-transformer": "catalog:backend"
  },
  "devDependencies": {
    "@nestjs/cli": "catalog:backend",
    "@nestia/sdk": "catalog:backend",
    "prisma": "catalog:backend"
  },
  "nx": {
    "tags": ["layer:app", "group:${{ values.projectName }}", "platform:nest", "type:api-server"]
  }
}
```

#### 3.2 Prisma Schema Template
```prisma
// skeleton/apps/${{values.projectName}}/api-server/prisma/schema.prisma.hbs
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id            Int       @id @default(autoincrement())
  email         String    @unique
  password      String
  posts         Post[]
  comments      Comment[]
  likes         Like[]
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  departmentId  Int
  department    Department @relation(fields: [departmentId], references: [id])
}

model Post {
  id          Int        @id @default(autoincrement())
  title       String
  content     String?
  authorId    Int
  author      User       @relation(fields: [authorId], references: [id])
  categories  Category[]
  tags        Tag[]
  comments    Comment[]
  likes       Like[]
  status      Status     @default(DRAFT)
  visibility  Visibility @default(PRIVATE)
  viewCount   Int        @default(0)
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt
}

enum Status {
  DRAFT
  PUBLISHED
}

enum Visibility {
  PUBLIC
  PRIVATE
}

model Category {
  id        Int      @id @default(autoincrement())
  name      String   @unique
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Tag {
  id        Int      @id @default(autoincrement())
  name      String   @unique
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Comment {
  id        Int       @id @default(autoincrement())
  content   String
  authorId  Int
  author    User      @relation(fields: [authorId], references: [id])
  postId    Int
  post      Post      @relation(fields: [postId], references: [id])
  parentId  Int?
  parent    Comment?  @relation("Replies", fields: [parentId], references: [id])
  replies   Comment[] @relation("Replies")
  createdAt DateTime  @default(now())
  updatedAt DateTime  @updatedAt
}

model Like {
  userId    Int
  user      User     @relation(fields: [userId], references: [id])
  postId    Int
  post      Post     @relation(fields: [postId], references: [id])
  createdAt DateTime @default(now())
  
  @@id([userId, postId])
}

model Department {
  id        Int      @id @default(autoincrement())
  name      String   @unique
  users     User[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

#### 3.3 User Client Package.json Template
```json
// skeleton/apps/${{values.projectName}}/user-client/package.json.hbs
{
  "name": "${{ values.projectName }}-user-client",
  "version": "0.0.1",
  "description": "${{ values.description }} - Frontend",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "tsc && vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext ts,tsx"
  },
  "dependencies": {
    "react": "^19.1.1",
    "react-dom": "^19.1.1",
    "react-router-dom": "^7.8.0",
    "@nestia/fetcher": "^8.0.7",
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
    {{#if values.enableDarkMode}}
    ,"next-themes": "^0.4.6"
    {{/if}}
    {{#if values.enableEditor}}
    ,"@lexical/react": "^0.34.0",
    "@lexical/rich-text": "^0.34.0",
    "lexical": "^0.34.0"
    {{/if}}
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^5.0.0",
    "typescript": "~5.8.3",
    "vite": "^7.1.2",
    "eslint": "^9.33.0"
  },
  "nx": {
    "tags": ["layer:app", "type:fe", "platform:react", "group:${{ values.projectName }}"]
  }
}
```

#### 3.4 Catalog Info Templates

**API Server Catalog Info:**
```yaml
# skeleton/apps/${{values.projectName}}/api-server/catalog-info.yaml.hbs
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.projectName }}-api-server
  description: |
    ${{ values.description }} - Backend API Server
    - NestJS Framework
    - PostgreSQL + Prisma ORM
    - JWT Authentication
  tags:
    - nestjs
    - prisma
    - postgresql
    - api
    - typescript
  annotations:
    github.com/project-slug: ${{ parameters.repoUrl | parseRepoUrl }}
    backstage.io/techdocs-ref: dir:.
  links:
    - url: http://localhost:3000/api/swagger
      title: Swagger API Documentation
      icon: docs
spec:
  type: service
  lifecycle: production
  owner: ${{ values.owner }}
  system: ${{ values.projectName }}-system
  providesApis:
    - ${{ values.projectName }}-rest-api
  dependsOn:
    - resource:${{ values.projectName }}-database
```

**User Client Catalog Info:**
```yaml
# skeleton/apps/${{values.projectName}}/user-client/catalog-info.yaml.hbs
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.projectName }}-user-client
  description: |
    ${{ values.description }} - Frontend Client
    - React + Vite
    - TailwindCSS
    {{#if values.enableEditor}}
    - Lexical Editor
    {{/if}}
    {{#if values.enableDarkMode}}
    - Dark Mode Support
    {{/if}}
  tags:
    - react
    - vite
    - frontend
    - tailwindcss
    - typescript
  annotations:
    github.com/project-slug: ${{ parameters.repoUrl | parseRepoUrl }}
    backstage.io/techdocs-ref: dir:.
spec:
  type: website
  lifecycle: production
  owner: ${{ values.owner }}
  system: ${{ values.projectName }}-system
  consumesApis:
    - ${{ values.projectName }}-rest-api
```

### Step 4: Backstage Catalog에 Template 등록

```yaml
# backstage/catalog-info.yaml 또는 별도 파일
apiVersion: backstage.io/v1alpha1
kind: Location
metadata:
  name: tech-blog-templates
  description: Tech Blog Software Templates
spec:
  type: url
  targets:
    - ./catalog/templates/tech-blog-fullstack/template.yaml
```

또는 app-config.yaml에 등록:

```yaml
# app-config.yaml
catalog:
  locations:
    - type: file
      target: ../../catalog/templates/tech-blog-fullstack/template.yaml
      rules:
        - allow: [Template]
```

### Step 5: Template 테스트

1. Backstage 재시작
```bash
yarn dev
```

2. Backstage UI에서 확인
   - `/create` 페이지 방문
   - "Tech Blog Full-Stack Application" 템플릿 확인

3. 테스트 프로젝트 생성
   - 템플릿 선택
   - 파라미터 입력
   - 프로젝트 생성

---

## 사용 예시

### 예시 1: 기본 블로그 시스템 생성

**입력 파라미터:**
```yaml
projectName: company-blog
description: 회사 기술 블로그 시스템
owner: group:engineering-team
databaseUrl: postgresql://username:password@localhost:5432/company_blog_db
enableDarkMode: true
enableEditor: true
uiLibrary: radix-ui
enableDocker: false
enableCI: true
```

**생성되는 구조:**
```
apps/company-blog/
├── api-server/
│   ├── src/
│   │   └── modules/
│   │       ├── posts/
│   │       ├── comments/
│   │       ├── categories/
│   │       └── tags/
│   ├── prisma/
│   └── catalog-info.yaml
├── user-client/
│   ├── src/
│   │   ├── components/
│   │   │   ├── editor/      # Lexical Editor 포함
│   │   │   └── ui/
│   │   └── pages/
│   └── catalog-info.yaml
└── api-server-test/
```

### 예시 2: 간단한 CMS 시스템

**입력 파라미터:**
```yaml
projectName: cms-platform
description: 간단한 CMS 플랫폼
owner: group:product-team
databaseUrl: postgresql://username:password@localhost:5432/cms_platform_db
enableDarkMode: true
enableEditor: true
uiLibrary: radix-ui
enableDocker: false
enableCI: true
```

**생성되는 구조:**
```
apps/cms-platform/
├── api-server/
│   ├── src/
│   │   └── modules/
│   │       ├── posts/
│   │       ├── comments/
│   │       ├── categories/
│   │       └── tags/
│   └── prisma/
│       └── schema.prisma     # 기본 블로그 모델만 포함
└── user-client/
    └── src/
        └── components/
            └── editor/       # Lexical Editor 포함
```

### 예시 3: 최소 설정 블로그

**입력 파라미터:**
```yaml
projectName: simple-blog
description: 간단한 블로그 시스템
owner: user:john
databaseUrl: postgresql://username:password@localhost:5432/simple_blog_db
enableDarkMode: false
enableEditor: false
uiLibrary: radix-ui
enableDocker: false
enableCI: false
```

**최소 구성:**
- 기본 CRUD 기능만 포함
- 간단한 텍스트 영역 (Lexical 제외)
- 라이트 모드만 지원
- Docker 설정 없음

---

## 다음 단계

### 1. Template 확장
- **인증 전략 선택**: JWT vs OAuth vs Passport
- **데이터베이스 선택**: PostgreSQL vs MySQL vs MongoDB
- **UI 라이브러리 선택**: Radix UI vs Material UI vs Ant Design
- **배포 타겟**: Vercel, Netlify, AWS, GCP

### 2. Shared 라이브러리 통합
현재 tech-blog가 사용 중인 내부 라이브러리를 Template에 포함:
```
libs/be/
├── common/
├── auth/
├── prisma/
└── swagger/
```

### 3. Custom Actions 개발
- `nx:add-project`: Nx workspace에 프로젝트 자동 등록
- `prisma:init`: Prisma 마이그레이션 및 시딩 자동화
- `env:setup`: 환경변수 파일 자동 생성

### 4. CI/CD Pipeline Template
```yaml
# .github/workflows/ci.yml.hbs
name: CI

on:
  push:
    branches: [develop, main]
  pull_request:
    branches: [develop, main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: pnpm/action-setup@v2
      - name: Install dependencies
        run: pnpm install
      - name: Run tests
        run: pnpm nx test ${{ values.projectName }}-api-server
      - name: Build
        run: pnpm nx build ${{ values.projectName }}-api-server
```

### 5. TechDocs 자동 생성
```yaml
# mkdocs.yml.hbs
site_name: ${{ values.projectName }} Documentation
docs_dir: docs
site_dir: site
nav:
  - Home: index.md
  - API Reference: api.md
```

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

---

## 버전 히스토리

- **v1.1** (2025-10-23): 실시간 기능 제외 및 데이터베이스 연동 방식 변경
  - WebSocket, Kafka 관련 기능 제거
  - Docker 컨테이너 대신 기존 PostgreSQL 서버 연동
  - Template 파라미터 및 예시 업데이트

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

