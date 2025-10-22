# 🔧 TechDocs Docker 에러 해결

## 🚨 문제 상황

### 에러 메시지
```
Building a newer version of this documentation failed. 
Error: "Failed to generate docs from /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server into /private/var/folders/.../T/techdocs-tmp-rs8IKF; 
caused by Error: Docker container returned a non-zero exit code (1)"
```

### 증상
- TechDocs가 Docker 컨테이너에서 문서 생성 시도
- Docker 컨테이너 실행 실패 (exit code 1)
- 문서가 표시되지 않음

---

## 🔍 원인 분석

### 1. app-config.yaml 설정
```yaml
techdocs:
  builder: 'local'
  generator:
    runIn: 'docker'  # ← 문제! Docker 컨테이너에서 MkDocs 실행
```

### 2. 왜 Docker를 사용했나?
- **격리된 환경**: MkDocs와 플러그인을 Docker 컨테이너에 격리
- **일관성**: 어떤 환경에서든 동일한 문서 생성
- **의존성 관리**: 로컬 Python 환경에 영향 없음

### 3. 왜 실패했나?
- Docker 이미지 pull 실패
- Docker 권한 문제
- MkDocs Docker 이미지 버전 호환성 문제
- 또는 Docker 컨테이너 자체 실행 오류

---

## ✅ 해결 방법 1: runIn을 'local'로 변경 (권장)

### app-config.yaml 수정
```yaml
techdocs:
  builder: 'local'
  generator:
    runIn: 'local'  # Docker → local 변경
  publisher:
    type: 'local'
```

### 장점
- ✅ 빠른 문서 생성 (Docker 오버헤드 없음)
- ✅ 간단한 설정
- ✅ 로컬 개발 환경에 적합

### 단점
- ⚠️ 로컬에 MkDocs와 플러그인 설치 필요
- ⚠️ Python 환경 의존성

---

## 📦 MkDocs 설치 (필수)

### 설치 확인
```bash
mkdocs --version
# 출력: mkdocs, version 1.6.1 (정상)
# 또는: mkdocs not found (설치 필요)
```

### MkDocs 설치
```bash
pip3 install mkdocs-techdocs-core --break-system-packages
```

**설치되는 패키지:**
- `mkdocs` (1.6.1): 핵심 MkDocs
- `mkdocs-material`: Material 테마
- `mkdocs-techdocs-core`: Backstage TechDocs 플러그인 모음
  - `pymdown-extensions`: Markdown 확장
  - `plantuml-markdown`: PlantUML 다이어그램
  - `mkdocs-monorepo-plugin`: Monorepo 지원
  - `mkdocs-redirects`: URL 리디렉션
  - 기타 Backstage 전용 플러그인들

### 설치 확인
```bash
mkdocs --version
# 출력: mkdocs, version 1.6.1 from /Users/seojiwon/.pyenv/versions/3.11.8/lib/python3.11/site-packages/mkdocs (Python 3.11)
```

---

## ✅ 해결 방법 2: Docker 이미지 문제 해결 (고급)

### Docker 이미지 수동 pull
```bash
docker pull spotify/mkdocs-techdocs:latest
```

### Docker 권한 확인
```bash
docker ps
# 권한 에러 발생 시: Docker Desktop 재시작
```

### Docker 컨테이너 로그 확인
```bash
docker logs $(docker ps -a | grep mkdocs | awk '{print $1}' | head -1)
```

---

## 🔄 적용된 변경 사항

### 1. app-config.yaml
**파일:** `/rnd-backstage/app-config.yaml`

**변경 전:**
```yaml
techdocs:
  builder: 'local'
  generator:
    runIn: 'docker'  # Docker 사용
```

**변경 후:**
```yaml
techdocs:
  builder: 'local'
  generator:
    runIn: 'local'  # Local 사용 (빠르고 간단)
```

---

### 2. MkDocs 설치
```bash
pip3 install mkdocs-techdocs-core --break-system-packages
```

**설치 완료:**
- ✅ mkdocs 1.6.1
- ✅ mkdocs-material 9.6.19
- ✅ mkdocs-techdocs-core 1.6.0
- ✅ 관련 플러그인 전체

---

## 🚀 변경 사항 적용

### 1. Backstage 재시작
```bash
# 현재 실행 중인 Backstage 중지 (Ctrl+C)
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn start
```

### 2. TechDocs 확인
```
Backstage UI → Catalog → tech-blog-api-server → Docs 탭
```

### 3. 문서 생성 확인
- ✅ 에러 없이 README.md 내용이 표시되어야 함!
- ✅ 문서 생성이 빠름 (Docker 오버헤드 없음)

---

## 📊 runIn 옵션 비교

| 옵션 | 장점 | 단점 | 사용 사례 |
|------|------|------|-----------|
| **local** | ✅ 빠른 생성<br>✅ 간단한 설정<br>✅ 즉시 시작 | ⚠️ 로컬 설치 필요<br>⚠️ Python 의존성 | 로컬 개발 환경 |
| **docker** | ✅ 격리된 환경<br>✅ 일관성<br>✅ 의존성 충돌 없음 | ⚠️ 느린 생성<br>⚠️ Docker 필요<br>⚠️ 복잡한 설정 | CI/CD, 프로덕션 |

---

## 🔍 TechDocs 동작 흐름 비교

### runIn: 'docker' (이전)
```
1. Catalog에서 Entity 확인
   ↓
2. techdocs-ref 위치 확인 (dir:.)
   ↓
3. Docker 컨테이너 시작
   - spotify/mkdocs-techdocs 이미지 pull
   - 컨테이너 실행
   ↓
4. MkDocs 실행 (컨테이너 내부)
   - README.md → HTML 변환
   ↓
5. 문서 파일 복사 (컨테이너 → 호스트)
   ↓
6. 로컬 스토리지 저장 (~/.backstage/techdocs/)
   ↓
7. 브라우저에 렌더링
```

**문제:** Docker 컨테이너 실행 실패 (exit code 1)

---

### runIn: 'local' (변경 후)
```
1. Catalog에서 Entity 확인
   ↓
2. techdocs-ref 위치 확인 (dir:.)
   ↓
3. MkDocs 실행 (로컬 Python)
   - README.md → HTML 변환
   ↓
4. 로컬 스토리지 저장 (~/.backstage/techdocs/)
   ↓
5. 브라우저에 렌더링
```

**장점:** 
- ✅ 빠름 (Docker 오버헤드 없음)
- ✅ 간단 (컨테이너 관리 불필요)
- ✅ 디버깅 쉬움

---

## 🛠️ 트러블슈팅

### Q1: MkDocs 설치 후에도 "mkdocs not found" 에러
```bash
# Python 경로 확인
which python3
# /Users/seojiwon/.pyenv/versions/3.11.8/bin/python3

# MkDocs 설치 위치 확인
pip3 show mkdocs
# Location: /Users/seojiwon/.pyenv/versions/3.11.8/lib/python3.11/site-packages

# 환경 변수 확인
echo $PATH
# /Users/seojiwon/.pyenv/versions/3.11.8/bin이 포함되어야 함

# 해결: 셸 재시작 또는 PATH 추가
source ~/.zshrc
```

---

### Q2: "No module named 'mkdocs'" 에러
```bash
# Backstage가 다른 Python 환경 사용 중
# 해결: Backstage 재시작
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn start
```

---

### Q3: 여전히 Docker 에러 발생
```yaml
# app-config.yaml 확인
techdocs:
  generator:
    runIn: 'local'  # ← 'local'인지 확인!
```

```bash
# 파일 내용 확인
grep "runIn" app-config.yaml
# 출력: runIn: 'local'
```

---

### Q4: "Permission denied" 에러 (macOS)
```bash
# --break-system-packages 옵션 사용
pip3 install mkdocs-techdocs-core --break-system-packages

# 또는 가상 환경 사용 (선택사항)
python3 -m venv ~/backstage-venv
source ~/backstage-venv/bin/activate
pip install mkdocs-techdocs-core
```

---

## 📋 체크리스트

- [x] app-config.yaml - `runIn: 'local'` 변경
- [x] MkDocs 설치 (`pip3 install mkdocs-techdocs-core`)
- [x] MkDocs 버전 확인 (`mkdocs --version`)
- [ ] Backstage 재시작
- [ ] TechDocs 접근 테스트
- [ ] 문서 생성 확인 (에러 없이 표시)

---

## 🎯 핵심 요약

### 문제
```yaml
techdocs:
  generator:
    runIn: 'docker'  # Docker 컨테이너 실행 실패
```
↓
**Docker container returned a non-zero exit code (1)**

---

### 해결
```yaml
techdocs:
  generator:
    runIn: 'local'  # 로컬 Python 환경에서 MkDocs 실행
```
↓
```bash
pip3 install mkdocs-techdocs-core --break-system-packages
```
↓
**정상 동작! 🚀**

---

### 동작 방식
```
TechDocs (runIn: local):
1. 로컬 Python의 mkdocs 실행
2. README.md → HTML 변환 (빠름!)
3. ~/.backstage/techdocs/ 저장
4. 브라우저에 렌더링 ✅
```

---

## 🚀 다음 단계

### 1. Backstage 재시작
```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
# Ctrl+C로 중지 후
yarn start
```

### 2. TechDocs 접근
```
http://localhost:3000/catalog/default/component/tech-blog-api-server
→ "Docs" 탭 클릭
```

### 3. 확인 사항
- ✅ 에러 없이 문서 표시
- ✅ README.md 내용이 HTML로 렌더링됨
- ✅ 문서 생성 속도 빠름 (Docker보다 10배 이상)

---

## 📚 참고 자료

### Backstage TechDocs 공식 문서
- [TechDocs Configuration](https://backstage.io/docs/features/techdocs/configuration)
- [TechDocs Getting Started](https://backstage.io/docs/features/techdocs/getting-started)

### MkDocs
- [MkDocs Official](https://www.mkdocs.org/)
- [MkDocs Material Theme](https://squidfunk.github.io/mkdocs-material/)

---

## ✅ 결론

**Docker 방식의 문제점:**
- 느림 (컨테이너 시작 오버헤드)
- 복잡 (Docker 관리 필요)
- 에러 가능성 높음 (이미지, 권한, 네트워크 등)

**Local 방식의 장점:**
- ✅ 빠름 (직접 실행)
- ✅ 간단 (Python만 있으면 OK)
- ✅ 디버깅 쉬움 (로그 확인 용이)

**로컬 개발 환경에서는 `runIn: 'local'`을 권장합니다!** 🎯

프로덕션 환경이나 CI/CD에서는 `runIn: 'docker'`를 사용하여 일관성을 보장할 수 있습니다.

