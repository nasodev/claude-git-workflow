---
name: git:2.sync
description: "main 브랜치 동기화 (isolated fork)"
context: fork
allowed-tools: [Bash]
model: haiku
---

# main 브랜치 동기화

main 브랜치의 최신 변경사항을 현재 브랜치로 가져온다.

---

## 스크립트 실행

먼저 스크립트 존재 여부를 확인:

```bash
[ -d "./scripts" ] && echo "EXISTS" || echo "NOT_FOUND"
```

### 스크립트가 있으면 (EXISTS)

```bash
./scripts/sync-main.sh
```

### 스크립트가 없으면 (NOT_FOUND)

```bash
cp -r ~/.claude/plugins/cache/nasodev-marketplace/git-workflow/*/scripts ./scripts && chmod +x ./scripts/*.sh && echo "✅ scripts 폴더 복사 완료" && ./scripts/sync-main.sh
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
