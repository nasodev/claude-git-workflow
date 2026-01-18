---
name: git:4.push
description: "Remote에 Push (isolated fork)"
context: fork
allowed-tools: [Bash]
model: opus
---

# Remote에 Push

현재 브랜치를 remote에 push한다.

---

## 스크립트 실행

**플러그인 스크립트를 직접 실행 (프로젝트에 복사하지 않음):**

```bash
bash ~/.claude/plugins/cache/nasodev-marketplace/git-workflow/*/scripts/git-push.sh
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
