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

**⚠️ 반드시 Bash tool로 아래 스크립트를 실행해라. 다른 방법은 허용하지 않는다.**

```bash
./scripts/merge-to-main.sh
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
