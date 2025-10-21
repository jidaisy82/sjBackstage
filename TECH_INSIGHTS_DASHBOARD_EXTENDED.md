# Tech Insights 대시보드 확장 완료

## 📊 추가된 데이터 항목 (1~10번)

### 기존 항목 (4개)
- ✅ `dbConnectionStatus` - 데이터베이스 연결 상태
- ✅ `dbResponseTime` - 응답 시간(ms)
- ✅ `dbConnectionCount` - 전체 연결 수 (수정)
- ✅ `dbDiskUsage` - 디스크 사용률(%)

### 새롭게 추가된 항목 (11개)

#### 연결 정보 (2개)
3. ✅ `activeConnections` - 활성 연결 수
4. ✅ `idleConnections` - 유휴 연결 수

#### 스토리지 정보 (1개)
5. ✅ `dbSizeMB` - DB 크기(MB)

#### 성능 지표 (2개)
6. ✅ `cacheHitRatio` - 캐시 히트율(%)
7. ✅ `longestQueryDuration` - 최장 쿼리 실행 시간(ms)

#### 데이터베이스 구조 (2개)
8. ✅ `tableCount` - 테이블 개수
9. ✅ `indexCount` - 인덱스 개수

#### 트랜잭션 정보 (1개)
10. ✅ `commitRatio` - 트랜잭션 커밋 비율(%)

#### 락 정보 (1개)
11. ✅ `lockCount` - 현재 락 개수

#### 유지보수 지표 (1개)
12. ✅ `deadTupleRatio` - Dead tuple 비율(%) (VACUUM 필요 여부)

## 🔍 데이터 수집 방법

### 1. 연결 정보
```sql
SELECT 
  count(*) as total_connections,
  count(*) FILTER (WHERE state = 'active') as active_connections,
  count(*) FILTER (WHERE state = 'idle') as idle_connections
FROM pg_stat_activity
WHERE datname = current_database()
```

### 2. 스토리지 정보
```sql
SELECT 
  pg_database_size(current_database()) as size,
  pg_database_size(current_database()) / 1024.0 / 1024.0 as size_mb,
  pg_database_size(current_database()) * 100.0 / 
  NULLIF(pg_tablespace_size('pg_default'), 0) as usage_percent
```

### 3. 캐시 히트율
```sql
SELECT 
  COALESCE(
    sum(heap_blks_hit) / NULLIF(sum(heap_blks_hit) + sum(heap_blks_read), 0) * 100,
    0
  ) as cache_hit_ratio
FROM pg_statio_user_tables
```

### 4. 최장 쿼리 실행 시간
```sql
SELECT 
  COALESCE(
    EXTRACT(EPOCH FROM MAX(now() - query_start)) * 1000,
    0
  ) as longest_duration
FROM pg_stat_activity
WHERE state != 'idle' 
  AND query_start IS NOT NULL
  AND datname = current_database()
```

### 5. 테이블 및 인덱스 개수
```sql
-- 테이블
SELECT count(*) as count 
FROM pg_tables 
WHERE schemaname = 'public'

-- 인덱스
SELECT count(*) as count 
FROM pg_indexes 
WHERE schemaname = 'public'
```

### 6. 트랜잭션 커밋 비율
```sql
SELECT 
  xact_commit,
  xact_rollback,
  COALESCE(
    ROUND(xact_commit::numeric / NULLIF(xact_commit + xact_rollback, 0) * 100, 2),
    0
  ) as commit_ratio
FROM pg_stat_database 
WHERE datname = current_database()
```

### 7. 락 개수
```sql
SELECT count(*) as count FROM pg_locks
```

### 8. Dead tuple 비율
```sql
SELECT 
  COALESCE(
    ROUND(
      sum(n_dead_tup)::numeric / NULLIF(sum(n_live_tup), 0) * 100,
      2
    ),
    0
  ) as dead_tuple_ratio
FROM pg_stat_user_tables
```

## ✅ Tech Insights Checks (10개)

### 1. DB 연결 상태
- **Check**: `db-connection-active`
- **조건**: `dbConnectionStatus == true`
- **설명**: 데이터베이스가 정상적으로 연결되어 있는지 확인

### 2. DB 응답 시간
- **Check**: `db-response-time-healthy`
- **조건**: `dbResponseTime <= 200ms`
- **설명**: 데이터베이스 응답 시간이 200ms 이하인지 확인

### 3. 활성 연결 수
- **Check**: `db-active-connections-normal`
- **조건**: `activeConnections <= 50`
- **설명**: 활성 연결 수가 50개 이하인지 확인

### 4. 유휴 연결 수
- **Check**: `db-idle-connections-normal`
- **조건**: `idleConnections <= 20`
- **설명**: 유휴 연결 수가 20개 이하인지 확인 (연결 누수 방지)

### 5. DB 디스크 사용률
- **Check**: `db-disk-usage-normal`
- **조건**: `dbDiskUsage <= 80%`
- **설명**: 디스크 사용률이 80% 이하인지 확인

### 6. DB 크기
- **Check**: `db-size-normal`
- **조건**: `dbSizeMB <= 10240 (10GB)`
- **설명**: DB 크기가 10GB 이하인지 확인

### 7. 캐시 히트율
- **Check**: `db-cache-hit-ratio-good`
- **조건**: `cacheHitRatio >= 90%`
- **설명**: 캐시 히트율이 90% 이상인지 확인

### 8. 최장 쿼리 실행 시간
- **Check**: `db-longest-query-duration-normal`
- **조건**: `longestQueryDuration <= 30000ms (30초)`
- **설명**: 가장 오래 실행 중인 쿼리가 30초 이하인지 확인

### 9. 트랜잭션 커밋 비율
- **Check**: `db-commit-ratio-good`
- **조건**: `commitRatio >= 95%`
- **설명**: 트랜잭션 커밋 비율이 95% 이상인지 확인

### 10. Dead Tuple 비율
- **Check**: `db-dead-tuple-ratio-low`
- **조건**: `deadTupleRatio <= 10%`
- **설명**: Dead tuple 비율이 10% 이하인지 확인 (VACUUM 필요 여부)

## 📈 예상 대시보드 레이아웃

### 기본 상태
- 🟢 **연결 상태**: 정상
- ⚡ **응답 시간**: 15ms
- 📅 **마지막 체크**: 2025-10-21 19:30:00

### 연결 정보
- 📊 **전체 연결**: 36개
- 🔥 **활성 연결**: 5개 (정상: ≤50)
- 💤 **유휴 연결**: 31개 (주의: ≤20)

### 스토리지 정보
- 💾 **디스크 사용률**: 5.26% (정상: ≤80%)
- 📦 **DB 크기**: 45.2 MB (정상: ≤10GB)

### 성능 지표
- ⚡ **캐시 히트율**: 95.3% (정상: ≥90%)
- ⏱️ **최장 쿼리**: 1,250ms (정상: ≤30초)

### 데이터베이스 구조
- 📋 **테이블**: 25개
- 🔑 **인덱스**: 48개

### 트랜잭션 정보
- ✅ **커밋 비율**: 99.8% (정상: ≥95%)

### 락 정보
- 🔒 **현재 락**: 12개

### 유지보수 지표
- 🧹 **Dead Tuple**: 2.3% (정상: ≤10%)

## 🚀 실행 방법

```bash
# Backstage 재시작
yarn start
```

## 📍 확인 위치

1. **Entity Page**: 
   - `http://localhost:3000/catalog/default/resource/tech-blog-database`
   - "Tech Insights" 탭

2. **Overview 카드**:
   - Entity Overview 페이지의 "데이터베이스 상태 점검" 카드

3. **Tech Insights Dashboard**:
   - `http://localhost:3000/tech-insights`

## 🎯 임계값 조정 가이드

### 연결 수
```yaml
# 활성 연결 수 임계값 변경 (50 → 100)
- fact: activeConnections
  operator: lessThanInclusive
  value: 100  # 변경
```

### 캐시 히트율
```yaml
# 캐시 히트율 임계값 변경 (90% → 85%)
- fact: cacheHitRatio
  operator: greaterThanInclusive
  value: 85  # 변경
```

### 쿼리 실행 시간
```yaml
# 최장 쿼리 시간 임계값 변경 (30초 → 60초)
- fact: longestQueryDuration
  operator: lessThanInclusive
  value: 60000  # 30000 → 60000 (ms)
```

## 📊 모니터링 권장 사항

### High Priority (즉시 확인 필요)
- 🔴 **연결 상태** = false
- 🔴 **응답 시간** > 200ms
- 🔴 **활성 연결** > 50
- 🔴 **디스크 사용률** > 80%

### Medium Priority (주의 필요)
- 🟡 **유휴 연결** > 20 (연결 누수 가능성)
- 🟡 **캐시 히트율** < 90% (성능 저하)
- 🟡 **최장 쿼리** > 30초 (슬로우 쿼리)
- 🟡 **Dead Tuple** > 10% (VACUUM 필요)

### Low Priority (정기 확인)
- 🟢 **DB 크기** (용량 계획)
- 🟢 **커밋 비율** (애플리케이션 안정성)
- 🟢 **락 개수** (동시성 이슈)
- 🟢 **테이블/인덱스 수** (스키마 변경 추적)

## 📝 다음 단계

1. ✅ Backstage 재시작
2. ✅ `tech-blog-database` 리소스 페이지 접속
3. ✅ "Tech Insights" 탭에서 10개 체크 항목 확인
4. ✅ Overview의 Scorecard 확인
5. ⏭️ 임계값 조정 (필요시)
6. ⏭️ 알림 설정 추가 (선택사항)

## 🎉 완료!

이제 Tech Blog 데이터베이스의 **15개 지표**를 실시간으로 모니터링할 수 있으며, **10개의 자동 체크**가 데이터베이스 상태를 지속적으로 확인합니다!

