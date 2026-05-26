#!/usr/bin/env bash
# PostToolUse hook — appends every significant tool action to session work log

set -euo pipefail

LOG_DIR=".claude"
LOG_FILE="$LOG_DIR/session-work.log"

mkdir -p "$LOG_DIR"

TOOL="${CLAUDE_TOOL_NAME:-unknown}"
TIMESTAMP=$(date "+%H:%M:%S")

# Extract meaningful identifier from input
INPUT="${CLAUDE_TOOL_INPUT:-{}}"
CONTEXT=""

case "$TOOL" in
  Write|Edit)
    CONTEXT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('file_path', d.get('path', 'unknown file')))
except:
    print('unknown file')
" 2>/dev/null || echo "unknown file")
    ;;
  Bash)
    CONTEXT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    cmd = d.get('command', '')
    print(cmd[:80])
except:
    print('unknown command')
" 2>/dev/null || echo "unknown command")
    ;;
  *)
    CONTEXT="$TOOL"
    ;;
esac

echo "[$TIMESTAMP] $TOOL → $CONTEXT" >> "$LOG_FILE"

# Optional Slack notification for deploys (if webhook is set)
if [[ "$TOOL" == "Bash" ]] && echo "$CONTEXT" | grep -qi "vercel\|deploy\|migrate"; then
  if [[ -n "${SLACK_WEBHOOK_URL:-}" ]]; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
    curl -s -X POST "$SLACK_WEBHOOK_URL" \
      -H 'Content-type: application/json' \
      -d "{\"text\": \"🚀 Claude ran: \`${CONTEXT:0:100}\` on branch \`$BRANCH\`\"}" \
      &>/dev/null &
  fi
fi

exit 0
