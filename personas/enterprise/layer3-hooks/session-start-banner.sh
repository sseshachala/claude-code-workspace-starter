#!/usr/bin/env bash
# SessionStart hook — prints situational awareness banner at session start

set -euo pipefail

BRANCH=$(git branch --show-current 2>/dev/null || echo "N/A")
DATE=$(date "+%A, %B %d %Y — %H:%M %Z")

echo ""
echo "╔═══════════════════════════════════════════════════════╗"
echo "║           Enterprise Claude Code Session               ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo "  Date   : $DATE"
echo "  Branch : $BRANCH"
echo ""

# Recent commits
echo "  Recent commits:"
git log --oneline -5 2>/dev/null | awk '{print "    " $0}' || echo "    (no git history)"
echo ""

# Unstaged changes
CHANGES=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
if [[ "$CHANGES" -gt 0 ]]; then
  echo "  ⚠️  Unstaged changes: $CHANGES file(s)"
  git status --short 2>/dev/null | head -5 | awk '{print "    " $0}'
  echo ""
fi

# Open PRs (requires gh CLI)
if command -v gh &>/dev/null; then
  echo "  Open PRs:"
  gh pr list --state open --limit 5 --json number,title,author \
    --template '{{range .}}    #{{.number}} {{.title}} ({{.author.login}}){{"\n"}}{{end}}' 2>/dev/null \
    || echo "    (gh CLI not authenticated)"
  echo ""
fi

# Compliance reminder
echo "  Compliance reminders:"
echo "    ✓ Run npm audit before submitting PR"
echo "    ✓ Reference JIRA ticket in all commits"
echo "    ✓ No secrets in code — use Vault / Secrets Manager"
echo "    ✓ All PII must be encrypted at rest"
echo ""
echo "  Hooks active: secrets-blocker, audit-log, SOC2-log"
echo "═══════════════════════════════════════════════════════"
echo ""
