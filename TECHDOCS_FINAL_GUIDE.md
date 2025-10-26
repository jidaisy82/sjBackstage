# 📚 Backstage TechDocs 최종 가이드

## 🎯 문서 개요

이 문서는 VNTG Backstage의 TechDocs 설정, 사용법, 문제 해결 방법을 통합적으로 다룹니다.

**대상 독자:**
- Backstage 관리자
- 프로젝트 문서 작성자
- DevOps 엔지니어

---

## 📋 목차

1. [TechDocs란?](#techdocs란)
2. [기본 설정](#기본-설정)
3. [문서 출처 및 URL 구조](#문서-출처-및-url-구조)
4. [문서 작성 방법](#문서-작성-방법)
5. [주요 문제 해결](#주요-문제-해결)
6. [인증 및 권한](#인증-및-권한)
7. [모범 사례](#모범-사례)
8. [트러블슈팅](#트러블슈팅)

---

## 1️⃣ TechDocs란?

### 개요

**TechDocs**는 Backstage의 문서 관리 시스템으로, 소프트웨어 개발 팀이 프로젝트 문서를 자동으로 수집, 생성, 관리할 수 있게 해줍니다.

### 주요 기능

- ✅ **자동 문서 수집**: `catalog-info.yaml`을 통해 자동으로 문서 위치 감지
- ✅ **Markdown 지원**: README.md 또는 MkDocs 형식 지원
- ✅ **통합 개발자 포털**: 하나의 UI에서 모든 문서 접근
- ✅ **자동 HTML 변환**: Markdown을 자동으로 HTML로 변환
- ✅ **검색 가능**: Backstage 통합 검색 기능

### URL 패턴

```
http://localhost:3000/docs/{namespace}/{kind}/{name}
```

**예시:**
```
http://localhost:3000/docs/default/component/tech-blog-api-server
```

**구성 요소:**
- `/docs`: TechDocs 플러그인 라우팅 경로
- `/default`: Namespace (기본값: default)
- `/component`: Entity Kind (Component, System, API 등)
- `/tech-blog-api-server`: Entity Name (catalog-info.yaml의 metadata.name)

---

## 2️⃣ 기본 설정

### app-config.yaml 설정

```yaml
techdocs:
  builder: 'local'              # 로컬 빌더 사용
  generator:
    runIn: 'local'             # 로컬 환경에서 실행 (빠르고 간단)
  publisher:
    type: 'local'              # 로컬 스토리지에 저장
```

**설정 옵션:**

| 옵션 | 값 | 설명 |
|------|-----|------|
| `builder` | `local` | 로컬에서 문서 빌드 |
| `generator.runIn` | `local` 또는 `docker` | 로컬 또는 Docker 환경 |
| `publisher.type` | `local` | 로컬 파일 시스템에 저장 |

### 현재 설정 상태

✅ **로컬 개발 환경 설정**
- 빠른 문서 생성
- Docker 설치 불필요
- 간단한 디버깅

**실제 위치:**
```bash
~/.backstage/techdocs/
└── default/
    └── component/
        └── tech-blog-api-server/
            ├── index.html
            └── assets/
```

---

## 3️⃣ 문서 출처 및 URL 구조

### 문서 수집 메커니즘

```
app-config.yaml (catalog.locations)
          ↓
    catalog-info.yaml 로드
          ↓
    techdocs-ref 어노테이션 확인
          ↓
    문서 위치 결정 (README.md 또는 mkdocs.yml)
          ↓
    HTML 변환 및 저장
          ↓
    Backstage UI에서 표시
```

### 현재 등록된 문서

| Component | 소스 위치 | TechDocs URL |
|-----------|----------|-------------|
| **tech-blog-api-server** | `/RND-NX/apps/tech-blog/api-server/README.md` | `/docs/default/component/tech-blog-api-server` |
| **tech-blog-user-client** | `/RND-NX/apps/tech-blog/user-client/README.md` | `/docs/default/component/tech-blog-user-client` |
| **tech-blog-api-server-test** | `/RND-NX/apps/tech-blog/api-server-test/README.md` | `/docs/default/component/tech-blog-api-server-test` |
| **example-website** | Backstage 내장 | `/docs/default/component/example-website` |

### catalog-info.yaml 구조

**기본 예시:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: tech-blog-api-server
  namespace: default
  annotations:
    backstage.io/techdocs-ref: dir:.  # 현재 디렉토리의 README.md 사용
spec:
  type: service
  lifecycle: production
```

**주요 어노테이션:**

| 어노테이션 | 용도 | 값 예시 |
|-----------|------|---------|
| `backstage.io/techdocs-ref` | TechDocs 문서 위치 (필수) | `dir:.` 또는 `url:https://...` |
| `backstage.io/source-location` | 소스 코드 위치 (선택) | 주석 처리 권장 |
| `github.com/project-slug` | GitHub 리포지토리 식별 | `VntgCorp/RND-NX` |

---

## 4️⃣ 문서 작성 방법

### 방법 1: README.md 사용 (권장) ✅

**가장 간단한 방법:**

```yaml
# catalog-info.yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.
```

**디렉토리 구조:**
```
my-component/
├── catalog-info.yaml
└── README.md         ← 이것만 있으면 됨!
```

**장점:**
- ✅ 간단한 구조
- ✅ 추가 설정 불필요
- ✅ README.md 그대로 사용
- ✅ 유지보수 쉬움

### 방법 2: MkDocs 사용 (고급)

**여러 페이지가 필요한 경우:**

```yaml
# catalog-info.yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.
```

**디렉토리 구조:**
```
my-component/
├── catalog-info.yaml
├── mkdocs.yml
└── docs/
    ├── index.md
    ├── api.md
    ├── setup.md
    └── troubleshooting.md
```

**mkdocs.yml 예시:**
```yaml
site_name: 'My Component Documentation'

nav:
  - Home: index.md
  - API Reference: api.md
  - Setup Guide: setup.md
  - Troubleshooting: troubleshooting.md

plugins:
  - techdocs-core
```

---

## 5️⃣ 주요 문제 해결

### 문제 1: mkdocs.yml 에러

**증상:**
```
ERROR - Config value 'docs_dir': The path '.../api-server/docs' isn't an existing directory.
```

**원인:**
- `mkdocs.yml` 파일이 존재하지만 `docs/` 디렉토리가 없음
- `docs_dir: docs` 설정으로 인해 에러 발생

**해결 방법:**
```bash
# mkdocs.yml 삭제
rm /path/to/mkdocs.yml

# .gitignore에 추가 (재생성 방지)
echo "mkdocs.yml" >> .gitignore
echo "site/" >> .gitignore
```

**왜 이 방법이 효과적인가?**
- `mkdocs.yml`이 없으면 Backstage가 README.md를 자동 감지
- 임시 mkdocs.yml을 자동 생성
- 복잡한 설정 불필요

### 문제 2: 401 Unauthorized 에러

**증상:**
```
Error: "Request failed for https://api.github.com/..., 401 Unauthorized"
```

**원인:**
- `backstage.io/source-location`이 GitHub URL로 설정됨
- Private 리포지토리에 접근 권한 없음

**해결 방법:**
```yaml
# catalog-info.yaml
annotations:
  github.com/project-slug: VntgCorp/RND-NX
  # backstage.io/source-location: url:https://github.com/...  ← 주석 처리!
  backstage.io/techdocs-ref: dir:.  # 이것만 사용
```

### 문제 3: 문서가 오래됨

**해결 방법:**

1. **Catalog에서 Refresh:**
   ```
   Catalog → Component 선택 → "..." → "Refresh"
   ```

2. **캐시 삭제:**
   ```bash
   rm -rf ~/.backstage/techdocs/
   ```

3. **Backstage 재시작:**
   ```bash
   # Ctrl+C로 중지 후
   yarn start
   ```

---

## 6️⃣ 인증 및 권한

### GitHub OAuth 설정

**app-config.yaml:**
```yaml
auth:
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        additionalScopes:
          - user:email    # 사용자 이메일 읽기
          - read:user     # 사용자 프로필 읽기
          - repo          # 리포지토리 접근 (TechDocs용)
          - read:org      # 조직 정보 읽기
```

### GitHub Integration 설정

```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}  # Personal Access Token (백업용)
```

### 동작 방식

**이전 (문제):**
```
User → TechDocs → GitHub API
                ↓
        [GITHUB_TOKEN 사용]
                ↓
        401 Unauthorized ❌
```

**개선 후 (정상):**
```
User (GitHub 로그인) → TechDocs → GitHub API
         ↓                            ↓
  [OAuth Token 전달]       [User 권한으로 접근]
                                ↓
                          200 OK ✅
```

### 권한 설정 체크리스트

**GitHub OAuth App 설정:**
- [ ] Repository permissions → Contents: Read-only
- [ ] Account permissions → Email, Profile
- [ ] Organization permissions → Members (조직 리포지토리 사용 시)

---

## 7️⃣ 모범 사례

### 1. 문서 소스 관리

**권장 디렉토리 구조:**
```
my-component/
├── catalog-info.yaml       # TechDocs 설정
├── README.md               # 주요 문서
└── docs/                   # 선택사항 (여러 페이지 필요 시)
    ├── index.md
    ├── api.md
    └── troubleshooting.md
```

### 2. catalog-info.yaml 작성 팁

**기본 구조:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-component
  namespace: default
  annotations:
    # TechDocs 설정 (필수)
    backstage.io/techdocs-ref: dir:.
    
    # GitHub 리포지토리
    github.com/project-slug: VntgCorp/RND-NX
    
    # source-location은 주석 처리 (문제 방지)
    # backstage.io/source-location: url:...
    
spec:
  type: service
  lifecycle: production
  owner: team-name
```

### 3. 어노테이션 우선순위

**TechDocs가 문서를 찾는 순서:**
```
1. backstage.io/techdocs-ref 확인
   ↓
2. source-location 확인 (있으면 우선 사용!)
   ↓ 문제의 원인!
3. 문서 위치 결정
   ↓
4. README.md 또는 mkdocs.yml 읽기
   ↓
5. HTML 생성
```

**권장 설정:**
- `techdocs-ref: dir:.` ✅ 사용
- `source-location` ❌ 주석 처리

### 4. 문서 작성 팁

**README.md 구조:**
```markdown
# 프로젝트 제목

## 개요
프로젝트에 대한 간략한 설명

## 설치
```bash
npm install
```

## 사용법
주요 기능 설명

## API 문서
링크 또는 자세한 설명

## 트러블슈팅
자주 발생하는 문제 해결

## 기여
기여 방법
```

---

## 8️⃣ 트러블슈팅

### Q1: "Documentation build failed"

**확인 사항:**
```bash
# 1. mkdocs.yml 존재 여부 확인
ls -la /path/to/project/mkdocs.yml

# 2. README.md 존재 여부 확인
ls -la /path/to/project/README.md

# 3. catalog-info.yaml 확인
grep "techdocs-ref" catalog-info.yaml
```

**해결 방법:**
- `mkdocs.yml` 삭제 (README.md만 사용)
- `source-location` 주석 처리
- Backstage 캐시 삭제 후 재시작

---

### Q2: 문서가 안 보여요

**확인 체크리스트:**

1. **catalog-info.yaml 확인:**
   ```bash
   # TechDocs 설정이 있는지 확인
   grep "techdocs-ref" catalog-info.yaml
   # 출력: backstage.io/techdocs-ref: dir:. ✅
   ```

2. **app-config.yaml 확인:**
   ```yaml
   catalog:
     locations:
       - type: file
         target: /path/to/catalog-info.yaml  # ✅ 등록되어 있는지 확인
   ```

3. **Backstage 로그 확인:**
   ```bash
   yarn start | grep techdocs
   ```

---

### Q3: GitHub 인증이 안 돼요

**GitHub 로그인 확인:**
```
1. Backstage → Sign in with GitHub
2. 권한 승인 화면 확인
   ✅ Read access to code
   ✅ Read your email addresses
3. Authorize 클릭
```

**OAuth App 설정 확인:**
```
GitHub Organization Settings → Third-party access
→ "VNTG Backstage" OAuth App 승인 확인
```

---

### Q4: 로컬 파일을 사용하고 싶어요

**설정:**
```yaml
# catalog-info.yaml
annotations:
  # source-location 주석 처리
  # backstage.io/source-location: url:...
  
  # techdocs-ref만 사용
  backstage.io/techdocs-ref: dir:.
```

**결과:**
- ✅ 로컬 README.md 사용
- ✅ GitHub API 호출 불필요
- ✅ 빠른 문서 생성

---

### Q5: 여러 페이지 문서를 만들고 싶어요

**MkDocs 사용:**
```bash
# 1. docs/ 디렉토리 생성
mkdir docs

# 2. 문서 파일들 생성
touch docs/index.md
touch docs/api.md
touch docs/setup.md

# 3. mkdocs.yml 생성
cat > mkdocs.yml << EOF
site_name: My Documentation

nav:
  - Home: index.md
  - API: api.md
  - Setup: setup.md

plugins:
  - techdocs-core
EOF
```

**주의:**
- `mkdocs.yml`이 있으면 `docs_dir: docs` 설정 필요
- `docs/` 디렉토리 필수

---

## 📊 설정 비교표

| 설정 | 로컬 환경 | GitHub | 추가 설정 |
|------|---------|--------|---------|
| **README.md만** | ✅ 권장 | ❌ | 없음 |
| **MkDocs** | ✅ 가능 | ❌ | mkdocs.yml, docs/ |
| **GitHub URL** | ⚠️ 복잡 | ⚠️ OAuth 필요 | 권한 관리 |

**현재 환경 권장:**
- ✅ 로컬 파일 시스템 사용
- ✅ README.md만 사용
- ✅ 간단하고 빠름

---

## 🎯 빠른 참조

### 새 문서 추가하기

```bash
# 1. 프로젝트에 catalog-info.yaml 추가
cd /path/to/project
cat > catalog-info.yaml << EOF
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-project
  annotations:
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
EOF

# 2. README.md 작성 또는 확인
ls README.md

# 3. app-config.yaml에 위치 추가
# rnd-backstage/app-config.yaml
# catalog:
#   locations:
#     - type: file
#       target: /path/to/catalog-info.yaml

# 4. Backstage 재시작 또는 Catalog Refresh
```

### 기존 문서 수정하기

```bash
# 1. README.md 편집
vim /path/to/project/README.md

# 2. Backstage에서 확인
# Catalog → Component 선택 → Docs 탭 → Refresh
```

### 문서 삭제하기

```yaml
# catalog-info.yaml에서 TechDocs 설정 제거
annotations:
  # backstage.io/techdocs-ref: dir:.  ← 주석 처리
```

---

## 📝 체크리스트

### 초기 설정
- [ ] `app-config.yaml`에 TechDocs 설정 추가
- [ ] `catalog-info.yaml`에 `techdocs-ref` 어노테이션 추가
- [ ] README.md 파일 작성
- [ ] Backstage 재시작

### 문제 발생 시
- [ ] mkdocs.yml 삭제 (있다면)
- [ ] source-location 주석 처리
- [ ] 캐시 삭제 (~/.backstage/techdocs/)
- [ ] Backstage 재시작
- [ ] GitHub OAuth 로그인 확인

### 모범 사례 준수
- [ ] 간단한 README.md 사용
- [ ] .gitignore에 mkdocs.yml 추가
- [ ] 불필요한 어노테이션 제거
- [ ] 문서 업데이트 주기적으로 확인

---

## 🚀 다음 단계

1. **문서 추가**: 새 프로젝트의 TechDocs 설정
2. **내용 개선**: README.md 작성 가이드 준수
3. **검색 최적화**: 문서에 적절한 키워드 포함
4. **피드백 수집**: 팀원들의 문서 사용 패턴 파악

---

## 📚 참고 문서

- [Backstage TechDocs 공식 문서](https://backstage.io/docs/features/techdocs/architecture-overview)
- [MkDocs 사용법](https://www.mkdocs.org/)
- [Markdown 문법](https://www.markdownguide.org/)

---

## ✅ 요약

### 핵심 설정

```yaml
# catalog-info.yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.  # 이것만으로 충분!
```

### 필요한 파일

```
프로젝트/
├── catalog-info.yaml  ✅ TechDocs 설정
└── README.md         ✅ 문서 소스
```

### 문제 해결 3단계

1. **mkdocs.yml 삭제**
   ```bash
   rm mkdocs.yml
   ```

2. **source-location 주석 처리**
   ```yaml
   # backstage.io/source-location: url:...
   ```

3. **Backstage 재시작**
   ```bash
   yarn start
   ```

---

**이제 TechDocs를 사용할 준비가 되었습니다!** 🎉
