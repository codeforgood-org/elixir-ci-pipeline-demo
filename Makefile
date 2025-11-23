.PHONY: help setup test coverage clean docker-build docker-up docker-down lint format check deploy

# Default target
.DEFAULT_GOAL := help

## help: Display this help message
help:
	@echo "Task Manager - Available Commands"
	@echo "=================================="
	@grep -E '^## [a-zA-Z_-]+:.*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ": "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' | \
		sed 's/^## //'

## setup: Install dependencies and set up the project
setup:
	@echo "Installing Elixir dependencies..."
	mix local.hex --force
	mix local.rebar --force
	mix deps.get
	@echo "Installing Node.js dependencies..."
	cd assets && npm install
	@echo "Setting up database..."
	mix ecto.setup
	@echo "✓ Setup complete!"

## install: Install dependencies only
install:
	mix deps.get
	cd assets && npm install

## test: Run all tests
test:
	mix test

## test-watch: Run tests in watch mode
test-watch:
	mix test.watch

## coverage: Generate test coverage report
coverage:
	mix coveralls.html
	@echo "✓ Coverage report generated in cover/excoveralls.html"

## coverage-ci: Generate coverage report for CI
coverage-ci:
	mix coveralls.json

## lint: Run all linting checks
lint:
	@echo "Running Credo..."
	mix credo --strict
	@echo "Running Dialyzer..."
	mix dialyzer
	@echo "Running Sobelow..."
	mix sobelow --config
	@echo "✓ All lint checks passed!"

## format: Format code
format:
	mix format

## format-check: Check code formatting
format-check:
	mix format --check-formatted

## check: Run all quality checks (format, lint, test)
check: format-check lint test
	@echo "✓ All checks passed!"

## clean: Clean build artifacts
clean:
	mix clean
	rm -rf _build deps cover priv/plts

## db-setup: Set up the database
db-setup:
	mix ecto.setup

## db-reset: Reset the database
db-reset:
	mix ecto.reset

## db-migrate: Run database migrations
db-migrate:
	mix ecto.migrate

## db-rollback: Rollback last database migration
db-rollback:
	mix ecto.rollback

## db-seed: Seed the database
db-seed:
	mix run priv/repo/seeds.exs

## server: Start the Phoenix server
server:
	mix phx.server

## iex: Start IEx with the application
iex:
	iex -S mix phx.server

## console: Start IEx without the server
console:
	iex -S mix

## routes: Display all routes
routes:
	mix phx.routes

## docker-build: Build Docker image
docker-build:
	docker build -t task-manager:latest .

## docker-up: Start Docker containers
docker-up:
	docker-compose up -d

## docker-down: Stop Docker containers
docker-down:
	docker-compose down

## docker-logs: View Docker logs
docker-logs:
	docker-compose logs -f

## docker-restart: Restart Docker containers
docker-restart:
	docker-compose restart

## docker-clean: Remove Docker containers and volumes
docker-clean:
	docker-compose down -v

## release: Build a production release
release:
	MIX_ENV=prod mix do deps.get, compile, assets.deploy, release

## deploy: Deploy to production (customize as needed)
deploy: release
	@echo "Deploying to production..."
	@echo "Configure this target for your deployment platform"

## docs: Generate documentation
docs:
	mix docs
	@echo "✓ Documentation generated in doc/"

## deps-update: Update dependencies
deps-update:
	mix deps.update --all

## security: Run security checks
security:
	mix sobelow --config
	mix deps.audit

## benchmark: Run benchmarks (if available)
benchmark:
	@echo "No benchmarks configured yet"

## ci: Run CI pipeline locally
ci: format-check lint coverage
	@echo "✓ CI pipeline completed successfully!"

## plt: Build Dialyzer PLT
plt:
	mix dialyzer --plt

## shell: Open a shell in running container
shell:
	docker-compose exec web sh

## stats: Show project statistics
stats:
	@echo "=== Project Statistics ==="
	@echo "Lines of code:"
	@find lib -name "*.ex" -o -name "*.exs" | xargs wc -l | tail -1
	@echo "\nTest files:"
	@find test -name "*.exs" | wc -l
	@echo "\nDependencies:"
	@mix deps | grep -c "^*"
