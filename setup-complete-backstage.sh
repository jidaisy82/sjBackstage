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
print_warning "📌 참고: 설치 '기준 위치'를 지정하세요."
print_warning ""
print_warning "  - 여기서 입력하는 경로(INSTALL_DIR)는 npx가 새 프로젝트 폴더(=프로젝트 이름)를 만들 '상위 경로'입니다."
print_warning "  - @backstage/create-app 은 항상 새로운 폴더를 생성합니다. (기존 폴더에 바로 설치하지 않음)"
print_warning ""
print_warning "예시"
print_warning "  1) 현재 위치에 바로 생성하려면: '.' 입력"
print_warning "     ⇒ 결과: $CURRENT_DIR/<프로젝트이름>/"
print_warning "  2) 하위 폴더를 하나 더 만들고 그 안에 생성하려면: './backstage' 입력"
print_warning "     ⇒ 결과: $CURRENT_DIR/backstage/<프로젝트이름>/"
print_warning ""
print_info "※ 정리: '.' 을 입력해도 현재 위치 '안에' <프로젝트이름> 폴더가 생성됩니다."
print_info ""
print_warning "※ 프로젝트 이름은 하이픈(-)을 사용하는 것을 권장합니다. (예: rnd-backstage, my-backstage)"
print_info ""

ask_input "Backstage를 설치할 프로젝트 이름(디렉토리 경로)를 입력하세요: " "INSTALL_DIR"

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

# Step 2: 스크립트 디렉토리 설정
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
print_info "스크립트 위치: $SCRIPT_DIR"

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

print_info ""
print_warning "⚠️  중요: @backstage/create-app은 interactive CLI입니다."
print_warning "프로젝트 이름은 하이픈(-)을 사용하는 것을 권장합니다. (예: rnd-backstage, my-backstage)"
ask_input "프로젝트 이름을 입력하세요 (기본: my-backstage): " "PROJECT_NAME"
PROJECT_NAME=${PROJECT_NAME:-my-backstage}

print_info ""
print_info "creating a new app..."

# stdin으로 자동 응답 제공
(echo "$PROJECT_NAME" | npx -y @backstage/create-app@latest) || {
    # fallback: expect를 사용한 자동화
    if command -v expect &> /dev/null; then
        print_info "expect를 사용하여 자동 입력 중..."
        expect << EOF
spawn npx @backstage/create-app@latest
expect "Enter a name for the app*"
send "$PROJECT_NAME\r"
expect eof
EOF
    else
        # expect가 없으면 사용자에게 수동 입력 요청
        print_warning "expect가 설치되어 있지 않습니다."
        print_warning "프롬프트가 나타나면 프로젝트 이름을 입력해주세요."
        echo "$PROJECT_NAME" | npx @backstage/create-app@latest
    fi
}

# 생성된 폴더 찾기
BACKSTAGE_NAME="$PROJECT_NAME"
if [ -d "$BACKSTAGE_NAME" ]; then
    cd "$BACKSTAGE_NAME"
    BACKSTAGE_DIR=$(pwd)
    print_success "Backstage 프로젝트 생성 완료"
    print_info "생성된 폴더: $BACKSTAGE_NAME"
    print_info "최종 위치: $BACKSTAGE_DIR"
else
    # fallback: 가장 최근에 만든 디렉토리 찾기
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
    #POSTGRES_PASSWORD=$(openssl rand -base64 32)
    POSTGRES_PASSWORD="post1234"
    POSTGRES_HOST="postgres"
    POSTGRES_PORT="5432"
    POSTGRES_USER="postgres"
    POSTGRES_DB="backstage"
fi

print_success "Secrets 생성 완료"

# GitHub Token 입력
ask_input "GitHub Personal Access Token을 입력하세요: " "GITHUB_TOKEN"

# GitHub OAuth 정보
print_info "GitHub OAuth 설정"
ask_input "GitHub OAuth Client ID를 입력하세요: " "AUTH_GITHUB_CLIENT_ID"
ask_input "GitHub OAuth Client Secret을 입력하세요: " "AUTH_GITHUB_CLIENT_SECRET"

# Google OAuth 정보
print_info "Google OAuth 설정"
ask_input "Google OAuth Client ID를 입력하세요: " "AUTH_GOOGLE_CLIENT_ID"
ask_input "Google OAuth Client Secret을 입력하세요: " "AUTH_GOOGLE_CLIENT_SECRET"


# Step 7: app-config.yaml 통합
print_info "app-config.yaml 통합 중..."

# 백스테이지 설치 시 생성된 app-config.yaml을 그대로 사용
if [ -f "$BACKSTAGE_DIR/app-config.yaml" ]; then
    print_info "백스테이지 생성 app-config.yaml을 사용합니다."
    print_info "파일 위치: $BACKSTAGE_DIR/app-config.yaml"
else
    print_warning "백스테이지 설치된 app-config.yaml을 찾을 수 없습니다."
fi

# rnd-backstage 폴더에서 참고용 app-config.yaml을 app-config-example.yaml로 복사
# (스크립트가 어디서 실행되든 rnd-backstage 폴더의 파일을 사용)
REF_APP_CONFIG=""
if [ -f "$SCRIPT_DIR/app-config.yaml" ]; then
    REF_APP_CONFIG="$SCRIPT_DIR/app-config.yaml"
    print_info "rnd-backstage 폴더에서 app-config.yaml 발견: $REF_APP_CONFIG"
else
    print_warning "참고용 app-config.yaml 파일을 찾을 수 없습니다."
    print_warning "  - 확인 위치: $SCRIPT_DIR/app-config.yaml"
fi

if [ -n "$REF_APP_CONFIG" ]; then
    cp "$REF_APP_CONFIG" "$BACKSTAGE_DIR/app-config-example.yaml"
    print_success "참고용 app-config-example.yaml 복사 완료"
    print_info "참고: 필요시 app-config-example.yaml을 참고하여 app-config.yaml을 수정하세요."
fi

# examples 폴더 파일 처리
print_info "examples 폴더 파일 처리 중..."

# 백스테이지 설치 시 생성된 examples 파일들을 그대로 사용
if [ -d "$BACKSTAGE_DIR/examples" ]; then
    print_info "백스테이지 생성 examples 폴더를 사용합니다."
    print_info "파일 위치: $BACKSTAGE_DIR/examples/"
    
    # entities.yaml 확인
    if [ -f "$BACKSTAGE_DIR/examples/entities.yaml" ]; then
        print_info "entities.yaml 확인됨"
    fi
    
    # org.yaml 확인
    if [ -f "$BACKSTAGE_DIR/examples/org.yaml" ]; then
        print_info "org.yaml 확인됨"
    fi
fi

# rnd-backstage 폴더에서 참고용 examples 파일을 -example로 복사
# (스크립트가 어디서 실행되든 rnd-backstage 폴더의 파일을 사용)
# entities.yaml 처리
REF_ENTITIES=""
if [ -f "$SCRIPT_DIR/examples/entities.yaml" ]; then
    REF_ENTITIES="$SCRIPT_DIR/examples/entities.yaml"
    print_info "rnd-backstage 폴더에서 entities.yaml 발견: $REF_ENTITIES"
else
    print_warning "참고용 entities.yaml 파일을 찾을 수 없습니다."
    print_warning "  - 확인 위치: $SCRIPT_DIR/examples/entities.yaml"
fi

if [ -n "$REF_ENTITIES" ]; then
    cp "$REF_ENTITIES" "$BACKSTAGE_DIR/entities-example.yaml"
    print_success "참고용 entities-example.yaml 복사 완료"
fi

# org.yaml 처리
REF_ORG=""
if [ -f "$SCRIPT_DIR/examples/org.yaml" ]; then
    REF_ORG="$SCRIPT_DIR/examples/org.yaml"
    print_info "rnd-backstage 폴더에서 org.yaml 발견: $REF_ORG"
else
    print_warning "참고용 org.yaml 파일을 찾을 수 없습니다."
    print_warning "  - 확인 위치: $SCRIPT_DIR/examples/org.yaml"
fi

if [ -n "$REF_ORG" ]; then
    cp "$REF_ORG" "$BACKSTAGE_DIR/org-example.yaml"
    print_success "참고용 org-example.yaml 복사 완료"
fi

print_info ""
print_info "⚠️  중요: app-config.yaml 파일 수정"
print_info ""
print_info "현재 백스테이지 생성 app-config.yaml이 사용됩니다."
print_info ""
print_info "필요시 수정 사항:"
print_info "  - catalog의 location 항목 조정"
print_info "  - techinsights 관련 설정 제거"
print_info "  - OAuth 설정 확인"
print_info "  - examples 경로 확인"
print_info ""

# example 파일들이 존재하면 참고하라는 메시지 추가
HAS_EXAMPLES=false
if [ -f "$BACKSTAGE_DIR/app-config-example.yaml" ]; then
    HAS_EXAMPLES=true
fi
if [ -f "$BACKSTAGE_DIR/org-example.yaml" ]; then
    HAS_EXAMPLES=true
fi
if [ -f "$BACKSTAGE_DIR/entities-example.yaml" ]; then
    HAS_EXAMPLES=true
fi

if [ "$HAS_EXAMPLES" = true ]; then
    print_info "📝 참고 파일 (example 파일들을 참고하여 수정하세요):"
    if [ -f "$BACKSTAGE_DIR/app-config-example.yaml" ]; then
        print_info "  - app-config-example.yaml"
    fi
    if [ -f "$BACKSTAGE_DIR/org-example.yaml" ]; then
        print_info "  - org-example.yaml"
    fi
    if [ -f "$BACKSTAGE_DIR/entities-example.yaml" ]; then
        print_info "  - entities-example.yaml"
    fi
    print_info ""
fi

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
# Multi-stage build for Backstage
# Stage 1: Build stage
FROM node:22-bookworm AS build

# Set Python interpreter for `node-gyp` to use
ENV PYTHON=/usr/bin/python3

# Install dependencies for native modules
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy Yarn files and enable corepack
COPY .yarnrc.yml ./
COPY .yarn ./.yarn
COPY package.json yarn.lock backstage.json ./
RUN corepack enable && corepack prepare yarn@4.4.1 --activate

# Copy workspace package.json files for dependency resolution
COPY packages/app/package.json ./packages/app/package.json
COPY packages/backend/package.json ./packages/backend/package.json

# Install all dependencies (including devDependencies needed for build)
RUN yarn install --immutable

# Copy all source files
COPY . .

# Build all packages (includes both frontend and backend)
RUN yarn tsc
RUN yarn build:all

# Stage 2: Runtime stage
FROM node:22-bookworm-slim

# Set Python interpreter for `node-gyp` to use
ENV PYTHON=/usr/bin/python3

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends python3 libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# Enable corepack as root before switching to node user
RUN corepack enable && corepack prepare yarn@4.4.1 --activate

# Use non-root user
USER node
WORKDIR /app

# Copy yarn configuration
COPY --chown=node:node .yarnrc.yml ./
COPY --chown=node:node .yarn ./.yarn
COPY --chown=node:node package.json yarn.lock backstage.json ./

# Copy skeleton and install production dependencies
COPY --chown=node:node --from=build /app/packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

# Install only production dependencies
RUN yarn workspaces focus --all --production

# Copy built backend bundle
COPY --chown=node:node --from=build /app/packages/backend/dist/bundle.tar.gz ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

# Copy config and examples
COPY --chown=node:node app-config*.yaml ./
COPY --chown=node:node examples ./examples

# Set production mode
ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"

EXPOSE 7007

# Run the backend
CMD ["node", "packages/backend", "--config", "app-config.yaml"]
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
    echo "     docker compose up --build -d"
else
    echo "     docker compose up --build -d"
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
