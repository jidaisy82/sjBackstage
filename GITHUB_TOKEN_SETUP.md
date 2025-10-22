# GitHub Personal Access Token 설정 가이드

## 🚨 현재 문제
- `.env` 파일에 `GITHUB_TOKEN=your-github-personal-access-token` (플레이스홀더)
- 실제 GitHub Token이 필요함
- 에러: `401 Unauthorized` - GitHub API 접근 권한 없음

## 🔑 GitHub Personal Access Token (PAT) 생성 방법

### 1️⃣ GitHub에서 토큰 생성

1. **GitHub 로그인** → 우측 상단 프로필 클릭
2. **Settings** 클릭
3. 좌측 메뉴 맨 아래 **Developer settings** 클릭
4. **Personal access tokens** → **Tokens (classic)** 클릭
5. **Generate new token** → **Generate new token (classic)** 선택

### 2️⃣ 토큰 설정

**Note (이름)**: `Backstage Integration`

**Expiration**: 
- `No expiration` (권장 - 개발용)
- 또는 `90 days` (보안 강화)

**Select scopes (권한)**:
```
✅ repo (전체 선택)
   ✅ repo:status
   ✅ repo_deployment
   ✅ public_repo
   ✅ repo:invite
   ✅ security_events

✅ read:org (조직 정보 읽기)
✅ read:user (사용자 정보 읽기)
✅ user:email (이메일 읽기)
```

**최소 권한 (Backstage 기본 기능)**:
```
✅ repo (전체)
✅ read:org
✅ read:user
```

### 3️⃣ 토큰 복사
- **Generate token** 클릭
- 생성된 토큰을 **즉시 복사** (다시 볼 수 없음!)
- 형식: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

---

## 📝 .env 파일 업데이트

### 방법 1: 직접 수정
```bash
# .env 파일 열기
code .env

# 또는
nano .env
```

**변경 전:**
```bash
GITHUB_TOKEN=your-github-personal-access-token
```

**변경 후:**
```bash
GITHUB_TOKEN=ghp_your_actual_token_here_40_characters_long
```

### 방법 2: 명령어로 수정 (권장)
```bash
# 기존 플레이스홀더 제거
sed -i '' '/GITHUB_TOKEN=/d' .env

# 새 토큰 추가 (아래 토큰을 실제 값으로 변경)
echo "GITHUB_TOKEN=ghp_your_actual_token_here" >> .env
```

---

## ✅ 설정 확인

### 1. 환경 변수 확인
```bash
# .env 파일 확인 (토큰이 실제 값인지)
grep GITHUB_TOKEN .env

# 토큰이 'ghp_'로 시작하는지 확인
```

### 2. Backstage 재시작
```bash
# 프로세스 종료
# Ctrl+C (실행 중인 yarn start 종료)

# 재시작
yarn start
```

### 3. 테스트
- `http://localhost:3000/catalog` 접속
- Catalog 페이지에서 **Docs** 탭 클릭
- 401 에러가 사라지고 문서가 표시되어야 함

---

## 🔒 보안 주의사항

### ⚠️ 절대로 하지 말 것
- ❌ GitHub Token을 코드에 직접 하드코딩
- ❌ `.env` 파일을 Git에 커밋
- ❌ 공개 저장소에 Token 노출

### ✅ 권장 사항
- ✅ `.env` 파일은 `.gitignore`에 포함되어 있는지 확인
- ✅ Token은 환경 변수로만 관리
- ✅ 주기적으로 Token 갱신
- ✅ 불필요한 권한은 부여하지 않음

### .gitignore 확인
```bash
# .env 파일이 Git에서 무시되는지 확인
cat .gitignore | grep .env
```

**결과:**
```
.env
.env.local
.env.*.local
```

---

## 🔍 문제 해결

### Q1: 토큰을 생성했는데도 401 에러가 계속 발생
**해결:**
1. `.env` 파일의 토큰 값 재확인
2. Backstage 완전히 재시작 (Ctrl+C 후 `yarn start`)
3. 토큰 권한 확인 (최소 `repo`, `read:org` 필요)

### Q2: 토큰을 잃어버렸거나 복사하지 못했을 때
**해결:**
- GitHub에서 해당 토큰 삭제 후 새로 생성
- Settings → Developer settings → Personal access tokens

### Q3: Organization의 Private 저장소에 접근 안 됨
**해결:**
1. GitHub Organization Settings 접속
2. Third-party access → Backstage 승인
3. 또는 Organization owner에게 승인 요청

### Q4: "Resource not accessible by integration" 에러
**해결:**
- 토큰 권한 부족
- `repo` 전체 권한 활성화 확인

---

## 📋 현재 설정 상태

### app-config.yaml
```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}  # ✅ 환경 변수 참조
```

### .env (수정 필요)
```bash
# 현재 (❌)
GITHUB_TOKEN=your-github-personal-access-token

# 수정 후 (✅)
GITHUB_TOKEN=ghp_실제토큰40자리
```

---

## 🎯 다음 단계

1. **GitHub Token 생성** (위 가이드 따라)
2. **.env 파일 업데이트** (실제 토큰으로)
3. **Backstage 재시작** (`yarn start`)
4. **Catalog 확인** (401 에러 해결 확인)

---

## 📚 참고 문서

- [Backstage GitHub Integration](https://backstage.io/docs/integrations/github/locations)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub Token Scopes](https://docs.github.com/en/developers/apps/building-oauth-apps/scopes-for-oauth-apps)

---

**생성 날짜**: 2025-10-21  
**문제**: 401 Unauthorized - GitHub API 접근 권한 없음  
**해결**: GitHub Personal Access Token 생성 및 .env 설정

