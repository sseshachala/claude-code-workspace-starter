---
name: cost-optimization
description: Keeps cloud infrastructure costs under control — surfaces expensive patterns and recommends cheaper alternatives for a bootstrapped startup
---

# Cost Optimization Skill

## The Rule: Estimate First, Build Second
Before any infrastructure decision, answer: **"What does this cost at 1000 users?"**

If the answer is > $100/month — evaluate cheaper alternatives first.

## LLM Cost Calculator
Before building any AI feature:

```
Model         | Input cost per 1M tokens | Output cost per 1M tokens
claude-haiku  | $0.80                     | $4.00
claude-sonnet | $3.00                     | $15.00
claude-opus   | $15.00                    | $75.00
gpt-4o-mini   | $0.15                     | $0.60
gpt-4o        | $2.50                     | $10.00
```

**Cost estimate formula:**
```
Daily users × avg tokens/request × cost_per_token × 30 = monthly cost
```

**Optimize:**
1. Use the smallest model that meets quality requirements (Haiku/GPT-4o-mini first)
2. Add caching for any prompt that could return the same output: `unstable_cache()` in Next.js
3. Batch API calls where possible
4. Set output token limits aggressively — most responses don't need 4096 tokens

## Free Tier First
| Service | Free Tier |
|---|---|
| Vercel | Hobby: 100GB bandwidth, 100 deployments/day |
| Supabase | Free: 500MB DB, 2GB storage, 50k MAU |
| Clerk | Free: 10k MAU |
| Resend | Free: 3k emails/month |
| PostHog | Free: 1M events/month |
| Upstash Redis | Free: 10k commands/day |
| Cloudflare R2 | Free: 10GB storage |

Stay on free tiers until you're charging real money.

## Expensive Patterns to Avoid
- **Polling loops**: use webhooks instead (Stripe webhooks, GitHub webhooks)
- **Unindexed DB queries on growing tables**: add index or paginate
- **Large files in DB**: use Supabase Storage / Cloudflare R2 instead
- **Uncached LLM calls**: if 10 users ask the same thing, cache it
- **Full-page re-renders for small data**: use React Query / SWR + optimistic updates
- **Logging everything**: log errors and key events only, not every request

## Monthly Budget Tracker
Keep a running estimate in `docs/infra-costs.md`:

```markdown
## Monthly Infrastructure Costs (estimate at current scale)

| Service | Plan | Monthly Cost | At 1k users |
|---|---|---|---|
| Vercel | Pro | $20 | $20 |
| Supabase | Pro | $25 | $25 |
| Clerk | Pro | $25 | $25 |
| [LLM API] | Pay-per-use | $[X] | $[Y] |
| Total | | $[X] | $[Y] |

**Budget threshold**: $500/month before requiring founder approval for new services
```
