# Git Workflow Plugin for Claude Code

Git 워크플로우 자동화를 위한 Claude Code 플러그인입니다.

## 기능

대화형 스크립트를 통한 Git 워크플로우 자동화:

| 커맨드 | 설명 |
|--------|------|
| `/git-0-check` | Git 상태 및 설정 확인 |
| `/git-1-branch` | 새 브랜치 생성 |
| `/git-2-sync` | main 브랜치 동기화 |
| `/git-3-commit` | 변경사항 커밋 |
| `/git-4-push` | Remote에 Push |
| `/git-5-pr` | Pull Request 생성 |
| `/git-6-merge` | Main에 머지 |

## 워크플로우

```
/git-0-check → /git-1-branch → /git-2-sync → /git-3-commit → /git-4-push → /git-5-pr → /git-6-merge
     ↓              ↓              ↓              ↓              ↓            ↓            ↓
  상태확인      새 브랜치       최신화          커밋          push        PR생성        머지
```

## 설치

### 방법 1: Marketplace를 통한 설치 (권장)

```bash
# 1. Marketplace 추가
/plugin marketplace add nasodev/nasodev-marketplace

# 2. 플러그인 설치
/plugin install git-workflow@nasodev-marketplace
```

### 방법 2: 수동 설치

프로젝트에 직접 복사:

```bash
# GitHub에서 다운로드
curl -sL https://github.com/nasodev/claude-git-workflow/archive/main.tar.gz | tar xz

# commands 복사
mkdir -p .claude/commands
cp claude-git-workflow-main/commands/* .claude/commands/

# scripts 복사
cp -r claude-git-workflow-main/scripts ./scripts

# 실행 권한 부여
chmod +x ./scripts/*.sh

# 정리
rm -rf claude-git-workflow-main
```

## 스크립트 기능

### git-check.sh
- 저장소 정보 (이름, 경로, Remote)
- 브랜치 상태 (현재, 기본, ahead/behind)
- 사용자 설정 (Local, Global, Effective)
- 작업 상태 (Staged, Unstaged, Untracked, Stash)
- 최근 커밋 5개
- 추가 설정 (GPG, 에디터, Credential)

### git-branch.sh
- 변경사항 자동 stash
- main 기준 시 최신화 제안
- 브랜치명 유효성/중복 검사

### git-commit.sh
- Staged/Unstaged/Untracked 분류 표시
- 대화형 staging
- 커밋 메시지 50자 초과 경고

### git-push.sh
- 멀티 언어 lint 지원 (Node.js, Python, Go, Rust, Java)
- 첫 push시 upstream 자동 설정
- main/master 직접 push 경고

### git-pr.sh
- 기존 PR 중복 확인
- 변경사항 요약
- gh CLI 연동

### sync-main.sh
- main 최신 변경사항 동기화
- 자동 stash/복원

### merge-to-main.sh
- main 머지 및 push
- 원래 브랜치로 자동 복귀

## 필요 조건

- Git
- Bash
- gh CLI (PR 생성용): `brew install gh`

## 커밋 메시지 규칙

- 한글 사용
- 첫 줄: 변경 요약 (50자 이내)
- 본문: 주요 변경 내용 bullet point

## 브랜치 네이밍 규칙

- `feature/<기능명>` - 새 기능
- `fix/<버그명>` - 버그 수정
- `draft` - 임시 작업
- `post/<글제목>` - 블로그 포스트

## 라이선스

MIT
