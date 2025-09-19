# Database Operations Makefile

# Detect operating system and set script command
ifeq ($(OS),Windows_NT)
    DB_SCRIPT_CMD = powershell -ExecutionPolicy Bypass -File ./scripts/db-setup.ps1
else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
        DB_SCRIPT_CMD = ./scripts/db-setup.sh
    endif
    ifeq ($(UNAME_S),Darwin)
        DB_SCRIPT_CMD = ./scripts/db-setup.sh
    endif
endif

# Default target
.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make check      - Check database connectivity"
	@echo "  make migrate    - Run Prisma migrations"
	@echo "  make generate   - Generate Prisma client"
	@echo "  make seed       - Seed the database"
	@echo "  make create     - Create database if not exists"
	@echo "  make reset      - Reset database (drop & recreate)"
	@echo "  make reroll     - Reset database and reseed"
	@echo "  make studio     - Open Prisma Studio"
	@echo "  make push       - Push schema changes to database"
	@echo "  make deploy     - Deploy migrations to production"

# Check database connectivity
.PHONY: check
check:
	$(DB_SCRIPT_CMD) check

# Create database if it doesn't exist
.PHONY: create
create:
	$(DB_SCRIPT_CMD) create

# Generate Prisma client
.PHONY: generate
generate:
	npx prisma generate

# Create and run new migration
.PHONY: migrate
migrate:
	npx prisma migrate dev

# Push schema changes without migration (dev only)
.PHONY: push
push:
	npx prisma db push

# Reset database (force recreate)
.PHONY: reset
reset:
	$(DB_SCRIPT_CMD) reset

# Seed database
.PHONY: seed
seed:
	$(DB_SCRIPT_CMD) seed

# Reset and reseed database
.PHONY: reroll
reroll:
	$(DB_SCRIPT_CMD) reroll

# Open Prisma Studio
.PHONY: studio
studio:
	npx prisma studio

# Deploy migrations (production)
.PHONY: deploy
deploy:
	npx prisma migrate deploy

# Format schema
.PHONY: format
format:
	npx prisma format

# Validate schema
.PHONY: validate
validate:
	npx prisma validate
