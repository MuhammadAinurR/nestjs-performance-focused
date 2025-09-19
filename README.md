# MPIX Backend - High Performance NestJS API

A high-performance NestJS backend targeting 100k RPS with PostgreSQL, Redis, and JWT authentication.

## 🚀 Features

- **High Performance**: Built with Fastify, Redis caching, and optimized middleware
- **Authentication**: JWT-based auth with refresh tokens and Redis session management
- **Database**: PostgreSQL with Prisma ORM for type-safe database operations
- **Health Checks**: Comprehensive health monitoring endpoints
- **Rate Limiting**: Multi-tier throttling for DDoS protection
- **Docker Support**: Containerized PostgreSQL and Redis for development
- **Type Safety**: Full TypeScript support with strict typing
- **API Documentation**: Auto-generated Swagger/OpenAPI docs

## 📋 Prerequisites

- Node.js 18+ 
- npm or yarn
- Docker and Docker Compose
- Make (for Makefile commands)

## 🛠️ Quick Start

1. **Clone and Install**
   ```bash
   git clone <repository-url>
   cd backend
   npm install
   ```

2. **Start Services**
   ```bash
   make db-up    # Start PostgreSQL and Redis
   make reroll   # Reset and seed database
   ```

3. **Start Development Server**
   ```bash
   make dev      # Start with hot reload
   ```

The API will be available at:
- **API**: http://localhost:3000
- **Swagger Docs**: http://localhost:3000/docs

## 🎯 API Endpoints

### Health Endpoints
```bash
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
