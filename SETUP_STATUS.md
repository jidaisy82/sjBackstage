# Backstage + Tech Insights 설정 상태

## ✅ 완료된 작업

### 1. Tech Blog 카탈로그 설정
- [x] RND-NX tech-blog 컴포넌트 catalog-info.yaml 생성
  - tech-blog-api-server
  - tech-blog-user-client
  - tech-blog-api-server-test
- [x] Backstage 카탈로그 구조 생성 (System, Domain, API, Resource)
- [x] app-config.yaml 설정 완료
- [x] 조직 구조 (팀) 설정 완료

### 2. Tech Insights 플러그인 백엔드 설정
- [x] 백엔드 패키지 설치
  - `@backstage-community/plugin-tech-insights-backend`
  - `@backstage-community/plugin-tech-insights-node`
  - `@backstage-community/plugin-tech-insights-common`
- [x] Fact Retriever 구현 (DB 상태 모니터링)
- [x] Check 규칙 정의
- [x] 백엔드 플러그인 등록

### 3. Tech Insights 플러그인 프론트엔드 준비
- [x] 프론트엔드 패키지 설치
  - `@backstage-community/plugin-tech-insights`
  - `@backstage-community/plugin-tech-insights-common`

### 4. 데이터베이스 설정
- [x] PostgreSQL 컨테이너 확인 (docker.postgres)
- [x] backstage 데이터베이스 생성
- [x] .env 파일 수정 (POSTGRES_DB=backstage)
- [x] 권한 설정 완료

---

## 📂 생성된 파일 구조

```
/Users/seojiwon/VNTG_PROJECT/

├── RND-NX/apps/tech-blog/
│   ├── api-server/catalog-info.yaml          ✅
│   ├── user-client/catalog-info.yaml         ✅
│   └── api-server-test/catalog-info.yaml     ✅
│
└── rnd-backstage/
    ├── catalog/
    │   ├── systems/rnd-nx-framework.yaml     ✅
    │   ├── domains/all-domains.yaml          ✅
    │   ├── apis/tech-blog-rest-api.yaml      ✅
    │   └── resources/tech-blog-database.yaml ✅
    │
    ├── packages/backend/src/plugins/tech-insights/
    │   ├── factRetrievers/
    │   │   └── dbStatusRetriever.ts          ✅
    │   ├── checks/
    │   │   └── dbStatusChecks.ts             ✅
    │   └── index.ts                          ✅
    │
    ├── app-config.yaml                       ✅ (업데이트됨)
    ├── examples/org.yaml                     ✅ (업데이트됨)
    ├── .env                                  ✅ (수정됨)
    │
    └── 문서/
        ├── TECH_BLOG_CATALOG_SETUP.md        ✅
        ├── tech_insights_plugin.md           ✅
        ├── TECH_INSIGHTS_SETUP_COMPLETE.md   ✅
        ├── DATABASE_SETUP_FIX.md             ✅
        └── SETUP_STATUS.md                   ✅ (현재 파일)
```

---

## ⏳ 남은 작업

### 1. 프론트엔드 설정 (우선순위: 높음)
- [ ] Entity Page에 Tech Insights 탭 추가
  - 파일: `packages/app/src/components/catalog/EntityPage.tsx`
- [ ] Tech Insights 대시보드 페이지 생성 (선택사항)
  - 파일: `packages/app/src/components/techInsights/TechInsightsDashboard.tsx`
- [ ] 사이드바 메뉴 추가
  - 파일: `packages/app/src/components/Root/Root.tsx`

### 2. 백엔드 실행 확인 (우선순위: 높음)
- [ ] 백엔드가 정상적으로 시작되는지 확인
- [ ] 포트 7007에서 API 응답 확인
- [ ] Tech Insights Fact Retriever 동작 확인

### 3. 고급 설정 (우선순위: 중간)
- [ ] 실제 PostgreSQL 연결 구현
- [ ] pg 패키지 설치 및 설정
- [ ] 실제 DB 메트릭 수집 로직 구현

### 4. 테스트 및 검증 (우선순위: 중간)
- [ ] Catalog UI에서 tech-blog 컴포넌트 확인
- [ ] Tech Insights Scorecard 결과 확인
- [ ] 의존성 그래프 시각화 확인

---

## 🚀 다음 단계 실행 방법

### Option 1: 백엔드만 실행 (현재 상태 확인)

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# 백엔드 실행
yarn workspace backend start

# 다른 터미널에서 확인
curl http://localhost:7007/healthcheck
curl http://localhost:7007/api/catalog/entities
```

### Option 2: 전체 시스템 실행

```bash
# 터미널 1: 백엔드
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn workspace backend start

# 터미널 2: 프론트엔드
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn workspace app start

# 브라우저에서 접속
# http://localhost:3000
```

### Option 3: 개발 모드 (통합 실행)

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn dev
```

---

## 🔍 현재 상태 확인

### PostgreSQL 데이터베이스
```bash
# 데이터베이스 확인
docker exec docker.postgres psql -U postgres -l

# backstage 데이터베이스 접속
docker exec -it docker.postgres psql -U postgres -d backstage

# 테이블 확인
\dt

# 종료
\q
```

### 환경 변수
```bash
# .env 파일 확인
cat /Users/seojiwon/VNTG_PROJECT/rnd-backstage/.env | grep POSTGRES
```

**현재 설정:**
```
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=postgres
POSTGRES_PASSWORD=post1234
POSTGRES_DB=backstage
```

### 설치된 패키지 확인
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# 백엔드 패키지
cd packages/backend
yarn list --pattern "@backstage-community/plugin-tech-insights*"

# 프론트엔드 패키지
cd packages/app
yarn list --pattern "@backstage-community/plugin-tech-insights*"
```

---

## 📊 예상되는 Tech Insights 기능

### Fact Retriever (30분마다 자동 실행)
- ✅ DB 연결 상태 (`dbConnectionStatus`)
- ✅ DB 응답 시간 (`dbResponseTime`)
- ✅ 활성 연결 수 (`dbConnectionCount`)
- ✅ 디스크 사용률 (`dbDiskUsage`)
- ✅ 마지막 체크 시간 (`lastChecked`)

### Check 규칙
1. ✅ DB 연결 상태 확인
2. ✅ 응답 시간 200ms 이하 확인
3. ✅ 디스크 사용률 80% 이하 확인

### 예상 Scorecard 결과
```
✅ DB 연결 상태: PASS (연결됨)
✅ DB 응답 시간: PASS (120ms < 200ms)
✅ DB 디스크 사용률: PASS (45.5% < 80%)
```

---

## 🐛 문제 해결 가이드

### 백엔드가 시작되지 않는 경우

1. **로그 확인**
   ```bash
   # 백엔드 로그 확인
   tail -f /Users/seojiwon/VNTG_PROJECT/rnd-backstage/packages/backend/dist/index.js
   ```

2. **데이터베이스 연결 확인**
   ```bash
   # PostgreSQL 연결 테스트
   docker exec docker.postgres psql -U postgres -d backstage -c "SELECT 1;"
   ```

3. **포트 충돌 확인**
   ```bash
   # 7007 포트 사용 확인
   lsof -i :7007
   
   # 프로세스 종료 (필요시)
   kill -9 <PID>
   ```

4. **캐시 정리**
   ```bash
   cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
   rm -rf node_modules packages/*/node_modules
   yarn install
   ```

### TypeScript 오류가 발생하는 경우

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# TypeScript 빌드
yarn tsc

# 또는 특정 패키지만
cd packages/backend
yarn tsc
```

### Tech Insights 플러그인 오류

```bash
# Tech Insights 관련 패키지 재설치
cd packages/backend
yarn remove @backstage-community/plugin-tech-insights-backend
yarn remove @backstage-community/plugin-tech-insights-node
yarn add @backstage-community/plugin-tech-insights-backend
yarn add @backstage-community/plugin-tech-insights-node
```

---

## 📚 참고 문서

| 문서 | 설명 |
|------|------|
| `TECH_BLOG_CATALOG_SETUP.md` | Tech Blog 카탈로그 설정 가이드 |
| `tech_insights_plugin.md` | Tech Insights 전체 설치 가이드 |
| `TECH_INSIGHTS_SETUP_COMPLETE.md` | 백엔드 설정 완료 상태 |
| `DATABASE_SETUP_FIX.md` | 데이터베이스 문제 해결 |
| `bs_sw_arc.md` | Backstage 소프트웨어 카탈로그 아키텍처 |

---

## 📞 지원

문제가 발생하면 다음을 확인하세요:
1. PostgreSQL이 실행 중인지 확인
2. .env 파일의 환경 변수가 올바른지 확인
3. 포트 충돌이 없는지 확인
4. 백엔드 로그에서 에러 메시지 확인

---

**작성일**: 2025-10-21  
**작성자**: Platform Team  
**상태**: 백엔드 설정 완료, 프론트엔드 설정 대기 중

