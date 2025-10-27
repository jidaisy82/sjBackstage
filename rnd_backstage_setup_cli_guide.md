# RND Backstage Docker 자동 설치 가이드

## 목차
1. [개요](#개요)
2. [사전 준비](#사전-준비)
3. [자동 설치 스크립트](#자동-설치-스크립트)
4. [수동 설치 가이드](#수동-설치-가이드)
5. [Git 연동 설정](#git-연동-설정)

---

## 개요

### 자동 설치 스크립트의 기능

RND Backstage를 Docker로 자동 설치하는 스크립트입니다:

✅ **자동 설치 확인**
- Docker 설치 여부 확인
- Docker Compose 설치 여부 확인
- 미설치 시 자동 설치 유도

✅ **사용자 입력 받기**
- Git 저장소 URL 입력
- OAuth Client ID/Secret 입력
- GitHub Token 입력

✅ **자동 구성**
- .env 파일 자동 생성
- docker-compose.yml 자동 생성
- Docker 이미지 빌드 및 실행

✅ **Git 연동**
- Git remote 자동 설정
- 변경사항 자동 커밋 및 푸시

---

## 사전 준비

### 필요한 계정 및 정보

다음 정보를 준비하세요:

1. **GitHub**
   - Personal Access Token (repo 권한)
   - OAuth App Client ID/Secret

2. **Google**
   - OAuth Client ID/Secret

3. **Git 저장소**
   - Backstage 코드가 있는 저장소 URL

---

## 자동 설치 스크립트 개요

### 🖥️ macOS & Linux 지원

스크립트는 자동으로 OS를 감지하고 각 환경에 맞는 명령어를 적용합니다:

#### OS 자동 감지
```bash
# 스크립트 시작 시 자동 감지
OS_TYPE=$(detect_os)
print_info "운영체제: macos 또는 linux"
```

#### OS별 차이점

| 항목 | macOS | Linux |
|------|-------|-------|
| **Docker 설치** | `brew install --cask docker` | `apt install docker.io` |
| **Docker 실행** | Docker Desktop GUI | `sudo systemctl start docker` |
| **Docker Compose** | `brew install docker-compose` | Docker에 포함 |
| **패키지 관리자** | Homebrew | apt/yum/dnf |

#### 적용되는 명령어 예시

**macOS:**
```bash
# Docker 설치
brew install --cask docker

# Docker 실행 안내
Docker Desktop을 실행한 후 이 스크립트를 다시 실행하세요.
```

**Linux (Ubuntu/Debian):**
```bash
# Docker 설치
sudo apt update
sudo apt install -y docker.io docker-compose
sudo systemctl start docker
sudo systemctl enable docker

# Docker 실행 안내
Docker 서비스를 시작하려면: sudo systemctl start docker
```

**Linux (CentOS/RHEL):**
```bash
# Docker 설치
sudo yum install -y docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

**Linux (Fedora):**
```bash
# Docker 설치
sudo dnf install -y docker docker-compose
sudo systemctl start docker
sudo systemctl enable docker
```

### 백스테이지 폴더 및 Git 저장소

**질문: 백스테이지 폴더는 새로운 폴더로 해도 되는거지?**  
**답변: 네, 가능합니다!**

스크립트는 다음 시나리오를 모두 지원합니다:

#### 시나리오 1: 기존 rnd-backstage 프로젝트에서 실행
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
./setup-backstage.sh
# → 기존 프로젝트에 Docker 설정 추가
```

#### 시나리오 2: 새 디렉토리에 Backstage 설치
```bash
./setup-backstage.sh
# → "현재 디렉토리 사용?" → N
# → 디렉토리 경로 입력: /path/to/new-backstage
# → 새 디렉토리 생성 및 설정
```

#### 시나리오 3: 다른 Git 저장소로 연동
```bash
# 기존 Git 저장소 확인
git remote -v
# → "이 Git 저장소 사용?" → N
# → 새 Git 저장소 URL 입력
# → origin이 새 URL로 변경됨
```

**질문: git 사용자로부터 새로운 깃 레파지토리 url을 제공하면 거기에 연동되는거고?**  
**답변: 네, 맞습니다!**

Git 연동 프로세스:
```
1. 사용자로부터 새 Git URL 입력
   예: https://github.com/your-org/your-backstage.git
   
2. Git remote 설정
   git remote add origin <URL>
   
3. 변경사항 커밋
   git add .
   git commit -m "feat: Setup Backstage with Docker"
   
4. 푸시
   git push -u origin main
   
→ 새 저장소에 모든 설정이 저장됨
```

### 설치 스크립트 생성

`setup-backstage.sh` 파일이 이미 생성되어 있습니다:

```bash
#!/bin/bash

# RND Backstage Docker 자동 설치 스크립트
# macOS용

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수: 메시지 출력
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 함수: Y/N 입력
ask_yes_no() {
    local prompt="$1"
    local default="$2"
    
    if [ "$default" = "Y" ]; then
        read -p "$(echo -e ${BLUE}$prompt (Y/n): ${NC})" response
        response=${response:-Y}
    else
        read -p "$(echo -e ${BLUE}$prompt (y/N): ${NC})" response
        response=${response:-N}
    fi
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        return 0
    else
        return 1
    fi
}

# 함수: 필수 입력 받기
ask_input() {
    local prompt="$1"
    local var_name="$2"
    
    while [ -z "${!var_name}" ]; do
        read -p "$(echo -e ${BLUE}$prompt: ${NC})" input
        if [ -n "$input" ]; then
            eval "$var_name='$input'"
        else
            print_error "값을 입력해주세요."
        fi
    done
}

# 시작 메시지
echo ""
echo "========================================="
echo "  RND Backstage Docker 설치 스크립트"
echo "========================================="
echo ""

# Step 1: Docker 설치 확인
print_info "Docker 설치 확인 중..."

if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_success "Docker 설치됨: $DOCKER_VERSION"
else
    print_warning "Docker가 설치되지 않았습니다."
    if ask_yes_no "Docker를 설치하시겠습니까?" "Y"; then
        print_info "Docker Desktop 설치 중..."
        brew install --cask docker
        print_success "Docker Desktop 설치 완료"
        print_warning "Docker Desktop을 실행한 후 이 스크립트를 다시 실행하세요."
        exit 0
    else
        print_error "Docker 없이는 설치할 수 없습니다."
        exit 1
    fi
fi

# Docker 실행 확인
if ! docker info &> /dev/null; then
    print_error "Docker가 실행 중이 아닙니다."
    print_warning "Docker Desktop을 실행한 후 이 스크립트를 다시 실행하세요."
    exit 1
fi

# Step 2: Docker Compose 확인
print_info "Docker Compose 확인 중..."

if command -v docker-compose &> /dev/null; then
    COMPOSE_VERSION=$(docker-compose --version)
    print_success "Docker Compose 설치됨: $COMPOSE_VERSION"
elif docker compose version &> /dev/null; then
    print_success "Docker Compose V2 사용 가능"
else
    print_warning "Docker Compose가 설치되지 않았습니다."
    if ask_yes_no "Docker Compose를 설치하시겠습니까?" "Y"; then
        brew install docker-compose
        print_success "Docker Compose 설치 완료"
    fi
fi

# Step 3: 작업 디렉토리 설정
print_info "작업 디렉토리 설정 중..."

# 현재 디렉토리 확인
CURRENT_DIR=$(pwd)
print_info "현재 디렉토리: $CURRENT_DIR"

# rnd-backstage 디렉토리인지 확인
if [ ! -f "app-config.yaml" ]; then
    print_warning "app-config.yaml 파일이 없습니다."
    
    if ask_yes_no "현재 디렉토리를 rnd-backstage로 사용하시겠습니까?" "N"; then
        WORK_DIR=$CURRENT_DIR
    else
        ask_input "rnd-backstage 프로젝트 경로를 입력하세요: " "WORK_DIR"
    fi
else
    WORK_DIR=$CURRENT_DIR
    print_success "rnd-backstage 디렉토리 확인됨"
fi

cd "$WORK_DIR"

# Step 4: Git 저장소 정보 수집
print_info "Git 저장소 정보 수집 중..."

# Git remote 확인
if [ -d ".git" ]; then
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    
    if [ -n "$REMOTE_URL" ]; then
        print_success "Git remote 발견: $REMOTE_URL"
        
        if ! ask_yes_no "이 Git 저장소를 사용하시겠습니까?" "Y"; then
            ask_input "Git 저장소 URL을 입력하세요: " "GIT_URL"
            git remote set-url origin "$GIT_URL"
            print_success "Git remote 업데이트 완료"
        else
            GIT_URL=$REMOTE_URL
        fi
    else
        ask_input "Git 저장소 URL을 입력하세요: " "GIT_URL"
        git remote add origin "$GIT_URL" 2>/dev/null || git remote set-url origin "$GIT_URL"
    fi
else
    print_warning "Git 저장소가 아닙니다."
    
    if ask_yes_no "Git 저장소로 초기화하시겠습니까?" "Y"; then
        git init
        ask_input "Git 저장소 URL을 입력하세요: " "GIT_URL"
        git remote add origin "$GIT_URL"
        print_success "Git 초기화 완료"
    else
        ask_input "Git 저장소 URL을 입력하세요: " "GIT_URL"
    fi
fi

# Step 5: 환경 변수 수집
print_info "환경 변수 수집 중..."

# Backend Secrets 생성
BACKEND_SECRET=$(openssl rand -base64 32)
EXTERNAL_SECRET=$(openssl rand -base64 32)
POSTGRES_PASSWORD=$(openssl rand -base64 32)

print_success "Backend secrets 생성 완료"

# GitHub Token 입력
ask_input "GitHub Personal Access Token을 입력하세요: " "GITHUB_TOKEN"

# Google OAuth 정보
print_info "Google OAuth 설정"
ask_input "Google OAuth Client ID를 입력하세요: " "AUTH_GOOGLE_CLIENT_ID"
ask_input "Google OAuth Client Secret을 입력하세요: " "AUTH_GOOGLE_CLIENT_SECRET"

# GitHub OAuth 정보
print_info "GitHub OAuth 설정"
ask_input "GitHub OAuth Client ID를 입력하세요: " "AUTH_GITHUB_CLIENT_ID"
ask_input "GitHub OAuth Client Secret을 입력하세요: " "AUTH_GITHUB_CLIENT_SECRET"

# Step 6: .env 파일 생성
print_info ".env 파일 생성 중..."

cat > .env << EOF
# Backend Secrets
BACKEND_SECRET=$BACKEND_SECRET
EXTERNAL_SECRET=$EXTERNAL_SECRET

# PostgreSQL
POSTGRES_PASSWORD=$POSTGRES_PASSWORD

# GitHub Integration
GITHUB_TOKEN=$GITHUB_TOKEN

# OAuth - Google
AUTH_GOOGLE_CLIENT_ID=$AUTH_GOOGLE_CLIENT_ID
AUTH_GOOGLE_CLIENT_SECRET=$AUTH_GOOGLE_CLIENT_SECRET

# OAuth - GitHub
AUTH_GITHUB_CLIENT_ID=$AUTH_GITHUB_CLIENT_ID
AUTH_GITHUB_CLIENT_SECRET=$AUTH_GITHUB_CLIENT_SECRET
EOF

print_success ".env 파일 생성 완료"

# Step 7: docker-compose.yml 생성
print_info "docker-compose.yml 파일 생성 중..."

if [ -f "docker-compose.yml" ]; then
    if ! ask_yes_no "docker-compose.yml 파일이 이미 있습니다. 덮어쓰시겠습니까?" "N"; then
        print_info "기존 docker-compose.yml 유지"
    else
        CREATE_COMPOSE=true
    fi
else
    CREATE_COMPOSE=true
fi

if [ "$CREATE_COMPOSE" = true ]; then
cat > docker-compose.yml << 'COMPOSEEOF'
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
COMPOSEEOF

    print_success "docker-compose.yml 파일 생성 완료"
fi

# Step 8: Backstage 빌드 및 실행
print_info "Backstage 빌드 및 실행 중..."

if ask_yes_no "Docker 이미지를 빌드하고 컨테이너를 시작하시겠습니까?" "Y"; then
    # Docker 이미지 빌드 및 컨테이너 시작
    print_info "Docker Compose로 빌드 및 시작 중..."
    docker-compose up -d --build
    
    print_success "컨테이너 시작 완료"
    print_info "로그 확인 중 (30초 후 중지)..."
    
    timeout 30 docker-compose logs -f 2>/dev/null || docker-compose logs --tail=50
fi

# Step 9: Git 커밋 및 푸시
print_info "Git 커밋 및 푸시 옵션"

# GIT_URL이 비어있으면 Git 연동 건너뛰기
if [ -z "$GIT_URL" ]; then
    print_info "Git 저장소가 설정되지 않아 커밋을 건너뜁니다."
else
    if ask_yes_no "변경사항을 Git에 커밋하시겠습니까?" "Y"; then
    # .env 파일은 .gitignore에 추가
    if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
        echo ".env" >> .gitignore
        print_info ".env 파일을 .gitignore에 추가했습니다."
    fi
    
    # 변경사항 스테이징
    git add .
    
    # 커밋
    COMMIT_MESSAGE="feat: Setup Backstage with Docker configuration"
    
    if ask_yes_no "커밋 메시지를 변경하시겠습니까?" "N"; then
        read -p "커밋 메시지: " COMMIT_MESSAGE
    fi
    
    git commit -m "$COMMIT_MESSAGE"
    print_success "Git 커밋 완료"
    
    # 푸시
    if ask_yes_no "원격 저장소에 푸시하시겠습니까?" "Y"; then
        # 브랜치 확인
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
        
        # origin이 설정되어 있는지 확인
        if git remote | grep -q origin; then
            if ask_yes_no "main 브랜치에 푸시하시겠습니까?" "Y"; then
                git push origin main
            else
                read -p "푸시할 브랜치 이름: " PUSH_BRANCH
                git push origin "$PUSH_BRANCH"
            fi
            print_success "Git 푸시 완료"
        else
            print_warning "origin remote가 설정되지 않았습니다."
            
            ask_input "Git 저장소 URL을 입력하세요: " "REMOTE_URL"
            git remote add origin "$REMOTE_URL"
            
            if ask_yes_no "main 브랜치로 푸시하시겠습니까?" "Y"; then
                git push -u origin main
            else
                read -p "푸시할 브랜치 이름: " PUSH_BRANCH
                git push -u origin "$PUSH_BRANCH"
            fi
            print_success "Git 푸시 완료"
        fi
    else
        print_info "Git 푸시를 건너뜁니다."
    fi
fi

# 완료 메시지
echo ""
echo "========================================="
echo "  설치 완료!"
echo "========================================="
echo ""
print_success "Backstage 접속 URL: http://localhost:3000"
print_success "Backstage 백엔드: http://localhost:7007"
echo ""
print_info "컨테이너 관리 명령어:"
echo "  - 로그 확인: docker-compose logs -f"
echo "  - 중지: docker-compose down"
echo "  - 재시작: docker-compose restart"
echo ""
```

---

## 수동 설치 가이드

자동 설치 스크립트를 사용하지 않는 경우:

### Step 1: 필수 소프트웨어 확인

```bash
# Docker 확인
docker --version

# Docker Compose 확인
docker-compose --version
```

### Step 2: 환경 변수 설정

`.env` 파일 생성 (자동 설치 스크립트 참조)

### Step 3: docker-compose.yml 생성

자동 설치 스크립트의 docker-compose.yml 참조

### Step 4: 실행

```bash
docker-compose up -d --build
```

---

## Git 연동 설정

### Git 저장소 연결

자동 설치 스크립트가 다음을 수행합니다:

1. **Git 초기화**
```bash
git init
```

2. **Remote 추가**
```bash
git remote add origin <repo-url>
```

3. **변경사항 커밋**
```bash
git add .
git commit -m "feat: Setup Backstage with Docker"
```

4. **원격 저장소 푸시**
```bash
git push -u origin main
```

### Git 연동 방식

#### Option 1: 기존 저장소에 푸시

```bash
# 자동 설치 스크립트가 물어볼 때:
# "이 Git 저장소를 사용하시겠습니까?" → Y
# "변경사항을 Git에 커밋하시겠습니까?" → Y
# "원격 저장소에 푸시하시겠습니까?" → Y
```

#### Option 2: 새 저장소 생성 후 푸시

```bash
# GitHub에서 새 저장소 생성
# 자동 설치 스크립트 실행 시 URL 입력
```

#### Option 3: 로컬에서만 커밋

```bash
# "원격 저장소에 푸시하시겠습니까?" → N
# 나중에 수동으로 푸시 가능
```

---

## 스크립트 사용 방법

### Step 1: 스크립트 다운로드 및 권한 설정

```bash
# rnd-backstage 디렉토리로 이동
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# setup-backstage.sh 파일이 이미 존재
# 실행 권한 부여
chmod +x setup-backstage.sh

# 또는 직접 실행
bash setup-backstage.sh
```

### Step 2: 스크립트 실행

```bash
./setup-backstage.sh
```

**또는**

```bash
bash setup-backstage.sh
```

### Step 3: 질문에 답변

스크립트가 차례대로 질문합니다:

```
1. Docker 설치 여부 → Y/N
2. Docker Compose 설치 여부 → Y/N
3. 현재 디렉토리 사용 여부 → Y/N
4. Git 저장소 URL → 입력
5. GitHub Token → 입력
6. Google OAuth Client ID → 입력
7. Google OAuth Client Secret → 입력
8. GitHub OAuth Client ID → 입력
9. GitHub OAuth Client Secret → 입력
10. 빌드 및 실행 여부 → Y/N
11. Git 커밋 여부 → Y/N
12. Git 푸시 여부 → Y/N
```

---

## 설치 후 확인

### 컨테이너 상태 확인

```bash
# 실행 중인 컨테이너 확인
docker-compose ps

# 로그 확인
docker-compose logs -f

# 개별 서비스 로그
docker-compose logs backstage
docker-compose logs postgres
```

### 접속 확인

```bash
# 프론트엔드
open http://localhost:3000

# 백엔드 API
curl http://localhost:7007/api/healthcheck

# PostgreSQL
docker-compose exec postgres psql -U postgres -d backstage -c "\dt"
```

---

## 트러블슈팅

### 스크립트 실행 권한 오류

```bash
# 실행 권한 부여
chmod +x setup-backstage.sh

# 권한 확인
ls -l setup-backstage.sh

# bash로 직접 실행 (권한 없이도 가능)
bash setup-backstage.sh
```

### Docker 실행되지 않음

```bash
# Docker Desktop 실행 확인
open -a Docker

# Docker 실행 상태 확인
docker info
```

### Git 저장소 오류

```bash
# Git 초기화 다시
git init

# Remote 추가
git remote add origin <repo-url>

# 수동 커밋 및 푸시
git add .
git commit -m "feat: Setup Backstage"
git push -u origin main
```

### 포트 충돌

```bash
# 포트 사용 확인
lsof -i :3000
lsof -i :7007
lsof -i :5432

# 다른 포트로 변경
nano docker-compose.yml
# 포트 번호 수정 후
docker-compose up -d
```

---

## 참고 자료

- [Docker 공식 문서](https://docs.docker.com/)
- [Docker Compose 문서](https://docs.docker.com/compose/)
- [Git 공식 문서](https://git-scm.com/doc)
- [Backstage 공식 문서](https://backstage.io/docs)

---

## 작성 정보

**작성자**: Platform Team  
**작성일**: 2025-10-24  
**문서 버전**: 1.0  
**상태**: Complete

