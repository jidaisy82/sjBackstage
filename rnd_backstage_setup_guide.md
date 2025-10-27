# RND Backstage 설정 가이드

## 목차
1. [개요](#개요)
2. [시스템 요구사항](#시스템-요구사항)
3. [환경 변수 설정](#환경-변수-설정)
4. [인증 설정](#인증-설정)
5. [Docker 컨테이너화](#docker-컨테이너화)
6. [접속 및 로그인](#접속-및-로그인)
7. [로컬 개발 (선택)](#로컬-개발-선택)

---

## 개요

### Backstage 구성 요소

RND Backstage는 다음 필수 플러그인으로 구성됩니다:

**백엔드 플러그인:**
- `@backstage/backend-defaults` - 백엔드 기본 설정
- `@backstage/plugin-app-backend` - 앱 백엔드
- `@backstage/plugin-proxy-backend` - 프록시
- `@backstage/plugin-auth-backend` - 인증 (Google OAuth, GitHub OAuth)
- `@backstage/plugin-catalog-backend` - 카탈로그
- `@backstage/plugin-search-backend` - 검색
- `@backstage/plugin-scaffolder-backend` - Scaffolder
- `@backstage/plugin-techdocs-backend` - TechDocs
- `@backstage/plugin-kubernetes-backend` - Kubernetes
- `@backstage/plugin-notifications-backend` - 알림
- `@backstage/plugin-signals-backend` - 시그널
- `@backstage/plugin-permission-backend` - 권한

**커스텀 플러그인:**
- Tech Insights 커스텀 펙트 리트리버 (`plugins/tech-insights`)

---

## 시스템 요구사항

### Docker 컨테이너용 소프트웨어만 필요

| 소프트웨어 | 버전 | 용도 |
|-----------|------|------|
| **Docker** | 20+ | 컨테이너 런타임 |
| **Docker Compose** | 2.0+ | 멀티 컨테이너 관리 |
| **Git** | 2.0+ | 코드 다운로드 |

### 설치

#### macOS

```bash
# Docker 설치
brew install --cask docker

# 또는 Docker Desktop 설치
# https://www.docker.com/products/docker-desktop
```

#### Linux

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y docker.io docker-compose

# CentOS/RHEL
sudo yum install -y docker docker-compose

# 서비스 시작
sudo systemctl start docker
sudo systemctl enable docker

# 현재 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER
newgrp docker
```

---

## 환경 변수 설정

### Docker Compose에서 필요한 환경 변수

`.env` 파일을 생성합니다:

```bash
# Backend Secrets (랜덤 문자열 생성)
BACKEND_SECRET=<openssl rand -base64 32로 생성>
EXTERNAL_SECRET=<openssl rand -base64 32로 생성>

# PostgreSQL (컨테이너 내부 사용)
POSTGRES_PASSWORD=<openssl rand -base64 32로 생성>

# GitHub Integration Token
GITHUB_TOKEN=<GitHub-Personal-Access-Token>

# OAuth - Google
AUTH_GOOGLE_CLIENT_ID=<Google-OAuth-Client-ID>
AUTH_GOOGLE_CLIENT_SECRET=<Google-OAuth-Client-Secret>

# OAuth - GitHub
AUTH_GITHUB_CLIENT_ID=<GitHub-OAuth-Client-ID>
AUTH_GITHUB_CLIENT_SECRET=<GitHub-OAuth-Client-Secret>
```

### Secret 생성 스크립트

```bash
# .env 파일 자동 생성
cat > .env << EOF
# Backend Secrets
BACKEND_SECRET=$(openssl rand -base64 32)
EXTERNAL_SECRET=$(openssl rand -base64 32)

# PostgreSQL
POSTGRES_PASSWORD=$(openssl rand -base64 32)

# GitHub Integration (실제 값으로 교체 필요)
GITHUB_TOKEN=<your-github-token>

# OAuth - Google (실제 값으로 교체 필요)
AUTH_GOOGLE_CLIENT_ID=<your-client-id>
AUTH_GOOGLE_CLIENT_SECRET=<your-client-secret>

# OAuth - GitHub (실제 값으로 교체 필요)
AUTH_GITHUB_CLIENT_ID=<your-client-id>
AUTH_GITHUB_CLIENT_SECRET=<your-client-secret>
EOF

# 실제 값으로 교체
nano .env
```

---

## 인증 설정

### Google OAuth 설정

1. **Google Cloud Console 접속**
   - https://console.cloud.google.com/

2. **OAuth 2.0 클라이언트 ID 생성**
   - APIs & Services > Credentials
   - Create Credentials > OAuth client ID
   - Application type: Web application
   - Authorized redirect URIs: `http://localhost:7007/api/auth/google/handler/frame`

3. **환경 변수 설정**
   ```bash
   AUTH_GOOGLE_CLIENT_ID=<your-client-id>
   AUTH_GOOGLE_CLIENT_SECRET=<your-client-secret>
   ```

### GitHub OAuth 설정

1. **GitHub Developer Settings 접속**
   - https://github.com/settings/developers

2. **OAuth App 생성**
   - New OAuth App
   - Application name: Backstage Dev
   - Homepage URL: `http://localhost:3000`
   - Authorization callback URL: `http://localhost:7007/api/auth/github/handler/frame`

3. **환경 변수 설정**
   ```bash
   AUTH_GITHUB_CLIENT_ID=<your-client-id>
   AUTH_GITHUB_CLIENT_SECRET=<your-client-secret>
   ```

### GitHub Integration Token 설정

1. **Personal Access Token 생성**
   - GitHub Settings > Developer settings > Personal access tokens
   - Generate new token (classic)
   - Scopes: `repo`, `read:user`, `read:org`

2. **환경 변수 설정**
   ```bash
   GITHUB_TOKEN=<your-github-token>
   ```

---


## Docker 컨테이너화

### Docker Compose 파일 생성

#### `docker-compose.yml` 생성

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:17-bookworm
    container_name: rnd-backstage-postgres
    environment:
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: backstage
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - backstage-network

  backstage:
    build:
      context: .
      dockerfile: packages/backend/Dockerfile
    container_name: rnd-backstage-app
    ports:
      - "3000:3000"
      - "7007:7007"
    environment:
      - BACKEND_SECRET=${BACKEND_SECRET}
      - EXTERNAL_SECRET=${EXTERNAL_SECRET}
      - POSTGRES_HOST=postgres
      - POSTGRES_PORT=5432
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=backstage
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - AUTH_GOOGLE_CLIENT_ID=${AUTH_GOOGLE_CLIENT_ID}
      - AUTH_GOOGLE_CLIENT_SECRET=${AUTH_GOOGLE_CLIENT_SECRET}
      - AUTH_GITHUB_CLIENT_ID=${AUTH_GITHUB_CLIENT_ID}
      - AUTH_GITHUB_CLIENT_SECRET=${AUTH_GITHUB_CLIENT_SECRET}
      - NODE_ENV=production
      - NODE_OPTIONS=--no-node-snapshot
    depends_on:
      postgres:
        condition: service_healthy
    volumes:
      - ./app-config.yaml:/app/app-config.yaml:ro
      - ./app-config.production.yaml:/app/app-config.production.yaml:ro
    networks:
      - backstage-network
    restart: unless-stopped

volumes:
  postgres_data:
    driver: local

networks:
  backstage-network:
    driver: bridge
```

### Docker로 실행하는 전체 프로세스

#### Step 1: 프로젝트 준비

```bash
# 프로젝트 클론 또는 이동
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# Git 저장소가 필요한 경우
# git clone <repo-url> rnd-backstage
# cd rnd-backstage
```

#### Step 2: 환경 변수 설정

```bash
# .env 파일 생성 (환경 변수 섹션 참조)
cat > .env << EOF
BACKEND_SECRET=$(openssl rand -base64 32)
EXTERNAL_SECRET=$(openssl rand -base64 32)
POSTGRES_PASSWORD=$(openssl rand -base64 32)
GITHUB_TOKEN=<your-token>
AUTH_GOOGLE_CLIENT_ID=<your-client-id>
AUTH_GOOGLE_CLIENT_SECRET=<your-client-secret>
AUTH_GITHUB_CLIENT_ID=<your-client-id>
AUTH_GITHUB_CLIENT_SECRET=<your-client-secret>
EOF

# 실제 값으로 교체
nano .env
```

#### Step 3: Docker Compose 실행 (자동 빌드 포함)

```bash
# Docker Compose로 빌드 및 실행 (자동으로 이미지 빌드)
docker-compose up -d --build

# 로그 확인
docker-compose logs -f

# 상태 확인
docker-compose ps
```

#### Step 4: 접속 확인

```bash
# Backstage 접속 (30초~1분 대기 후)
open http://localhost:3000

# Health check
curl http://localhost:7007/api/healthcheck

# PostgreSQL 확인
docker-compose exec postgres psql -U postgres -d backstage -c "\dt"
```

### 컨테이너 관리

```bash
# 로그 확인
docker-compose logs -f backstage
docker-compose logs -f postgres

# 재시작
docker-compose restart

# 중지
docker-compose down

# 볼륨 포함 정리
docker-compose down -v

# 이미지 재빌드
docker-compose up -d --build
```

---

## 접속 및 로그인

### 첫 접속

1. **브라우저에서 접속**
   ```
   http://localhost:3000
   ```

2. **로그인 방법 선택**
   - Google 계정으로 로그인
   - GitHub 계정으로 로그인

### 로그인 프로세스

```
1. "Sign In" 클릭
2. OAuth provider 선택 (Google 또는 GitHub)
3. OAuth 인증 페이지로 리다이렉트
4. 인증 완료 후 Backstage로 복귀
5. 자동으로 Dashboard 표시
```

### 로그아웃

- 상단 오른쪽 아이콘 클릭 > "Sign Out"
- 또는 자동 로그아웃 (30분 유휴 후)

---

## 로컬 개발 (선택)

> **참고**: Docker만 사용하는 경우 이 섹션은 건너뛰세요.

로컬에서 개발하려면 다음 추가 소프트웨어가 필요합니다:

### 추가 설치

#### macOS

```bash
# Node.js 설치
brew install node@22

# Yarn 설치
brew install yarn

# PostgreSQL 설치
brew install postgresql@17
brew services start postgresql@17
```

#### Linux

```bash
# Node.js 설치 (nvm)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 22

# Yarn 설치
npm install -g yarn

# PostgreSQL 설치
sudo apt-get install postgresql-17
sudo systemctl start postgresql
```

### 로컬 실행

```bash
# 프로젝트 클론
git clone <repo-url> rnd-backstage
cd rnd-backstage

# 의존성 설치
yarn install

# TypeScript 컴파일
yarn tsc

# 환경 변수 설정 (.env 파일)
echo "BACKEND_SECRET=..." > .env
echo "POSTGRES_HOST=localhost" >> .env
# ... (나머지 환경 변수)

# 로컬 PostgreSQL 데이터베이스 생성
createdb backstage

# Backstage 시작
yarn start
```

### 접속

- **프론트엔드**: http://localhost:3000
- **백엔드**: http://localhost:7007

---

## 트러블슈팅

### Docker 컨테이너 시작 실패

```bash
# 로그 확인
docker-compose logs -f backstage

# PostgreSQL 로그 확인
docker-compose logs -f postgres

# 컨테이너 상태 확인
docker-compose ps

# 전체 재시작
docker-compose down
docker-compose up -d --build
```

### PostgreSQL 연결 실패

```bash
# 컨테이너 내부에서 PostgreSQL 접속 테스트
docker-compose exec postgres psql -U postgres -d backstage

# 네트워크 확인
docker-compose exec backstage ping postgres

# 환경 변수 확인
docker-compose exec backstage env | grep POSTGRES
```

### OAuth 로그인 실패

**가능한 원인:**
1. Client ID/Secret 잘못됨
2. Redirect URI 불일치
3. 환경 변수 누락

**해결:**
```bash
# .env 파일 확인
cat .env | grep AUTH

# 컨테이너 환경 변수 확인
docker-compose exec backstage env | grep AUTH

# .env 파일 수정 후 컨테이너 재시작
nano .env
docker-compose restart backstage
```

### 포트 충돌

```bash
# 포트 사용 확인
# macOS
lsof -i :3000
lsof -i :7007
lsof -i :5432

# Linux
sudo netstat -tulpn | grep -E ':(3000|7007|5432)'

# docker-compose.yml에서 포트 변경
nano docker-compose.yml
docker-compose up -d
```

---

## 구성 요소 요약

### Docker 컨테이너
- **Backstage App**: Node.js 22 기반
- **PostgreSQL**: 17 (컨테이너 내부)

### 네트워크 포트
- **프론트엔드**: http://localhost:3000
- **백엔드 API**: http://localhost:7007
- **PostgreSQL**: localhost:5432

### 인증
- **Google OAuth**: 로그인
- **GitHub OAuth**: 로그인
- **GitHub Integration**: 리포지토리 접근 (Personal Access Token)

### 데이터베이스
- **Database**: backstage (컨테이너 내부 자동 생성)
- **스키마**: Backstage가 자동 생성 (plugin_catalog, tech_insights 등)

---

## 빠른 시작 요약

### Docker로 Backstage 실행하기 (3단계)

```bash
# 1. Docker 설치 및 .env 파일 설정
docker --version
nano .env  # 환경 변수 입력

# 2. Docker Compose로 실행
docker-compose up -d --build

# 3. 접속
open http://localhost:3000
```

### 전체 프로세스 요약

```
1. Docker 설치 ✅
   ↓
2. 환경 변수 설정 (.env) ✅
   ↓
3. OAuth 인증 설정 (Google, GitHub) ✅
   ↓
4. docker-compose up -d --build ✅
   ↓
5. http://localhost:3000 접속 ✅
   ↓
6. OAuth 로그인 (Google/GitHub) ✅
```

### 필요한 것만 정리

**필수:**
- Docker + Docker Compose
- .env 파일 (Backend secrets, OAuth tokens)
- OAuth Client ID/Secret (Google, GitHub)

**선택:**
- 로컬 개발 환경 (Node.js, Yarn, PostgreSQL)
- 카탈로그, TechDocs, Templates

---

## 다음 단계

1. ✅ Backstage 기본 설정 완료
2. ⏳ 카탈로그 엔티티 추가 (필요시)
3. ⏳ Software Templates 구성 (필요시)
4. ⏳ TechDocs 설정 (필요시)
5. ⏳ Kubernetes 연동 (필요시)

---

## 참고 자료

- [Backstage 공식 문서](https://backstage.io/docs)
- [PostgreSQL 공식 문서](https://www.postgresql.org/docs/)
- [Docker Compose 문서](https://docs.docker.com/compose/)

---

## 작성 정보

**작성자**: Platform Team  
**작성일**: 2025-10-24  
**문서 버전**: 1.0  
**상태**: Complete (Docker-focused)

