# Enterprise Workspace — CLAUDE.md

> This file is always loaded. It is your operating constitution for this project.
> Edit the sections below to match your specific organization before your first session.

---

## Project Identity
- **Organization**: [Your Company Name]
- **Product**: [Multi-tenant SaaS / Regulated B2B Platform / Internal Platform]
- **Industry**: [Financial Services / Healthcare / Legal / Enterprise SaaS]
- **Compliance requirements**: SOC 2 Type II, [GDPR / HIPAA / ISO 27001 — choose applicable]
- **Current sprint focus**: [e.g., "Q3: Payments refactor + SSO rollout"]

---

## Architecture
- **Stack**: TypeScript, Node.js, PostgreSQL, Redis, Kubernetes
- **Repo structure**: Monorepo — `/services`, `/packages`, `/platform`, `/docs`
- **Service communication**: gRPC internally, REST externally
- **Auth**: OAuth2 + SAML SSO via [Okta / Auth0]
- **Infra**: AWS / GCP / Azure — [specify your cloud]

---

## Mandatory Rules (Non-Negotiable)

### Security
- NEVER commit secrets, API keys, or credentials — use Vault / AWS Secrets Manager
- NEVER disable SSL verification in any environment
- ALL new API endpoints require auth middleware — no unauthenticated routes
- Run `npm audit --audit-level=high` before every PR — block on CVSS 7+

### Data & Compliance
- ALL PII fields must be encrypted at rest using AES-256
- ALL database write operations must emit an audit log entry
- NO raw SQL — use the ORM (Prisma / TypeORM / SQLAlchemy) at all times
- Data retention: follow the policy in `/docs/data-retention-policy.md`

### Code Quality
- TypeScript strict mode — `strict: true` in tsconfig
- Minimum 80% test coverage — enforced in CI
- Every PR requires: passing tests + passing lint + a JIRA ticket reference

### Commits & PRs
- Commit message format: `type(scope): message [JIRA-XXXX]`
- No direct pushes to `main` or `production` — all changes via PR
- Two reviewers required for changes to: auth, billing, migrations, infra

---

## Naming Conventions
- Services: `<domain>-<function>-service` (e.g., `auth-sso-service`)
- Packages: `@company/<name>` (e.g., `@company/audit-logger`)
- DB tables: `snake_case`, pluralized (e.g., `user_sessions`)
- Env vars: `COMPANY_<DOMAIN>_<KEY>` (e.g., `COMPANY_AUTH_SECRET`)
- Branch names: `feat/JIRA-123-short-description` or `fix/JIRA-456-short-description`

---

## Test Expectations
- Unit tests: every service function with external calls mocked
- Integration tests: every API endpoint against a real test DB
- E2E tests: auth flows, billing flows, onboarding — run before each release
- Load tests: required before launching any endpoint expected at 1k+ RPS

---

## Architecture Decision Records
All significant technical decisions are documented in `/docs/adr/`. Before proposing a new pattern, check if an ADR already addresses it. When introducing a new pattern, create an ADR first.

---

## Change Calendar
Production changes are restricted to:
- **Allowed**: Tuesday–Thursday, 10am–3pm [timezone]
- **Blocked**: Fridays, weekends, and dates in `/docs/change-freeze-calendar.md`

---

## Repo Map
```
/services          → microservices (each owns its own DB schema)
/packages          → shared libraries (@company/audit, @company/auth-client)
/platform          → shared infra: API gateway, service mesh, observability
/migrations        → DB migrations (ordered, immutable, named with timestamp)
/docs              → ADRs, runbooks, compliance docs, architecture diagrams
/ci                → CI/CD pipeline configs (GitHub Actions / GitLab CI)
/.claude           → Claude Code config: skills, hooks, agents, plugins
```

---

## Team Conventions
- Always reference the JIRA ticket in commits and PRs
- Post in #engineering Slack before any production deploy
- Write the runbook before the feature ships, not after
- If you're unsure whether something needs a compliance review — it does
