#!/usr/bin/env bash
# PreToolUse hook on Write/Edit — blocks changes to regulated paths without a ticket reference

set -euo pipefail

INPUT="${CLAUDE_TOOL_INPUT:-}"
TOOL="${CLAUDE_TOOL_NAME:-}"
JIRA_KEY="${JIRA_PROJECT_KEY:-ENG}"

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('file_path', d.get('path', '')))
except:
    print('')
" 2>/dev/null || echo "")

if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Check if the file is in a regulated path
REGULATED_PATTERNS=(
  "src/auth/"
  "src/billing/"
  "migrations/"
  "infra/"
  "ci/"
  ".env"
  "secret"
  "credential"
  "config.production"
)

IS_REGULATED=false
for pattern in "${REGULATED_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -qi "$pattern"; then
    IS_REGULATED=true
    break
  fi
done

if [[ "$IS_REGULATED" == "false" ]]; then
  exit 0
fi

# Check for ticket reference in current branch name
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
TICKET_REGEX="${JIRA_KEY}-[0-9]+"

if echo "$BRANCH" | grep -qiE "$TICKET_REGEX"; then
  exit 0
fi

# Check for ticket reference in last commit message
LAST_COMMIT=$(git log -1 --format="%s" 2>/dev/null || echo "")
if echo "$LAST_COMMIT" | grep -qiE "$TICKET_REGEX"; then
  exit 0
fi

# No ticket reference found — block
echo "{\"decision\": \"block\", \"reason\": \"Regulated path detected: '${FILE_PATH}'. A ${JIRA_KEY}-XXXX ticket reference is required in your branch name or commit message before modifying this file. Create a ticket, then: git checkout -b feat/${JIRA_KEY}-XXX-description\"}"
exit 2
