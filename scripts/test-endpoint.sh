#!/bin/bash
set -e

# Get endpoint from command line argument
ENDPOINT=${1:-/health}
VUS=${VUS:-30}
DURATION=${DURATION:-10s}

# Smart URL detection for different scenarios
if [ -n "$BASE_URL" ]; then
    # User explicitly set BASE_URL
    TARGET_URL="${BASE_URL}${ENDPOINT}"
    CHECK_URL="${BASE_URL}${ENDPOINT}"
elif curl -s --max-time 2 "http://localhost:3000${ENDPOINT}" > /dev/null 2>&1; then
    # API is running on localhost, use localhost for checking but host.docker.internal for k6
    TARGET_URL="http://host.docker.internal:3000${ENDPOINT}"
    CHECK_URL="http://localhost:3000${ENDPOINT}"
else
    # Fallback to host.docker.internal for both
    TARGET_URL="http://host.docker.internal:3000${ENDPOINT}"
    CHECK_URL="http://host.docker.internal:3000${ENDPOINT}"
fi

echo "🔥 Testing endpoint: ${ENDPOINT}"
echo "📍 Target URL: ${TARGET_URL}"
echo "👥 Virtual Users: ${VUS}"
echo "⏱️  Duration: ${DURATION}"
echo "================================================"

# Check if endpoint is reachable
echo "🔍 Checking if endpoint is reachable..."
if ! curl -s --max-time 5 "${CHECK_URL}" > /dev/null 2>&1; then
    echo "❌ Endpoint ${CHECK_URL} is not reachable!"
    echo "💡 Make sure your API is running:"
    echo "   npm run dev    # or"
    echo "   npm run start  # or"
    echo "   docker run -p 3000:3000 ultra-nest-api"
    exit 1
fi

echo "✅ Endpoint is reachable"
echo ""

# Run k6 test
echo "🚀 Running k6 load test..."

# Create temporary file for k6 output
temp_output=$(mktemp)

# Run k6 test with real-time output (no timeout on macOS)
if docker run --rm \
  -e TARGET_URL="${TARGET_URL}" \
  -e VUS="${VUS}" \
  -e DURATION="${DURATION}" \
  -v "$PWD":/scripts \
  grafana/k6 run /scripts/k6-health-test.js 2>&1 | tee "$temp_output"; then
  
  echo ""
  echo "📊 EXTRACTING METRICS..."
  
  # Read output from temp file
  k6_output=$(cat "$temp_output")
  
  # Extract key metrics from k6 output with better regex
  rps=$(echo "$k6_output" | grep "http_reqs" | grep -o "[0-9.]*[0-9]/s" | head -1 | cut -d'/' -f1)
  p50=$(echo "$k6_output" | grep "http_req_duration" | grep -o "med=[0-9.]*[μms]*" | head -1 | cut -d'=' -f2)
  p95=$(echo "$k6_output" | grep "p(95)=" | grep -o "p(95)=[0-9.]*[μms]*" | head -1 | cut -d'=' -f2)
  error_rate=$(echo "$k6_output" | grep "http_req_failed" | grep -o "[0-9.]*%" | head -1)
  
  echo ""
  echo "📊 TEST RESULTS FOR ${ENDPOINT}"
  echo "================================================"
  echo "🔸 Requests per second: ${rps:-N/A}"
  echo "🔸 Median latency (p50): ${p50:-N/A}"
  echo "🔸 95th percentile (p95): ${p95:-N/A}"
  echo "🔸 Error rate: ${error_rate:-N/A}"
  echo "🔸 Virtual users: ${VUS}"
  echo "🔸 Duration: ${DURATION}"
  echo "🔸 Target: ${TARGET_URL}"
  
else
  echo ""
  echo "❌ k6 test failed!"
  echo "📋 Output:"
  cat "$temp_output" 2>/dev/null || echo "No output captured"
fi

# Clean up temp file
rm -f "$temp_output"

echo ""
echo "✅ Test completed for ${ENDPOINT}!"