---
name: growth-hacking
description: Instruments features for growth — referral mechanics, viral loops, conversion tracking, and A/B test scaffolding
---

# Growth Hacking Skill

## The Tracking-First Rule
Before shipping any user-facing feature, instrument it. You can't improve what you can't measure.

## PostHog Event Tracking (add to every feature)
```typescript
import posthog from 'posthog-js'

// Key events to track for every feature:
posthog.capture('feature_used', {
  feature_name: 'csv_export',
  user_id: user.id,
  plan: user.plan,
})

posthog.capture('feature_completed', {
  feature_name: 'csv_export',
  rows_exported: 150,
})

posthog.capture('feature_failed', {
  feature_name: 'csv_export',
  error_code: 'TIMEOUT',
})
```

**Naming convention**: `noun_verb` — `user_signed_up`, `payment_completed`, `feature_exported`, `onboarding_skipped`

## Conversion Funnel Instrumentation
For any multi-step flow, track every step:
```typescript
// Step tracking pattern
const ONBOARDING_STEPS = ['account_created', 'profile_completed', 'first_project', 'invite_sent']

// Track each step with the same event name + step property
posthog.capture('onboarding_step_completed', {
  step: 'first_project',
  step_number: 3,
  time_since_signup_hours: 2.5,
})
```

## Referral Mechanics Checklist
For any feature with a sharing component, ask:
- [ ] Is there a shareable link? (`/share/[uuid]`)
- [ ] Does the link have UTM parameters? (`?ref=[user-id]&utm_source=referral`)
- [ ] Is referral tracked in the DB? (`referral_source` on the `users` table)
- [ ] Is there an incentive for the referrer? (even a simple "thank you" email)

**Minimum viral loop (< 2 hours to implement):**
```typescript
// Generate share link with referral tracking
const shareUrl = `${process.env.NEXT_PUBLIC_APP_URL}/signup?ref=${user.id}`
// Track when someone clicks it
// Track when someone signs up via it
// Send thank-you email to referrer when their referral converts
```

## A/B Test Scaffolding (PostHog Feature Flags)
For any uncertain conversion element:
```typescript
import { useFeatureFlagVariantKey } from 'posthog-js/react'

function HeroSection() {
  const variant = useFeatureFlagVariantKey('hero-headline-test')
  
  return (
    <h1>
      {variant === 'control' && 'Build faster with AI'}
      {variant === 'variant-a' && 'Ship your product 10x faster'}
      {variant === 'variant-b' && 'Your AI engineering co-pilot'}
    </h1>
  )
}
```

## Growth Checklist (per feature)
- [ ] Success event tracked (`feature_completed`)
- [ ] Drop-off event tracked (`feature_abandoned`)
- [ ] Shareable link generated (if applicable)
- [ ] Referral source captured (if sharing possible)
- [ ] A/B flag scaffolded (if headline/CTA is uncertain)
- [ ] Metric defined: "This feature succeeds when [specific PostHog metric] reaches [target]"
