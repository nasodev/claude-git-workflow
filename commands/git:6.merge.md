---
name: git:6.merge
description: "Main에 머지 (isolated fork)"
context: fork
allowed-tools: [Bash]
model: haiku
---

# Main에 머지

현재 브랜치를 main에 머지하고 remote에 push한다.

---

## 스크립트 실행

먼저 스크립트 존재 여부를 확인:

```bash
[ -d "./scripts" ] && echo "EXISTS" || echo "NOT_FOUND"
```

### 스크립트가 있으면 (EXISTS)

```bash
./scripts/merge-to-main.sh
```

### 스크립트가 없으면 (NOT_FOUND)

```bash
cp -r ~/.claude/plugins/cache/nasodev-marketplace/git-workflow/*/scripts ./scripts && chmod +x ./scripts/*.sh && echo "✅ scripts 폴더 복사 완료" && ./scripts/merge-to-main.sh
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
