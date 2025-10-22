# GitHub OAuth 인증 활성화 완료

## ✅ 완료된 설정

### 1. 환경 변수 (.env)
```bash
AUTH_GITHUB_CLIENT_ID=your_client_id  # ✅ 설정됨
AUTH_GITHUB_CLIENT_SECRET=your_secret # ✅ 설정됨
```

### 2. Backstage 설정 (app-config.yaml)
```yaml
auth:
  environment: development
  providers:
    github:                              # ✅ 활성화됨
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        additionalScopes:
          - user:email
          - read:user
        signIn:
          resolvers:
            - resolver: usernameMatchingUserEntityName
            - resolver: emailMatchingUserEntityProfileEmail
            - resolver: emailLocalPartMatchingUserEntityName
```

---

## 🚀 사용 방법

### 1. Backstage 재시작
```bash
# 현재 실행 중이면 Ctrl+C로 종료
yarn start
```

### 2. 로그인
```
http://localhost:3000
```

**예상 화면:**
```
┌──────────────────────────────────┐
│  Sign in to Backstage            │
│                                   │
│  ┌────────────────────────────┐  │
│  │  Sign in with Google       │  │
│  └────────────────────────────┘  │
│                                   │
│  ┌────────────────────────────┐  │
│  │  Sign in with GitHub       │  │ ← 새로 추가됨!
│  └────────────────────────────┘  │
│                                   │
└──────────────────────────────────┘
```

### 3. GitHub 로그인 플로우
1. **"Sign in with GitHub"** 클릭
2. **GitHub 로그인 페이지**로 리다이렉트
3. **권한 승인** (처음 한 번만)
   - Read user profile
   - Read email address
   - Read organization membership
4. **Backstage로 돌아옴** (로그인 완료)
5. **우측 상단에 GitHub 프로필** 표시

---

## 👥 팀 협업

### 각 사용자별 동작
- ✅ **사용자 A**: 자신의 GitHub 계정으로 로그인 → A의 권한으로 리포지토리 접근
- ✅ **사용자 B**: 자신의 GitHub 계정으로 로그인 → B의 권한으로 리포지토리 접근
- ✅ **사용자 C**: 자신의 GitHub 계정으로 로그인 → C의 권한으로 리포지토리 접근

### 권한 관리
- 각 사용자는 **자신의 GitHub 권한**에 따라 리포지토리 접근
- Private 리포지토리는 **해당 사용자가 GitHub에서 권한이 있어야** Backstage에서도 표시됨
- 개인 토큰 공유 없음 (보안 강화)

---

## 🔍 Sign-In Resolvers 설명

Backstage는 GitHub 로그인 후 사용자를 식별하는 3가지 방법을 시도합니다:

### 1. usernameMatchingUserEntityName (Primary)
```yaml
# examples/org.yaml의 User entity와 GitHub username 매칭
- resolver: usernameMatchingUserEntityName
```

**예시:**
```yaml
# examples/org.yaml
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: jidaisy  # ← GitHub username과 일치해야 함
spec:
  memberOf: [platform-team]
```

**동작:**
- GitHub username: `jidaisy`
- Backstage User entity name: `jidaisy`
- ✅ 매칭 성공 → 로그인 완료

### 2. emailMatchingUserEntityProfileEmail (Fallback)
```yaml
# User entity의 email과 GitHub email 매칭
- resolver: emailMatchingUserEntityProfileEmail
```

**예시:**
```yaml
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: jidaisy
spec:
  profile:
    email: jidaisy@example.com  # ← GitHub email과 일치
  memberOf: [platform-team]
```

### 3. emailLocalPartMatchingUserEntityName (Last Resort)
```yaml
# GitHub email의 @ 앞 부분을 User entity name으로 매칭
- resolver: emailLocalPartMatchingUserEntityName
```

**예시:**
- GitHub email: `jidaisy@example.com`
- Email local part: `jidaisy` (@ 앞 부분)
- Backstage User entity name: `jidaisy`
- ✅ 매칭 성공

---

## 📋 사용자 추가 방법

### examples/org.yaml에 팀원 추가

```yaml
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: jidaisy  # GitHub username
spec:
  profile:
    displayName: Jiwon Seo
    email: jidaisy@example.com
    picture: https://avatars.githubusercontent.com/u/xxxxx
  memberOf:
    - platform-team
    - backend-team
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: newuser  # 새 팀원의 GitHub username
spec:
  profile:
    displayName: New User
    email: newuser@example.com
  memberOf:
    - frontend-team
```

**재시작 후 자동 인식**

---

## 🔒 보안 및 권한

### OAuth App 권한 범위
```yaml
additionalScopes:
  - user:email   # 사용자 이메일 읽기
  - read:user    # 사용자 프로필 읽기
  - read:org     # 조직 멤버십 읽기 (자동 포함)
```

### GitHub Integration 권한
```yaml
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}  # 선택사항 (공개 repo용)
```

**권장:**
- OAuth App으로 사용자 인증
- Personal Token은 공개 리포지토리 접근용 (백업)

---

## 🧪 테스트

### 1. 로그인 테스트
```bash
# Backstage 재시작
yarn start

# 브라우저
http://localhost:3000
```

### 2. 확인 사항
- ✅ "Sign in with GitHub" 버튼 표시
- ✅ 클릭 시 GitHub 인증 페이지로 이동
- ✅ 권한 승인 후 Backstage로 돌아옴
- ✅ 우측 상단에 GitHub 프로필 사진 표시
- ✅ Catalog에서 내가 접근 가능한 리포지토리 표시

### 3. 권한 테스트
```
사용자 A (repo1 권한 있음):
  → Catalog에 repo1 표시 ✅

사용자 B (repo1 권한 없음):
  → Catalog에 repo1 표시 안 됨 ✅
```

---

## 🚨 문제 해결

### Q1: "Sign in with GitHub" 버튼이 안 보임
**원인**: app-config.yaml 설정 오류
**해결**:
```bash
# app-config.yaml 확인
grep -A 10 "github:" app-config.yaml

# auth.providers.github가 주석 처리되지 않았는지 확인
```

### Q2: 로그인 후 "User not found" 에러
**원인**: examples/org.yaml에 사용자 정의 안 됨
**해결**:
```yaml
# examples/org.yaml에 추가
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: your-github-username  # GitHub username과 정확히 일치
spec:
  memberOf: [platform-team]
```

### Q3: "Invalid redirect_uri" 에러
**원인**: GitHub OAuth App의 Callback URL이 잘못됨
**해결**:
- GitHub OAuth App 설정 확인
- Callback URL: `http://localhost:7007/api/auth/github/handler/frame`

### Q4: Private 리포지토리가 안 보임
**원인**: 
1. GitHub OAuth App이 조직에서 승인되지 않음
2. 사용자가 해당 리포지토리 권한 없음

**해결**:
1. GitHub Organization Settings
2. Third-party access
3. VNTG Backstage (또는 OAuth App 이름) 승인

---

## 📊 인증 흐름

```
┌──────────┐
│  User    │
└─────┬────┘
      │ 1. http://localhost:3000
      ▼
┌──────────────────┐
│  Backstage       │
│  (Frontend)      │
└─────┬────────────┘
      │ 2. Click "Sign in with GitHub"
      ▼
┌──────────────────┐
│  Backstage       │
│  (Backend Auth)  │
└─────┬────────────┘
      │ 3. Redirect to GitHub
      ▼
┌──────────────────┐
│  GitHub OAuth    │
│  Authorization   │
└─────┬────────────┘
      │ 4. User approves
      ▼
┌──────────────────┐
│  GitHub          │
│  (returns token) │
└─────┬────────────┘
      │ 5. Redirect back
      ▼
┌──────────────────┐
│  Backstage       │
│  (Backend Auth)  │
└─────┬────────────┘
      │ 6. Match user entity
      ▼
┌──────────────────┐
│  Backstage       │
│  (Frontend)      │
│  ✅ Logged in   │
└──────────────────┘
```

---

## 🎯 다음 단계

### 1. 팀원 추가
```yaml
# examples/org.yaml 수정
# 각 팀원의 GitHub username으로 User entity 생성
```

### 2. 조직 제한 (선택사항)
```yaml
# app-config.yaml
auth:
  providers:
    github:
      development:
        # ... 기존 설정 ...
        # 특정 조직 멤버만 로그인 허용
        allowedOrganizations:
          - 'your-github-org'
```

### 3. 세션 시간 조정 (선택사항)
```yaml
auth:
  providers:
    github:
      development:
        # ... 기존 설정 ...
        sessionDuration: { hours: 24 }  # 24시간 세션 유지
```

---

## 📚 관련 문서

- [Backstage GitHub Authentication](https://backstage.io/docs/auth/github/provider)
- [Sign-in Resolvers](https://backstage.io/docs/auth/identity-resolver)
- [GitHub OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps)

---

**생성 날짜**: 2025-10-21  
**상태**: ✅ GitHub OAuth 활성화 완료  
**다음 작업**: Backstage 재시작 및 로그인 테스트

