---
name: crm-integration
description: Enables Claude to query and summarize CRM data — customer health scores, churn risk, support ticket volume, and MRR per account
---

# CRM Integration Skill

Use when: support calls, account reviews, churn analysis, renewal conversations.

## Read-Only Queries Only
This skill uses SELECT queries only. No updates, no deletes.

## Customer Health Snapshot
```sql
-- Full customer health view
SELECT 
  u.id,
  u.email,
  u.company_name,
  u.plan,
  s.status as subscription_status,
  s.mrr_cents / 100.0 as mrr,
  u.last_sign_in_at,
  DATE_PART('day', NOW() - u.last_sign_in_at) as days_since_login,
  (SELECT COUNT(*) FROM support_tickets st WHERE st.user_id = u.id AND st.created_at > NOW() - INTERVAL '30 days') as tickets_last_30d,
  (SELECT COUNT(*) FROM support_tickets st WHERE st.user_id = u.id AND st.status = 'open') as open_tickets
FROM users u
JOIN subscriptions s ON s.user_id = u.id
WHERE u.email = '[customer email]';
```

## Churn Risk Flags
Flag an account as at-risk if ANY of:
- Days since last login > 14
- Open support tickets > 2
- Subscription status = 'past_due' or 'unpaid'
- MRR declined in the last 3 months

```sql
-- Accounts at churn risk
SELECT 
  u.email,
  u.company_name,
  u.plan,
  DATE_PART('day', NOW() - u.last_sign_in_at) as days_inactive,
  s.status,
  (SELECT COUNT(*) FROM support_tickets st WHERE st.user_id = u.id AND st.status = 'open') as open_tickets
FROM users u
JOIN subscriptions s ON s.user_id = u.id
WHERE 
  DATE_PART('day', NOW() - u.last_sign_in_at) > 14
  OR s.status IN ('past_due', 'unpaid')
  OR (SELECT COUNT(*) FROM support_tickets st WHERE st.user_id = u.id AND st.status = 'open') > 2
ORDER BY days_inactive DESC
LIMIT 20;
```

## Account Summary Output
```
ACCOUNT SUMMARY: [Company Name]
══════════════════════════════════
Contact    : [email]
Plan       : [plan] — $[MRR]/month
Status     : [active / past_due / at_risk]

Engagement :
  Last login        : [X days ago]
  Open tickets      : [N]
  Tickets (30 days) : [N]

Health score: [GREEN / YELLOW / RED]

Risk flags:
  [⚠️ flag if any at-risk criteria met]

Recommended action: [none / check in / urgent outreach]
```
