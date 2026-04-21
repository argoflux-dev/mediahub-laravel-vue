# MediaHub

A fullstack media management web application for uploading, browsing, and sharing images — built with **Laravel 12** and **Vue 3**, containerized with **Docker**.

[![PHP](https://img.shields.io/badge/PHP-8.4-777BB4?logo=php)](https://php.net)
[![Laravel](https://img.shields.io/badge/Laravel-12-FF2D20?logo=laravel)](https://laravel.com)
[![Vue.js](https://img.shields.io/badge/Vue-3.5-4FC08D?logo=vue.js)](https://vuejs.org)
[![Docker](https://img.shields.io/badge/Docker-28-2496ED?logo=docker)](https://docker.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## ✨ Features

- **Image gallery** — browse all uploaded images without authentication
- **Secure upload** — authenticated users can upload images with optional labels
- **Token-based authentication** — token-based auth via Laravel Sanctum (Breeze scaffolding)
- **Image management** — delete images directly from the gallery
- **Clipboard copy** — copy any image URL with one click
- **SPA routing** — smooth client-side navigation with Vue Router
- **Responsive UI** — Tailwind CSS 4 with dark-mode support via system preference

## 🏗️ Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Vue 3.5, Vite 8, Tailwind CSS 4, Pinia, Vue Router 4 |
| Backend | Laravel 12, PHP 8.4, Laravel Sanctum, Laravel Breeze |
| Database | PostgreSQL 16 |
| Cache | Redis 7 |
| Web Server | Nginx |
| Containerization | Docker 28, Docker Compose |

## 📁 Project Structure

```
mediahub-laravel-vue/
├── backend/          # Laravel application (PHP-FPM)
├── frontend/         # Vue 3 SPA
├── docker/           # Dockerfiles and Nginx configs
│   ├── nginx/
│   ├── node/
│   ├── php-fpm/
│   └── postgres/
├── scripts/          # Utility shell scripts
├── docs/             # Extended documentation
├── docker-compose.yml          # Production services
├── docker-compose.dev.yml      # Development overrides
├── Makefile                    # Developer commands
├── .env.dev.example
└── .env.prod.example
```

## 🚀 Quick Start

See [docs/QUICKSTART.md](docs/QUICKSTART.md) for step-by-step setup.

```bash
# Clone the repository
git clone https://github.com/argoflux-dev/store-laravel-react.git
cd mediahub-laravel-vue

# Launch installation
```bash
make inatall
```

Application will be available at (dev mode):
- **Frontend (Vite HMR):** `http://localhost:5174`
- **Backend API:** `http://localhost:8082`

## 📖 Documentation

| Document | Description |
|---|---|
| [docs/QUICKSTART.md](docs/QUICKSTART.md) | Environment setup and first run |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System design and component overview |

## 🛠️ Common Commands

```bash
make dev            # Start dev environment
make up             # Start prod environment
make down           # Stop all containers
make migrate        # Run database migrations
make shell          # Open shell in API container
make logs-api       # Stream API logs
make fbuild         # Build frontend for production
```

Run `make help` for the full list.

## 🔐 Authentication

Stateless token-based authentication (Laravel Sanctum) using Bearer authorization header. Tokens are persisted in localStorage and injected into requests via Axios interceptor. Session-based auth is scaffolded but disabled — see `backend/bootstrap/app.php` and `frontend/src/axios.js` for commented alternatives.

## 🤝 Contributing

Pull requests are welcome. For major changes, please open an issue first.

## 📄 License

[MIT](LICENSE)
