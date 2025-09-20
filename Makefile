# Makefile for MPIX Backend

# Default target
.DEFAULT_GOAL := help

# Variables
DOCKER_COMPOSE = docker-compose
DOCKER_COMPOSE_DEV = docker-compose -f docker-compose.dev.yml
NPM = npm
DB_CONTAINER = mdc_postgres_dev
REDIS_CONTAINER = mdc_redis_dev
APP_CONTAINER = mdc_backend

# Detect OS and set colors accordingly
ifeq ($(OS),Windows_NT)
    # Windows - no colors due to PowerShell compatibility issues
    GREEN = 
    YELLOW = 
    RED = 
    NC = 
else
    # Unix/Linux/macOS - use ANSI colors
    GREEN = \033[0;32m
    YELLOW = \033[1;33m
    RED = \033[0;31m
    NC = \033[0m
endif

.PHONY: help install dev build start stop clean db-up db-down db-reset reroll migrate seed test lint format docker-up docker-down docker-build docker-logs

help: ## Show this help message
ifeq ($(OS),Windows_NT)
	@echo "MPIX Backend Makefile"
	@echo "Available commands:"
	@echo "  help            - Show this help message"
	@echo "  install         - Install dependencies"
	@echo "  dev             - Start development server with database"
	@echo "  build           - Build the application"
	@echo "  start           - Start production server"
	@echo "  stop            - Stop all services"
	@echo "  clean           - Clean up containers and volumes"
	@echo.
	@echo "Database Commands:"
	@echo "  db-up           - Start database and Redis containers (development)"
	@echo "  db-down         - Stop database and Redis containers (development)"
	@echo "  reroll          - Complete database reset: delete, create, migrate, and seed"
	@echo "  reroll-confirm  - Complete database reset with confirmation (Unix only)"
	@echo "  setup           - Start services and setup database (complete development setup)"
	@echo "  migrate         - Run database migrations"
	@echo "  seed            - Seed database with test data"
	@echo "  db-reset        - Reset database (delete, create, migrate)"
	@echo.
	@echo "Docker Commands:"
	@echo "  docker-up       - Start all services with Docker (production)"
	@echo "  docker-down     - Stop all Docker services"
	@echo "  docker-build    - Build Docker images"
	@echo "  docker-logs     - Show all Docker service logs"
	@echo.
	@echo "Development Commands:"
	@echo "  test            - Run tests"
	@echo "  test-e2e        - Run end-to-end tests"
	@echo "  lint            - Run linting"
	@echo "  format          - Format code"
	@echo "  logs            - Show application logs"
	@echo "  status          - Show service status"
else
	@echo "$(GREEN)MPIX Backend Makefile$(NC)"
	@echo "Available commands:"
	@echo "  $(YELLOW)help           $(NC) Show this help message"
	@echo "  $(YELLOW)install        $(NC) Install dependencies"
	@echo "  $(YELLOW)dev            $(NC) Start development server with database"
	@echo "  $(YELLOW)build          $(NC) Build the application"
	@echo "  $(YELLOW)start          $(NC) Start production server"
	@echo "  $(YELLOW)stop           $(NC) Stop all services"
	@echo "  $(YELLOW)clean          $(NC) Clean up containers and volumes"
	@echo ""
	@echo "  $(GREEN)Database Commands:$(NC)"
	@echo "  $(YELLOW)db-up          $(NC) Start database and Redis containers (development)"
	@echo "  $(YELLOW)db-down        $(NC) Stop database and Redis containers (development)"
	@echo "  $(YELLOW)reroll         $(NC) Complete database reset: delete, create, migrate, and seed"
	@echo "  $(YELLOW)reroll-confirm $(NC) Complete database reset with confirmation (Unix only)"
	@echo "  $(YELLOW)setup          $(NC) Start services and setup database (complete development setup)"
	@echo "  $(YELLOW)migrate        $(NC) Run database migrations"
	@echo "  $(YELLOW)seed           $(NC) Seed database with test data"
	@echo "  $(YELLOW)db-reset       $(NC) Reset database (delete, create, migrate)"
	@echo ""
	@echo "  $(GREEN)Docker Commands:$(NC)"
	@echo "  $(YELLOW)docker-up      $(NC) Start all services with Docker (production)"
	@echo "  $(YELLOW)docker-down    $(NC) Stop all Docker services"
	@echo "  $(YELLOW)docker-build   $(NC) Build Docker images"
	@echo "  $(YELLOW)docker-logs    $(NC) Show all Docker service logs"
	@echo ""
	@echo "  $(GREEN)Development Commands:$(NC)"
	@echo "  $(YELLOW)test           $(NC) Run tests"
	@echo "  $(YELLOW)test-e2e       $(NC) Run end-to-end tests"
	@echo "  $(YELLOW)lint           $(NC) Run linting"
	@echo "  $(YELLOW)format         $(NC) Format code"
	@echo "  $(YELLOW)logs           $(NC) Show application logs"
	@echo "  $(YELLOW)status         $(NC) Show service status"
endif

install: ## Install dependencies
	@echo "Installing dependencies..."
	$(NPM) install

dev: db-up ## Start development server with database
	@echo "$(GREEN)Starting development server...$(NC)"
	$(NPM) run dev

build: ## Build the application
	@echo "Building application..."
	$(NPM) run build

start: ## Start production server
	@echo "Starting production server..."
	$(NPM) run start:prod

stop: ## Stop all services
	@echo "Stopping all services..."
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE_DEV) down

clean: stop ## Clean up containers and volumes
	@echo "Cleaning up containers and volumes..."
	$(DOCKER_COMPOSE) down -v --remove-orphans
	$(DOCKER_COMPOSE_DEV) down -v --remove-orphans
	docker system prune -f

db-up: ## Start database and Redis containers (development)
	@echo "Starting development database and Redis containers..."
	$(DOCKER_COMPOSE_DEV) up -d postgres redis
	@echo "Waiting for database to be ready..."
	@timeout /t 5 >nul 2>&1 || sleep 5 2>/dev/null || echo "Waiting 5 seconds..."

db-down: ## Stop database and Redis containers (development)
	@echo "Stopping development database and Redis containers..."
	$(DOCKER_COMPOSE_DEV) down

docker-up: ## Start all services with Docker (production)
	@echo "Starting all services with Docker..."
	$(DOCKER_COMPOSE) up -d
	@echo "Waiting for services to be ready..."
	@timeout /t 10 >nul 2>&1 || sleep 10 2>/dev/null || echo "Waiting 10 seconds..."

docker-down: ## Stop all Docker services
	@echo "Stopping all Docker services..."
	$(DOCKER_COMPOSE) down

docker-build: ## Build Docker images
	@echo "Building Docker images..."
	$(DOCKER_COMPOSE) build

docker-logs: ## Show all Docker service logs
	@echo "Showing Docker service logs..."
	$(DOCKER_COMPOSE) logs -f

db-reset: ## Reset database (delete, create, migrate)
	@echo "Resetting database..."
	@echo "This will delete all data. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	$(NPM) run db:reset
	@echo "Database reset completed"

migrate: ## Run database migrations
	@echo "Running database migrations..."
	$(NPM) run prisma:migrate

seed: ## Seed database with test data
	@echo "Seeding database..."
	$(NPM) run prisma:seed

reroll: ## Complete database reset: delete, create, migrate, and seed
	@echo "Starting complete database reroll..."
	@echo "This will delete ALL data and recreate the database!"
	@echo "Step 1: Resetting database..."
	$(NPM) run db:reset --force
	@echo "Step 2: Generating Prisma client..."
	$(NPM) run prisma:generate
	@echo "Step 3: Running migrations..."
	$(NPM) run prisma:migrate
	@echo "Step 4: Seeding database..."
	$(NPM) run prisma:seed
	@echo "Database reroll completed successfully!"
	@echo "Your database is now ready to use with fresh test data."

reroll-confirm: ## Complete database reset with confirmation prompt (Unix only)
	@echo "Starting complete database reroll..."
	@timeout /t 3 >nul 2>&1 || sleep 3 2>/dev/null || echo "Waiting 3 seconds..."
	@echo "This will delete ALL data and recreate the database!"
	@echo "Are you sure you want to continue? [y/N]" && read ans && [ $${ans:-N} = y ]
	@echo "Step 1: Resetting database..."
	$(NPM) run db:reset --force
	@echo "Step 2: Generating Prisma client..."
	$(NPM) run prisma:generate
	@echo "Step 3: Running migrations..."
	$(NPM) run prisma:migrate
	@echo "Step 4: Seeding database..."
	$(NPM) run prisma:seed
	@echo "Database reroll completed successfully!"
	@echo "Your database is now ready to use with fresh test data."

setup: db-up reroll ## Start services and setup database (complete development setup)
	@echo "Complete development setup finished!"
	@echo "Database services are running and database is ready."
	@echo "You can now run 'make dev' to start the application."

test: ## Run tests
	@echo "Running tests..."
	$(NPM) run test

test-e2e: ## Run end-to-end tests
	@echo "Running e2e tests..."
	$(NPM) run test:e2e

lint: ## Run linting
	@echo "Running linter..."
	$(NPM) run lint

format: ## Format code
	@echo "Formatting code..."
	$(NPM) run format

logs: ## Show application logs
	@echo "Showing logs..."
	$(DOCKER_COMPOSE_DEV) logs -f

db-logs: ## Show database logs
	@echo "Showing database logs..."
	$(DOCKER_COMPOSE_DEV) logs -f postgres

redis-logs: ## Show Redis logs
	@echo "Showing Redis logs..."
	$(DOCKER_COMPOSE_DEV) logs -f redis

status: ## Show service status
	@echo "Development Service Status:"
	$(DOCKER_COMPOSE_DEV) ps
	@echo "Production Service Status:"
	$(DOCKER_COMPOSE) ps
