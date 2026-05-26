#!/usr/bin/env bash
# PostToolUse hook — logs tool completion to a rotating daily log

set -euo pipefail

LOG_DIR=".claude/logs"
TODAY=$(date -u +"%Y-%m-%d")
LOG_FILE="$LOG_DIR/${TODAY}.log"

mkdir -p "$LOG_DIR"

TOOL="${CLAUDE_TOOL_NAME:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
EXIT_CODE="${CLAUDE_TOOL_EXIT_CODE:-0}"

# Determine outcome
if [[ "$EXIT_CODE" == "0" ]]; then
  OUTCOME="success"
else
  OUTCOME="failure"
fi

# Write log entry
printf '[%s] %-12s %s\n' "$TIMESTAMP" "$TOOL" "$OUTCOME" >> "$LOG_FILE"

# Rotate logs older than 30 days
find "$LOG_DIR" -name "*.log" -mtime +30 -delete 2>/dev/null || true

exit 0
