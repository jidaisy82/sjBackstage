# Backstage Software Template 가이드 v2.0

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
RND-NX 모노레포 내 tech-blog 프로젝트를 기반으로 한 **간단한 풀스택 템플릿**을 설계하여, PostgreSQL 데이터베이스를 조회하는 기본적인 웹 애플리케이션을 빠르게 생성할 수 있도록 합니다. 개발자가 이 기반 위에서 추가 개발을 진행할 수 있는 환경을 제공합니다.

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

#### 주요 기능 모듈 (간소화)
```typescript
src/
├── modules/
│   ├── posts/          # 게시물 CRUD (기본 기능)
│   ├── categories/     # 카테고리 관리
│   └── users/          # 사용자 관리 (기본)
└── app.module.ts       # 메인 모듈
```

#### 인증/인가
- **JWT (JSON Web Token)**: 인증 토큰
- **Passport**: 인증 미들웨어
- **bcrypt**: 비밀번호 해싱

#### API 문서화
- **Nestia Swagger**: 자동 API 문서 생성
- Swagger UI Path: `/api/swagger`

#### 데이터베이스 스키마 (Prisma) - 간소화

기본 모델:
```prisma
- User: 사용자 관리 (기본)
- Post: 게시물 (status: DRAFT/PUBLISHED)
- Category: 카테고리
```

#### Nx 빌드 타겟
```json
{
  "build": "nest build",
  "start:local": "NODE_ENV=local nest start --watch",
  "start:dev": "NODE_ENV=dev nest start --watch",
  "start:prod": "NODE_ENV=prod node dist/main",
  "test": "jest",
  "db:generate": "npx prisma generate",
  "db:migrate": "npx prisma migrate dev",
  "nestia:sdk": "npx nestia sdk",
  "nestia:swagger": "npx nestia swagger"
}
```

#### 의존성 라이브러리
```typescript
// 내부 라이브러리 (libs/)
libs-be-common
libs-be-auth
libs-be-prisma
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
  - button, card, input, select
- **shadcn/ui**: TailwindCSS + Radix UI 기반 컴포넌트
- **Lucide React**: 아이콘 라이브러리

#### 상태 관리
- **Zustand** (5.0.7): 경량 상태 관리
- **React Hook Form** (7.62.0): 폼 상태 관리
- **Zod** (4.0.17): 스키마 검증

#### API 통신
- **@nestia/fetcher** (8.0.7): Type-safe API 클라이언트
- **Axios** (1.11.0): HTTP 클라이언트
- **Typia** (9.7.2): 런타임 타입 검증

#### Nx 빌드 타겟
```json
{
  "build": "tsc && vite build",
  "serve": "vite --force",
  "dev": "vite",
  "preview": "vite preview",
  "lint": "eslint . --ext ts,tsx",
  "type-check": "tsc --noEmit"
}
```

#### 주요 디렉토리 구조
```
src/
├── api/                    # Nestia 자동 생성 SDK
│   ├── functional/         # API 엔드포인트별 함수
│   └── structures/         # DTO 타입 정의
├── components/
│   ├── ui/                # shadcn/ui 컴포넌트
│   ├── PostCard.tsx       # 게시물 카드 컴포넌트
│   └── Layout.tsx         # 레이아웃 컴포넌트
├── pages/
│   ├── Home.tsx           # 홈 페이지 (게시물 목록)
│   ├── PostDetail.tsx     # 게시물 상세
│   └── CreatePost.tsx    # 게시물 작성
├── hooks/                 # 커스텀 훅
├── lib/
│   ├── api/               # API 어댑터
│   └── utils.ts           # 유틸리티 함수
└── stores/                # Zustand 상태 관리
```

### 4. 공통 인프라

#### Database
- **PostgreSQL**: 기존 데이터베이스 서버 연동
- **Prisma ORM**: 데이터베이스 스키마 관리 및 마이그레이션

#### 환경 설정
- **다중 환경 지원**: local, dev, staging, prod
- **NODE_ENV**: 환경별 설정 분기

#### Nx 태그 시스템
```typescript
// API Server
tags: ["layer:app", "group:{{projectName}}", "platform:nest", "type:api-server", "type:be"]

// User Client
tags: ["layer:app", "type:fe", "platform:react", "group:{{projectName}}"]
```

---

## Software Template 설계

### 1. Template 목표

tech-blog를 기반으로 다음과 같은 **간단한 풀스택 애플리케이션**을 자동 생성:
- **기본 블로그/CMS 시스템**
- **NestJS + React 조합**
- **Nx 모노레포 통합**
- **Type-safe API 통신 (Nestia)**
- **PostgreSQL + Prisma ORM**
- **PostgreSQL 데이터 조회 화면**

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
        description: 프로젝트 식별자 (예: my-blog, simple-cms)
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
        default: postgresql://username:password@localhost:5432/simple_blog_db
        ui:field: Secret

  - title: 프론트엔드 설정
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
        enumNames:
          - Radix UI (shadcn/ui)
          - Material UI
        default: radix-ui

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
catalog/templates/simple-fullstack/
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
│   │       │   │       │   ├── posts.controller.ts.hbs
│   │       │   │       │   ├── posts.service.ts.hbs
│   │       │   │       │   ├── posts.module.ts.hbs
│   │       │   │       │   └── dto/
│   │       │   │       ├── categories/
│   │       │   │       │   ├── categories.controller.ts.hbs
│   │       │   │       │   ├── categories.service.ts.hbs
│   │       │   │       │   └── categories.module.ts.hbs
│   │       │   │       └── users/
│   │       │   │           ├── users.controller.ts.hbs
│   │       │   │           ├── users.service.ts.hbs
│   │       │   │           └── users.module.ts.hbs
│   │       │   ├── prisma/
│   │       │   │   ├── schema.prisma.hbs
│   │       │   │   └── seed.ts.hbs
│   │       │   ├── package.json.hbs
│   │       │   ├── nestia.config.ts.hbs
│   │       │   ├── tsconfig.json
│   │       │   └── catalog-info.yaml.hbs
│   │       │
│   │       ├── user-client/
│   │       │   ├── src/
│   │       │   │   ├── components/
│   │       │   │   │   ├── ui/            # shadcn/ui 컴포넌트
│   │       │   │   │   ├── PostCard.tsx.hbs
│   │       │   │   │   ├── Layout.tsx.hbs
│   │       │   │   │   └── ThemeProvider.tsx.hbs  # (conditional: enableDarkMode)
│   │       │   │   ├── pages/
│   │       │   │   │   ├── Home.tsx.hbs
│   │       │   │   │   ├── PostDetail.tsx.hbs
│   │       │   │   │   └── CreatePost.tsx.hbs
│   │       │   │   ├── hooks/
│   │       │   │   │   └── usePosts.ts.hbs
│   │       │   │   ├── lib/
│   │       │   │   │   ├── api/
│   │       │   │   │   └── utils.ts.hbs
│   │       │   │   ├── stores/
│   │       │   │   │   └── postStore.ts.hbs
│   │       │   │   ├── App.tsx.hbs
│   │       │   │   └── main.tsx.hbs
│   │       │   ├── package.json.hbs
│   │       │   ├── vite.config.ts.hbs
│   │       │   ├── tailwind.config.js.hbs
│   │       │   └── catalog-info.yaml.hbs
│   │       │
│   │       └── api-server-test/
│   │           ├── src/
│   │           │   ├── api/
│   │           │   │   └── posts.test.ts.hbs
│   │           └── setup/
│   │               └── test-setup.ts.hbs
│   │           ├── package.json.hbs
│   │           └── catalog-info.yaml.hbs
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
        uiLibrary: ${{ parameters.uiLibrary }}

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

  # 3. Catalog에 Component 등록
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

  # 4. 환경 변수 파일 생성
  - id: setup-env
    name: Setup Environment Variables
    action: fs:write
    input:
      path: apps/${{ parameters.projectName }}/api-server/.env
      content: |
        DATABASE_URL="${{ parameters.databaseUrl }}"
        JWT_SECRET="your-jwt-secret-key-change-this"
        NODE_ENV="local"
        PORT=3000

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
    - title: Frontend Application
      url: http://localhost:5173
      icon: web
```

### 5. 생성되는 주요 코드 예시

#### API Server - Posts Controller
```typescript
// skeleton/apps/${{values.projectName}}/api-server/src/modules/posts/posts.controller.ts.hbs
import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';

@Controller('posts')
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @Post()
  create(@Body() createPostDto: CreatePostDto) {
    return this.postsService.create(createPostDto);
  }

  @Get()
  findAll() {
    return this.postsService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.postsService.findOne(+id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @Body() updatePostDto: UpdatePostDto) {
    return this.postsService.update(+id, updatePostDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.postsService.remove(+id);
  }
}
```

#### User Client - Home Page
```typescript
// skeleton/apps/${{values.projectName}}/user-client/src/pages/Home.tsx.hbs
import React, { useEffect } from 'react';
import { PostCard } from '../components/PostCard';
import { usePosts } from '../hooks/usePosts';

export function Home() {
  const { posts, loading, fetchPosts } = usePosts();

  useEffect(() => {
    fetchPosts();
  }, [fetchPosts]);

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="text-center">Loading posts...</div>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <h1 className="text-3xl font-bold mb-6">Welcome to {{ values.projectName }}</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {posts.map((post) => (
          <PostCard key={post.id} post={post} />
        ))}
      </div>
    </div>
  );
}
```

#### Prisma Schema
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
  id        Int      @id @default(autoincrement())
  email     String   @unique
  password  String
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model Post {
  id          Int        @id @default(autoincrement())
  title       String
  content     String?
  authorId    Int
  author      User       @relation(fields: [authorId], references: [id])
  categoryId  Int?
  category    Category?  @relation(fields: [categoryId], references: [id])
  status      Status     @default(DRAFT)
  viewCount   Int        @default(0)
  createdAt   DateTime   @default(now())
  updatedAt   DateTime   @updatedAt
}

model Category {
  id        Int      @id @default(autoincrement())
  name      String   @unique
  posts     Post[]
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

enum Status {
  DRAFT
  PUBLISHED
}
```

---

## Template 구현 가이드

### Step 1: Template 디렉토리 생성

```bash
# Backstage 프로젝트 루트에서
mkdir -p catalog/templates/simple-fullstack
cd catalog/templates/simple-fullstack
```

### Step 2: template.yaml 작성

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: simple-fullstack
  title: Simple Full-Stack Application
  description: |
    NestJS + React 기반 간단한 풀스택 애플리케이션을 생성합니다.
    - Type-safe API (Nestia)
    - PostgreSQL + Prisma ORM
    - 기본 CRUD 기능
    - TailwindCSS + shadcn/ui
    - Nx 모노레포 통합
    - PostgreSQL 데이터 조회 화면
  tags:
    - nestjs
    - react
    - fullstack
    - simple
    - nx
    - typescript
    - postgresql
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
    "db:seed": "ts-node prisma/seed.ts",
    "nestia:sdk": "npx nestia sdk",
    "nestia:swagger": "npx nestia swagger"
  },
  "dependencies": {
    "@nestjs/common": "catalog:backend",
    "@nestjs/core": "catalog:backend",
    "@nestjs/config": "catalog:backend",
    "@nestjs/jwt": "catalog:backend",
    "@nestjs/passport": "catalog:backend",
    "@nestjs/platform-express": "catalog:backend",
    "@prisma/client": "catalog:backend",
    "@nestia/core": "catalog:backend",
    "bcrypt": "catalog:backend",
    "class-validator": "catalog:backend",
    "class-transformer": "catalog:backend",
    "winston": "catalog:backend",
    "helmet": "catalog:backend",
    "typia": "catalog:backend"
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

#### 3.2 User Client Package.json Template
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

#### 3.3 Catalog Info Templates

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
    - Basic CRUD Operations
  tags:
    - nestjs
    - prisma
    - postgresql
    - api
    - typescript
    - simple
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
    - PostgreSQL Data Display
    {{#if values.enableDarkMode}}
    - Dark Mode Support
    {{/if}}
  tags:
    - react
    - vite
    - frontend
    - tailwindcss
    - typescript
    - simple
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
# app-config.yaml
catalog:
  locations:
    - type: file
      target: ../../catalog/templates/simple-fullstack/template.yaml
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
   - "Simple Full-Stack Application" 템플릿 확인

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
uiLibrary: radix-ui
```

**생성되는 구조:**
```
apps/company-blog/
├── api-server/
│   ├── src/
│   │   └── modules/
│   │       ├── posts/          # 게시물 CRUD
│   │       ├── categories/    # 카테고리 관리
│   │       └── users/          # 사용자 관리
│   ├── prisma/
│   │   └── schema.prisma       # User, Post, Category 모델
│   └── catalog-info.yaml
├── user-client/
│   ├── src/
│   │   ├── components/
│   │   │   ├── PostCard.tsx    # 게시물 카드
│   │   │   └── Layout.tsx      # 레이아웃
│   │   ├── pages/
│   │   │   ├── Home.tsx        # 게시물 목록
│   │   │   ├── PostDetail.tsx  # 게시물 상세
│   │   │   └── CreatePost.tsx  # 게시물 작성
│   │   └── hooks/
│   │       └── usePosts.ts     # 게시물 데이터 훅
│   └── catalog-info.yaml
└── api-server-test/
    └── src/
        └── api/
            └── posts.test.ts   # 게시물 API 테스트
```

### 예시 2: 간단한 CMS 시스템

**입력 파라미터:**
```yaml
projectName: simple-cms
description: 간단한 CMS 플랫폼
owner: group:product-team
databaseUrl: postgresql://username:password@localhost:5432/simple_cms_db
enableDarkMode: true
uiLibrary: radix-ui
```

**생성되는 기능:**
- ✅ 게시물 목록 조회 (PostgreSQL에서 데이터 가져오기)
- ✅ 게시물 상세 보기
- ✅ 게시물 작성/수정/삭제
- ✅ 카테고리 관리
- ✅ 사용자 인증 (기본)
- ✅ 다크모드 지원

### 예시 3: 최소 설정 애플리케이션

**입력 파라미터:**
```yaml
projectName: basic-app
description: 기본 웹 애플리케이션
owner: user:john
databaseUrl: postgresql://username:password@localhost:5432/basic_app_db
enableDarkMode: false
uiLibrary: radix-ui
```

**최소 구성:**
- ✅ 기본 CRUD 기능만 포함
- ✅ 라이트 모드만 지원
- ✅ PostgreSQL 데이터 조회 화면
- ✅ 개발자가 추가 개발할 수 있는 기반 구조

---

## 개발자 가이드

### 생성 후 개발 단계

1. **의존성 설치**
```bash
cd apps/{{projectName}}/api-server
pnpm install

cd ../user-client
pnpm install
```

2. **데이터베이스 설정**
```bash
cd apps/{{projectName}}/api-server
npx prisma generate
npx prisma migrate dev --name init
npx prisma db seed
```

3. **개발 서버 실행**
```bash
# API 서버
cd apps/{{projectName}}/api-server
pnpm start:local

# 프론트엔드
cd apps/{{projectName}}/user-client
pnpm dev
```

4. **확인**
- API 서버: http://localhost:3000/api/swagger
- 프론트엔드: http://localhost:5173

### 추가 개발 가능한 영역

1. **백엔드 확장**
   - 새로운 모듈 추가 (comments, likes 등)
   - 인증/인가 로직 강화
   - 파일 업로드 기능
   - 검색 기능

2. **프론트엔드 확장**
   - 새로운 페이지 추가
   - 컴포넌트 라이브러리 확장
   - 상태 관리 개선
   - UI/UX 개선

3. **데이터베이스 확장**
   - 새로운 테이블 추가
   - 관계 설정 개선
   - 인덱스 최적화

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

### 4. TechDocs 자동 생성
```yaml
# mkdocs.yml.hbs
site_name: ${{ values.projectName }} Documentation
docs_dir: docs
site_dir: site
nav:
  - Home: index.md
  - API Reference: api.md
  - Database Schema: database.md
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

- **v2.0** (2025-10-23): 간단한 풀스택 템플릿으로 변경
  - CI/CD 기능 제거
  - 기본 CRUD 기능에 집중
  - PostgreSQL 데이터 조회 화면 중심
  - 개발자 추가 개발 기반 제공
  - 복잡한 기능 제거 (WebSocket, Kafka, 고급 에디터 등)

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
