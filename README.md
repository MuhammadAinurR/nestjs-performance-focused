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

### 1. **Clone and Install**
```bash
git clone https://github.com/MuhammadAinurR/nestjs-performance-focused.git
cd backend
npm install
```

### 2. **Environment Setup**
```bash
# Copy environment template
cp .env.example .env

# Edit configuration (update database credentials, JWT secrets, etc.)
nano .env
```

**Important**: Update the following in your `.env` file:
- `DATABASE_URL`: Your PostgreSQL connection string
- `JWT_SECRET` & `JWT_REFRESH_SECRET`: Strong, unique secrets for production
- `DB_USER`, `DB_PASSWORD`, `DB_NAME`: Your database credentials

### 3. **Database Setup**
```bash
# Start database services
make db-up

# Initialize database with fresh data
make reroll
```

### 4. **Start Development**
```bash
# Start development server with hot reload
make dev
```

**🎉 Your API is now running!**
- **API Base**: http://localhost:3000
- **Swagger Documentation**: http://localhost:3000/docs
- **Health Check**: http://localhost:3000/health

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

## 🐳 Docker Configuration

### Services
```yaml
## 🐳 Docker Configuration

### Development vs Production

**Development** (`docker-compose.dev.yml`):
- Only database and Redis services
- Your app runs locally with `make dev`
- Optimized for development workflow

**Production** (`docker-compose.yml`):
- Complete application stack
- App, database, and Redis all containerized
- Ready for deployment

### Services
```yaml
# Application (Production only)
app:
  image: mdc-backend:latest
  port: 3000:3000
  
# PostgreSQL Database  
postgres:
  image: postgres:15-alpine
  port: 5433:5432
  database: mpix_db
  
# Redis Cache
redis:
  image: redis:7-alpine  
  port: 6379:6379
  max_memory: 512mb
```

### Quick Commands
```bash
# Development (services only)
make db-up        # Start database & Redis
make db-down      # Stop services

# Production (full stack)
make docker-up    # Start complete application
make docker-down  # Stop all services
make docker-build # Build application image
```

### Environment Variables for Docker
When running with Docker, the application uses these environment variables:
```env
DATABASE_URL="postgresql://mpix_user:mpix_password@postgres:5432/mpix_db"
REDIS_HOST=redis
REDIS_PORT=6379
```
```

### Commands
```bash
# Start all services
docker-compose up -d

# View service status
docker-compose ps

# View logs
docker-compose logs -f postgres
```

## 🔐 Environment Configuration

### Quick Setup
```bash
# Copy the environment template
cp .env.example .env

# Edit your configuration
nano .env
```

### Required Environment Variables
The `.env.example` file contains all necessary environment variables with documentation. Key variables to configure:

```env
# Application
NODE_ENV=development
PORT=3000

# Database (Local Development)
DATABASE_URL="postgresql://your_db_user:your_db_password@localhost:5432/mdcn"

# Database (Docker Development)  
DATABASE_URL="postgresql://mpix_user:mpix_password@localhost:5433/mpix_db"

# JWT Security (CHANGE IN PRODUCTION!)
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_REFRESH_SECRET=your-super-secret-refresh-jwt-key-change-in-production
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d
```

### Environment Templates
- **`.env.example`**: Complete template with all available options
- **`.env`**: Your local configuration (git-ignored)
- **Docker**: Environment variables are configured in docker-compose.yml

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
