# 🔧 TechDocs mkdocs.yml 에러 해결

## 🚨 문제 상황

### 에러 메시지
```
Building a newer version of this documentation failed. 
Error: "Failed to generate docs from /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server into /private/var/folders/.../T/techdocs-tmp-ImPBPr; 
caused by unknown error 'Command mkdocs failed, exit code: 1'"
```

### 근본 원인
```bash
# MkDocs를 직접 실행하면...
cd /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server
mkdocs build

# 출력:
ERROR - Config value 'docs_dir': The path '.../api-server/docs' isn't an existing directory.
```

---

## 🔍 원인 분석

### 문제가 된 파일: `mkdocs.yml`

**파일 위치:** `/RND-NX/apps/tech-blog/api-server/mkdocs.yml`

```yaml
site_name: tech-blog-api-server
docs_dir: docs              # ← 문제! 'docs/' 디렉토리가 없음
plugins:
  - techdocs-core
```

### 왜 문제가 발생했나?

1. **`mkdocs.yml` 파일이 존재**
   - MkDocs가 이 설정 파일을 발견
   - 설정 파일의 내용을 따름

2. **`docs_dir: docs` 설정**
   - MkDocs가 `docs/` 디렉토리에서 문서를 찾으려고 시도
   - `docs/` 디렉토리가 없음 → 에러 발생

3. **`README.md`는 무시됨**
   - `mkdocs.yml`이 있으면 MkDocs는 설정 파일을 우선시
   - 루트의 `README.md`는 자동으로 사용되지 않음!

---

## ✅ 해결 방법 (권장)

### `mkdocs.yml` 파일 삭제

**이유:**
- ✅ `catalog-info.yaml`에 `backstage.io/techdocs-ref: dir:.` 설정만으로 충분
- ✅ Backstage가 자동으로 `README.md`를 찾아서 사용
- ✅ 추가 디렉토리 구조 불필요
- ✅ 간단하고 직관적

**작업:**
```bash
# mkdocs.yml 삭제
rm /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/mkdocs.yml
```

---

## 📋 TechDocs 문서 우선순위

### Backstage TechDocs가 문서를 찾는 순서:

```
1. mkdocs.yml 파일 존재?
   YES ↓
   - mkdocs.yml의 설정을 따름
   - docs_dir 경로에서 index.md 찾기
   - docs_dir이 없으면 에러! ❌
   
   NO ↓
   - README.md 찾기
   - 자동으로 MkDocs 설정 생성
   - 정상 동작 ✅
```

### 핵심: `mkdocs.yml`이 있으면 우선순위가 높음!

---

## 📂 디렉토리 구조 비교

### ❌ 문제 상황 (mkdocs.yml 있음)
```
api-server/
├── catalog-info.yaml
│   └── backstage.io/techdocs-ref: dir:.
├── mkdocs.yml               ← 문제의 원인!
│   └── docs_dir: docs       ← 'docs/' 디렉토리 없음
├── README.md               ← 무시됨!
└── (docs/ 디렉토리 없음)   ← 에러 발생!
```

**결과:**
```
MkDocs 실행 → mkdocs.yml 발견 → docs_dir: docs 확인 
→ docs/ 디렉토리 없음 → 에러!
```

---

### ✅ 해결 후 (mkdocs.yml 삭제)
```
api-server/
├── catalog-info.yaml
│   └── backstage.io/techdocs-ref: dir:.
├── README.md               ← 자동으로 사용됨!
└── (mkdocs.yml 없음)       ← Backstage가 자동 생성
```

**결과:**
```
MkDocs 실행 → mkdocs.yml 없음 → README.md 자동 감지 
→ 임시 mkdocs.yml 생성 → 정상 동작 ✅
```

---

## 🎯 catalog-info.yaml의 역할

### `backstage.io/techdocs-ref: dir:.`의 의미

```yaml
# catalog-info.yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.
```

**의미:**
- `dir:.` = "현재 디렉토리에서 문서 찾기"
- Backstage가 자동으로:
  1. `mkdocs.yml` 찾기 (있으면 사용)
  2. 없으면 `README.md` 찾기
  3. `README.md`로 자동 MkDocs 설정 생성

**즉, `mkdocs.yml` 없어도 자동으로 동작합니다!**

---

## 💡 사용자 질문에 대한 답변

### Q: "왜 md 파일은 존재하면 catalog-info.yaml에서 경로만 지정해주면 되는거 아니야?"

**A: 정확합니다! 맞습니다!** ✅

**설명:**
1. **`catalog-info.yaml`에 경로 지정**
   ```yaml
   backstage.io/techdocs-ref: dir:.
   ```

2. **`README.md` 파일 존재**
   ```
   api-server/README.md  ✅
   ```

3. **이것만으로 충분!**
   - Backstage가 자동으로 `README.md` 찾기
   - 자동으로 MkDocs 설정 생성
   - 정상 동작!

**하지만 `mkdocs.yml`이 있으면?**
- Backstage는 `mkdocs.yml`의 설정을 따름
- `docs_dir: docs` 설정이 있으면 `docs/` 디렉토리 필요
- `README.md`는 무시됨!

**결론: `mkdocs.yml` 삭제하면 간단하게 해결!**

---

## 🔄 완료된 작업

### 1. mkdocs.yml 삭제
```bash
rm /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/mkdocs.yml
```

### 2. 생성된 디렉토리 삭제
```bash
rm -rf /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/docs
rm -rf /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/site
```

### 3. 최종 구조
```
api-server/
├── catalog-info.yaml  ✅
│   └── backstage.io/techdocs-ref: dir:.
└── README.md         ✅ (자동으로 사용됨!)
```

---

## 🚀 다음 단계

### 1. Backstage 재시작
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
# Ctrl+C로 중지 후
yarn start
```

### 2. TechDocs 확인
```
Catalog → tech-blog-api-server → Docs 탭
```

### 3. 기대 결과
- ✅ 에러 없이 README.md 내용 표시
- ✅ 문서 생성 성공
- ✅ 추가 설정 불필요

---

## 📊 두 가지 방식 비교

### 방식 1: mkdocs.yml 사용 (복잡)
```
api-server/
├── mkdocs.yml
│   └── docs_dir: docs
└── docs/
    ├── index.md      ← README.md 복사 필요
    ├── api.md
    └── setup.md
```

**장점:**
- 다중 페이지 문서 가능
- 세밀한 설정 가능
- 네비게이션 구조 정의

**단점:**
- 복잡한 디렉토리 구조
- README.md 복사 필요
- 유지보수 어려움

---

### 방식 2: README.md만 사용 (권장) ✅
```
api-server/
├── catalog-info.yaml
└── README.md         ← 그대로 사용!
```

**장점:**
- ✅ 간단한 구조
- ✅ 추가 설정 불필요
- ✅ README.md 그대로 사용
- ✅ 유지보수 쉬움

**단점:**
- 단일 페이지 문서만 가능
- 네비게이션 없음

**권장 사용 사례:**
- 단일 프로젝트 문서 (API 서버, 클라이언트 등)
- Quick Start 가이드
- 간단한 README 기반 문서

---

## 🛠️ 트러블슈팅

### Q1: 여전히 "docs directory not found" 에러
```bash
# 1. mkdocs.yml이 완전히 삭제되었는지 확인
ls -la /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/mkdocs.yml
# 출력: No such file or directory (정상)

# 2. Backstage 캐시 삭제
rm -rf ~/.backstage/techdocs/

# 3. Backstage 재시작
```

---

### Q2: README.md가 표시되지 않음
```bash
# README.md 파일 존재 확인
ls -la /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/README.md

# catalog-info.yaml 확인
grep "techdocs-ref" /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/catalog-info.yaml
# 출력: backstage.io/techdocs-ref: dir:.
```

---

### Q3: 다른 컴포넌트도 같은 에러
```bash
# 다른 디렉토리에서 mkdocs.yml 찾기
find /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog -name "mkdocs.yml"

# 발견되면 삭제
rm /path/to/mkdocs.yml
```

---

## 📝 핵심 정리

### 문제의 본질
```
mkdocs.yml이 있으면
→ MkDocs는 mkdocs.yml의 설정을 따름
→ docs_dir: docs 설정
→ docs/ 디렉토리 필요
→ 없으면 에러!
```

### 해결책
```
mkdocs.yml 삭제
→ Backstage가 README.md 자동 감지
→ 자동으로 MkDocs 설정 생성
→ 정상 동작! ✅
```

### catalog-info.yaml의 역할
```yaml
backstage.io/techdocs-ref: dir:.
```
↓
**"현재 디렉토리에서 문서 찾아줘!"**
↓
- mkdocs.yml 있으면 → 사용
- 없으면 → README.md 자동 사용

---

## ✅ 결론

**사용자 질문에 대한 답:**
> "왜 md 파일은 존재하면 catalog-info.yaml에서 경로만 지정해주면 되는거 아니야?"

**답: 완전히 맞습니다!** ✅

- `catalog-info.yaml`에 `backstage.io/techdocs-ref: dir:.` 설정
- `README.md` 파일 존재
- **이것만으로 충분합니다!**

**하지만:**
- `mkdocs.yml`이 있으면 Backstage는 그 설정을 따름
- `mkdocs.yml` 삭제 → 간단하게 해결!

**최종 구조:**
```
api-server/
├── catalog-info.yaml  (backstage.io/techdocs-ref: dir:.)
└── README.md         (Backstage가 자동으로 사용)
```

**이제 Backstage를 재시작하면 정상 동작합니다!** 🚀

