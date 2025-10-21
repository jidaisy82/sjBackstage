# Backstage 데이터베이스 설정 수정 완료

## 🔧 해결한 문제

### 원래 에러
```
Error: Failed to connect to the database to make sure that 'backstage_plugin_app' exists, 
Error: SASL: SCRAM-SERVER-FIRST-MESSAGE: client password must be a string
```

### 원인
1. **데이터베이스 이름 불일치**: `.env` 파일에는 `POSTGRES_DB=postgres`로 설정되어 있었지만, Backstage는 `backstage` 데이터베이스를 찾으려고 했습니다.
2. **데이터베이스 미존재**: PostgreSQL에 `backstage` 데이터베이스가 생성되어 있지 않았습니다.

---

## ✅ 수정 작업

### 1. PostgreSQL 상태 확인
```bash
# PostgreSQL 컨테이너 확인
docker ps -a | grep postgres

# 결과:
docker.postgres (pgvector/pgvector:pg17) - 실행 중
```

### 2. backstage 데이터베이스 생성
```bash
# 데이터베이스 생성
docker exec docker.postgres psql -U postgres -c "CREATE DATABASE backstage;"

# 권한 부여
docker exec docker.postgres psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE backstage TO postgres;"
```

### 3. .env 파일 수정
**변경 전:**
```env
POSTGRES_DB=postgres
```

**변경 후:**
```env
POSTGRES_DB=backstage
```

---

## 📋 현재 데이터베이스 설정

### .env 파일 내용
```env
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=
POSTGRES_DB=backstage
```

### PostgreSQL 정보
- **컨테이너**: docker.postgres
- **이미지**: pgvector/pgvector:pg17
- **포트**: 5432
- **데이터베이스**: backstage (새로 생성됨)
- **사용자**: postgres

---

## 🚀 실행 방법

### 백엔드 시작
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn workspace backend start
```

### 프론트엔드 시작 (다른 터미널에서)
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn workspace app start
```

### 브라우저 접속
- **프론트엔드**: http://localhost:3000
- **백엔드 API**: http://localhost:7007

---

## 🔍 확인 사항

### 1. 데이터베이스 연결 확인
```bash
# PostgreSQL 접속
docker exec -it docker.postgres psql -U postgres -d backstage

# 테이블 확인
\dt

# 종료
\q
```

### 2. Backstage 테이블 생성 확인
백엔드가 시작되면 자동으로 다음 테이블들이 생성됩니다:
- `backstage_plugin_catalog`
- `backstage_plugin_search`
- `backstage_plugin_auth`
- `backstage_plugin_techdocs`
- `backstage_plugin_tech_insights` (Tech Insights 플러그인 테이블)

### 3. API 엔드포인트 확인
```bash
# 카탈로그 엔티티 확인
curl http://localhost:7007/api/catalog/entities

# Tech Insights Facts 확인
curl http://localhost:7007/api/tech-insights/facts
```

---

## 🐛 문제 해결

### 만약 여전히 연결 오류가 발생한다면

#### 1. 환경 변수 다시 로드
```bash
# 터미널 재시작 또는
source ~/.zshrc  # 또는 ~/.bashrc
```

#### 2. PostgreSQL 비밀번호 확인
```bash
# PostgreSQL 컨테이너 환경 변수 확인
docker exec docker.postgres env | grep POSTGRES
```

#### 3. PostgreSQL 재시작
```bash
# 컨테이너 재시작
docker restart docker.postgres

# 재시작 확인
docker ps | grep postgres
```

#### 4. Backstage 캐시 정리
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# node_modules 재설치
rm -rf node_modules
yarn install

# 빌드 캐시 정리
yarn clean
```

---

## 📊 Tech Insights 데이터베이스 스키마

Tech Insights 플러그인이 생성하는 주요 테이블:

### tech_insights_facts 테이블
```sql
CREATE TABLE tech_insights_facts (
  id SERIAL PRIMARY KEY,
  entity_ref VARCHAR(255) NOT NULL,
  fact_retriever_id VARCHAR(255) NOT NULL,
  facts JSONB NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### tech_insights_checks 테이블
```sql
CREATE TABLE tech_insights_checks (
  id SERIAL PRIMARY KEY,
  check_id VARCHAR(255) NOT NULL,
  entity_ref VARCHAR(255) NOT NULL,
  result JSONB NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## 🎯 다음 단계

데이터베이스 설정이 완료되었으므로:

1. ✅ 백엔드 실행 확인
2. ⏳ 프론트엔드 설정 (Entity Page, Dashboard)
3. ⏳ Tech Insights UI 통합
4. ⏳ 실제 DB 모니터링 구현

자세한 내용은 다음 문서를 참조하세요:
- `TECH_INSIGHTS_SETUP_COMPLETE.md` - 백엔드 설정 완료 상태
- `tech_insights_plugin.md` - 전체 설치 가이드

---

**작성일**: 2025-10-21  
**수정자**: Platform Team  
**상태**: 데이터베이스 설정 완료 ✅

