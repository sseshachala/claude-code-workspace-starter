---
name: git-workflow
description: Enforces branch-first development, conventional commit messages, and PR-before-merge discipline across all projects
---

# Git Workflow

## Before Any Code Change
1. Run `git branch` and `git status` to confirm current state
2. Create or switch to a named branch: `git checkout -b feat/description` or `fix/`, `docs/`, `ux/`, `chore/`
3. Never work directly on `main` or `master`

## Commit Messages
Format: `type(scope): short description`

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

Examples:
- `feat(auth): add OAuth2 Google login`
- `fix(billing): correct proration on plan downgrade`
- `docs(api): add rate limit documentation`

Rules:
- First line under 72 characters
- Present tense ("add" not "added")
- Reference ticket/issue when applicable: `feat(checkout): add coupon field (#142)`

## Commit Cadence
- Commit after every logical unit of work — not after every file save
- Never commit generated files, secrets, or build artifacts
- Run `git diff --staged` before committing to verify what's included

## Pull Requests
- Push to remote before marking work complete: `git push -u origin <branch>`
- Open PR via `gh pr create --base main --fill`
- Never merge your own PR without review unless explicitly authorized
- Delete the branch after merge

## What Claude Should Never Do
- `git push --force` on shared branches
- `git reset --hard` without user confirmation
- Commit files matching: `*.env`, `*secret*`, `*credential*`, `*.pem`, `*.key`
