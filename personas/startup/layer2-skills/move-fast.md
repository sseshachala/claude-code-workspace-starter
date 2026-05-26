---
name: move-fast
description: Startup velocity skill — defaults to the fastest path to shipped, with deliberate tech debt documentation
---

# Move Fast Skill

## The Startup Filter
Before writing a single line, ask:
- Can this be done in < 4 hours? If yes, ship the simple version.
- Is there a library that does 80% of this? Use it.
- Does this need to be perfect on day one? Almost certainly no.

## Coding Principles

### Libraries Over Custom
If a battle-tested library exists — use it. Don't write a custom:
- Auth system (use Clerk / NextAuth)
- Payment processing (use Stripe)
- Email sending (use Resend / SendGrid)
- File uploads (use Uploadthing / Supabase Storage)
- Date handling (use date-fns)
- Form validation (use Zod + react-hook-form)

**Exception**: if the library would add > $100/month cost and you can build it in < 4 hours, build it.

## The 30-Minute Rule
If you've been stuck on a problem for 30 minutes:
1. Ship the "good enough" version with a `// TODO(debt):` note
2. Document it in `TECH_DEBT.md`
3. Move to the next thing
4. Come back when you have a fresh perspective

## Tech Debt Documentation
Every shortcut gets documented immediately:

**In code:**
```typescript
// TODO(debt): This manually validates the Stripe webhook.
// Switch to stripe.webhooks.constructEvent() when we refactor webhooks. ETA: Q2.
```

**In TECH_DEBT.md:**
```markdown
## [date] — [Short description]
- File: [path/to/file.ts:line]
- Shortcut taken: [what we did]
- What we should do: [the right way]
- Risk if not fixed: [low/medium/high — why]
```

## Feature Flags (Simple Version)
For anything risky, wrap it in a simple env var flag:
```typescript
// In lib/flags.ts
export const FLAGS = {
  NEW_ONBOARDING: process.env.NEXT_PUBLIC_FF_NEW_ONBOARDING === 'true',
  AI_RECOMMENDATIONS: process.env.NEXT_PUBLIC_FF_AI_RECS === 'true',
}

// Usage
if (FLAGS.NEW_ONBOARDING) {
  // new behavior
} else {
  // old behavior — keep until we're confident
}
```

## Ship Checklist (Startup Edition)
- [ ] Happy path works
- [ ] Error states don't crash the app (even if the error message isn't polished)
- [ ] No secrets committed
- [ ] PostHog event tracking added
- [ ] Feature flag in place (if changes existing behavior)
- [ ] `TECH_DEBT.md` updated (if shortcuts taken)
