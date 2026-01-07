#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "  ___  _ __   ___ _ __    ___  __ _ ___ ___  "
echo " / _ \| '_ \ / _ \ '_ \  / __|/ _\` / __/ __| "
echo "| (_) | |_) |  __/ | | | \__ \ (_| \__ \__ \ "
echo " \___/| .__/ \___|_| |_| |___/\__,_|___/___/ "
echo "      |_|                                    "
echo -e "${NC}"
echo ""

# Get project name
read -p "Project name (e.g., My SaaS): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo "Project name is required"
    exit 1
fi

# Generate slug from project name
DEFAULT_SLUG=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g' | sed 's/[^a-z0-9-]//g')
read -p "Project slug [$DEFAULT_SLUG]: " PROJECT_SLUG
PROJECT_SLUG=${PROJECT_SLUG:-$DEFAULT_SLUG}

echo ""
echo "Setting up $PROJECT_NAME..."
echo ""

# Replace placeholders
for file in package.json docker-compose.yml constants/index.ts; do
    if [ -f "$file" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$file"
            sed -i '' "s|{{PROJECT_SLUG}}|$PROJECT_SLUG|g" "$file"
        else
            sed -i "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$file"
            sed -i "s|{{PROJECT_SLUG}}|$PROJECT_SLUG|g" "$file"
        fi
    fi
done

# Copy .env.example to .env
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "Created .env from .env.example"
fi

# Install dependencies
echo "Installing dependencies..."
pnpm install

echo ""
echo -e "${GREEN}Done!${NC}"
echo ""
echo "Next steps:"
echo "  1. Edit .env and fill in your values:"
echo "     - Run: openssl rand -hex 32 (for BETTER_AUTH_SECRET)"
echo "     - Add your Stripe keys"
echo "  2. Run: make dev"
echo ""
