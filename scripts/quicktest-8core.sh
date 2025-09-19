#!/bin/bash
set -e

echo "🚀 Starting quicktest: API with 8 cores / 8GB RAM + k6 load test"
echo "================================================"

# Clean up any existing container
docker rm -f ultra-nest-api-test-8core 2>/dev/null || true

# Start API in background with resource limits
echo "📦 Starting API container (8 cores, 8GB RAM)..."
docker run -d \
  --name ultra-nest-api-test-8core \
  --cpus=8 \
  --memory=8g \
  -p 3000:3000 \
  ultra-nest-api

echo "⏱️  Waiting for API to be ready..."
# Wait for health endpoint to respond
for i in {1..30}; do
  if curl -s http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ API is ready after ${i}s"
    break
  fi
  if [ $i -eq 30 ]; then
    echo "❌ API failed to start within 30s"
    docker logs ultra-nest-api-test-8core
    docker rm -f ultra-nest-api-test-8core
    exit 1
  fi
  sleep 1
done

echo ""
echo "🔥 Running k6 load test (higher VUs for 8-core setup)..."
echo "================================================"

# Run k6 test with more VUs to utilize additional cores
k6_output=$(docker run --rm \
  -e TARGET_URL=http://host.docker.internal:3000/health \
  -e VUS=120 \
  -e DURATION=15s \
  -v "$PWD":/scripts \
  grafana/k6 run /scripts/k6-health-test.js 2>&1)

# Extract key metrics from k6 output
rps=$(echo "$k6_output" | grep "http_reqs" | awk '{print $3}' | cut -d'/' -f1)
p50=$(echo "$k6_output" | grep "http_req_duration" | head -1 | grep -o "med=[0-9.]*[μm]*s" | cut -d'=' -f2)
p95=$(echo "$k6_output" | grep "p(95)=" | grep -o "p(95)=[0-9.]*[μm]*s" | cut -d'=' -f2)
error_rate=$(echo "$k6_output" | grep "http_req_failed" | awk '{print $3}')

echo ""
echo "📊 QUICKTEST RESULTS (8-CORE)"
echo "================================================"
echo "🔸 Requests per second: $rps"
echo "🔸 Median latency (p50): $p50"
echo "🔸 95th percentile (p95): $p95"
echo "🔸 Error rate: $error_rate"
echo "🔸 Resource limits: 8 CPU cores, 8GB RAM"
echo "🔸 Virtual users: 120"
echo "🔸 Duration: 15s"
echo ""

# Show full k6 output for reference
echo "📋 Full k6 output:"
echo "================================================"
echo "$k6_output"

# Cleanup
echo ""
echo "🧹 Cleaning up..."
docker rm -f ultra-nest-api-test-8core

echo "✅ Quicktest (8-core) completed!"