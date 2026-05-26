#!/usr/bin/env bash
# PostToolUse hook on Write/Edit — tracks daily coding velocity

set -euo pipefail

LOG_DIR=".claude"
VELOCITY_LOG="$LOG_DIR/velocity.log"
TODAY=$(date -u +"%Y-%m-%d")

mkdir -p "$LOG_DIR"

# Get git diff stats
STATS=$(git diff --stat HEAD 2>/dev/null | tail -1 || echo "")

if [[ -z "$STATS" ]]; then
  exit 0
fi

# Parse: "X files changed, Y insertions(+), Z deletions(-)"
FILES=$(echo "$STATS" | grep -oE '[0-9]+ file' | grep -oE '[0-9]+' || echo "0")
ADDED=$(echo "$STATS" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
DELETED=$(echo "$STATS" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")

# Check if we already have an entry for today
if grep -q "^$TODAY" "$VELOCITY_LOG" 2>/dev/null; then
  # Update today's entry (replace the line)
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/^$TODAY.*/$TODAY | files: $FILES | +$ADDED | -$DELETED/" "$VELOCITY_LOG"
  else
    sed -i "s/^$TODAY.*/$TODAY | files: $FILES | +$ADDED | -$DELETED/" "$VELOCITY_LOG"
  fi
else
  # Append new entry
  echo "$TODAY | files: $FILES | +$ADDED | -$DELETED" >> "$VELOCITY_LOG"
fi

# Keep only last 30 days
if [[ "$(uname)" == "Darwin" ]]; then
  tail -30 "$VELOCITY_LOG" > "${VELOCITY_LOG}.tmp" && mv "${VELOCITY_LOG}.tmp" "$VELOCITY_LOG"
else
  tail -30 "$VELOCITY_LOG" > "${VELOCITY_LOG}.tmp" && mv "${VELOCITY_LOG}.tmp" "$VELOCITY_LOG"
fi

exit 0
