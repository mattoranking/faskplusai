BACKEND_DIR := apps/backend

.PHONY: help setup dev down \
	backend-fmt backend-lint backend-typecheck \
	backend-test backend-test-cov backend-test-ci \
	backend-dev backend-clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# --- Infrastructure ---

setup: ## Set up local dev environment (hosts, certs)
	@echo "🔧 Adding api.faskplusai.dev to /etc/hosts if missing..."
	@grep -q "api.faskplusai.dev" /etc/hosts || echo "127.0.0.1 api.faskplusai.dev" | sudo tee -a /etc/hosts
	@echo "🔧 Adding faskplusai.dev to /etc/hosts if missing..."
	@grep -q " faskplusai.dev" /etc/hosts || echo "127.0.0.1 faskplusai.dev" | sudo tee -a /etc/hosts
	@echo "🔧 Generating mkcert certificate for api.faskplusai.dev..."
	@mkcert -cert-file traefik/certs/api.faskplusai.dev.pem -key-file traefik/certs/api.faskplusai.dev-key.pem api.faskplusai.dev
	@echo "🔧 Generating mkcert certificate for faskplusai.dev..."
	@mkcert -cert-file traefik/certs/faskplusai.dev.pem -key-file traefik/certs/faskplusai.dev-key.pem faskplusai.dev
	@echo "✅ Setup complete"

dev: ## Start all services via docker compose
	docker compose up --build

down: ## Stop all services
	docker compose down

# --- Backend: Code Quality ---

backend-fmt: ## Format backend code with ruff
	cd $(BACKEND_DIR) && uv run ruff format .
	cd $(BACKEND_DIR) && uv run ruff check --fix .

backend-lint: ## Lint backend code (no auto-fix)
	cd $(BACKEND_DIR) && uv run ruff format --check .
	cd $(BACKEND_DIR) && uv run ruff check .

backend-typecheck: ## Run mypy on backend
	cd $(BACKEND_DIR) && uv run mypy faskplusai/

# --- Backend: Tests ---

backend-db-up: ## Start test database
	docker compose up -d db-test
	@echo "Waiting for test database..."
	@until docker compose exec db-test pg_isready -U faskplusai > /dev/null 2>&1; do sleep 0.5; done
	@echo "Test database ready"

backend-db-down: ## Stop test database
	docker compose down db-test

backend-test: backend-db-up ## Run backend tests
	cd $(BACKEND_DIR) && env $$(cat .env.testing | xargs) uv run pytest -v

backend-test-cov: backend-db-up ## Run backend tests with coverage
	cd $(BACKEND_DIR) && env $$(cat .env.testing | xargs) uv run pytest -v --cov=faskplusai --cov-report=term-missing --cov-report=html

backend-test-ci: backend-lint backend-typecheck backend-test-cov ## Run full backend CI locally

# --- Backend: Development ---

backend-dev: ## Start backend dev server (uvicorn with reload)
	cd $(BACKEND_DIR) && uv run uvicorn faskplusai.main:app --reload --host 0.0.0.0 --port 8000

backend-clean: ## Remove backend build artifacts
	cd $(BACKEND_DIR) && rm -rf .pytest_cache .mypy_cache .ruff_cache htmlcov .coverage coverage.xml
	cd $(BACKEND_DIR) && find . -type d -name __pycache__ -exec rm -rf {} +
