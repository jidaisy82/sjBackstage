#!/bin/bash

# 완전히 새로운 Backstage 프로젝트 생성 스크립트

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

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# 시작 메시지
echo ""
echo "========================================="
echo "  새로운 Backstage 프로젝트 생성"
echo "========================================="
echo ""

print_info "이 스크립트는 완전히 새로운 Backstage 프로젝트를 생성합니다."
print_info ""
print_info "사용 가능한 방법:"
print_info "  1. npx로 Backstage 생성 (권장)"
print_info "  2. 기존 rnd-backstage 복사 후 Docker 설정"
echo ""

print_info "새 Backstage 생성 명령어:"
print_info ""
echo "npx @backstage/create-app@latest"
echo ""
print_info "추가 정보: CREATE_NEW_BACKSTAGE.md 파일을 참조하세요."
echo ""

