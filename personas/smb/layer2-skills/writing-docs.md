---
name: writing-docs
description: Produces customer-facing and internal documentation — accurate, versioned, written at the right audience level
---

# Writing Docs Skill

## Two Types of Documentation

### Customer-Facing Docs
- Audience: non-technical or lightly technical end users
- Tone: plain English, friendly, action-oriented
- Format: Step by step, with screenshots or GIF if the flow is non-obvious
- Never include: internal jargon, error codes, tech stack names
- Always include: the "why" (not just "click here" but "this allows you to...")
- Location: `docs/help/` or your help center (Intercom, Notion, Helpscout)

**Template:**
```markdown
# How to [do the thing]

[One sentence explaining what this feature does and why a customer would want it.]

## Steps
1. Go to [Settings → Billing]
2. Click [Add Payment Method]
3. Enter your card details and click [Save]

Your new payment method will be used for all future charges.

## Common questions

**What if my card is declined?**
[answer]

**Can I have multiple payment methods?**
[answer]
```

### Internal / Engineering Docs
- Audience: your team (now and future engineers who join in 6 months)
- Tone: direct, precise, no fluff
- Must include: architecture diagram references, links to relevant code, a "last verified" date
- Location: `docs/internal/` or Notion engineering wiki

**Template:**
```markdown
# [Feature/System Name]

**Last verified**: [YYYY-MM-DD]
**Owner**: [team/person]
**Code**: [link to main file or directory]

## What it does
[2–3 sentences. What problem it solves, how it fits in the system.]

## Architecture
[Reference to diagram or ASCII diagram]

## Key decisions
- [Decision 1 and why]
- [Decision 2 and why]

## How to [common operation]
[Step-by-step, with actual commands]

## Known issues / gotchas
- [Issue 1]
- [Issue 2]

## Runbook
[Link to runbook or inline steps for common failure scenarios]
```

## Changelog (Required for Every Customer-Visible Change)
Append to `docs/CHANGELOG.md`:
```markdown
## [YYYY-MM-DD] — [Short title]
**Type**: New Feature / Improvement / Bug Fix
**Affects**: [who sees this change]

[1–3 sentences describing what changed from the customer's perspective. Not the technical details — what they experience differently.]
```

## Done Means Documented
A feature is NOT complete until:
- [ ] A customer-facing help article draft exists (even rough)
- [ ] Any new API endpoint is documented in `docs/api/`
- [ ] Any new env var is added to `docs/environment-variables.md`
- [ ] `docs/CHANGELOG.md` has an entry for this change
