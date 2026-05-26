---
name: governance
description: Enforces enterprise change governance — every significant code change must reference a ticket, have a reviewer, and respect the change calendar
---

# Governance Skill

## Change Governance Rules

### Ticket Reference (Required)
Every commit touching regulated paths must include a ticket reference:
- Format: `[A-Z]+-[0-9]+` (e.g., `ENG-1234`, `PLAT-567`)
- Check current branch: `git branch --show-current`
- Acceptable: branch name contains ticket OR commit message contains ticket
- Unacceptable: work on `main` directly, or no ticket reference anywhere

**If no ticket reference found:**
```
GOVERNANCE BLOCK: No ticket reference found.
Create a ticket first: [link to your project management tool]
Then create a branch: git checkout -b feat/TICKET-123-description
```

### Two-Eyes Rule (Required for regulated paths)
Changes to these paths require two reviewers before merge:
- `src/auth/**`
- `src/billing/**`
- `migrations/**`
- `infra/**`
- `ci/**`
- Any file matching `*secret*`, `*credential*`, `*config.production*`

Verify: `gh pr view --json reviews | jq '.reviews | length'` ≥ 2

### Change Calendar (Required for production)
Production changes are only allowed within the change window.

```bash
CURRENT_HOUR=$(date +%H)
START="${CHANGE_WINDOW_START:-10}"
END="${CHANGE_WINDOW_END:-15}"
DAY=$(date +%u)  # 1=Mon, 5=Fri, 6=Sat, 7=Sun

if [[ "$DAY" -ge 5 ]]; then
  echo "BLOCKED: No production changes on weekends"
elif [[ "$CURRENT_HOUR" -lt "$START" || "$CURRENT_HOUR" -ge "$END" ]]; then
  echo "BLOCKED: Outside change window (${START}:00–${END}:00)"
fi
```

### Governance Checklist Output
```
GOVERNANCE CHECK
════════════════
Ticket reference : [FOUND: ENG-1234 / NOT FOUND ⚠️]
Branch hygiene   : [COMPLIANT / WORKING ON MAIN ⚠️]
Reviewer count   : [N reviews — COMPLIANT / INSUFFICIENT ⚠️]
Change window    : [OPEN / CLOSED ⚠️]

STATUS: APPROVED | BLOCKED — [reason]
```
