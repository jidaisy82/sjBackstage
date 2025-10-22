# Backstage Catalog 확장 계획

## 📋 현재 상태
- ✅ `tech-blog` 애플리케이션 (api-server, user-client, api-server-test)
- ✅ `tech-blog-database` 리소스
- ✅ `tech-blog-rest-api` API

## 🎯 추가 가능한 Backstage 엔티티들

### 1. 인프라스트럭처 리소스 (Infrastructure Resources)

#### A. GCP 인프라 (`/infra/gcp/`)

##### **GKE Clusters** (Resource)
```yaml
# catalog/resources/gke-dev-cluster.yaml
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: gke-dev-cluster
  description: GCP Kubernetes Engine - Development 환경
  tags:
    - gcp
    - kubernetes
    - dev
    - infrastructure
spec:
  type: kubernetes-cluster
  lifecycle: production
  owner: devops-team
  system: rnd-nx-framework
  dependsOn:
    - resource:gcp-vpc-dev
```

**발견된 GCP 리소스:**
- `gke-dev-cluster` (dev 환경)
- `gke-test-cluster` (test 환경)
- `gke-prod-cluster` (prod 환경)
- `cloudsql-test` (test 환경 CloudSQL)
- `gcp-vpc-dev`, `gcp-vpc-test`, `gcp-vpc-prod` (네트워크)
- `argocd-dev` (ArgoCD)

##### **Cloud SQL** (Resource)
```yaml
# catalog/resources/cloudsql-test.yaml
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: cloudsql-test
  description: Cloud SQL PostgreSQL - Test 환경
  tags:
    - gcp
    - database
    - postgresql
    - test
  links:
    - url: https://console.cloud.google.com/sql
      title: GCP Console
      icon: cloud
spec:
  type: database
  lifecycle: experimental
  owner: backend-team
  system: rnd-nx-framework
  dependsOn:
    - resource:gcp-vpc-test
```

#### B. ArgoCD Applications (`/k8s/argocd/apps/`)

##### **ArgoCD Apps** (Resource)
```yaml
# catalog/resources/argocd-dev-shared.yaml
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: argocd-dev-shared
  description: ArgoCD Application - Dev 환경 공유 리소스
  tags:
    - argocd
    - kubernetes
    - gitops
    - dev
spec:
  type: argocd-application
  lifecycle: production
  owner: devops-team
  system: rnd-nx-framework
```

**발견된 ArgoCD 리소스:**
- `argocd-dev-shared` (shared/dev.yaml)
- `argocd-prod-shared` (shared/prod.yaml)
- `argocd-sample-service` (services/sample.yaml)

#### C. Terraform 모듈 (`/libs/infra/terraform/`)

##### **Terraform Modules** (Template 또는 Component)
```yaml
# catalog/components/terraform-gke-module.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: terraform-gke-module
  description: 재사용 가능한 GKE Cluster Terraform 모듈
  tags:
    - terraform
    - infrastructure-as-code
    - gcp
    - kubernetes
  annotations:
    terraform.io/module-path: libs/infra/terraform/gcp/modules/gke-cluster
spec:
  type: library
  lifecycle: production
  owner: devops-team
  system: rnd-nx-framework
  domain: infrastructure
```

**발견된 Terraform 모듈:**
- `terraform-gke-cluster-module` (gcp/modules/gke-cluster)
- 기타 on-prem 모듈들

#### D. Ansible Roles (`/libs/infra/ansible/`)

##### **Ansible Roles** (Component)
```yaml
# catalog/components/ansible-common-setup.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ansible-common-setup
  description: 서버 공통 설정을 위한 Ansible Role
  tags:
    - ansible
    - configuration-management
    - automation
  annotations:
    ansible.io/role-path: libs/infra/ansible/roles/common-setup
spec:
  type: library
  lifecycle: production
  owner: devops-team
  system: rnd-nx-framework
  domain: infrastructure
```

### 2. 백엔드 라이브러리 (`/libs/be/`)

#### **NestJS 라이브러리들** (Component - library)

##### **Auth Library**
```yaml
# catalog/components/be-auth-library.yaml (이미 생성됨)
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-auth-library
  description: NestJS 인증/인가 라이브러리 (JWT, Guards)
  tags:
    - nestjs
    - authentication
    - authorization
    - jwt
  annotations:
    nx.dev/project: '@rnd-nx/be-auth'
spec:
  type: library
  lifecycle: production
  owner: backend-team
  system: rnd-nx-framework
  domain: backend-services
  providesApis:
    - be-auth-api
```

**발견된 BE 라이브러리:**
- ✅ `be-auth` (이미 tech-blog dependency로 등록됨)
- ✅ `be-common` (이미 tech-blog dependency로 등록됨)
- ✅ `be-prisma` (이미 tech-blog dependency로 등록됨)
- 🆕 `be-users` (사용자 관리)
- 🆕 `be-kafka-core` (Kafka 통합)
- 🆕 `be-websocket` (WebSocket/Chat)
- 🆕 `be-swagger` (Swagger/OpenAPI)
- 🆕 `be-log-pipeline` (로깅 파이프라인)

##### **Users Library** (신규)
```yaml
# catalog/components/be-users-library.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-users-library
  description: NestJS 사용자 관리 라이브러리
  tags:
    - nestjs
    - user-management
    - backend
  annotations:
    nx.dev/project: '@rnd-nx/be-users'
spec:
  type: library
  lifecycle: production
  owner: backend-team
  system: rnd-nx-framework
  domain: backend-services
  dependsOn:
    - component:be-prisma-library
    - component:be-common-library
```

##### **Kafka Core Library** (신규)
```yaml
# catalog/components/be-kafka-core-library.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-kafka-core-library
  description: Kafka 통합을 위한 NestJS 라이브러리
  tags:
    - nestjs
    - kafka
    - messaging
    - event-driven
  annotations:
    nx.dev/project: '@rnd-nx/be-kafka-core'
spec:
  type: library
  lifecycle: production
  owner: backend-team
  system: rnd-nx-framework
  domain: backend-services
  dependsOn:
    - resource:kafka-cluster
```

##### **WebSocket Library** (신규)
```yaml
# catalog/components/be-websocket-library.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: be-websocket-library
  description: WebSocket/실시간 채팅을 위한 NestJS 라이브러리
  tags:
    - nestjs
    - websocket
    - real-time
    - chat
  annotations:
    nx.dev/project: '@rnd-nx/be-websocket'
spec:
  type: library
  lifecycle: production
  owner: backend-team
  system: rnd-nx-framework
  domain: backend-services
```

### 3. 프론트엔드 라이브러리 (`/libs/fe/`)

##### **Cursor-Figma MCP** (신규)
```yaml
# catalog/components/fe-cursor-figma-mcp.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: fe-cursor-figma-mcp
  description: Cursor와 Figma 통합을 위한 MCP 라이브러리
  tags:
    - figma
    - design-tools
    - mcp
    - frontend
  annotations:
    nx.dev/project: '@rnd-nx/fe-cursor-figma-mcp'
spec:
  type: library
  lifecycle: experimental
  owner: frontend-team
  system: rnd-nx-framework
  domain: frontend-applications
```

### 4. 추가 리소스

#### **Kafka Cluster** (Resource - 신규)
```yaml
# catalog/resources/kafka-cluster.yaml
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: kafka-cluster
  description: Apache Kafka 클러스터 (이벤트 스트리밍)
  tags:
    - kafka
    - messaging
    - event-streaming
spec:
  type: message-broker
  lifecycle: production
  owner: backend-team
  system: rnd-nx-framework
```

#### **Loki-Grafana Stack** (Resource - 신규)
```yaml
# catalog/resources/loki-grafana-stack.yaml
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: loki-grafana-stack
  description: Loki + Grafana 로깅 및 모니터링 스택
  tags:
    - logging
    - monitoring
    - grafana
    - loki
  links:
    - url: http://localhost:3000
      title: Grafana Dashboard
      icon: dashboard
spec:
  type: monitoring-system
  lifecycle: production
  owner: devops-team
  system: rnd-nx-framework
```

#### **Local Docker Environment** (Resource - 신규)
```yaml
# catalog/resources/local-docker-env.yaml
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: local-docker-env
  description: 로컬 개발 환경 Docker Compose 스택
  tags:
    - docker
    - local-development
    - postgresql
spec:
  type: development-environment
  lifecycle: experimental
  owner: platform-team
  system: rnd-nx-framework
```

### 5. API 정의 (APIs)

#### **WebSocket Chat API** (신규)
```yaml
# catalog/apis/websocket-chat-api.yaml
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: websocket-chat-api
  description: WebSocket 기반 실시간 채팅 API
  tags:
    - websocket
    - chat
    - real-time
spec:
  type: websocket
  lifecycle: production
  owner: backend-team
  system: rnd-nx-framework
  definition: |
    # WebSocket Events
    - chat:message
    - chat:join
    - chat:leave
```

## 📊 우선순위별 추가 계획

### Priority 1 (즉시 추가 권장)
1. ✅ **BE 라이브러리들** (`be-users`, `be-kafka-core`, `be-websocket`)
   - 이미 코드베이스에 존재
   - tech-blog와의 관계 명확화
   - 재사용성 추적

2. ✅ **GCP 리소스들** (GKE, CloudSQL, VPC)
   - 인프라 가시성 향상
   - 배포 환경 추적
   - 비용 및 리소스 관리

3. ✅ **ArgoCD Applications**
   - GitOps 워크플로우 추적
   - 배포 상태 모니터링

### Priority 2 (중요도 중)
4. ⚠️ **Terraform 모듈**
   - Infrastructure as Code 추적
   - 모듈 재사용성 관리
   - 버전 관리

5. ⚠️ **Kafka/Loki 리소스**
   - 메시징 및 로깅 인프라 가시성

### Priority 3 (선택적)
6. ⏸️ **Ansible Roles**
   - 설정 관리 추적
   - 자동화 워크플로우 문서화

7. ⏸️ **Local Development 환경**
   - 개발자 온보딩 지원

## 🎯 Backstage Catalog 구조 (확장 후)

```
rnd-nx-framework (System)
├── Domains
│   ├── backend-services
│   ├── frontend-applications
│   ├── shared-libraries
│   └── infrastructure
│
├── Components
│   ├── Services
│   │   ├── tech-blog-api-server
│   │   └── tech-blog-api-server-test
│   ├── Websites
│   │   └── tech-blog-user-client
│   └── Libraries
│       ├── Backend
│       │   ├── be-auth-library ✅
│       │   ├── be-common-library ✅
│       │   ├── be-prisma-library ✅
│       │   ├── be-users-library 🆕
│       │   ├── be-kafka-core-library 🆕
│       │   ├── be-websocket-library 🆕
│       │   └── be-swagger-library 🆕
│       ├── Frontend
│       │   ├── ui-component-library ✅
│       │   ├── design-tokens-library ✅
│       │   └── fe-cursor-figma-mcp 🆕
│       └── Infrastructure
│           ├── terraform-gke-cluster-module 🆕
│           └── ansible-common-setup 🆕
│
├── APIs
│   ├── tech-blog-rest-api ✅
│   └── websocket-chat-api 🆕
│
└── Resources
    ├── Databases
    │   ├── tech-blog-database ✅
    │   └── cloudsql-test 🆕
    ├── Kubernetes
    │   ├── gke-dev-cluster 🆕
    │   ├── gke-test-cluster 🆕
    │   └── gke-prod-cluster 🆕
    ├── ArgoCD
    │   ├── argocd-dev-shared 🆕
    │   ├── argocd-prod-shared 🆕
    │   └── argocd-sample-service 🆕
    ├── Messaging
    │   └── kafka-cluster 🆕
    ├── Monitoring
    │   └── loki-grafana-stack 🆕
    └── Development
        └── local-docker-env 🆕
```

## 📝 구현 계획

### Phase 1: BE 라이브러리 추가 (즉시)
- `be-users-library.yaml`
- `be-kafka-core-library.yaml`
- `be-websocket-library.yaml`
- `be-swagger-library.yaml`

### Phase 2: GCP 인프라 추가 (1주일 내)
- `gke-dev-cluster.yaml`
- `gke-test-cluster.yaml`
- `gke-prod-cluster.yaml`
- `cloudsql-test.yaml`
- `gcp-vpc-*.yaml`

### Phase 3: ArgoCD & GitOps (2주일 내)
- `argocd-dev-shared.yaml`
- `argocd-prod-shared.yaml`
- ArgoCD 플러그인 설정

### Phase 4: Terraform & IaC (선택적)
- Terraform 모듈 catalog 등록
- TechDocs로 모듈 문서화

## 🔗 Backstage 플러그인 추천

### 즉시 설치 권장
1. **Kubernetes Plugin**
   - GKE 클러스터 상태 모니터링
   - Pod/Deployment 정보 표시

2. **ArgoCD Plugin**
   - GitOps 배포 상태 추적
   - 동기화 상태 모니터링

3. **TechDocs**
   - Terraform 모듈 문서화
   - API 문서 호스팅

### 선택적 설치
4. **Cloud Cost Insights** (GCP)
   - GCP 리소스 비용 추적

5. **Terraform Plugin**
   - Terraform 상태 추적
   - 리소스 변경 이력

## 📈 예상 효과

### 개발자 경험 향상
- ✅ 전체 시스템 아키텍처 가시성
- ✅ 컴포넌트 간 의존성 파악
- ✅ 인프라 리소스 현황 파악

### 운영 효율성
- ✅ 배포 상태 중앙 모니터링
- ✅ 리소스 소유권 명확화
- ✅ 문서화 자동화

### 협업 강화
- ✅ 팀 간 컴포넌트 공유
- ✅ API 계약 명확화
- ✅ 온보딩 시간 단축

## 🚀 다음 단계

1. **Priority 1 항목 catalog 파일 생성** (BE 라이브러리, GCP 리소스)
2. **app-config.yaml 업데이트** (새로운 catalog locations 추가)
3. **Kubernetes/ArgoCD 플러그인 설치**
4. **Tech Insights 확장** (인프라 리소스 모니터링)

---

**생성 날짜**: 2025-10-21  
**작성자**: Backstage 설정팀

