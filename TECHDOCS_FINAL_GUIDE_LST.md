# 📚 Backstage TechDocs 최종 통합 가이드 (검증본)

## 🎯 문서 개요

이 문서는 VNTG Backstage의 TechDocs 설정, 사용법, 문제 해결 방법을 **공식 문서를 기반으로 검증**하여 제공합니다.

**검증 정보:**
- ✅ [Backstage TechDocs 공식 문서](https://backstage.io/docs/features/techdocs/creating-and-publishing/) 기반
- ✅ 공식 문서 명시: mkdocs.yml 없으면 README.md 자동 사용
- ✅ VNTG 프로젝트 실제 경험 반영
- ✅ MkDocs 설정의 실제 동작 방식 설명

**공식 문서 근거:**
> Backstage 공식 문서에 명시적으로 "mkdocs.yml이 없으면 README.md를 사용"이라고 나와있습니다.

---

## 📋 목차

1. [TechDocs란?](#techdocs란)
2. [기본 설정](#기본-설정)
3. [문서 작성 방법](#문서-작성-방법)
4. [mkdocs.yml 동작 원리](#mkdocsyml-동작-원리)
5. [주요 문제 해결](#주요-문제-해결)
6. [모범 사례](#모범-사례)
7. [트러블슈팅](#트러블슈팅)

---

## 1️⃣ TechDocs란?

### 개요

**TechDocs**는 Spotify의 개발자 문서 관리 솔루션으로, Backstage에 통합된 "docs-as-code" 접근 방식입니다.

**공식 문서에 따르면** ([링크](https://backstage.io/docs/features/techdocs/)):

- 엔지니어가 Markdown으로 문서 작성
- 코드와 함께 문서 관리
- 최소한의 설정으로 Backstage에서 문서 사이트 제공
- Spotify에서 5000+ 문서 사이트, 10000+ 일일 조회수

### 주요 기능

- ✅ **자동 문서 수집**: `catalog-info.yaml`을 통해 문서 위치 자동 감지
- ✅ **Markdown 지원**: README.md 또는 MkDocs 멀티 페이지 형식
- ✅ **실시간 HTML 변환**: MkDocs를 사용한 자동 HTML 생성
- ✅ **통합 포털**: Backstage UI에서 모든 문서 접근
- ✅ **검색 기능**: Backstage 통합 검색으로 문서 검색

### URL 구조

```
http://localhost:3000/docs/{namespace}/{kind}/{name}
```

**예시:**
```
http://localhost:3000/docs/default/component/tech-blog-api-server
```

---

## 2️⃣ 기본 설정

### app-config.yaml

```yaml
techdocs:
  builder: 'local'        # 'local' 또는 'external'
  generator:
    runIn: 'local'        # 'local' 또는 'docker'
  publisher:
    type: 'local'         # 'local', 'awsS3', 'googleGcs' 등
```

**VNTG 현재 설정:**
```yaml
techdocs:
  builder: 'local'              # ✅ 로컬 빌더
  generator:
    runIn: 'local'             # ✅ 로컬 실행 (빠르고 간단)
  publisher:
    type: 'local'              # ✅ 로컬 파일 시스템 저장
```

### 저장 위치

```bash
~/.backstage/techdocs/
└── default/
    └── component/
        └── tech-blog-api-server/
            ├── index.html
            └── assets/
```

---

## 3️⃣ 문서 작성 방법

### 방법 1: README.md만 사용 (권장) ✅

**가장 간단한 방법입니다.**

**디렉토리 구조:**
```
my-component/
├── catalog-info.yaml       # TechDocs 설정
└── README.md              # 문서 소스 (이것만 있으면 됨!)
```

**catalog-info.yaml:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: tech-blog-api-server
  annotations:
    backstage.io/techdocs-ref: dir:.  # 현재 디렉토리 사용
spec:
  type: service
  lifecycle: production
```

**장점:**
- ✅ 간단한 구조
- ✅ 추가 설정 파일 불필요
- ✅ README.md 그대로 사용
- ✅ 유지보수 쉬움

---

### 방법 2: MkDocs 멀티 페이지 (고급)

**여러 페이지가 필요한 경우:**

**디렉토리 구조:**
```
my-component/
├── catalog-info.yaml
├── mkdocs.yml              # MkDocs 설정
└── docs/
    ├── index.md
    ├── api.md
    ├── setup.md
    └── troubleshooting.md
```

**mkdocs.yml:**
```yaml
site_name: 'My Documentation'

nav:
  - Home: index.md
  - API Reference: api.md
  - Setup Guide: setup.md
  - Troubleshooting: troubleshooting.md

plugins:
  - techdocs-core
```

**주의:**
- `docs_dir` 설정 시 해당 디렉토리가 존재해야 함
- `docs_dir`이 없으면 에러 발생

---

## 4️⃣ mkdocs.yml 동작 원리

### ⚠️ 중요한 사항 (공식 문서 검증됨 ✅)

**[Backstage 공식 문서](https://backstage.io/docs/features/techdocs/creating-and-publishing/)에 명시됨**:
- ✅ `mkdocs.yml` 파일이 없을 경우, TechDocs는 `README.md`를 자동으로 사용
- ✅ MkDocs의 기본 동작: `docs/index.md`를 찾고, 없으면 `README.md` 사용
- ✅ TechDocs의 `prepare-directory` 단계에서 기본 설정 생성
- ⚠️ 하지만 명시적 제어를 위해 `mkdocs.yml` 제공 권장

### TechDocs의 준비 과정

TechDocs는 문서를 빌드하기 전에 다음 단계를 거칩니다:

```
1. catalog-info.yaml에서 techdocs-ref 확인
2. 문서 소스 디렉토리로 이동
3. mkdocs.yml 존재 확인
   ↓
   있으면 → 그대로 사용
   없으면 → 기본 설정 자동 생성
              ↓
         README.md를 index.md로 변환
         임시 mkdocs.yml 생성
4. MkDocs 빌드 실행
```

### 실제 동작 (VNTG 프로젝트 검증)

**상황 1: mkdocs.yml 없음**
```
api-server/
├── catalog-info.yaml  ✅
└── README.md          ✅

결과: 정상 동작! ✅
Backstage가 임시 설정 생성
```

**상황 2: mkdocs.yml 있음 (docs_dir 설정 오류)**
```
api-server/
├── mkdocs.yml         ✅ (docs_dir: docs)
└── README.md          ✅

docs/ 디렉토리 없음 → 에러! ❌
```

### ✅ 권장 설정

**README.md만 사용하는 것이 가장 안전합니다:**

```yaml
# catalog-info.yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.
```

**결과:**
- ✅ Backstage가 README.md 감지
- ✅ 자동으로 기본 mkdocs.yml 생성
- ✅ 정상 빌드

---

## 5️⃣ 주요 문제 해결

### 문제 1: mkdocs.yml 에러

**증상:**
```
ERROR - Config value 'docs_dir': The path '.../docs' isn't an existing directory.
```

**원인:**
- `mkdocs.yml` 파일이 존재
- `docs_dir: docs` 설정
- `docs/` 디렉토리 없음

**해결 방법:**

```bash
# 옵션 1: mkdocs.yml 삭제 (가장 간단)
rm mkdocs.yml

# 옵션 2: .gitignore에 추가 (재생성 방지)
echo "mkdocs.yml" >> .gitignore
echo "site/" >> .gitignore
```

**왜 작동하는가?**
- mkdocs.yml이 없으면 Backstage가 README.md 자동 감지
- 기본 설정으로 임시 mkdocs.yml 생성
- `docs/` 디렉토리 불필요

---

### 문제 2: 401 Unauthorized

**증상:**
```
Error: "Request failed for https://api.github.com/..., 401 Unauthorized"
```

**원인:**
- `backstage.io/source-location`이 GitHub URL
- Private 리포지토리에 접근 권한 없음

**해결:**
```yaml
# catalog-info.yaml
metadata:
  annotations:
    github.com/project-slug: VntgCorp/RND-NX
    # backstage.io/source-location: url:...  ← 주석 처리!
    backstage.io/techdocs-ref: dir:.       # 이것만 사용
```

---

### 문제 3: 문서가 갱신되지 않음

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
   yarn start
   ```

---

## 6️⃣ 모범 사례

### 1. 문서 소스 관리

**권장 구조:**
```
프로젝트/
├── catalog-info.yaml       # TechDocs 설정
├── README.md               # 주 문서
└── docs/                   # 선택 (여러 페이지 필요 시)
    ├── index.md
    └── api.md
```

### 2. catalog-info.yaml 작성

```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-component
  annotations:
    # TechDocs 필수
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

### 3. Git 설정

**.gitignore:**
```gitignore
# TechDocs 생성 파일 무시
mkdocs.yml     # 자동 생성 방지
site/          # 빌드 결과물
```

---

## 7️⃣ 트러블슈팅

### Q1: 문서가 표시되지 않아요

**확인 사항:**

```bash
# 1. catalog-info.yaml 확인
grep "techdocs-ref" catalog-info.yaml
# 출력: backstage.io/techdocs-ref: dir:. ✅

# 2. README.md 존재 확인
ls -la README.md

# 3. mkdocs.yml 확인 (있다면)
ls -la mkdocs.yml
```

**해결:**
- `techdocs-ref` 어노테이션 확인
- README.md 존재 확인
- mkdocs.yml 문제 확인 (있다면)
- Backstage 캐시 삭제 및 재시작

---

### Q2: mkdocs.yml 에러가 발생해요

**원인:**
- mkdocs.yml에 `docs_dir: docs` 설정
- docs/ 디렉토리 없음

**해결:**
```bash
# mkdocs.yml 삭제
rm mkdocs.yml

# Backstage 재시작
# 자동으로 README.md 사용
```

---

### Q3: 문서가 오래된 버전이에요

**해결:**
```bash
# 1. 캐시 삭제
rm -rf ~/.backstage/techdocs/

# 2. Catalog에서 Refresh
# Backstage UI → Component → "..." → "Refresh"

# 3. 재시작 (필요 시)
yarn start
```

---

## 📊 설정 비교표

| 방법 | 파일 구조 | 장점 | 단점 | 권장도 |
|------|----------|------|------|--------|
| **README.md만** | `catalog-info.yaml` + `README.md` | ✅ 간단, 자동 감지 | 단일 페이지만 | ⭐⭐⭐⭐⭐ |
| **MkDocs (올바른 설정)** | `mkdocs.yml` + `docs/` | 멀티 페이지, 네비게이션 | 구조 복잡 | ⭐⭐⭐⭐ |
| **MkDocs (잘못된 설정)** | `mkdocs.yml` (docs 없음) | - | 에러 발생 | ❌ |

**VNTG 환경 권장:**
- ✅ README.md만 사용하는 것이 가장 안전하고 간단합니다
- ✅ mkdocs.yml은 필요한 경우에만 사용

---

## 🎯 핵심 정리

### TechDocs 동작 순서

```
1. catalog-info.yaml 읽기
   ↓
2. techdocs-ref 확인 → 문서 위치 결정
   ↓
3. mkdocs.yml 존재?
   ↓
   YES → 그대로 사용
   NO  → Backstage가 README.md 감지
         → 임시 mkdocs.yml 생성
   ↓
4. MkDocs 빌드 실행
   ↓
5. HTML 저장 및 표시
```

### 권장 설정

**가장 간단하고 안전한 방법:**

```yaml
# catalog-info.yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.
```

```
프로젝트/
├── catalog-info.yaml  ✅
└── README.md           ✅
```

### 주의사항

1. **mkdocs.yml이 있으면 그 설정을 따릅니다**
   - 만약 `docs_dir: docs` 설정이 있으면
   - `docs/` 디렉토리가 반드시 필요

2. **README.md만 있으면 자동으로 처리됩니다**
   - Backstage가 기본 설정 생성
   - 추가 파일 불필요

3. **source-location은 주석 처리합니다**
   - GitHub URL을 사용하면 401 에러 발생
   - 로컬 파일 시스템 사용 권장

---

## 📚 참고 자료

- [Backstage TechDocs 공식 문서](https://backstage.io/docs/features/techdocs/)
- [Getting Started Guide](https://backstage.io/docs/features/techdocs/getting-started)
- [TechDocs Concepts](https://backstage.io/docs/features/techdocs/concepts)
- [MkDocs 사용법](https://www.mkdocs.org/)
- [Markdown 가이드](https://www.markdownguide.org/)

---

## ✅ 최종 요약

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

### TechDocs의 동작

1. **mkdocs.yml 없음** → Backstage가 README.md 자동 감지 ✅
2. **mkdocs.yml 있음** → MkDocs 설정 따름 (docs_dir 설정 주의!)
3. **권장**: README.md만 사용하는 것이 가장 안전

### 문제 발생 시 3단계

1. mkdocs.yml 삭제 (있다면)
2. source-location 주석 처리
3. Backstage 캐시 삭제 및 재시작

---

**이제 TechDocs를 안전하게 사용할 수 있습니다!** 🎉

**검증 완료:** 이 가이드는 Backstage 공식 문서와 VNTG 프로젝트의 실제 경험을 모두 반영하여 작성되었습니다.
