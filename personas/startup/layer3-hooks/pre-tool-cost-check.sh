#!/usr/bin/env bash
# PreToolUse hook on Bash — flags cloud commands that could incur unexpected costs

set -euo pipefail

INPUT="${CLAUDE_TOOL_INPUT:-}"
BUDGET="${STARTUP_MONTHLY_BUDGET:-100}"

if [[ -z "$INPUT" ]]; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('command', ''))
except:
    print('')
" 2>/dev/null || echo "")

# Cost lookup table (estimated monthly cost at small scale)
declare -A COST_ESTIMATE
COST_ESTIMATE["aws ec2 run-instances"]="100+ per instance/month"
COST_ESTIMATE["aws rds create-db-instance"]="50–500 per DB/month"
COST_ESTIMATE["gcloud compute instances create"]="50–200 per instance/month"
COST_ESTIMATE["heroku addons:add"]="varies — check Heroku pricing"
COST_ESTIMATE["vercel teams add"]="20+ per member/month"
COST_ESTIMATE["supabase db create"]="25+ per project/month"
COST_ESTIMATE["railway up"]="5–50 per service/month"

FLAGGED=false
COST_MSG=""

for pattern in "${!COST_ESTIMATE[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    FLAGGED=true
    COST_MSG="${COST_ESTIMATE[$pattern]}"
    break
  fi
done

if [[ "$FLAGGED" == "true" ]]; then
  echo "{\"decision\": \"block\", \"reason\": \"Cost check: This command ('${COMMAND:0:80}') may add infrastructure at approximately \$${COST_MSG}. Your current budget threshold is \$${BUDGET}/month. Confirm this is intentional and that it fits within budget before running manually.\"}"
  exit 2
fi

# Also flag vercel --prod deploys to ensure they're intentional
if echo "$COMMAND" | grep -qi "vercel.*--prod"; then
  # Log it but allow
  mkdir -p ".claude"
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] PROD DEPLOY: $COMMAND" >> ".claude/deploy-log.log"
fi

exit 0
