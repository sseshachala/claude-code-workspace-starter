---
name: architecture-review
description: Evaluates proposed system designs against enterprise-grade criteria — scalability, fault tolerance, security posture, and operational runbook existence
---

# Architecture Review Skill

Use before implementing any new service, significant refactor, or cross-service integration.

## Step 1 — Create an ADR First
Before implementation begins, write an Architecture Decision Record at `docs/adr/YYYY-MM-DD-title.md`:

```markdown
# ADR: [Title]

## Status
Proposed | Accepted | Deprecated | Superseded

## Context
[What problem are we solving? What constraints exist?]

## Decision
[What did we decide to do?]

## Consequences
[What becomes easier/harder? What do we take on?]

## Alternatives Considered
[What else did we evaluate and why did we reject it?]
```

## Step 2 — Score the Design (1–5 per axis)

| Axis | Score | Notes |
|---|---|---|
| **Scalability** | /5 | Can this handle 10x current load without redesign? |
| **Observability** | /5 | Metrics, logs, traces — all three present from day one? |
| **Security** | /5 | Threat model documented? Auth, authz, input validation covered? |
| **Cost** | /5 | Cost at scale estimated? Cheaper alternatives evaluated? |
| **Operability** | /5 | Can on-call resolve incidents without the author present? |

Minimum acceptable score per axis: 3. Any axis below 3 is a blocker.

## Step 3 — Distributed Systems Checklist
For any change involving multiple services:
- [ ] What happens if Service B is unavailable when Service A calls it?
- [ ] Is there a circuit breaker / retry with exponential backoff?
- [ ] Are distributed transactions avoided (favor eventual consistency with outbox pattern)?
- [ ] Is the API contract versioned? Can Service B deploy independently?
- [ ] Is there a single point of failure? (Database, message broker, external API)
- [ ] Are idempotency keys implemented for all mutating operations?

## Step 4 — Data Layer Review
- [ ] New DB tables have appropriate indexes for query patterns
- [ ] Migration is backward-compatible (additive only in the first pass)
- [ ] ORM queries reviewed for N+1 problems (use `EXPLAIN ANALYZE`)
- [ ] Connection pooling configured — not opening unbounded connections
- [ ] Sensitive fields are encrypted at the application layer

## Step 5 — Runbook Required
No new service ships without a runbook at `docs/runbooks/<service-name>.md` covering:
- How to deploy
- How to roll back
- How to check if it's healthy
- Known failure modes and how to recover
- On-call escalation path

## Output
```
ARCHITECTURE REVIEW: APPROVED | NEEDS REVISION | BLOCKED

Scores: Scalability[X] Observability[X] Security[X] Cost[X] Operability[X]

Blockers:
- [axis]: [issue] → Required change: [change]

Recommendations:
- [issue] → Suggested improvement: [improvement]

ADR: [created / missing — required before implementation]
Runbook: [created / missing — required before launch]
```
