# RND-NX Backstage Catalog 전체 문서

> **작성일**: 2025-10-23  
> **프로젝트**: RND-NX Monorepo  
> **Backstage 버전**: Latest  
> **상태**: ✅ 확장 완료

---

## 📋 목차

1. [개요](#개요)
2. [Catalog 아키텍처](#catalog-아키텍처)
3. [전체 엔티티 목록](#전체-엔티티-목록)
4. [도메인별 상세 설명](#도메인별-상세-설명)
5. [의존성 관계도](#의존성-관계도)
6. [설정 파일](#설정-파일)
7. [사용 가이드](#사용-가이드)
8. [확장 이력](#확장-이력)
9. [다음 단계](#다음-단계)

---

## 개요

### 프로젝트 배경

**RND-NX**는 Nx 모노레포 기반의 차세대 통합 개발 프레임워크입니다. 이 프로젝트는 다음과 같은 특징을 가지고 있습니다:

- **모노레포 구조**: Nx를 활용한 효율적인 코드 관리
- **풀스택 개발**: NestJS(Backend) + React(Frontend)
- **인프라 자동화**: Terraform + Ansible + ArgoCD
- **이벤트 기반 아키텍처**: Kafka를 통한 마이크로서비스 통신
- **클라우드 네이티브**: GCP 기반 Kubernetes 배포

### Backstage Catalog의 역할

Backstage Catalog는 RND-NX 프로젝트의 모든 컴포넌트, 서비스, 인프라 리소스를 중앙에서 관리하고 시각화하는 역할을 합니다:

- ✅ **서비스 디스커버리**: 전체 시스템 구성 요소 한눈에 파악
- ✅ **의존성 관리**: 컴포넌트 간 관계 추적 및 시각화
- ✅ **소유권 명확화**: 팀별 책임 영역 정의
- ✅ **문서화 통합**: TechDocs를 통한 API 문서 호스팅
- ✅ **운영 효율화**: Tech Insights를 통한 헬스 체크 자동화

### 확장 범위

| 단계 | 범위 | 상태 |
|------|------|------|
| **Phase 1** | Tech Blog 애플리케이션 | ✅ 완료 |
| **Phase 2** | Backend 라이브러리 확장 | ✅ 완료 |
| **Phase 3** | GCP 인프라 리소스 | ✅ 완료 |
| **Phase 4** | ArgoCD & GitOps | ✅ 완료 |
| **Phase 5** | 추가 인프라 (Kafka, Loki) | ✅ 완료 |

---

## Catalog 아키텍처

### 계층 구조

```
rnd-nx-framework (System)
│
├── Domains (4개)
│   ├── backend-services
│   ├── frontend-applications
│   ├── shared-libraries
│   └── infrastructure
│
├── Components (10개)
│   ├── Services (2개)
│   ├── Websites (1개)
│   └── Libraries (7개)
│
├── APIs (2개)
│   ├── tech-blog-rest-api
│   └── websocket-chat-api
│
└── Resources (14개)
    ├── Databases (2개)
    ├── Kubernetes (3개)
    ├── Networks (3개)
    ├── ArgoCD (3개)
    ├── Messaging (1개)
    ├── Monitoring (1개)
    └── Development (1개)
```

### 엔티티 타입별 분류

| 엔티티 타입 | 개수 | 설명 |
|------------|------|------|
| **System** | 1 | rnd-nx-framework |
| **Domain** | 4 | 비즈니스 도메인 구분 |
| **Component** | 10 | 애플리케이션 및 라이브러리 |
| **API** | 2 | REST API, WebSocket API |
| **Resource** | 14 | 인프라 리소스 (DB, K8s, 네트워크) |
| **Group** | 5 | 팀 조직 구조 |
| **User** | N | 사용자 정보 |
| **총계** | **31+** | - |

---

## 전체 엔티티 목록

### 1. System (1개)

#### `rnd-nx-framework`
```yaml
kind: System
metadata:
  name: rnd-nx-framework
  description: 차세대 통합 개발 프레임워크 - Nx 모노레포 기반
spec:
  owner: group:platform-team
  domain: engineering
```

**주요 특징:**
- Nx 모노레포 기반 통합 프레임워크
- 풀스택 개발 환경 제공
- 멀티 클라우드 지원 (GCP, On-Premise)

---

### 2. Domains (4개)

#### A. `backend-services`
- **설명**: 백엔드 API 서버 및 마이크로서비스 도메인
- **Owner**: `backend-team`
- **포함 컴포넌트**: 
  - tech-blog-api-server
  - tech-blog-api-server-test
  - be-* 라이브러리들

#### B. `frontend-applications`
- **설명**: 사용자 대면 프론트엔드 애플리케이션 도메인
- **Owner**: `frontend-team`
- **포함 컴포넌트**:
  - tech-blog-user-client
  - ui-component-library
  - design-tokens-library

#### C. `shared-libraries`
- **설명**: 재사용 가능한 공유 라이브러리 도메인
- **Owner**: `platform-team`
- **포함 컴포넌트**:
  - 백엔드/프론트엔드 공통 라이브러리

#### D. `infrastructure`
- **설명**: 인프라 및 DevOps 리소스 도메인
- **Owner**: `devops-team`
- **포함 컴포넌트**:
  - Terraform 모듈
  - Ansible 롤
  - GCP 리소스

---

### 3. Components (10개)

#### 📦 A. Services (2개)

##### 1. `tech-blog-api-server`
```yaml
kind: Component
spec:
  type: service
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
  domain: backend-services
  providesApis:
    - tech-blog-rest-api
  dependsOn:
    - resource:tech-blog-database
```

**기술 스택:**
- NestJS + TypeScript
- Prisma ORM + PostgreSQL
- JWT 인증/인가
- Kafka 이벤트 스트리밍
- WebSocket 실시간 채팅

**주요 기능:**
- 블로그 포스트 CRUD
- 사용자 인증 및 권한 관리
- 실시간 댓글 알림
- 이벤트 기반 비동기 처리

**엔드포인트:**
- Local Dev: `http://localhost:3001`
- Swagger Docs: `http://localhost:3001/api-docs`

##### 2. `tech-blog-api-server-test`
```yaml
kind: Component
spec:
  type: service
  lifecycle: experimental
  owner: group:backend-team
  system: rnd-nx-framework
  domain: backend-services
```

**목적:**
- 테스트 환경 격리
- CI/CD 파이프라인 검증
- 새로운 기능 실험

---

#### 🌐 B. Websites (1개)

##### 3. `tech-blog-user-client`
```yaml
kind: Component
spec:
  type: website
  lifecycle: production
  owner: group:frontend-team
  system: rnd-nx-framework
  domain: frontend-applications
  consumesApis:
    - tech-blog-rest-api
    - websocket-chat-api
  dependsOn:
    - component:ui-component-library
    - component:design-tokens-library
```

**기술 스택:**
- React 18 + TypeScript
- Vite 빌드 시스템
- TailwindCSS + shadcn/ui
- React Query (데이터 페칭)
- Zustand (상태 관리)

**주요 페이지:**
- `/` - 블로그 포스트 목록
- `/posts/:id` - 포스트 상세
- `/write` - 포스트 작성
- `/profile` - 사용자 프로필

**엔드포인트:**
- Local Dev: `http://localhost:4200`

---

#### 📚 C. Libraries (7개)

##### Backend Libraries (4개)

###### 4. `be-users-library`
```yaml
kind: Component
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  domain: backend-services
  dependsOn:
    - component:be-prisma-library
    - component:be-common-library
```

**제공 기능:**
- 사용자 CRUD 연산
- 프로필 관리
- 권한 검증 유틸리티

**Nx Project**: `@rnd-nx/be-users`

---

###### 5. `be-kafka-core-library`
```yaml
kind: Component
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  domain: backend-services
  dependsOn:
    - resource:kafka-cluster
```

**제공 기능:**
- Kafka Producer/Consumer 추상화
- 이벤트 발행/구독 패턴
- 재시도 로직 및 에러 핸들링
- 메시지 스키마 검증

**주요 모듈:**
- `KafkaProducerService`
- `KafkaConsumerService`
- `KafkaAdminService`

**Nx Project**: `@rnd-nx/be-kafka-core`

---

###### 6. `be-websocket-library`
```yaml
kind: Component
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  domain: backend-services
  providesApis:
    - websocket-chat-api
```

**제공 기능:**
- WebSocket 연결 관리
- 실시간 채팅 룸
- 메시지 브로드캐스팅
- 온라인 사용자 추적

**이벤트 타입:**
- `chat:message` - 메시지 전송
- `chat:join` - 채팅방 입장
- `chat:leave` - 채팅방 퇴장
- `chat:typing` - 타이핑 상태

**Nx Project**: `@rnd-nx/be-websocket`

---

###### 7. `be-swagger-library`
```yaml
kind: Component
spec:
  type: library
  lifecycle: production
  owner: group:backend-team
  domain: backend-services
```

**제공 기능:**
- Swagger/OpenAPI 문서 자동 생성
- API 엔드포인트 데코레이터
- DTO 스키마 자동화
- 인증 스키마 정의

**Nx Project**: `@rnd-nx/be-swagger`

---

##### Frontend Libraries (1개)

###### 8. `fe-cursor-figma-mcp`
```yaml
kind: Component
spec:
  type: library
  lifecycle: experimental
  owner: group:frontend-team
  domain: frontend-applications
```

**제공 기능:**
- Figma 디자인 토큰 추출
- Cursor IDE 통합
- shadcn/ui 컴포넌트 자동 생성
- 디자인-코드 동기화

**기술:**
- Model Context Protocol (MCP)
- Figma REST API
- AST 파싱 및 코드 생성

**Nx Project**: `@rnd-nx/fe-cursor-figma-mcp`

---

##### Infrastructure Libraries (2개)

###### 9. `terraform-gke-module`
```yaml
kind: Component
spec:
  type: library
  lifecycle: production
  owner: group:devops-team
  domain: infrastructure
```

**제공 기능:**
- 재사용 가능한 GKE 클러스터 모듈
- VPC 네트워크 설정
- Node Pool 구성
- IAM 권한 관리

**모듈 파일:**
- `main.tf` - 메인 리소스 정의
- `variables.tf` - 입력 변수
- `outputs.tf` - 출력 값
- `versions.tf` - Provider 버전

**경로**: `/infra/gcp/modules/gke-cluster`

---

###### 10. `ansible-common-setup`
```yaml
kind: Component
spec:
  type: library
  lifecycle: production
  owner: group:devops-team
  domain: infrastructure
```

**제공 기능:**
- 서버 초기 설정 자동화
- 패키지 설치 및 업데이트
- 방화벽 규칙 설정
- 모니터링 에이전트 배포

**Role 구조:**
- `tasks/main.yml` - 주요 태스크
- `handlers/main.yml` - 이벤트 핸들러
- `defaults/main.yml` - 기본 변수
- `templates/` - 설정 파일 템플릿

**경로**: `/libs/infra/ansible/roles/common-setup`

---

### 4. APIs (2개)

#### A. `tech-blog-rest-api`
```yaml
kind: API
spec:
  type: openapi
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
```

**엔드포인트 그룹:**

##### 인증 (Auth)
- `POST /auth/signup` - 회원가입
- `POST /auth/login` - 로그인
- `POST /auth/refresh` - 토큰 갱신
- `POST /auth/logout` - 로그아웃

##### 포스트 (Posts)
- `GET /posts` - 포스트 목록 (페이지네이션)
- `GET /posts/:id` - 포스트 상세
- `POST /posts` - 포스트 작성
- `PUT /posts/:id` - 포스트 수정
- `DELETE /posts/:id` - 포스트 삭제

##### 댓글 (Comments)
- `GET /posts/:id/comments` - 댓글 목록
- `POST /posts/:id/comments` - 댓글 작성
- `PUT /comments/:id` - 댓글 수정
- `DELETE /comments/:id` - 댓글 삭제

##### 사용자 (Users)
- `GET /users/me` - 내 프로필
- `PUT /users/me` - 프로필 수정
- `GET /users/:id` - 사용자 프로필

**OpenAPI 문서**: `http://localhost:3001/api-docs`

---

#### B. `websocket-chat-api`
```yaml
kind: API
spec:
  type: websocket
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
```

**WebSocket 이벤트:**

##### Client → Server
```typescript
// 채팅방 입장
socket.emit('chat:join', { roomId: string, userId: string })

// 메시지 전송
socket.emit('chat:message', { 
  roomId: string, 
  userId: string, 
  message: string 
})

// 타이핑 상태
socket.emit('chat:typing', { roomId: string, userId: string })

// 채팅방 퇴장
socket.emit('chat:leave', { roomId: string, userId: string })
```

##### Server → Client
```typescript
// 사용자 입장 알림
socket.on('chat:user-joined', { userId: string, username: string })

// 새 메시지 수신
socket.on('chat:new-message', { 
  messageId: string,
  userId: string, 
  username: string,
  message: string,
  timestamp: string
})

// 타이핑 상태 알림
socket.on('chat:user-typing', { userId: string, username: string })

// 사용자 퇴장 알림
socket.on('chat:user-left', { userId: string, username: string })
```

**WebSocket 엔드포인트**: `ws://localhost:3001/chat`

---

### 5. Resources (14개)

#### 📊 A. Databases (2개)

##### 1. `tech-blog-database`
```yaml
kind: Resource
spec:
  type: database
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
```

**데이터베이스 정보:**
- **엔진**: PostgreSQL 15
- **환경**: Local Docker / GCP Cloud SQL
- **포트**: 5432
- **스키마**: Prisma ORM 관리

**주요 테이블:**
- `users` - 사용자 정보
- `posts` - 블로그 포스트
- `comments` - 댓글
- `tags` - 태그
- `sessions` - 세션 정보

**Tech Insights 모니터링:**
- ✅ 연결 상태 체크
- ✅ 응답 시간 (< 200ms)
- ✅ 활성 연결 수 (< 50개)
- ✅ 캐시 히트율 (> 90%)
- ✅ 디스크 사용률 (< 80%)

---

##### 2. `cloudsql-test`
```yaml
kind: Resource
spec:
  type: database
  lifecycle: experimental
  owner: group:backend-team
  system: rnd-nx-framework
  dependsOn:
    - resource:gcp-vpc-test
```

**데이터베이스 정보:**
- **엔진**: Cloud SQL PostgreSQL
- **환경**: GCP Test 환경
- **인스턴스 타입**: db-f1-micro
- **VPC**: gcp-vpc-test

**사용 목적:**
- CI/CD 테스트 환경
- 통합 테스트 데이터
- 성능 테스트 베이스라인

**GCP Console**: `https://console.cloud.google.com/sql`

---

#### ☸️ B. Kubernetes Clusters (3개)

##### 3. `gke-dev-cluster`
```yaml
kind: Resource
spec:
  type: kubernetes-cluster
  lifecycle: production
  owner: group:devops-team
  system: rnd-nx-framework
  dependsOn:
    - resource:gcp-vpc-dev
```

**클러스터 정보:**
- **환경**: Development
- **GCP Region**: asia-northeast3 (Seoul)
- **Kubernetes 버전**: 1.28+
- **Node Pool**: 
  - 최소 노드: 1
  - 최대 노드: 5
  - Machine Type: e2-medium

**배포 애플리케이션:**
- tech-blog-api-server (dev)
- tech-blog-user-client (dev)
- PostgreSQL (StatefulSet)
- Kafka (StatefulSet)

**Terraform 관리**: `/infra/gcp/environments/dev/gke.tf`

---

##### 4. `gke-test-cluster`
```yaml
kind: Resource
spec:
  type: kubernetes-cluster
  lifecycle: production
  owner: group:devops-team
  system: rnd-nx-framework
  dependsOn:
    - resource:gcp-vpc-test
```

**클러스터 정보:**
- **환경**: Test/Staging
- **GCP Region**: asia-northeast3
- **Node Pool**: 
  - 최소 노드: 2
  - 최대 노드: 10

**용도:**
- QA 테스트 환경
- 성능 테스트
- 프로덕션 배포 전 검증

---

##### 5. `gke-prod-cluster`
```yaml
kind: Resource
spec:
  type: kubernetes-cluster
  lifecycle: production
  owner: group:devops-team
  system: rnd-nx-framework
  dependsOn:
    - resource:gcp-vpc-prod
```

**클러스터 정보:**
- **환경**: Production
- **GCP Region**: Multi-region (HA)
- **Node Pool**: 
  - 최소 노드: 3
  - 최대 노드: 20
  - Machine Type: n2-standard-4

**고가용성:**
- ✅ Multi-zone 배포
- ✅ Auto-healing
- ✅ Auto-scaling
- ✅ 백업 자동화

---

#### 🌐 C. Networks (3개)

##### 6. `gcp-vpc-dev`
```yaml
kind: Resource
spec:
  type: network
  lifecycle: production
  owner: group:devops-team
  system: rnd-nx-framework
```

**네트워크 정보:**
- **CIDR**: 10.0.0.0/16
- **Subnet**: 
  - `gke-subnet-dev`: 10.0.1.0/24
  - `db-subnet-dev`: 10.0.2.0/24

---

##### 7. `gcp-vpc-test`
- **CIDR**: 10.1.0.0/16

---

##### 8. `gcp-vpc-prod`
- **CIDR**: 10.2.0.0/16
- **고가용성**: Multi-region

---

#### 🔄 D. ArgoCD Applications (3개)

##### 9. `argocd-dev-shared`
```yaml
kind: Resource
spec:
  type: argocd-application
  lifecycle: production
  owner: group:devops-team
  system: rnd-nx-framework
```

**ArgoCD Application 정보:**
- **환경**: Development 공유 리소스
- **Git 저장소**: RND-NX/k8s/overlays/dev
- **대상 클러스터**: gke-dev-cluster
- **Sync 정책**: Auto-sync

**배포 리소스:**
- ConfigMaps
- Secrets
- PersistentVolumeClaims
- Services (공통)

**ArgoCD URL**: `https://argocd.dev.your-domain.com`

---

##### 10. `argocd-prod-shared`
- **환경**: Production 공유 리소스
- **Sync 정책**: Manual approval

---

##### 11. `argocd-sample-service`
- **환경**: Sample/Demo 서비스
- **용도**: GitOps 워크플로우 데모

---

#### 📨 E. Messaging (1개)

##### 12. `kafka-cluster`
```yaml
kind: Resource
spec:
  type: message-broker
  lifecycle: production
  owner: group:backend-team
  system: rnd-nx-framework
```

**Kafka 클러스터 정보:**
- **버전**: Apache Kafka 3.5+
- **Brokers**: 3 (HA 구성)
- **Zookeeper**: 3 노드 앙상블

**주요 Topics:**
- `tech-blog.posts.created` - 포스트 생성 이벤트
- `tech-blog.posts.updated` - 포스트 수정 이벤트
- `tech-blog.comments.added` - 댓글 추가 이벤트
- `tech-blog.users.registered` - 회원가입 이벤트

**Consumer Groups:**
- `notification-service` - 알림 전송
- `analytics-service` - 분석 데이터 수집
- `search-indexer` - 검색 인덱스 업데이트

**배포 환경:**
- Local: Docker Compose
- Dev/Test/Prod: Kubernetes StatefulSet

---

#### 📊 F. Monitoring (1개)

##### 13. `loki-grafana-stack`
```yaml
kind: Resource
spec:
  type: monitoring-system
  lifecycle: production
  owner: group:devops-team
  system: rnd-nx-framework
```

**모니터링 스택 구성:**

**Loki (로그 수집)**
- 모든 Kubernetes Pod 로그 수집
- 쿼리 언어: LogQL
- 보존 기간: 30일

**Grafana (대시보드)**
- **URL**: `http://localhost:3000` (로컬)
- **대시보드**:
  - Application Logs
  - Kubernetes Cluster Metrics
  - Database Performance
  - API Response Times
  - Error Rates & Alerts

**Promtail (로그 전송 에이전트)**
- DaemonSet으로 모든 노드에 배포
- 로그 라벨링 및 필터링

**Alert Rules:**
- 🚨 Error rate > 5%
- 🚨 API response time > 1s
- 🚨 Database connection pool exhausted
- 🚨 Disk usage > 85%

---

#### 🛠️ G. Development (1개)

##### 14. `local-docker-env`
```yaml
kind: Resource
spec:
  type: development-environment
  lifecycle: experimental
  owner: group:platform-team
  system: rnd-nx-framework
```

**Docker Compose 스택:**
```yaml
services:
  postgres:
    image: postgres:15
    ports: ["5432:5432"]
  
  kafka:
    image: confluentinc/cp-kafka:7.5.0
    ports: ["9092:9092"]
  
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
  
  grafana:
    image: grafana/grafana:10.0.0
    ports: ["3000:3000"]
  
  loki:
    image: grafana/loki:2.9.0
    ports: ["3100:3100"]
```

**시작 방법:**
```bash
cd /Users/seojiwon/VNTG_PROJECT/RND-NX/infra/local
docker-compose up -d
```

**사용 목적:**
- 로컬 개발 환경 구성
- 외부 의존성 없이 개발
- CI/CD 파이프라인 로컬 테스트

---

## 도메인별 상세 설명

### Backend Services Domain

**책임 범위:**
- RESTful API 서버 개발
- 비즈니스 로직 구현
- 데이터베이스 스키마 관리
- 이벤트 기반 아키텍처 설계

**팀 구성:** `group:backend-team`

**기술 스택:**
- NestJS (Node.js Framework)
- TypeScript
- Prisma ORM
- PostgreSQL
- Kafka
- WebSocket (Socket.io)
- JWT (인증)

**컴포넌트 목록:**
1. tech-blog-api-server (Service)
2. tech-blog-api-server-test (Service)
3. be-users-library (Library)
4. be-kafka-core-library (Library)
5. be-websocket-library (Library)
6. be-swagger-library (Library)

**의존성:**
- tech-blog-database (Resource)
- kafka-cluster (Resource)
- be-common-library (기존)
- be-prisma-library (기존)
- be-auth-library (기존)

---

### Frontend Applications Domain

**책임 범위:**
- 사용자 UI/UX 개발
- 상태 관리
- API 통합
- 반응형 디자인

**팀 구성:** `group:frontend-team`

**기술 스택:**
- React 18
- TypeScript
- Vite
- TailwindCSS
- shadcn/ui
- React Query
- Zustand

**컴포넌트 목록:**
1. tech-blog-user-client (Website)
2. ui-component-library (기존)
3. design-tokens-library (기존)
4. fe-cursor-figma-mcp (Library)

**의존성:**
- tech-blog-rest-api (API)
- websocket-chat-api (API)
- ui-component-library
- design-tokens-library

---

### Shared Libraries Domain

**책임 범위:**
- 재사용 가능한 코드 모듈 개발
- 공통 유틸리티 함수
- 타입 정의 공유
- 디자인 시스템 관리

**팀 구성:** `group:platform-team`

**라이브러리 목록:**
- be-common-library (기존)
- be-prisma-library (기존)
- be-auth-library (기존)
- ui-component-library (기존)
- design-tokens-library (기존)

---

### Infrastructure Domain

**책임 범위:**
- 인프라 프로비저닝
- CI/CD 파이프라인 구축
- 모니터링 및 로깅
- 보안 및 네트워크 관리

**팀 구성:** `group:devops-team`

**기술 스택:**
- Terraform (IaC)
- Ansible (Configuration Management)
- ArgoCD (GitOps)
- Kubernetes (Orchestration)
- GCP (Cloud Provider)

**컴포넌트 & 리소스:**
1. terraform-gke-module (Component)
2. ansible-common-setup (Component)
3. gke-dev/test/prod-cluster (Resources)
4. gcp-vpc-dev/test/prod (Resources)
5. argocd-* (Resources)
6. kafka-cluster (Resource)
7. loki-grafana-stack (Resource)

---

## 의존성 관계도

### 주요 의존성 체인

```
tech-blog-user-client (Website)
  ├── consumesApis:
  │   ├── tech-blog-rest-api (API)
  │   └── websocket-chat-api (API)
  └── dependsOn:
      ├── ui-component-library (Library)
      └── design-tokens-library (Library)

tech-blog-api-server (Service)
  ├── providesApis:
  │   └── tech-blog-rest-api (API)
  ├── dependsOn:
  │   ├── tech-blog-database (Resource)
  │   ├── kafka-cluster (Resource)
  │   ├── be-users-library (Library)
  │   ├── be-kafka-core-library (Library)
  │   ├── be-websocket-library (Library)
  │   ├── be-common-library (Library)
  │   ├── be-prisma-library (Library)
  │   └── be-auth-library (Library)
  └── deployedOn:
      └── gke-dev-cluster (Resource)

be-users-library (Library)
  └── dependsOn:
      ├── be-prisma-library (Library)
      └── be-common-library (Library)

be-kafka-core-library (Library)
  └── dependsOn:
      └── kafka-cluster (Resource)

be-websocket-library (Library)
  └── providesApis:
      └── websocket-chat-api (API)

gke-dev-cluster (Resource)
  ├── dependsOn:
  │   └── gcp-vpc-dev (Resource)
  └── managedBy:
      ├── terraform-gke-module (Component)
      └── argocd-dev-shared (Resource)
```

### 레이어별 의존성

```
┌─────────────────────────────────────────┐
│   Presentation Layer (사용자 UI)         │
│   - tech-blog-user-client               │
└─────────────────┬───────────────────────┘
                  │ consumes
┌─────────────────▼───────────────────────┐
│   API Layer (API 계약)                   │
│   - tech-blog-rest-api                  │
│   - websocket-chat-api                  │
└─────────────────┬───────────────────────┘
                  │ provided by
┌─────────────────▼───────────────────────┐
│   Application Layer (비즈니스 로직)      │
│   - tech-blog-api-server                │
└─────────────────┬───────────────────────┘
                  │ depends on
┌─────────────────▼───────────────────────┐
│   Library Layer (공통 모듈)              │
│   - be-users-library                    │
│   - be-kafka-core-library               │
│   - be-websocket-library                │
│   - be-common/prisma/auth               │
└─────────────────┬───────────────────────┘
                  │ depends on
┌─────────────────▼───────────────────────┐
│   Infrastructure Layer (인프라)          │
│   - tech-blog-database                  │
│   - kafka-cluster                       │
│   - gke-*-cluster                       │
└─────────────────────────────────────────┘
```

---

## 설정 파일

### app-config.yaml

Backstage의 메인 설정 파일에 총 **31개의 catalog location**이 등록되어 있습니다:

```yaml
catalog:
  locations:
    # System & Domains (5개)
    - rnd-nx-framework.yaml
    - all-domains.yaml
    - org.yaml
    
    # Tech Blog 애플리케이션 (3개)
    - tech-blog-api-server/catalog-info.yaml
    - tech-blog-user-client/catalog-info.yaml
    - tech-blog-api-server-test/catalog-info.yaml
    
    # Backend Libraries (4개)
    - be-users-library.yaml
    - be-kafka-core-library.yaml
    - be-websocket-library.yaml
    - be-swagger-library.yaml
    
    # Frontend Libraries (1개)
    - fe-cursor-figma-mcp.yaml
    
    # Infrastructure Components (2개)
    - terraform-gke-module.yaml
    - ansible-common-setup.yaml
    
    # APIs (2개)
    - tech-blog-rest-api.yaml
    - websocket-chat-api.yaml
    
    # Resources (14개)
    - tech-blog-database.yaml
    - gke-dev-cluster.yaml
    - gke-test-cluster.yaml
    - gke-prod-cluster.yaml
    - cloudsql-test.yaml
    - gcp-vpc-dev.yaml
    - gcp-vpc-test.yaml
    - gcp-vpc-prod.yaml
    - argocd-dev-shared.yaml
    - argocd-prod-shared.yaml
    - argocd-sample-service.yaml
    - kafka-cluster.yaml
    - loki-grafana-stack.yaml
    - local-docker-env.yaml
```

---

## 사용 가이드

### 1. Backstage 시작하기

```bash
# 1. 의존성 설치
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn install

# 2. 환경 변수 설정 (.env)
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage
POSTGRES_DB=backstage
BACKEND_SECRET=<random-secret>
GITHUB_TOKEN=<your-github-token>

# 3. 데이터베이스 마이그레이션
yarn backstage-cli backend:bundle
yarn workspace backend migrate:run

# 4. Backstage 실행
yarn dev
```

**접속:**
- Frontend: `http://localhost:3000`
- Backend: `http://localhost:7007`

---

### 2. Catalog 탐색

#### 전체 Catalog 보기
```
http://localhost:3000/catalog
```

#### 필터링 옵션

**Kind 별 필터:**
- Components: `http://localhost:3000/catalog?filters[kind]=component`
- Resources: `http://localhost:3000/catalog?filters[kind]=resource`
- APIs: `http://localhost:3000/catalog?filters[kind]=api`

**Domain 별 필터:**
- Backend: `http://localhost:3000/catalog?filters[domain]=backend-services`
- Frontend: `http://localhost:3000/catalog?filters[domain]=frontend-applications`
- Infra: `http://localhost:3000/catalog?filters[domain]=infrastructure`

**Tag 별 필터:**
- NestJS: `?filters[tags]=nestjs`
- Kafka: `?filters[tags]=kafka`
- GCP: `?filters[tags]=gcp`
- Kubernetes: `?filters[tags]=kubernetes`

**Owner 별 필터:**
- Backend Team: `?filters[owner]=backend-team`
- Frontend Team: `?filters[owner]=frontend-team`
- DevOps Team: `?filters[owner]=devops-team`

---

### 3. 의존성 그래프 확인

각 엔티티 상세 페이지에서 **"Dependencies"** 탭을 클릭하면:

- ✅ **Depends On**: 이 컴포넌트가 의존하는 다른 엔티티
- ✅ **Provides**: 이 컴포넌트가 제공하는 API
- ✅ **Consumes**: 이 컴포넌트가 사용하는 API
- ✅ **Dependency Of**: 이 컴포넌트에 의존하는 다른 엔티티

**예시: tech-blog-api-server 의존성**
```
Depends On:
  ├── resource:tech-blog-database
  ├── resource:kafka-cluster
  ├── component:be-users-library
  ├── component:be-kafka-core-library
  └── component:be-websocket-library

Provides:
  └── api:tech-blog-rest-api

Dependency Of:
  └── component:tech-blog-user-client
```

---

### 4. Tech Insights 확인

**Database Health 대시보드:**
```
http://localhost:3000/tech-insights
```

**모니터링 항목:**
1. ✅ DB 연결 상태
2. ✅ DB 응답 시간 (< 200ms)
3. ✅ 활성 연결 수 (< 50개)
4. ✅ 유휴 연결 수 (< 20개)
5. ✅ 디스크 사용률 (< 80%)
6. ✅ DB 크기 (< 10GB)
7. ✅ 캐시 히트율 (> 90%)
8. ✅ 최장 쿼리 실행 시간 (< 30초)
9. ✅ 트랜잭션 커밋 비율 (> 95%)
10. ✅ Dead Tuple 비율 (< 10%)

**Fact Retriever:**
- 실행 주기: 매 1분
- TTL: 24시간
- 데이터 소스: tech-blog-database

---

### 5. TechDocs 문서화

**System 문서 확인:**
```
http://localhost:3000/docs/default/system/rnd-nx-framework
```

**문서 구조:**
```
docs/
├── index.md (시스템 개요)
├── architecture.md (아키텍처 다이어그램)
├── getting-started.md (시작 가이드)
├── api-reference.md (API 레퍼런스)
└── deployment.md (배포 가이드)
```

---

### 6. API 문서 확인

**REST API:**
```
http://localhost:3000/catalog/default/api/tech-blog-rest-api
```

**WebSocket API:**
```
http://localhost:3000/catalog/default/api/websocket-chat-api
```

---

## 확장 이력

### Phase 1: 초기 구성 (2025-10-20)
- ✅ System: rnd-nx-framework
- ✅ Domains: 4개 도메인 정의
- ✅ Components: tech-blog 애플리케이션 (3개)
- ✅ APIs: tech-blog-rest-api
- ✅ Resources: tech-blog-database

**결과:** 총 **10개** 엔티티

---

### Phase 2: Backend 라이브러리 확장 (2025-10-21)
- ✅ be-users-library
- ✅ be-kafka-core-library
- ✅ be-websocket-library
- ✅ be-swagger-library
- ✅ websocket-chat-api (API 추가)

**결과:** 총 **15개** 엔티티 (+5개)

---

### Phase 3: GCP 인프라 확장 (2025-10-21)
- ✅ gke-dev-cluster
- ✅ gke-test-cluster
- ✅ gke-prod-cluster
- ✅ cloudsql-test
- ✅ gcp-vpc-dev/test/prod (3개)

**결과:** 총 **22개** 엔티티 (+7개)

---

### Phase 4: ArgoCD & GitOps (2025-10-21)
- ✅ argocd-dev-shared
- ✅ argocd-prod-shared
- ✅ argocd-sample-service

**결과:** 총 **25개** 엔티티 (+3개)

---

### Phase 5: 추가 인프라 (2025-10-21)
- ✅ kafka-cluster
- ✅ loki-grafana-stack
- ✅ local-docker-env
- ✅ terraform-gke-module (Component)
- ✅ ansible-common-setup (Component)
- ✅ fe-cursor-figma-mcp (Component)

**결과:** 총 **31개** 엔티티 (+6개)

---

### 확장 통계

| Phase | 날짜 | 추가 엔티티 | 누적 합계 |
|-------|------|------------|----------|
| Phase 1 | 2025-10-20 | 10 | 10 |
| Phase 2 | 2025-10-21 | +5 | 15 |
| Phase 3 | 2025-10-21 | +7 | 22 |
| Phase 4 | 2025-10-21 | +3 | 25 |
| Phase 5 | 2025-10-21 | +6 | **31** |

---

## 다음 단계

### 즉시 실행 가능한 개선 사항

#### 1. Backstage 플러그인 설치

##### A. Kubernetes Plugin
```bash
yarn --cwd packages/app add @backstage/plugin-kubernetes
yarn --cwd packages/backend add @backstage/plugin-kubernetes-backend
```

**기능:**
- GKE 클러스터 실시간 상태 모니터링
- Pod/Deployment/Service 정보 표시
- 로그 조회
- 리소스 사용률 확인

**설정 예시:**
```yaml
# app-config.yaml
kubernetes:
  serviceLocatorMethod:
    type: 'multiTenant'
  clusterLocatorMethods:
    - type: 'config'
      clusters:
        - name: gke-dev-cluster
          url: https://kubernetes.default.svc
          authProvider: 'serviceAccount'
```

---

##### B. ArgoCD Plugin
```bash
yarn --cwd packages/app add @roadiehq/backstage-plugin-argo-cd
yarn --cwd packages/backend add @roadiehq/backstage-plugin-argo-cd-backend
```

**기능:**
- GitOps 배포 상태 실시간 추적
- Sync/Health Status 확인
- 배포 이력 조회
- Manual Sync 트리거

**설정 예시:**
```yaml
# app-config.yaml
argocd:
  appLocatorMethods:
    - type: 'config'
      instances:
        - name: argocd-dev
          url: https://argocd.dev.your-domain.com
          token: ${ARGOCD_AUTH_TOKEN}
```

---

##### C. GitHub Insights Plugin
```bash
yarn --cwd packages/app add @roadiehq/backstage-plugin-github-insights
```

**기능:**
- Pull Request 목록
- Code Review 상태
- Commit 히스토리
- Contributor 통계

---

#### 2. Tech Insights 확장

##### A. Kafka 헬스 체크 추가

**새로운 Fact Retriever:**
```typescript
// packages/backend/src/plugins/techInsights.ts
const kafkaStatusFactRetriever = createFactRetriever({
  id: 'kafka-status-retriever',
  version: '1.0.0',
  entityFilter: [{ kind: 'resource', type: 'message-broker' }],
  schema: {
    brokerCount: { type: 'integer' },
    topicCount: { type: 'integer' },
    consumerLag: { type: 'integer' },
    replicationFactor: { type: 'integer' },
  },
  handler: async ({ discovery, auth, logger }) => {
    // Kafka Admin API 호출
    const admin = kafka.admin();
    const brokers = await admin.listNodes();
    const topics = await admin.listTopics();
    
    return {
      facts: {
        brokerCount: brokers.length,
        topicCount: topics.length,
        // ...
      }
    };
  }
});
```

**새로운 Check 추가:**
```yaml
# app-config.yaml
techInsights:
  factChecker:
    checks:
      kafka-brokers-healthy:
        type: json-rules-engine
        name: Kafka Broker 상태
        description: 모든 Kafka Broker가 정상인지 확인
        factIds:
          - kafka-status-retriever
        rule:
          conditions:
            all:
              - fact: brokerCount
                operator: equal
                value: 3
```

---

##### B. GKE 클러스터 모니터링

**Fact Retriever for GKE:**
```typescript
const gkeStatusFactRetriever = createFactRetriever({
  id: 'gke-status-retriever',
  version: '1.0.0',
  entityFilter: [{ kind: 'resource', type: 'kubernetes-cluster' }],
  schema: {
    nodeCount: { type: 'integer' },
    podCount: { type: 'integer' },
    cpuUsage: { type: 'number' },
    memoryUsage: { type: 'number' },
  },
  handler: async ({ entity, discovery, auth, logger }) => {
    // Kubernetes API 호출
    const k8sApi = kc.makeApiClient(k8s.CoreV1Api);
    const nodes = await k8sApi.listNode();
    const pods = await k8sApi.listPodForAllNamespaces();
    
    return {
      facts: {
        nodeCount: nodes.body.items.length,
        podCount: pods.body.items.length,
        // ...
      }
    };
  }
});
```

---

##### C. API 응답 시간 모니터링

**Fact Retriever for API Performance:**
```typescript
const apiPerformanceFactRetriever = createFactRetriever({
  id: 'api-performance-retriever',
  version: '1.0.0',
  entityFilter: [{ kind: 'component', 'spec.type': 'service' }],
  schema: {
    avgResponseTime: { type: 'number' },
    errorRate: { type: 'number' },
    requestPerSecond: { type: 'number' },
  },
  handler: async ({ entity, discovery, auth, logger }) => {
    // Grafana/Prometheus API 호출
    const metrics = await fetchMetrics(entity);
    
    return {
      facts: {
        avgResponseTime: metrics.avgResponseTime,
        errorRate: metrics.errorRate,
        // ...
      }
    };
  }
});
```

---

#### 3. GitHub 연동 개선

**현재 상태:**
- Placeholder URLs: `https://github.com/your-org/RND-NX`
- Annotation 누락: `github.com/project-slug`

**개선 작업:**

##### A. 모든 catalog 파일 업데이트
```bash
# 일괄 URL 변경 스크립트
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog

# your-org → 실제 조직명 변경
find . -name "*.yaml" -exec sed -i '' 's/your-org/VntgCorp/g' {} +

# Annotation 추가
find . -name "*.yaml" -exec sed -i '' '/metadata:/a\
  annotations:\n    github.com/project-slug: VntgCorp/RND-NX' {} +
```

##### B. catalog-info.yaml에 annotation 추가
```yaml
# 모든 catalog-info.yaml
metadata:
  annotations:
    github.com/project-slug: VntgCorp/RND-NX
    backstage.io/source-location: url:https://github.com/VntgCorp/RND-NX/tree/main/apps/tech-blog/api-server
```

---

#### 4. TechDocs 확장

##### A. API 문서화

**tech-blog-rest-api 문서 추가:**
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/apis

mkdir -p tech-blog-rest-api-docs
cd tech-blog-rest-api-docs

# mkdocs.yml 생성
cat > mkdocs.yml << 'EOF'
site_name: Tech Blog REST API
site_description: 기술 블로그 RESTful API 문서

nav:
  - Home: index.md
  - Authentication: auth.md
  - Posts: posts.md
  - Comments: comments.md
  - Users: users.md

theme:
  name: material
EOF

# API 문서 작성
cat > docs/index.md << 'EOF'
# Tech Blog REST API

기술 블로그 플랫폼의 RESTful API 문서입니다.

## Base URL
- Development: `http://localhost:3001`
- Production: `https://api.tech-blog.com`

## Authentication
모든 인증된 요청은 JWT Bearer Token이 필요합니다.
EOF
```

**tech-blog-rest-api.yaml 업데이트:**
```yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:./tech-blog-rest-api-docs
```

---

##### B. Terraform 모듈 문서화

```bash
cd /Users/seojiwon/VNTG_PROJECT/RND-NX/infra/gcp/modules/gke-cluster

# README.md 작성 (TechDocs 자동 변환)
cat > README.md << 'EOF'
# GKE Cluster Terraform Module

재사용 가능한 GKE 클러스터 생성 모듈입니다.

## Usage

```hcl
module "gke_cluster" {
  source = "./modules/gke-cluster"
  
  project_id = "your-gcp-project"
  region     = "asia-northeast3"
  cluster_name = "dev-cluster"
  
  node_pools = [
    {
      name         = "default-pool"
      machine_type = "e2-medium"
      min_count    = 1
      max_count    = 5
    }
  ]
}
```

## Variables

| Name | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `project_id` | string | yes | - | GCP Project ID |
| `region` | string | yes | - | GCP Region |
| `cluster_name` | string | yes | - | Cluster 이름 |
EOF
```

---

#### 5. 추가 엔티티 등록

##### A. ERP 애플리케이션 (현재 미등록)

**경로:** `/apps/erp/`

**생성 필요 Catalog:**
```yaml
# apps/erp/catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: erp-application
  description: 사내 ERP 시스템
  tags:
    - erp
    - internal
spec:
  type: website
  lifecycle: production
  owner: group:platform-team
  system: rnd-nx-framework
  domain: frontend-applications
```

---

##### B. Shared Libraries (libs/shared/)

**경로:** `/libs/shared/`

**생성 필요 Catalog:**
```yaml
# catalog/components/shared-utils-library.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: shared-utils-library
  description: 프론트엔드/백엔드 공통 유틸리티 라이브러리
  tags:
    - typescript
    - shared
    - utility
spec:
  type: library
  lifecycle: production
  owner: group:platform-team
  system: rnd-nx-framework
  domain: shared-libraries
```

---

### 중장기 개선 계획 (1-3개월)

#### 1. Scaffolder 템플릿 추가

**NestJS Service 템플릿:**
```yaml
# examples/template/nestjs-service-template.yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: nestjs-service-template
  title: NestJS Service 생성
  description: 새로운 NestJS 마이크로서비스 생성
spec:
  owner: group:backend-team
  type: service
  
  parameters:
    - title: 서비스 정보
      required:
        - name
        - description
      properties:
        name:
          title: 서비스 이름
          type: string
        description:
          title: 설명
          type: string
  
  steps:
    - id: fetch-template
      name: Fetch Template
      action: fetch:template
      input:
        url: ./nestjs-service-skeleton
        values:
          name: ${{ parameters.name }}
    
    - id: publish
      name: Publish to GitHub
      action: publish:github
      input:
        allowedHosts: ['github.com']
        repoUrl: github.com?repo=${{ parameters.name }}
    
    - id: register
      name: Register Component
      action: catalog:register
      input:
        repoContentsUrl: ${{ steps.publish.output.repoContentsUrl }}
        catalogInfoPath: '/catalog-info.yaml'
```

---

#### 2. Custom Annotations 추가

**Cost Tracking:**
```yaml
metadata:
  annotations:
    cloud.google.com/cost-center: "engineering"
    cloud.google.com/budget-alert: "monthly-500usd"
```

**On-Call Rotation:**
```yaml
metadata:
  annotations:
    pagerduty.com/integration-key: "xxx"
    pagerduty.com/service-id: "P123ABC"
```

**Monitoring:**
```yaml
metadata:
  annotations:
    grafana/dashboard-url: "https://grafana.com/d/xxx"
    sentry.io/project-slug: "tech-blog-api"
    newrelic.com/application-id: "123456"
```

---

#### 3. RBAC 권한 관리

**권한 정의:**
```typescript
// packages/backend/src/plugins/permission.ts
const catalogPermissions = [
  {
    type: 'resource',
    name: 'catalog-entity',
    attributes: { domain: 'backend-services' },
    policy: 'allow',
    roles: ['backend-team']
  },
  {
    type: 'resource',
    name: 'catalog-entity',
    attributes: { kind: 'resource', 'spec.type': 'database' },
    policy: 'allow',
    roles: ['devops-team', 'backend-team']
  }
];
```

---

#### 4. CI/CD 통합

**GitHub Actions Workflow:**
```yaml
# .github/workflows/catalog-ci.yaml
name: Catalog CI

on:
  pull_request:
    paths:
      - 'catalog/**'
      - '**/catalog-info.yaml'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Validate Catalog Files
        run: |
          npx @backstage/cli catalog:validate \
            --catalog-info-path "**/catalog-info.yaml"
      
      - name: Lint YAML
        run: |
          yamllint catalog/**/*.yaml
```

---

## 문제 해결

### 자주 발생하는 문제

#### 1. Catalog 파일 로드 실패

**증상:**
```
Error: Failed to load catalog file at target xxx.yaml
```

**해결 방법:**
```bash
# 1. 파일 경로 확인
ls -la /Users/seojiwon/VNTG_PROJECT/rnd-backstage/catalog/components/

# 2. YAML 문법 검증
yamllint catalog/components/be-users-library.yaml

# 3. Backstage 재시작
yarn dev
```

---

#### 2. 의존성 참조 오류

**증상:**
```
Warning: Entity component:tech-blog-api-server references resource:tech-blog-database, but it does not exist
```

**해결 방법:**
```yaml
# dependsOn 참조 형식 확인
dependsOn:
  - resource:default/tech-blog-database  # ✅ 올바른 형식 (namespace/name)
  - tech-blog-database                   # ❌ 잘못된 형식
```

---

#### 3. Tech Insights Fact Retriever 오류

**증상:**
```
Error: Failed to retrieve facts for tech-blog-db-status-retriever
```

**해결 방법:**
```bash
# 1. 데이터베이스 연결 확인
psql -h localhost -U backstage -d backstage

# 2. Fact Retriever 로그 확인
yarn workspace backend start --inspect

# 3. 수동으로 Fact 실행
curl -X POST http://localhost:7007/api/tech-insights/facts/tech-blog-db-status-retriever
```

---

## 참고 자료

### 공식 문서
- [Backstage 공식 문서](https://backstage.io/docs)
- [Nx 공식 문서](https://nx.dev)
- [NestJS 공식 문서](https://nestjs.com)

### 커뮤니티
- [Backstage Discord](https://discord.gg/backstage)
- [Nx Discord](https://discord.gg/nx)

### 내부 문서
- `BACKSTAGE_CATALOG_EXPANSION_PLAN.md` - 확장 계획서
- `CATALOG_EXPANSION_COMPLETE.md` - 확장 완료 보고서
- `TECH_INSIGHTS_LAST_GUIDE.md` - Tech Insights 가이드
- `bs_sw_arc_guide.md` - Backstage 소프트웨어 아키텍처 가이드

---

## 부록

### A. 팀 조직 구조

```yaml
# examples/org.yaml
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: platform-team
  description: 플랫폼 인프라 팀
spec:
  type: team
  children: []

---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: backend-team
  description: 백엔드 개발 팀
spec:
  type: team
  parent: platform-team

---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: frontend-team
  description: 프론트엔드 개발 팀
spec:
  type: team
  parent: platform-team

---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: devops-team
  description: DevOps 팀
spec:
  type: team
  parent: platform-team
```

---

### B. 환경 변수 템플릿

```bash
# .env
# Database
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=backstage
POSTGRES_PASSWORD=backstage
POSTGRES_DB=backstage

# Backstage
BACKEND_SECRET=<generate-random-secret>
EXTERNAL_SECRET=<generate-random-secret>

# GitHub
GITHUB_TOKEN=<your-personal-access-token>
AUTH_GITHUB_CLIENT_ID=<your-github-oauth-client-id>
AUTH_GITHUB_CLIENT_SECRET=<your-github-oauth-client-secret>

# Google OAuth (optional)
AUTH_GOOGLE_CLIENT_ID=<your-google-oauth-client-id>
AUTH_GOOGLE_CLIENT_SECRET=<your-google-oauth-client-secret>

# ArgoCD (optional)
ARGOCD_AUTH_TOKEN=<argocd-api-token>
```

---

### C. 주요 명령어

```bash
# Backstage 실행
yarn dev

# 특정 패키지만 실행
yarn workspace backend start
yarn workspace app start

# 데이터베이스 마이그레이션
yarn workspace backend migrate:run

# Catalog 검증
yarn backstage-cli catalog:validate

# 프로덕션 빌드
yarn build:all
yarn build:backend
```

---

## 마무리

### 현재 상태 요약

✅ **완료된 작업:**
- 총 **31개** 엔티티 등록
- 4개 도메인 정의
- 10개 컴포넌트 (Services, Libraries)
- 2개 API 정의
- 14개 인프라 리소스
- Tech Insights 10개 체크 활성화

✅ **주요 성과:**
- 전체 시스템 아키텍처 시각화
- 컴포넌트 간 의존성 추적
- 데이터베이스 헬스 모니터링 자동화
- 팀별 소유권 명확화

---

### 다음 목표

🎯 **단기 (1주일):**
- Kubernetes Plugin 설치
- ArgoCD Plugin 설치
- GitHub URL 실제 값으로 변경

🎯 **중기 (1개월):**
- Tech Insights 확장 (Kafka, GKE)
- TechDocs 문서 작성
- Scaffolder 템플릿 추가

🎯 **장기 (3개월):**
- RBAC 권한 관리 구현
- Custom Annotations 정의
- CI/CD 파이프라인 통합

---

**문서 작성일**: 2025-10-23  
**작성자**: Backstage 설정팀  
**버전**: 1.0  
**마지막 업데이트**: 2025-10-23


