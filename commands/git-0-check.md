---
name: git:0.check
description: "Git 상태 확인 (isolated fork)"
context: fork
allowed-tools: [Bash]
model: opus
---

# Git 상태 및 설정 확인

현재 저장소의 브랜치, 사용자 설정, 작업 상태를 확인한다.

---

## 스크립트 실행

**플러그인 스크립트를 직접 실행 (설치 스코프에 따라 경로 자동 탐색):**

```bash
SCRIPT=$(find ~/.claude/plugins ./.claude/plugins -path "*/git-workflow/*/scripts/git-check.sh" 2>/dev/null | head -1) && bash "$SCRIPT"
```

---

## 필수 출력 (반드시 사용자에게 보여줄 것)

스크립트 실행 후 **아래 정보를 요약해서 반드시 표시**해라:

1. **현재 브랜치** 및 upstream 상태
2. **User Configuration** - Local/Global/Effective name과 email (커밋 시 누구 이름으로 올라가는지 중요!)
3. **Working Directory** - 변경사항 개수
4. **최근 커밋** 3개

---

## 표시 정보

### Repository
- 저장소 이름, 경로
- Remote URL

### Branch
- 현재 브랜치
- 기본 브랜치
- 로컬/리모트 브랜치 개수
- Upstream 상태 (ahead/behind)

### User Configuration
- Local 설정 (name, email)
- Global 설정 (name, email)
- 실제 사용될 설정

### Working Directory
- Staged/Unstaged/Untracked 파일 수
- Stash 개수

### Recent Commits
- 최근 5개 커밋

### Additional Settings
- GPG 서명 여부
- 에디터
- Credential helper

## 워크플로우

```
[0.check] → 1.branch → 2.sync → 3.commit → 4.push → 5.pr → 6.merge
```
