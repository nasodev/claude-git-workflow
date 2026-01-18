#!/bin/bash
#
# git-pr.sh
# GitHub Pull Request를 생성하는 스크립트
#
# 사용법:
#   ./scripts/git-pr.sh                    # 대화형 PR 생성
#   ./scripts/git-pr.sh -t "제목"          # 제목 지정
#   ./scripts/git-pr.sh -b main            # base 브랜치 지정
#   ./scripts/git-pr.sh --draft            # draft PR 생성
#
# 필요: gh CLI (GitHub CLI)
#

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 옵션 파싱
PR_TITLE=""
BASE_BRANCH="main"
IS_DRAFT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--title)
            PR_TITLE="$2"
            shift 2
            ;;
        -b|--base)
            BASE_BRANCH="$2"
            shift 2
            ;;
        -d|--draft)
            IS_DRAFT=true
            shift
            ;;
        -h|--help)
            echo "사용법: ./scripts/git-pr.sh [옵션]"
            echo ""
            echo "옵션:"
            echo "  -t, --title \"제목\"  PR 제목 지정"
            echo "  -b, --base <브랜치>  base 브랜치 (기본: main)"
            echo "  -d, --draft          draft PR로 생성"
            echo "  -h, --help           도움말 표시"
            exit 0
            ;;
        *)
            echo -e "${RED}알 수 없는 옵션: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  GitHub PR Creator${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# ─────────────────────────────────────────────
# 0. gh CLI 확인
# ─────────────────────────────────────────────
if ! command -v gh &> /dev/null; then
    echo -e "${RED}gh CLI가 설치되어 있지 않습니다.${NC}"
    echo -e "${YELLOW}설치: brew install gh${NC}"
    echo -e "${YELLOW}인증: gh auth login${NC}"
    exit 1
fi

# gh 인증 확인
if ! gh auth status &> /dev/null; then
    echo -e "${RED}gh CLI 인증이 필요합니다.${NC}"
    echo -e "${YELLOW}실행: gh auth login${NC}"
    exit 1
fi

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${CYAN}브랜치: ${CURRENT_BRANCH} → ${BASE_BRANCH}${NC}\n"

# main 브랜치에서 PR 생성 방지
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo -e "${RED}${CURRENT_BRANCH} 브랜치에서는 PR을 생성할 수 없습니다.${NC}"
    exit 1
fi

# ─────────────────────────────────────────────
# 1. 기존 PR 확인
# ─────────────────────────────────────────────
echo -e "${BLUE}[1/5] 기존 PR 확인${NC}"

EXISTING_PR=$(gh pr list --head "$CURRENT_BRANCH" --json number,url,state --jq '.[0]' 2>/dev/null || echo "")

if [ -n "$EXISTING_PR" ] && [ "$EXISTING_PR" != "null" ]; then
    PR_NUMBER=$(echo "$EXISTING_PR" | jq -r '.number')
    PR_URL=$(echo "$EXISTING_PR" | jq -r '.url')
    PR_STATE=$(echo "$EXISTING_PR" | jq -r '.state')

    echo -e "${YELLOW}이미 PR이 존재합니다: #${PR_NUMBER} (${PR_STATE})${NC}"
    echo -e "${CYAN}URL: ${PR_URL}${NC}"
    echo -e "\n${YELLOW}브라우저에서 열까요? [y/n]${NC}"
    read -r -p "> " open_choice

    if [ "$open_choice" = "y" ] || [ "$open_choice" = "Y" ]; then
        gh pr view --web
    fi
    exit 0
fi

echo -e "${GREEN}✓ 기존 PR 없음${NC}"

# ─────────────────────────────────────────────
# 2. push 상태 확인
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[2/5] Push 상태 확인${NC}"

UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")

if [ -z "$UPSTREAM" ]; then
    echo -e "${YELLOW}remote에 push되지 않았습니다.${NC}"
    echo -e "${YELLOW}먼저 push하시겠습니까? [y/n]${NC}"
    read -r -p "> " push_choice

    if [ "$push_choice" = "y" ] || [ "$push_choice" = "Y" ]; then
        git push -u origin "$CURRENT_BRANCH"
        echo -e "${GREEN}✓ Push 완료${NC}"
    else
        echo -e "${RED}PR 생성을 위해 push가 필요합니다.${NC}"
        exit 1
    fi
else
    # 로컬이 remote보다 앞서 있는지 확인
    UNPUSHED=$(git rev-list --count "${UPSTREAM}..HEAD" 2>/dev/null || echo "0")

    if [ "$UNPUSHED" -gt 0 ]; then
        echo -e "${YELLOW}push되지 않은 커밋이 ${UNPUSHED}개 있습니다.${NC}"
        echo -e "${YELLOW}push하시겠습니까? [y/n]${NC}"
        read -r -p "> " push_choice

        if [ "$push_choice" = "y" ] || [ "$push_choice" = "Y" ]; then
            git push origin "$CURRENT_BRANCH"
            echo -e "${GREEN}✓ Push 완료${NC}"
        fi
    else
        echo -e "${GREEN}✓ 최신 상태${NC}"
    fi
fi

# ─────────────────────────────────────────────
# 3. 변경사항 요약
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[3/5] 변경사항 요약${NC}"

# base 브랜치와의 diff
git fetch origin "$BASE_BRANCH" &>/dev/null || true

COMMIT_COUNT=$(git rev-list --count "origin/${BASE_BRANCH}..HEAD" 2>/dev/null || echo "0")
FILE_COUNT=$(git diff --name-only "origin/${BASE_BRANCH}..HEAD" 2>/dev/null | wc -l | tr -d ' ')

echo -e "${CYAN}커밋: ${COMMIT_COUNT}개${NC}"
echo -e "${CYAN}변경 파일: ${FILE_COUNT}개${NC}"

echo -e "\n${CYAN}커밋 목록:${NC}"
git log --oneline "origin/${BASE_BRANCH}..HEAD" 2>/dev/null | head -10 | while read -r line; do echo -e "  $line"; done

if [ "$COMMIT_COUNT" -gt 10 ]; then
    echo -e "  ${YELLOW}... 외 $((COMMIT_COUNT - 10))개${NC}"
fi

# ─────────────────────────────────────────────
# 4. PR 정보 입력
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[4/5] PR 정보 입력${NC}"

# 제목
if [ -z "$PR_TITLE" ]; then
    # 기본 제목: 첫 번째 커밋 메시지 또는 브랜치명
    DEFAULT_TITLE=$(git log --format=%s "origin/${BASE_BRANCH}..HEAD" 2>/dev/null | tail -1)
    if [ -z "$DEFAULT_TITLE" ]; then
        DEFAULT_TITLE="$CURRENT_BRANCH"
    fi

    echo -e "${YELLOW}PR 제목을 입력하세요 (기본: ${DEFAULT_TITLE}):${NC}"
    read -r -p "> " PR_TITLE

    if [ -z "$PR_TITLE" ]; then
        PR_TITLE="$DEFAULT_TITLE"
    fi
fi

echo -e "${GREEN}제목: ${PR_TITLE}${NC}"

# 본문
echo -e "\n${YELLOW}PR 본문을 입력하세요 (선택사항, 빈 줄로 종료):${NC}"
PR_BODY=""
while IFS= read -r -p "  " line; do
    [ -z "$line" ] && break
    PR_BODY="${PR_BODY}${line}\n"
done

# ─────────────────────────────────────────────
# 5. PR 생성
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[5/5] PR 생성${NC}"

# PR 생성 명령 구성
PR_CMD="gh pr create --base $BASE_BRANCH --title \"$PR_TITLE\""

if [ "$IS_DRAFT" = true ]; then
    PR_CMD="$PR_CMD --draft"
    echo -e "${YELLOW}Draft PR로 생성됩니다.${NC}"
fi

# 최종 확인
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}PR 정보:${NC}"
echo -e "  제목: ${GREEN}${PR_TITLE}${NC}"
echo -e "  브랜치: ${CYAN}${CURRENT_BRANCH} → ${BASE_BRANCH}${NC}"
if [ "$IS_DRAFT" = true ]; then
    echo -e "  상태: ${YELLOW}Draft${NC}"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

echo -e "\n${YELLOW}PR을 생성하시겠습니까? [y/n]${NC}"
read -r -p "> " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo -e "${YELLOW}취소되었습니다.${NC}"
    exit 0
fi

# PR 생성 실행
if [ -n "$PR_BODY" ]; then
    PR_URL=$(echo -e "$PR_BODY" | gh pr create --base "$BASE_BRANCH" --title "$PR_TITLE" --body-file - $( [ "$IS_DRAFT" = true ] && echo "--draft" ))
else
    PR_URL=$(gh pr create --base "$BASE_BRANCH" --title "$PR_TITLE" --body "" $( [ "$IS_DRAFT" = true ] && echo "--draft" ))
fi

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ PR 생성 완료!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  URL: ${CYAN}${PR_URL}${NC}"

# 브라우저에서 열기
echo -e "\n${YELLOW}브라우저에서 열까요? [y/n]${NC}"
read -r -p "> " open_choice

if [ "$open_choice" = "y" ] || [ "$open_choice" = "Y" ]; then
    gh pr view --web
fi
