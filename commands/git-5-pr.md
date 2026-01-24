---
name: git:5.pr
description: "Pull Request 생성 (isolated fork)"
context: fork
allowed-tools: [Bash]
model: opus
---

# Pull Request 생성

GitHub Pull Request를 생성한다.

---

## 스크립트 실행

**플러그인 스크립트를 직접 실행 (설치 스코프에 따라 경로 자동 탐색):**

```bash
SCRIPT=$(find ~/.claude/plugins ./.claude/plugins -path "*/git-workflow/*/scripts/git-pr.sh" 2>/dev/null | head -1) && bash "$SCRIPT"
```

---

## 옵션

```bash
./scripts/git-pr.sh -t "PR 제목"    # 제목 지정
./scripts/git-pr.sh -b develop      # base 브랜치 지정 (기본: main)
./scripts/git-pr.sh --draft         # draft PR로 생성
```

## 예상 결과

- 기존 PR 중복 확인
- push 상태 확인 (필요시 자동 push)
- 변경사항 요약 (커밋 수, 파일 수)
- PR 제목/본문 입력
- PR 생성 및 URL 출력
- 브라우저에서 열기 (선택)

## 필요 조건

- gh CLI 설치: `brew install gh`
- gh 인증: `gh auth login`

## 워크플로우

```
1.branch → 2.sync → 3.commit → 4.push → [5.pr] → 6.merge
```
