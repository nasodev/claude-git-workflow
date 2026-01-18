---
name: git:1.branch
description: "새 브랜치 생성 (isolated fork)"
context: fork
allowed-tools: [Bash]
model: opus
---

# 새 브랜치 생성

새 브랜치를 생성하고 전환한다.

---

## 스크립트 실행

**플러그인 스크립트를 직접 실행 (프로젝트에 복사하지 않음):**

```bash
bash ~/.claude/plugins/cache/nasodev-marketplace/git-workflow/*/scripts/git-branch.sh
```

---

## 옵션

```bash
./scripts/git-branch.sh feature/login      # 브랜치명 직접 지정
./scripts/git-branch.sh -f main draft      # main 기준으로 draft 생성
```

## 예상 결과

- 커밋되지 않은 변경사항 확인 (stash 선택)
- main/master 기준 시 remote 최신화 제안
- 기존 브랜치 목록 표시
- 브랜치명 유효성/중복 검사
- 새 브랜치 생성 및 전환
- stash 자동 복원

## 브랜치 네이밍 규칙

- `feature/<기능명>` - 새 기능
- `fix/<버그명>` - 버그 수정
- `draft` - 임시 작업
- `post/<글제목>` - 블로그 포스트

## 워크플로우

```
[1.branch] → 2.sync → 3.commit → 4.push → 5.pr → 6.merge
```
