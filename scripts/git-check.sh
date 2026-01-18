#!/bin/bash
#
# git-check.sh
# Git 상태 및 설정 정보를 표시하는 스크립트
#
# 사용법:
#   ./scripts/git-check.sh
#

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Git Status & Configuration${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ─────────────────────────────────────────────
# 1. 저장소 정보
# ─────────────────────────────────────────────
echo -e "\n${CYAN}[Repository]${NC}"

# Git 저장소인지 확인
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo -e "${RED}현재 디렉토리는 Git 저장소가 아닙니다.${NC}"
    exit 1
fi

REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
echo -e "  이름: ${GREEN}${REPO_NAME}${NC}"
echo -e "  경로: ${REPO_ROOT}"

# Remote 정보
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "없음")
echo -e "  Remote: ${REMOTE_URL}"

# ─────────────────────────────────────────────
# 2. 브랜치 정보
# ─────────────────────────────────────────────
echo -e "\n${CYAN}[Branch]${NC}"

CURRENT_BRANCH=$(git branch --show-current)
echo -e "  현재: ${GREEN}${CURRENT_BRANCH}${NC}"

# Default 브랜치
DEFAULT_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
if [ -z "$DEFAULT_BRANCH" ]; then
    DEFAULT_BRANCH="main (추정)"
fi
echo -e "  기본: ${DEFAULT_BRANCH}"

# 브랜치 개수
LOCAL_BRANCHES=$(git branch | wc -l | tr -d ' ')
REMOTE_BRANCHES=$(git branch -r 2>/dev/null | wc -l | tr -d ' ')
echo -e "  로컬: ${LOCAL_BRANCHES}개 / 리모트: ${REMOTE_BRANCHES}개"

# Upstream 정보
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")
if [ -n "$UPSTREAM" ]; then
    echo -e "  Upstream: ${UPSTREAM}"

    # ahead/behind
    AHEAD=$(git rev-list --count "${UPSTREAM}..HEAD" 2>/dev/null || echo "0")
    BEHIND=$(git rev-list --count "HEAD..${UPSTREAM}" 2>/dev/null || echo "0")

    if [ "$AHEAD" -gt 0 ] || [ "$BEHIND" -gt 0 ]; then
        echo -e "  상태: ${YELLOW}↑${AHEAD} ↓${BEHIND}${NC}"
    else
        echo -e "  상태: ${GREEN}최신${NC}"
    fi
else
    echo -e "  Upstream: ${YELLOW}없음 (첫 push 필요)${NC}"
fi

# ─────────────────────────────────────────────
# 3. 사용자 설정
# ─────────────────────────────────────────────
echo -e "\n${CYAN}[User Configuration]${NC}"

# Local 설정
LOCAL_NAME=$(git config --local user.name 2>/dev/null || echo "")
LOCAL_EMAIL=$(git config --local user.email 2>/dev/null || echo "")

echo -e "  ${MAGENTA}Local:${NC}"
if [ -n "$LOCAL_NAME" ]; then
    echo -e "    name:  ${GREEN}${LOCAL_NAME}${NC}"
else
    echo -e "    name:  ${YELLOW}(설정 안됨)${NC}"
fi

if [ -n "$LOCAL_EMAIL" ]; then
    echo -e "    email: ${GREEN}${LOCAL_EMAIL}${NC}"
else
    echo -e "    email: ${YELLOW}(설정 안됨)${NC}"
fi

# Global 설정
GLOBAL_NAME=$(git config --global user.name 2>/dev/null || echo "")
GLOBAL_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

echo -e "  ${MAGENTA}Global:${NC}"
if [ -n "$GLOBAL_NAME" ]; then
    echo -e "    name:  ${GREEN}${GLOBAL_NAME}${NC}"
else
    echo -e "    name:  ${YELLOW}(설정 안됨)${NC}"
fi

if [ -n "$GLOBAL_EMAIL" ]; then
    echo -e "    email: ${GREEN}${GLOBAL_EMAIL}${NC}"
else
    echo -e "    email: ${YELLOW}(설정 안됨)${NC}"
fi

# 실제 사용될 설정
EFFECTIVE_NAME=$(git config user.name 2>/dev/null || echo "")
EFFECTIVE_EMAIL=$(git config user.email 2>/dev/null || echo "")

echo -e "  ${MAGENTA}Effective (실제 사용):${NC}"
echo -e "    name:  ${GREEN}${EFFECTIVE_NAME}${NC}"
echo -e "    email: ${GREEN}${EFFECTIVE_EMAIL}${NC}"

# ─────────────────────────────────────────────
# 4. 작업 상태
# ─────────────────────────────────────────────
echo -e "\n${CYAN}[Working Directory]${NC}"

# 변경사항 확인
STAGED=$(git diff --cached --name-only | wc -l | tr -d ' ')
UNSTAGED=$(git diff --name-only | wc -l | tr -d ' ')
UNTRACKED=$(git ls-files --others --exclude-standard | wc -l | tr -d ' ')

echo -e "  Staged:    ${STAGED}개"
echo -e "  Unstaged:  ${UNSTAGED}개"
echo -e "  Untracked: ${UNTRACKED}개"

if [ "$STAGED" -eq 0 ] && [ "$UNSTAGED" -eq 0 ] && [ "$UNTRACKED" -eq 0 ]; then
    echo -e "  상태: ${GREEN}Clean${NC}"
else
    echo -e "  상태: ${YELLOW}변경사항 있음${NC}"
fi

# Stash 개수
STASH_COUNT=$(git stash list 2>/dev/null | wc -l | tr -d ' ')
if [ "$STASH_COUNT" -gt 0 ]; then
    echo -e "  Stash: ${YELLOW}${STASH_COUNT}개${NC}"
fi

# ─────────────────────────────────────────────
# 5. 최근 커밋
# ─────────────────────────────────────────────
echo -e "\n${CYAN}[Recent Commits]${NC}"
git log --oneline -5 2>/dev/null | while read -r line; do
    echo -e "  $line"
done

# ─────────────────────────────────────────────
# 6. 추가 설정
# ─────────────────────────────────────────────
echo -e "\n${CYAN}[Additional Settings]${NC}"

# GPG 서명
GPG_SIGN=$(git config commit.gpgsign 2>/dev/null || echo "false")
echo -e "  GPG 서명: ${GPG_SIGN}"

# Default 에디터
EDITOR=$(git config core.editor 2>/dev/null || echo "${EDITOR:-vim}")
echo -e "  에디터: ${EDITOR}"

# Credential helper
CREDENTIAL=$(git config credential.helper 2>/dev/null || echo "없음")
echo -e "  Credential: ${CREDENTIAL}"

echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
