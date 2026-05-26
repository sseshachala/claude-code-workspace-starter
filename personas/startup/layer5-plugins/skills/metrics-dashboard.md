---
name: metrics-dashboard
description: Generates a live metrics report from the database — MRR, DAU, activation rate, and growth trends — saved as a dated markdown file
---

# Metrics Dashboard Skill

## Run This Weekly
Generates `reports/metrics-YYYY-MM-DD.md` with all key metrics pulled from the DB.

## Required Queries

### Core Business Metrics
```sql
-- MRR and subscribers
SELECT 
  SUM(mrr_cents) / 100.0 AS mrr,
  COUNT(*) AS paying_customers,
  AVG(mrr_cents) / 100.0 AS arpu
FROM subscriptions WHERE status = 'active';

-- MRR vs last month
SELECT 
  SUM(mrr_cents) FILTER (WHERE created_at >= DATE_TRUNC('month', NOW())) / 100.0 AS new_mrr,
  SUM(mrr_cents) FILTER (WHERE cancelled_at >= DATE_TRUNC('month', NOW())) / 100.0 AS churned_mrr
FROM subscriptions;
```

### User Growth
```sql
SELECT 
  COUNT(*) AS total_users,
  COUNT(*) FILTER (WHERE created_at >= DATE_TRUNC('month', NOW())) AS new_this_month,
  COUNT(*) FILTER (WHERE created_at >= DATE_TRUNC('week', NOW())) AS new_this_week
FROM users;
```

### Activation Rate
```sql
-- % of users who completed their first key action within 7 days
SELECT 
  ROUND(
    COUNT(*) FILTER (WHERE EXISTS (
      SELECT 1 FROM events e 
      WHERE e.user_id = u.id 
      AND e.event = 'first_key_action_completed'
      AND e.created_at < u.created_at + INTERVAL '7 days'
    )) * 100.0 / NULLIF(COUNT(*), 0), 1
  ) AS activation_rate_pct
FROM users
WHERE created_at > NOW() - INTERVAL '30 days';
```

### Churn Rate
```sql
SELECT 
  ROUND(
    COUNT(*) FILTER (WHERE cancelled_at >= DATE_TRUNC('month', NOW())) * 100.0 /
    NULLIF(COUNT(*) FILTER (WHERE status = 'active'), 0), 2
  ) AS monthly_churn_pct
FROM subscriptions;
```

## Output: Report File
Save to `reports/metrics-YYYY-MM-DD.md`:

```markdown
# Metrics Dashboard — [Date]

## 💰 Revenue
| Metric | Value | vs Last Month |
|---|---|---|
| MRR | $[X] | [↑/↓ X%] |
| Paying customers | [N] | [↑/↓ N] |
| ARPU | $[X] | [↑/↓ X%] |
| New MRR | $[X] | — |
| Churned MRR | $[X] | — |

## 👥 Users
| Metric | Value |
|---|---|
| Total users | [N] |
| New this month | [N] |
| New this week | [N] |

## 📈 Product Health
| Metric | Value | Target |
|---|---|---|
| Activation rate (7d) | [X%] | 40% |
| Monthly churn | [X%] | < 5% |
| DAU/MAU | [X%] | > 20% |

## Key Takeaway
[One sentence: what's the most important thing this data tells us?]

## Action This Week
[One thing to do based on this data]

---
*Generated: [ISO timestamp]*
```

## Trend Arrows
- Up vs last period: ↑
- Down vs last period: ↓
- No change: →
- Not enough data: —
