# Backstage Docker 컨테이너화 계획

## 목차
1. [개요](#개요)
2. [현재 구성 분석](#현재-구성-분석)
3. [컨테이너화 아키텍처](#컨테이너화-아키텍처)
4. [파일 구조 설계](#파일-구조-설계)
5. [초기 설정 절차](#초기-설정-절차)
6. [Docker Compose 구성](#docker-compose-구성)
7. [데이터베이스 초기화](#데이터베이스-초기화)
8. [빌드 및 실행](#빌드-및-실행)
9. [운영 고려사항](#운영-고려사항)

---

## 개요

### 목표
RND Backstage를 Docker 컨테이너화하여:
- ✅ 일관된 개발 환경 제공
- ✅ 프로덕션 배포 자동화
- ✅ PostgreSQL 컨테이너화
- ✅ 초기 데이터베이스 스키마 자동 설정
- ✅ 환경 변수 기반 설정
- ✅ CI/CD 파이프라인 통합

### 현재 구성 분석

#### 1. 기술 스택
- **Backstage**: Node.js 20/22, Yarn 4.4.1
- **데이터베이스**: PostgreSQL (프로덕션)
- **인증**: Google OAuth, GitHub OAuth
- **통합**: GitHub Integration, Tech Insights, TechDocs

#### 2. 설정 파일
- `app-config.yaml` - 기본 설정
- `app-config.local.yaml` - 로컬 개발 오버라이드
- `app-config.production.yaml` - 프로덕션 설정

#### 3. 환경 변수
다음 환경 변수들이 필요합니다:
```bash
# Backend
BACKEND_SECRET=<random-string>
EXTERNAL_SECRET=<random-string>

# PostgreSQL
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage_user
POSTGRES_PASSWORD=<password>
POSTGRES_DB=backstage_plugin_catalog

# GitHub
GITHUB_TOKEN=<github-token>

# OAuth
GOOGLE_CLIENT_ID=<client-id>
GOOGLE_CLIENT_SECRET=<client-secret>
GOOGLE_CLIENT_BACKEND_SECRET=<backend-secret>
GITHUB_CLIENT_ID=<client-id>
GITHUB_CLIENT_SECRET=<client-secret>
```

---

## 컨테이너화 아키텍처

### 전체 아키텍처

```
┌─────────────────────────────────────────────────────────────────┐
│                    Docker Compose 네트워크                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────────┐         ┌──────────────┐                     │
│  │ PostgreSQL   │◄────────┤  Backstage   │                     │
│  │  Container   │         │  Container   │                     │
│  │              │         │              │                     │
│  │ Port: 5432   │         │ Port: 7007   │                     │
│  │              │         │              │                     │
│  └──────────────┘         └──────────────┘                     │
│         │                        │                              │
│         │                        │                              │
│         ▼                        ▼                              │
│  ┌────────────────────────────────────────────────┐            │
│  │         Persistent Volume                     │            │
│  │  - PostgreSQL Data                            │            │
│  │  - Backstage Config                           │            │
│  └────────────────────────────────────────────────┘            │
└─────────────────────────────────────────────────────────────────┘
```

### 컨테이너 구성 요소

#### 1. Backstage Container
- **기반 이미지**: node:22-bookworm-slim
- **포트**: 7007 (백엔드)
- **기능**: Backstage 백엔드 서버
- **볼륨**: 설정 파일, 데이터

#### 2. PostgreSQL Container
- **기반 이미지**: postgres:17-bookworm
- **포트**: 5432
- **기능**: 데이터베이스 서버
- **볼륨**: 데이터 영속성

#### 3. (선택) Nginx Container
- **기반 이미지**: nginx:alpine
- **포트**: 80, 443
- **기능**: 리버스 프록시, SSL 종료

---

## 파일 구조 설계

### 생성할 파일 목록

```
rnd-backstage/
├── docker/
│   ├── Dockerfile.backstage           # Backstage 이미지 빌드
│   ├── Dockerfile.production          # 프로덕션 멀티스테이지 빌드
│   └── docker-entrypoint.sh          # 컨테이너 시작 스크립트
│
├── docker-compose.yml                  # 개발 환경용
├── docker-compose.production.yml       # 프로덕션 환경용
│
├── .env.example                        # 환경 변수 예시
├── .env.docker                         # Docker용 환경 변수
│
└── init-db/
    ├── 01-create-databases.sql        # 데이터베이스 생성
    ├── 02-init-schema.sql              # 초기 스키마
    └── 03-seed-data.sql                # 시드 데이터 (선택)
```

---

## 초기 설정 절차

### Step 1: 환경 변수 파일 생성

#### `.env.docker` 파일 생성

```bash
# Backend Secrets
BACKEND_SECRET=$(openssl rand -base64 32)
EXTERNAL_SECRET=$(openssl rand -base64 32)

# PostgreSQL
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$(openssl rand -base64 32)
POSTGRES_DB=backstage  # 하나의 DB에 모든 플러그인 데이터 저장

# 참고: Backstage는 하나의 데이터베이스에 여러 스키마를 사용합니다
# - plugin_catalog: 카탈로그 데이터
# - tech_insights: Tech Insights 데이터  
# - plugin_scaffolder: Scaffolder 데이터
# 등등...

# GitHub Integration
GITHUB_TOKEN=<your-github-token>

# OAuth - Google
GOOGLE_CLIENT_ID=<your-google-client-id>
GOOGLE_CLIENT_SECRET=<your-google-client-secret>
GOOGLE_CLIENT_BACKEND_SECRET=$(openssl rand -base64 32)

# OAuth - GitHub
GITHUB_CLIENT_ID=<your-github-client-id>
GITHUB_CLIENT_SECRET=<your-github-client-secret>
```

#### `.env.example` 파일 생성

```bash
# .env.docker 파일을 복사하고 실제 값을 입력
cp .env.docker .env.example
# .env.example 파일을 열어 <placeholder> 값들을 실제 값으로 교체
```

### Step 2: Docker Compose 파일 생성

#### `docker-compose.yml` (개발 환경)

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:17-bookworm
    container_name: rnd-backstage-postgres
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    ports:
      - "${POSTGRES_PORT}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-db:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 5s
      timeout: 5s
      retries: 5
    networks:
      - backstage-network

  backstage:
    build:
      context: .
      dockerfile: docker/Dockerfile.backstage
    container_name: rnd-backstage-app
    ports:
      - "7007:7007"
    environment:
      # Backend
      - BACKEND_SECRET=${BACKEND_SECRET}
      - EXTERNAL_SECRET=${EXTERNAL_SECRET}
      
      # PostgreSQL
      - POSTGRES_HOST=postgres
      - POSTGRES_PORT=5432
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
      
      # GitHub
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      
      # OAuth - Google
      - GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
      - GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}
      - GOOGLE_CLIENT_BACKEND_SECRET=${GOOGLE_CLIENT_BACKEND_SECRET}
      
      # OAuth - GitHub
      - GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID}
      - GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET}
      
      # Node
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

#### `docker-compose.production.yml` (프로덕션)

```yaml
version: '3.8'

services:
  postgres:
    image: postgres:16-alpine
    container_name: rnd-backstage-postgres-prod
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./init-db:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - backstage-network
    restart: always

  backstage:
    build:
      context: .
      dockerfile: docker/Dockerfile.production
    container_name: rnd-backstage-app-prod
    environment:
      - BACKEND_SECRET=${BACKEND_SECRET}
      - EXTERNAL_SECRET=${EXTERNAL_SECRET}
      - POSTGRES_HOST=postgres
      - POSTGRES_PORT=5432
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}
      - GOOGLE_CLIENT_SECRET=${GOOGLE_CLIENT_SECRET}
      - GOOGLE_CLIENT_BACKEND_SECRET=${GOOGLE_CLIENT_BACKEND_SECRET}
      - GITHUB_CLIENT_ID=${GITHUB_CLIENT_ID}
      - GITHUB_CLIENT_SECRET=${GITHUB_CLIENT_SECRET}
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
    restart: always
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:7007/api/healthcheck"]
      interval: 30s
      timeout: 10s
      retries: 3

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/postgres

networks:
  backstage-network:
    driver: bridge
```

### Step 3: Dockerfile 생성

#### `docker/Dockerfile.backstage` (개발용)

```dockerfile
# Backstage Docker Image for Development
FROM node:22-bookworm-slim

# Set Python interpreter for node-gyp
ENV PYTHON=/usr/bin/python3

# Install dependencies for building native modules
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    g++ \
    build-essential \
    libsqlite3-dev \
    ca-certificates \
    curl && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Switch to non-root user
USER node

# Set Node environment
ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"

# Copy package files
COPY --chown=node:node .yarn ./.yarn
COPY --chown=node:node .yarnrc.yml backstage.json yarn.lock package.json ./

# Copy skeleton and install dependencies
COPY --chown=node:node packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

# Copy examples and backend bundle
COPY --chown=node:node examples ./examples
COPY --chown=node:node packages/backend/dist/bundle.tar.gz ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# Copy configuration files
COPY --chown=node:node app-config.yaml ./
COPY --chown=node:node app-config.production.yaml ./

# Expose port
EXPOSE 7007

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node packages/backend healthcheck || exit 1

# Start command
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
```

#### `docker/Dockerfile.production` (프로덕션용 멀티스테이지)

```dockerfile
# Stage 1: Builder
FROM node:22-bookworm AS builder

WORKDIR /app

# Install dependencies
COPY .yarn ./.yarn
COPY .yarnrc.yml backstage.json package.json yarn.lock ./
COPY packages/backend/package.json packages/backend/
COPY packages/app/package.json packages/app/

RUN yarn install --immutable

# Copy and build
COPY . .
RUN yarn tsc
RUN yarn build:backend
RUN yarn build:all

# Stage 2: Runtime
FROM node:22-bookworm-slim

ENV PYTHON=/usr/bin/python3
ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"

# Install runtime dependencies
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    python3 \
    g++ \
    build-essential \
    libsqlite3-dev \
    ca-certificates \
    curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
USER node

# Copy from builder
COPY --from=builder --chown=node:node /app/.yarn ./.yarn
COPY --from=builder --chown=node:node /app/.yarnrc.yml ./
COPY --from=builder --chown=node:node /app/backstage.json ./
COPY --from=builder --chown=node:node /app/yarn.lock package.json ./
COPY --from=builder --chown=node:node /app/packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

RUN --mount=type=cache,target=/home/node/.cache/yarn,sharing=locked,uid=1000,gid=1000 \
    yarn workspaces focus --all --production && rm -rf "$(yarn cache clean)"

COPY --from=builder --chown=node:node /app/examples ./examples
COPY --from=builder --chown=node:node /app/packages/backend/dist/bundle.tar.gz ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# Configuration files will be mounted as volumes
COPY --chown=node:node app-config.yaml ./
COPY --chown=node:node app-config.production.yaml ./

EXPOSE 7007

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:7007/api/healthcheck || exit 1

CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
```

---

## 데이터베이스 초기화

### Backstage의 데이터베이스 구조

중요: Backstage는 **하나의 PostgreSQL 데이터베이스**에 여러 스키마를 사용합니다. 별도의 데이터베이스를 만들 필요가 없습니다.

```
PostgreSQL Database: backstage
├── schema: plugin_catalog     # 카탈로그 플러그인 데이터
├── schema: tech_insights      # Tech Insights 데이터
├── schema: plugin_scaffolder  # Scaffolder 데이터
├── schema: plugin_auth       # 인증 플러그인 데이터
└── schema: plugin_permission # 권한 플러그인 데이터
```

**데이터베이스 이름 선택:**
- `backstage` ✅ (권장) - 모든 플러그인 데이터 포함
- `backstage_plugin_catalog` - 구버전 명명 관례
- 원하는 이름 사용 가능

**같은 데이터베이스를 사용하는 이유:**
1. 단순한 설정 관리
2. 단일 연결로 성능 최적화
3. 트랜잭션 일관성 유지
4. 백업/복원 용이

### PostgreSQL 초기화 스크립트

Backstage는 PostgreSQL 컨테이너가 시작될 때 `init-db` 디렉토리의 SQL 스크립트를 자동으로 실행합니다.

#### 1. 데이터베이스 생성 (`init-db/01-create-databases.sql`)

```sql
-- Create a single database for all Backstage plugins
-- This script runs automatically when PostgreSQL container starts for the first time

-- 하나의 데이터베이스만 생성 (환경변수 POSTGRES_DB로 지정된 이름)
-- PostgreSQL이 자동으로 생성하므로 명시적으로 CREATE DATABASE 불필요

-- 추가로 필요한 경우에만 생성
-- CREATE DATABASE backstage;

-- 스키마는 Backstage가 자동으로 생성합니다
-- - plugin_catalog (카탈로그)
-- - tech_insights (Tech Insights)
-- - plugin_scaffolder (Scaffolder)
-- 등등...

-- 권한 설정 (필요한 경우)
-- GRANT ALL PRIVILEGES ON DATABASE backstage TO postgres;
```

#### 2. 초기 스키마 (자동 생성)

Backstage가 시작되면 자동으로 다음 스키마를 생성합니다:
- `plugin_catalog` 스키마
- `tech_insights` 스키마 (Tech Insights 사용 시)

#### 3. 초기 데이터 설정 (선택)

`init-db/03-seed-data.sql`:

```sql
-- Optional: Insert initial data
-- INSERT INTO public.entities (...)

-- Note: Backstage catalog entities are usually managed through the app-config.yaml
-- or via API, not through direct SQL inserts
```

---

## 빌드 및 실행

### 개발 환경 실행 절차

#### 현재 방식: 미리 빌드된 코드를 이미지화 ⚙️

문서의 현재 구성은 **rnd-backstage 폴더를 로컬에서 먼저 빌드한 후, 빌드된 결과물을 Docker 이미지에 포함시키는 방식**입니다.

**장점:**
- ✅ 로컬 환경에서 빌드 디버깅 가능
- ✅ CI/CD 파이프라인과 통합 용이
- ✅ 멀티 플랫폼 빌드 간소화

**단점:**
- ❌ Docker 빌드 전에 로컬 빌드 필요
- ❌ 빌드 환경에 Docker 호스트와 일치해야 함

#### Step 1: 환경 변수 설정

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# .env.docker 파일 생성 및 수정
cp .env.example .env.docker
# .env.docker 파일을 열어 실제 값 입력
```

#### Step 2: Backstage 로컬 빌드

```bash
# 1. 의존성 설치
yarn install --immutable

# 2. TypeScript 컴파일
yarn tsc

# 3. 백엔드 빌드 (skeleton, bundle 생성)
yarn build:backend

# 4. (선택) 프론트엔드 빌드
yarn build:all
```

**빌드 결과물:**
- `packages/backend/dist/skeleton.tar.gz` - 백엔드 스켈레톤
- `packages/backend/dist/bundle.tar.gz` - 백엔드 번들

#### Step 3: Docker 이미지 빌드

```bash
# 현재 디렉토리를 Docker context로 사용
# 이미 빌드된 skeleton, bundle을 이미지에 복사

# BuildKit 사용 (권장)
DOCKER_BUILDKIT=1 docker build -t rnd-backstage:latest -f docker/Dockerfile.backstage .

# 또는 일반 빌드
docker build -t rnd-backstage:latest -f docker/Dockerfile.backstage .

# 기존 Backstage 제공 스크립트 사용
yarn build-image
```

**⚠️ 중요:**
Docker 빌드 전에 반드시 `yarn build:backend`를 실행해야 합니다!

#### Step 4: Docker Compose로 실행

```bash
# 모든 서비스 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f backstage
docker-compose logs -f postgres

# 상태 확인
docker-compose ps
```

#### Step 5: 접속 확인

```bash
# Backstage 접속
open http://localhost:7007

# Health check
curl http://localhost:7007/api/healthcheck

# PostgreSQL 확인
docker-compose exec postgres psql -U backstage_user -d backstage_plugin_catalog -c "\dt"
```

### 프로덕션 배포

#### 옵션 1: 현재 방식 (멀티스테이지 빌드) ✅ 권장

```bash
# 프로덕션 이미지 빌드 (Dockerfile.production 사용)
# 이 방식은 Docker 이미지 내에서 빌드를 수행합니다
docker build -t rnd-backstage:production -f docker/Dockerfile.production .

# 프로덕션 환경 실행
docker-compose -f docker-compose.production.yml up -d

# 로그 확인
docker-compose -f docker-compose.production.yml logs -f
```

**특징:**
- Docker 안에서 빌드 및 실행 (완전한 격리)
- 로컬 환경과 무관하게 동일한 이미지 생성
- CI/CD에 적합

#### 옵션 2: 기존 Backstage 방식

```bash
# 1. 로컬에서 빌드
yarn install --immutable
yarn tsc
yarn build:backend

# 2. 기존 Dockerfile 사용
docker build -t rnd-backstage:production -f packages/backend/Dockerfile .

# 3. 실행
docker run -p 7007:7007 rnd-backstage:production
```

**차이점 비교:**

| 방식 | 로컬 빌드 필요 | Docker 크기 | 빌드 시간 | 권장 용도 |
|------|---------------|------------|----------|----------|
| 현재 방식 (Step 2-3) | ✅ 필요 | 중간 | 빠름 | 개발 환경 |
| 멀티스테이지 | ❌ 불필요 | 작음 | 느림 | 프로덕션 |
| 기존 방식 | ✅ 필요 | 작음 | 빠름 | 간단한 배포 |

---

## 운영 고려사항

### 1. 데이터 영속성

#### 볼륨 마운트 전략

```yaml
volumes:
  postgres_data:
    # 프로덕션: 호스트 경로 지정
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /data/postgres/backstage
  
  # 백업 용이성을 위해 명시적 마운트
```

#### 데이터 백업

```bash
# PostgreSQL 백업
docker-compose exec postgres pg_dump -U backstage_user backstage_plugin_catalog > backup.sql

# 복원
docker-compose exec postgres psql -U backstage_user backstage_plugin_catalog < backup.sql
```

### 2. 보안 설정

#### SSL/TLS 구성

```yaml
# docker-compose.production.yml
services:
  backstage:
    environment:
      - SSL_ENABLED=true
      - SSL_KEY_PATH=/app/keys/private.key
      - SSL_CERT_PATH=/app/keys/certificate.crt
    volumes:
      - ./keys:/app/keys:ro
```

#### 환경 변수 보안

```bash
# Secrets 관리를 위한 외부 도구 사용
# Docker Swarm Secrets
docker secret create backend_secret ./secrets/backend_secret.txt

# 또는 Kubernetes Secrets
kubectl create secret generic backstage-secrets --from-env-file=.env.docker
```

### 3. 모니터링 및 로깅

#### 로그 수집

```bash
# 로그 확인
docker-compose logs -f --tail=100 backstage

# 로그 파일 저장
docker-compose logs > backstage-$(date +%Y%m%d).log

# JSON 로그 파싱
docker-compose logs --json | jq '.'
```

#### Health Check 설정

```yaml
healthcheck:
  test: ["CMD", "curl", "-f", "http://localhost:7007/api/healthcheck"]
  interval: 30s
  timeout: 10s
  retries: 3
  start_period: 40s
```

### 4. 성능 최적화

#### 리소스 제한

```yaml
services:
  backstage:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 2G
        reservations:
          cpus: '1.0'
          memory: 1G
```

#### PostgreSQL 튜닝

```bash
# postgresql.conf 커스터마이징
# docker-compose.yml
postgres:
  command:
    - "postgres"
    - "-c"
    - "shared_buffers=256MB"
    - "-c"
    - "max_connections=200"
```

### 5. 자동 재시작

```yaml
services:
  backstage:
    restart: always  # 또는 unless-stopped
  postgres:
    restart: always
```

---

## 트러블슈팅

### 1. 컨테이너 시작 실패

```bash
# 로그 확인
docker-compose logs backstage

# 컨테이너 상태 확인
docker-compose ps

# 재시작
docker-compose restart backstage
```

### 2. 데이터베이스 연결 실패

```bash
# PostgreSQL 접속 테스트
docker-compose exec postgres psql -U backstage_user -d backstage_plugin_catalog

# 환경 변수 확인
docker-compose config
```

### 3. 권한 문제

```bash
# 파일 권한 수정
chmod 755 docker-entrypoint.sh
chmod 644 app-config*.yaml

# 사용자 확인
docker-compose exec backstage whoami
# 출력: node (비root 사용자)
```

---

## 다음 단계

### 1. CI/CD 통합

```yaml
# .github/workflows/docker-build.yml
name: Build and Deploy Backstage
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Docker image
        run: docker build -t rnd-backstage .
      - name: Push to registry
        run: |
          docker tag rnd-backstage registry.example.com/backstage:latest
          docker push registry.example.com/backstage:latest
```

### 2. Kubernetes 배포

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backstage
spec:
  replicas: 2
  template:
    spec:
      containers:
      - name: backstage
        image: rnd-backstage:latest
        ports:
        - containerPort: 7007
```

### 3. 로드 밸런서 구성

```nginx
# nginx.conf
upstream backstage {
  server backstage:7007;
}

server {
  listen 80;
  server_name backstage.example.com;
  
  location / {
    proxy_pass http://backstage;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
  }
}
```

---

## 참고 자료

- [Backstage Docker Documentation](https://backstage.io/docs/deployment/docker)
- [PostgreSQL Docker Hub](https://hub.docker.com/_/postgres)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

---

## 작성 정보

**작성자**: Platform Team  
**작성일**: 2025-10-24  
**문서 버전**: 1.0  
**상태**: Planning Complete

**다음 단계:**
1. 환경 변수 파일 생성 및 설정
2. Dockerfile 및 Docker Compose 파일 생성
3. PostgreSQL 초기화 스크립트 작성
4. 빌드 및 테스트
5. 프로덕션 배포 검증


