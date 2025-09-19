# Makefile for MPIX Backend

# Default target
.DEFAULT_GOAL := help

# Variables
DOCKER_COMPOSE = docker-compose
NPM = npm
DB_CONTAINER = mpix_postgres
REDIS_CONTAINER = mpix_redis

# Colors for output
GREEN = \033[0;32m
YELLOW = \033[1;33m
RED = \033[0;31m
NC = \033[0m # No Color

.PHONY: help install dev build start stop clean db-up db-down db-reset reroll migrate seed test lint format

help: ## Show this help message
	@echo "$(GREEN)MPIX Backend Makefile$(NC)"
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(YELLOW)%-15s$(NC) %s\n", $$1, $$2}' $(MAKEFILE_LIST)

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

clean: stop ## Clean up containers and volumes
	@echo "$(RED)Cleaning up containers and volumes...$(NC)"
	$(DOCKER_COMPOSE) down -v --remove-orphans
	docker system prune -f

db-up: ## Start database and Redis containers
	@echo "$(GREEN)Starting database and Redis containers...$(NC)"
	$(DOCKER_COMPOSE) up -d postgres redis
	@echo "$(GREEN)Waiting for database to be ready...$(NC)"
	@sleep 5

db-down: ## Stop database and Redis containers
	@echo "$(YELLOW)Stopping database and Redis containers...$(NC)"
	$(DOCKER_COMPOSE) down

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

reroll: db-up ## Complete database reset: delete, create, migrate, and seed
	@echo "$(GREEN)Starting complete database reroll...$(NC)"
	@sleep 3
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
	$(DOCKER_COMPOSE) logs -f

db-logs: ## Show database logs
	@echo "$(GREEN)Showing database logs...$(NC)"
	$(DOCKER_COMPOSE) logs -f postgres

redis-logs: ## Show Redis logs
	@echo "$(GREEN)Showing Redis logs...$(NC)"
	$(DOCKER_COMPOSE) logs -f redis

status: ## Show service status
	@echo "$(GREEN)Service Status:$(NC)"
	$(DOCKER_COMPOSE) ps
