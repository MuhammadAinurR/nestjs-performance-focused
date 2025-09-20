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

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help install dev build start stop clean db-up db-down db-reset reroll migrate seed test lint format docker-up docker-down docker-build docker-logs

help: ## Show this help message
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

install: ## Install dependencies
	@echo "$(GREEN)Installing dependencies...$(NC)"
	$(NPM) install

dev: db-up ## Start development server with database
	@echo "$(GREEN)Starting development server...$(NC)"
	$(NPM) run start:dev

build: ## Build the application
	@echo "$(GREEN)Building application...$(NC)"
	$(NPM) run build

start: ## Start production server
	@echo "$(GREEN)Starting production server...$(NC)"
	$(NPM) run start:prod

stop: ## Stop all services
	@echo "$(YELLOW)Stopping all services...$(NC)"
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE_DEV) down

clean: stop ## Clean up containers and volumes
	@echo "$(RED)Cleaning up containers and volumes...$(NC)"
	$(DOCKER_COMPOSE) down -v --remove-orphans
	$(DOCKER_COMPOSE_DEV) down -v --remove-orphans
	docker system prune -f

db-up: ## Start database and Redis containers (development)
	@echo "$(GREEN)Starting development database and Redis containers...$(NC)"
	$(DOCKER_COMPOSE_DEV) up -d postgres redis
	@echo "$(GREEN)Waiting for database to be ready...$(NC)"
	@timeout /t 5 >nul 2>&1 || sleep 5 2>/dev/null || echo "Waiting 5 seconds..."

db-down: ## Stop database and Redis containers (development)
	@echo "$(YELLOW)Stopping development database and Redis containers...$(NC)"
	$(DOCKER_COMPOSE_DEV) down

docker-up: ## Start all services with Docker (production)
	@echo "$(GREEN)Starting all services with Docker...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Waiting for services to be ready...$(NC)"
	@timeout /t 10 >nul 2>&1 || sleep 10 2>/dev/null || echo "Waiting 10 seconds..."

docker-down: ## Stop all Docker services
	@echo "$(YELLOW)Stopping all Docker services...$(NC)"
	$(DOCKER_COMPOSE) down

docker-build: ## Build Docker images
	@echo "$(GREEN)Building Docker images...$(NC)"
	$(DOCKER_COMPOSE) build

docker-logs: ## Show all Docker service logs
	@echo "$(GREEN)Showing Docker service logs...$(NC)"
	$(DOCKER_COMPOSE) logs -f

db-reset: ## Reset database (delete, create, migrate)
	@echo "$(RED)Resetting database...$(NC)"
	@echo "$(YELLOW)This will delete all data. Are you sure? [y/N]$(NC)" && read ans && [ $${ans:-N} = y ]
	$(NPM) run db:reset
	@echo "$(GREEN)Database reset completed$(NC)"

migrate: ## Run database migrations
	@echo "$(GREEN)Running database migrations...$(NC)"
	$(NPM) run prisma:migrate

seed: ## Seed database with test data
	@echo "$(GREEN)Seeding database...$(NC)"
	$(NPM) run prisma:seed

reroll: ## Complete database reset: delete, create, migrate, and seed
	@echo "$(GREEN)Starting complete database reroll...$(NC)"
	@echo "$(RED)This will delete ALL data and recreate the database!$(NC)"
	@echo "$(GREEN)Step 1: Resetting database...$(NC)"
	$(NPM) run db:reset --force
	@echo "$(GREEN)Step 2: Generating Prisma client...$(NC)"
	$(NPM) run prisma:generate
	@echo "$(GREEN)Step 3: Running migrations...$(NC)"
	$(NPM) run prisma:migrate
	@echo "$(GREEN)Step 4: Seeding database...$(NC)"
	$(NPM) run prisma:seed
	@echo "$(GREEN)✅ Database reroll completed successfully!$(NC)"
	@echo "$(YELLOW)Your database is now ready to use with fresh test data.$(NC)"

reroll-confirm: ## Complete database reset with confirmation prompt (Unix only)
	@echo "$(GREEN)Starting complete database reroll...$(NC)"
	@timeout /t 3 >nul 2>&1 || sleep 3 2>/dev/null || echo "Waiting 3 seconds..."
	@echo "$(RED)This will delete ALL data and recreate the database!$(NC)"
	@echo "$(YELLOW)Are you sure you want to continue? [y/N]$(NC)" && read ans && [ $${ans:-N} = y ]
	@echo "$(GREEN)Step 1: Resetting database...$(NC)"
	$(NPM) run db:reset --force
	@echo "$(GREEN)Step 2: Generating Prisma client...$(NC)"
	$(NPM) run prisma:generate
	@echo "$(GREEN)Step 3: Running migrations...$(NC)"
	$(NPM) run prisma:migrate
	@echo "$(GREEN)Step 4: Seeding database...$(NC)"
	$(NPM) run prisma:seed
	@echo "$(GREEN)✅ Database reroll completed successfully!$(NC)"
	@echo "$(YELLOW)Your database is now ready to use with fresh test data.$(NC)"

setup: db-up reroll ## Start services and setup database (complete development setup)
	@echo "$(GREEN)✅ Complete development setup finished!$(NC)"
	@echo "$(YELLOW)Database services are running and database is ready.$(NC)"
	@echo "$(GREEN)You can now run 'make dev' to start the application.$(NC)"

test: ## Run tests
	@echo "$(GREEN)Running tests...$(NC)"
	$(NPM) run test

test-e2e: ## Run end-to-end tests
	@echo "$(GREEN)Running e2e tests...$(NC)"
	$(NPM) run test:e2e

lint: ## Run linting
	@echo "$(GREEN)Running linter...$(NC)"
	$(NPM) run lint

format: ## Format code
	@echo "$(GREEN)Formatting code...$(NC)"
	$(NPM) run format

logs: ## Show application logs
	@echo "$(GREEN)Showing logs...$(NC)"
	$(DOCKER_COMPOSE_DEV) logs -f

db-logs: ## Show database logs
	@echo "$(GREEN)Showing database logs...$(NC)"
	$(DOCKER_COMPOSE_DEV) logs -f postgres

redis-logs: ## Show Redis logs
	@echo "$(GREEN)Showing Redis logs...$(NC)"
	$(DOCKER_COMPOSE_DEV) logs -f redis

status: ## Show service status
	@echo "$(GREEN)Development Service Status:$(NC)"
	$(DOCKER_COMPOSE_DEV) ps
	@echo "$(GREEN)Production Service Status:$(NC)"
	$(DOCKER_COMPOSE) ps
