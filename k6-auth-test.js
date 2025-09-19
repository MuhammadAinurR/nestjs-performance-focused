import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '10s', target: parseInt(__ENV.VUS) || 10 },
    { duration: (__ENV.DURATION || '30s'), target: parseInt(__ENV.VUS) || 10 },
    { duration: '5s', target: 0 },
  ],
};

const BASE_URL = __ENV.TARGET_URL || 'http://localhost:3000';

// Test data
const testUser = {
  fullName: `Test User ${Date.now()}`,
  phoneNumber: `+123456${Math.floor(Math.random() * 10000)}`,
  email: `test${Date.now()}@example.com`,
  password: 'password123'
};

export default function () {
  const endpoint = __ENV.ENDPOINT || '/auth/register';
  
  let url = `${BASE_URL}${endpoint}`;
  let payload = {};
  let params = {
    headers: {
      'Content-Type': 'application/json',
    },
  };

  // Configure payload based on endpoint
  if (endpoint.includes('/auth/register')) {
    payload = JSON.stringify(testUser);
  } else if (endpoint.includes('/auth/login')) {
    payload = JSON.stringify({
      email: 'john.doe@example.com',
      password: 'password123'
    });
  } else if (endpoint.includes('/health')) {
    // For health endpoint, just do GET request
    const res = http.get(url);
    check(res, {
      'status is 200': (r) => r.status === 200,
      'response time < 50ms': (r) => r.timings.duration < 50,
    });
    return;
  }

  // For POST endpoints
  const res = http.post(url, payload, params);
  
  check(res, {
    'status is 200 or 201': (r) => r.status === 200 || r.status === 201 || r.status === 409,
    'response time < 100ms': (r) => r.timings.duration < 100,
    'has success field': (r) => {
      try {
        const body = JSON.parse(r.body);
        return body.hasOwnProperty('success');
      } catch {
        return false;
      }
    },
  });

  sleep(0.1);
}