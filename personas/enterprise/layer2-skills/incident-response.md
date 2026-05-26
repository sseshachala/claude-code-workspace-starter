---
name: incident-response
description: Guides Claude through a structured P1/P2 incident response — triage, mitigation, root cause analysis, and post-mortem writing
---

# Incident Response Skill

## Severity Classification
| Severity | Criteria | Response SLA |
|---|---|---|
| P1 — Critical | Production down, data loss, security breach | 15 min response, 4hr resolution |
| P2 — Major | Core feature broken, >10% users affected | 1hr response, 8hr resolution |
| P3 — Minor | Degraded performance, single-user issue | 4hr response, 24hr resolution |

## Phase 1 — Declare & Assemble (0–5 min)
1. Post in #incidents Slack: `🔴 P[X] INCIDENT: [one-line description]. IC: @[your name]`
2. Assign roles: Incident Commander (IC), Communications Lead, Technical Lead
3. Open incident bridge (Zoom / Meet)
4. Create incident ticket with timestamp

## Phase 2 — Triage (5–15 min)
Run these diagnostics immediately:

```bash
# Check error rates
kubectl logs -n production -l app=<service> --tail=100 | grep ERROR

# Check recent deployments
kubectl rollout history deployment/<service> -n production

# Check database health
psql $DATABASE_URL -c "SELECT count(*), state FROM pg_stat_activity GROUP BY state;"

# Check upstream dependencies
curl -s https://status.stripe.com/api/v2/status.json | jq .status.description
```

Answer:
- What is broken? (feature, service, data)
- Who is affected? (all users, subset, specific tenant)
- When did it start? (check deploy history, alerting timestamps)
- What changed recently? (`git log --since="2 hours ago" --oneline`)

## Phase 3 — Mitigate First (before root cause)
Apply the fastest mitigation available:
1. **Rollback**: `kubectl rollout undo deployment/<service>` — always try this first
2. **Feature flag**: disable the broken feature if flagged
3. **Scale up**: `kubectl scale deployment/<service> --replicas=N` if load-related
4. **Circuit break**: enable circuit breaker to degrade gracefully
5. **DNS failover**: switch traffic to DR environment if catastrophic

## Phase 4 — Root Cause Analysis
Only after mitigation is stable:
- Identify the exact commit / deployment / config change that caused the incident
- Reproduce in staging if possible
- Fix the root cause (not the symptom)
- Write tests that would have caught this

## Phase 5 — Post-Mortem (within 48 hours)
Write to `docs/post-mortems/YYYY-MM-DD-title.md`:

```markdown
# Post-Mortem: [Title]
**Date**: [YYYY-MM-DD]
**Severity**: P[X]
**Duration**: [X hours Y minutes]
**Author**: [name]

## Impact
[Who was affected, what was unavailable, estimated business impact]

## Timeline
- HH:MM — [event]
- HH:MM — [detection]
- HH:MM — [mitigation applied]
- HH:MM — [incident resolved]

## Root Cause
[Exact technical cause]

## Contributing Factors
[What made this possible / why it wasn't caught earlier]

## What Went Well
[Things that helped resolve it faster]

## Action Items
| Action | Owner | Due Date |
|---|---|---|
| [prevention] | [@person] | [date] |
| [detection] | [@person] | [date] |
```

**Blameless principle**: Post-mortems identify system failures, not individual failures.
