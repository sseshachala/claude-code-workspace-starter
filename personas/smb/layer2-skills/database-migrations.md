---
name: database-migrations
description: Safe database migration patterns — always additive first, backward compatible, rollback SQL included in every migration
---

# Database Migrations Skill

## The Golden Rule
**Never make a breaking schema change in a single deploy.** Always use the expand-contract pattern.

## Expand-Contract Pattern (Required for all schema changes)

### Step 1 — Expand (additive, backward-compatible)
```sql
-- Migration: 001_add_user_stripe_customer_id.sql
-- Safe: adds a nullable column, old code still works
ALTER TABLE users ADD COLUMN stripe_customer_id VARCHAR(255);
```

### Step 2 — Backfill (separate deploy/job)
```typescript
// Run as a one-off job, not inline in the migration
const users = await db.user.findMany({ where: { stripe_customer_id: null } })
for (const user of users) {
  const customer = await stripe.customers.create({ email: user.email })
  await db.user.update({ where: { id: user.id }, data: { stripe_customer_id: customer.id } })
}
```

### Step 3 — Contract (add constraints after backfill is verified)
```sql
-- Migration: 002_make_stripe_customer_id_required.sql
-- Only run AFTER verifying all rows have a value
ALTER TABLE users ALTER COLUMN stripe_customer_id SET NOT NULL;
```

## Migration File Structure
Every migration needs:
```
migrations/
  001_add_user_stripe_customer_id.up.sql
  001_add_user_stripe_customer_id.down.sql  ← REQUIRED
  002_make_stripe_customer_id_required.up.sql
  002_make_stripe_customer_id_required.down.sql
```

### Rollback SQL (always write this first)
```sql
-- down.sql for adding a column
ALTER TABLE users DROP COLUMN IF EXISTS stripe_customer_id;

-- down.sql for adding a table
DROP TABLE IF EXISTS subscription_events;

-- down.sql for adding an index
DROP INDEX IF EXISTS idx_users_stripe_customer_id;
```

## What NEVER to Do
- Never rename a column in a single migration (add new + backfill + drop old)
- Never drop a column without a code deploy removing all references first
- Never run migrations during peak traffic hours
- Never skip writing the down migration ("we'll never need it" is famous last words)

## Pre-Migration Checklist
- [ ] Down migration written and tested on a copy of the DB
- [ ] Migration tested against a production-size dataset (check timing — 1M rows can take minutes)
- [ ] Deployment window is off-peak
- [ ] Application can handle the old schema during the migration window
- [ ] Rollback procedure confirmed with the team

## Running Migrations
```bash
# Prisma
npx prisma migrate deploy

# Knex
npx knex migrate:latest

# Rollback (if needed)
npx prisma migrate resolve --rolled-back [migration-name]
npx knex migrate:rollback
```
