#!/usr/bin/env bash
# PreToolUse hook — writes audit record for every Bash tool call
# Satisfies SOC 2 CC7.2: audit trail of AI agent actions

set -euo pipefail

LOG_DIR=".claude/logs"
AUDIT_LOG="$LOG_DIR/audit.log"

mkdir -p "$LOG_DIR"

TOOL="${CLAUDE_TOOL_NAME:-unknown}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
USER=$(git config user.email 2>/dev/null || echo "unknown")

# Read and sanitize input (remove credential patterns)
RAW="${CLAUDE_TOOL_INPUT:-{}}"
SAFE=$(echo "${RAW:0:500}" | sed \
  -e 's/AKIA[0-9A-Z]\{16\}/[REDACTED_AWS_KEY]/g' \
  -e 's/sk-[a-zA-Z0-9]\{20,\}/[REDACTED_API_KEY]/g' \
  -e 's/password=[^ &]*/password=[REDACTED]/gi' \
  -e 's/secret=[^ &]*/secret=[REDACTED]/gi')

# Append audit record (JSON Lines format)
printf '{"ts":"%s","tool":"%s","branch":"%s","actor":"%s","input":%s}\n' \
  "$TIMESTAMP" "$TOOL" "$BRANCH" "$USER" \
  "$(echo "$SAFE" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '"[unparseable]"')" \
  >> "$AUDIT_LOG"

# Block known-dangerous patterns
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "git push --force"
  "git push -f"
  "DROP DATABASE"
  "DROP TABLE"
  "TRUNCATE"
  "kubectl delete namespace"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "${CLAUDE_TOOL_INPUT:-}" | grep -qi "$pattern"; then
    echo "{\"decision\": \"block\", \"reason\": \"Blocked dangerous pattern: '$pattern'. Requires explicit human confirmation.\"}"
    exit 2
  fi
done

exit 0
