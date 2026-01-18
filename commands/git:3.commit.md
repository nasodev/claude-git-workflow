---
name: git:3.commit
description: "변경사항 커밋 (isolated fork)"
context: fork
allowed-tools: [Bash]
model: opus
---

# 변경사항 커밋

현재 미커밋 변경사항을 확인하고 커밋한다.

---

## 스크립트 실행

**플러그인 스크립트를 직접 실행 (프로젝트에 복사하지 않음):**

```bash
bash ~/.claude/plugins/cache/nasodev-marketplace/git-workflow/*/scripts/git-commit.sh
```

---

## 옵션

```bash
./scripts/git-commit.sh -m "메시지"     # 메시지 직접 지정
./scripts/git-commit.sh --all           # 모든 변경사항 자동 staging
./scripts/git-commit.sh -a -m "메시지"  # 조합
```

## 예상 결과

- Staged/Unstaged/Untracked 파일 분류 표시
- 변경 내용 요약 (diff --stat)
- 대화형 staging 선택
- 최근 커밋 5개 표시 (스타일 참고)
- 커밋 메시지 입력 (50자 초과 경고)
- 최종 확인 후 커밋

## 커밋 메시지 규칙

- 한글 사용
- 첫 줄: 변경 요약 (50자 이내)
- 본문: 주요 변경 내용 bullet point

## 워크플로우

```
1.branch → 2.sync → [3.commit] → 4.push → 5.pr → 6.merge
```
