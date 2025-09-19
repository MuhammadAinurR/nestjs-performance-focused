# Ultra Minimal High-Performance NestJS API

Lightweight NestJS 10 + Fastify service with modular architecture. Optimized for small footprint, fast cold start, and scalable development.

## Project Structure

```
src/
├── app.module.ts              # Root application module
├── main.ts                    # Application bootstrap
├── config/                    # Configuration management
│   ├── index.ts              # Barrel export
│   └── app.config.ts         # App configuration with env support
└── modules/                   # Feature modules
    ├── index.ts              # Barrel export for modules
    └── health/               # Health check feature
        ├── index.ts          # Barrel export
        ├── health.controller.ts
        └── health.module.ts
```

## Quick Start (Local)
```bash
npm install
npm run dev        # Fast reload dev server on :3000 (configurable via PORT env)
# or production build
npm run build && NODE_ENV=production node dist/main.js
```

Check health:
```bash
curl -s http://localhost:3000/health | jq
```

Example response:
```json
{"status":"ok","version":"0.1.0","ts":1690000000000,"uptime":0.523,"started":0.012}
```

## Flexible Endpoint Testing
Test any endpoint with configurable load:
```bash
# Test existing endpoints
npm run test /health

# Test future endpoints
npm run test /users
npm run test /api/profile

# Custom load testing
VUS=50 DURATION=15s npm run test /health
BASE_URL=http://localhost:8080 npm run test /api/status
```

## Docker (1 core / 1 GB limit example)
```bash
docker build -t ultra-nest-api .
docker run --rm -p 3000:3000 --cpus=1 --memory=1g ultra-nest-api
```

## Minimal k6 Load Test
One constant-VUs scenario (defaults baked into script):
```bash
# Run (defaults: VUS=30, DURATION=10s, TARGET_URL=http://host.docker.internal:3000/health)
npm run perf:health

# Override parameters
VUS=60 DURATION=25s TARGET_URL=http://127.0.0.1:3000/health npm run perf:health
```
Direct Docker (without npm script):
```bash
docker run --rm \
  -e TARGET_URL=http://host.docker.internal:3000/health \
  -e VUS=40 -e DURATION=15s \
  -v "$PWD":/scripts grafana/k6 run /scripts/k6-health-test.js
```

macOS note: When the API runs on the host, use `host.docker.internal` inside the k6 container. If both API and k6 are containers:
```bash
docker network create perf-net || true
docker run -d --name api --network perf-net ultra-nest-api
docker run --rm --network perf-net -e TARGET_URL=http://api:3000/health -v "$PWD":/scripts grafana/k6 run /scripts/k6-health-test.js
```

Thresholds (inside script) will fail the run if error rate > 0 or if latency percentiles exceed configured bounds.

## Performance Guidelines (Applied / Suggested)
- Fastify adapter (lower overhead than Express)
- Disabled Nest default verbose logging
- Lean JSON payload (flat constant keys)
- No class-transformer / class-validator overhead
- Multi-stage Docker build, pruned dev deps
- Use horizontal scaling to push beyond single-instance limits

Monitoring ideas (add only when needed): pino logging, Prometheus (fastify-metrics), OpenTelemetry traces, event loop lag sampling.

## Environment Configuration
```bash
# Development
PORT=3000 npm run dev

# Production
NODE_ENV=production PORT=8080 npm run start

# Docker
PORT=3000 UV_THREADPOOL_SIZE=4 npm run start
```

## Adding New Endpoints

### 1. Create a New Module
```bash
# Create module directory
mkdir -p src/modules/users

# Create module files
touch src/modules/users/users.controller.ts
touch src/modules/users/users.module.ts
touch src/modules/users/index.ts
```

### 2. Controller Implementation
```typescript
// src/modules/users/users.controller.ts
import { Controller, Get, Post, Body, Param } from '@nestjs/common';

@Controller('users')
export class UsersController {
  @Get()
  findAll() {
    return { users: [], total: 0 };
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return { id, name: 'John Doe', email: 'john@example.com' };
  }

  @Post()
  create(@Body() createUserDto: any) {
    return { id: '123', ...createUserDto, created: new Date() };
  }
}
```

### 3. Module Definition
```typescript
// src/modules/users/users.module.ts
import { Module } from '@nestjs/common';
import { UsersController } from './users.controller.js';

@Module({
  controllers: [UsersController]
})
export class UsersModule {}
```

### 4. Barrel Export
```typescript
// src/modules/users/index.ts
export * from './users.controller.js';
export * from './users.module.js';
```

### 5. Register in Main Module
```typescript
// src/modules/index.ts
export * from './health/index.js';
export * from './users/index.js';  // Add this line
```

```typescript
// src/app.module.ts
import { Module } from '@nestjs/common';
import { HealthModule, UsersModule } from './modules/index.js';  // Import new module

@Module({
  imports: [HealthModule, UsersModule]  // Register new module
})
export class AppModule {}
```

### 6. Test Your New Endpoints
```bash
# Build and start
npm run build && npm run start

# Test endpoints
curl http://localhost:3000/users
curl http://localhost:3000/users/123
curl -X POST http://localhost:3000/users -H "Content-Type: application/json" -d '{"name":"Jane","email":"jane@example.com"}'

# Load test
npm run test /users
npm run test /users/123
```

## Testing New Endpoints

The flexible testing system works with any endpoint:

```bash
# Quick smoke test
npm run test /users

# Heavy load test
VUS=100 DURATION=30s npm run test /api/heavy-endpoint

# Different environments
BASE_URL=https://staging.example.com npm run test /health
```

See `TEST_GUIDE.md` for comprehensive testing documentation.

## Best Practices for New Modules

### **1. Follow the Module Pattern**
```
src/modules/[feature]/
├── index.ts              # Barrel export
├── [feature].controller.ts
├── [feature].service.ts  # Business logic (optional)
├── [feature].module.ts
└── dto/                  # Data transfer objects (optional)
    ├── create-[feature].dto.ts
    └── update-[feature].dto.ts
```

### **2. Use Dependency Injection**
```typescript
// users.service.ts
import { Injectable } from '@nestjs/common';

@Injectable()
export class UsersService {
  findAll() {
    return { users: [], total: 0 };
  }
}

// users.controller.ts
import { Controller, Get } from '@nestjs/common';
import { UsersService } from './users.service.js';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get()
  findAll() {
    return this.usersService.findAll();
  }
}

// users.module.ts
import { Module } from '@nestjs/common';
import { UsersController } from './users.controller.js';
import { UsersService } from './users.service.js';

@Module({
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService]  // Export if used by other modules
})
export class UsersModule {}
```

### **3. Configuration Integration**
```typescript
// In your controller/service
import { APP_VERSION, config } from '../../config/index.js';

@Controller('api')
export class ApiController {
  @Get('info')
  getInfo() {
    return {
      version: APP_VERSION,
      environment: config.environment,
      port: config.app.port
    };
  }
}
```

### **4. Performance Considerations**
- Keep controllers thin, move logic to services
- Use appropriate HTTP status codes
- Implement proper error handling
- Consider caching for expensive operations
- Use streaming for large responses

## Env Suggestions
```bash
NODE_ENV=production
UV_THREADPOOL_SIZE=4   # increase only for heavy fs/crypto
```

## Security Hardening (Container)
- Run as non-root (implemented in Dockerfile)
- Add `--read-only` and necessary `tmpfs` mounts if filesystem immutability desired
- Drop capabilities: `--cap-drop ALL`
- Resource limits as shown above

## Future (Optional) Enhancements
- Autocannon script for quick CLI benchmarking
- Basic metrics endpoint
- Graceful shutdown timings & readiness probe examples

## License
Internal / TBD

## Related Documentation
- `TEST_GUIDE.md` - Comprehensive testing guide
- `BEST_PRACTICES.md` - Performance optimization tips  
- `CLEANUP_SUMMARY.md` - Recent codebase improvements
