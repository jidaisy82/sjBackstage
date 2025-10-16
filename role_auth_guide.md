# Backstage 인증 및 접근 제어 구성 가이드

## 📋 목차
1. [개요](#개요)
2. [Google OAuth 인증 설정](#google-oauth-인증-설정)
3. [사용자 매핑 및 Resolver 구성](#사용자-매핑-및-resolver-구성)
4. [사용자 엔티티 관리](#사용자-엔티티-관리)
5. [Role 기반 접근 제어](#role-기반-접근-제어)
6. [권한 정책 구성](#권한-정책-구성)
7. [트러블슈팅](#트러블슈팅)

---

## 개요

이 문서는 Backstage에서 Google OAuth 인증을 구성하고 Role 기반 접근 제어(RBAC)를 설정하는 방법을 설명합니다.

### 주요 구성 요소
- **인증 (Authentication)**: Google OAuth 2.0
- **사용자 매핑**: 이메일 기반 사용자 엔티티 매칭
- **권한 관리**: Role 기반 접근 제어
- **정책 엔진**: Backstage Permission Framework

---

## Google OAuth 인증 설정

### 1. Google Cloud Console 설정

#### OAuth 2.0 클라이언트 ID 생성
```bash
# Google Cloud Console에서 수행할 작업:
1. Google Cloud Console (https://console.cloud.google.com) 접속
2. 프로젝트 선택 또는 새 프로젝트 생성
3. "API 및 서비스" > "사용자 인증 정보" 이동
4. "+ 사용자 인증 정보 만들기" > "OAuth 클라이언트 ID" 선택
5. 애플리케이션 유형: "웹 애플리케이션" 선택
```

#### 승인된 리디렉션 URI 설정
```
# 개발 환경
http://localhost:7007/api/auth/google/handler/frame

# 프로덕션 환경 (예시)
https://your-backstage-domain.com/api/auth/google/handler/frame
```

### 2. 환경 변수 설정

`.env` 파일에 Google OAuth 정보 추가:

```bash
# Google OAuth Configuration
AUTH_GOOGLE_CLIENT_ID=your_google_client_id_here
AUTH_GOOGLE_CLIENT_SECRET=your_google_client_secret_here

# Backend Secret (보안을 위해 강력한 랜덤 문자열 사용)
BACKEND_SECRET=your_strong_random_secret_here
```

### 3. app-config.yaml 구성

```yaml
auth:
  environment: development
  providers:
    google:
      development:
        clientId: ${AUTH_GOOGLE_CLIENT_ID}
        clientSecret: ${AUTH_GOOGLE_CLIENT_SECRET}
        sessionDuration: { hours: 24 }
        # Nonce 오류 방지를 위한 추가 스코프
        additionalScopes:
          - openid
          - profile
          - email
        signIn:
          resolvers:
            # 주 resolver: annotation 기반 매칭
            - resolver: emailMatchingUserEntityAnnotation
            # 백업 resolver: 단순 이메일 매칭
            - resolver: emailMatchingUserEntityProfileEmail
```

### 4. 백엔드 모듈 구성

`packages/backend/src/index.ts`:

```typescript
// auth plugin
backend.add(import('@backstage/plugin-auth-backend'));

// Google OAuth provider 추가
backend.add(import('@backstage/plugin-auth-backend-module-google-provider'));

// Guest provider 비활성화 (Google OAuth만 사용)
// backend.add(import('@backstage/plugin-auth-backend-module-guest-provider'));
```

### 5. 프론트엔드 구성

`packages/app/src/App.tsx`:

```typescript
import { googleAuthApiRef } from '@backstage/core-plugin-api';

const app = createApp({
  // ... 기타 설정
  components: {
    SignInPage: props => (
      <SignInPage
        {...props}
        auto
        provider={{
          id: 'google-auth-provider',
          title: 'Google',
          message: 'Sign in using Google',
          apiRef: googleAuthApiRef,
        }}
      />
    ),
  },
});
```

---

## 사용자 매핑 및 Resolver 구성

### 1. 사용자 엔티티 정의

`examples/org.yaml`:

```yaml
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: admin-user
  annotations:
    # emailMatchingUserEntityAnnotation resolver를 위한 필수 annotation
    backstage.io/managed-by-location: 'url:file:///examples/org.yaml'
spec:
  profile:
    displayName: 관리자
    email: admin@company.com
  memberOf: [admins, developers]

---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: dev-user
  annotations:
    backstage.io/managed-by-location: 'url:file:///examples/org.yaml'
spec:
  profile:
    displayName: 개발자
    email: developer@company.com
  memberOf: [developers]

---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: guest-user
  annotations:
    backstage.io/managed-by-location: 'url:file:///examples/org.yaml'
spec:
  profile:
    displayName: 게스트
    email: guest@company.com
  memberOf: [guests]
```

### 2. 그룹 정의

```yaml
---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: admins
spec:
  type: team
  profile:
    displayName: 관리자 그룹
    description: 시스템 전체 관리 권한
  children: []

---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: developers
spec:
  type: team
  profile:
    displayName: 개발자 그룹
    description: 개발 관련 리소스 접근 권한
  children: []
  parent: admins

---
apiVersion: backstage.io/v1alpha1
kind: Group
metadata:
  name: guests
spec:
  type: team
  profile:
    displayName: 게스트 그룹
    description: 읽기 전용 접근 권한
  children: []
```

### 3. Resolver 유형별 특징

| Resolver | 설명 | 요구사항 | 사용 사례 |
|----------|------|----------|-----------|
| `emailMatchingUserEntityAnnotation` | annotation 기반 엄격한 매칭 | `backstage.io/managed-by-location` annotation 필요 | 보안이 중요한 환경 |
| `emailMatchingUserEntityProfileEmail` | 단순 이메일 매칭 | profile.email 필드만 필요 | 간단한 설정 |
| `emailLocalPartMatchingUserEntityName` | 이메일 로컬 부분으로 매칭 | 사용자 name이 이메일 @ 앞부분과 일치 | 자동 사용자 생성 |

---

## 사용자 엔티티 관리

### 1. 사용자 엔티티 생명주기 관리

#### 신규 사용자 추가

**수동 추가 방법**:
```yaml
# examples/org.yaml에 새 사용자 추가
---
apiVersion: backstage.io/v1alpha1
kind: User
metadata:
  name: new-user
  annotations:
    backstage.io/managed-by-location: 'url:file:///examples/org.yaml'
spec:
  profile:
    displayName: 새로운 사용자
    email: newuser@company.com
    picture: https://avatars.githubusercontent.com/u/username
  memberOf: [developers]
```

**API를 통한 추가**:
```bash
# REST API로 사용자 엔티티 생성
curl -X POST http://localhost:7007/api/catalog/entities \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "apiVersion": "backstage.io/v1alpha1",
    "kind": "User",
    "metadata": {
      "name": "api-user",
      "annotations": {
        "backstage.io/managed-by-location": "url:api://manual"
      }
    },
    "spec": {
      "profile": {
        "displayName": "API 생성 사용자",
        "email": "apiuser@company.com"
      },
      "memberOf": ["developers"]
    }
  }'
```

#### 사용자 정보 수정

**프로필 업데이트**:
```yaml
# 기존 사용자 정보 수정
spec:
  profile:
    displayName: 업데이트된 이름
    email: updated-email@company.com
    picture: https://new-avatar-url.com/avatar.jpg
    # 추가 프로필 정보
    bio: "백엔드 개발자, 5년 경력"
    location: "서울, 대한민국"
    links:
      - url: https://github.com/username
        title: GitHub
        icon: github
      - url: https://linkedin.com/in/username
        title: LinkedIn
        icon: linkedin
```

**그룹 멤버십 변경**:
```yaml
# 사용자의 그룹 멤버십 업데이트
spec:
  memberOf: 
    - developers      # 기존 그룹 유지
    - team-backend    # 새 팀 추가
    - project-alpha   # 프로젝트 그룹 추가
```

#### 사용자 비활성화/삭제

**비활성화 (권장 방법)**:
```yaml
# 사용자를 비활성화하되 히스토리 유지
metadata:
  name: inactive-user
  annotations:
    backstage.io/managed-by-location: 'url:file:///examples/org.yaml'
    backstage.io/status: 'inactive'  # 비활성화 마킹
spec:
  profile:
    displayName: 비활성 사용자 (퇴사)
    email: inactive@company.com
  memberOf: []  # 모든 그룹에서 제거
```

**완전 삭제**:
```bash
# API를 통한 엔티티 삭제
curl -X DELETE http://localhost:7007/api/catalog/entities/by-name/user/default/username \
  -H "Authorization: Bearer $TOKEN"
```

### 2. 대량 사용자 관리

#### CSV/Excel 데이터 변환

**Python 스크립트 예시**:
```python
#!/usr/bin/env python3
import csv
import yaml

def csv_to_backstage_users(csv_file, output_file):
    """CSV 파일을 Backstage 사용자 엔티티로 변환"""
    users = []
    
    with open(csv_file, 'r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        
        for row in reader:
            user = {
                'apiVersion': 'backstage.io/v1alpha1',
                'kind': 'User',
                'metadata': {
                    'name': row['username'],
                    'annotations': {
                        'backstage.io/managed-by-location': 'url:file:///examples/org.yaml'
                    }
                },
                'spec': {
                    'profile': {
                        'displayName': row['display_name'],
                        'email': row['email']
                    },
                    'memberOf': row['groups'].split(',') if row['groups'] else []
                }
            }
            users.append(user)
    
    # YAML 파일로 출력
    with open(output_file, 'w', encoding='utf-8') as file:
        yaml.dump_all(users, file, default_flow_style=False, allow_unicode=True)

# 사용 예시
# csv_to_backstage_users('users.csv', 'generated_users.yaml')
```

**CSV 파일 형식**:
```csv
username,display_name,email,groups
john.doe,John Doe,john.doe@company.com,"developers,team-frontend"
jane.smith,Jane Smith,jane.smith@company.com,"developers,team-backend,admins"
guest.user,Guest User,guest@company.com,guests
```

#### 배치 업데이트 스크립트

```bash
#!/bin/bash
# 대량 사용자 업데이트 스크립트

BACKSTAGE_API="http://localhost:7007/api/catalog"
TOKEN="your-auth-token"

# 사용자 목록 파일에서 읽어서 업데이트
while IFS=',' read -r username email groups; do
    echo "Updating user: $username"
    
    # 기존 사용자 정보 가져오기
    existing_user=$(curl -s -H "Authorization: Bearer $TOKEN" \
        "$BACKSTAGE_API/entities/by-name/user/default/$username")
    
    if [ "$existing_user" != "null" ]; then
        # 사용자 정보 업데이트
        updated_user=$(echo "$existing_user" | jq \
            --arg email "$email" \
            --argjson groups "$(echo $groups | jq -R 'split(",")')" \
            '.spec.profile.email = $email | .spec.memberOf = $groups')
        
        # API로 업데이트 전송
        curl -X PUT "$BACKSTAGE_API/entities/by-name/user/default/$username" \
            -H "Content-Type: application/json" \
            -H "Authorization: Bearer $TOKEN" \
            -d "$updated_user"
    fi
done < users_update.csv
```

### 3. 외부 시스템 연동

#### LDAP/Active Directory 연동

**LDAP 프로바이더 설정**:
```yaml
# app-config.yaml
catalog:
  providers:
    ldap:
      target: ldap://ldap.company.com
      bind:
        dn: cn=backstage,ou=service,dc=company,dc=com
        secret: ${LDAP_SECRET}
      users:
        dn: ou=people,dc=company,dc=com
        options:
          filter: (objectClass=person)
        map:
          name: uid
          displayName: cn
          email: mail
          memberOf: memberOf
      groups:
        dn: ou=groups,dc=company,dc=com
        options:
          filter: (objectClass=groupOfNames)
        map:
          name: cn
          displayName: description
          members: member
```

**LDAP 동기화 스케줄러**:
```typescript
// packages/backend/src/ldap-sync.ts
import { CatalogApi } from '@backstage/catalog-client';
import { LdapClient } from 'ldapjs';

export class LdapUserSync {
  constructor(
    private catalogApi: CatalogApi,
    private ldapClient: LdapClient
  ) {}

  async syncUsers(): Promise<void> {
    // LDAP에서 사용자 목록 가져오기
    const ldapUsers = await this.fetchLdapUsers();
    
    // Backstage 카탈로그의 기존 사용자 목록
    const catalogUsers = await this.catalogApi.getEntities({
      filter: { kind: 'User' }
    });

    // 신규 사용자 추가
    for (const ldapUser of ldapUsers) {
      const existingUser = catalogUsers.items.find(
        u => u.spec?.profile?.email === ldapUser.email
      );

      if (!existingUser) {
        await this.createBackstageUser(ldapUser);
      } else {
        await this.updateBackstageUser(existingUser, ldapUser);
      }
    }

    // 비활성 사용자 처리
    await this.handleInactiveUsers(catalogUsers.items, ldapUsers);
  }

  private async createBackstageUser(ldapUser: any): Promise<void> {
    const userEntity = {
      apiVersion: 'backstage.io/v1alpha1',
      kind: 'User',
      metadata: {
        name: ldapUser.uid,
        annotations: {
          'backstage.io/managed-by-location': 'url:ldap://sync',
          'backstage.io/managed-by-origin-location': 'url:ldap://sync'
        }
      },
      spec: {
        profile: {
          displayName: ldapUser.displayName,
          email: ldapUser.email
        },
        memberOf: ldapUser.groups || []
      }
    };

    await this.catalogApi.addLocation({
      type: 'url',
      target: 'data:application/yaml,' + encodeURIComponent(
        require('yaml').stringify(userEntity)
      )
    });
  }
}
```

#### HR 시스템 연동

**Webhook 기반 실시간 동기화**:
```typescript
// packages/backend/src/hr-webhook.ts
import { Router } from 'express';
import { CatalogApi } from '@backstage/catalog-client';

export function createHrWebhookRouter(catalogApi: CatalogApi): Router {
  const router = Router();

  // 신규 입사자 웹훅
  router.post('/employee/created', async (req, res) => {
    const employee = req.body;
    
    const userEntity = {
      apiVersion: 'backstage.io/v1alpha1',
      kind: 'User',
      metadata: {
        name: employee.employeeId,
        annotations: {
          'backstage.io/managed-by-location': 'url:hr://webhook',
          'hr.company.com/employee-id': employee.employeeId,
          'hr.company.com/department': employee.department,
          'hr.company.com/hire-date': employee.hireDate
        }
      },
      spec: {
        profile: {
          displayName: employee.fullName,
          email: employee.email,
          picture: employee.profilePicture
        },
        memberOf: [
          `department-${employee.department.toLowerCase()}`,
          employee.isManager ? 'managers' : 'employees'
        ]
      }
    };

    await catalogApi.addLocation({
      type: 'url',
      target: 'data:application/yaml,' + encodeURIComponent(
        require('yaml').stringify(userEntity)
      )
    });

    res.status(200).json({ success: true });
  });

  // 퇴사자 웹훅
  router.post('/employee/terminated', async (req, res) => {
    const { employeeId } = req.body;
    
    // 사용자를 비활성화 (삭제하지 않음)
    const user = await catalogApi.getEntityByName({
      kind: 'User',
      namespace: 'default',
      name: employeeId
    });

    if (user) {
      const updatedUser = {
        ...user,
        metadata: {
          ...user.metadata,
          annotations: {
            ...user.metadata.annotations,
            'backstage.io/status': 'inactive',
            'hr.company.com/termination-date': new Date().toISOString()
          }
        },
        spec: {
          ...user.spec,
          memberOf: [] // 모든 그룹에서 제거
        }
      };

      await catalogApi.addLocation({
        type: 'url',
        target: 'data:application/yaml,' + encodeURIComponent(
          require('yaml').stringify(updatedUser)
        )
      });
    }

    res.status(200).json({ success: true });
  });

  return router;
}
```

### 4. 사용자 엔티티 모니터링 및 감사

#### 사용자 활동 추적

**로그인 이벤트 추적**:
```typescript
// packages/backend/src/user-analytics.ts
import { AuthService } from '@backstage/backend-plugin-api';

export class UserAnalytics {
  constructor(private authService: AuthService) {}

  async trackUserLogin(userRef: string): Promise<void> {
    const loginEvent = {
      timestamp: new Date().toISOString(),
      userRef,
      event: 'login',
      metadata: {
        ip: req.ip,
        userAgent: req.get('User-Agent')
      }
    };

    // 로그인 이벤트를 데이터베이스에 저장
    await this.saveEvent(loginEvent);
  }

  async generateUserReport(): Promise<any> {
    // 사용자 활동 보고서 생성
    return {
      totalUsers: await this.getTotalUsers(),
      activeUsers: await this.getActiveUsers(30), // 30일 기준
      newUsers: await this.getNewUsers(7), // 7일 기준
      inactiveUsers: await this.getInactiveUsers(90) // 90일 기준
    };
  }
}
```

#### 권한 변경 감사

**권한 변경 로그**:
```typescript
// 권한 변경 이벤트 추적
export class PermissionAudit {
  async auditPermissionChange(
    userRef: string,
    oldGroups: string[],
    newGroups: string[],
    changedBy: string
  ): Promise<void> {
    const auditEvent = {
      timestamp: new Date().toISOString(),
      type: 'permission_change',
      subject: userRef,
      changedBy,
      changes: {
        added: newGroups.filter(g => !oldGroups.includes(g)),
        removed: oldGroups.filter(g => !newGroups.includes(g))
      }
    };

    await this.saveAuditEvent(auditEvent);
  }
}
```

### 5. 사용자 엔티티 검증 및 품질 관리

#### 데이터 검증 규칙

```typescript
// packages/backend/src/user-validation.ts
export class UserEntityValidator {
  validateUser(userEntity: any): ValidationResult {
    const errors: string[] = [];

    // 필수 필드 검증
    if (!userEntity.metadata?.name) {
      errors.push('사용자 이름이 필요합니다');
    }

    if (!userEntity.spec?.profile?.email) {
      errors.push('이메일 주소가 필요합니다');
    }

    // 이메일 형식 검증
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (userEntity.spec?.profile?.email && 
        !emailRegex.test(userEntity.spec.profile.email)) {
      errors.push('올바른 이메일 형식이 아닙니다');
    }

    // 그룹 존재 여부 검증
    if (userEntity.spec?.memberOf) {
      for (const group of userEntity.spec.memberOf) {
        if (!this.groupExists(group)) {
          errors.push(`그룹 '${group}'이 존재하지 않습니다`);
        }
      }
    }

    return {
      isValid: errors.length === 0,
      errors
    };
  }
}
```

#### 중복 사용자 감지

```bash
#!/bin/bash
# 중복 사용자 감지 스크립트

echo "=== 중복 이메일 검사 ==="
curl -s http://localhost:7007/api/catalog/entities?filter=kind=User | \
  jq -r '.items[].spec.profile.email' | \
  sort | uniq -d

echo "=== 중복 사용자명 검사 ==="
curl -s http://localhost:7007/api/catalog/entities?filter=kind=User | \
  jq -r '.items[].metadata.name' | \
  sort | uniq -d

echo "=== 고아 그룹 멤버십 검사 ==="
# 존재하지 않는 그룹에 속한 사용자 찾기
curl -s http://localhost:7007/api/catalog/entities?filter=kind=User | \
  jq -r '.items[] | select(.spec.memberOf) | 
    {name: .metadata.name, groups: .spec.memberOf[]} | 
    "\(.name): \(.groups)"'
```

### 6. 사용자 셀프 서비스

#### 프로필 업데이트 UI 컴포넌트
```typescript
// packages/app/src/components/UserProfile/UserProfileEditor.tsx
import React, { useState } from 'react';
import { useApi, identityApiRef } from '@backstage/core-plugin-api';
import { catalogApiRef } from '@backstage/plugin-catalog-react';

export const UserProfileEditor = () => {
  const identityApi = useApi(identityApiRef);
  const catalogApi = useApi(catalogApiRef);
  const [profile, setProfile] = useState({});

  const updateProfile = async () => {
    const identity = await identityApi.getBackstageIdentity();
    const userRef = identity.userEntityRef;

    // 사용자 엔티티 업데이트
    await catalogApi.addLocation({
      type: 'url',
      target: 'data:application/yaml,' + encodeURIComponent(
        require('yaml').stringify({
          ...existingUser,
          spec: {
            ...existingUser.spec,
            profile: {
              ...existingUser.spec.profile,
              ...profile
            }
          }
        })
      )
    });
  };

  return (
    <div>
      {/* 프로필 편집 폼 */}
    </div>
  );
};
```

---

## Role 기반 접근 제어

### 1. 권한 시스템 활성화

`app-config.yaml`:

```yaml
permission:
  enabled: true
  # 개발 중에는 모든 권한 허용 (프로덕션에서는 변경 필요)
  # policy: allow-all
```

### 2. 커스텀 권한 정책 생성

`packages/backend/src/permissions.ts` (새 파일 생성):

```typescript
import {
  BackstageIdentityResponse,
  BackstageSignInResult,
} from '@backstage/plugin-auth-node';
import {
  PermissionPolicy,
  PolicyDecision,
} from '@backstage/plugin-permission-node';
import {
  AuthorizeResult,
  PolicyQuery,
} from '@backstage/plugin-permission-common';
import { catalogEntityCreatePermission, catalogEntityDeletePermission } from '@backstage/plugin-catalog-common/alpha';

export class CustomPermissionPolicy implements PermissionPolicy {
  async handle(
    request: PolicyQuery,
    user?: BackstageIdentityResponse,
  ): Promise<PolicyDecision> {
    
    // 사용자 그룹 정보 추출
    const userGroups = user?.identity.ownershipEntityRefs || [];
    
    // 관리자 권한 확인
    const isAdmin = userGroups.some(ref => 
      ref.includes('group:default/admins')
    );
    
    // 개발자 권한 확인
    const isDeveloper = userGroups.some(ref => 
      ref.includes('group:default/developers') || 
      ref.includes('group:default/admins')
    );

    // 권한별 정책 적용
    switch (request.permission.name) {
      case 'catalog.entity.create':
        return {
          result: isDeveloper ? AuthorizeResult.ALLOW : AuthorizeResult.DENY,
        };
      
      case 'catalog.entity.delete':
        return {
          result: isAdmin ? AuthorizeResult.ALLOW : AuthorizeResult.DENY,
        };
      
      case 'catalog.entity.read':
        // 모든 인증된 사용자는 읽기 가능
        return { result: AuthorizeResult.ALLOW };
      
      default:
        // 기본적으로 개발자 이상 권한 필요
        return {
          result: isDeveloper ? AuthorizeResult.ALLOW : AuthorizeResult.DENY,
        };
    }
  }
}
```

### 3. 권한 정책 적용

`packages/backend/src/index.ts`:

```typescript
// 기본 allow-all 정책 제거
// backend.add(
//   import('@backstage/plugin-permission-backend-module-allow-all-policy'),
// );

// 커스텀 권한 정책 적용
backend.add(import('./permissions'));
```

---

## 권한 정책 구성

### 1. Role 정의

| Role | 그룹 | 권한 | 설명 |
|------|------|------|------|
| **관리자** | `admins` | 전체 시스템 관리 | - 모든 엔티티 CRUD<br>- 사용자 관리<br>- 시스템 설정 |
| **개발자** | `developers` | 개발 리소스 관리 | - 컴포넌트 생성/수정<br>- 템플릿 사용<br>- API 문서 작성 |
| **게스트** | `guests` | 읽기 전용 접근 | - 카탈로그 조회<br>- 문서 읽기<br>- 검색 기능 |

### 2. 세부 권한 매트릭스

```yaml
# 권한 매트릭스 예시
permissions:
  catalog:
    entity:
      create: [admins, developers]
      read: [admins, developers, guests]
      update: [admins, developers]
      delete: [admins]
  
  scaffolder:
    template:
      execute: [admins, developers]
      parameter.edit: [admins]
  
  techdocs:
    document:
      read: [admins, developers, guests]
      write: [admins, developers]
  
  kubernetes:
    cluster:
      read: [admins, developers]
      proxy: [admins]
```

### 3. 동적 권한 규칙

```typescript
// 소유권 기반 권한 예시
export const ownershipBasedPolicy = (
  request: PolicyQuery,
  user?: BackstageIdentityResponse,
): PolicyDecision => {
  
  // 엔티티 소유자 확인
  const entityOwner = request.resource?.metadata?.annotations?.['backstage.io/owner'];
  const userRef = user?.identity.userEntityRef;
  
  if (entityOwner === userRef) {
    return { result: AuthorizeResult.ALLOW };
  }
  
  // 그룹 소유권 확인
  const userGroups = user?.identity.ownershipEntityRefs || [];
  if (userGroups.includes(entityOwner)) {
    return { result: AuthorizeResult.ALLOW };
  }
  
  return { result: AuthorizeResult.DENY };
};
```

---

## 트러블슈팅

### 일반적인 문제 및 해결 방법

#### 1. "Invalid nonce" 오류

**원인**: OAuth 인증 과정에서 보안 토큰 불일치

**해결 방법**:
```bash
# 1. 브라우저 캐시 및 쿠키 삭제
# 2. Google Cloud Console에서 리다이렉트 URI 확인
# 3. app-config.yaml에 추가 스코프 설정 확인
additionalScopes:
  - openid
  - profile
  - email
```

#### 2. "Unable to resolve user identity" 오류

**원인**: 사용자 엔티티와 Google 계정 매칭 실패

**해결 방법**:
```yaml
# org.yaml에서 사용자 엔티티 확인
metadata:
  annotations:
    backstage.io/managed-by-location: 'url:file:///examples/org.yaml'
spec:
  profile:
    email: google-login-email@domain.com  # Google 로그인 이메일과 정확히 일치해야 함
```

#### 3. 권한 거부 문제

**원인**: 사용자가 적절한 그룹에 속하지 않음

**해결 방법**:
```yaml
# 사용자의 memberOf 확인
spec:
  memberOf: [appropriate-group-name]
```

### 디버깅 도구

#### 1. 사용자 정보 확인
```bash
# 카탈로그에서 사용자 엔티티 확인
curl http://localhost:7007/api/catalog/entities/by-name/user/default/username
```

#### 2. 권한 상태 확인
```bash
# 권한 정책 상태 확인
curl -H "Authorization: Bearer $TOKEN" \
     http://localhost:7007/api/permission/authorize
```

#### 3. 로그 모니터링
```bash
# 백엔드 로그에서 인증 관련 오류 확인
yarn start --verbose
```

### 보안 고려사항

1. **환경 변수 보안**
   - `.env` 파일을 `.gitignore`에 추가
   - 프로덕션에서는 환경 변수 또는 시크릿 관리 도구 사용

2. **세션 관리**
   - 적절한 세션 만료 시간 설정
   - HTTPS 사용 (프로덕션 환경)

3. **권한 최소화 원칙**
   - 사용자에게 필요한 최소한의 권한만 부여
   - 정기적인 권한 검토 및 업데이트

---

## 참고 자료

- [Backstage Authentication Documentation](https://backstage.io/docs/auth/)
- [Backstage Permission Framework](https://backstage.io/docs/permissions/)
- [Google OAuth 2.0 Documentation](https://developers.google.com/identity/protocols/oauth2)
- [Backstage Catalog Model](https://backstage.io/docs/features/software-catalog/descriptor-format)

---

**작성일**: 2024년 10월 16일  
**버전**: 1.0  
**작성자**: Backstage 관리팀
