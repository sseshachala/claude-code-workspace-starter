#!/usr/bin/env bash
# PreToolUse hook on Bash — blocks destructive SQL and filesystem operations
# Critical for SMB teams with no dedicated DBA

set -euo pipefail

INPUT="${CLAUDE_TOOL_INPUT:-}"

if [[ -z "$INPUT" ]]; then
  exit 0
fi

# Destructive patterns to block outright
BLOCK_PATTERNS=(
  "rm -rf /"
  "rm -rf \*"
  "DROP DATABASE"
  "DROP TABLE"
  "TRUNCATE TABLE"
)

for pattern in "${BLOCK_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qi "$pattern"; then
    echo "{\"decision\": \"block\", \"reason\": \"Blocked outright-destructive operation: '${pattern}'. This requires explicit human confirmation. Please run this command manually if truly intended.\"}"
    exit 2
  fi
done

# Warn-and-allow patterns (log but don't block — these may be legitimate)
WARN_PATTERNS=(
  "DELETE FROM"
  "UPDATE.*SET"
  "ALTER TABLE.*DROP"
  "git reset --hard"
  "git clean -f"
)

for pattern in "${WARN_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qi "$pattern"; then
    # Log the warning
    LOG_DIR=".claude"
    mkdir -p "$LOG_DIR"
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] WARN: Potentially destructive command detected: $(echo "${INPUT:0:200}" | tr '\n' ' ')" >> "$LOG_DIR/destructive-commands.log"
    # Allow it to proceed (no block) — just logged
    break
  fi
done

# Check for DELETE without WHERE clause — block this one
if echo "$INPUT" | grep -qiE "DELETE FROM [a-z_]+ *;|DELETE FROM [a-z_]+ *$"; then
  if ! echo "$INPUT" | grep -qi "WHERE"; then
    echo "{\"decision\": \"block\", \"reason\": \"DELETE without WHERE clause detected — this would delete ALL rows. Add a WHERE clause or run manually if a full table clear is intended.\"}"
    exit 2
  fi
fi

exit 0
