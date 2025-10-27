# 새로운 Backstage 프로젝트 생성 가이드

## 목적
완전히 새로운 환경에서 Backstage를 처음부터 구축할 때 사용하는 가이드입니다.

---

## 방법 1: 공식 Backstage 생성 도구 사용 (권장 ⭐)

### Step 1: Backstage 생성

```bash
# 새 폴더 생성
mkdir my-new-backstage
cd my-new-backstage

# Backstage 앱 생성
npx @backstage/create-app@latest
```

### Step 2: 질문에 답변

```
? Enter a name for the app [required]
→ backstage

? Select database for the backend
→ PostgreSQL

? How would you like to use Backstage?
→ I want to explore Backstage
  (또는 "I have a backend ready")

? Select database for the backend
→ PostgreSQL
```

### Step 3: 완료

```
✅  Created a new Backstage application!

실행 방법:
  cd backstage
  yarn install
  yarn dev
```

---

## 방법 2: 기존 rnd-backstage 기반으로 생성

### Step 1: rnd-backstage 확인

```bash
# 기존 rnd-backstage 폴더 확인
ls /Users/seojiwon/VNTG_PROJECT/rnd-backstage
```

### Step 2: 새 위치로 복사

```bash
# 새 폴더 생성
mkdir /Users/seojiwon/VNTG_PROJECT/my-backstage
cd /Users/seojiwon/VNTG_PROJECT/my-backstage

# rnd-backstage 복사
rsync -av \
  --exclude='.git' \
  --exclude='node_modules' \
  --exclude='dist' \
  --exclude='*.log' \
  /Users/seojiwon/VNTG_PROJECT/rnd-backstage/ .
```

### Step 3: Docker 설정

```bash
# setup-backstage.sh 실행
./setup-backstage.sh
```

---

## 두 방법 비교

| 방법 | 용도 | 장점 | 단점 |
|------|------|------|------|
| **방법 1** | 완전히 새로운 Backstage | 공식 도구, 최신 버전, 공식 문서 지원 | 커스터마이징 필요한 경우 설정 추가 필요 |
| **방법 2** | 기존 rnd-backstage 설정 재사용 | 기존 설정 그대로 사용, 빠른 배포 | rnd-backstage에 종속성 |

---

## 추천 사용 시나리오

### 시나리오 1: 처음 Backstage 배포
→ **방법 1** 사용
```bash
npx @backstage/create-app@latest
```

### 시나리오 2: 동일한 설정으로 새 환경 구축
→ **방법 2** 사용
```bash
# rnd-backstage 폴더에서 실행
./setup-backstage.sh
```

### 시나리오 3: 기존 rnd-backstage를 다른 위치로 복사
→ **방법 2** + rnd-backstage 경로 지정

---

## 자주 묻는 질문

### Q: setup-backstage.sh는 왜 기존 폴더를 찾나요?
**A:** 이 스크립트는 "기존 rnd-backstage를 Docker로 컨테이너화"하는 것이 목적입니다. Backstage를 처음부터 생성하는 것이 아닙니다.

### Q: 완전히 새로운 Backstage를 만들려면?
**A:** 방법 1 사용:
```bash
npx @backstage/create-app@latest
```

### Q: 기존 rnd-backstage 설정을 새 환경에 복제하려면?
**A:** 방법 2 사용:
```bash
# rnd-backstage 폴더에서
./setup-backstage.sh
```

---

## 요약

| 목적 | 사용할 도구 |
|------|------------|
| 🆕 **처음부터 Backstage 생성** | `npx @backstage/create-app` |
| 📦 **기존 rnd-backstage 컨테이너화** | `./setup-backstage.sh` (rnd-backstage 폴더에서) |
| 📋 **기존 rnd-backstage 복사** | `./setup-backstage.sh` + 경로 지정 |

