---
description: "main 브랜치 동기화"
context: fork
---

# main 브랜치 동기화

main 브랜치의 최신 변경사항을 현재 브랜치로 가져온다.

---

**⚠️ 반드시 Bash tool로 아래 스크립트를 실행해라. 다른 방법은 허용하지 않는다.**

```bash
./scripts/sync-main.sh
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
