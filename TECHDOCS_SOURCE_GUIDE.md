# 📚 Backstage TechDocs 문서 출처 가이드

## 🤔 질문: Docs에 표시되는 4개의 문서는 어디서 오나요?

Backstage의 **Docs** 탭에 표시되는 문서들은 **catalog-info.yaml 파일의 TechDocs 설정**을 따라 자동으로 수집됩니다.

---

## 📍 문서 출처 확인 방법

### 1️⃣ Catalog에 등록된 엔티티 확인

`app-config.yaml`에서 등록된 모든 카탈로그 위치를 확인:

```yaml
catalog:
  locations:
    # RND-NX 프로젝트 컴포넌트
    - type: file
      target: ../../../RND-NX/apps/tech-blog/api-server/catalog-info.yaml
    - type: file
      target: ../../../RND-NX/apps/tech-blog/user-client/catalog-info.yaml
    - type: file
      target: ../../../RND-NX/apps/tech-blog/api-server-test/catalog-info.yaml
    
    # 예시 엔티티
    - type: file
      target: ../../examples/entities.yaml
```

---

## 🔍 현재 TechDocs가 수집되는 4개의 문서

### 1. **tech-blog-api-server** (API 서버)

**파일 위치:**
```
/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/
├── catalog-info.yaml       ← TechDocs 설정
└── README.md              ← 문서 소스
```

**catalog-info.yaml 설정:**
```yaml
metadata:
  name: tech-blog-api-server
  annotations:
    backstage.io/techdocs-ref: dir:.  # 현재 디렉토리의 README.md 사용
```

**문서 내용:**
- NestJS API 서버 설명
- Quick Start 가이드
- API 문서 링크
- 환경 설정 방법

---

### 2. **tech-blog-user-client** (프론트엔드)

**파일 위치:**
```
/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/user-client/
├── catalog-info.yaml       ← TechDocs 설정
├── README.md              ← 주 문서
├── frontend_install_guide.md
├── MIGRATION_SUMMARY.md
└── README_API_MIGRATION.md
```

**catalog-info.yaml 설정:**
```yaml
metadata:
  name: tech-blog-user-client
  annotations:
    backstage.io/techdocs-ref: dir:.  # 현재 디렉토리의 README.md 사용
```

**문서 내용:**
- React 프론트엔드 설명
- 설치 가이드
- UI 컴포넌트 정보
- API 마이그레이션 가이드

---

### 3. **tech-blog-api-server-test** (테스트 프로젝트)

**파일 위치:**
```
/Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server-test/
├── catalog-info.yaml       ← TechDocs 설정
└── README.md              ← 문서 소스
```

**catalog-info.yaml 설정:**
```yaml
metadata:
  name: tech-blog-api-server-test
  annotations:
    backstage.io/techdocs-ref: dir:.  # 현재 디렉토리의 README.md 사용
```

**문서 내용:**
- E2E 테스트 설명
- 테스트 실행 방법
- API 테스트 케이스

---

### 4. **example-website** (Backstage 예시)

**파일 위치:**
```
/Users/seojiwon/VNTG_PROJECT/rnd-backstage/examples/entities.yaml
```

**entities.yaml 설정:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: example-website
spec:
  type: website
  lifecycle: experimental
  owner: guests
  system: examples
```

**문서 내용:**
- Backstage 기본 예시 컴포넌트
- TechDocs 기능 데모용

---

## 🔄 TechDocs 동작 원리

### 1. 카탈로그 스캔
```
app-config.yaml → catalog.locations 확인
                ↓
        catalog-info.yaml 파일들 로드
```

### 2. TechDocs 감지
```
catalog-info.yaml의 annotations 확인
                ↓
    backstage.io/techdocs-ref 있는지 체크
```

### 3. 문서 생성
```
techdocs-ref 위치의 README.md 또는 mkdocs.yml 찾기
                ↓
        Markdown을 HTML로 변환
                ↓
        Backstage UI에서 "Docs" 탭으로 표시
```

---

## 📝 TechDocs 설정 방법

### 기본 설정 (README.md 사용)

**catalog-info.yaml:**
```yaml
metadata:
  name: my-component
  annotations:
    # 현재 디렉토리의 README.md를 문서로 사용
    backstage.io/techdocs-ref: dir:.
```

**디렉토리 구조:**
```
my-component/
├── catalog-info.yaml
└── README.md          ← TechDocs 소스
```

---

### 고급 설정 (MkDocs 사용)

**catalog-info.yaml:**
```yaml
metadata:
  name: my-component
  annotations:
    # MkDocs를 사용한 다중 페이지 문서
    backstage.io/techdocs-ref: dir:.
```

**디렉토리 구조:**
```
my-component/
├── catalog-info.yaml
├── mkdocs.yml         ← MkDocs 설정
└── docs/
    ├── index.md       ← 메인 페이지
    ├── api.md
    ├── setup.md
    └── troubleshooting.md
```

**mkdocs.yml 예시:**
```yaml
site_name: 'My Component Documentation'
site_description: 'Comprehensive documentation for My Component'

nav:
  - Home: index.md
  - API Reference: api.md
  - Setup Guide: setup.md
  - Troubleshooting: troubleshooting.md

plugins:
  - techdocs-core
```

---

### GitHub URL 사용

**catalog-info.yaml:**
```yaml
metadata:
  name: my-component
  annotations:
    # GitHub 리포지토리의 특정 경로 사용
    backstage.io/techdocs-ref: url:https://github.com/vntg/RND-NX/tree/main/apps/tech-blog/api-server
```

---

## 🎯 현재 Backstage 설정 요약

### app-config.yaml
```yaml
techdocs:
  builder: 'local'              # Backstage가 직접 문서 생성
  generator:
    runIn: 'docker'            # Docker에서 MkDocs 실행
  publisher:
    type: 'local'              # 로컬에 문서 저장
```

### 문서 생성 흐름
```
1. Backstage 시작
   ↓
2. catalog-info.yaml 파일들 스캔
   ↓
3. techdocs-ref 발견
   ↓
4. Docker 컨테이너에서 MkDocs 실행
   ↓
5. README.md → HTML 변환
   ↓
6. 로컬 스토리지에 저장
   ↓
7. UI의 "Docs" 탭에서 표시
```

---

## 🔧 문서 추가/수정 방법

### 새 문서 추가하기

1. **catalog-info.yaml에 TechDocs 설정 추가**
```yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.
```

2. **README.md 파일 생성**
```bash
cd /path/to/component
echo "# My Component Documentation" > README.md
```

3. **Backstage에서 자동 감지**
- 변경 사항이 즉시 반영됨
- 필요시 "Refresh" 클릭

---

### 기존 문서 수정하기

1. **README.md 파일 편집**
```bash
vim /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/README.md
```

2. **Backstage에서 확인**
- Catalog → Component 선택
- "Docs" 탭 클릭
- "Refresh" 클릭 (필요시)

---

### 문서 삭제하기

1. **catalog-info.yaml에서 TechDocs 설정 제거**
```yaml
metadata:
  annotations:
    # backstage.io/techdocs-ref: dir:.  ← 주석 처리 또는 삭제
```

2. **Backstage 재시작 또는 Refresh**

---

## 📊 현재 등록된 문서 목록

| Component | 문서 위치 | 주요 내용 |
|-----------|---------|---------|
| **tech-blog-api-server** | `/RND-NX/apps/tech-blog/api-server/README.md` | NestJS API 서버, Quick Start, 환경 설정 |
| **tech-blog-user-client** | `/RND-NX/apps/tech-blog/user-client/README.md` | React 프론트엔드, UI 컴포넌트, API 연동 |
| **tech-blog-api-server-test** | `/RND-NX/apps/tech-blog/api-server-test/README.md` | E2E 테스트, 테스트 실행 방법 |
| **example-website** | (Backstage 내장) | 예시 컴포넌트 |

---

## 🚀 문서를 찾는 방법

### 방법 1: Catalog에서 찾기
```
Backstage → Catalog → Component 선택 → "Docs" 탭
```

### 방법 2: 검색 사용
```
Backstage 상단 검색창 → Component 이름 입력 → "Docs" 탭
```

### 방법 3: URL 직접 접근
```
http://localhost:3000/docs/default/component/tech-blog-api-server
http://localhost:3000/docs/default/component/tech-blog-user-client
```

---

## 🔍 트러블슈팅

### 문서가 안 보이는 경우

1. **catalog-info.yaml 확인**
```bash
# TechDocs 설정이 있는지 확인
grep "techdocs-ref" catalog-info.yaml
```

2. **README.md 파일 존재 확인**
```bash
ls -la README.md
```

3. **Backstage 로그 확인**
```bash
# TechDocs 빌드 에러 확인
yarn start | grep techdocs
```

---

### 401 Unauthorized 에러

**원인**: GitHub private repository 접근 권한 없음

**해결**: 
1. GitHub OAuth로 로그인
2. `repo` 권한 승인
3. 문서 다시 로드

**참고**: `TECHDOCS_GITHUB_AUTH_FIX.md` 문서 참조

---

### 문서가 오래된 경우

**해결**:
1. Component 페이지에서 "Refresh" 클릭
2. 또는 Backstage 재시작
```bash
# Ctrl+C로 중지 후
yarn start
```

---

## ✅ 요약

### 📍 4개의 문서 출처:
1. ✅ **tech-blog-api-server** → `/RND-NX/apps/tech-blog/api-server/README.md`
2. ✅ **tech-blog-user-client** → `/RND-NX/apps/tech-blog/user-client/README.md`
3. ✅ **tech-blog-api-server-test** → `/RND-NX/apps/tech-blog/api-server-test/README.md`
4. ✅ **example-website** → Backstage 내장 예시

### 🔄 수집 메커니즘:
- `app-config.yaml` → `catalog.locations` 정의
- `catalog-info.yaml` → `backstage.io/techdocs-ref` 설정
- `README.md` 또는 `mkdocs.yml` → 실제 문서 소스

### 🎯 핵심:
**catalog-info.yaml의 `backstage.io/techdocs-ref` 어노테이션**이 TechDocs 문서의 출처를 정의합니다!

