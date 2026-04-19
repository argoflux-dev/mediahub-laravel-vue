# Quick Start

This guide gets MediaHub running locally in development mode.

## Prerequisites

- **Docker** 28+ with the Compose plugin (`docker compose version`)
- **Git**
- **Make**

No local PHP, Node.js, or database installation required — everything runs in containers.

---

## 1. Clone the repository

```bash
git clone https://github.com/argoflux-dev/store-laravel-react.git
cd mediahub-laravel-vue
```

---

## 2. Launch installation

```bash
make inatall
```
This command:
1. Stops & cleans docker containers (if exists)
2. Creates .env.dev & .env.prod from .env.dev.example & .env.prod.example, and creates symlink .env -> .env.prod in repo dir
3. Builds & Starts `api`, `nginx`, `postgres`, `redis`, and `app` (Vite) containers
4. Installs composer packages in `backend` dir and syncs env variable from repo into `backend` dir
5. Sets permissions to needed dirs in `laravel` project dir
6. Generates the `laravel` application key & makes storage link
7. Installs npm dependencies
8. Syncs env variables to the frontend `.env` files via `scripts/sync-env.sh`
9. Starts the Vite dev server inside the `app` container

Wait ~10 seconds for all services to become healthy.

---

## 3. Open the application in dev mode

| URL | Description |
|---|---|
| `http://localhost:5174` | Vite dev server (direct) |
| `http://localhost:8082` | Laravel API |

---

# Production build

## 1. Set application key and real passwords & domain names

Open `.env.prod` and set the required values instead of placeholders:

```
APP_KEY=                      # make key-generate
APP_URL=https://api.{your_domain}
FRONTEND_URL=https://{your_domain}
DB_PASSWORD={your_password}
REDIS_PASSWORD={your_password}
VITE_API_BASE_URL=https://api.{your_domain}
```

## 2. Restart Docker containers in production mode

```bash
make down
make fbuild
make up
```

## Useful development commands

```bash
make logs-api            # Stream Laravel / PHP-FPM logs
make logs-app            # Stream Vite logs
make shell               # Open shell inside the API container
make shell-app           # Open shell inside the Node container
make migrate             # Run new migrations
make migrate-fresh-seed  # Drop all tables and re-seed (⚠ destroys data)
make cache-clear         # Clear all Laravel caches
make tinker              # Open Laravel Tinker REPL
make down                # Stop all containers
```

Run `make help` to see the full list of available commands.

---

## Troubleshooting

**Containers won't start** — check for port conflicts on 8081, 8082, 5174, 5433. Change the host-side ports in `docker-compose.dev.yml` if needed.

**500 errors from API** — run `make logs-api` and inspect `backend/storage/logs/laravel.log`. The most common causes are a missing `APP_KEY` or a failed database connection.

**Frontend changes not reflected** — confirm the Vite dev server is running with `make logs-app`. If the `app` container stopped, restart it with `make start-vite`.

**Permission errors on storage** — run `make permissions` to restore correct ownership inside the container.
