---
name: sla-tracker
description: Monitors and surfaces SLA compliance for APIs and services — tracks p99 latency, error rates, and uptime targets inline during development
---

# SLA Tracker Skill

Use when modifying API handlers, adding database queries, or designing new endpoints.

## SLA Targets Reference
Define your SLAs in `docs/sla-targets.json`. Default template:
```json
{
  "api": {
    "p99_latency_ms": 500,
    "p95_latency_ms": 200,
    "error_rate_percent": 0.1,
    "uptime_percent": 99.9
  },
  "database": {
    "query_p99_ms": 100,
    "connection_timeout_ms": 3000
  },
  "background_jobs": {
    "p99_duration_seconds": 30,
    "failure_rate_percent": 1.0
  }
}
```

## When Adding a New Endpoint
Before implementation, estimate and document:

```markdown
## SLA Pre-Assessment: POST /api/v1/[resource]

Expected load    : [X RPS at peak]
DB queries       : [N queries per request]
External calls   : [list any third-party APIs]
Estimated p99    : [Xms]
SLA target p99   : [Xms from sla-targets.json]
Compliant?       : [YES / NO — if NO, explain mitigation]

Required mitigations:
- [ ] Add DB index on: [columns]
- [ ] Add caching layer: [strategy]
- [ ] Add request timeout: [Xms]
- [ ] Add circuit breaker for: [service]
```

## When Modifying an Existing Endpoint
1. Check current p99 from observability platform (Datadog / New Relic / Grafana)
2. Estimate impact of your change (does it add DB queries? external calls?)
3. If estimated p99 > SLA target — add index, caching, or async offloading before shipping

## Load Test Requirement
Required for any endpoint expected at > 1000 RPS:
```bash
# k6 load test template
k6 run --vus 100 --duration 60s tests/load/[endpoint].js

# Acceptance criteria
# p99 < [SLA target]ms
# Error rate < 0.1%
# No memory leaks over 10-minute sustained run
```

## SLA Compliance Report
```
SLA COMPLIANCE CHECK: [endpoint]
══════════════════════════════════
Current p99      : [Xms] [✓ within SLA / ⚠️ exceeds SLA]
Error rate       : [X%]  [✓ within SLA / ⚠️ exceeds SLA]
DB queries/req   : [N]   [✓ acceptable / ⚠️ N+1 detected]
External calls   : [N]   [✓ cached / ⚠️ uncached]

VERDICT: COMPLIANT | NEEDS OPTIMIZATION before shipping
```
