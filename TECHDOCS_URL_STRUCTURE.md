# 📍 Backstage TechDocs URL 구조 설명

## 🤔 질문: `http://localhost:3000/docs/default/component/tech-blog-api-server`는 어떤 서비스 링크인가요?

**답변**: 이것은 **외부 서비스가 아니라 Backstage 내부에서 생성한 URL**입니다!

---

## 🔗 URL 구조 분석

### 전체 URL
```
http://localhost:3000/docs/default/component/tech-blog-api-server
```

### 각 부분의 의미

```
┌─────────────────────┬──────┬─────────┬───────────┬─────────────────────┐
│ http://localhost:3000 │ /docs │ /default │ /component │ /tech-blog-api-server │
└─────────────────────┴──────┴─────────┴───────────┴─────────────────────┘
        ①                 ②       ③          ④                ⑤
```

#### ① `http://localhost:3000`
- **Backstage 프론트엔드 서버**
- `yarn start` 명령어로 실행된 React 애플리케이션
- 로컬 개발 환경 주소

#### ② `/docs`
- **TechDocs 플러그인의 라우팅 경로**
- `packages/app/src/App.tsx`에서 정의됨
- TechDocs 관련 모든 페이지는 `/docs`로 시작

#### ③ `/default`
- **Namespace** (네임스페이스)
- `catalog-info.yaml`의 `metadata.namespace` 값
- 명시하지 않으면 기본값 `default` 사용

#### ④ `/component`
- **Entity Kind** (엔티티 종류)
- `catalog-info.yaml`의 `kind` 값
- 가능한 값: `Component`, `System`, `API`, `Resource`, `Domain` 등

#### ⑤ `/tech-blog-api-server`
- **Entity Name** (엔티티 이름)
- `catalog-info.yaml`의 `metadata.name` 값
- 고유 식별자

---

## 📂 catalog-info.yaml과의 매핑

### catalog-info.yaml 파일
```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Component                    # ← ④ /component
metadata:
  name: tech-blog-api-server      # ← ⑤ /tech-blog-api-server
  namespace: default              # ← ③ /default (생략 가능)
  annotations:
    backstage.io/techdocs-ref: dir:.
```

### 생성되는 URL
```
http://localhost:3000/docs/default/component/tech-blog-api-server
                           ↑       ↑          ↑
                      namespace  kind      name
```

---

## 🔄 TechDocs URL 생성 흐름

```
1. Backstage가 catalog-info.yaml 읽기
   ↓
2. Entity 정보 추출
   - kind: Component
   - metadata.namespace: default
   - metadata.name: tech-blog-api-server
   ↓
3. TechDocs URL 패턴에 매핑
   /docs/{namespace}/{kind}/{name}
   ↓
4. 최종 URL 생성
   /docs/default/component/tech-blog-api-server
   ↓
5. README.md를 HTML로 변환해서 해당 경로에 서비스
```

---

## 🌐 다른 엔티티의 URL 예시

### 1. tech-blog-user-client (Component)
```yaml
# catalog-info.yaml
kind: Component
metadata:
  name: tech-blog-user-client
  namespace: default
```
**URL**: 
```
http://localhost:3000/docs/default/component/tech-blog-user-client
```

---

### 2. tech-blog-database (Resource)
```yaml
# catalog-info.yaml
kind: Resource
metadata:
  name: tech-blog-database
  namespace: default
```
**URL**: 
```
http://localhost:3000/docs/default/resource/tech-blog-database
```

---

### 3. rnd-nx-framework (System)
```yaml
# catalog-info.yaml
kind: System
metadata:
  name: rnd-nx-framework
  namespace: default
```
**URL**: 
```
http://localhost:3000/docs/default/system/rnd-nx-framework
```

---

### 4. Custom Namespace 사용 시
```yaml
# catalog-info.yaml
kind: Component
metadata:
  name: my-service
  namespace: production
```
**URL**: 
```
http://localhost:3000/docs/production/component/my-service
```

---

## 🚀 Backstage의 다른 URL 패턴들

### Catalog 페이지
```
http://localhost:3000/catalog/default/component/tech-blog-api-server
                     └─ catalog ─┘ └─────── entity 정보 ───────────┘
```

### API 문서 페이지
```
http://localhost:3000/api-docs/default/api/tech-blog-rest-api
                     └─ api-docs ─┘ └────── entity 정보 ────────┘
```

### Tech Insights 페이지
```
http://localhost:3000/catalog/default/resource/tech-blog-database
                                                  ↓
                                           Tech Insights 탭 클릭
```

---

## 📝 URL 패턴 규칙

### 기본 패턴
```
/{plugin-route}/{namespace}/{kind}/{name}
```

### TechDocs 전용 패턴
```
/docs/{namespace}/{kind}/{name}
```

### 특수 규칙
1. **Namespace 생략 시**: `default` 자동 사용
2. **Kind**: 소문자로 변환 (`Component` → `component`)
3. **Name**: 대소문자 유지

---

## 🔍 URL 구성 요소 확인 방법

### 방법 1: catalog-info.yaml 직접 확인
```bash
# Entity 정보 확인
cat /path/to/catalog-info.yaml

# 출력 예시
kind: Component              # ← kind
metadata:
  name: tech-blog-api-server # ← name
  namespace: default         # ← namespace
```

### 방법 2: Backstage UI에서 확인
```
Catalog → Component 선택 → 우측 상단 "Copy Entity URL" 클릭
```

### 방법 3: Backstage API로 확인
```bash
# Entity 정보 조회
curl http://localhost:7007/api/catalog/entities/by-name/component/default/tech-blog-api-server

# 출력에서 확인
{
  "kind": "Component",
  "metadata": {
    "namespace": "default",
    "name": "tech-blog-api-server"
  }
}
```

---

## 🎯 실제 동작 원리

### 1. Backstage Frontend (React)
```typescript
// packages/app/src/App.tsx
<Route path="/docs" element={<TechDocsReaderPage />} />
```

### 2. TechDocs 플러그인
```typescript
// TechDocs Reader가 URL 파싱
const { namespace, kind, name } = parseEntityRef(entityRef);
// entityRef = "component:default/tech-blog-api-server"
```

### 3. 문서 조회
```typescript
// 1. Catalog에서 Entity 정보 가져오기
const entity = await catalogApi.getEntityByRef(entityRef);

// 2. TechDocs 어노테이션 확인
const techdocsRef = entity.metadata.annotations['backstage.io/techdocs-ref'];
// techdocsRef = "dir:."

// 3. 문서 위치 확인
const docsLocation = resolveDocsLocation(entity, techdocsRef);
// docsLocation = "/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server"

// 4. README.md 읽기 및 HTML 변환
const html = await generateDocs(docsLocation);

// 5. 브라우저에 렌더링
```

---

## 🛠️ TechDocs 저장 위치

### app-config.yaml 설정
```yaml
techdocs:
  builder: 'local'
  generator:
    runIn: 'docker'
  publisher:
    type: 'local'
```

### 로컬 저장 경로
```bash
# macOS/Linux
~/.backstage/techdocs/

# 구조
~/.backstage/techdocs/
└── default/
    └── component/
        └── tech-blog-api-server/
            ├── index.html           # 변환된 HTML
            ├── techdocs_metadata.json
            └── assets/
                └── ...
```

### 확인 방법
```bash
# TechDocs 캐시 확인
ls -la ~/.backstage/techdocs/default/component/tech-blog-api-server/

# 출력 예시
drwxr-xr-x  index.html
-rw-r--r--  techdocs_metadata.json
```

---

## 📊 전체 흐름 도식화

```
사용자가 URL 접속
http://localhost:3000/docs/default/component/tech-blog-api-server
                    ↓
┌─────────────────────────────────────────────────────────┐
│ Backstage Frontend (React)                               │
│ - URL 파싱: /docs/{namespace}/{kind}/{name}             │
│ - Entity Ref 생성: "component:default/tech-blog-api-server" │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│ Catalog API                                              │
│ - Entity 정보 조회                                       │
│ - techdocs-ref 어노테이션 확인                           │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│ TechDocs Backend                                         │
│ - 문서 위치 확인 (README.md)                             │
│ - MkDocs로 HTML 생성                                     │
│ - 로컬 스토리지에 저장                                   │
└─────────────────────────────────────────────────────────┘
                    ↓
┌─────────────────────────────────────────────────────────┐
│ TechDocs Reader (UI)                                     │
│ - HTML 렌더링                                            │
│ - 네비게이션, 검색 기능 제공                             │
└─────────────────────────────────────────────────────────┘
```

---

## ✅ 핵심 요약

### ❓ 질문
> `http://localhost:3000/docs/default/component/tech-blog-api-server`는 어떤 서비스 링크인가요?

### ✅ 답변
**Backstage 내부에서 생성한 URL**입니다!

1. **외부 서비스 아님**
   - Backstage가 자체적으로 생성하고 서비스하는 경로

2. **URL 구성**
   ```
   /docs/{namespace}/{kind}/{name}
   ```

3. **문서 소스**
   - `catalog-info.yaml`의 `backstage.io/techdocs-ref`가 가리키는 `README.md`
   - Backstage가 Markdown → HTML로 변환해서 제공

4. **접근 방법**
   - Catalog → Component 선택 → "Docs" 탭 클릭
   - 또는 URL 직접 입력

### 🔑 핵심
**Backstage = Developer Portal**
- 모든 문서를 한 곳에서 통합 관리
- 일관된 URL 패턴 제공
- GitHub, GitLab 등 외부 서비스 아님!

