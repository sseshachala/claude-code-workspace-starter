#!/usr/bin/env bash
# PostToolUse hook on Write/Edit — reminds to commit when too many files are open

set -euo pipefail

THRESHOLD="${COMMIT_REMINDER_THRESHOLD:-5}"

# Count uncommitted changes
CHANGED=$(git status --short 2>/dev/null | wc -l | tr -d ' ')

if [[ "$CHANGED" -gt "$THRESHOLD" ]]; then
  echo ""
  echo "┌─────────────────────────────────────────────────────┐"
  echo "│  💡 Commit reminder                                  │"
  echo "├─────────────────────────────────────────────────────┤"
  echo "│  You have $CHANGED uncommitted files.                │"
  echo "│  Consider committing this chunk as a rollback point. │"
  echo "│                                                      │"
  echo "│  git add -p && git commit -m 'wip: [description]'   │"
  echo "└─────────────────────────────────────────────────────┘"
  echo ""
fi

exit 0
