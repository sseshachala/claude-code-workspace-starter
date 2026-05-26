#!/usr/bin/env bash
# SessionStart hook — gives the SMB developer instant situational awareness

set -euo pipefail

BRANCH=$(git branch --show-current 2>/dev/null || echo "N/A")
DATE=$(date "+%A, %B %d — %H:%M")

echo ""
echo "┌─────────────────────────────────────────────┐"
echo "│         Claude Code — SMB Session           │"
echo "└─────────────────────────────────────────────┘"
echo "  $DATE"
echo "  Branch: $BRANCH"
echo ""

# Last commit
LAST_COMMIT=$(git log -1 --format="  Last commit: %s (%ar)" 2>/dev/null || echo "  No commits yet")
echo "$LAST_COMMIT"
echo ""

# Unstaged changes
CHANGES=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
if [[ "$CHANGES" -gt 0 ]]; then
  echo "  ⚠️  Uncommitted changes: $CHANGES file(s)"
  git status --short 2>/dev/null | head -8 | awk '{print "     " $0}'
  echo ""
fi

# Quick test health check
echo "  Running tests..."
if npm test --silent 2>/dev/null; then
  echo "  ✓ Tests passing"
else
  echo "  ⚠️  Tests failing — check before continuing"
fi
echo ""

# Open issues (if gh available)
if command -v gh &>/dev/null 2>&1; then
  OPEN_ISSUES=$(gh issue list --state open --limit 5 --label "bug,critical" --json number,title 2>/dev/null || echo "[]")
  if [[ "$OPEN_ISSUES" != "[]" ]]; then
    echo "  Open bugs:"
    echo "$OPEN_ISSUES" | python3 -c "
import sys, json
issues = json.load(sys.stdin)
for i in issues[:3]:
    print(f'    #{i[\"number\"]} {i[\"title\"][:60]}')
" 2>/dev/null || true
    echo ""
  fi
fi

# Session work log preview
if [[ -f ".claude/session-work.log" ]]; then
  echo "  Last session activity:"
  tail -3 ".claude/session-work.log" | awk '{print "    " $0}'
  echo ""
fi

echo "  Hooks active: destructive-blocker, secrets-blocker, work-log"
echo "────────────────────────────────────────────────"
echo ""
