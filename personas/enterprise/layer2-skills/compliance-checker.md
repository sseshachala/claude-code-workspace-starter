---
name: compliance-checker
description: Audits code and infrastructure changes against SOC 2, GDPR, and HIPAA control requirements before they reach production
---

# Compliance Checker Skill

Use this skill when reviewing any change that touches: data models, API endpoints, auth flows, logging, or infrastructure.

## Pre-Check Setup
Identify which compliance frameworks apply to this change:
- [ ] SOC 2 Type II (access control, availability, processing integrity)
- [ ] GDPR (personal data, consent, right to erasure, data minimization)
- [ ] HIPAA (PHI handling, audit controls, encryption, access controls)

## SOC 2 Controls Checklist

### CC6 — Logical and Physical Access
- [ ] New endpoint has authentication middleware
- [ ] Role-based access control enforced at the service layer
- [ ] Privileged actions require MFA or elevated session
- [ ] Access logs emitted for every authenticated request

### CC7 — System Operations
- [ ] Monitoring alerts exist for the new component
- [ ] Error rates and latency tracked in observability platform
- [ ] Runbook exists for failure scenarios

### CC8 — Change Management
- [ ] Change is linked to an approved ticket (JIRA/Linear)
- [ ] Code reviewed by at least two engineers
- [ ] Deployed via CI/CD — no manual production deploys

## GDPR Controls Checklist
- [ ] Does this code process personal data? (name, email, IP, device ID, behavioral data)
- [ ] Is data minimization applied — only collecting what's necessary?
- [ ] Is there a lawful basis for processing (consent, contract, legitimate interest)?
- [ ] Is PII encrypted at rest (AES-256) and in transit (TLS 1.2+)?
- [ ] Is there a retention period defined for this data?
- [ ] Does the system support right-to-erasure for this data type?
- [ ] Are data transfers outside the EU covered by SCCs or adequacy decision?

## HIPAA Controls Checklist (if applicable)
- [ ] PHI is identified and documented in the data dictionary
- [ ] PHI at rest is encrypted with a FIPS 140-2 validated algorithm
- [ ] PHI in transit uses TLS 1.2 or higher
- [ ] Access to PHI is role-based and logged
- [ ] Audit log is immutable and retained for 6 years
- [ ] Business Associate Agreement (BAA) exists with all subprocessors handling PHI

## Audit Log Requirements
Every write operation on regulated data must emit an audit event:
```json
{
  "timestamp": "ISO8601",
  "actor_id": "user|service|system",
  "action": "create|update|delete|access",
  "resource_type": "user|payment|health_record",
  "resource_id": "uuid",
  "ip_address": "x.x.x.x",
  "outcome": "success|failure",
  "change_summary": "brief description"
}
```

## Output
After checking, produce:
```
COMPLIANCE STATUS: CLEAR | ISSUES FOUND | BLOCKED

Framework: [SOC2 / GDPR / HIPAA]
Issues:
- [BLOCKING] [control reference]: [description] → Required action: [action]
- [WARNING]  [control reference]: [description] → Recommended action: [action]

Sign-off required from: [Security / Legal / DPO] before merge
```
