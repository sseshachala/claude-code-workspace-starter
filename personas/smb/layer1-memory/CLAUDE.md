# SMB Workspace — CLAUDE.md

> This file is always loaded. Edit the sections below before your first session.

---

## Project Identity
- **Company**: [Your Company Name]
- **Product**: [B2B SaaS / E-commerce / Internal Tool / Client Project]
- **Customers**: [50–500 businesses / 1k–50k end users]
- **Team size**: [5–50 people, most wearing multiple hats]
- **Current focus**: [e.g., "Reduce churn — improve onboarding flow + billing reliability"]

---

## Stack
- **Frontend**: Next.js (App Router) / React / [your choice]
- **Backend**: Node.js + Express / tRPC / [your choice]
- **Database**: PostgreSQL via [Prisma / Drizzle / Knex]
- **Payments**: Stripe
- **Auth**: [NextAuth / Clerk / custom]
- **Hosting**: Vercel + [Railway / Render / AWS]
- **Monitoring**: [Sentry, LogRocket, Datadog Lite]

---

## Core Rules

### What Claude Should Always Do
- Check if a feature already exists (or is half-built) before starting fresh
- Write working code before writing perfect code
- Include error handling for external calls (Stripe, email, DB)
- Stripe webhooks MUST be idempotent — check for duplicate event processing
- Use the ORM — no raw SQL unless there's a compelling performance reason
- Every API route that handles customer data requires auth middleware

### What Claude Should Never Do
- Commit `.env` files or hardcoded credentials
- Drop or truncate tables without explicit user confirmation
- Make breaking changes to the public API without versioning
- Delete customer data without a soft-delete + 30-day recovery window
- Run `rm -rf` on anything without explicit confirmation

---

## Coding Standards
- TypeScript — types required, `any` only as last resort
- Consistent error responses: `{ error: { code: string, message: string } }`
- Log errors with context, not just the message: `logger.error({ err, userId, action })`
- Prefer readability over cleverness — this team has no dedicated code reviewer

---

## Testing Expectations
- Unit tests for: business logic, utility functions, webhook handlers
- Integration tests for: API routes, database operations
- Manual testing in staging before any Stripe or auth change goes to production
- Run `npm test` before every PR

---

## Database Conventions
- Migrations: use the ORM migration tool — never edit the DB directly
- New columns: add nullable first, then backfill, then add constraints
- Always include `created_at` and `updated_at` timestamps on every table
- Soft delete: use `deleted_at` column instead of `DELETE` on customer records

---

## Repo Map
```
/src
  /app          → Next.js app router pages and API routes
  /lib          → shared utilities (db, auth, email, stripe)
  /components   → React components
  /hooks        → custom React hooks
/prisma         → schema and migrations
/tests          → unit and integration tests
/docs           → internal docs, runbooks, customer help drafts
/.claude        → Claude Code config
```

---

## Customer-First Reminders
- Before any deploy: "what's the worst that could happen for a customer right now?"
- If a bug affects a paying customer — fix it before shipping new features
- Every customer-visible change needs a help article draft (even a rough one)
- Don't expose internal error messages to customers — log internally, show friendly message externally
