---
name: mvp-scoping
description: Defines the minimum set of features needed to validate a hypothesis with real users — cuts everything that doesn't directly test the core assumption
---

# MVP Scoping Skill

## The Hypothesis First
Before listing any features, write the hypothesis:

> **"We believe that [target user] will [desired behavior] because [reason]."**
> **"We'll know this is true when [measurable outcome]."**

Example:
> "We believe that B2B SaaS founders will pay $99/month for AI brand monitoring because they currently have no way to measure their AI visibility. We'll know this is true when 10 paying customers use it weekly for 4 weeks."

If you can't write this sentence — you're not ready to build yet. Get customer conversations first.

## The Feature Sorting Exercise
List every proposed feature. For each, ask: **"Does this directly test the hypothesis?"**

| Feature | Tests hypothesis? | Verdict |
|---|---|---|
| [feature] | YES / NO | BUILD / BACKLOG |

- **YES**: goes into the MVP
- **NO**: goes into `BACKLOG.md` — not deleted, just deferred

## The 48-Hour Test
A good MVP can be built by one engineer in 48 hours. If your YES-column list would take longer:
- Cut more features
- Simplify the ones that remain ("manual process behind the scenes" > automated)
- Use a waitlist + manual fulfillment instead of a full product

## Stubs Are Valid
For MVP, these are acceptable:
- Manual email instead of automated email system
- Spreadsheet instead of admin dashboard
- Hardcoded values instead of user-configurable settings
- One Stripe price ID instead of a billing management system
- CSV export instead of API integration

## MVP Definition Output
```
MVP DEFINITION: [Product Name]

Hypothesis: [your hypothesis sentence]
Success metric: [what we measure]
Timeline: [days/weeks to build]

IN SCOPE (tests the hypothesis):
  1. [Feature] — [why it's essential]
  2. [Feature] — [why it's essential]
  3. [Feature] — [why it's essential]

OUT OF SCOPE (backlog):
  - [Feature] → why: [doesn't test hypothesis / nice-to-have]
  - [Feature] → why: [can be done manually for first 10 customers]

Stubs we'll use:
  - [manual process instead of X]
  - [hardcoded instead of Y]

Estimated build time: [X days]
Launch target: [date]
```

## After Launch
Once you have 10 real users:
1. Watch what they actually do (PostHog recordings)
2. Ask: "What is the #1 thing missing?"
3. Build ONLY that thing next
4. Repeat
