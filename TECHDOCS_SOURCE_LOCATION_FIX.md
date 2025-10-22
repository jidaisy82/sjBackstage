# 🔧 TechDocs 401 Unauthorized 에러 해결

## 🚨 문제 상황

### 에러 메시지
```
Building a newer version of this documentation failed. 
Error: "Request failed for https://api.github.com/repos/VntgCorp/RND-NX/commits/develop/status?per_page=0, 401 Unauthorized"
```

### 증상
- Backstage Docs 탭에서 문서 클릭
- 401 Unauthorized 에러 발생
- TechDocs가 GitHub API를 호출하려고 시도

---

## 🔍 원인 분석

### 문제가 된 설정 (catalog-info.yaml)
```yaml
metadata:
  annotations:
    github.com/project-slug: VntgCorp/RND-NX
    backstage.io/source-location: url:https://github.com/VntgCorp/RND-NX/tree/develop/apps/tech-blog/api-server  # ← 문제!
    backstage.io/techdocs-ref: dir:.
```

### 왜 문제가 발생했나?

1. **`backstage.io/source-location`**이 GitHub URL로 설정됨
   - Backstage가 이 어노테이션을 보고 "GitHub에서 소스를 가져오라"고 해석
   
2. **`backstage.io/techdocs-ref: dir:.`**도 있지만
   - `source-location`의 우선순위가 더 높음!
   - TechDocs가 GitHub에서 문서를 가져오려고 시도
   
3. **GitHub API 호출**
   ```
   GET https://api.github.com/repos/VntgCorp/RND-NX/commits/develop/status
   ```
   - Private 리포지토리라 인증 필요
   - 401 Unauthorized 발생

---

## ✅ 해결 방법

### 방법 1: `source-location` 주석 처리 (권장)

**catalog-info.yaml 수정:**
```yaml
metadata:
  annotations:
    github.com/project-slug: VntgCorp/RND-NX
    # backstage.io/source-location: url:https://github.com/VntgCorp/RND-NX/tree/develop/apps/tech-blog/api-server
    backstage.io/techdocs-ref: dir:.  # ← 이것만 사용!
```

**장점:**
- ✅ 간단하고 명확
- ✅ 로컬 파일 시스템 사용 (GitHub 인증 불필요)
- ✅ 빠른 문서 생성

**단점:**
- ⚠️ Catalog UI에서 "View Source" 링크 표시 안 됨

---

### 방법 2: GitHub OAuth 권한으로 해결

**이 방법은 권장하지 않음** (복잡하고 불필요)

1. GitHub OAuth에 `repo` 권한 추가 (이미 완료)
2. GitHub로 로그인
3. Backstage가 사용자의 GitHub 토큰으로 API 호출

**문제:**
- 모든 사용자가 VntgCorp/RND-NX 리포지토리 접근 권한 필요
- GitHub API rate limit 소비
- 문서 생성 느림

---

## 📝 수정된 파일들

### 1. tech-blog-api-server
**파일:** `/RND-NX/apps/tech-blog/api-server/catalog-info.yaml`

```yaml
annotations:
  github.com/project-slug: VntgCorp/RND-NX
  # backstage.io/source-location: url:https://github.com/VntgCorp/RND-NX/tree/develop/apps/tech-blog/api-server
  backstage.io/techdocs-ref: dir:.
```

---

### 2. tech-blog-user-client
**파일:** `/RND-NX/apps/tech-blog/user-client/catalog-info.yaml`

```yaml
annotations:
  github.com/project-slug: VntgCorp/RND-NX
  # backstage.io/source-location: url:https://github.com/VntgCorp/RND-NX/tree/develop/apps/tech-blog/user-client
  backstage.io/techdocs-ref: dir:.
```

**추가 수정:**
- `vntg/RND-NX` → `VntgCorp/RND-NX` (일관성 유지)

---

### 3. tech-blog-api-server-test
**파일:** `/RND-NX/apps/tech-blog/api-server-test/catalog-info.yaml`

```yaml
annotations:
  github.com/project-slug: VntgCorp/RND-NX
  # backstage.io/source-location: url:https://github.com/VntgCorp/RND-NX/tree/develop/apps/tech-blog/api-server-test
  backstage.io/techdocs-ref: dir:.
```

**추가 수정:**
- `vntg/RND-NX` → `VntgCorp/RND-NX` (일관성 유지)

---

## 🔄 변경 사항 적용

### 1. Backstage 재시작 (필요 시)
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
# Ctrl+C로 중지 후
yarn start
```

### 2. Catalog Refresh (권장)
```
Backstage UI → Catalog → Component 선택 → 우측 상단 "..." → "Refresh"
```

### 3. TechDocs 확인
```
Catalog → tech-blog-api-server → Docs 탭
```
- ✅ 에러 없이 README.md 내용이 표시되어야 함!

---

## 📊 어노테이션 비교표

| 어노테이션 | 용도 | 값 예시 |
|-----------|------|---------|
| **github.com/project-slug** | GitHub 리포지토리 식별 | `VntgCorp/RND-NX` |
| **backstage.io/source-location** | 소스 코드 위치 (선택사항) | `url:https://github.com/...` 또는 주석 처리 |
| **backstage.io/techdocs-ref** | TechDocs 문서 위치 (필수) | `dir:.` (현재 디렉토리) |

---

## 🎯 각 어노테이션의 역할

### 1. `github.com/project-slug`
```yaml
github.com/project-slug: VntgCorp/RND-NX
```
- **용도**: GitHub 관련 기능 활성화
- **사용처**:
  - GitHub Insights 플러그인
  - CI/CD 상태 표시
  - Pull Request 목록
- **영향**: TechDocs와는 무관

---

### 2. `backstage.io/source-location`
```yaml
backstage.io/source-location: url:https://github.com/VntgCorp/RND-NX/tree/develop/apps/tech-blog/api-server
```
- **용도**: 소스 코드 위치 지정
- **사용처**:
  - Catalog UI의 "View Source" 링크
  - **TechDocs가 이 어노테이션을 참조할 수 있음!** ← 문제의 원인
- **권장**: 주석 처리 또는 제거

---

### 3. `backstage.io/techdocs-ref`
```yaml
backstage.io/techdocs-ref: dir:.
```
- **용도**: TechDocs 문서 위치 지정 (필수!)
- **값의 의미**:
  - `dir:.` - 현재 디렉토리의 README.md 또는 mkdocs.yml
  - `url:https://...` - GitHub URL (비권장)
- **사용처**: TechDocs 플러그인만 사용
- **영향**: 문서 생성에 직접 영향

---

## 🔍 TechDocs 문서 위치 우선순위

TechDocs가 문서를 찾는 순서:

```
1. backstage.io/techdocs-ref 확인
   ↓
2. source-location 확인 (있으면 우선 사용!)
   ↓
3. 문서 위치 결정
   ↓
4. README.md 또는 mkdocs.yml 읽기
   ↓
5. HTML 생성
```

**문제:**
- `source-location`이 GitHub URL → GitHub API 호출 시도
- `techdocs-ref: dir:.` 무시됨!

**해결:**
- `source-location` 제거 → `techdocs-ref`만 사용

---

## 🛠️ 트러블슈팅

### Q1: 여전히 401 에러가 발생해요
```bash
# 1. catalog-info.yaml 확인
grep "source-location" catalog-info.yaml
# 출력에 주석 처리된 것만 나와야 함

# 2. Backstage 캐시 삭제
rm -rf ~/.backstage/techdocs/

# 3. Backstage 재시작
yarn start
```

---

### Q2: "View Source" 링크를 살리고 싶어요
**해결책:**
- `links` 섹션에 GitHub 링크 추가 (이미 있음!)

```yaml
links:
  - url: https://github.com/VntgCorp/RND-NX/tree/develop/apps/tech-blog/api-server
    title: Source Code
    icon: github
```

이렇게 하면:
- ✅ TechDocs는 로컬 파일 사용
- ✅ GitHub 링크는 "Links" 섹션에 표시

---

### Q3: GitHub에서 문서를 가져오고 싶어요
**이유:**
- CI/CD에서 자동 업데이트
- 여러 환경에서 일관된 문서

**해결:**
1. **GitHub OAuth 설정 완료** (이미 완료)
2. **`techdocs-ref`를 GitHub URL로 변경**
```yaml
backstage.io/techdocs-ref: url:https://github.com/VntgCorp/RND-NX/tree/develop/apps/tech-blog/api-server
```
3. **모든 사용자 GitHub로 로그인 필수**

**단점:**
- GitHub API rate limit
- 느린 문서 생성
- 모든 사용자에게 리포지토리 권한 필요

---

## ✅ 핵심 요약

### 문제 원인
```yaml
# 이렇게 하면 GitHub API 호출 시도 → 401 에러
backstage.io/source-location: url:https://github.com/...
backstage.io/techdocs-ref: dir:.
```

### 해결책
```yaml
# source-location 주석 처리 → 로컬 파일 사용 → 에러 없음
# backstage.io/source-location: url:https://github.com/...
backstage.io/techdocs-ref: dir:.
```

### 동작 방식
```
TechDocs가 문서 찾는 순서:
1. source-location 확인 → 주석 처리됨 → 무시
2. techdocs-ref 확인 → dir:. → 현재 디렉토리의 README.md 사용
3. 로컬 파일 읽기 → GitHub API 호출 불필요
4. HTML 생성 → 정상 표시 ✅
```

---

## 📋 체크리스트

- [x] tech-blog-api-server - `source-location` 주석 처리
- [x] tech-blog-user-client - `source-location` 주석 처리
- [x] tech-blog-api-server-test - `source-location` 주석 처리
- [x] `github.com/project-slug` 일관성 확인 (`VntgCorp/RND-NX`)
- [ ] Backstage 재시작 또는 Catalog Refresh
- [ ] TechDocs 접근 테스트

---

## 🎯 결론

**`backstage.io/source-location`이 GitHub URL이면 TechDocs가 GitHub에서 문서를 가져오려고 시도합니다!**

**해결:**
- 로컬 개발 환경에서는 `source-location` 주석 처리
- `techdocs-ref: dir:.`만 사용
- GitHub 링크는 `links` 섹션에 추가

이제 TechDocs가 **로컬 README.md**를 읽어서 에러 없이 문서를 표시합니다! 🚀

