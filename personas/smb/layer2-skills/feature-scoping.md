---
name: feature-scoping
description: Breaks down customer feature requests into a tiered plan — quick win, full implementation, and future enhancement
---

# Feature Scoping Skill

## Step 1 — Understand the Real Request
Customer feature requests are often solutions dressed up as requirements. Dig to the real problem:

- "We need bulk CSV import" → Real need: "We're spending 2 hours/week manually entering data"
- "We need a mobile app" → Real need: "Our field team can't use the desktop app on-site"
- "We need an API" → Real need: "We want to connect this to our existing CRM"

Before scoping, write: **"The customer's actual problem is: [problem statement]"**

## Step 2 — Three-Tier Breakdown

### Tier 1 — Quick Win (< 1 day, ships this week)
Solves 70% of the need with minimal risk. Deployable independently.
- DB changes: [list]
- API changes: [list]  
- UI changes: [list]
- Tests needed: [list]
- Estimated time: [X hours]

### Tier 2 — Full Implementation (3–5 days)
The complete version customers actually asked for.
- DB changes: [list]
- API changes: [list]
- UI changes: [list]
- Tests needed: [list]
- Estimated time: [X days]

### Tier 3 — Future Enhancement (backlog)
Nice-to-have additions for after we've validated the core.
- [Feature A] — adds value but not required for launch
- [Feature B] — depends on adoption first

## Step 3 — Risk Assessment
| Risk | Level | Mitigation |
|---|---|---|
| Touches Stripe / payments | HIGH | Staging test + feature flag |
| Schema migration | MEDIUM | Additive migration, rollback tested |
| Changes existing behavior | MEDIUM | Feature flag, opt-in for existing customers |
| New UI only | LOW | Deploy freely |

## Step 4 — Scope Decision Output
```
FEATURE SCOPE: [Feature Name]

Customer problem: [one sentence]

Tier 1 (Quick Win — ships by [date]):
  - [what's included]
  - Estimated: [X hours]
  - Delivers: [% of full value]

Tier 2 (Full — ships by [date]):
  - [what's included]
  - Estimated: [X days]

Tier 3 (Backlog):
  - [list]

Risks: [HIGH/MEDIUM/LOW] — [mitigation]
Recommendation: Start with Tier 1, validate with customer, then Tier 2.
```
