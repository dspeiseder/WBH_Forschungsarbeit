import http from 'k6/http';
import { check } from 'k6';
import { Trend, Rate } from 'k6/metrics';

// ------- configuration over eco variables -------

const BASE_URL = __ENV.BASE_URL || 'http://localhost:8080';
const VARIANT = __ENV.VARIANT || 'imperative'; // 'imperative' or 'reactive'
const MIN_ID = __ENV.MIN_ID ? parseInt(__ENV.MIN_ID) : 1;
const MAX_ID = __ENV.MAX_ID ? parseInt(__ENV.MAX_ID) : 1000;

const RPS = __ENV.RPS ? parseInt(__ENV.RPS) : 100;      // requests per second
const DURATION = __ENV.DURATION || '10m';               // e.g. '3m', '10m'
const PRE_VUS = __ENV.VUS ? parseInt(__ENV.VUS) : 50;   // vorallozierte VUs?????????
const MAX_VUS = __ENV.MAX_VUS ? parseInt(__ENV.MAX_VUS) : 100;

// ------- k6-options: constant request-Rate -------

export const options = {
  scenarios: {
    constant_rps: {
      executor: 'constant-arrival-rate',
      rate: RPS,
      timeUnit: '1s',
      duration: DURATION,
      preAllocatedVUs: PRE_VUS,
      maxVUs: MAX_VUS,
    },
  },
};

// ------- own metrics (optional, additional to standard metric) -------

const latency = new Trend('latency_ms');
const successRate = new Rate('success_rate');

// ------- test function -------

export default function () {
  const id =
    Math.floor(Math.random() * (MAX_ID - MIN_ID + 1)) + MIN_ID;
  const url = `${BASE_URL}/${VARIANT}/items/${id}`;

  const res = http.get(url, {
    tags: { variant: VARIANT },
  });

  latency.add(res.timings.duration, { variant: VARIANT });
  successRate.add(res.status === 200, { variant: VARIANT });

  check(res, {
    'Status is 200': (r) => r.status === 200,
  });
}
