---
name: change-management
description: Enforces an approval gate workflow for production changes — staged rollout, canary checks, and rollback readiness before promotion
---

# Change Management Skill

Use before any production deployment, schema migration, or infrastructure change.

## Change Classification
| Type | Risk | Approval Required |
|---|---|---|
| Standard | Low — documented, tested, reversible | Team lead sign-off |
| Normal | Medium — new feature, config change | 2 engineers + team lead |
| Emergency | High — production incident mitigation | IC + on-call lead |

## Pre-Deployment Checklist

### Code Readiness
- [ ] All CI checks pass (lint, tests, security scan)
- [ ] PR reviewed and approved by required reviewers
- [ ] JIRA/Linear ticket linked and status updated to "Ready for Deploy"
- [ ] `CHANGELOG.md` updated with this change

### Rollback Readiness (required — no exceptions)
- [ ] Rollback command documented:
  ```bash
  # Application rollback
  kubectl rollout undo deployment/<service> -n production

  # Database rollback (if migration included)
  npm run migrate:down  # or equivalent
  ```
- [ ] Rollback tested in staging
- [ ] Rollback time estimated: [< 5 min / 5–30 min / 30+ min — escalate if 30+]

### Staging Verification
- [ ] Change deployed to staging at least 24 hours before production
- [ ] Smoke tests run on staging
- [ ] Key user flows verified manually: [list the flows]
- [ ] Monitoring shows no anomalies in staging for 4+ hours

## Deployment Strategy by Risk

### Standard (Feature flag or low-risk change)
```
Deploy → Monitor 5 min → Confirm healthy → Done
```

### Normal (New API, schema migration, third-party integration)
```
Deploy to 5% (canary) → Monitor 15 min → 
Check error rate < 0.1% → Promote to 100% → Monitor 30 min
```

### Database Migration (always run separately from code deploy)
```
Step 1: Run additive migration (add column nullable)
Step 2: Deploy new code version
Step 3: Backfill data (separate job, off-peak)
Step 4: Add constraints (separate migration after backfill)
Step 5: Remove old code paths
```

## Post-Deployment Verification
Run within 5 minutes of deploy:
```bash
# Health check
curl -f https://api.yourcompany.com/health

# Key metrics (adjust for your stack)
# Check error rate < 0.5% in last 5 min
# Check p99 latency < SLA threshold
# Check no spike in 5xx responses
```

Stay in #engineering Slack for 30 minutes post-deploy to field issues.

## If Something Goes Wrong
1. Do not debug in production — rollback first
2. Post in #incidents immediately
3. Run `kubectl rollout undo` or equivalent
4. Verify system is healthy after rollback
5. Open an incident ticket and follow the incident-response skill
