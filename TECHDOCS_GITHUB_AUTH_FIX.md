# TechDocs GitHub 인증 문제 해결

## 🚨 문제 상황
- **증상**: TechDocs에서 문서를 클릭하면 `401 Unauthorized` 에러 발생
- **원인**: TechDocs가 Private GitHub Repository에 접근할 권한이 없음
- **기존 방식**: 공용 `GITHUB_TOKEN` (Personal Access Token) 사용
- **문제점**: 사용자가 로그인해도 자신의 GitHub 권한으로 접근하지 못함

---

## ✅ 해결 방법

### 1️⃣ Backstage 설정 업데이트 (완료)

#### `app-config.yaml` 수정 내용:

**GitHub OAuth Scopes 추가**
```yaml
auth:
  providers:
    github:
      development:
        clientId: ${AUTH_GITHUB_CLIENT_ID}
        clientSecret: ${AUTH_GITHUB_CLIENT_SECRET}
        additionalScopes:
          - user:email   # 사용자 이메일 읽기
          - read:user    # 사용자 프로필 읽기
          - repo         # 📦 리포지토리 접근 (TechDocs용) ← 추가됨!
          - read:org     # 조직 정보 읽기 ← 추가됨!
```

**Integration 설명 업데이트**
```yaml
integrations:
  github:
    - host: github.com
      # Personal Access Token (공개 리포지토리 및 백업용)
      # 로그인하지 않은 사용자나 권한이 없는 경우에만 사용됨
      # TechDocs는 로그인한 사용자의 GitHub OAuth 토큰을 우선 사용
      token: ${GITHUB_TOKEN}
```

---

### 2️⃣ GitHub OAuth App 권한 업데이트 (필수!)

#### GitHub OAuth App 설정 수정

1. **GitHub OAuth App 관리 페이지 접속**
   - 조직용: `https://github.com/organizations/YOUR_ORG/settings/applications`
   - 개인용: `https://github.com/settings/developers`

2. **VNTG Backstage OAuth App 선택**

3. **"Repository permissions" 섹션으로 스크롤**

4. **다음 권한 추가/확인:**
   ```
   ✅ Repository contents: Read-only
      (리포지토리 파일 읽기 - TechDocs용)
   
   ✅ Metadata: Read-only
      (기본 권한, 자동 선택됨)
   
   선택사항 (권장):
   ✅ Commit statuses: Read-only
   ✅ Deployments: Read-only
   ```

5. **"Account permissions" 섹션 확인:**
   ```
   ✅ Email addresses: Read-only
   ✅ Profile: Read-only
   ```

6. **"Organization permissions" (조직 리포지토리 사용 시):**
   ```
   ✅ Members: Read-only
   ```

7. **"Save changes" 클릭**

---

## 🔄 동작 방식

### 이전 (문제 발생)
```
User → TechDocs → GitHub API
                   ↓
           [GITHUB_TOKEN 사용]
                   ↓
          401 Unauthorized
       (권한 없음)
```

### 개선 후 (정상 동작)
```
User (GitHub 로그인) → TechDocs → GitHub API
         ↓                           ↓
  [OAuth Token 자동 전달]    [User의 권한으로 접근]
                                     ↓
                            200 OK (문서 표시)
```

---

## 📝 작동 흐름

1. **사용자가 Backstage에 로그인**
   - Google 또는 GitHub OAuth로 로그인

2. **TechDocs에서 문서 클릭**
   - Backstage가 GitHub API 호출 필요 감지

3. **자동 권한 확인**
   - 사용자가 GitHub로 로그인했는지 확인
   - GitHub OAuth 토큰이 있는지 확인

4. **GitHub 리포지토리 접근**
   - ✅ **GitHub 로그인 O**: 사용자의 OAuth 토큰 사용 → 성공!
   - ⚠️ **GitHub 로그인 X**: `GITHUB_TOKEN` (PAT) 사용 → 제한적 접근

---

## 🧪 테스트 방법

### 1. Backstage 재시작
```bash
# 현재 실행 중인 Backstage 중지 (Ctrl+C)
yarn start
```

### 2. GitHub로 재로그인
1. Backstage 접속 (`http://localhost:3000`)
2. **로그아웃** (우측 상단)
3. **Sign in with GitHub** 클릭
4. **새로운 권한 승인 화면 표시**
   ```
   VNTG Backstage wants to access your account:
   
   ✅ Read access to code
   ✅ Read access to metadata
   ✅ Read your email addresses
   ✅ Read your profile information
   
   [Authorize VNTG Backstage]
   ```
5. **Authorize** 클릭

### 3. TechDocs 접근 테스트
1. **Catalog** → 임의의 Component 선택
2. **Docs** 탭 클릭
3. 문서 파일 클릭
4. ✅ **에러 없이 문서가 표시되어야 함!**

---

## 🔒 보안 고려사항

### ✅ 장점
1. **사용자별 권한 관리**
   - 각 사용자가 자신의 GitHub 권한으로 접근
   - GitHub에서 접근 권한이 없는 리포지토리는 Backstage에서도 볼 수 없음

2. **토큰 공유 불필요**
   - Personal Access Token을 팀원과 공유할 필요 없음
   - 각자의 GitHub 계정으로 관리

3. **감사 추적**
   - GitHub 로그에 사용자별 접근 기록 남음

### ⚠️ 주의사항
1. **Private 리포지토리 접근**
   - GitHub 조직에서 사용자에게 리포지토리 접근 권한 부여 필요
   - Backstage는 GitHub 권한을 대체하지 않고 전달만 함

2. **첫 로그인 시 권한 승인 필요**
   - 기존 사용자도 재로그인 시 새 권한 승인 필요
   - "repo" 권한이 추가되었기 때문

---

## 🚀 기대 효과

### 자동 권한 처리
- 사용자가 GitHub 로그인만 하면 TechDocs가 자동으로 동작
- 별도의 안내 메시지나 설정 불필요

### 원활한 협업
- 팀원들이 각자의 GitHub 계정으로 로그인
- 자신이 접근 가능한 문서만 표시
- 권한이 없는 문서는 자동으로 숨김 (401 에러 대신)

### 유지보수 간소화
- Personal Access Token 만료 걱정 불필요
- 각 사용자의 GitHub 토큰이 자동 갱신됨

---

## 📋 체크리스트

- [x] `app-config.yaml` - GitHub OAuth scopes 추가 (`repo`, `read:org`)
- [ ] GitHub OAuth App - Repository permissions 업데이트
- [ ] Backstage 재시작
- [ ] GitHub 재로그인 (새 권한 승인)
- [ ] TechDocs 접근 테스트

---

## 🔍 트러블슈팅

### 여전히 401 에러 발생 시

1. **GitHub OAuth App 권한 확인**
   ```bash
   # GitHub OAuth App 설정 페이지에서:
   Repository permissions → Contents: Read-only ✓
   ```

2. **로그아웃 후 재로그인**
   - 브라우저 캐시 삭제 권장
   - 시크릿 모드로 테스트

3. **Backstage 로그 확인**
   ```bash
   # 백엔드 로그에서 GitHub API 호출 확인
   # "401" 또는 "Unauthorized" 키워드 검색
   ```

4. **GitHub Token 만료 확인**
   ```bash
   # .env 파일의 GITHUB_TOKEN 유효성 확인
   curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
   ```

### 특정 리포지토리만 안 보이는 경우

1. **GitHub Organization 접근 권한 확인**
   - Organization Settings → Member privileges
   - 사용자가 해당 리포지토리에 접근 권한이 있는지 확인

2. **OAuth App 조직 승인**
   - GitHub Organization Settings → Third-party access
   - "VNTG Backstage" OAuth App이 승인되어 있는지 확인

---

## ✅ 결론

**변경 전**: TechDocs 접근 시 항상 공용 토큰 사용 → 401 에러

**변경 후**: 로그인한 사용자의 GitHub OAuth 토큰 자동 사용 → 정상 동작

**사용자 경험**: 
- ❌ "권한이 없습니다" 안내 메시지 표시 → 사용자 혼란
- ✅ GitHub 로그인하면 자동으로 동작 → 매끄러운 경험

**다음 할 일**: GitHub OAuth App 권한 업데이트 후 재시작! 🚀

