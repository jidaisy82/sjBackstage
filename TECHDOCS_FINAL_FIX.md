# ✅ TechDocs 최종 해결 가이드

## 🚨 문제 요약

### 에러 메시지
```
Failed to generate docs from .../api-server; 
caused by unknown error 'Command mkdocs failed, exit code: 1'
```

### 근본 원인
**`mkdocs.yml` 파일이 계속 재생성됨!**

---

## 🔍 발견된 문제

### 1. mkdocs.yml이 자동 생성됨
```bash
# 삭제해도 다시 생성되는 현상
rm mkdocs.yml
# → 잠시 후 다시 나타남!
```

### 2. 파일 내용
```yaml
site_name: tech-blog-api-server
docs_dir: docs              # ← 문제: docs/ 디렉토리 없음
plugins:
  - techdocs-core
```

### 3. 누가 생성하는가?
- Git에서 tracked 상태
- 또는 Backstage가 초기화 시 생성
- 또는 다른 도구가 생성

---

## ✅ 최종 해결책

### 1. mkdocs.yml 삭제 및 .gitignore 추가

```bash
cd /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server

# mkdocs.yml 삭제
rm -f mkdocs.yml

# .gitignore에 추가 (재생성 방지)
echo "mkdocs.yml" >> .gitignore
echo "site/" >> .gitignore
```

### 2. TechDocs 캐시 삭제

```bash
rm -rf ~/.backstage/techdocs/
```

### 3. Backstage 완전 재시작

```bash
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage

# Ctrl+C로 완전히 중지 후
yarn start
```

---

## 🔄 완료된 작업

### ✅ 체크리스트

- [x] mkdocs.yml 삭제
- [x] .gitignore에 mkdocs.yml 추가
- [x] .gitignore에 site/ 추가
- [x] TechDocs 캐시 삭제 (~/.backstage/techdocs/)
- [ ] **Backstage 재시작 (필수!)**
- [ ] TechDocs 접근 테스트

---

## 📁 현재 디렉토리 구조

### api-server/
```
api-server/
├── .gitignore           ✅ (mkdocs.yml, site/ 추가)
├── catalog-info.yaml    ✅ (techdocs-ref: dir:.)
├── README.md           ✅ (문서 소스)
└── (mkdocs.yml 없음)   ✅ (삭제됨, .gitignore로 재생성 방지)
```

---

## 🚀 다음 단계 (반드시 실행!)

### 1. Backstage 재시작

**중요: 현재 실행 중인 Backstage를 완전히 종료해야 합니다!**

```bash
# 터미널에서 Ctrl+C로 Backstage 중지

# 완전히 중지되었는지 확인
ps aux | grep "yarn start" | grep -v grep
# 출력 없으면 정상 종료됨

# 재시작
cd /Users/seojiwon/VNTG_PROJECT/rnd-backstage
yarn start
```

### 2. TechDocs 확인

```
1. Backstage UI 접속: http://localhost:3000
2. Catalog 메뉴 클릭
3. tech-blog-api-server 선택
4. Docs 탭 클릭
```

### 3. 기대 결과

- ✅ 에러 없이 README.md 내용 표시
- ✅ 빌드 성공 메시지
- ✅ 문서가 정상적으로 렌더링됨

---

## 🛠️ 트러블슈팅

### Q1: 재시작 후에도 같은 에러 발생

**확인 사항:**
```bash
# 1. mkdocs.yml이 다시 생성되었는지 확인
ls -la /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/mkdocs.yml
# 출력: No such file or directory (정상)

# 2. .gitignore 확인
cat /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/.gitignore | grep mkdocs
# 출력: mkdocs.yml (정상)

# 3. 캐시 완전 삭제
rm -rf ~/.backstage/techdocs/
```

---

### Q2: "mkdocs.yml이 다시 생성됨"

**원인:** Git이 tracked 상태

**해결:**
```bash
cd /Users/seojiwon/VNTG_PROJECT/RND-NX

# Git에서 완전히 제거
git rm --cached apps/tech-blog/api-server/mkdocs.yml

# 커밋
git commit -m "Remove mkdocs.yml from git tracking"

# 로컬에서 삭제
rm apps/tech-blog/api-server/mkdocs.yml

# .gitignore 확인
cat apps/tech-blog/api-server/.gitignore | grep mkdocs
```

---

### Q3: 여전히 "Command mkdocs failed" 에러

**직접 MkDocs 실행으로 디버깅:**
```bash
cd /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server

# MkDocs 직접 실행
mkdocs build --verbose 2>&1 | head -20

# 예상 결과 (mkdocs.yml 없을 때):
# INFO - Building documentation...
# INFO - Cleaning site directory
# ...성공 메시지...
```

**만약 에러 발생:**
```bash
# 에러 메시지 전체 확인
mkdocs build --verbose 2>&1 > /tmp/mkdocs-debug.log
cat /tmp/mkdocs-debug.log
```

---

## 💡 왜 mkdocs.yml을 사용하지 않는가?

### mkdocs.yml 있을 때 (복잡)
```
mkdocs.yml 존재
  ↓
docs_dir: docs 설정
  ↓
docs/ 디렉토리 필요
  ↓
docs/index.md 파일 필요
  ↓
유지보수 복잡 ❌
```

### mkdocs.yml 없을 때 (간단)
```
mkdocs.yml 없음
  ↓
Backstage가 README.md 자동 감지
  ↓
자동으로 임시 mkdocs.yml 생성
  ↓
README.md를 index.md로 사용
  ↓
유지보수 간단 ✅
```

---

## 📊 설정 비교

### ❌ 문제 상황 (mkdocs.yml 사용)
```yaml
# mkdocs.yml
site_name: tech-blog-api-server
docs_dir: docs              # docs/ 필요
plugins:
  - techdocs-core
```

**필요한 구조:**
```
api-server/
├── mkdocs.yml
└── docs/
    └── index.md           ← README.md 복사 필요
```

---

### ✅ 해결 후 (mkdocs.yml 없음)
```yaml
# catalog-info.yaml만 필요
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.
```

**필요한 구조:**
```
api-server/
├── catalog-info.yaml
└── README.md              ← 그대로 사용!
```

---

## 🎯 핵심 정리

### 문제의 순환
```
1. mkdocs.yml 존재
   ↓
2. docs/ 디렉토리 없음
   ↓
3. MkDocs 실행 실패
   ↓
4. TechDocs 에러
   ↓
5. mkdocs.yml 삭제
   ↓
6. (뭔가가) mkdocs.yml 재생성
   ↓
7. 다시 1번으로...
```

### 해결책
```
1. mkdocs.yml 삭제
   ↓
2. .gitignore에 추가 (재생성 방지)
   ↓
3. Git에서 제거 (tracked 해제)
   ↓
4. 캐시 삭제
   ↓
5. Backstage 재시작
   ↓
6. 문제 해결! ✅
```

---

## 📝 .gitignore 내용

### api-server/.gitignore에 추가된 내용
```gitignore
# TechDocs 관련 파일 무시
mkdocs.yml
site/
docs/
```

**이유:**
- `mkdocs.yml`: 자동 생성 방지
- `site/`: MkDocs 빌드 결과물
- `docs/`: 임시 문서 디렉토리

---

## ✅ 최종 확인

### 완료 체크리스트

**파일 상태:**
- [ ] mkdocs.yml 삭제됨
- [ ] .gitignore에 mkdocs.yml 추가됨
- [ ] Git tracking 제거됨
- [ ] README.md 존재함

**Backstage:**
- [ ] 캐시 삭제됨 (~/.backstage/techdocs/)
- [ ] Backstage 재시작됨
- [ ] 에러 없이 문서 표시됨

**확인 명령어:**
```bash
# 1. mkdocs.yml 없는지 확인
ls /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/mkdocs.yml
# 출력: No such file or directory ✅

# 2. .gitignore 확인
grep mkdocs /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/.gitignore
# 출력: mkdocs.yml ✅

# 3. README.md 확인
ls -lh /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server/README.md
# 출력: ... README.md ✅
```

---

## 🚀 결론

**문제:**
- mkdocs.yml이 계속 재생성됨
- docs/ 디렉토리 없어서 MkDocs 실패

**해결:**
- mkdocs.yml 삭제 + .gitignore 추가
- Git tracking 제거
- 캐시 삭제 + Backstage 재시작

**원리:**
- catalog-info.yaml (techdocs-ref: dir:.)
- README.md (문서 소스)
- mkdocs.yml 없음 → Backstage가 자동 처리

**다음:**
- **Backstage를 재시작하세요!**
- Docs 탭에서 README.md 확인
- 정상 동작 확인 ✅

---

## 📞 문제 지속 시

만약 위 모든 단계를 완료했는데도 문제가 지속되면:

1. **Backstage 로그 확인**
   ```bash
   # 터미널에서 Backstage 실행 중 에러 메시지 확인
   ```

2. **MkDocs 직접 테스트**
   ```bash
   cd /Users/seojiwon/VNTG_PROJECT/RND-NX/apps/tech-blog/api-server
   mkdocs build --verbose
   ```

3. **catalog-info.yaml 확인**
   ```bash
   grep "techdocs-ref" catalog-info.yaml
   # 출력: backstage.io/techdocs-ref: dir:.
   ```

**이제 Backstage를 재시작하면 정상 동작할 것입니다!** 🚀

