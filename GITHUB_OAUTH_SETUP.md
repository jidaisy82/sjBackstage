# GitHub OAuth App 설정 가이드 (팀 협업용)

## 🎯 목표
- ✅ 여러 사용자가 각자의 GitHub 계정으로 로그인
- ✅ 각 사용자의 GitHub 권한으로 리포지토리 접근
- ✅ 보안 강화 (개인 토큰 공유하지 않음)

## 📋 Personal Access Token vs OAuth App

### Personal Access Token (현재 방식) ❌
```
[Backstage] ←──(고정 토큰)──→ [GitHub]
    ↑
   모든 사용자가 같은 토큰 사용
   (보안 위험, 권한 문제)
```

### GitHub OAuth App (권장 방식) ✅
```
[Backstage] ←→ [GitHub OAuth App] ←→ [GitHub]
    ↑                                      ↑
  사용자 A ─────────(A의 토큰)─────────────┘
  사용자 B ─────────(B의 토큰)─────────────┘
  사용자 C ─────────(C의 토큰)─────────────┘
```

---

## 🔧 GitHub OAuth App 생성

### 1️⃣ GitHub OAuth App 등록

1. **GitHub 조직 또는 개인 계정 접속**
   - 조직용: `https://github.com/organizations/YOUR_ORG/settings/applications`
   - 개인용: `https://github.com/settings/developers`

2. **OAuth Apps** 클릭

3. **New OAuth App** 클릭

4. **애플리케이션 정보 입력**:
   ```
   Application name: VNTG Backstage
   Homepage URL: http://localhost:3000
   Application description: VNTG Internal Developer Portal
   Authorization callback URL: http://localhost:7007/api/auth/github/handler/frame
   ```

5. **Register application** 클릭

6. **Client ID 복사**
   - 형식: `Iv1.xxxxxxxxxxxx`

7. **Generate a new client secret** 클릭
   - **Client Secret 복사** (한 번만 표시됨!)
   - 형식: `xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

---

## 📝 Backstage 설정

### 1. `.env` 파일 업데이트

```bash
# GitHub OAuth App (팀 협업용)
AUTH_GITHUB_CLIENT_ID=Iv1.your_client_id_here
AUTH_GITHUB_CLIENT_SECRET=your_client_secret_here

# GitHub Integration (읽기 전용, 선택사항)
GITHUB_TOKEN=ghp_optional_for_public_repos
```

### 2. `app-config.yaml` 업데이트

```yaml
auth:
  environment: development
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        ## uncomment if using GitHub Enterprise
        # enterpriseInstanceUrl: https://github.company.com
```

**추가 위치**: `app-config.yaml`의 `auth:` 섹션에 추가

---

## 🔄 완전한 app-config.yaml 설정

### auth 섹션 추가

```yaml
auth:
  # See https://backstage.io/docs/auth/ to learn about auth providers
  environment: development
  providers:
    # GitHub OAuth 설정 (팀 협업용)
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        # 선택사항: 특정 조직만 허용
        # signIn:
        #   resolvers:
        #     - resolver: usernameMatchingUserEntityName
        #     - resolver: emailMatchingUserEntityProfileEmail
        #     - resolver: emailLocalPartMatchingUserEntityName

# GitHub Integration (리포지토리 접근용)
integrations:
  github:
    - host: github.com
      # 옵션 1: OAuth 사용 (권장)
      apps:
        - appId: ${GITHUB_APP_ID}  # 선택사항
          clientId: ${AUTH_GITHUB_CLIENT_ID}
          clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
          webhookSecret: ${GITHUB_APP_WEBHOOK_SECRET}  # 선택사항
          privateKey: ${GITHUB_APP_PRIVATE_KEY}  # 선택사항
      
      # 옵션 2: Personal Token (공개 리포지토리용, 백업용)
      token: ${GITHUB_TOKEN}
```

---

## 🎨 Frontend 설정

### 1. `packages/app/src/App.tsx` 확인

GitHub 로그인 버튼이 이미 설정되어 있는지 확인:

```typescript
import { githubAuthApiRef } from '@backstage/core-plugin-api';
import { SignInPage } from '@backstage/core-components';

const app = createApp({
  // ...
  components: {
    SignInPage: props => (
      <SignInPage
        {...props}
        auto
        provider={{
          id: 'github-auth-provider',
          title: 'GitHub',
          message: 'Sign in using GitHub',
          apiRef: githubAuthApiRef,
        }}
      />
    ),
  },
});
```

이미 설정되어 있다면 수정 불필요!

---

## ✅ 사용자 로그인 흐름

### 1. 사용자 접속
```
사용자 → http://localhost:3000
```

### 2. GitHub 로그인 화면
```
┌─────────────────────────────────┐
│  Sign in to Backstage           │
│                                  │
│  ┌─────────────────────────┐   │
│  │  Sign in with GitHub    │   │
│  └─────────────────────────┘   │
│                                  │
└─────────────────────────────────┘
```

### 3. GitHub 인증
```
GitHub 로그인 페이지로 리다이렉트
  ↓
사용자가 GitHub 계정으로 로그인
  ↓
권한 승인 (VNTG Backstage 허용)
  ↓
Backstage로 리다이렉트 (로그인 완료)
```

### 4. 개인화된 경험
- 각 사용자의 GitHub 프로필 표시
- 각 사용자의 권한으로 리포지토리 접근
- 각 사용자가 접근 가능한 리포지토리만 표시

---

## 🔒 권한 설정

### OAuth App 권한 (자동 요청)
- `read:user` - 사용자 프로필 읽기
- `user:email` - 이메일 주소 읽기
- `read:org` - 조직 정보 읽기
- `repo` - 리포지토리 접근 (필요 시)

### 조직 제한 (선택사항)

특정 조직의 멤버만 로그인하도록 제한:

```yaml
auth:
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        signIn:
          resolvers:
            # GitHub Organization 멤버만 허용
            - resolver: usernameMatchingUserEntityName
        # 추가 필터
        allowedOrganizations:
          - 'your-github-org'
```

---

## 🧪 테스트 방법

### 1. 설정 완료 후 재시작
```bash
yarn start
```

### 2. 브라우저에서 확인
```
http://localhost:3000
```

### 3. 예상 동작
1. ✅ GitHub 로그인 버튼 표시
2. ✅ 클릭 시 GitHub 인증 페이지로 이동
3. ✅ 로그인 후 Backstage로 돌아옴
4. ✅ 우측 상단에 GitHub 프로필 사진 표시

---

## 🚨 문제 해결

### Q1: "Invalid client_id" 에러
**원인**: Client ID가 잘못됨
**해결**:
- `.env` 파일의 `AUTH_GITHUB_CLIENT_ID` 확인
- GitHub OAuth App 설정에서 Client ID 다시 복사

### Q2: "Redirect URI mismatch" 에러
**원인**: Callback URL이 일치하지 않음
**해결**:
- GitHub OAuth App의 **Authorization callback URL** 확인:
  ```
  http://localhost:7007/api/auth/github/handler/frame
  ```

### Q3: 로그인 후 빈 화면
**원인**: User entity가 없음
**해결**:
```yaml
# app-config.yaml
auth:
  providers:
    github:
      development:
        signIn:
          resolvers:
            - resolver: usernameMatchingUserEntityName
```

### Q4: Organization private repo 접근 안 됨
**원인**: OAuth App이 조직에서 승인되지 않음
**해결**:
1. GitHub Organization Settings
2. Third-party access
3. VNTG Backstage 승인

---

## 📊 비교표

| 항목 | Personal Access Token | GitHub OAuth App |
|------|----------------------|------------------|
| 사용자 | 단일 계정 토큰 공유 | 각 사용자별 로그인 |
| 보안 | 낮음 (토큰 노출 위험) | 높음 (개별 인증) |
| 권한 | 생성자의 권한 | 각 사용자의 권한 |
| 관리 | 토큰 갱신 필요 | 자동 관리 |
| 팀 협업 | ❌ 부적합 | ✅ 권장 |
| 로그인 필요 | ❌ 없음 | ✅ 있음 |

---

## 🎯 권장 사항

### 개발 환경 (소규모)
```yaml
# Personal Token만 사용 (간단함)
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
```

### 프로덕션 / 팀 환경 (권장)
```yaml
# OAuth App 사용 (보안 + 협업)
auth:
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}

integrations:
  github:
    - host: github.com
      apps:
        - appId: ${GITHUB_APP_ID}
          clientId: ${AUTH_GITHUB_CLIENT_ID}
          clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
```

---

## 📚 참고 문서

- [Backstage GitHub Authentication](https://backstage.io/docs/auth/github/provider)
- [GitHub OAuth Apps](https://docs.github.com/en/developers/apps/building-oauth-apps)
- [Backstage Sign-in Resolvers](https://backstage.io/docs/auth/identity-resolver)

---

## 🔄 마이그레이션 가이드

### Personal Token → OAuth App

**1단계**: OAuth App 생성 (위 가이드 참조)

**2단계**: `.env` 업데이트
```bash
# 추가
AUTH_GITHUB_CLIENT_ID=Iv1.xxxx
AUTH_GITHUB_CLIENT_SECRET=xxxx

# 기존 유지 (백업용)
GITHUB_TOKEN=ghp_xxxx
```

**3단계**: `app-config.yaml` 업데이트
```yaml
auth:
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
```

**4단계**: 재시작 및 테스트

---

**생성 날짜**: 2025-10-21  
**용도**: 팀 협업을 위한 GitHub OAuth 설정  
**보안 등급**: 높음 (개별 사용자 인증)

