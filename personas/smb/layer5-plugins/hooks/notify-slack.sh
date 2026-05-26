#!/usr/bin/env bash
# PostToolUse hook — sends Slack notification for deploys and migrations

set -euo pipefail

SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-}"
TOOL="${CLAUDE_TOOL_NAME:-}"
INPUT="${CLAUDE_TOOL_INPUT:-}"

# Only notify for Bash commands
if [[ "$TOOL" != "Bash" ]]; then
  exit 0
fi

# Only notify if Slack webhook is configured
if [[ -z "$SLACK_WEBHOOK_URL" ]]; then
  exit 0
fi

# Only notify for deploy/migration patterns
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('command', ''))
except:
    print('')
" 2>/dev/null || echo "")

NOTIFY_PATTERNS=("vercel" "deploy" "migrate" "prisma migrate" "knex migrate" "git push origin main")
SHOULD_NOTIFY=false

for pattern in "${NOTIFY_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    SHOULD_NOTIFY=true
    break
  fi
done

if [[ "$SHOULD_NOTIFY" != "true" ]]; then
  exit 0
fi

BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
TIMESTAMP=$(date "+%H:%M %Z")
TRUNCATED_CMD="${COMMAND:0:100}"

curl -s -X POST "$SLACK_WEBHOOK_URL" \
  -H 'Content-type: application/json' \
  -d "{
    \"text\": \"🚀 *Claude ran a deploy/migration*\",
    \"attachments\": [{
      \"color\": \"good\",
      \"fields\": [
        {\"title\": \"Command\", \"value\": \"\`${TRUNCATED_CMD}\`\", \"short\": false},
        {\"title\": \"Branch\", \"value\": \"${BRANCH}\", \"short\": true},
        {\"title\": \"Time\", \"value\": \"${TIMESTAMP}\", \"short\": true}
      ]
    }]
  }" &>/dev/null

exit 0
