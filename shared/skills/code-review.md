---
name: code-review
description: Guides Claude to review code for correctness, security, test coverage, and architectural fit before approving or merging
---

# Code Review Skill

## Review Checklist

### Correctness
- [ ] Does the change solve the stated problem?
- [ ] Are all edge cases handled (null, empty, overflow, concurrent access)?
- [ ] Is error handling present for external calls (API, DB, file I/O)?
- [ ] Does logic match the intent described in the PR/commit message?

### Security
- [ ] No hardcoded secrets, API keys, or credentials
- [ ] All user inputs are validated and sanitized
- [ ] SQL queries use parameterized statements — no string concatenation
- [ ] Auth checks present on every new endpoint
- [ ] No sensitive data in logs or error messages

### Tests
- [ ] New code has corresponding tests
- [ ] Tests cover happy path, error path, and at least one boundary condition
- [ ] Tests are not testing mocks of mocks (they test real behavior)
- [ ] `npm test` / `pytest` / equivalent passes

### Architecture
- [ ] No unnecessary abstraction introduced
- [ ] Change is contained to the right layer (no business logic in controllers, no DB calls in UI)
- [ ] No circular dependencies introduced
- [ ] Performance-sensitive paths have appropriate indexing or caching

### Tech Debt
- [ ] Any shortcut is marked with `// TODO(debt):` and a one-line explanation
- [ ] No commented-out code committed
- [ ] No unused imports or dead code introduced

## Output Format

```
VERDICT: LGTM | NEEDS CHANGES | BLOCKING

Summary: [one sentence]

Issues:
- [file:line] BLOCKING: [issue] → Suggested fix: [fix]
- [file:line] IMPORTANT: [issue] → Suggested fix: [fix]
- [file:line] MINOR: [issue] → Suggested fix: [fix]
```

Always pair every issue with a concrete suggested fix.
