---
name: git:2.sync
description: "main 브랜치 동기화 (isolated fork)"
context: fork
allowed-tools: [Bash]
model: opus
---

# main 브랜치 동기화

main 브랜치의 최신 변경사항을 현재 브랜치로 가져온다.

---

## 스크립트 실행

**플러그인 스크립트를 직접 실행 (설치 스코프에 따라 경로 자동 탐색):**

```bash
SCRIPT=$(find ~/.claude/plugins ./.claude/plugins -path "*/git-workflow/*/scripts/sync-main.sh" 2>/dev/null | head -1) && bash "$SCRIPT"
```

---

## 옵션

```bash
./scripts/sync-main.sh develop   # 다른 소스 브랜치 지정
```

## 예상 결과

- remote/main pull
- 현재 브랜치에 main 머지
- 커밋되지 않은 변경사항은 자동 stash/복원

## 워크플로우

```
1.branch → [2.sync] → 3.commit → 4.push → 5.pr → 6.merge
```
