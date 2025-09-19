#!/usr/bin/env bash
set -euo pipefail

IMAGE_NAME=${IMAGE_NAME:-ultra-nest-api}
CONTAINER_NAME=${CONTAINER_NAME:-ultra-nest-api-perf}
PORT=${PORT:-3000}
TARGET_URL=${TARGET_URL:-http://host.docker.internal:${PORT}/health}
SUMMARY_FILE=${SUMMARY_FILE:-k6-summary.json}
VUS=${VUS:-30}
DURATION=${DURATION:-10s}
MODE=${MODE:-smoke}
K6_IMAGE=${K6_IMAGE:-grafana/k6}

echo "[perf] Building API image (${IMAGE_NAME})..." >&2
docker build -t "${IMAGE_NAME}" . >/dev/null

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  echo "[perf] Removing existing container ${CONTAINER_NAME}" >&2
  docker rm -f "${CONTAINER_NAME}" >/dev/null || true
fi

echo "[perf] Starting API container..." >&2
docker run -d --name "${CONTAINER_NAME}" -p ${PORT}:3000 "${IMAGE_NAME}" >/dev/null

echo -n "[perf] Waiting for readiness" >&2
for i in {1..30}; do
  if curl -fsS --max-time 1 "http://localhost:${PORT}/health" >/dev/null; then
    echo " OK" >&2
    break
  fi
  sleep 1
  echo -n "." >&2
  if [[ $i -eq 30 ]]; then
    echo " FAILED" >&2
    echo "API did not become ready in time" >&2
    docker logs "${CONTAINER_NAME}" || true
    exit 3
  fi
done

# Small stabilization delay so first k6 requests don't hit during warm-up
sleep 0.5

echo "[perf] Running k6 (VUS=${VUS}, DURATION=${DURATION}) against ${TARGET_URL}" >&2
docker run --rm \
  -e TARGET_URL="${TARGET_URL}" \
  -e VUS="${VUS}" \
  -e DURATION="${DURATION}" \
  -v "$PWD":/scripts \
  "${K6_IMAGE}" run --summary-export /scripts/${SUMMARY_FILE} /scripts/k6-health-test.js >/dev/null || K6_EXIT=$? || true
K6_EXIT=${K6_EXIT:-0}

if [[ ! -f ${SUMMARY_FILE} ]]; then
  echo "[perf] ERROR: k6 summary file not found (${SUMMARY_FILE})" >&2
  docker rm -f "${CONTAINER_NAME}" >/dev/null || true
  exit 4
fi

echo "[perf] Extracting key metrics" >&2

parse_simple() {
  METRIC="$1" KEY="$2" SUMMARY="${SUMMARY_FILE}" node --input-type=module -e "import fs from 'fs';try{const f=JSON.parse(fs.readFileSync(process.env.SUMMARY,'utf8'));const m=f.metrics[process.env.METRIC];if(!m){process.exit(1)}let val; if(m.values){val=m.values[process.env.KEY];} else {val=m[process.env.KEY];} if(val==null){process.exit(1)}process.stdout.write(String(val));}catch{process.exit(1)}" 2>/dev/null || echo NA
}

# For duration percentiles, attempt p(50)/p(90)/p(95); fallback to med / p90 / p95 or NA
P50=$(parse_simple http_req_duration 'p(50)')
[[ "$P50" == "NA" ]] && P50=$(parse_simple http_req_duration 'med')
P90=$(parse_simple http_req_duration 'p(90)')
P95=$(parse_simple http_req_duration 'p(95)')
FAIL_RATE=$(parse_simple http_req_failed 'rate')
RPS=$(parse_simple http_reqs 'rate')

echo "\n===== k6 Summary ====="
echo "Requests/sec      : ${RPS}"
echo "Fail rate         : ${FAIL_RATE}" 
echo "Latency p50 (ms)  : ${P50}"
echo "Latency p90 (ms)  : ${P90}"
echo "Latency p95 (ms)  : ${P95}"
echo "Summary file      : ${SUMMARY_FILE}" 
echo "k6 exit code      : ${K6_EXIT}" 
echo "======================\n"

if [[ ${K6_EXIT} -ne 0 ]]; then
  echo "[perf] k6 exited with non-zero status ${K6_EXIT}" >&2
fi

if [[ "${RPS}" == "NA" ]]; then
  echo "[perf] WARNING: Metrics not captured. Possible causes: no successful requests, TARGET_URL unreachable from k6 container, or k6 summary format change." >&2
  echo "[perf] Troubleshoot: run 'docker logs ${CONTAINER_NAME}' and verify curl from host: curl -v ${TARGET_URL}" >&2
else
  # Provide quick derived throughput summary if data present
  echo "[perf] Derived: ~${RPS%.*} req/s over ${DURATION}" >&2
fi

echo "[perf] Stopping container" >&2
docker rm -f "${CONTAINER_NAME}" >/dev/null || true

exit ${K6_EXIT}
