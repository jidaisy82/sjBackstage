#!/bin/bash

# RND Backstage Docker 자동 설치 스크립트
# macOS & Linux 지원

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
    local prompt_text
    
    if [ "$default" = "Y" ]; then
        printf "${BLUE}%s (Y/n): ${NC}" "$prompt"
        read response
        response=${response:-Y}
    else
        printf "${BLUE}%s (y/N): ${NC}" "$prompt"
        read response
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
        printf "${BLUE}%s: ${NC}" "$prompt"
        read input
        if [ -n "$input" ]; then
            eval "$var_name='$input'"
        else
            print_error "값을 입력해주세요."
        fi
    done
}

# OS 감지
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

# OS 자동 감지
OS_TYPE=$(detect_os)
print_info "운영체제: $OS_TYPE"

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
        if [ "$OS_TYPE" = "macos" ]; then
            print_info "macOS: Docker Desktop 설치 중..."
            brew install --cask docker
            print_success "Docker Desktop 설치 완료"
            print_warning "Docker Desktop을 실행한 후 이 스크립트를 다시 실행하세요."
            exit 0
        elif [ "$OS_TYPE" = "linux" ]; then
            print_info "Linux: Docker 설치 중..."
            
            # 패키지 매니저 감지
            if command -v apt &> /dev/null; then
                # Ubuntu/Debian
                sudo apt update
                sudo apt install -y docker.io docker-compose
                sudo systemctl start docker
                sudo systemctl enable docker
            elif command -v yum &> /dev/null; then
                # CentOS/RHEL
                sudo yum install -y docker docker-compose
                sudo systemctl start docker
                sudo systemctl enable docker
            elif command -v dnf &> /dev/null; then
                # Fedora
                sudo dnf install -y docker docker-compose
                sudo systemctl start docker
                sudo systemctl enable docker
            else
                print_error "패키지 매니저를 찾을 수 없습니다."
                print_error "수동으로 Docker를 설치해주세요: https://docs.docker.com/get-docker/"
                exit 1
            fi
            
            print_success "Docker 설치 완료"
            print_warning "Docker 설치 후 시스템을 재부팅하거나 로그아웃/로그인한 후 다시 실행하세요."
            exit 0
        else
            print_error "지원하지 않는 운영체제입니다."
            exit 1
        fi
    else
        print_error "Docker 없이는 설치할 수 없습니다."
        exit 1
    fi
fi

# Docker 실행 확인
if ! docker info &> /dev/null; then
    print_error "Docker가 실행 중이 아닙니다."
    if [ "$OS_TYPE" = "macos" ]; then
        print_warning "Docker Desktop을 실행한 후 이 스크립트를 다시 실행하세요."
    elif [ "$OS_TYPE" = "linux" ]; then
        print_warning "Docker 서비스를 시작하려면: sudo systemctl start docker"
    fi
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
        if [ "$OS_TYPE" = "macos" ]; then
            print_info "Docker Compose 설치 중..."
            brew install docker-compose
            print_success "Docker Compose 설치 완료"
        elif [ "$OS_TYPE" = "linux" ]; then
            print_info "Linux에서 Docker Compose는 Docker와 함께 설치됩니다."
            print_info "Docker 설치 시 자동으로 포함됩니다."
        fi
    fi
fi

# Step 3: 작업 디렉토리 및 Git 설정
print_info "작업 디렉토리 및 Git 설정 중..."

# 현재 디렉토리 확인
CURRENT_DIR=$(pwd)
print_info "현재 디렉토리: $CURRENT_DIR"

# rnd-backstage 프로젝트인지 확인
IS_BACKSTAGE_PROJECT=false
if [ -f "app-config.yaml" ] && [ -f "package.json" ] && [ -d "packages" ]; then
    IS_BACKSTAGE_PROJECT=true
    print_success "rnd-backstage 프로젝트 확인됨"
    BACKSTAGE_SOURCE_DIR=$CURRENT_DIR
    WORK_DIR=$CURRENT_DIR
else
    # 현재 위치가 rnd-backstage가 아닌 경우
    print_warning "현재 디렉토리는 rnd-backstage 프로젝트가 아닙니다."
    print_info ""
    print_info "이 스크립트는 기존 rnd-backstage 프로젝트를 Docker로 컨테이너화합니다."
    print_info ""
    print_info "옵션 1: 기존 rnd-backstage를 현재 위치로 복사"
    print_info "옵션 2: 기존 rnd-backstage를 다른 위치로 복사"
    print_info "옵션 3: 처음부터 Backstage 생성 (npx 명령어 사용 권장)"
    print_info ""
    
    if ask_yes_no "기존 rnd-backstage 폴더 경로를 지정하여 복사하시겠습니까?" "N"; then
        ask_input "rnd-backstage 프로젝트의 전체 경로를 입력하세요: " "BACKSTAGE_PATH"
        
        if [ ! -d "$BACKSTAGE_PATH" ]; then
            print_error "경로가 존재하지 않습니다: $BACKSTAGE_PATH"
            exit 1
        fi
        
        if [ ! -f "$BACKSTAGE_PATH/app-config.yaml" ] || [ ! -f "$BACKSTAGE_PATH/package.json" ] || [ ! -d "$BACKSTAGE_PATH/packages" ]; then
            print_error "rnd-backstage 프로젝트가 아닙니다: $BACKSTAGE_PATH"
            exit 1
        fi
        
        BACKSTAGE_SOURCE_DIR="$BACKSTAGE_PATH"
        print_success "rnd-backstage 프로젝트 확인됨: $BACKSTAGE_PATH"
        
        # 새 폴더로 복사할지 확인
        if ask_yes_no "현재 디렉토리에 rnd-backstage를 복사하여 설치하시겠습니까?" "Y"; then
            WORK_DIR=$CURRENT_DIR
            print_info "rnd-backstage 프로젝트를 현재 디렉토리로 복사 중..."
            
            # 숨김 파일 포함 복사 (.gitignore, .env 등)
            rsync -av --exclude='.git' --exclude='node_modules' --exclude='dist' --exclude='*.log' "$BACKSTAGE_SOURCE_DIR/" "$WORK_DIR/"
            
            print_success "복사 완료: $WORK_DIR"
        else
            ask_input "Backstage를 설치할 디렉토리 경로를 입력하세요: " "WORK_DIR"
            
            if [ ! -d "$WORK_DIR" ]; then
                if ask_yes_no "디렉토리를 생성하시겠습니까?" "Y"; then
                    mkdir -p "$WORK_DIR"
                else
                    print_error "디렉토리가 존재하지 않습니다."
                    exit 1
                fi
            fi
            
            print_info "rnd-backstage 프로젝트를 $WORK_DIR로 복사 중..."
            rsync -av --exclude='.git' --exclude='node_modules' --exclude='dist' --exclude='*.log' "$BACKSTAGE_SOURCE_DIR/" "$WORK_DIR/"
            print_success "복사 완료: $WORK_DIR"
        fi
    else
        print_info ""
        print_info "⚠️  새로운 Backstage를 처음부터 생성하려면:"
        print_info ""
        print_info "방법 1: npx로 Backstage 생성 (권장)"
        print_info "  npx @backstage/create-app"
        print_info ""
        print_info "방법 2: 기존 rnd-backstage 사용"
        print_info "  1. rnd-backstage 폴더로 이동:"
        print_info "     cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage"
        print_info "  2. 스크립트 실행:"
        print_info "     ./setup-backstage.sh"
        print_info ""
        exit 0
    fi
fi

cd "$WORK_DIR"

# Git 저장소 설정
print_info "Git 저장소 설정 중..."

if [ -d ".git" ]; then
    print_success "Git 저장소 확인됨"
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
    
    if [ -n "$REMOTE_URL" ]; then
        print_info "Git remote: $REMOTE_URL"
        
        if ask_yes_no "이 Git 저장소를 사용하시겠습니까?" "Y"; then
            GIT_URL=$REMOTE_URL
        else
            ask_input "새 Git 저장소 URL을 입력하세요: " "GIT_URL"
            git remote set-url origin "$GIT_URL"
            print_success "Git remote 업데이트 완료"
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
        print_success "Git 초기화 완료: $GIT_URL"
    else
        GIT_URL=""
        print_warning "Git 연동 없이 진행합니다."
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
        CREATE_COMPOSE=false
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
    else
        print_info "Git 커밋을 건너뜁니다."
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

