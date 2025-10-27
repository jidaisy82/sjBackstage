# 기존 rnd-backstage 확인하는 이유

## 왜 기존 rnd-backstage 경로를 확인하나요?

스크립트에서 기존 rnd-backstage를 확인하는 이유는 **설정 파일과 커스터마이징된 내용을 재사용**하기 위해서입니다.

---

## 확인하는 주요 이유

### 1. app-config.yaml 설정 복사 ⭐

새 Backstage에는 기본 설정만 있습니다. 기존 rnd-backstage의 설정을 재사용하려면 복사해야 합니다.

**기존 rnd-backstage의 app-config.yaml에 포함된 내용:**
```yaml
# OAuth 설정 (Google, GitHub)
auth:
  providers:
    google:
      development:
        clientId: ${AUTH_GOOGLE_CLIENT_ID}
        clientSecret: ${AUTH_GOOGLE_CLIENT_SECRET}

# 카탈로그 설정
catalog:
  locations:
    - type: url
      target: ...

# Tech Insights 설정
techInsights:
  factRetrievers: ...

# 그리고 많은 커스터마이징 설정
```

**다음 파일 복사:**
```bash
# rnd-backstage의 app-config.yaml 복사
cp "$RND_BACKSTAGE_DIR/app-config.yaml" "$BACKSTAGE_DIR/app-config.yaml"
```

### 2. 커스텀 플러그인 및 설정

기존 rnd-backstage에는 이미 구성된 플러그인과 설정이 있습니다.

**예시:**
- Tech Insights 플러그인 설정
- 커스텀 backend 플러그인 (`packages/backend/src/plugins/`)
- OAuth 설정
- 인증 설정

### 3. 자동 설정 통합

수동 설정 대신 자동으로 통합할 수 있습니다.

**사용자가 원했던 것:**
> "rnd-backstage/app-config.yaml에 있는 정보를 참고해서 초기에 세팅할 수 있도록 지원"

**스크립트가 하는 것:**
1. rnd-backstage 경로 입력 받기
2. app-config.yaml 복사
3. 필요한 플러그인 설정 통합
4. Docker 설정 생성

---

## 실제 사용 예시

### Step 1: 새 Backstage 생성
```bash
npx @backstage/create-app@latest
# → 기본 설정만 있음
```

### Step 2: 기존 설정 확인 및 복사
```bash
# rnd-backstage 경로 입력
입력: /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# 스크립트가 자동으로:
cp /Users/seojiwon/.../rnd-backstage/app-config.yaml 
   → /새백스테이지/app-config.yaml
```

### Step 3: 수정 필수
사용자는 이 파일을 수정해야 합니다:
- `catalog.locations` 조정
- `techInsights` 제거 또는 조정

### Step 4: 결과
```
새 Backstage
  ├── app-config.yaml          ← rnd-backstage에서 복사
  ├── docker-compose.yml        ← 스크립트가 생성
  ├── Dockerfile                ← 스크립트가 생성
  └── .env                      ← 환경 변수
```

---

## 요약

### ✅ 확인하는 이유
1. **app-config.yaml 재사용** - OAuth, 인증, 설정 등
2. **커스터마이징 설정 통합** - 기존 설정 그대로 사용
3. **자동 설정** - 수동 작업 최소화

### ❌ 확인하지 않으면
- 수동으로 모든 설정을 다시 해야 함
- OAuth, 인증, 플러그인 설정을 일일이 입력해야 함
- 실수 가능성 증가

**즉, 기존 rnd-backstage는 "설정 템플릿" 역할을 합니다!** 🎯

