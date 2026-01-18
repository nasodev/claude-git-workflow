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

먼저 스크립트 존재 여부를 확인:

```bash
[ -d "./scripts" ] && echo "EXISTS" || echo "NOT_FOUND"
```

### 스크립트가 있으면 (EXISTS)

```bash
./scripts/git-commit.sh
```

### 스크립트가 없으면 (NOT_FOUND)

```bash
cp -r ~/.claude/plugins/cache/nasodev-marketplace/git-workflow/*/scripts ./scripts && chmod +x ./scripts/*.sh && echo "✅ scripts 폴더 복사 완료" && ./scripts/git-commit.sh
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
