#!/bin/bash

# 완전히 새로운 Backstage 프로젝트 생성 + rnd-backstage 설정 통합 + Docker 설정
# PostgreSQL 선택 가능 (새 컨테이너 / 기존 DB)

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

# 시작 메시지
echo ""
echo "========================================="
echo "  새로운 Backstage 설치 (Docker 포함)"
echo "========================================="
echo ""

print_info "이 스크립트는:"
print_info "  1. 새 Backstage 프로젝트 생성 (npx @backstage/create-app)"
print_info "  2. PostgreSQL 선택 (새 컨테이너 / 기존 DB)"
print_info "  3. rnd-backstage 설정 통합"
print_info "  4. Docker 컨테이너화"
echo ""

# Step 1: 작업 디렉토리 확인
print_info "작업 디렉토리 확인 중..."

CURRENT_DIR=$(pwd)
print_info "현재 디렉토리: $CURRENT_DIR"
print_info ""
print_warning "📌 참고: Backstage가 생성될 폴더를 지정해주세요."
print_warning ""
print_warning "  현재 위치: $CURRENT_DIR"
print_warning ""
print_warning "  옵션 1: 현재 위치에 바로 생성"
print_warning "    입력: ."
print_warning "    결과: $CURRENT_DIR/my-backstage/"
print_warning ""
print_warning "  옵션 2: 하위 폴더 생성"
print_warning "    입력: ./backstage"
print_warning "    결과: $CURRENT_DIR/backstage/my-backstage/"
print_warning ""
print_warning "  중요: npx가 입력한 폴더 '안에' 또 폴더를 생성합니다!"
print_warning ""
print_info "추천: 현재 위치(.)에 바로 생성하는 것을 권장합니다."
print_info ""

ask_input "Backstage를 설치할 디렉토리 경로를 입력하세요: " "INSTALL_DIR"

if [ ! -d "$INSTALL_DIR" ]; then
    if ask_yes_no "디렉토리를 생성하시겠습니까?" "Y"; then
        mkdir -p "$INSTALL_DIR"
        print_success "디렉토리 생성 완료: $INSTALL_DIR"
    else
        print_error "디렉토리가 존재하지 않습니다."
        exit 1
    fi
fi

cd "$INSTALL_DIR"

# Step 2: app-config.yaml 참고 파일 확인
print_info "app-config.yaml 참고 파일 확인 중..."
print_info ""
print_info "⚠️  참고할 app-config.yaml 파일을 찾습니다."
print_info "   스크립트 위치에서 app-config.yaml 파일을 찾습니다."
print_info ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -f "$SCRIPT_DIR/app-config.yaml" ]; then
    APP_CONFIG_REF="$SCRIPT_DIR/app-config.yaml"
    print_success "app-config.yaml 파일 발견: $APP_CONFIG_REF"
else
    print_warning "스크립트 위치에 app-config.yaml이 없습니다."
    print_info "rnd-backstage 폴더의 app-config.yaml 경로를 입력하세요:"
    
    ask_input "app-config.yaml 파일의 전체 경로를 입력하세요: " "APP_CONFIG_REF"
    
    if [ ! -f "$APP_CONFIG_REF" ]; then
        print_error "파일이 존재하지 않습니다: $APP_CONFIG_REF"
        exit 1
    fi
fi

# Step 3: Docker 확인
print_info "Docker 확인 중..."

if ! command -v docker &> /dev/null; then
    print_error "Docker가 설치되지 않았습니다."
    print_info "Docker를 먼저 설치해주세요: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! docker info &> /dev/null; then
    print_error "Docker가 실행 중이 아닙니다."
    exit 1
fi

print_success "Docker 확인됨"

# Step 4: Backstage 생성
print_info "Backstage 프로젝트 생성 중..."

print_info "npx @backstage/create-app 실행 중..."
print_info "현재 위치: $(pwd)"
print_info "npx는 이 위치에 Backstage 프로젝트 폴더를 생성합니다."
print_warning "주의: npx가 새로운 폴더를 생성합니다!"

npx @backstage/create-app@latest --yes

# 생성된 폴더 찾기 (가장 최근에 만든 디렉토리)
BACKSTAGE_NAME=$(ls -td */ 2>/dev/null | head -n 1 | tr -d '/')
if [ -n "$BACKSTAGE_NAME" ]; then
    cd "$BACKSTAGE_NAME"
    BACKSTAGE_DIR=$(pwd)
    print_success "Backstage 프로젝트 생성 완료"
    print_info "생성된 폴더: $BACKSTAGE_NAME"
    print_info "최종 위치: $BACKSTAGE_DIR"
else
    print_error "Backstage 폴더를 찾을 수 없습니다."
    exit 1
fi

# Step 5: PostgreSQL 선택
print_info "PostgreSQL 설정 중..."

echo ""
print_info "PostgreSQL 옵션:"
print_info "  1. 새로운 Docker 컨테이너 생성 (권장)"
print_info "  2. 기존 PostgreSQL 사용"

if ask_yes_no "새로운 PostgreSQL 컨테이너를 생성하시겠습니까?" "Y"; then
    USE_CONTAINER_DB=true
    print_info "Docker 컨테이너로 PostgreSQL을 생성합니다."
else
    USE_CONTAINER_DB=false
    print_info "기존 PostgreSQL을 사용합니다."
    
    ask_input "PostgreSQL 호스트를 입력하세요: " "POSTGRES_HOST"
    ask_input "PostgreSQL 포트를 입력하세요 (기본: 5432): " "POSTGRES_PORT"
    ask_input "PostgreSQL 사용자명을 입력하세요 (기본: postgres): " "POSTGRES_USER"
    ask_input "PostgreSQL 비밀번호를 입력하세요: " "POSTGRES_PASSWORD"
    ask_input "PostgreSQL 데이터베이스명을 입력하세요 (기본: backstage): " "POSTGRES_DB"
    
    POSTGRES_PORT=${POSTGRES_PORT:-5432}
    POSTGRES_USER=${POSTGRES_USER:-postgres}
    POSTGRES_DB=${POSTGRES_DB:-backstage}
fi

# Step 6: 환경 변수 수집
print_info "환경 변수 수집 중..."

# Backend Secrets 생성
BACKEND_SECRET=$(openssl rand -base64 32)
EXTERNAL_SECRET=$(openssl rand -base64 32)

if [ "$USE_CONTAINER_DB" = true ]; then
    POSTGRES_PASSWORD=$(openssl rand -base64 32)
    POSTGRES_HOST="postgres"
    POSTGRES_PORT="5432"
    POSTGRES_USER="postgres"
    POSTGRES_DB="backstage"
fi

print_success "Secrets 생성 완료"

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

# Step 7: app-config.yaml 통합
print_info "app-config.yaml 통합 중..."

# 기존 app-config.yaml 백업
if [ -f "$BACKSTAGE_DIR/app-config.yaml" ]; then
    cp "$BACKSTAGE_DIR/app-config.yaml" "$BACKSTAGE_DIR/app-config.yaml.backup"
    print_info "기존 app-config.yaml 백업 완료"
fi

# 참고 app-config.yaml 복사
cp "$APP_CONFIG_REF" "$BACKSTAGE_DIR/app-config.yaml"
print_info "app-config.yaml 복사 완료: $APP_CONFIG_REF → $BACKSTAGE_DIR/app-config.yaml"

# examples 폴더 확인 및 복사
if [ -d "$(dirname "$APP_CONFIG_REF")/examples" ]; then
    print_info "examples 폴더 복사 중..."
    cp -r "$(dirname "$APP_CONFIG_REF")/examples" "$BACKSTAGE_DIR/"
    print_success "examples 폴더 복사 완료"
    
    print_info ""
    print_info "⚠️  중요: app-config.yaml의 location 설정 확인"
    print_info "   복사된 examples 폴더를 참조하도록 설정되어 있는지 확인하세요:"
    print_info "   예: target: ../../examples/org.yaml"
    print_info ""
fi

print_info ""
print_info "⚠️  중요: app-config.yaml 파일 수정"
print_info ""
print_info "현재 app-config.yaml이 이미 복사되어 있습니다."
print_info ""
print_info "필요시 수정 사항:"
print_info "  - catalog의 location 항목 조정"
print_info "  - techinsights 관련 설정 제거"
print_info "  - OAuth 설정 확인"
print_info "  - examples 경로 확인"
print_info ""
print_info "수정하지 않으면 현재 app-config.yaml이 그대로 적용이 되며, 컨테이너 빌드 시 적용됩니다."
print_warning "수정 후 Enter를 누르면 다음 단계로 진행합니다..."
print_info "(수정하지 않고 Enter만 눌러도 됩니다)"
read -p "Press Enter to continue..."

# Step 8: .env 파일 생성
print_info ".env 파일 생성 중..."

cat > .env << EOF
# Backend Secrets
BACKEND_SECRET=$BACKEND_SECRET
EXTERNAL_SECRET=$EXTERNAL_SECRET

# PostgreSQL
POSTGRES_HOST=$POSTGRES_HOST
POSTGRES_PORT=$POSTGRES_PORT
POSTGRES_USER=$POSTGRES_USER
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
POSTGRES_DB=$POSTGRES_DB

# GitHub Integration
GITHUB_TOKEN=$GITHUB_TOKEN

# Google OAuth
AUTH_GOOGLE_CLIENT_ID=$AUTH_GOOGLE_CLIENT_ID
AUTH_GOOGLE_CLIENT_SECRET=$AUTH_GOOGLE_CLIENT_SECRET

# GitHub OAuth
AUTH_GITHUB_CLIENT_ID=$AUTH_GITHUB_CLIENT_ID
AUTH_GITHUB_CLIENT_SECRET=$AUTH_GITHUB_CLIENT_SECRET
EOF

print_success ".env 파일 생성 완료"

# Step 9: docker-compose.yml 생성
print_info "docker-compose.yml 생성 중..."

if [ "$USE_CONTAINER_DB" = true ]; then
    # Docker 컨테이너로 PostgreSQL 생성
    cat > docker-compose.yml << 'COMPOSEEOF'
version: '3.8'

services:
  postgres:
    image: postgres:17-bookworm
    container_name: backstage-postgres
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
      dockerfile: Dockerfile
    container_name: backstage-app
    ports:
      - "3000:3000"
      - "7007:7007"
    environment:
      - BACKEND_SECRET=${BACKEND_SECRET}
      - EXTERNAL_SECRET=${EXTERNAL_SECRET}
      - POSTGRES_HOST=${POSTGRES_HOST}
      - POSTGRES_PORT=${POSTGRES_PORT}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
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
else
    # 기존 PostgreSQL 사용
    cat > docker-compose.yml << 'COMPOSEEOF'
version: '3.8'

services:
  backstage:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: backstage-app
    ports:
      - "3000:3000"
      - "7007:7007"
    environment:
      - BACKEND_SECRET=${BACKEND_SECRET}
      - EXTERNAL_SECRET=${EXTERNAL_SECRET}
      - POSTGRES_HOST=${POSTGRES_HOST}
      - POSTGRES_PORT=${POSTGRES_PORT}
      - POSTGRES_USER=${POSTGRES_USER}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
      - POSTGRES_DB=${POSTGRES_DB}
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - AUTH_GOOGLE_CLIENT_ID=${AUTH_GOOGLE_CLIENT_ID}
      - AUTH_GOOGLE_CLIENT_SECRET=${AUTH_GOOGLE_CLIENT_SECRET}
      - AUTH_GITHUB_CLIENT_ID=${AUTH_GITHUB_CLIENT_ID}
      - AUTH_GITHUB_CLIENT_SECRET=${AUTH_GITHUB_CLIENT_SECRET}
      - NODE_ENV=production
      - NODE_OPTIONS=--no-node-snapshot
    volumes:
      - ./app-config.yaml:/app/app-config.yaml:ro
    restart: unless-stopped
COMPOSEEOF
fi

print_success "docker-compose.yml 생성 완료"

# Step 10: Dockerfile 생성
print_info "Dockerfile 생성 중..."

cat > Dockerfile << 'DOCKERFILEEOF'
FROM node:20-bookworm-slim

WORKDIR /app

# 패키지 파일 복사
COPY package.json yarn.lock ./
COPY packages/backend/package.json ./packages/backend/
COPY packages/app/package.json ./packages/app/

# 의존성 설치
RUN yarn install --frozen-lockfile

# 소스 코드 복사
COPY . .

# Backstage 빌드
RUN yarn tsc
RUN yarn build:backend --config app-config.yaml
RUN yarn build

EXPOSE 3000 7007

CMD ["node", "packages/backend/dist/index.js", "--config", "app-config.yaml"]
DOCKERFILEEOF

print_success "Dockerfile 생성 완료"

# Step 11: 완료
echo ""
echo "========================================="
echo "  설치 완료!"
echo "========================================="
echo ""
print_success "Backstage 프로젝트 위치: $BACKSTAGE_DIR"
print_success ""
print_success "다음 단계:"
echo ""
echo "  1. 의존성 설치 및 빌드"
echo "     cd $BACKSTAGE_DIR"
echo "     yarn install"
echo "     yarn build:backend"
echo ""
echo "  2. Docker 이미지 빌드 및 실행"
if [ "$USE_CONTAINER_DB" = true ]; then
    echo "     docker-compose up -d --build"
else
    echo "     docker-compose up -d --build"
fi
echo ""
echo "  3. 접속"
echo "     http://localhost:3000"
echo ""
print_info ""
print_warning "⚠️  중요: 컨테이너는 아직 생성되지 않았습니다!"
print_info ""
print_info "위 명령어(yarn install, docker-compose up)를 실행해야 컨테이너가 생성됩니다."
print_info "app-config.yaml은 컨테이너 빌드 시 적용됩니다."
