---
name: security-audit
description: Performs a focused security review of code changes — injection vectors, auth bypass, dependency vulnerabilities, and secrets exposure
---

# Security Audit Skill

Use this skill on any PR touching: API routes, authentication, database queries, file uploads, third-party integrations, or infrastructure.

## Step 1 — Run Automated Checks First
```bash
# Dependency vulnerabilities
npm audit --audit-level=high
# or
pip-audit --require-hashes

# Secret scanning
git diff HEAD~1 | grep -iE '(password|secret|key|token)\s*=\s*["\x27][^"\x27]{8,}'

# SAST (if available)
semgrep --config=p/owasp-top-ten .
```

Block on any CVSS 7.0+ vulnerability.

## Step 2 — OWASP Top 10 Review

### A01 — Broken Access Control
- [ ] Every new route has authorization middleware
- [ ] Resource-level authorization checked (not just role, but ownership)
- [ ] No insecure direct object references (IDOR) — use UUIDs, not sequential IDs
- [ ] Admin endpoints are separated from user endpoints

### A02 — Cryptographic Failures
- [ ] No MD5 or SHA1 for password hashing — use bcrypt/argon2
- [ ] TLS 1.2+ enforced, TLS 1.0/1.1 disabled
- [ ] Sensitive data encrypted at rest (AES-256)
- [ ] No sensitive data in URLs (use POST body or headers)

### A03 — Injection
- [ ] All SQL via ORM parameterized queries — NO string concatenation
- [ ] Command execution uses array form, not string: `exec(['git', 'log'])` not `exec('git log')`
- [ ] LDAP / XPath queries parameterized
- [ ] Template injection: no user input in template strings rendered server-side

### A04 — Insecure Design
- [ ] Rate limiting on auth endpoints (login, password reset, 2FA)
- [ ] Account lockout after N failed attempts
- [ ] Password reset tokens expire within 15 minutes
- [ ] Session invalidated on logout (server-side)

### A05 — Security Misconfiguration
- [ ] CORS configured with explicit allowlist — no `*` in production
- [ ] Security headers present: `Strict-Transport-Security`, `X-Content-Type-Options`, `X-Frame-Options`
- [ ] No debug endpoints or verbose stack traces in production
- [ ] Default credentials changed / removed

### A07 — Identification and Authentication Failures
- [ ] Passwords meet minimum complexity requirements
- [ ] JWT tokens have short expiry (15min access, 7day refresh)
- [ ] JWT algorithm is explicitly set — never `alg: none`
- [ ] Refresh token rotation implemented

### A09 — Security Logging and Monitoring
- [ ] Failed auth attempts are logged with IP and timestamp
- [ ] Privilege escalation events are logged
- [ ] Log entries do not contain passwords, tokens, or PII in plaintext

## Step 3 — Output
```
SECURITY AUDIT: CLEAN | ISSUES FOUND | BLOCKED

Automated scan: [PASSED / N findings — CVSS X.X]

Manual review findings:
- [CRITICAL] [OWASP category]: [description] → Fix: [fix]
- [HIGH]     [OWASP category]: [description] → Fix: [fix]
- [MEDIUM]   [OWASP category]: [description] → Fix: [fix]

Clearance: [APPROVED for production / BLOCKED — resolve CRITICAL/HIGH first]
```
