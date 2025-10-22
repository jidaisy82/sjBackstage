# Multi-Provider OAuth 충돌 해결

## 🚨 문제: Email 충돌

### 발생 상황
```
사용자 A:
  Google 계정: alice@example.com
  GitHub 계정: alice@example.com (같은 이메일!)
  
로그인 시도:
  1. Google로 로그인 → alice@example.com으로 User entity 매칭
  2. GitHub로 로그인 → alice@example.com으로 User entity 매칭
  ⚠️ 같은 User entity를 여러 provider가 사용 → 충돌!
```

### 원인
```yaml
# app-config.yaml
google:
  signIn:
    resolvers:
      - resolver: emailMatchingUserEntityProfileEmail  # ← email 사용
      
github:
  signIn:
    resolvers:
      - resolver: emailMatchingUserEntityProfileEmail  # ← email 사용 (충돌!)
```

---

## ✅ 해결 방법 1: Provider별 식별자 분리 (권장)

### 전략
- **Google**: Email로 User entity 매칭
- **GitHub**: Username으로 User entity 매칭

### 설정
```yaml
auth:
  providers:
    google:
      development:
        signIn:
          resolvers:
            # Google은 email 매칭 사용
            - resolver: emailMatchingUserEntityAnnotation
            - resolver: emailMatchingUserEntityProfileEmail
    
    github:
      development:
        signIn:
          resolvers:
            # GitHub는 username 매칭만 사용 (email 충돌 방지)
            - resolver: usernameMatchingUserEntityName
```

### User Entity 예시
```yaml
# examples/org.yaml

# Google 로그인용 User (email 기반)
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: alice  # 임의의 name
  annotations:
    google.com/email: alice@example.com  # Google email
spec:
  profile:
    email: alice@example.com
    displayName: Alice (Google)
  memberOf: [frontend-team]

# GitHub 로그인용 User (username 기반)
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: alice-github  # GitHub username
spec:
  profile:
    email: alice@example.com  # 같은 email이어도 OK (username으로 구분)
    displayName: Alice (GitHub)
  memberOf: [backend-team]
```

---

## ✅ 해결 방법 2: 단일 User Entity + Annotation 사용

### 전략
한 명의 실제 사용자가 **하나의 User entity**를 가지되, **여러 provider annotation** 사용

### 설정
```yaml
auth:
  providers:
    google:
      development:
        signIn:
          resolvers:
            # Google email annotation 확인
            - resolver: emailMatchingUserEntityAnnotation
    
    github:
      development:
        signIn:
          resolvers:
            # GitHub username annotation 확인
            - resolver: usernameMatchingUserEntityAnnotation  # 커스텀 필요
            # 또는 username 직접 매칭
            - resolver: usernameMatchingUserEntityName
```

### User Entity 예시
```yaml
# examples/org.yaml
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: alice
  annotations:
    # Google 로그인용
    google.com/email: alice@example.com
    # GitHub 로그인용
    github.com/username: alice-github
spec:
  profile:
    email: alice@example.com
    displayName: Alice
  memberOf: [platform-team]
```

---

## ✅ 해결 방법 3: 하나의 Provider만 사용 (가장 간단)

### 전략
팀에서 **주로 사용하는 하나의 OAuth provider만** 활성화

### Google만 사용
```yaml
auth:
  providers:
    google:
      development:
        # ... 설정 ...
    # github:
    #   development:
    #     # 비활성화
```

### GitHub만 사용
```yaml
auth:
  providers:
    # google:
    #   development:
    #     # 비활성화
    github:
      development:
        # ... 설정 ...
```

---

## 📊 방법 비교

| 방법 | 장점 | 단점 | 추천 |
|------|------|------|------|
| 1. Provider별 분리 | 충돌 없음, 명확함 | User entity가 많아짐 | ⭐⭐⭐ 권장 |
| 2. 단일 Entity + Annotation | 중복 없음, 깔끔함 | 설정 복잡함 | ⭐⭐ |
| 3. 단일 Provider | 가장 간단함 | 유연성 낮음 | ⭐ 소규모 팀 |

---

## 🎯 현재 적용된 해결책: 방법 1

### Google
```yaml
google:
  signIn:
    resolvers:
      - resolver: emailMatchingUserEntityAnnotation
      - resolver: emailMatchingUserEntityProfileEmail
```
→ **Email로 User entity 찾기**

### GitHub
```yaml
github:
  signIn:
    resolvers:
      - resolver: usernameMatchingUserEntityName  # ← username만 사용!
```
→ **GitHub username으로 User entity 찾기**

---

## 📋 사용자 등록 가이드

### Google 로그인용 사용자
```yaml
# examples/org.yaml
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: jidaisy
  annotations:
    google.com/email: jidaisy@example.com
spec:
  profile:
    email: jidaisy@example.com
    displayName: Jiwon Seo
  memberOf: [platform-team, backend-team]
```

**로그인 방법**: Google OAuth → `jidaisy@example.com` 이메일 사용

### GitHub 로그인용 사용자
```yaml
# examples/org.yaml
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: jidaisy  # ← GitHub username과 정확히 일치!
spec:
  profile:
    email: jidaisy@github-email.com
    displayName: Jiwon Seo (GitHub)
  memberOf: [platform-team, backend-team]
```

**로그인 방법**: GitHub OAuth → `jidaisy` username 사용

---

## 🧪 테스트 시나리오

### 시나리오 1: 같은 이메일, 다른 Provider
```
User A:
  Google: alice@example.com
  GitHub: alice-dev (username)
  
examples/org.yaml:
  User entity 1: name=alice (Google email용)
  User entity 2: name=alice-dev (GitHub username용)

테스트:
  ✅ Google 로그인 → alice entity로 로그인
  ✅ GitHub 로그인 → alice-dev entity로 로그인
  ✅ 충돌 없음!
```

### 시나리오 2: 다른 이메일, 다른 Provider
```
User B:
  Google: bob@company.com
  GitHub: bob-github (username)
  
examples/org.yaml:
  User entity 1: name=bob (Google email용)
  User entity 2: name=bob-github (GitHub username용)

테스트:
  ✅ Google 로그인 → bob entity로 로그인
  ✅ GitHub 로그인 → bob-github entity로 로그인
  ✅ 충돌 없음!
```

---

## 🔍 Resolver 동작 이해

### emailMatchingUserEntityProfileEmail
```yaml
# User entity
metadata:
  name: alice
spec:
  profile:
    email: alice@example.com  # ← 이 email과 OAuth email 비교
```

**동작:**
1. OAuth에서 email 가져옴: `alice@example.com`
2. 모든 User entity의 `spec.profile.email` 검색
3. 일치하는 entity 찾으면 로그인

### usernameMatchingUserEntityName
```yaml
# User entity
metadata:
  name: alice-github  # ← 이 name과 OAuth username 비교
spec:
  profile:
    # email은 사용 안 함
```

**동작:**
1. OAuth에서 username 가져옴: `alice-github`
2. 모든 User entity의 `metadata.name` 검색
3. 일치하는 entity 찾으면 로그인

---

## ⚠️ 주의사항

### Google + GitHub 동시 사용 시
1. **이메일 충돌 주의**
   - Google은 email resolver 사용
   - GitHub는 username resolver만 사용 (email 제거)

2. **User entity 이름 규칙**
   - Google용: 자유롭게 (email로 찾음)
   - GitHub용: **GitHub username과 정확히 일치**해야 함

3. **한 사람이 두 provider 사용 가능**
   ```yaml
   # 같은 사람이 Google과 GitHub 둘 다 사용
   ---
   apiVersion: backstage.io/v1alpha1
   kind: User
   metadata:
     name: alice  # Google용
     annotations:
       google.com/email: alice@example.com
   spec:
     profile:
       email: alice@example.com
     memberOf: [platform-team]
   ---
   apiVersion: backstage.io/v1alpha1
   kind: User
   metadata:
     name: alice-github  # GitHub용
   spec:
     profile:
       email: alice@example.com
     memberOf: [platform-team]
   ```

---

## 🚨 문제 해결

### Q1: GitHub 로그인 시 "User not found"
**원인**: GitHub username과 User entity name이 불일치
**해결**:
```yaml
# examples/org.yaml
metadata:
  name: exact-github-username  # ← GitHub username 정확히 입력!
```

### Q2: Google 로그인 시 "User not found"
**원인**: User entity의 email이 Google email과 불일치
**해결**:
```yaml
# examples/org.yaml
spec:
  profile:
    email: exact-google-email@example.com  # ← Google email 정확히 입력!
```

### Q3: 같은 사람이 Google/GitHub 둘 다 쓰고 싶음
**해결**: User entity 2개 생성 (위 예시 참조)

---

## 📚 참고 문서

- [Backstage Sign-in Resolvers](https://backstage.io/docs/auth/identity-resolver)
- [Google Auth Provider](https://backstage.io/docs/auth/google/provider)
- [GitHub Auth Provider](https://backstage.io/docs/auth/github/provider)

---

## 🎯 권장 설정 (요약)

### 팀 규모에 따른 권장 사항

#### 소규모 팀 (5명 이하)
→ **단일 Provider** (Google 또는 GitHub 하나만)

#### 중규모 팀 (5-20명)
→ **Provider별 분리** (현재 적용된 방법)
- Google: email 매칭
- GitHub: username 매칭

#### 대규모 팀 (20명 이상)
→ **커스텀 Sign-in Resolver** 구현
- 조직 SSO 연동
- LDAP/AD 통합

---

**생성 날짜**: 2025-10-21  
**적용 방법**: Provider별 식별자 분리 (방법 1)  
**상태**: ✅ Email 충돌 해결 완료

