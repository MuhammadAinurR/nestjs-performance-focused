#!/usr/bin/env bash
set -euo pipefail

TARGET_URL="${TARGET_URL:-http://host.docker.internal:3000/health}"
MODE="${MODE:-smoke}"

echo "[k6-run] Target: $TARGET_URL" >&2

echo -n "[k6-run] Connectivity check... "
if curl -fsS --max-time 2 "$TARGET_URL" >/dev/null; then
  echo "OK"
else
  echo "FAILED"
  cat <<EOF >&2
[k6-run] Cannot reach $TARGET_URL
Troubleshooting:
  1. Is the API running?  (try: curl -v http://localhost:3000/health)
  2. If API is in Docker, use a user-defined network and service name, e.g.:
       docker network create perf-net || true
       docker run -d --name api --network perf-net ultra-nest-api
       TARGET_URL=http://api:3000/health npm run perf:k6
  3. On macOS, host.docker.internal maps to the host; ensure the server is not inside another container with no published port.
  4. Verify something listens: (lsof -nP -iTCP:3000 | grep LISTEN) or (docker ps).
Aborting.
EOF
  exit 2
fi

echo "[k6-run] Launching k6 ($MODE) ..." >&2

DOCKER_IMAGE="grafana/k6"

if [[ "$MODE" == "heavy" ]]; then
  HEAVY_ENV="-e HEAVY=true -e RATE -e PREALLOC -e MAX_VUS -e HEAVY_DURATION -e HEAVY_START"
else
  HEAVY_ENV=""
fi

exec docker run --rm \
  -e TARGET_URL="$TARGET_URL" \
  -e VUS -e DURATION $HEAVY_ENV \
  -v "$PWD":/scripts \
  "$DOCKER_IMAGE" run /scripts/k6-health-test.js
