# 새 Backstage 설치 가이드 (Docker 포함)

## 개요

이 가이드는 완전히 새로운 Backstage 프로젝트를 생성하고 Docker로 컨테이너화하는 과정을 설명합니다.

---

## 프로세스 개요

```
1. npx로 새 Backstage 생성
   ↓
2. PostgreSQL 선택 (새 컨테이너 / 기존 DB)
   ↓
3. rnd-backstage 설정 통합 (app-config.yaml)
   ↓
4. 필요한 패키지 설치
   ↓
5. app-config.yaml 수정 (catalog location, techinsights 제거)
   ↓
6. Docker 이미지 빌드
   ↓
7. 컨테이너 실행
```

---

## 자동 설치 스크립트

### 스크립트 실행 위치

**⚠️ 중요: 스크립트는 Backstage가 생성될 부모 폴더에서 실행합니다!**

```
예:
└── /path/to/your/work/          ← 여기서 스크립트 실행
    ├── setup-complete-backstage.sh
    └── my-backstage/            ← 여기에 Backstage 생성됨
        ├── app-config.yaml
        ├── docker-compose.yml
        └── packages/
```

### 사용 방법

#### Step 1: 작업 폴더 준비

```bash
# 원하는 위치에서 폴더 생성
mkdir -p /path/to/your/work
cd /path/to/your/work

# 스크립트 복사 (rnd-backstage 폴더에서)
cp /Users/seojiwon/VNTG_PROJECT/rnd-backstage/setup-complete-backstage.sh .
```

#### Step 2: 실행 권한 부여

```bash
chmod +x setup-complete-backstage.sh
```

#### Step 3: 스크립트 실행

```bash
bash setup-complete-backstage.sh
# 또는
./setup-complete-backstage.sh
```

#### Step 4: 질문에 답변

스크립트가 물어보는 항목:
1. **Backstage 설치 디렉토리 경로** - 예: `/path/to/your/work/backstage`
2. **rnd-backstage 경로** - 예: `/Users/seojiwon/VNTG_PROJECT/rnd-backstage`
3. **PostgreSQL 선택** (새 컨테이너 / 기존 DB)
4. **환경 변수** (GitHub Token, OAuth 등)
5. **app-config.yaml 수정** (Enter 대기)

#### Step 5: 결과 확인

스크립트가 생성하는 구조:
```
/work-folder/
└── <backstage-name>/          ← 생성된 Backstage 프로젝트
    ├── .env                   ← 환경 변수
    ├── Dockerfile             ← Docker 빌드 설정
    ├── docker-compose.yml     ← Docker Compose 설정
    ├── app-config.yaml        ← Backstage 설정
    └── packages/              ← Backstage 소스 코드
```

### 스크립트가 자동으로 처리하는 것

✅ **1. 새 Backstage 프로젝트 생성**
   - `npx @backstage/create-app@latest` 실행
   - PostgreSQL 옵션 포함

✅ **2. PostgreSQL 선택**
   - 옵션 1: 새 Docker 컨테이너 생성 (권장)
   - 옵션 2: 기존 PostgreSQL 사용

✅ **3. 환경 변수 수집**
   - GitHub Token
   - Google OAuth Client ID/Secret
   - GitHub OAuth Client ID/Secret
   - Backend Secrets (자동 생성)

✅ **4. rnd-backstage 설정 통합**
   - `app-config.yaml` 복사
   - `.env` 파일 생성
   - `docker-compose.yml` 생성
   - `Dockerfile` 생성

---

## PostgreSQL 선택

### 옵션 1: 새로운 Docker 컨테이너 (권장 ⭐)

**장점:**
- 독립적인 환경
- 쉽게 재생성 가능
- 개발 환경에 최적화

**사용 시:**
```yaml
# docker-compose.yml에 PostgreSQL 컨테이너 포함
services:
  postgres:
    image: postgres:17-bookworm
    # ...
```

### 옵션 2: 기존 PostgreSQL 사용

**장점:**
- 기존 데이터 활용
- 리소스 절약

**사용 시 입력 정보:**
```
PostgreSQL 호스트: localhost
PostgreSQL 포트: 5432
PostgreSQL 사용자명: postgres
PostgreSQL 비밀번호: [입력]
PostgreSQL 데이터베이스명: backstage
```

---

## rnd-backstage 설정 통합

### 자동 복사되는 파일

| 파일 | 설명 |
|------|------|
| `app-config.yaml` | 메인 설정 파일 (수정 필요) |
| `packages/backend/src/plugins/*` | 커스텀 플러그인 |
| `docker-compose.yml` | Docker Compose 설정 |
| `Dockerfile` | Docker 이미지 빌드 설정 |
| `.env` | 환경 변수 |

### 수동 수정이 필요한 파일

#### 1. app-config.yaml

**제거할 항목:**
- `catalog.locations` - 새 프로젝트용으로 조정
- `techInsights.*` - 새로 구성하므로 제거 권장

**예시:**
```yaml
# 기존 (rnd-backstage)
catalog:
  locations:
    - type: url
      target: https://github.com/org/repo/blob/main/catalog-info.yaml

# 신규 (수정 필요)
catalog:
  locations: []  # 또는 새로운 URL
```

#### 2. packages/backend/src/index.ts

**추가할 플러그인:**
rnd-backstage에서 사용하는 커스텀 플러그인을 추가하세요.

```typescript
// Tech Insights 플러그인 (예시)
backend.add(import('./plugins/tech-insights'));
```

---

## Docker 빌드 및 실행

### Step 1: 의존성 설치 및 빌드

```bash
cd <backstage-project>

# 의존성 설치
yarn install

# Backend 빌드
yarn build:backend
```

### Step 2: Docker 이미지 빌드 및 실행

#### PostgreSQL 컨테이너 포함 (권장)

```bash
# 빌드 및 실행
docker-compose up -d --build

# 로그 확인
docker-compose logs -f
```

#### 기존 PostgreSQL 사용

```bash
# Backstage만 실행
docker-compose up -d --build
```

### Step 3: 접속

```
Frontend: http://localhost:3000
Backend: http://localhost:7007
```

---

## 데이터베이스 초기화

### 첫 실행 시 자동 초기화

Backstage가 처음 실행되면 다음과 같이 자동 초기화됩니다:

```sql
-- 자동 생성되는 스키마
- plugin_catalog     (카탈로그 데이터)
- plugin_scaffolder  (Scaffolder 데이터)
- plugin_auth        (인증 데이터)
- plugin_permission  (권한 데이터)
- plugin_search      (검색 데이터)
```

**주의:** 
- 데이터베이스는 생성되지 않습니다 (PostgreSQL 컨테이너가 생성하거나 수동 생성 필요)
- 테이블/스키마는 첫 실행 시 자동 생성

---

## 수동 설치 가이드

### Step 1: Backstage 생성

```bash
npx @backstage/create-app@latest
```

### Step 2: PostgreSQL 설정

#### Option A: Docker 컨테이너

```bash
docker run -d \
  --name backstage-postgres \
  -e POSTGRES_PASSWORD=your-password \
  -e POSTGRES_DB=backstage \
  -p 5432:5432 \
  postgres:17-bookworm
```

#### Option B: 기존 PostgreSQL

```bash
# 데이터베이스 생성
createdb -U postgres backstage
```

### Step 3: app-config.yaml 수정

```yaml
backend:
  database:
    client: pg
    connection:
      host: ${POSTGRES_HOST}
      port: ${POSTGRES_PORT}
      user: ${POSTGRES_USER}
      password: ${POSTGRES_PASSWORD}
      database: ${POSTGRES_DB}
```

### Step 4: 환경 변수 설정

`.env` 파일 생성:

```bash
BACKEND_SECRET=$(openssl rand -base64 32)
EXTERNAL_SECRET=$(openssl rand -base64 32)
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-password
POSTGRES_DB=backstage
```

### Step 5: Docker 빌드 및 실행

```bash
docker-compose up -d --build
```

---

## 트러블슈팅

### 문제: Docker 빌드 실패

**해결:**
```bash
# 의존성 다시 설치
yarn install

# 빌드 다시 시도
yarn build:backend
```

### 문제: PostgreSQL 연결 실패

**확인:**
```bash
# PostgreSQL 실행 중인지 확인
docker ps | grep postgres

# 연결 테스트
psql -h localhost -U postgres -d backstage
```

### 문제: 포트 충돌

**해결:**
```bash
# 사용 중인 포트 확인
lsof -i :3000
lsof -i :7007
lsof -i :5432

# docker-compose.yml에서 포트 변경
```

---

## 요약

1. ✅ `npx @backstage/create-app` - 새 Backstage 생성
2. ✅ PostgreSQL 선택 (새 컨테이너 / 기존 DB)
3. ✅ rnd-backstage 설정 통합
4. ✅ app-config.yaml 수정
5. ✅ `yarn install && yarn build:backend`
6. ✅ `docker-compose up -d --build`
7. ✅ http://localhost:3000 접속

**그러면 컨테이너화 완료!**

---

## Docker 이미지 공유하기

### 현재 상태

현재 설정으로는 **Docker 이미지를 직접 공유할 수 없습니다.**

이유:
- `docker-compose up -d --build`는 로컬에서만 빌드
- 이미지는 Docker Hub나 Registry에 업로드되지 않음

### 공유 방법

#### 방법 1: Dockerfile 공유 (권장) ⭐

각 개발자가 로컬에서 빌드합니다.

**개발자 1 (이미지 빌드한 사람):**
```bash
# 소스 코드만 Git에 push
git add .
git commit -m "Add Backstage Docker setup"
git push
```

**개발자 2 (이미지를 받는 사람):**
```bash
# 소스 코드 클론
git clone <repo-url>
cd <backstage-project>

# 로컬에서 빌드
docker-compose up -d --build
```

**장점:**
- Git으로 관리 가능
- 각자 환경에 맞게 빌드
- 실제 코드 변경 가능

#### 방법 2: Docker Registry 사용

이미지를 Docker Hub, ECR 등에 업로드합니다.

```bash
# 1. 이미지 태깅
docker tag backstage-app:latest <registry>/backstage-app:1.0.0

# 2. Registry에 업로드
docker push <registry>/backstage-app:1.0.0

# 3. 다른 개발자들이 다운로드
docker pull <registry>/backstage-app:1.0.0
```

**Docker Hub 예시:**
```bash
# 이미지 빌드
docker-compose build

# 태깅
docker tag backstage-app yourusername/backstage-app:latest

# 업로드
docker push yourusername/backstage-app:latest

# 다른 개발자가 다운로드
docker pull yourusername/backstage-app:latest
```

**docker-compose.yml 수정 필요:**
```yaml
services:
  backstage:
    # build 대신 image 사용
    image: yourusername/backstage-app:latest
    # build:
    #   context: .
    #   dockerfile: Dockerfile
```

**장점:**
- 빠른 배포 (빌드 불필요)
- 동일한 이미지 사용

**단점:**
- 소스 코드 변경 시마다 재업로드 필요
- Registry 비용 발생 가능

---

## 개발팀 공유 방법 추천

### 시나리오별 추천

| 시나리오 | 추천 방법 | 이유 |
|---------|-----------|------|
| 소스 코드 변경이 많은 경우 | **Dockerfile 공유 (Git)** | 각자 빌드하여 최신 코드 반영 |
| 안정 버전 배포 | **Docker Registry** | 동일한 이미지로 테스트/배포 |
| 개발 환경 통일 | **Docker Compose + Git** | 설정 통일, 각자 빌드 |
| 빠른 배포 필요 | **Pre-built 이미지** | Registry에서 즉시 pull |

### 실무 추천 워크플로우

```
개발 환경:
├── 소스 코드: Git으로 공유 ⭐
├── Dockerfile: Git으로 공유 ⭐
└── docker-compose.yml: Git으로 공유 ⭐

배포 환경:
├── 빌드: CI/CD에서 자동 빌드
├── 이미지: Docker Registry에 업로드
└── 실행: Registry에서 pull
```

**즉, Dockerfile을 공유하면 충분합니다!** ✅

다른 개발자는:
1. Git clone
2. `docker-compose up -d --build`
3. 끝!

