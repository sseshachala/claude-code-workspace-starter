---
name: debugging
description: Systematic debugging methodology — reproduce first, isolate second, fix third, always add a regression test
---

# Debugging Skill

## Step 1 — Reproduce
- Get the exact error message, stack trace, or unexpected behavior description
- Reproduce with the smallest possible input: strip away unrelated data/state
- Confirm you can reproduce consistently before proceeding
- Note the environment: local vs staging vs production, OS, Node/Python version, DB version

## Step 2 — Add Structured Logging (before reading code)
- Add temporary `console.log` / `print` / `logger.debug` at the suspected entry point
- Log: input values, intermediate state, and the exact point of failure
- Run again — let the logs tell you what's happening before forming a hypothesis

## Step 3 — Bisect to Root Cause
- `git bisect start` to find the commit that introduced the bug (when applicable)
- Narrow to the exact file, function, and line
- Ask: is this a logic error, a data error, a configuration error, or an environment error?

## Step 4 — Fix
- Fix the root cause, not the symptom
- Explain the fix in a comment if the cause is non-obvious
- Remove all temporary debug logging before committing

## Step 5 — Regression Test (mandatory)
- Write a test that reproduces the bug in its broken state
- Verify the test fails before the fix and passes after
- Name the test: `it('should not [bug behavior] when [trigger condition]')`

## Common Patterns

| Symptom | First Check |
|---|---|
| `undefined is not a function` | Check if module is imported; check async/await missing |
| 500 on specific user only | Check user's data for edge case values (null, special chars) |
| Works locally, fails in CI | Check env vars, file paths, timezone differences |
| Flaky test | Check for shared state, timing assumptions, external calls |
| Memory leak | Check for unclosed streams, listeners not removed, circular refs |
