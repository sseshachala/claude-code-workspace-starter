# Startup Workspace — CLAUDE.md

> This file is always loaded. Edit it ruthlessly to match your actual situation.

---

## The One-Liner
**[Your startup]** helps **[target customer]** to **[core value proposition]**.

Example: "Narratr helps B2B SaaS companies understand how visible their brand is to AI models."

---

## Current Stage
- [ ] Pre-launch (building toward first 10 users)
- [ ] Post-launch (10–100 users, finding product-market fit)
- [ ] Scaling (100+ users, growing MRR)

**Current stage**: [select above]
**Sprint focus**: [what are you working on this week?]
**Biggest risk right now**: [what would kill the company if unaddressed?]

---

## Stack (keep it minimal)
- **Frontend**: Next.js App Router
- **Backend**: tRPC API routes / Next.js API routes
- **Database**: Supabase (PostgreSQL)
- **Auth**: [Clerk / Supabase Auth / NextAuth]
- **Payments**: Stripe
- **Analytics**: PostHog
- **Hosting**: Vercel
- **Monthly infra budget**: $[X]

---

## The Startup Constitution

### Speed Over Perfection
- Shipped beats perfect. A working feature today > a polished feature next week.
- Write `// TODO(debt):` for every shortcut taken — document it in `TECH_DEBT.md`
- Three similar lines > one premature abstraction

### Before Building Anything
Answer these or don't build:
1. What hypothesis are we testing?
2. What is the minimum version that tests it?
3. How will we know it worked? (define the metric before coding)

### Cost Discipline
- Every new infrastructure choice: estimate monthly cost at 1000 users
- LLM calls: estimate tokens × price before building AI features
- Default to free tier until proven we need more
- No new paid services without founder approval

### What Claude Should Always Do
- Check `TECH_DEBT.md` before starting — see if work is already partially done
- Commit frequently — every logical chunk of work
- Add PostHog event tracking to every new user-facing feature
- Use feature flags for anything that changes existing behavior
- Stripe webhooks must be idempotent — always check for duplicate events

### What Claude Should Never Do
- Commit `.env` files or hardcoded secrets
- Add paid infrastructure without flagging the cost
- Build Tier 3 (backlog features) when Tier 1 is good enough
- Delete user data without a soft-delete + recovery window
- Spin up new cloud resources without checking the monthly cost impact

---

## Repo Map
```
/src
  /app              → Next.js pages and API routes
  /components       → React components
  /lib              → Supabase client, Stripe client, PostHog
  /hooks            → custom React hooks
  /types            → TypeScript types
/supabase
  /migrations       → DB migrations
/tests              → unit and integration tests
/docs               → internal docs
TECH_DEBT.md        → running list of shortcuts and IOUs
DECISIONS.md        → architectural decisions (lightweight ADRs)
/.claude            → Claude Code config
```

---

## Founding Team Context
- **Founders**: [names and roles]
- **Engineers**: [who owns what]
- **Working hours**: [async / timezone / preference]
- **How we make decisions**: [founder decides / team vote / whoever does the work decides]
