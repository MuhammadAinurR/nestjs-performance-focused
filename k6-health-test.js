import http from 'k6/http';
import { check } from 'k6';

export const options = {
  vus: Number(__ENV.VUS || 30),
  duration: __ENV.DURATION || '10s',
  thresholds: {
    http_req_failed: ['rate<0.001'],
    http_req_duration: [
      'p(50)<8',
      'p(90)<20',
      'p(95)<30'
    ]
  }
};

const URL = __ENV.TARGET_URL || 'http://localhost:3000/health';

export default function () {
  const res = http.get(URL, { tags: { endpoint: 'health' } });
  let okFlag = false;
  try { okFlag = res.body && res.json('status') === 'ok'; } catch { okFlag = false; }
  check(res, {
    'status 200': r => r.status === 200,
    'body status ok': _ => okFlag
  });
}
