#!/bin/bash
#
# git-push.sh
# 현재 브랜치를 remote에 push하는 스크립트
#
# 사용법:
#   ./scripts/git-push.sh           # 현재 브랜치 push
#   ./scripts/git-push.sh -f        # force push (주의)
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
FORCE_PUSH=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_PUSH=true
            shift
            ;;
        -h|--help)
            echo "사용법: ./scripts/git-push.sh [옵션]"
            echo ""
            echo "옵션:"
            echo "  -f, --force   force push (주의해서 사용)"
            echo "  -h, --help    도움말 표시"
            exit 0
            ;;
        *)
            echo -e "${RED}알 수 없는 옵션: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Git Push${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
echo -e "${CYAN}브랜치: ${CURRENT_BRANCH}${NC}\n"

# main 브랜치 직접 push 경고
if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
    echo -e "${YELLOW}⚠️  ${CURRENT_BRANCH} 브랜치에 직접 push하려고 합니다.${NC}"
    echo -e "${YELLOW}계속하시겠습니까? [y/n]${NC}"
    read -r -p "> " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${YELLOW}취소되었습니다.${NC}"
        exit 0
    fi
fi

# ─────────────────────────────────────────────
# 1. 커밋되지 않은 변경사항 확인
# ─────────────────────────────────────────────
echo -e "${BLUE}[1/4] 상태 확인${NC}"

if ! git diff --quiet || ! git diff --cached --quiet; then
    echo -e "${YELLOW}⚠️  커밋되지 않은 변경사항이 있습니다.${NC}"
    git status --short
    echo -e "\n${YELLOW}커밋하지 않고 push하시겠습니까? [y/n]${NC}"
    read -r -p "> " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo -e "${YELLOW}먼저 커밋하세요: ./scripts/git-commit.sh${NC}"
        exit 0
    fi
fi

# ─────────────────────────────────────────────
# 2. push할 커밋 확인
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[2/4] push할 커밋 확인${NC}"

# upstream 설정 여부 확인
UPSTREAM=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "")

if [ -z "$UPSTREAM" ]; then
    echo -e "${YELLOW}upstream이 설정되지 않았습니다. 첫 push입니다.${NC}"
    COMMITS_TO_PUSH=$(git log --oneline | head -5)
    COMMIT_COUNT=$(git rev-list --count HEAD)
else
    # push할 커밋 개수
    COMMIT_COUNT=$(git rev-list --count "${UPSTREAM}..HEAD" 2>/dev/null || echo "0")

    if [ "$COMMIT_COUNT" -eq 0 ]; then
        echo -e "${GREEN}✓ 이미 최신 상태입니다. push할 커밋이 없습니다.${NC}"
        exit 0
    fi

    COMMITS_TO_PUSH=$(git log --oneline "${UPSTREAM}..HEAD")
fi

echo -e "${CYAN}push할 커밋 (${COMMIT_COUNT}개):${NC}"
echo "$COMMITS_TO_PUSH" | head -10 | while read -r line; do echo -e "  $line"; done

if [ "$COMMIT_COUNT" -gt 10 ]; then
    echo -e "  ${YELLOW}... 외 $((COMMIT_COUNT - 10))개${NC}"
fi

# ─────────────────────────────────────────────
# 3. Lint 확인 (선택)
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[3/4] Lint 확인${NC}"

# 프로젝트 타입 감지 및 린터 설정
LINT_CMD=""
LINT_TYPE=""

if [ -f "package.json" ] && grep -q '"lint"' package.json; then
    LINT_TYPE="Node.js"
    LINT_CMD="npm run lint"
elif [ -f "pyproject.toml" ]; then
    LINT_TYPE="Python"
    if command -v ruff &> /dev/null; then
        LINT_CMD="ruff check ."
    elif command -v pylint &> /dev/null; then
        LINT_CMD="pylint **/*.py"
    elif command -v flake8 &> /dev/null; then
        LINT_CMD="flake8 ."
    fi
elif [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
    LINT_TYPE="Python"
    if command -v ruff &> /dev/null; then
        LINT_CMD="ruff check ."
    elif command -v pylint &> /dev/null; then
        LINT_CMD="pylint **/*.py"
    elif command -v flake8 &> /dev/null; then
        LINT_CMD="flake8 ."
    fi
elif [ -f "go.mod" ]; then
    LINT_TYPE="Go"
    LINT_CMD="go vet ./..."
elif [ -f "Cargo.toml" ]; then
    LINT_TYPE="Rust"
    LINT_CMD="cargo clippy -- -D warnings"
elif [ -f "build.gradle" ] || [ -f "pom.xml" ]; then
    LINT_TYPE="Java"
    if [ -f "build.gradle" ] && grep -q "checkstyle" build.gradle 2>/dev/null; then
        LINT_CMD="./gradlew checkstyleMain"
    elif [ -f "pom.xml" ]; then
        LINT_CMD="mvn checkstyle:check"
    fi
fi

if [ -n "$LINT_CMD" ]; then
    echo -e "${CYAN}감지된 프로젝트: ${LINT_TYPE}${NC}"
    echo -e "${CYAN}린터: ${LINT_CMD}${NC}"
    echo -e "${YELLOW}lint 검사를 실행하시겠습니까? [y/n]${NC}"
    read -r -p "> " lint_choice

    if [ "$lint_choice" = "y" ] || [ "$lint_choice" = "Y" ]; then
        echo -e "${GREEN}lint 실행 중...${NC}"
        if eval "$LINT_CMD"; then
            echo -e "${GREEN}✓ lint 통과${NC}"
        else
            echo -e "${RED}✗ lint 실패${NC}"
            echo -e "${YELLOW}lint 오류를 무시하고 push하시겠습니까? [y/n]${NC}"
            read -r -p "> " ignore_lint
            if [ "$ignore_lint" != "y" ] && [ "$ignore_lint" != "Y" ]; then
                exit 1
            fi
        fi
    else
        echo -e "${YELLOW}lint 검사 건너뜀${NC}"
    fi
else
    echo -e "${YELLOW}지원되는 린터를 찾을 수 없음, 건너뜀${NC}"
fi

# ─────────────────────────────────────────────
# 4. Push 실행
# ─────────────────────────────────────────────
echo -e "\n${BLUE}[4/4] Push 실행${NC}"

if [ "$FORCE_PUSH" = true ]; then
    echo -e "${RED}⚠️  Force push를 실행합니다!${NC}"
    echo -e "${YELLOW}정말 진행하시겠습니까? [yes 입력]${NC}"
    read -r -p "> " confirm
    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}취소되었습니다.${NC}"
        exit 0
    fi
    git push --force-with-lease origin "$CURRENT_BRANCH"
else
    if [ -z "$UPSTREAM" ]; then
        # 첫 push - upstream 설정
        echo -e "${GREEN}upstream 설정과 함께 push...${NC}"
        git push -u origin "$CURRENT_BRANCH"
    else
        git push origin "$CURRENT_BRANCH"
    fi
fi

echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Push 완료!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  브랜치: ${CYAN}${CURRENT_BRANCH}${NC}"
echo -e "  커밋 수: ${CYAN}${COMMIT_COUNT}개${NC}"

# PR 생성 안내
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo -e "\n${YELLOW}PR을 생성하려면: ./scripts/git-pr.sh${NC}"
fi
