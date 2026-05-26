#!/usr/bin/env bash
# Stop hook — prints a session summary from tool-use.log

set -euo pipefail

LOG_FILE=".claude/tool-use.log"

if [[ ! -f "$LOG_FILE" ]]; then
  echo "No tool usage recorded this session."
  exit 0
fi

TOTAL=$(wc -l < "$LOG_FILE" | tr -d ' ')

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Claude Code Session Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Total tool calls : $TOTAL"
echo ""
echo "  Top tools used:"
grep -o '"tool":"[^"]*"' "$LOG_FILE" \
  | sort | uniq -c | sort -rn \
  | head -5 \
  | awk '{gsub(/"tool":"|"/, "", $2); printf "    %-6s %s\n", $1, $2}'
echo ""
echo "  Files modified this session:"
grep '"tool":"Write"\|"tool":"Edit"' "$LOG_FILE" \
  | grep -o '"file_path":"[^"]*"' \
  | sort -u \
  | sed 's/"file_path":"//;s/"//' \
  | head -10 \
  | awk '{print "    " $0}'
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exit 0
