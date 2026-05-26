#!/usr/bin/env bash
# PostToolUse hook — appends every tool invocation to .claude/tool-use.log

set -euo pipefail

LOG_DIR=".claude"
LOG_FILE="$LOG_DIR/tool-use.log"

mkdir -p "$LOG_DIR"

TOOL="${CLAUDE_TOOL_NAME:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Truncate input to avoid huge log entries
RAW_INPUT="${CLAUDE_TOOL_INPUT:-{}}"
TRUNCATED_INPUT="${RAW_INPUT:0:200}"

# Sanitize: remove common secret patterns before logging
SAFE_INPUT=$(echo "$TRUNCATED_INPUT" | sed \
  -e 's/AKIA[0-9A-Z]\{16\}/[REDACTED_AWS_KEY]/g' \
  -e 's/sk-[a-zA-Z0-9]\{20,\}/[REDACTED_API_KEY]/g' \
  -e 's/ghp_[a-zA-Z0-9]\{36\}/[REDACTED_GH_TOKEN]/g')

echo "{\"ts\":\"$TIMESTAMP\",\"tool\":\"$TOOL\",\"input\":$(echo "$SAFE_INPUT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '\"[unparseable]\"')}" >> "$LOG_FILE"

exit 0
