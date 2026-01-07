.PHONY: dev setup db migrate build clean down help

help:
	@echo "Development Commands"
	@echo ""
	@echo "  dev        - Start development server (auto-setup included)"
	@echo "  setup      - Manual setup (database, schema, and dependencies)"
	@echo "  db         - Start PostgreSQL database only"
	@echo "  clean      - Clean build artifacts and stop services"
	@echo "  down       - Stop all services"
	@echo ""


generate:
	@echo "Generating types and client..."
	@pnpm run db:generate

db:
	@echo "Starting PostgreSQL database..."
	@docker-compose up -d postgres

setup: db
	@echo "Installing dependencies..."
	@pnpm install
	@echo "Setting up database schema..."
	@pnpm run db:push
	@echo "Setup complete!"

dev: setup
	@echo "Starting Next.js development server..."
	@pnpm dev

clean:
	@echo "Cleaning up..."
	@rm -rf .next node_modules
	@docker-compose down -v

down:
	@echo "Stopping all services..."
	@docker-compose down

stripe-listen:
	stripe listen --forward-to localhost:3000/api/stripe/webhook
