#!/bin/bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}"
echo "  ___  _ __   ___ _ __    ___  __ _ ___ ___  "
echo " / _ \| '_ \ / _ \ '_ \  / __|/ _\` / __/ __| "
echo "| (_) | |_) |  __/ | | | \__ \ (_| \__ \__ \ "
echo " \___/| .__/ \___|_| |_| |___/\__,_|___/___/ "
echo "      |_|                                    "
echo -e "${NC}"
echo "SaaS Template Setup"
echo "==================="
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

# Database name
DEFAULT_DB="${PROJECT_SLUG}db"
read -p "Database name [$DEFAULT_DB]: " DB_NAME
DB_NAME=${DB_NAME:-$DEFAULT_DB}

# GitHub username (for release workflow)
read -p "GitHub username: " GITHUB_USER

echo ""
echo -e "${YELLOW}Setting up your project...${NC}"
echo ""

# Generate auth secret (hex to avoid special chars)
AUTH_SECRET=$(openssl rand -hex 32)

# Replace placeholders in all files
echo "Replacing placeholders..."

# Files to process
FILES=(
    "package.json"
    "docker-compose.yml"
    ".env.example"
    "constants/index.ts"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$file"
            sed -i '' "s|{{PROJECT_SLUG}}|$PROJECT_SLUG|g" "$file"
            sed -i '' "s|{{DB_NAME}}|$DB_NAME|g" "$file"
            sed -i '' "s|{{GITHUB_USER}}|$GITHUB_USER|g" "$file"
        else
            sed -i "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" "$file"
            sed -i "s|{{PROJECT_SLUG}}|$PROJECT_SLUG|g" "$file"
            sed -i "s|{{DB_NAME}}|$DB_NAME|g" "$file"
            sed -i "s|{{GITHUB_USER}}|$GITHUB_USER|g" "$file"
        fi
    fi
done

# Create .env from .env.example
echo "Creating .env file..."
cp .env.example .env

# Update .env with generated secret and correct db name
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s|your-secret-key-here|$AUTH_SECRET|g" .env
    sed -i '' "s|{{PROJECT_SLUG}}db|$DB_NAME|g" .env
else
    sed -i "s|your-secret-key-here|$AUTH_SECRET|g" .env
    sed -i "s|{{PROJECT_SLUG}}db|$DB_NAME|g" .env
fi

# Initialize git if not already
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit from open-sass template"
fi

# Install dependencies
echo "Installing dependencies..."
pnpm install

echo ""
echo -e "${GREEN}Setup complete!${NC}"
echo ""
echo "Next steps:"
echo "  1. Update your Stripe keys in .env"
echo "  2. Update your Resend API key in .env (optional)"
echo "  3. Run 'make dev' to start developing"
echo ""
echo -e "${BLUE}Happy building!${NC}"
