---
name: git:4.push
description: "Remote에 Push (isolated fork)"
context: fork
allowed-tools: [Bash]
model: haiku
---

# Remote에 Push

현재 브랜치를 remote에 push한다.

---

## 스크립트 실행

먼저 스크립트 존재 여부를 확인:

```bash
[ -d "./scripts" ] && echo "EXISTS" || echo "NOT_FOUND"
```

### 스크립트가 있으면 (EXISTS)

```bash
./scripts/git-push.sh
```

### 스크립트가 없으면 (NOT_FOUND)

```bash
cp -r ~/.claude/plugins/cache/nasodev-marketplace/git-workflow/*/scripts ./scripts && chmod +x ./scripts/*.sh && echo "✅ scripts 폴더 복사 완료" && ./scripts/git-push.sh
```

---

## 옵션

```bash
./scripts/git-push.sh -f    # force push (주의)
```

## 예상 결과

- 커밋되지 않은 변경사항 확인
- push할 커밋 목록 표시
- lint 검사 (선택, 자동 감지)
- 첫 push시 upstream 자동 설정 (-u)
- main/master 직접 push 경고

## Lint 지원 언어

| 언어 | 감지 파일 | 린터 |
|------|----------|------|
| Node.js | package.json | npm run lint |
| Python | pyproject.toml, setup.py | ruff, pylint, flake8 |
| Go | go.mod | go vet |
| Rust | Cargo.toml | cargo clippy |
| Java | build.gradle, pom.xml | checkstyle |

## 워크플로우

```
1.branch → 2.sync → 3.commit → [4.push] → 5.pr → 6.merge
```
