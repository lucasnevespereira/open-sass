#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo "Usage: pnpm run release <patch|minor|major> [--retry]"
    echo ""
    echo "This will:"
    echo "1. Create a git tag based on current version"
    echo "2. Push the tag to trigger GitHub Actions"
    echo "3. GitHub Actions will create release and update version.ts"
    echo ""
    echo "Options:"
    echo "  --retry    Force retry by deleting existing remote tag and GitHub release"
    echo ""
    echo "Examples:"
    echo "  pnpm run release patch        # 0.1.0 -> 0.1.1"
    echo "  pnpm run release minor        # 0.1.0 -> 0.2.0"
    echo "  pnpm run release major        # 0.1.0 -> 1.0.0"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

TYPE=$1
RETRY=false

for arg in "$@"; do
    case $arg in
        --retry)
            RETRY=true
            shift
            ;;
        *)
            ;;
    esac
done

if [[ ! "$TYPE" =~ ^(patch|minor|major)$ ]]; then
    echo -e "${RED}Invalid release type: $TYPE${NC}"
    usage
fi

CURRENT_VERSION=$(node -p "require('./package.json').version")

IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

case $TYPE in
    major)
        NEW_VERSION="$((MAJOR + 1)).0.0"
        ;;
    minor)
        NEW_VERSION="$MAJOR.$((MINOR + 1)).0"
        ;;
    patch)
        NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))"
        ;;
esac

echo "Current version: $CURRENT_VERSION"
echo "New version: $NEW_VERSION"
echo ""

echo -e "${BLUE}Checking git status...${NC}"
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}Git working directory is not clean. Please commit or stash your changes.${NC}"
    exit 1
fi

echo -e "${BLUE}Creating and pushing git tag...${NC}"

if git tag -l | grep -q "^v$NEW_VERSION$"; then
    echo -e "${YELLOW}Tag v$NEW_VERSION already exists locally. Deleting it...${NC}"
    git tag -d "v$NEW_VERSION"
fi

if git ls-remote --tags origin | grep -q "refs/tags/v$NEW_VERSION$"; then
    if [ "$RETRY" = true ]; then
        echo -e "${YELLOW}Tag v$NEW_VERSION exists on remote. Deleting for retry...${NC}"
        git push --delete origin "v$NEW_VERSION"
        echo -e "${YELLOW}Attempting to delete GitHub release...${NC}"
        gh release delete "v$NEW_VERSION" --yes 2>/dev/null || echo -e "${YELLOW}(No GitHub release found or gh CLI not available)${NC}"
    else
        echo -e "${RED}Tag v$NEW_VERSION already exists on remote!${NC}"
        echo -e "${YELLOW}If you want to retry this release, use:${NC}"
        echo "   pnpm run release $TYPE --retry"
        exit 1
    fi
fi

git tag -a "v$NEW_VERSION" -m "Release v$NEW_VERSION"
git push origin "v$NEW_VERSION"

echo -e "${GREEN}Tag pushed successfully!${NC}"
echo ""
echo -e "${YELLOW}GitHub Actions will now:${NC}"
echo "   1. Run lint and build"
echo "   2. Create GitHub release"
echo "   3. Update lib/version.ts"
echo "   4. Commit version update to main"
