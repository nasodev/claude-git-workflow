#!/bin/bash
#
# git-branch.sh
# 새 브랜치를 생성하고 전환하는 스크립트
#
# 사용법:
#   ./scripts/git-branch.sh                    # 대화형 브랜치 생성
#   ./scripts/git-branch.sh feature/login      # 브랜치명 직접 지정
#   ./scripts/git-branch.sh -f main            # 특정 브랜치 기준으로 생성
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
FROM_BRANCH=""
BRANCH_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--from)
            FROM_BRANCH="$2"
            shift 2
            ;;
        -h|--help)
            echo "사용법: ./scripts/git-branch.sh [옵션] [브랜치명]"
            echo ""
            echo "옵션:"
            echo "  -f, --from <브랜치>  기준 브랜치 지정 (기본: 현재 브랜치)"
            echo "  -h, --help           도움말 표시"
            echo ""
            echo "예시:"
            echo "  ./scripts/git-branch.sh feature/new-post"
            echo "  ./scripts/git-branch.sh -f main feature/login"
            echo "  ./scripts/git-branch.sh draft"
            exit 0
            ;;
        -*)
            echo -e "${RED}알 수 없는 옵션: $1${NC}"
            exit 1
            ;;
        *)
            BRANCH_NAME="$1"
            shift
            ;;
    esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Git Branch Creator${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 현재 브랜치
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${CYAN}현재 브랜치: ${CURRENT_BRANCH}${NC}\n"

# ─────────────────────────────────────────────
# 1. 변경사항 확인
# ─────────────────────────────────────────────
STASHED=false

if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️  커밋되지 않은 변경사항이 있습니다.${NC}"
    git status --short
    echo ""
    echo -e "선택: [s] stash 후 진행  [c] 그대로 진행  [q] 취소"
    read -r -p "> " choice

    case $choice in
        s|S)
            git stash push -u -m "git-branch: auto-stash from $CURRENT_BRANCH"
            STASHED=true
            echo -e "${GREEN}✓ 변경사항이 stash 되었습니다.${NC}\n"
            ;;
        c|C)
            echo -e "${YELLOW}변경사항을 유지한 채 진행합니다.${NC}\n"
            ;;
        q|Q)
            echo -e "${YELLOW}취소되었습니다.${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}잘못된 선택입니다.${NC}"
            exit 1
            ;;
    esac
fi

# ─────────────────────────────────────────────
# 2. 기준 브랜치 설정
# ─────────────────────────────────────────────
if [ -z "$FROM_BRANCH" ]; then
    FROM_BRANCH="$CURRENT_BRANCH"
fi

# 기준 브랜치 존재 확인
if ! git rev-parse --verify "$FROM_BRANCH" &>/dev/null; then
    echo -e "${RED}브랜치가 존재하지 않습니다: $FROM_BRANCH${NC}"
    exit 1
fi

echo -e "${BLUE}[1/3] 기준 브랜치: ${FROM_BRANCH}${NC}"

# main/master 기준이면 최신화 제안
if [ "$FROM_BRANCH" = "main" ] || [ "$FROM_BRANCH" = "master" ]; then
    echo -e "${YELLOW}remote에서 ${FROM_BRANCH} 최신화하시겠습니까? [y/n]${NC}"
    read -r -p "> " sync_choice

    if [ "$sync_choice" = "y" ] || [ "$sync_choice" = "Y" ]; then
        echo -e "${GREEN}${FROM_BRANCH} 최신화 중...${NC}"
        git fetch origin "$FROM_BRANCH"

        if [ "$CURRENT_BRANCH" = "$FROM_BRANCH" ]; then
            git pull origin "$FROM_BRANCH"
        fi
        echo -e "${GREEN}✓ 최신화 완료${NC}\n"
    fi
fi

# ─────────────────────────────────────────────
# 3. 브랜치명 입력
# ─────────────────────────────────────────────
echo -e "${BLUE}[2/3] 브랜치 생성${NC}"

# 기존 브랜치 목록 표시
echo -e "${CYAN}기존 브랜치:${NC}"
git branch --list | head -10 | while read -r line; do echo -e "  $line"; done
BRANCH_COUNT=$(git branch --list | wc -l | tr -d ' ')
if [ "$BRANCH_COUNT" -gt 10 ]; then
    echo -e "  ${YELLOW}... 외 $((BRANCH_COUNT - 10))개${NC}"
fi

if [ -z "$BRANCH_NAME" ]; then
    echo -e "\n${CYAN}브랜치 네이밍 규칙:${NC}"
    echo -e "  feature/<기능명>  - 새 기능"
    echo -e "  fix/<버그명>      - 버그 수정"
    echo -e "  draft             - 임시 작업"
    echo -e "  post/<글제목>     - 블로그 포스트"

    echo -e "\n${YELLOW}새 브랜치명을 입력하세요:${NC}"
    read -r -p "> " BRANCH_NAME
fi

if [ -z "$BRANCH_NAME" ]; then
    echo -e "${RED}브랜치명이 비어있습니다.${NC}"
    exit 1
fi

# 브랜치명 유효성 검사
if ! git check-ref-format --branch "$BRANCH_NAME" &>/dev/null; then
    echo -e "${RED}유효하지 않은 브랜치명입니다: $BRANCH_NAME${NC}"
    exit 1
fi

# 브랜치 중복 확인
if git rev-parse --verify "$BRANCH_NAME" &>/dev/null; then
    echo -e "${RED}이미 존재하는 브랜치입니다: $BRANCH_NAME${NC}"
    echo -e "${YELLOW}해당 브랜치로 전환하시겠습니까? [y/n]${NC}"
    read -r -p "> " switch_choice

    if [ "$switch_choice" = "y" ] || [ "$switch_choice" = "Y" ]; then
        git checkout "$BRANCH_NAME"
        echo -e "${GREEN}✓ ${BRANCH_NAME} 브랜치로 전환되었습니다.${NC}"

        if [ "$STASHED" = true ]; then
            echo -e "${YELLOW}stash 복원 중...${NC}"
            git stash pop
        fi
        exit 0
    else
        exit 1
    fi
fi

# ─────────────────────────────────────────────
# 4. 브랜치 생성 및 전환
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[3/3] 브랜치 생성 및 전환${NC}"

# 기준 브랜치에서 새 브랜치 생성
git checkout -b "$BRANCH_NAME" "$FROM_BRANCH"

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ 브랜치 생성 완료!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  기준: ${CYAN}${FROM_BRANCH}${NC}"
echo -e "  생성: ${GREEN}${BRANCH_NAME}${NC}"

# stash 복원
if [ "$STASHED" = true ]; then
    echo -e "\n${YELLOW}stash 복원 중...${NC}"
    if git stash pop; then
        echo -e "${GREEN}✓ 변경사항이 복원되었습니다.${NC}"
    else
        echo -e "${RED}stash 복원 중 충돌 발생. 수동 해결 필요: git stash pop${NC}"
    fi
fi
