# Tech Blog Backstage Template - 최종 가이드

## 목차
1. [개요](#개요)
2. [Template 구조](#template-구조)
3. [핵심 컴포넌트](#핵심-컴포넌트)
4. [Handlebars 파라미터 전달 시스템](#handlebars-파라미터-전달-시스템) ⭐️
5. [사용 방법](#사용-방법)
6. [기술 스택](#기술-스택)
7. [PostgreSQL 연동](#postgresql-연동)
8. [Backstage 연동](#backstage-연동)
9. [문제 해결](#문제-해결)

---

## 개요

### Tech Blog Template이란?

Tech Blog Frontend React + Vite Template은 RND-NX 프로젝트의 `apps/tech-blog/user-client`를 기반으로 한 Backstage Software Template입니다. 이 Template은 다음 기능을 제공합니다:

- ✅ **React 19** 기반 프론트엔드 애플리케이션
- ✅ **Vite 7** 빌드 도구로 빠른 개발 경험
- ✅ **TailwindCSS** 스타일링 + 다크모드 지원
- ✅ **Zustand** 상태 관리
- ✅ **PostgreSQL** 데이터 조회 기능
- ✅ **Type-safe** API 통신
- ✅ **Backstage 카탈로그** 자동 등록

### Template 위치

```
rnd-backstage/catalog/templates/frontend-react-vite-test/
├── template.yaml              # Template 메타데이터 및 파라미터
└── skeleton/                   # 생성될 프로젝트 구조
    ├── catalog-info.yaml.hbs  # Backstage 카탈로그 등록 파일
    ├── index.html.hbs         # HTML 엔트리
    ├── package.json.hbs       # 프로젝트 의존성
    ├── vite.config.ts.hbs     # Vite 설정 (API Proxy 포함)
    └── src/
        ├── main.tsx.hbs       # React 엔트리
        ├── App.tsx.hbs        # React Router
        ├── components/        # UI 컴포넌트
        ├── pages/             # 페이지 컴포넌트
        ├── hooks/             # 커스텀 훅
        ├── lib/               # 유틸리티
        └── stores/            # Zustand 상태 관리
```

### 원본 프로젝트와의 관계

이 Template은 다음 프로젝트를 기반으로 설계되었습니다:

```
RND-NX/apps/tech-blog/user-client/
├── src/
│   ├── components/            # 실제 컴포넌트
│   ├── pages/                 # 페이지
│   ├── hooks/                  # 커스텀 훅
│   ├── lib/api/               # API 클라이언트
│   └── stores/                # Zustand 스토어
├── package.json
└── vite.config.ts
```

---

## 원본 소스를 Template으로 변환하기

### 어떤 파일을 Template화해야 하는가?

Tech Blog의 원본 소스를 Template으로 만들기 위해서는 다음 파일들을 수정해야 합니다:

#### 1. 하드코딩된 값을 변수로 치환

**수정 전 (원본):**
```typescript
// src/components/Layout.tsx
<h1 className="text-2xl font-bold">Tech Blog</h1>
```

**수정 후 (Template):**
```handlebars
// skeleton/src/components/Layout.tsx.hbs
<h1 className="text-2xl font-bold">${{ values.projectName }}</h1>
```

**처리:**
- ❌ "Tech Blog" 같은 하드코딩된 값
- ✅ `${{ values.projectName }}` 변수로 치환

#### 2. 프로젝트명이 포함된 곳 수정

**확인이 필요한 파일들:**

| 파일 경로 | 수정 내용 | 예시 |
|-----------|-----------|------|
| `package.json` | `name`, `description` | `${{ values.projectSlug }}-user-client` |
| `index.html` | `<title>` | `${{ values.projectName }}` |
| `catalog-info.yaml` | `name`, `description` | `${{ values.projectSlug }}-user-client` |
| 컴포넌트 내부 | 프로젝트명 표시 | `${{ values.projectName }}` |
| `README.md` | 프로젝트 설명 | `${{ values.description }}` |

#### 3. 조건부 기능 추가

**package.json.hbs - 다크모드 조건부 추가:**
```json
"lucide-react": "^0.539.0"{% if values.enableDarkMode -%},
"next-themes": "^0.4.6"{%- endif %}
```

**설명:**
- `enableDarkMode`가 `true`일 때만 `next-themes` 패키지 포함
- 선택적 의존성 추가

#### 4. 절대 경로를 상대 경로로 변경

**index.html.hbs:**
```html
<!doctype html>
<html lang="en">
  <head>
    <title>${{ values.projectName }}</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.tsx"></script>
  </body>
</html>
```

**변경 사항:**
- `<title>` 태그에 프로젝트명 변수 추가
- 다른 부분은 그대로 유지

#### 5. Catalog 정보 자동화

**catalog-info.yaml.hbs 생성:**

**원본 (기존에 존재):**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: tech-blog-user-client
  description: |
    Tech Blog React 사용자 클라이언트
spec:
  owner: "group:frontend-team"
```

**Template화:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.projectSlug }}-user-client
  description: ${{ values.description }} - Frontend Client
  tags:
    - react
    - vite
    - frontend
    - tailwindcss
    - typescript
  annotations:
    github.com/project-slug: ${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}
spec:
  owner: "${{ values.owner }}"
  system: ${{ values.projectSlug }}-system
  consumesApis:
    - ${{ values.projectSlug }}-rest-api
```

**주요 변환:**
- `name` → `${{ values.projectSlug }}-user-client`
- `description` → `${{ values.description }} - Frontend Client`
- `owner` → `${{ values.owner }}`
- GitHub URL 자동 파싱

### 수정 전략 체크리스트

#### 필수 수정 항목

- [ ] **package.json → package.json.hbs**
  - `name` 필드에 `projectSlug` 변수 추가
  - `description` 필드에 `description` 변수 추가
  
- [ ] **index.html → index.html.hbs**
  - `<title>` 태그에 `projectName` 변수 추가
  
- [ ] **모든 컴포넌트 파일 → *.hbs**
  - 하드코딩된 프로젝트명을 변수로 치환
  - 불필요한 비즈니스 로직은 제거하고 간단한 예시로 대체
  
- [ ] **catalog-info.yaml.hbs 생성**
  - 전체를 Handlebars 변수로 작성
  - GitHub URL 파싱 함수 사용

#### 선택적 수정 항목

- [ ] **조건부 패키지 추가**
  - `enableDarkMode`, `uiLibrary` 등에 따른 조건부 의존성
  
- [ ] **API 클라이언트 선택**
  - `apiClient` 파라미터에 따른 다른 구현
  
- [ ] **상태 관리 라이브러리**
  - `stateManagement` 파라미터에 따른 다른 설정

### 변환 과정 예시

#### Step 1: 원본 파일 선택
```bash
# 원본 파일
cd /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/user-client
ls src/components/Layout.tsx
```

#### Step 2: .hbs 확장자로 복사
```bash
# Template 디렉토리에 복사
cp src/components/Layout.tsx \
   /Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/src/components/Layout.tsx.hbs
```

#### Step 3: 변수 치환 적용
```typescript
// 원본
export function Layout({ children }: LayoutProps) {
  return (
    <div>
      <h1>Tech Blog</h1>
      {children}
    </div>
  );
}

// Template (.hbs)
export function Layout({ children }: LayoutProps) {
  return (
    <div>
      <h1>${{ values.projectName }}</h1>
      {children}
    </div>
  );
}
```

#### Step 4: 불필요한 코드 정리
```typescript
// 원본에 있는 복잡한 로직은 간소화
// 실제 비즈니스 로직은 제거하고
// Template으로 생성된 후 개발자가 추가
```

### 주의사항

1. **보안 관련 정보 제거**
   - API 키, 토큰 등은 제거
   - 환경 변수로 처리

2. **프로젝트 특화 로직 제거**
   - 원본의 복잡한 비즈니스 로직은 제거
   - 기본 구조만 유지

3. **확장 가능성 고려**
   - 사용자가 쉽게 커스터마이징할 수 있도록
   - 주석으로 설명 추가

4. **테스트 파일은 제외**
   - 원본의 테스트 파일은 Template에 포함 안 함
   - 기본 구조만 제공

### 검증 방법

1. **Template 생성 테스트**
```bash
# Backstage에서 Template 실행
# 생성된 파일 확인
```

2. **변수 치환 확인**
```bash
# 생성된 파일에서
grep "${{" generated-file.js
# 결과가 없어야 함 (치환 완료)
```

3. **의존성 확인**
```bash
cd generated-project
pnpm install
pnpm dev
```

---

## Template 구조

### 1. Template 설정 (`template.yaml`)

```yaml:1:24:rnd-backstage/catalog/templates/frontend-react-vite-test/template.yaml
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
  tags:
    - react
    - vite
    - frontend
    - tailwindcss
    - test
    - typescript
```

**주요 파라미터:**

- `projectName`: 프로젝트 이름
- `description`: 프로젝트 설명
- `owner`: 소유자 (OwnerPicker)
- `enableDarkMode`: 다크모드 지원 여부
- `uiLibrary`: UI 컴포넌트 라이브러리 (radix-ui/mui/ant-design)
- `stateManagement`: 상태 관리 라이브러리 (zustand/redux/context)
- `apiClient`: API 클라이언트 (nestia/axios/fetch)
- `repoUrl`: GitHub 저장소 URL

### 2. 생성되는 프로젝트 구조

```
프로젝트명-user-client/
├── .gitignore
├── index.html                  # HTML 엔트리
├── package.json                # 의존성 및 스크립트
├── vite.config.ts              # Vite 설정 + API Proxy
├── tsconfig.json               # TypeScript 설정
├── catalog-info.yaml          # Backstage 카탈로그 등록
├── README.md
└── src/
    ├── main.tsx               # React 엔트리 포인트
    ├── index.css              # TailwindCSS 설정
    ├── App.tsx                # React Router 설정
    ├── components/
    │   ├── Layout.tsx         # 네비게이션 레이아웃
    │   ├── PostCard.tsx       # 게시물 카드
    │   └── ui/                # shadcn/ui 컴포넌트
    ├── pages/
    │   └── Home.tsx           # PostgreSQL 데이터 조회 페이지
    ├── hooks/
    │   └── usePosts.ts        # 데이터 fetching 훅
    ├── lib/
    │   └── api/               # API 클라이언트
    └── stores/                # Zustand 상태 관리
```

---

## 핵심 컴포넌트

### Handlebars 템플릿 시스템 이해

Template의 모든 `.hbs` 파일은 Handlebars 문법을 사용하여 사용자가 입력한 파라미터를 동적으로 치환합니다.

**치환 과정:**
1. 사용자가 Backstage UI에서 Template 선택 및 파라미터 입력
2. Template YAML의 `steps` 섹션이 실행
3. `fetch:template` 액션이 skeleton 폴더의 `.hbs` 파일을 처리
4. `${{ values.* }}` 변수가 실제 값으로 치환
5. 최종 파일이 생성되어 GitHub에 푸시

**주요 Handlebars 문법:**
- `${{ values.projectName }}` - 단순 변수 치환
- `${{ values.projectSlug | parseRepoUrl | pick('owner') }}` - 함수 체인
- `{% if values.enableDarkMode -%}` - 조건부 처리
- `# {{...}}` - 주석

### 1. Application 진입점 (`src/main.tsx`)

```typescript:1:10:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/src/main.tsx.hbs
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App.tsx';
import './index.css';

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
);
```

**역할:**
- React 애플리케이션을 DOM에 마운트
- StrictMode로 개발 환경 경고 제공

**Handlebars 처리:**
- 이 파일은 변수 치환이 없어 그대로 생성됨

### 2. 메인 App 컴포넌트 (`src/App.tsx`)

```typescript:1:19:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/src/App.tsx.hbs
import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { Home } from './pages/Home';
import { Layout } from './components/Layout';

function App() {
  return (
    <Router>
      <Layout>
        <Routes>
          <Route path="/" element={<Home />} />
        </Routes>
      </Layout>
    </Router>
  );
}

export default App;
```

**역할:**
- React Router v7로 라우팅 설정
- Layout 컴포넌트로 공통 레이아웃 적용
- Home 페이지 연결

### 3. 레이아웃 컴포넌트 (`src/components/Layout.tsx`)

```typescript:1:23:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/src/components/Layout.tsx.hbs
import React from 'react';

interface LayoutProps {
  children: React.ReactNode;
}

export function Layout({ children }: LayoutProps) {
  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <nav className="bg-white dark:bg-gray-800 shadow">
        <div className="container mx-auto px-4 py-4">
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
            ${{ values.projectName }}
          </h1>
        </div>
      </nav>
      <main className="container mx-auto px-4 py-8">
        {children}
      </main>
    </div>
  );
}
```

**특징:**
- TailwindCSS로 스타일링
- 다크모드 지원 (`dark:bg-gray-900`)
- 반응형 레이아웃 (`container mx-auto`)
- 프로젝트 이름 표시 (Handlebars 변수 사용)

**Handlebars 처리 예시:**
```yaml
# 사용자 입력: projectName = "Company Blog"

# 원본 (.hbs 파일):
<h1>${{ values.projectName }}</h1>

# 생성된 파일:
<h1>Company Blog</h1>
```

이렇게 사용자가 입력한 프로젝트 이름이 자동으로 치환됩니다.

### 4. 데이터 Fetching 훅 (`src/hooks/usePosts.ts`)

```typescript:1:35:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/src/hooks/usePosts.ts.hbs
import { useState, useEffect } from 'react';

interface Category {
  id: number;
  name: string;
  createdAt: string;
  updatedAt: string;
}

export function usePosts() {
  const [posts, setPosts] = useState<Category[]>([]);
  const [loading, setLoading] = useState(true);

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

  return {
    posts,
    loading,
    fetchPosts,
  };
}
```

**기능:**
- PostgreSQL 데이터를 백엔드 API로부터 fetch
- 로딩 상태 관리
- 에러 처리

### 5. Home 페이지 (`src/pages/Home.tsx`)

```typescript:1:30:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/src/pages/Home.tsx.hbs
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
      <h1 className="text-3xl font-bold mb-6">Welcome to ${{ values.projectName }}</h1>
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {posts.map((post) => (
          <PostCard key={post.id} post={post} />
        ))}
      </div>
    </div>
  );
}
```

**기능:**
- 컴포넌트 마운트 시 데이터 자동 조회
- 로딩 상태 표시
- 그리드 레이아웃으로 카드 리스트 표시

### 6. PostCard 컴포넌트 (`src/components/PostCard.tsx`)

```typescript:1:33:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/src/components/PostCard.tsx.hbs
import React from 'react';

interface Category {
  id: number;
  name: string;
  createdAt: string;
  updatedAt: string;
}

interface PostCardProps {
  post: Category;
}


export function PostCard({ post }: PostCardProps) {
  return (
    <div className="bg-white dark:bg-gray-800 rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow">
      <h2 className="text-xl font-semibold mb-2 text-gray-900 dark:text-white">
        {post.name}
      </h2>
      <div className="flex justify-between items-center text-sm text-gray-500 dark:text-gray-400">
        <span>Category ID: {post.id}</span>
        <span>Created: {new Date(post.createdAt).toLocaleDateString()}</span>
      </div>
      <div className="mt-2">
        <span className="inline-block bg-blue-100 dark:bg-blue-900 text-blue-800 dark:text-blue-200 text-xs px-2 py-1 rounded">
          Updated: {new Date(post.updatedAt).toLocaleDateString()}
        </span>
      </div>
    </div>
  );
}
```

**특징:**
- 카드 UI 디자인
- 다크모드 지원
- 호버 효과 (`hover:shadow-lg`)
- 날짜 포맷팅

### 7. Vite 설정 (`vite.config.ts`)

```typescript:1:17:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/vite.config.ts.hbs
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, '')
      }
    }
  }
})
```

**주요 설정:**
- React 플러그인 사용
- 개발 서버 포트: 5173
- API Proxy: `/api` → `http://localhost:3000`

### 8. Package.json 의존성

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

**주요 라이브러리:**
- **React 19**: 최신 UI 라이브러리
- **React Router v7**: 클라이언트 사이드 라우팅
- **Zustand**: 경량 상태 관리
- **TailwindCSS**: 유틸리티 기반 CSS
- **Radix UI**: 접근성 높은 UI 컴포넌트
- **Axios**: HTTP 클라이언트

**Handlebars 조건부 처리:**
```json:26:27:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/package.json.hbs
    "lucide-react": "^0.539.0"{% if values.enableDarkMode -%},
    "next-themes": "^0.4.6"{%- endif %}
```

`enableDarkMode`가 `true`일 때만 `next-themes` 패키지가 추가됩니다.

---

## Handlebars 파라미터 전달 시스템

### 파라미터 전달 흐름도

```
┌─────────────────────────────────────────────────────────────┐
│  1. Backstage UI - 사용자 입력                              │
├─────────────────────────────────────────────────────────────┤
│  projectName: "Company Blog"                               │
│  description: "Enterprise blog platform"                  │
│  owner: "group:frontend-team"                              │
│  repoUrl: "https://github.com/acme/blog-frontend"          │
│  enableDarkMode: true                                       │
│  ...                                                        │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Template YAML - steps 섹션                              │
├─────────────────────────────────────────────────────────────┤
│  steps:                                                     │
│    - id: fetch-base                                         │
│      action: fetch:template                                 │
│      input:                                                 │
│        values:                                              │
│          projectName: ${{ parameters.projectName }}        │
│          projectSlug: ${{ parameters.projectName | ... }}  │
│          enableDarkMode: ${{ parameters.enableDarkMode }}  │
│          ...                                                │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  │ Handlebars 변수 전달
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  3. Skeleton 파일 처리 (.hbs → 실제 파일)                    │
├─────────────────────────────────────────────────────────────┤
│  index.html.hbs                                             │
│    <title>${{ values.projectName }}</title>                 │
│    ↓                                                        │
│  index.html                                                 │
│    <title>Company Blog</title>                             │
│                                                             │
│  package.json.hbs                                           │
│    "name": "${{ values.projectSlug }}-user-client"         │
│    ↓                                                        │
│  package.json                                               │
│    "name": "company-blog-user-client"                      │
│                                                             │
│  {% if values.enableDarkMode -%}                           │
│    "next-themes": "^0.4.6"                                │
│  {%- endif %}                                               │
│    ↓                                                        │
│  (enableDarkMode=true일 때만 포함)                         │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│  4. GitHub 저장소 생성 및 푸시                               │
└─────────────────────────────────────────────────────────────┘
```

### 1. Template YAML에서 파라미터 정의

```yaml:28:96:rnd-backstage/catalog/templates/frontend-react-vite-test/template.yaml
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
```

### 2. Steps 섹션에서 파라미터를 values로 전달

```yaml:110:126:rnd-backstage/catalog/templates/frontend-react-vite-test/template.yaml
  steps:
    - id: fetch-base
      name: Fetch Frontend Template
      action: fetch:template
      input:
        url: ./skeleton
        templateFileExtension: hbs
        values:
          projectName: ${{ parameters.projectName }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}
          repoUrl: ${{ parameters.repoUrl }}
          projectSlug: ${{ parameters.projectName | lower | replace(' ', '-', true) | replace('_', '-', true) }}
          enableDarkMode: ${{ parameters.enableDarkMode }}
          uiLibrary: ${{ parameters.uiLibrary }}
          stateManagement: ${{ parameters.stateManagement }}
          apiClient: ${{ parameters.apiClient }}
```

**핵심 동작:**
- `parameters.*`는 사용자가 입력한 값
- `values.*`는 skeleton 파일에서 사용할 변수
- Handlebars 필터 적용: `lower`, `replace`, `parseRepoUrl`, `pick`

### 3. Skeleton 파일에서 values 사용

**예시 1: index.html.hbs**
```html:7:7:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/index.html.hbs
    <title>${{ values.projectName }}</title>
```

**처리 결과:**
```
입력: projectName = "My Awesome Blog"
생성: <title>My Awesome Blog</title>
```

**예시 2: catalog-info.yaml.hbs**
```yaml:5:6:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/catalog-info.yaml.hbs
  name: ${{ values.projectSlug }}-user-client
  description: ${{ values.description }} - Frontend Client
```

**처리 과정:**
```yaml
입력: projectName = "My Awesome Blog"
projectSlug 변환: "My Awesome Blog" 
  → lower: "my awesome blog"
  → replace(' ', '-'): "my-awesome-blog"
  → replace('_', '-'): "my-awesome-blog"

최종 결과:
  name: my-awesome-blog-user-client
  description: Awesome blog frontend - Frontend Client
```

### 4. Handlebars 필터 및 함수

#### A. 기본 필터

```handlebars
# lower - 소문자 변환
${{ values.projectName | lower }}
# "My Project" → "my project"

# replace - 문자열 치환
${{ values.projectName | replace(' ', '-', true) }}
# "My Project" → "My-Project"

# upper - 대문자 변환
${{ values.projectName | upper }}
# "My Project" → "MY PROJECT"
```

#### B. 파이프 체인 (Pipe Chain)

```handlebars
# 여러 필터를 체인으로 연결
${{ values.projectName | lower | replace(' ', '-', true) }}
# "My Awesome Blog" → "my-awesome-blog"
```

#### C. 백스테이지 내장 함수

```handlebars
# parseRepoUrl - GitHub URL 파싱
${{ values.repoUrl | parseRepoUrl }}

# pick - 객체에서 특정 키 추출
${{ values.repoUrl | parseRepoUrl | pick('owner') }}
${{ values.repoUrl | parseRepoUrl | pick('repo') }}

# 예시
# 입력: https://github.com/acme/cool-project
# parseRepoUrl: { owner: "acme", repo: "cool-project", hostname: "github.com" }
# pick('owner'): "acme"
```

#### D. 조건부 렌더링

```handlebars
{% if values.enableDarkMode -%}
  "next-themes": "^0.4.6"
{%- endif %}

# - 기호는 공백 제거
# enableDarkMode가 true일 때만 위 줄이 출력됨
```

### 5. 실제 치환 예시

**사용자 입력:**
```yaml
projectName: "Company Blog"
description: "Enterprise blog platform"
owner: "group:frontend-team"
repoUrl: "https://github.com/acme/company-blog-frontend"
enableDarkMode: true
uiLibrary: "radix-ui"
stateManagement: "zustand"
apiClient: "axios"
```

**Skeleton → 생성된 파일:**

**index.html.hbs → index.html**
```html
<!-- Before (skeleton) -->
<title>${{ values.projectName }}</title>

<!-- After (generated) -->
<title>Company Blog</title>
```

**package.json.hbs → package.json**
```json
{
  "name": "${{ values.projectSlug }}-user-client",
  "version": "0.0.1",
  "description": "${{ values.description }} - Frontend",
}
```
↓
```json
{
  "name": "company-blog-user-client",
  "version": "0.0.1",
  "description": "Enterprise blog platform - Frontend",
}
```

**catalog-info.yaml.hbs → catalog-info.yaml**
```yaml
metadata:
  name: ${{ values.projectSlug }}-user-client
  annotations:
    github.com/project-slug: ${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}
spec:
  owner: "${{ values.owner }}"
  system: ${{ values.projectSlug }}-system
```
↓
```yaml
metadata:
  name: company-blog-user-client
  annotations:
    github.com/project-slug: acme/company-blog-frontend
spec:
  owner: "group:frontend-team"
  system: company-blog-system
```

### 6. 디버깅 팁

**변수 치환이 안 될 때:**
```bash
# 1. Template YAML에서 values 섹션 확인
grep -A 5 "values:" template.yaml

# 2. Handlebars 문법 확인
# 올바른: ${{ values.projectName }}
# 잘못된: ${{values.projectName}} (공백 필요)

# 3. 백스테이지 로그 확인
yarn dev | grep "template"

# 4. 생성된 파일 직접 확인
# /tmp/backstage-scaffolder-* 디렉토리에서 확인
```

---

## 사용 방법

### 1. Template 생성

1. **Backstage 접속**
   ```bash
   cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
   yarn dev
   # → http://localhost:3000 접속
   ```

2. **Template 선택**
   - 왼쪽 메뉴에서 **Create** 클릭
   - **Frontend React + Vite (test)** 선택

3. **파라미터 입력**
   ```yaml
   projectName: company-blog-frontend
   description: 회사 블로그 프론트엔드
   owner: group:frontend-team
   enableDarkMode: true
   uiLibrary: radix-ui
   stateManagement: zustand
   apiClient: axios
   repoUrl: https://github.com/company/company-blog-frontend
   ```

4. **생성 완료**
   - GitHub 저장소 자동 생성
   - Backstage 카탈로그에 자동 등록
   - 생성된 프로젝트 링크 제공

### 2. 로컬 개발 환경 구축

```bash
# 1. 생성된 저장소 클론
git clone https://github.com/company/company-blog-frontend.git
cd company-blog-frontend

# 2. 의존성 설치
pnpm install

# 3. 개발 서버 실행
pnpm dev

# → http://localhost:5173 에서 확인 가능
```

### 3. 백엔드 API 서버 실행

```bash
# Backend NestJS 서버 실행 (별도 터미널)
cd /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server
pnpm start:dev

# → http://localhost:3000 에서 API 제공
```

### 4. 실행 확인

1. **프론트엔드**: http://localhost:5173
2. **백엔드 API**: http://localhost:3000
3. **API 프록시**: `/api` 요청이 자동으로 백엔드로 전달

---

## 기술 스택

### 프론트엔드

| 기술 | 버전 | 용도 |
|------|------|------|
| React | 19.1.1 | UI 라이브러리 |
| Vite | 7.1.2 | 빌드 도구 |
| TypeScript | 5.8.3 | 타입 안전성 |
| TailwindCSS | 3.4.17 | CSS 프레임워크 |
| Zustand | 5.0.7 | 상태 관리 |
| React Router | 7.8.0 | 라우팅 |
| Axios | 1.11.0 | HTTP 클라이언트 |
| Radix UI | latest | UI 컴포넌트 |
| React Hook Form | 7.62.0 | 폼 관리 |
| Zod | 4.0.17 | 스키마 검증 |

### 개발 도구

- **ESLint**: 코드 품질 검사
- **TypeScript**: 정적 타입 검사
- **Vite**: 빠른 개발 서버

---

## PostgreSQL 연동

### 1. 데이터 흐름

```
PostgreSQL Database
    ↓
NestJS Backend API (localhost:3000)
    ↓
Vite Proxy (/api → localhost:3000)
    ↓
React Frontend (localhost:5173)
```

### 2. API 호출 방식

**usePosts 훅에서의 호출:**
```typescript
const response = await fetch('http://localhost:3000/api/categories');
```

**Vite Proxy 설정:**
```typescript
proxy: {
  '/api': {
    target: 'http://localhost:3000',
    changeOrigin: true,
    rewrite: (path) => path.replace(/^\/api/, '')
  }
}
```

**결과:**
- 프론트엔드에서 `/api/categories`로 요청
- Vite가 자동으로 `http://localhost:3000/categories`로 전달
- CORS 문제 해결

### 3. 백엔드 API 엔드포인트

```typescript
// 예상되는 백엔드 API 스펙
GET /api/categories
Response: {
  data: [
    {
      id: number,
      name: string,
      createdAt: string,
      updatedAt: string
    }
  ]
}
```

---

## Backstage 연동

### 1. 자동 등록 과정

Template 생성 시 자동으로 Backstage 카탈로그에 등록됩니다:

```yaml:1:24:rnd-backstage/catalog/templates/frontend-react-vite-test/skeleton/catalog-info.yaml.hbs
---
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.projectSlug }}-user-client
  description: ${{ values.description }} - Frontend Client
  tags:
    - react
    - vite
    - frontend
    - tailwindcss
    - typescript
    - test
  annotations:
    github.com/project-slug: ${{ values.repoUrl | parseRepoUrl | pick('owner') }}/${{ values.repoUrl | parseRepoUrl | pick('repo') }}
    backstage.io/techdocs-ref: dir:.
spec:
  type: website
  lifecycle: production
  owner: "${{ values.owner }}"
  system: ${{ values.projectSlug }}-system
  consumesApis:
    - ${{ values.projectSlug }}-rest-api
```

### 2. 카탈로그 정보

- **Type**: `website`
- **Owner**: 선택한 소유자 (예: `group:frontend-team`)
- **System**: 프로젝트 슬러그 기반 시스템
- **Consumes**: 백엔드 API 자동 연결

### 3. Backstage에서 확인

1. **Catalog 메뉴** 클릭
2. 생성된 컴포넌트 확인
3. **Dependencies** 탭에서 백엔드 API 연결 확인

---

## 문제 해결

### 1. 개발 서버가 시작되지 않는 경우

**문제:** `pnpm dev` 실행 시 오류 발생

**해결:**
```bash
# Node.js 버전 확인
node -v  # v18 이상 필요

# 의존성 재설치
rm -rf node_modules
pnpm install

# 캐시 삭제
pnpm cache clean
```

### 2. API 호출이 실패하는 경우

**문제:** 404 에러 또는 CORS 에러

**해결:**
1. 백엔드 서버 실행 확인
   ```bash
   curl http://localhost:3000/api/categories
   ```

2. Vite Proxy 설정 확인
   ```typescript
   // vite.config.ts
   proxy: {
     '/api': {
       target: 'http://localhost:3000',
       changeOrigin: true,
     }
   }
   ```

3. 브라우저 개발자 도구에서 네트워크 탭 확인

### 3. PostgreSQL 연결 실패

**문제:** 데이터가 표시되지 않음

**해결:**
1. 백엔드 `.env` 파일 확인
   ```
   DATABASE_URL=postgresql://user:password@localhost:5432/dbname
   ```

2. Prisma 마이그레이션 실행
   ```bash
   cd backend-project
   npx prisma generate
   npx prisma migrate dev
   ```

3. Seed 데이터 확인
   ```bash
   npx prisma db seed
   ```

### 4. Handlebars 변수 치환 실패

**문제:** `${{ values.projectName }}`이 텍스트로 표시됨

**해결:**
1. Template YAML에서 변수명 확인
2. `templateFileExtension: hbs` 설정 확인
3. `.hbs` 확장자 파일 확인

### 5. GitHub 저장소 생성 실패

**문제:** `publish:github` 액션 실패

**해결:**
1. GitHub Token 확인 (`app-config.yaml`)
   ```yaml
   integrations:
     github:
       - host: github.com
         token: ${GITHUB_TOKEN}
   ```

2. 저장소 권한 확인
3. 저장소 중복 확인

---

## Next Steps

### 1. 기능 확장

- [ ] 사용자 인증 추가
- [ ] 게시물 CRUD 구현
- [ ] 실시간 채팅 기능
- [ ] 파일 업로드
- [ ] 검색 기능

### 2. UI 개선

- [ ] shadcn/ui 컴포넌트 추가
- [ ] 다크모드 토글 버튼
- [ ] 반응형 디자인 개선
- [ ] 로딩 스피너 커스터마이징

### 3. 성능 최적화

- [ ] 코드 스플리팅
- [ ] 이미지 최적화
- [ ] API 캐싱
- [ ] 렌더링 최적화

### 4. 테스트 추가

- [ ] Unit Test (Jest)
- [ ] Integration Test
- [ ] E2E Test (Playwright)

---

## 참고 자료

### Backstage Template 문서
- [Software Template 가이드 v3](./software_template_guide_v3.md)
- [Tech Blog 카탈로그 설정](./TECH_BLOG_CATALOG_SETUP.md)
- [Backstage 카탈로그 확장 계획](./BACKSTAGE_CATALOG_EXPANSION_PLAN.md)

### 기술 문서
- [React Documentation](https://react.dev/)
- [Vite Documentation](https://vite.dev/)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)
- [Zustand Documentation](https://github.com/pmndrs/zustand)
- [React Router Documentation](https://reactrouter.com/)

### RND-NX 관련
- [RND-NX 카탈로그](./RND_NX_CATALOG.md)
- 원본 프로젝트: `/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/user-client`

---

## 작성 정보

**작성자**: Platform Team  
**작성일**: 2025-10-24  
**문서 버전**: 1.0  
**상태**: Final Guide

**작성 배경:**
이 문서는 RND-NX 프로젝트의 `tech-blog/user-client`를 기반으로 구현된 Backstage Software Template에 대한 기술 가이드입니다. 실제 구현된 코드와 구조를 기반으로 작성되었으며, 개발자가 이 Template을 사용하여 프론트엔드 프로젝트를 빠르게 생성하고 개발할 수 있도록 돕는 것이 목적입니다.

---

## 핵심 요약

### Handlebars 템플릿 시스템의 동작 원리

1. **파라미터 정의 → Template YAML**
   - `parameters` 섹션에 사용자가 입력할 값 정의
   - UI 필드 타입 지정 (OwnerPicker, RepoUrlPicker 등)

2. **값 변환 → Steps**
   - `parameters.*` 값을 `values.*`로 변환
   - Handlebars 필터 적용 (lower, replace, parseRepoUrl 등)

3. **파일 생성 → Skeleton**
   - `.hbs` 파일에서 `${{ values.* }}` 변수 치환
   - 조건부 처리는 `{% if %}` 사용

4. **자동화 → Actions**
   - GitHub 저장소 생성 및 푸시
   - Backstage 카탈로그 자동 등록

### 주요 포인트

- ✅ **자동화된 프로젝트 생성**: 사용자 입력만으로 완전한 React 프로젝트 생성
- ✅ **유연한 커스터마이징**: 조건부 렌더링으로 선택적 기능 추가
- ✅ **타입 안전성**: TypeScript로 전체 구조 지원
- ✅ **통합된 개발 환경**: Backstage 카탈로그와 자동 연동
- ✅ **확장 가능**: 다른 기술 스택도 동일한 패턴으로 추가 가능

### 다음 단계

1. Template 테스트: 실제 프로젝트 생성해보기
2. 기능 확장: 필요한 기능 추가
3. 백엔드 연동: NestJS Template과 함께 사용
4. 카탈로그 활용: Backstage에서 의존성 관리

