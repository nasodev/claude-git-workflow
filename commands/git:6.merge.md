---
name: git:6.merge
description: "Main에 머지 (isolated fork)"
context: fork
allowed-tools: [Bash]
model: opus
---

# Main에 머지

현재 브랜치를 main에 머지하고 remote에 push한다.

---

## 스크립트 실행

**플러그인 스크립트를 직접 실행 (설치 스코프에 따라 경로 자동 탐색):**

```bash
SCRIPT=$(find ~/.claude/plugins ./.claude/plugins -path "*/git-workflow/*/scripts/merge-to-main.sh" 2>/dev/null | head -1) && bash "$SCRIPT"
```

---

## 예상 결과

- main 브랜치로 전환
- remote main pull (최신화)
- 현재 브랜치를 main에 머지
- remote에 push
- 원래 브랜치로 복귀

## 워크플로우

```
1.branch → 2.sync → 3.commit → 4.push → 5.pr → [6.merge]
```
