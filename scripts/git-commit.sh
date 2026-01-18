#!/bin/bash
#
# git-commit.sh
# 변경사항을 확인하고 대화형으로 커밋하는 스크립트
#
# 사용법:
#   ./scripts/git-commit.sh              # 대화형 커밋
#   ./scripts/git-commit.sh -m "메시지"  # 직접 메시지 지정
#   ./scripts/git-commit.sh --all        # 모든 변경사항 자동 staging
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
AUTO_STAGE=false
DIRECT_MESSAGE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--message)
            DIRECT_MESSAGE="$2"
            shift 2
            ;;
        -a|--all)
            AUTO_STAGE=true
            shift
            ;;
        -h|--help)
            echo "사용법: ./scripts/git-commit.sh [옵션]"
            echo ""
            echo "옵션:"
            echo "  -m, --message \"메시지\"  커밋 메시지 직접 지정"
            echo "  -a, --all               모든 변경사항 자동 staging"
            echo "  -h, --help              도움말 표시"
            exit 0
            ;;
        *)
            echo -e "${RED}알 수 없는 옵션: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Git Commit Helper${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 현재 브런치 표시
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${CYAN}브런치: ${CURRENT_BRANCH}${NC}\n"

# ─────────────────────────────────────────────
# 1. 변경사항 확인
# ─────────────────────────────────────────────
echo -e "${BLUE}[1/4] 변경사항 확인${NC}"

# staged, unstaged, untracked 확인
STAGED=$(git diff --cached --name-only)
UNSTAGED=$(git diff --name-only)
UNTRACKED=$(git ls-files --others --exclude-standard)

if [ -z "$STAGED" ] && [ -z "$UNSTAGED" ] && [ -z "$UNTRACKED" ]; then
    echo -e "${YELLOW}커밋할 변경사항이 없습니다.${NC}"
    exit 0
fi

# 상태 요약 표시
echo -e "${GREEN}Staged:${NC}"
if [ -n "$STAGED" ]; then
    echo "$STAGED" | while read -r file; do echo -e "  ${GREEN}✓ $file${NC}"; done
else
    echo -e "  ${YELLOW}(없음)${NC}"
fi

echo -e "\n${YELLOW}Unstaged:${NC}"
if [ -n "$UNSTAGED" ]; then
    echo "$UNSTAGED" | while read -r file; do echo -e "  ${YELLOW}M $file${NC}"; done
else
    echo -e "  ${YELLOW}(없음)${NC}"
fi

echo -e "\n${RED}Untracked:${NC}"
if [ -n "$UNTRACKED" ]; then
    echo "$UNTRACKED" | while read -r file; do echo -e "  ${RED}? $file${NC}"; done
else
    echo -e "  ${YELLOW}(없음)${NC}"
fi

# ─────────────────────────────────────────────
# 2. 변경 내용 미리보기
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[2/4] 변경 내용 요약${NC}"
git diff --stat 2>/dev/null || true
git diff --cached --stat 2>/dev/null || true

# ─────────────────────────────────────────────
# 3. Staging
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[3/4] Staging${NC}"

if [ -z "$STAGED" ]; then
    if [ "$AUTO_STAGE" = true ]; then
        echo -e "${GREEN}모든 변경사항을 staging합니다...${NC}"
        git add -A
    else
        echo -e "${YELLOW}Staged 파일이 없습니다.${NC}"
        echo -e "선택: [a] 모두 추가  [s] 선택적 추가  [q] 취소"
        read -r -p "> " choice

        case $choice in
            a|A)
                git add -A
                echo -e "${GREEN}✓ 모든 변경사항이 staged 되었습니다.${NC}"
                ;;
            s|S)
                git add -i
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
else
    echo -e "${GREEN}✓ 이미 staged된 파일이 있습니다.${NC}"

    if [ -n "$UNSTAGED" ] || [ -n "$UNTRACKED" ]; then
        echo -e "${YELLOW}추가로 staging할 파일이 있습니다.${NC}"
        echo -e "선택: [y] 나머지도 추가  [n] 현재 상태로 진행  [q] 취소"
        read -r -p "> " choice

        case $choice in
            y|Y)
                git add -A
                echo -e "${GREEN}✓ 모든 변경사항이 staged 되었습니다.${NC}"
                ;;
            n|N)
                echo -e "${GREEN}현재 staged 파일만 커밋합니다.${NC}"
                ;;
            q|Q)
                echo -e "${YELLOW}취소되었습니다.${NC}"
                exit 0
                ;;
        esac
    fi
fi

# staged 파일 재확인
FINAL_STAGED=$(git diff --cached --name-only)
if [ -z "$FINAL_STAGED" ]; then
    echo -e "${YELLOW}staging된 파일이 없습니다. 커밋을 중단합니다.${NC}"
    exit 0
fi

# ─────────────────────────────────────────────
# 4. 커밋
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[4/4] 커밋${NC}"

# 최근 커밋 스타일 참고용 표시
echo -e "${CYAN}최근 커밋 메시지 (참고용):${NC}"
git log --oneline -5 | while read -r line; do echo -e "  $line"; done

echo -e "\n${CYAN}커밋 메시지 규칙:${NC}"
echo -e "  - 한글 사용"
echo -e "  - 첫 줄: 변경 요약 (50자 이내)"
echo -e "  - 본문: 주요 변경 내용 (선택사항)"

# 커밋 메시지 입력
if [ -n "$DIRECT_MESSAGE" ]; then
    COMMIT_MSG="$DIRECT_MESSAGE"
    echo -e "\n${GREEN}커밋 메시지: ${COMMIT_MSG}${NC}"
else
    echo -e "\n${YELLOW}커밋 메시지를 입력하세요 (빈 줄 입력시 종료):${NC}"
    read -r -p "제목: " TITLE

    if [ -z "$TITLE" ]; then
        echo -e "${RED}커밋 메시지가 비어있습니다. 취소합니다.${NC}"
        exit 1
    fi

    # 50자 경고
    if [ ${#TITLE} -gt 50 ]; then
        echo -e "${YELLOW}⚠️  제목이 50자를 초과합니다 (${#TITLE}자)${NC}"
    fi

    echo -e "${YELLOW}본문을 입력하세요 (선택사항, 빈 줄로 종료):${NC}"
    BODY=""
    while IFS= read -r -p "  " line; do
        [ -z "$line" ] && break
        BODY="${BODY}${line}\n"
    done

    if [ -n "$BODY" ]; then
        COMMIT_MSG="${TITLE}\n\n${BODY}"
    else
        COMMIT_MSG="$TITLE"
    fi
fi

# 최종 확인
echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}커밋 대상 파일:${NC}"
echo "$FINAL_STAGED" | while read -r file; do echo -e "  ${GREEN}$file${NC}"; done
echo -e "\n${CYAN}커밋 메시지:${NC}"
echo -e "$COMMIT_MSG" | while read -r line; do echo -e "  $line"; done
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ -z "$DIRECT_MESSAGE" ]; then
    echo -e "\n${YELLOW}커밋하시겠습니까? [y/n]${NC}"
    read -r -p "> " confirm

    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${YELLOW}취소되었습니다.${NC}"
        exit 0
    fi
fi

# 커밋 실행
echo -e "$COMMIT_MSG" | git commit -F -

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ 커밋 완료!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 최종 상태
git log --oneline -1
