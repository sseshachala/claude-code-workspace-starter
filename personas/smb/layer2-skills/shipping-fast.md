---
name: shipping-fast
description: Applies the minimum viable implementation mindset — ship the smallest version that delivers value, then iterate based on real usage
---

# Shipping Fast Skill

## The Filter Before You Build
Before writing any code, answer these three questions:
1. **Does this solve a named customer problem?** (not a hypothetical one)
2. **What is the smallest version we could ship today?**
3. **How will we know if it worked?** (define the success metric now)

If you can't answer all three, stop and get clarity before coding.

## The 80/20 Rule
Most features can deliver 80% of their value with 20% of the full implementation. Find that 20% and ship it first.

Ask: "What parts of this feature are genuinely required on day one vs nice-to-have after we see usage?"

Move everything non-essential to `BACKLOG.md` with a one-line description.

## Feature Flag Rule
Use a feature flag (LaunchDarkly / PostHog / simple env var) for:
- Anything touching auth flows
- Anything touching payment flows
- Anything that changes existing customer behavior
- Any experiment where you're unsure of customer reaction

Flag syntax (simple env var approach):
```typescript
const ENABLE_NEW_CHECKOUT = process.env.ENABLE_NEW_CHECKOUT === 'true'
```

## Rollback Readiness
Before marking any deploy complete:
- Write the rollback command: `git revert [commit]` or `vercel rollback`
- For DB changes: confirm there's a down migration
- For feature flags: confirm the flag can be turned off without a deploy

## Tech Debt Documentation
Every shortcut taken must be documented:
```typescript
// TODO(debt): This manually parses the Stripe event type.
// Replace with the stripe-signature-verification middleware when we refactor webhooks.
```

Then add one line to `TECH_DEBT.md`:
```
- [date] Manual Stripe event parsing in /api/webhooks/stripe.ts — replace with middleware
```

## Ship Checklist
- [ ] Feature works for the happy path
- [ ] Error states handled (don't leave users stuck)
- [ ] Works on mobile (if customer-facing)
- [ ] Stripe/auth flows: tested in staging with test credentials
- [ ] Feature flag in place (if applicable)
- [ ] Rollback plan documented
- [ ] Help article draft created (even one paragraph)
