---
name: analytics-queries
description: Generates and runs analytics SQL for SMB KPIs — MRR, churn, feature adoption, and cohort retention
---

# Analytics Queries Skill

Use for: weekly metrics reviews, investor updates, product decisions.

**Always run EXPLAIN before executing on production.** Always LIMIT results unless you need the full dataset.

## Key Metrics Queries

### MRR (Monthly Recurring Revenue)
```sql
-- Current MRR
SELECT 
  SUM(mrr_cents) / 100.0 AS mrr_dollars,
  COUNT(*) AS active_subscriptions,
  AVG(mrr_cents) / 100.0 AS avg_revenue_per_account
FROM subscriptions
WHERE status = 'active';

-- MRR by plan
SELECT 
  plan,
  COUNT(*) AS accounts,
  SUM(mrr_cents) / 100.0 AS mrr
FROM subscriptions
WHERE status = 'active'
GROUP BY plan
ORDER BY mrr DESC;
```

### Monthly Churn Rate
```sql
-- Churn rate this month
SELECT 
  COUNT(*) FILTER (WHERE cancelled_at >= DATE_TRUNC('month', NOW())) AS churned,
  (SELECT COUNT(*) FROM subscriptions WHERE status = 'active') AS active,
  ROUND(
    COUNT(*) FILTER (WHERE cancelled_at >= DATE_TRUNC('month', NOW())) * 100.0 /
    NULLIF((SELECT COUNT(*) FROM subscriptions WHERE status = 'active'), 0), 2
  ) AS churn_rate_pct
FROM subscriptions
WHERE cancelled_at IS NOT NULL;
```

### New Signups This Month
```sql
SELECT 
  DATE_TRUNC('week', created_at) AS week,
  COUNT(*) AS signups
FROM users
WHERE created_at >= DATE_TRUNC('month', NOW())
GROUP BY week
ORDER BY week;
```

### Feature Adoption
```sql
-- Which features are users actually using?
SELECT 
  feature_name,
  COUNT(DISTINCT user_id) AS unique_users,
  COUNT(*) AS total_events,
  ROUND(COUNT(DISTINCT user_id) * 100.0 / (SELECT COUNT(*) FROM users WHERE status = 'active'), 1) AS adoption_pct
FROM feature_events
WHERE created_at > NOW() - INTERVAL '30 days'
GROUP BY feature_name
ORDER BY unique_users DESC
LIMIT 20;
```

### Cohort Retention (Day 1, Day 7, Day 30)
```sql
SELECT 
  DATE_TRUNC('week', u.created_at) AS cohort_week,
  COUNT(DISTINCT u.id) AS cohort_size,
  COUNT(DISTINCT CASE WHEN MAX(s.created_at) > u.created_at + INTERVAL '1 day' THEN u.id END) AS day1_retained,
  COUNT(DISTINCT CASE WHEN MAX(s.created_at) > u.created_at + INTERVAL '7 days' THEN u.id END) AS day7_retained,
  COUNT(DISTINCT CASE WHEN MAX(s.created_at) > u.created_at + INTERVAL '30 days' THEN u.id END) AS day30_retained
FROM users u
LEFT JOIN sessions s ON s.user_id = u.id
WHERE u.created_at > NOW() - INTERVAL '90 days'
GROUP BY cohort_week
ORDER BY cohort_week DESC;
```

## Output Format
Present results as a markdown table with a one-sentence interpretation:

```markdown
| Metric | Value | vs Last Month |
|---|---|---|
| MRR | $X,XXX | +X% ↑ |
| Active customers | XXX | +X ↑ |
| Churn rate | X.X% | -X% ↓ |
| New signups | XX | +X ↑ |

**Interpretation**: [One sentence on the most important trend]
```
