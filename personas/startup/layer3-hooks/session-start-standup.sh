#!/usr/bin/env bash
# SessionStart hook — async standup for solo founders

set -euo pipefail

DATE=$(date "+%A, %B %d — %H:%M")
BRANCH=$(git branch --show-current 2>/dev/null || echo "N/A")

echo ""
echo "┌────────────────────────────────────────────────┐"
echo "│         Startup Claude Code Session             │"
echo "└────────────────────────────────────────────────┘"
echo "  $DATE"
echo "  Branch: $BRANCH"
echo ""

# Yesterday: what shipped?
echo "  Yesterday:"
LAST_COMMIT=$(git log -1 --format="%s" 2>/dev/null || echo "(no recent commits)")
echo "    Last commit: $LAST_COMMIT"
echo ""

# Today: what's in progress?
echo "  In progress:"
CHANGES=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
if [[ "$CHANGES" -gt 0 ]]; then
  echo "    $CHANGES uncommitted file(s)"
  git status --short 2>/dev/null | head -5 | awk '{print "    " $0}'
else
  echo "    Clean slate — no uncommitted work"
fi
echo ""

# Open "today" issues (if gh available)
if command -v gh &>/dev/null 2>&1; then
  TODAY_ISSUES=$(gh issue list --label "today,in-progress" --state open --limit 5 --json number,title 2>/dev/null || echo "[]")
  if [[ "$TODAY_ISSUES" != "[]" && "$TODAY_ISSUES" != "" ]]; then
    echo "  Today's focus:"
    echo "$TODAY_ISSUES" | python3 -c "
import sys, json
try:
    issues = json.load(sys.stdin)
    for i in issues:
        print(f'    #{i[\"number\"]} {i[\"title\"][:55]}')
except:
    pass
" 2>/dev/null || true
    echo ""
  fi
fi

# Velocity log
if [[ -f ".claude/velocity.log" ]]; then
  echo "  Recent velocity:"
  tail -3 ".claude/velocity.log" | awk '{print "    " $0}'
  echo ""
fi

echo "  Move fast. Ship value. Document shortcuts."
echo "─────────────────────────────────────────────────"
echo ""
