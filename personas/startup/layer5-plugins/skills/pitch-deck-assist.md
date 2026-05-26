---
name: pitch-deck-assist
description: Structures and sharpens investor pitch narratives using the problem-solution-traction-ask framework, backed by real data
---

# Pitch Deck Assist Skill

## Framework: Problem → Insight → Solution → Traction → Market → Team → Ask

Every great pitch tells this story in order. Don't skip steps.

## Slide-by-Slide Outline

### Slide 1 — Problem
- State the problem in **customer language**, not founder language
- Make the pain visceral: "Right now, [target customer] has to [painful manual process] which takes [X hours/week] and costs [$ or risk]"
- Include: 1 real customer quote if you have it

**Data to pull**:
```sql
-- If you have customer interviews or support tickets:
SELECT subject, created_at FROM support_tickets 
WHERE category = 'pain_point' ORDER BY created_at DESC LIMIT 5;
```

### Slide 2 — Insight (the "why now")
- What changed in the world that makes this solvable now?
- Technology shift? Regulatory change? Market timing?
- Without this slide, investors ask "why hasn't this been built before?"

### Slide 3 — Solution
- One sentence: "[Product] helps [customer] to [outcome] by [mechanism]"
- Show the product, don't describe it — screenshot or demo GIF
- What makes this 10x better than the current alternative (spreadsheets, manual process, competitor)?

### Slide 4 — Traction (the most important slide)
Pull real numbers:
```sql
SELECT 
  COUNT(*) as total_users,
  COUNT(*) FILTER (WHERE plan != 'free') as paying_users,
  SUM(mrr_cents) / 100.0 as mrr,
  COUNT(*) FILTER (WHERE created_at >= DATE_TRUNC('month', NOW())) as new_users_this_month
FROM users u
LEFT JOIN subscriptions s ON s.user_id = u.id;
```

Show growth trend — week over week or month over month.

### Slide 5 — Market Size
- TAM / SAM / SOM (but don't make up big numbers)
- Bottom-up: "[N target customers] × [$X ACV] = $Y ARR opportunity"
- More credible than top-down percentage of giant market

### Slide 6 — Team
- Why are YOU the right people to build this?
- Domain expertise, previous experience, unfair advantages
- Keep it short: 2–3 sentences per founder

### Slide 7 — Ask
- How much are you raising?
- What will you use it for? (18-month runway, specific milestones)
- What will you have proven at the end of this round?

## Output Format
```
PITCH DECK OUTLINE
══════════════════

Slide 1 — Problem
  Key message: [one sentence]
  Data point: [real stat or quote]
  
Slide 2 — Insight
  Key message: [what changed]
  
Slide 3 — Solution  
  Key message: [one sentence product description]
  Visual needed: [screenshot / demo / diagram]

Slide 4 — Traction
  MRR: $[X]
  Users: [N] total, [N] paying
  Growth: [X%] MoM
  Key message: [your strongest traction metric]

Slide 5 — Market
  TAM: $[X]B
  SAM: $[X]M  
  Bottom-up: [N customers × $X ACV = $Y]

Slide 6 — Team
  [Founder 1]: [relevant credential]
  [Founder 2]: [relevant credential]

Slide 7 — Ask
  Raising: $[X]
  Use of funds: [breakdown]
  Milestones: [what you'll prove]
```
