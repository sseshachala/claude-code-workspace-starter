---
name: customer-support-triage
description: Investigates and responds to customer bug reports — reproduce, diagnose, communicate ETA, fix or escalate
---

# Customer Support Triage Skill

## Intake — What You Need
Before investigating, collect:
- Customer email or account ID
- Exact error message or description of unexpected behavior
- When it started happening
- Browser / device (if frontend issue)
- Steps to reproduce

## Step 1 — Reproduce
```bash
# Look up the customer account
psql $DATABASE_URL -c "SELECT id, email, plan, created_at FROM users WHERE email = 'customer@example.com';"

# Check their recent actions
psql $DATABASE_URL -c "SELECT * FROM activity_log WHERE user_id = 'UUID' ORDER BY created_at DESC LIMIT 20;"
```

Try to reproduce the issue using the customer's account in a staging/dev environment that mirrors their data shape.

## Step 2 — Check Logs
```bash
# Application logs (adjust for your stack)
# Vercel: check Function Logs in dashboard for the customer's session timeframe
# Self-hosted:
grep "customer@example.com" logs/app.log | tail -50
grep "userId=UUID" logs/errors.log | tail -20
```

Look for: HTTP 4xx/5xx errors, database timeouts, unhandled exceptions, payment failures.

## Step 3 — Classify Severity
| Severity | Criteria | Response time |
|---|---|---|
| Critical | Data loss, can't access account, payment charged incorrectly | 1 hour |
| High | Core feature completely broken for this customer | 4 hours |
| Medium | Feature degraded or workaround exists | 24 hours |
| Low | Cosmetic issue, minor inconvenience | Next sprint |

## Step 4 — Customer Response Draft
Write an honest, human response:
```
Subject: Re: [their subject]

Hi [Name],

Thanks for reaching out — I've looked into this and here's what I found:

[One-sentence plain-English explanation of what happened]

[If fixed]: Good news — this is now resolved. You may need to [refresh / log out and back in / etc.].

[If in progress]: We're working on a fix and expect to have it resolved by [honest ETA]. I'll follow up directly when it's done.

Sorry for the trouble. Let me know if you see anything else.

[Your name]
```

## Step 5 — Create a Bug Report
Open a GitHub issue:
```
Title: bug: [brief description] — reported by customer [ID/name]
Labels: bug, customer-reported, [severity]
Body:
  Customer: [email/ID]
  Reported: [date]
  Severity: [critical/high/medium/low]
  
  Reproduction steps:
  1. ...
  
  Expected: ...
  Actual: ...
  
  Logs: [paste relevant log lines]
  
  Root cause: [your diagnosis]
  Proposed fix: [brief description]
```
