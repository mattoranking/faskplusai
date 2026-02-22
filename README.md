# Starter App

A full-stack monorepo starter kit built with **NestJS** (frontend) and **FastAPI** (backend). Pre-configured with Turborepo, Docker, PostgreSQL, Tailwind CSS, and AI tooling — clone and start building.

---

## What's Included

| Layer | Technology | Details |
|-------|-----------|---------|
| **Frontend** | NestJS 11 + Handlebars + Tailwind CSS | Server-rendered views with WebSocket support |
| **Backend** | FastAPI + SQLAlchemy + Alembic | Async Python API with auto-generated docs |
| **AI** | Google Gemini + MCP | Chat interface with Model Context Protocol servers |
| **Database** | PostgreSQL 15 | Managed via Alembic migrations |
| **Monorepo** | Turborepo + pnpm 8 | Parallel builds, caching, shared packages |
| **Infra** | Docker Compose | One-command dev environment |

---

## Prerequisites

- **Node.js** >= 20
- **pnpm** >= 8
- **Python** >= 3.13
- **uv** (Python package manager)
- **Docker & Docker Compose** (optional, for containerised dev)

---

## Quick Start

### 1. Clone & install

```bash
git clone <your-repo-url> my-app
cd my-app

# Node dependencies
pnpm install

# Python dependencies
cd apps/backend && uv sync && cd ../..
```

### 2. Configure environment

```bash
cp .env.example .env
# Edit .env with your database credentials, API keys, etc.
```

### 3. Run (choose one)

**Option A — Turborepo (recommended for development)**

```bash
# Both frontend and backend in parallel
pnpm start

# Or individually
pnpm start:frontend   # http://localhost:3000
pnpm start:backend    # http://localhost:8000
```

**Option B — Docker Compose**

```bash
docker-compose up      # Starts PostgreSQL + backend + frontend
docker-compose up -d   # Detached mode
docker-compose down    # Stop and remove containers
```

Each app has its own multi-stage Dockerfile:

- **Frontend** (`apps/frontend/Dockerfile`) — Builds on `node:20-alpine`, compiles Tailwind CSS, bundles the NestJS app, and includes a health check on `/health`.
- **Backend** (`apps/backend/Dockerfile`) — Builds on `python:3.11-slim`, installs dependencies with `uv`, and includes a health check on `/health`.

The `docker-compose.yml` orchestrates three services: **PostgreSQL 15**, **backend** (port 8000), and **frontend** (port 3000), with hot-reload via bind-mounted source directories.

---

## Project Structure

```
├── apps/
│   ├── frontend/              # NestJS application
│   │   ├── Dockerfile         # Multi-stage Docker build
│   │   ├── src/
│   │   │   ├── modules/       # Feature modules (chat, clients, …)
│   │   │   ├── styles/        # Tailwind CSS
│   │   │   └── main.ts        # App entry point
│   │   ├── views/             # Handlebars templates
│   │   └── public/            # Static assets (CSS/JS)
│   │
│   └── backend/               # FastAPI application
│       ├── Dockerfile         # Multi-stage Docker build
│       ├── app/
│       │   ├── api/           # Route handlers
│       │   ├── models/        # SQLAlchemy models
│       │   ├── services/      # Business logic
│       │   ├── chat/          # AI chat module
│       │   ├── core/          # Config, security, deps
│       │   └── main.py        # App entry point
│       ├── alembic/           # Database migrations
│       ├── mcp_servers/       # MCP server definitions
│       └── tests/             # Pytest test suite
│
├── packages/                  # Shared packages (add your own)
├── docker-compose.yml         # Container orchestration
├── turbo.json                 # Turborepo pipeline config
└── pnpm-workspace.yaml        # pnpm workspace definition
```

---

## Development URLs

| Service | URL |
|---------|-----|
| Frontend | [http://localhost:3000](http://localhost:3000) |
| Backend API | [http://localhost:8000](http://localhost:8000) |
| API Docs (Swagger) | [http://localhost:8000/docs](http://localhost:8000/docs) |
| API Docs (ReDoc) | [http://localhost:8000/redoc](http://localhost:8000/redoc) |

---

## Common Commands

```bash
pnpm dev              # Start all services in dev mode
pnpm build            # Build all apps
pnpm lint             # Lint all apps
pnpm test             # Run all tests
pnpm format           # Format code with Prettier

# Backend only
cd apps/backend
uv run pytest                          # Run tests
uv run alembic upgrade head            # Apply migrations
uv run alembic revision --autogenerate -m "description"  # Create migration

# Frontend only
cd apps/frontend
pnpm test              # Unit tests
pnpm test:e2e          # End-to-end tests
```

---

## Customising This Starter

1. **Rename the project** — update `name` in the root [package.json](package.json) and [pyproject.toml](apps/backend/pyproject.toml)
2. **Add shared packages** — create a new folder under `packages/` and reference it in [pnpm-workspace.yaml](pnpm-workspace.yaml)
3. **Add backend routes** — create modules under `apps/backend/app/api/`
4. **Add frontend features** — generate NestJS modules with `nest g module modules/<name>` inside `apps/frontend/`
5. **Configure AI** — set your Gemini API key in `.env` and customise MCP servers in `apps/backend/mcp_servers/`

---

## License

MIT
