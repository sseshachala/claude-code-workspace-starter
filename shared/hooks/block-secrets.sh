#!/usr/bin/env bash
# PreToolUse hook on Write/Edit — blocks writing credentials to disk
# Exit code 2 + JSON = block the tool call

set -euo pipefail

INPUT="${CLAUDE_TOOL_INPUT:-}"

if [[ -z "$INPUT" ]]; then
  exit 0
fi

# Patterns that indicate secrets
PATTERNS=(
  'AKIA[0-9A-Z]{16}'                    # AWS Access Key
  'aws_secret_access_key\s*=\s*\S+'     # AWS Secret
  '-----BEGIN (RSA|EC|OPENSSH) PRIVATE' # Private key header
  'password\s*=\s*["\x27][^"\x27]{8,}' # Hardcoded password
  'secret\s*=\s*["\x27][^"\x27]{8,}'   # Hardcoded secret
  'api_key\s*=\s*["\x27][^"\x27]{8,}'  # Hardcoded API key
  'sk-[a-zA-Z0-9]{32,}'                # OpenAI/Anthropic style key
  'ghp_[a-zA-Z0-9]{36}'               # GitHub Personal Access Token
  'xoxb-[0-9]+-[a-zA-Z0-9]+'          # Slack Bot Token
)

for pattern in "${PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qiE "$pattern" 2>/dev/null; then
    echo "{\"decision\": \"block\", \"reason\": \"Potential secret detected matching pattern: ${pattern}. Review the content before writing. Use environment variables or a secrets manager instead.\"}"
    exit 2
  fi
done

exit 0
