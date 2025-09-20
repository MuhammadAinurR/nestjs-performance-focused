# MDC Backend - High Performance NestJS API

A high-performance NestJS backend built with Fastify, PostgreSQL, and JWT authentication. This project follows modern development practices with comprehensive type safety, API documentation, and performance optimizations.

## 🚀 Features

- **High Performance**: Built with Fastify for maximum throughput
- **Authentication**: Complete JWT-based auth system with refresh tokens
- **Database**: PostgreSQL with Prisma ORM for type-safe database operations
- **Health Monitoring**: Comprehensive health check endpoints with database status
- **Type Safety**: Full TypeScript support with strict typing and path aliases
- **API Documentation**: Auto-generated Swagger/OpenAPI documentation
- **Development Tools**: Hot reload, linting, formatting, and testing setup
- **Docker Support**: Containerized development environment
- **Modern Stack**: Latest NestJS, Node.js 20+, and ecosystem tools

## 📋 Prerequisites

- **Node.js**: 18+ (recommended: 20+)
- **npm**: Latest version 
- **Docker & Docker Compose**: For database services
- **Make**: For convenient development commands
- **PostgreSQL**: Local or Docker (configured)

## 🛠️ Quick Start

### Option 1: Cross-Platform Development (Recommended)
```bash
# Install dependencies
npm install

# Start development (auto-detects Docker/alternatives)
npm run dev

# Quick database setup
npm run setup
```

### Option 2: Traditional Make Commands
```bash
# Install dependencies
make install

# Start database services and development server
make dev

# Complete database reset with fresh data
make reroll
```

**🎉 Your API is now running!**
- **API Base**: http://localhost:3000
- **Swagger Documentation**: http://localhost:3000/docs
- **Health Check**: http://localhost:3000/health

## 🐳 Docker Development Workflows

### Development Workflow (Recommended)

**Using docker-compose.dev.yml** - Only runs database services, your app runs locally:

```bash
# Start database and Redis only
make db-up
# OR
docker compose -f docker-compose.dev.yml up -d

# Start your app locally with hot reload
make dev
# OR
npm run start:dev

# Stop database services
make db-down
# OR
docker compose -f docker-compose.dev.yml down
```

**Benefits:**
- ✅ Fast development with hot reload
- ✅ Easy debugging and development
- ✅ Only database services in containers
- ✅ Local Node.js environment

### Production Workflow

**Using docker-compose.yml** - Complete application stack:

```bash
# Build and start complete application stack
make docker-up
# OR
docker compose up -d

# View logs
make docker-logs
# OR
docker compose logs -f

# Stop all services
make docker-down
# OR
docker compose down
```

**Benefits:**
- ✅ Production-like environment
- ✅ Complete containerized stack
- ✅ Ready for deployment
- ✅ Isolated application environment

## 🔧 Makefile Commands Reference

### Essential Development Commands
```bash
make help           # Show all available commands with descriptions
make install        # Install/update dependencies
make dev            # Start development server with database
make build          # Build application for production
make start          # Start production server
```

### Database Management Commands
```bash
make db-up          # Start PostgreSQL and Redis (development)
make db-down        # Stop database containers
make reroll         # 🔄 Complete database reset: delete → migrate → seed
make migrate        # Run database migrations only
make seed           # Seed database with test data
make db-reset       # Reset database schema only
```

### Docker Commands
```bash
# Development (services only)
make db-up          # Start database and Redis containers
make db-down        # Stop development services

# Production (full stack)
make docker-up      # Start complete application with Docker
make docker-down    # Stop all Docker services
make docker-build   # Build Docker images
make docker-logs    # Show all service logs
```

### Code Quality & Testing
```bash
make test           # Run unit tests
make test-e2e       # Run end-to-end tests
make lint           # Run ESLint with auto-fix
make format         # Format code with Prettier
```

### Monitoring & Logs
```bash
make logs           # Show application logs
make db-logs        # Show database logs
make redis-logs     # Show Redis logs
make status         # Show all service status
make clean          # Clean containers and volumes
```

## 📋 Database Management Guide

### Quick Database Reset (Most Common)
```bash
# Complete reset with fresh test data
make reroll
```
This command will:
1. 🗑️ Delete existing database
2. 🏗️ Run all migrations
3. 🌱 Seed with test data
4. ✅ Ready to use with test users

### Individual Database Operations
```bash
# Database lifecycle
make db-up          # Start PostgreSQL and Redis containers
make migrate        # Apply database schema changes
make seed           # Add test data to database
make db-down        # Stop database containers

# Troubleshooting
make db-reset       # Reset schema only (no seeding)
make clean          # Clean all containers and volumes
```

### Test Data Access
After running `make reroll` or `make seed`, you can use these test accounts:

**User 1:**
- **Email**: `john.doe@example.com`
- **Password**: `password123`

**User 2:**
- **Email**: `rofiq@example.com`  
- **Password**: `password123`

## 🎯 API Endpoints

### 🔍 Health & Monitoring
```http
GET /health           # Basic application health check
GET /health/db        # Database connectivity and status
```

### 🔐 Authentication System
```http
POST /auth/register   # User registration
POST /auth/login      # User authentication  
POST /auth/refresh    # Refresh access token
GET /auth/me          # Get current user profile (protected)
POST /auth/logout     # Logout and invalidate token (protected)
```

## � API Usage Examples

### User Registration
```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "full_name": "John Doe",
    "phone_number": "+1234567890",
    "email": "john.doe@example.com", 
    "password": "securePassword123"
  }'
```

### User Login
```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@example.com",
    "password": "securePassword123"
  }'
```

### Access Protected Endpoint
```bash
curl -X GET http://localhost:3000/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### Health Check
```bash
curl http://localhost:3000/health
# Response: {"rc":"SUCCESS","message":"Health check completed successfully",...}
```

## 🗄️ Database Management

### Complete Database Reset (Recommended for Development)
```bash
make reroll  # Delete → Migrate → Seed with fresh test data
```

**What `make reroll` does:**
1. 🗑️ **Delete**: Removes all existing data and schema
2. 🏗️ **Migrate**: Applies all database migrations
3. 🌱 **Seed**: Adds fresh test data
4. ✅ **Ready**: Database ready with test users

### Individual Database Commands
```bash
make db-up       # Start PostgreSQL and Redis containers
make db-down     # Stop database containers  
make migrate     # Run database migrations only
make seed        # Seed database with test data
make db-reset    # Reset database schema only
```

### Test Data
The seed command creates test users:
- **Email**: `john.doe@example.com` | **Password**: `password123`
- **Email**: `rofiq@example.com` | **Password**: `password123`

### Database Connection Strings

**Development (Docker):**
```env
DATABASE_URL="postgresql://mpix_user:mpix_password@localhost:5433/mpix_db"
```

**Production (Docker):**
```env
DATABASE_URL="postgresql://mpix_user:mpix_password@postgres:5432/mpix_db"
```

**Local Installation:**
```env
DATABASE_URL="postgresql://your_user:your_password@localhost:5432/your_database"
```

## 🚨 Troubleshooting Guide

### Docker Issues

**Container Won't Start:**
```bash
# Check container status
docker ps -a
make status

# View logs for specific issues
make docker-logs
docker compose logs postgres
docker compose logs redis
```

**Port Already in Use:**
```bash
# Check what's using the port
netstat -an | findstr :5433    # Windows
netstat -an | grep :5433       # Linux/Mac

# Stop conflicting services
docker stop $(docker ps -q)    # Stop all containers
make clean                      # Clean everything
```

**Database Connection Failed:**
```bash
# Ensure database is running
make db-up
make status

# Check database logs
make db-logs

# Reset if corrupted
make clean
make reroll
```

### Application Issues

**Build Failures:**
```bash
# Clean and reinstall
npm ci
make clean
make docker-build

# Check for missing dependencies
npm audit
npm run build
```

**Permission Errors (Linux/Mac):**
```bash
# Fix Docker permissions
sudo chown -R $USER:$USER .
sudo chmod +x Makefile

# Or run with sudo
sudo make docker-up
```

**Windows-Specific Issues:**
```bash
# Use cross-platform scripts
npm run dev      # Instead of make dev
npm run setup    # Instead of make reroll

# Check Docker Desktop
# Ensure Docker Desktop is running and accessible
```

### Performance Issues

**Slow Database Queries:**
```bash
# Check database performance
make db-logs

# Reset with fresh data
make reroll

# Monitor application logs
make logs
```

**Memory Issues:**
```bash
# Check container memory usage
docker stats

# Restart services
make docker-down
make docker-up
```

## 🔧 Development Commands

### Essential Commands
```bash
make help       # Show all available commands
make install    # Install/update dependencies
make dev        # Start development server with hot reload
make build      # Build for production
make start      # Start production server
```

### Code Quality
```bash
make lint       # Run ESLint with auto-fix
make format     # Format code with Prettier  
make test       # Run unit tests
make test-e2e   # Run end-to-end tests
```

### Docker Operations
```bash
make docker-build    # Build Docker images
make docker-up       # Start all services with Docker (production)
make docker-down     # Stop all Docker services
make docker-logs     # Show all Docker service logs
```

### Service Management
```bash
make logs       # Show application logs
make db-logs    # Show database logs
make status     # Show all service status
make clean      # Clean containers and volumes
```

## ⚡ Performance & Architecture

### Application Performance
- **Framework**: Fastify (high-performance alternative to Express)
- **Database**: Prisma ORM with connection pooling
- **Validation**: Class-validator with transformation pipelines
- **Caching**: Ready for Redis integration
- **Monitoring**: Performance interceptor for request timing

### Database Design
```sql
-- Users table with optimized indexes
CREATE TABLE "users" (
    "id" TEXT PRIMARY KEY,
    "email" TEXT UNIQUE NOT NULL,
    "full_name" TEXT NOT NULL,
    "phone_number" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL
);

-- Refresh tokens for secure auth
CREATE TABLE "refresh_tokens" (
    "id" TEXT PRIMARY KEY,
    "token" TEXT UNIQUE NOT NULL,
    "user_id" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) DEFAULT CURRENT_TIMESTAMP
);
```

### Security Features
- **JWT Authentication**: Secure token-based authentication
- **Password Hashing**: bcrypt with salt rounds (12)
- **CORS**: Configurable cross-origin resource sharing
- **Validation**: Input validation and sanitization
- **Error Handling**: Global exception filter with structured responses

## 🐳 Docker Services Configuration

### Service Overview

| Service | Development | Production | Port | Purpose |
|---------|-------------|------------|------|---------|
| **App** | Local Node.js | Docker Container | 3000 | NestJS Backend |
| **PostgreSQL** | Docker Container | Docker Container | 5433→5432 | Main Database |
| **Redis** | Docker Container | Docker Container | 6379 | Cache & Sessions |

### Development Configuration (`docker-compose.dev.yml`)

**PostgreSQL Database:**
```yaml
postgres:
  image: postgres:15-alpine
  container: mdc_postgres_dev
  port: 5433:5432
  database: mpix_db
  user: mpix_user
  password: mpix_password
  volume: postgres_dev_data
```

**Redis Cache:**
```yaml
redis:
  image: redis:7-alpine
  container: mdc_redis_dev
  port: 6379:6379
  config: appendonly=yes, maxmemory=512mb
  volume: redis_dev_data
```

### Production Configuration (`docker-compose.yml`)

**Complete Stack:**
```yaml
app:
  build: Dockerfile
  container: mdc_backend
  port: 3000:3000
  depends_on: [postgres, redis]
  health_check: /health endpoint

postgres:
  image: postgres:15-alpine
  container: mdc_postgres
  port: 5433:5432
  health_check: pg_isready

redis:
  image: redis:7-alpine
  container: mdc_redis
  port: 6379:6379
  health_check: redis-cli ping
```

### Docker Command Quick Reference

**Development Workflow:**
```bash
# Services only (recommended for development)
docker compose -f docker-compose.dev.yml up -d     # Start DB + Redis
docker compose -f docker-compose.dev.yml down      # Stop services
docker compose -f docker-compose.dev.yml ps        # Check status
docker compose -f docker-compose.dev.yml logs -f   # View logs

# With Makefile shortcuts
make db-up          # Start development services
make db-down        # Stop development services
make status         # Check service status
make db-logs        # View database logs
```

**Production Workflow:**
```bash
# Complete application stack
docker compose up -d --build           # Build and start all services
docker compose down                     # Stop all services
docker compose ps                       # Check status
docker compose logs -f app              # View app logs
docker compose logs -f postgres         # View database logs

# With Makefile shortcuts
make docker-up      # Start production stack
make docker-down    # Stop all services
make docker-build   # Build images
make docker-logs    # View all logs
```

### Without Docker (Local Setup)
If Docker isn't available, see our [Local Setup Guide](docs/LOCAL_SETUP.md) for:
- **Windows**: PostgreSQL + Redis installation
- **macOS**: Homebrew setup instructions  
- **Linux**: APT/YUM package installation
- **Alternatives**: Podman, Rancher Desktop, Colima

```bash
# Quick local setup test
npm run dev  # Auto-detects Docker availability
```

## 🔐 Environment Configuration

### Quick Environment Setup
```bash
# Copy the environment template
cp .env.example .env

# Edit your configuration (see below for mode-specific settings)
nano .env
```

### Configuration Modes

The `.env.example` file provides configurations for three different setups:

#### 🔧 **Development Mode** (Recommended)
- **Use case**: Local development with hot reload
- **Services**: Only database and Redis in Docker
- **App**: Runs locally with Node.js

```env
# Development configuration in .env
NODE_ENV=development
DATABASE_URL="postgresql://mpix_user:mpix_password@localhost:5433/mpix_db?schema=public"
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=dev-secret-key
JWT_REFRESH_SECRET=dev-refresh-secret-key
```

**Commands:**
```bash
make db-up      # Start database and Redis only
make dev        # Start app locally with hot reload
```

#### 🐳 **Production Mode** (Docker Stack)
- **Use case**: Production deployment or testing complete stack
- **Services**: App, database, and Redis all in Docker
- **Networking**: Internal Docker networking

```env
# Production configuration in .env
NODE_ENV=production
DATABASE_URL="postgresql://mpix_user:mpix_password@postgres:5432/mpix_db?schema=public"
REDIS_HOST=redis
REDIS_PORT=6379
JWT_SECRET=your-strong-production-secret
JWT_REFRESH_SECRET=your-strong-refresh-secret
```

**Commands:**
```bash
make docker-up  # Start complete Docker stack
```

#### 💻 **Local Installation Mode**
- **Use case**: PostgreSQL and Redis installed locally (no Docker)
- **Services**: All services run on local machine
- **Networking**: Local networking

```env
# Local installation configuration in .env
NODE_ENV=development
DATABASE_URL="postgresql://your_username:your_password@localhost:5432/your_database?schema=public"
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=your-local-secret-key
JWT_REFRESH_SECRET=your-local-refresh-secret
```

### Required Environment Variables

**Essential Configuration:**
```env
NODE_ENV=development          # Environment mode
PORT=3000                     # Application port
DATABASE_URL="postgresql://..." # Database connection string
JWT_SECRET=your-secret        # JWT signing key
JWT_REFRESH_SECRET=your-refresh-secret # Refresh token key
```

**Redis Configuration:**
```env
REDIS_HOST=localhost          # Redis hostname
REDIS_PORT=6379              # Redis port
REDIS_PASSWORD=              # Redis password (optional)
REDIS_DB=0                   # Redis database number
```

**Security Settings:**
```env
JWT_EXPIRES_IN=15m           # Access token lifetime
JWT_REFRESH_EXPIRES_IN=7d    # Refresh token lifetime
CORS_ORIGIN=*                # CORS allowed origins
THROTTLE_LIMIT=100           # Rate limiting
```

### Environment Templates
The `.env.example` file contains complete examples for all three modes with detailed comments explaining each configuration option.

**Important Security Notes:**
- 🔒 **Always change JWT secrets in production**
- 🔒 **Use strong, unique passwords for database**
- 🔒 **Restrict CORS origins in production**
- 🔒 **Never commit `.env` file to version control**

## 📊 Project Structure

```
src/
├── app.module.ts           # Root application module
├── main.ts                 # Application bootstrap
│
├── auth/                   # Authentication module
│   ├── auth.controller.ts  # Auth endpoints
│   ├── auth.service.ts     # Auth business logic
│   ├── auth.module.ts      # Auth module configuration
│   ├── dto/                # Data transfer objects
│   └── guards/             # JWT authentication guard
│
├── health/                 # Health check module  
│   ├── health.controller.ts
│   ├── health.service.ts
│   └── dto/
│
├── prisma/                 # Database module
│   ├── prisma.service.ts   # Database service
│   └── prisma.module.ts    # Global database module
│
└── common/                 # Shared utilities
    ├── filters/            # Global exception handling
    └── interceptors/       # Performance monitoring

prisma/
├── schema.prisma           # Database schema definition
├── seed.ts                 # Database seeding script
└── migrations/             # Database migration files

config/
├── docker-compose.yml      # Development services
├── Makefile               # Development automation
├── eslint.config.js       # Modern ESLint configuration
├── .prettierrc            # Code formatting rules
└── tsconfig.json          # TypeScript configuration
```

## 🧪 Testing

### Test Setup
```bash
# Run all tests
make test

# Run tests in watch mode  
npm run test:watch

# Run with coverage report
npm run test:cov

# Run end-to-end tests
make test-e2e
```

### Test Structure
- **Unit Tests**: Service and controller testing
- **Integration Tests**: Database and API endpoint testing
- **E2E Tests**: Full application workflow testing

## 🔄 Development Workflow

### 1. **Feature Development**
```bash
# Start development environment
make db-up && make dev

# Make changes to code (auto-reload enabled)
# Test endpoints at http://localhost:3000/docs
```

### 2. **Database Changes**
```bash
# Modify prisma/schema.prisma
# Generate migration
npm run prisma:migrate

# Reset with new schema (development)
make reroll
```

### 3. **Code Quality**
```bash
# Before committing
make lint     # Fix linting issues
make format   # Format code
make test     # Run tests
```

## 🚀 Deployment

### Docker Deployment (Recommended)
```bash
# Build and start production stack
make docker-build
make docker-up

# Check service status
make status

# View logs
make docker-logs
```

### Manual Production Build
```bash
# Build application
make build

# Start production server
make start

# Or with PM2
pm2 start dist/main.js --name "mdc-backend"
```

### Environment Variables for Production
Ensure these are set in your production environment:
```env
NODE_ENV=production
PORT=3000
DATABASE_URL="postgresql://user:password@host:5432/database"
JWT_SECRET="your-strong-production-secret"
JWT_REFRESH_SECRET="your-strong-refresh-secret"
```

## 🤝 Contributing

### Development Guidelines
1. **Fork** the repository
2. **Create** a feature branch: `git checkout -b feature/amazing-feature`
3. **Make** your changes following the code style
4. **Test** your changes: `make test && make lint`
5. **Commit** with clear messages: `git commit -m 'Add amazing feature'`
6. **Push** to your branch: `git push origin feature/amazing-feature`
7. **Submit** a pull request

### Code Standards
- **TypeScript**: Strict typing enabled
- **ESLint**: Modern configuration with TypeScript support
- **Prettier**: Consistent code formatting
- **Conventional Commits**: Clear commit message format

## 📈 Performance Metrics

### Target Performance
- **Response Time**: <100ms (95th percentile)
- **Throughput**: Optimized for high concurrent requests
- **Memory Usage**: <512MB under normal load
- **Database**: Connection pooling for efficient resource usage

### Monitoring
- **Health Checks**: Application and database status monitoring
- **Performance Interceptor**: Request timing and slow query detection
- **Structured Logging**: Comprehensive error tracking and debugging

## 📄 License

This project is licensed under the **UNLICENSED** license - see the [LICENSE](LICENSE) file for details.

## 🔗 Links

- **Repository**: [nestjs-performance-focused](https://github.com/MuhammadAinurR/nestjs-performance-focused)
- **NestJS Documentation**: [https://nestjs.com](https://nestjs.com)
- **Prisma Documentation**: [https://prisma.io](https://prisma.io)
- **Fastify Documentation**: [https://fastify.io](https://fastify.io)
GET /health           # Basic health check
GET /health/db        # Database health check
```

### Authentication
```bash
POST /auth/register   # User registration
POST /auth/login      # User login
POST /auth/refresh    # Refresh access token
```

### Example Requests

**Register User:**
```json
POST /auth/register
{
  "full_name": "Rofiq Rofiq",
  "phone_number": "+6285731966274", 
  "email": "rofiq@example.com",
  "password": "password123"
}
```

**Login:**
```json
POST /auth/login
{
  "email": "john.doe@example.com",
  "password": "password123"
}
```

**Refresh Token:**
```json
POST /auth/refresh
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

## 🗄️ Database Management

The `make reroll` command provides a complete database reset:

```bash
make reroll  # Delete → Create → Migrate → Seed
```

Individual commands:
```bash
make db-up      # Start database containers
make db-down    # Stop database containers
make migrate    # Run migrations only
make seed       # Seed data only
make db-reset   # Reset database only
```

## 🔧 Available Commands

```bash
make help       # Show all available commands
make install    # Install dependencies
make dev        # Start development server
make build      # Build for production
make start      # Start production server
make test       # Run tests
make lint       # Run linting
make format     # Format code
make logs       # Show application logs
make status     # Show service status
```

## ⚡ Performance Optimizations

### Application Level
- **Fastify**: High-performance web framework (vs Express)
- **Redis Caching**: Multi-tier caching strategy
- **Compression**: Gzip compression for responses
- **Rate Limiting**: Multi-tier throttling (100/sec, 500/10sec, 1000/min)
- **Connection Pooling**: Optimized database connections

### Database Level
- **Prisma**: Type-safe ORM with optimized queries
- **Indexes**: Strategic database indexing
- **Connection Management**: Efficient connection pooling

### Monitoring
- **Performance Interceptor**: Request timing and slow query detection
- **Global Exception Handling**: Structured error responses
- **Health Checks**: Application and database monitoring

## 🐳 Docker Services

```yaml
# PostgreSQL Database
postgres:
  - Port: 5432
  - Database: mpix_db
  - User: mpix_user

# Redis Cache
redis:
  - Port: 6379
  - Max Memory: 512MB
  - Policy: allkeys-lru
```

## 🔐 Environment Variables

Copy `.env` and configure:

```env
NODE_ENV=development
PORT=3000
DATABASE_URL="postgresql://mpix_user:mpix_password@localhost:5432/mpix_db"
REDIS_HOST=localhost
REDIS_PORT=6379
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=15m
JWT_REFRESH_SECRET=your-super-secret-refresh-jwt-key
JWT_REFRESH_EXPIRES_IN=7d
```

## 📊 Performance Targets

- **Target RPS**: 100,000 requests per second
- **Response Time**: <100ms (p95)
- **Uptime**: 99.9%
- **Memory Usage**: <512MB under load

## 🧪 Testing

```bash
make test       # Unit tests
make test-e2e   # End-to-end tests
```

## 📚 Project Structure

```
src/
├── auth/           # Authentication module
├── health/         # Health check endpoints
├── prisma/         # Database service
├── common/         # Shared utilities
│   ├── filters/    # Exception filters
│   └── interceptors/ # Performance interceptors
└── main.ts         # Application bootstrap

prisma/
├── schema.prisma   # Database schema
└── seed.ts         # Seed data

docker-compose.yml  # Development services
Makefile           # Development commands
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and linting
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.
