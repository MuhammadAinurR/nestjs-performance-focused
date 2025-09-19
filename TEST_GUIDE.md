# Test Guide

Complete testing documentation for the Ultra Minimal High-Performance NestJS API.

## Available Test Commands

### 1. Basic Endpoint Testing
```bash
# Test any endpoint against running API
npm run test /health
npm run test /profile
npm run test /api/users

# With custom parameters
VUS=50 DURATION=15s npm run test /health
BASE_URL=http://localhost:8080 npm run test /health
```

**What it does:**
- Checks if endpoint is reachable
- Runs k6 load test with configurable parameters
- Shows summary metrics (RPS, latency, error rate)
- Works against any running API instance

### 2. Quick Docker Tests
```bash
# Test with 1 core / 1GB RAM limits
npm run quicktest

# Test with 8 cores / 8GB RAM limits  
npm run quicktest:8core
```

**What it does:**
- Builds Docker image
- Starts containerized API with resource limits
- Runs k6 load test against container
- Shows performance metrics
- Cleans up automatically

### 3. Manual Performance Test
```bash
# Direct k6 against running API
npm run perf:health

# With custom parameters
VUS=100 DURATION=30s TARGET_URL=http://localhost:3000/health npm run perf:health
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BASE_URL` | `http://localhost:3000` | Base server URL for endpoint tests |
| `TARGET_URL` | `http://host.docker.internal:3000/health` | Full URL for perf tests |
| `VUS` | `30` | Number of virtual users |
| `DURATION` | `10s` | Test duration |

## Test Scenarios

### Development Workflow
```bash
# 1. Start API in dev mode
npm run dev

# 2. Test specific endpoints
npm run test /health
npm run test /profile

# 3. Performance check
VUS=50 DURATION=20s npm run test /health
```

### Docker Performance Testing
```bash
# Quick 1-core baseline
npm run quicktest

# Scale up to 8-core
npm run quicktest:8core

# Compare results
```

### CI/CD Integration
```bash
# Automated build + test
npm run quicktest:build
docker run -d --name api-test -p 3000:3000 ultra-nest-api
sleep 2
npm run test /health
docker rm -f api-test
```

## Understanding Results

### Key Metrics
- **RPS (Requests/Second)**: Total throughput
- **p50 (Median)**: Typical response time
- **p95**: 95th percentile latency (SLA indicator)
- **Error Rate**: Failed requests percentage

### Example Output
```
📊 TEST RESULTS FOR /health
================================================
🔸 Requests per second: 13667
🔸 Median latency (p50): 1.88ms
🔸 95th percentile (p95): 3.33ms  
🔸 Error rate: 0.00%
🔸 Virtual users: 30
🔸 Duration: 10s
```

### Performance Expectations

| Configuration | Expected RPS | Typical p50 | Notes |
|---------------|--------------|-------------|-------|
| Local dev | 20k-25k | 1-2ms | Host machine, no limits |
| Docker 1-core | 12k-15k | 2-3ms | Resource constrained |
| Docker 8-core | 12k-15k | 2-8ms | Single Node process limitation |

## Troubleshooting

### Connection Refused
```bash
# Check if API is running
curl -v http://localhost:3000/health

# Start API first
npm run dev  # or npm run start
```

### Docker Network Issues (macOS)
```bash
# Use host.docker.internal for containerized k6
TARGET_URL=http://host.docker.internal:3000/health npm run perf:health

# Or run both in same network
docker network create test-net
docker run -d --name api --network test-net ultra-nest-api
docker run --rm --network test-net -e TARGET_URL=http://api:3000/health -v $PWD:/scripts grafana/k6 run /scripts/k6-health-test.js
```

### Low Performance
```bash
# Check system resources
docker stats

# Monitor API logs
docker logs ultra-nest-api-test

# Increase test load gradually
VUS=10 npm run test /health
VUS=30 npm run test /health  
VUS=50 npm run test /health
```

## Advanced Testing

### Custom k6 Script
Modify `k6-health-test.js` for:
- Different request patterns
- POST/PUT testing
- Authentication headers
- Custom thresholds

### Load Testing Best Practices
1. **Start Small**: Begin with low VU counts
2. **Gradual Increase**: Scale up to find breaking point
3. **Monitor Resources**: Watch CPU, memory, network
4. **Multiple Runs**: Average results across runs
5. **Realistic Scenarios**: Match production patterns

### Scaling Beyond Single Process
For 100k+ RPS targets:
```bash
# Cluster mode (multiple processes)
npm install -g pm2
pm2 start dist/main.js -i max

# Multiple containers + load balancer
docker-compose up --scale api=4
```

## Test Files Structure
```
scripts/
├── quicktest.sh           # 1-core containerized test
├── quicktest-8core.sh     # 8-core containerized test  
└── test-endpoint.sh       # Flexible endpoint testing

k6-health-test.js          # k6 load test script
```

## Integration Examples

### GitHub Actions
```yaml
- name: Performance Test
  run: |
    npm run quicktest:build
    timeout 60 npm run quicktest:run || exit 1
```

### Docker Compose
```yaml
services:
  api:
    build: .
    ports: ["3000:3000"]
  
  k6:
    image: grafana/k6
    command: run /scripts/k6-health-test.js
    environment:
      - TARGET_URL=http://api:3000/health
    volumes:
      - .:/scripts
    depends_on:
      - api
```

## Performance Tuning Tips

1. **Resource Limits**: Test with production-like constraints
2. **Keep-Alive**: Ensure HTTP keep-alive is enabled
3. **Payload Size**: Monitor request/response sizes
4. **Event Loop**: Check for blocking operations
5. **Memory**: Watch for memory leaks in longer tests

For more details, see `BEST_PRACTICES.md`.