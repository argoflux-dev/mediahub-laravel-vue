.PHONY: help build up down restart logs shell composer artisan npm test clean install setup

# Color output
# YELLOW := \033
# GREEN := \033
# RED := \033
# BLUE := \033
# NC := \033

# No Color
YELLOW :=
GREEN :=
RED :=
BLUE :=
NC :=

# Docker Compose files path
COMPOSE_FILE := docker-compose.yml
COMPOSE_FILE_DEV := docker-compose.dev.yml

# Docker Compose Commands
COMPOSE_PROD = docker compose --env-file .env.prod -f $(COMPOSE_FILE)
COMPOSE_DEV  = docker compose --env-file .env.dev -f $(COMPOSE_FILE) -f $(COMPOSE_FILE_DEV)

# Load .env file
ifneq (,$(wildcard .env))
    include .env
    export
endif

SHELL := /bin/bash

help: ## Show this help message
	@echo '$(YELLOW)Available commands:$(NC)'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-25s$(NC) %s\n", $$1, $$2}'

info: ## Show system information
	@echo "$(GREEN)============================================$(NC)"
	@echo "$(YELLOW)Docker Compose Version:$(NC)"
	@docker compose version
	@echo ""
	@echo "$(YELLOW)Container Status:$(NC)"
	@docker compose -f $(COMPOSE_FILE) ps
	@echo ""
	@echo "$(YELLOW)Access URLs:$(NC)"
	@echo "  $(BLUE)Application:$(NC)  $(API_URL)"
	@echo "  $(BLUE)Vite Dev:$(NC)     $(APP_URL):5174"
	@echo "$(GREEN)============================================$(NC)"

#++++++++++++++++++++++ Assembly and installation +++++++++++++++++++++++++++

install: ## Initial project installation (complete setup)
	@echo "$(YELLOW)Сleaning in case of reinstallation...$(NC)"
	@make clean-for-reinstall
	@echo "$(YELLOW)Starting complete project installation...$(NC)"
	@make dbuild
	@make dup
	@echo "$(YELLOW)Waiting for containers to be ready...$(NC)"
	@sleep 10
	@make exec-scripts
	@make laravel-install
	@make setup
	@make permissions
	@make npm-install
	@make key-generate
# 	@make seed-db
	@make storage-link
	@make start-vite
	@echo "$(GREEN)============================================$(NC)"
	@echo "$(GREEN)Installation complete!$(NC)"
	@echo "$(YELLOW)Access points:$(NC)"
	@echo "  $(BLUE)Api:$(NC) https:$(API_URL)"
	@echo "  $(BLUE)Vite Dev:$(NC)    $(APP_URL):5174"
	@echo "$(GREEN)============================================$(NC)"

clean-for-reinstall: ## Stop and remove containers and volumes before reinstall
	@echo "Cleaning up before reinstall..."
	@docker compose -f $(COMPOSE_FILE) --profile dev down -v 2>/dev/null || true
	@docker compose -f $(COMPOSE_FILE) --profile prod down -v 2>/dev/null || true
	@echo "Cleaning backend directory..."
	@find backend/ -mindepth 1 -delete 2>/dev/null || true
	@echo "Clean complete"

setup: ## Setup environment and create symlinks
	@if [ ! -f .env ]; then \
		echo "Creating root .env from .env.example..."; \
		cp .env.dev.example .env.dev; \
		cp .env.prod.example .env.prod; \
		echo "root .env files created"; \
	else \
		echo "root .env already exists"; \
	fi
	@ln -s .env.prod .env
	@rm -f backend/.env.*
	@rm -f frontend/.env.*

laravel-install: ## Install Laravel into backend/ if not already installed
	@if [ ! -f "backend/artisan" ]; then \
			if [ -f "backend/composer.json" ]; then \
					echo "Found existing composer.json, running composer install..."; \
					docker compose -f $(COMPOSE_FILE) exec api composer install --prefer-dist; \
			else \
					echo "Installing fresh Laravel..."; \
					docker compose -f $(COMPOSE_FILE) exec api composer create-project laravel/laravel=^12.0 . --prefer-dist; \
			fi \
	else \
			echo "Laravel already installed, skipping."; \
	fi

vite-install: ## Create Vite + Vue project
	@if [ ! -f "frontend/package.json" ]; then \
		echo "Creating Vite project..."; \
		docker compose -f $(COMPOSE_FILE) run --rm app sh -c "\
			npm create vite@latest . && \
			npm install"; \
	else \
		echo "Frontend already exists, skipping."; \
	fi

dev: ## Start development environment
	@echo "$(YELLOW)Starting development environment...$(NC)"
	@make dup
	@echo "$(GREEN)============================================$(NC)"
	@echo "$(GREEN)Development environment started!$(NC)"
	@echo "$(YELLOW)Access points:$(NC)"
	@echo "  $(BLUE)Vite:	http://localhost:5174"
	@echo "  $(BLUE)Api:	http://localhost:8082"
	@echo "$(GREEN)============================================$(NC)"

fbuild: ## Build assets for production
	@echo "$(YELLOW)Building assets for production...$(NC)"
	rm -rf frontend/dist frontend/hot
	sh scripts/sync-env.sh
	# If fresh build needed (before deploy) add this row (clean node_modules):
	# docker compose -f $(COMPOSE_FILE) exec app npm ci
	@docker compose -f $(COMPOSE_FILE) --profile dev up -d app
	@docker compose -f $(COMPOSE_FILE) exec app npm run build
	@docker compose -f $(COMPOSE_FILE) stop app
	# Alternative (CI-approach: create service container, build, stop & clean)
	# the most slow & clean build method, use without up & stop container rows:
	# docker compose -f $(COMPOSE_FILE) run --rm app sh -c "npm ci && npm run build"
	@echo "$(GREEN)Production build complete!$(NC)"
	@echo "$(BLUE)Built files are in frontend/dist/$(NC)"

build: ## Full production build (composer + npm)
	@echo "$(YELLOW)Starting full production build...$(NC)"
	@make composer-install
	@make fbuild
	@make optimize
	@echo "$(GREEN)============================================$(NC)"
	@echo "$(GREEN)Production build complete!$(NC)"
	@echo "$(YELLOW)Built assets:$(NC) frontend/dist/"
	@echo "$(YELLOW)Next steps:$(NC)"
	@echo "  1. Deploy files to production server"
	@echo "  2. Run migrations: make migrate"
	@echo "  3. Clear cache: make cache-clear"
	@echo "$(GREEN)============================================$(NC)"

breeze-install: ## Install Laravel Breeze with Vue
	@echo "$(YELLOW)Installing Laravel Breeze...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api composer require laravel/breeze --dev
	docker compose -f $(COMPOSE_FILE) exec api php artisan breeze:install vue
	docker compose -f $(COMPOSE_FILE) exec app npm install --legacy-peer-deps
	docker compose -f $(COMPOSE_FILE) exec app npm run build
	@echo "$(GREEN)Breeze with Vue installed successfully!$(NC)"

key-generate: ## Generate application key
	@echo "$(YELLOW)Generating application key...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api php artisan key:generate
	@echo "$(GREEN)Application key generated!$(NC)"

storage-link: ## Create storage symbolic link
	@echo "$(YELLOW)Creating storage link...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api php artisan storage:link
	@echo "$(GREEN)Storage link created!$(NC)"

permissions: ## Fix storage and cache permissions
	@echo "$(YELLOW)Fixing permissions...$(NC)"
	@chmod +x scripts/setup-permissions.sh
	@./scripts/setup-permissions.sh
	@echo "$(GREEN)Permissions fixed!$(NC)"

exec-scripts: ## Make all scripts executable
	@echo "$(YELLOW)Making scripts executable...$(NC)"
	@chmod +x scripts/*.sh
	@echo "$(GREEN)Scripts are now executable!$(NC)"

#++++++++++++++++++++++ Docker +++++++++++++++++++++++++++

ps: ## Show running containers
	docker compose -f $(COMPOSE_FILE) ps

stats: ## Show container resource usage
	@docker stats --no-stream

dbuild: ## Build Docker containers
	@echo "$(YELLOW)Building Docker containers...$(NC)"
	docker compose -f $(COMPOSE_FILE) build --no-cache

dbuild-quick: ## Build Docker containers (with cache)
	@echo "$(YELLOW)Building Docker containers (quick)...$(NC)"
	docker compose -f $(COMPOSE_FILE) build

dup: ## Start Docker containers in dev mode
	@echo "$(YELLOW)Starting Docker containers...$(NC)"
	sh scripts/sync-env.sh
	$(COMPOSE_DEV) up -d
	@echo "$(YELLOW)Cleaning Laravel cache...$(NC)"
	@sleep 5
	$(COMPOSE_DEV) exec api php artisan config:clear
	$(COMPOSE_DEV) exec api php artisan route:clear
	$(COMPOSE_DEV) exec api php artisan view:clear
	@echo "$(YELLOW)Starting Vite...$(NC)"
	$(COMPOSE_DEV) exec -d app npm run dev
	@echo "$(GREEN)Dev containers started!$(NC)"
	@make ps

up: ## Start Docker containers in prod mode
	@echo "$(YELLOW)Starting Docker containers...$(NC)"
	rm -rf backend/public/hot
	sh scripts/sync-env.sh
	$(COMPOSE_PROD) up -d
	@echo "$(YELLOW)Optimizing Laravel...$(NC)"
	@sleep 3
	$(COMPOSE_PROD) exec api php artisan config:cache
	$(COMPOSE_PROD) exec api php artisan route:cache
	@echo "$(GREEN)Prod containers started!$(NC)"
	@make ps

down: ## Stop Docker containers
	@echo "$(YELLOW)Stopping Docker containers...$(NC)"
	$(COMPOSE_DEV) down
	@echo "$(GREEN)Containers stopped!$(NC)"

down-v: ## Stop and remove all containers with volumes
	@echo "$(YELLOW)Stopping containers and removing volumes...$(NC)"
	docker compose -f $(COMPOSE_FILE) down -v
	@echo "$(GREEN)Containers and volumes removed!$(NC)"

restart: ## Restart Docker containers
	@echo "$(YELLOW)Restarting containers...$(NC)"
	@make down
	@make up

drestart: ## Restart Docker containers - development mode
	@echo "$(YELLOW)Restarting containers - development mode...$(NC)"
	@make down
	@make dup

volumes-list: ## List all project volumes
	@echo "$(YELLOW)Project volumes:$(NC)"
	@docker volume ls | grep infrastructure || echo "No volumes found"

volumes-prune: ## Remove unused volumes (careful!)
	@echo "$(RED)WARNING: This will remove ALL unused Docker volumes!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker volume prune -f; \
		echo "$(GREEN)Unused volumes removed!$(NC)"; \
	fi

clean: ## Clean up containers, volumes, and cache
	@echo "$(RED)WARNING: This will remove all containers, volumes, and cached data!$(NC)"
	@read -p "Are you sure? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(YELLOW)Cleaning up...$(NC)"; \
		docker compose -f $(COMPOSE_FILE) down -v; \
		rm -rf vendor node_modules; \
		rm -rf storage/logs/*.log; \
		echo "$(GREEN)Cleanup complete!$(NC)"; \
	fi

#++++++++++++++++++++++ Artisan +++++++++++++++++++++++++++

artisan: ## Run Artisan command (use CMD="command" syntax)
	@docker compose -f $(COMPOSE_FILE) exec api php artisan $(CMD)

cache-clear: ## Clear application cache
	@echo "$(YELLOW)Clearing cache...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api php artisan cache:clear
	docker compose -f $(COMPOSE_FILE) exec api php artisan config:clear
	docker compose -f $(COMPOSE_FILE) exec api php artisan route:clear
	docker compose -f $(COMPOSE_FILE) exec api php artisan view:clear
	@echo "$(GREEN)Cache cleared!$(NC)"

optimize: ## Optimize application
	@echo "$(YELLOW)Optimizing application...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api php artisan config:cache
	docker compose -f $(COMPOSE_FILE) exec api php artisan route:cache
	docker compose -f $(COMPOSE_FILE) exec api php artisan view:cache
	docker compose -f $(COMPOSE_FILE) exec api php artisan optimize
	@echo "$(GREEN)Application optimized!$(NC)"

#++++++++++++++++++++++ Vite +++++++++++++++++++++++++++

start-vite: ## Start Vite dev server
	@echo "$(YELLOW)Starting Vite dev server...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec -d app npm run dev
	@echo "$(GREEN)Vite dev server started in background!$(NC)"

stop-vite: ## Stop Vite dev server
	@echo "$(YELLOW)Stopping Vite dev server...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec app pkill -f vite || true
	@echo "$(GREEN)Vite dev server stopped!$(NC)"

restart-vite: ## Restart Vite dev server
	@make stop-vite
	@sleep 2
	@make start-vite

#++++++++++++++++++++++ Database +++++++++++++++++++++++++++

migrate: ## Run database migrations
	@echo "$(YELLOW)Running database migrations...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api php artisan migrate
	@echo "$(GREEN)Migrations complete!$(NC)"

migrate-fresh: ## Fresh migration with seed
	@echo "$(RED)WARNING: This will drop all tables!$(NC)"
	@echo "$(YELLOW)Running fresh migrations...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api php artisan migrate:fresh --force
	@echo "$(GREEN)Fresh migrations complete!$(NC)"

migrate-fresh-seed: ## Fresh migration with seed
	@echo "$(RED)WARNING: This will drop all tables!$(NC)"
	@echo "$(YELLOW)Running fresh migrations with seed...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api php artisan migrate:fresh --seed --force
	@echo "$(GREEN)Fresh migrations complete!$(NC)"

migrate-rollback: ## Rollback last migration
	@echo "$(YELLOW)Rolling back last migration...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api php artisan migrate:rollback
	@echo "$(GREEN)Rollback complete!$(NC)"

seed: ## Seed the database
	@echo "$(YELLOW)Seeding database...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api php artisan db:seed
	@echo "$(GREEN)Database seeded!$(NC)"

# seed-db: ## Fresh DB, then Migrate and Seed with demo data
# 	@echo "$(YELLOW)Freshing > Migrating > Seeding database with demo data...$(NC)"
# 	@chmod +x scripts/seed-database.sh
# 	@./scripts/seed-database.sh
# 	@echo "$(GREEN)Permissions fixed!$(NC)"

db-backup: ## Backup database (output: backup_YYYY-MM-DD_HH-MM-SS.sql)
	@echo "$(YELLOW)Creating database backup...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec -T postgres pg_dump -U mediahub_user mediahub_db > backup_$$(date +%Y-%m-%d_%H-%M-%S).sql
	@echo "$(GREEN)Backup created: backup_$$(date +%Y-%m-%d_%H-%M-%S).sql$(NC)"

db-restore: ## Restore database from backup (use FILE=backup.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: Please specify FILE=backup.sql$(NC)"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Restoring database from $(FILE)...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec -T postgres psql -U mediahub_user mediahub_db < $(FILE)
	@echo "$(GREEN)Database restored!$(NC)"

#++++++++++++++++++++++ Shell +++++++++++++++++++++++++++

shell: ## Access api container shell
	@docker compose -f $(COMPOSE_FILE) exec api sh

shell-root: ## Access store container shell as root
	@docker compose -f $(COMPOSE_FILE) exec -u root api sh

tinker: ## Run tinker command in api container
	docker compose -f $(COMPOSE_FILE) exec api php artisan tinker

shell-app: ## Access app container shell
	@docker compose -f $(COMPOSE_FILE) exec app sh

shell-redis: ## Access redis container shell
	@docker compose -f $(COMPOSE_FILE) exec redis sh

shell-db: ## Access DB container shell
	@docker compose -f $(COMPOSE_FILE) exec postgres sh

#++++++++++++++++++++++ npm +++++++++++++++++++++++++++

npm-install: ## Install NPM dependencies
	@echo "$(YELLOW)Installing NPM dependencies (this may take 2-3 minutes)...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec app npm install --prefer-offline --no-audit
	@echo "$(GREEN)NPM dependencies installed!$(NC)"

npm-update: ## Update NPM dependencies
	@echo "$(YELLOW)Updating NPM dependencies...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec app npm update
	@echo "$(GREEN)NPM dependencies updated!$(NC)"

npm: ## Run NPM command (use CMD="command" syntax)
	@docker compose -f $(COMPOSE_FILE) exec app npm $(CMD)

#++++++++++++++++++++++ Composer +++++++++++++++++++++++++++

composer-install: ## Install Composer dependencies
	@echo "$(YELLOW)Installing Composer dependencies...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api composer install --optimize-autoloader
	@echo "$(GREEN)Composer dependencies installed!$(NC)"

composer-update: ## Update Composer dependencies
	@echo "$(YELLOW)Updating Composer dependencies...$(NC)"
	docker compose -f $(COMPOSE_FILE) exec api composer update
	@echo "$(GREEN)Composer dependencies updated!$(NC)"

composer: ## Run Composer command (use CMD="command" syntax)
	@docker compose -f $(COMPOSE_FILE) exec api composer $(CMD)

#++++++++++++++++++++++ Logs +++++++++++++++++++++++++++

logs: ## Show container logs (use CONTAINER=name for specific container)
	@docker compose -f $(COMPOSE_FILE) logs -f $(CONTAINER)

logs-api: ## Show api container logs
	@docker compose -f $(COMPOSE_FILE) logs -f api

logs-nginx-dev: ## Show nginx-dev container logs
	@docker compose -f $(COMPOSE_FILE) logs -f nginx-dev

logs-nginx-prod: ## Show nginx-prod container logs
	@docker compose -f $(COMPOSE_FILE) logs -f nginx-prod

logs-app: ## Show app container logs
	@docker compose -f $(COMPOSE_FILE) logs -f app

#++++++++++++++++++++++ XDebug +++++++++++++++++++++++++++

xdebug-enable: ## Enable Xdebug
	@echo "$(YELLOW)Enabling Xdebug...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec api sed -i 's/;zend_extension=xdebug/zend_extension=xdebug/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini || true
	@docker compose -f $(COMPOSE_FILE) restart api
	@echo "$(GREEN)Xdebug enabled!$(NC)"

xdebug-disable: ## Disable Xdebug (better performance)
	@echo "$(YELLOW)Disabling Xdebug...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec api sed -i 's/zend_extension=xdebug/;zend_extension=xdebug/' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini || true
	@docker compose -f $(COMPOSE_FILE) restart api
	@echo "$(GREEN)Xdebug disabled!$(NC)"

xdebug-status: ## Check Xdebug status
	@docker compose -f $(COMPOSE_FILE) exec api php -v | grep -i xdebug || echo "Xdebug is not enabled"

#++++++++++++++++++++++ Linters +++++++++++++++++++++++++++

lint: ## Run ESLint
	@echo "$(YELLOW)Running ESLint...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec app npm run lint

lint-fix: ## Fix ESLint issues
	@echo "$(YELLOW)Fixing ESLint issues...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec app npm run lint:fix

format: ## Format code with Prettier
	@echo "$(YELLOW)Formatting code...$(NC)"
	@docker compose -f $(COMPOSE_FILE) exec app npm run format