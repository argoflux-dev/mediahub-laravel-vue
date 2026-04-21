# Architecture

This document describes the technical design of MediaHub: its services, data flow, authentication model, and Docker environment strategy.

## Overview

MediaHub follows a **decoupled fullstack architecture**: a Vue 3 SPA communicates with a Laravel REST API over HTTP. The two applications are independently served by Nginx and share no server-side rendering concerns.

```
Browser
  │
  ▼
Nginx (port 80 / 8080)
  ├──► Vue SPA (frontend dist or Vite dev server)
  └──► Laravel API via PHP-FPM (port 9000)
          ├──► PostgreSQL
          └──► Redis
```

---

## Docker Environment Strategy

The project uses a **composition-based** Docker setup rather than the override mechanism:

- `docker-compose.yml` — defines the **production** baseline: `api`, `nginx`, `postgres`, `redis`
- `docker-compose.dev.yml` — **extends** the baseline for local development, adding the `app` service (Vite dev server) and adjusting volumes, ports, and Nginx config

This is intentional: it prevents the dev layer from accidentally being loaded on a production server. Dev mode must be started explicitly with both files - implementation of the paradigm "Production first"

```bash
# Dev (explicit composition)
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Prod (baseline only)
docker compose -f docker-compose.yml up -d
```

The `Makefile` aliases these as `make dup` (dev) and `make up` (prod).

### Services

| Service | Image / Build | Purpose | Dev | Prod |
|---|---|---|---|---|
| `api` | Custom PHP 8.4-FPM | Laravel application | ✅ | ✅ |
| `app` | Custom Node 22 | Vite dev server + HMR | ✅ | ❌ |
| `nginx` | Custom Nginx Alpine | Reverse proxy / static files | ✅ | ✅ |
| `postgres` | `postgres:16-alpine` | Relational database | ✅ | ✅ |
| `redis` | `redis:7-alpine` | Cache and queue backend | ✅ | ✅ |

In production, the frontend is served from the pre-built `frontend/dist/` directory mounted into Nginx. In development, Nginx proxies to the Vite dev server (`app:5174`) with WebSocket support for HMR.

---

## Backend (Laravel)

**Entry point:** `backend/public/index.php`

### Directory layout

```
backend/
├── app/
│   ├── Http/Controllers/
│   │   ├── Auth/               # Breeze auth controllers
│   │   └── ImageController.php
│   ├── Http/Middleware/
│   │   └── EnsureEmailIsVerified.php
│   ├── Models/
│   │   ├── User.php
│   │   └── Image.php
│   └── Providers/AppServiceProvider.php
├── routes/
│   ├── api.php                 # API routes
│   ├── auth.php                # Auth routes
│   └── web.php
└── database/
    └── migrations/             # Schema definitions
```

### API Routes

All API routes are prefixed with `/api`.

| Method | Path | Auth | Description |
|---|---|---|---|
| `GET` | `/api/images` | Public | List all images |
| `POST` | `/api/images` | Required | Upload an image |
| `DELETE` | `/api/images/{id}` | Required | Delete an image |
| `POST` | `/api/logout` | Required | Invalidate token |
| `GET` | `/api/user` | Required | Get current user |
| `POST` | `/login` | Guest | Authenticate |
| `POST` | `/register` | Guest | Create account |
| `POST` | `/forgot-password` | Guest | Send reset link |
| `POST` | `/reset-password` | Guest | Reset password |

### Authentication Model

Authentication is implemented using Laravel Sanctum personal access tokens (stateless mode), rather than the stateful SPA cookie-based authentication.

**Login flow:**
1. Client `POST /login` with email + password
2. Laravel validates credentials, creates a `personal_access_token` record
3. Returns `{ user, token }` — token stored in browser `localStorage`
4. Subsequent requests include `Authorization: Bearer {token}` header
5. Logout deletes the current access token from the database

CSRF validation is disabled for auth and API routes since stateless tokens are used (`backend/bootstrap/app.php`).

### Image Storage

Images are stored on the `public` disk (`backend/storage/app/public/images/`), exposed via a symlink at `backend/public/storage`. The `ImageController` stores the path in the `images` table and returns the full public URL using `Storage::url()`.

**Database schema — `images` table:**

```
id          bigint PK
path        varchar(2000)
label       varchar(255) nullable
created_at  timestamp
updated_at  timestamp
```

---

## Frontend (Vue 3)

**Entry point:** `frontend/src/main.js`

### Directory layout

```
frontend/src/
├── components/
│   ├── DefaultLayout.vue       # Authenticated layout with nav
│   └── GuestLayout.vue         # Centered guest layout
├── pages/
│   ├── Home.vue                # Gallery view
│   ├── Login.vue
│   ├── Register.vue
│   ├── Upload.vue              # Protected upload page
│   └── NotFound.vue
├── store/
│   └── user.js                 # Pinia store (user state)
├── axios.js                    # Axios instance + interceptors
└── router.js                   # Vue Router with navigation guards
```

### State Management

A single **Pinia store** (`useUserStore`) holds the authenticated user object. On every page load under `DefaultLayout`, the router guard calls `userStore.fetchUser()` which hits `/api/user` with the stored token. If the token is missing or invalid, the user state is set to `null` (guest).

### Routing & Guards

| Route | Component | Guard |
|---|---|---|
| `/` | `Home` | None |
| `/login` | `Login` | None |
| `/register` | `Register` | None |
| `/upload` | `Upload` | User must be authenticated |
| `/*` | `NotFound` | None |

### HTTP Client

`frontend/src/axios.js` creates an Axios instance with `baseURL` from `VITE_API_BASE_URL`. A request interceptor attaches the bearer token from `localStorage` on every outbound request. A response interceptor logs 500 errors to the console.

---

## Environment Variables

The root `.env.dev` / `.env.prod` file is the single source of truth. It is:
- Bind-mounted read-only into the `api` container at `/env/.env`
- Parsed by `scripts/sync-env.sh` to generate `frontend/.env.development` and `frontend/.env.production` before each build

Frontend variables must be prefixed with `VITE_` to be exposed to the browser bundle.

### Key variables

| Variable | Used by | Purpose |
|---|---|---|
| `APP_KEY` | Backend | Laravel encryption key |
| `APP_URL` | Backend | API base URL |
| `FRONTEND_URL` | Backend | CORS allowed origin |
| `DB_*` | Backend | PostgreSQL connection |
| `REDIS_*` | Backend | Redis connection |
| `VITE_API_BASE_URL` | Frontend | Axios base URL |
| `ENABLE_XDEBUG` | PHP-FPM build | Enable/disable Xdebug extension |

---

## Nginx Configuration

Two Nginx server blocks are active in both environments:

| Port | Purpose |
|---|---|
| `80` | Frontend (Vite HMR proxy in dev; static `dist/` in prod) |
| `8080` | Backend API (PHP-FPM FastCGI pass) |

Security headers (`X-Frame-Options`, `X-Content-Type-Options`, `X-XSS-Protection`, `Referrer-Policy`) are set on both blocks. Sensitive files (`.env`, `composer.lock`, `.git`) are denied by Nginx location rules.
