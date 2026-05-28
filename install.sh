#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-$(pwd)}"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Claude Code Workspace Starter Kit        ║${NC}"
echo -e "${BLUE}║     5-Layer Setup — Choose Your Persona      ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "Installing into: ${TARGET_DIR}"
echo ""

echo "Which persona best describes your team?"
echo ""
echo "  1) Enterprise  — 100+ engineers, compliance, SOC2, audit trails"
echo "  2) SMB         — 5–50 people, B2B SaaS, pragmatic quality"
echo "  3) Startup     — 1–15 people, move fast, MVPs, growth"
echo ""
read -p "Enter choice [1-3]: " choice

case $choice in
  1) PERSONA="enterprise" ;;
  2) PERSONA="smb" ;;
  3) PERSONA="startup" ;;
  *)
    echo -e "${RED}Invalid choice. Exiting.${NC}"
    exit 1
    ;;
esac

PERSONA_DIR="$SCRIPT_DIR/personas/$PERSONA"
SHARED_DIR="$SCRIPT_DIR/shared"
CLAUDE_DIR="$TARGET_DIR/.claude"

# Timestamp used for all backups created during this run (e.g. 20260528_153045)
BACKUP_TIMESTAMP="$(date +%Y%m%d_%H%M%S)"

echo ""
echo -e "${GREEN}Selected: ${PERSONA}${NC}"
echo ""

# Create .claude directory structure
mkdir -p "$CLAUDE_DIR"/{skills,hooks,agents,plugins/local}

# ── Layer 1: CLAUDE.md ────────────────────────────────────────────────────────
echo -e "  ${BLUE}[Layer 1]${NC} Installing CLAUDE.md (Memory Layer)..."
if [[ -f "$TARGET_DIR/CLAUDE.md" ]]; then
  BAK_FILE="$TARGET_DIR/CLAUDE.md.bak.${BACKUP_TIMESTAMP}"
  echo -e "  ${YELLOW}Warning:${NC} CLAUDE.md already exists. Saving backup to CLAUDE.md.bak.${BACKUP_TIMESTAMP}"
  cp "$TARGET_DIR/CLAUDE.md" "$BAK_FILE"
fi
cp "$PERSONA_DIR/layer1-memory/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
echo -e "  ${GREEN}✓${NC} CLAUDE.md installed"

# ── Layer 2: Skills ───────────────────────────────────────────────────────────
echo -e "  ${BLUE}[Layer 2]${NC} Installing Skills (Knowledge Layer)..."
# Shared skills first
if [[ -d "$SHARED_DIR/skills" ]]; then
  cp "$SHARED_DIR/skills/"*.md "$CLAUDE_DIR/skills/" 2>/dev/null || true
fi
# Persona-specific skills
if [[ -d "$PERSONA_DIR/layer2-skills" ]]; then
  cp "$PERSONA_DIR/layer2-skills/"*.md "$CLAUDE_DIR/skills/" 2>/dev/null || true
fi
SKILL_COUNT=$(ls "$CLAUDE_DIR/skills/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} ${SKILL_COUNT} skills installed"

# ── Layer 3: Hooks ────────────────────────────────────────────────────────────
echo -e "  ${BLUE}[Layer 3]${NC} Installing Hooks (Guardrail Layer)..."
# Shared hooks
if [[ -d "$SHARED_DIR/hooks" ]]; then
  cp "$SHARED_DIR/hooks/"*.sh "$CLAUDE_DIR/hooks/" 2>/dev/null || true
fi
# Persona-specific hooks
if [[ -d "$PERSONA_DIR/layer3-hooks" ]]; then
  cp "$PERSONA_DIR/layer3-hooks/"*.sh "$CLAUDE_DIR/hooks/" 2>/dev/null || true
fi
# Make all hooks executable
chmod +x "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null || true

# Merge settings.json
PERSONA_SETTINGS="$PERSONA_DIR/layer3-hooks/settings.json"
TARGET_SETTINGS="$CLAUDE_DIR/settings.json"
if [[ -f "$PERSONA_SETTINGS" ]]; then
  if [[ -f "$TARGET_SETTINGS" ]]; then
    SETTINGS_BAK="${TARGET_SETTINGS}.bak.${BACKUP_TIMESTAMP}"
    echo -e "  ${YELLOW}Warning:${NC} .claude/settings.json exists. Saving backup to settings.json.bak.${BACKUP_TIMESTAMP}"
    cp "$TARGET_SETTINGS" "$SETTINGS_BAK"
  fi
  cp "$PERSONA_SETTINGS" "$TARGET_SETTINGS"
fi

HOOK_COUNT=$(ls "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} ${HOOK_COUNT} hook scripts installed and made executable"

# ── Layer 4: Subagents ────────────────────────────────────────────────────────
echo -e "  ${BLUE}[Layer 4]${NC} Installing Subagents (Delegation Layer)..."
# Shared agents
if [[ -d "$SHARED_DIR/agents" ]]; then
  cp "$SHARED_DIR/agents/"*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true
fi
# Persona-specific agents
if [[ -d "$PERSONA_DIR/layer4-subagents" ]]; then
  cp "$PERSONA_DIR/layer4-subagents/"*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true
fi
AGENT_COUNT=$(ls "$CLAUDE_DIR/agents/"*.md 2>/dev/null | wc -l | tr -d ' ')
echo -e "  ${GREEN}✓${NC} ${AGENT_COUNT} agent definitions installed"

# ── Layer 5: Plugins ──────────────────────────────────────────────────────────
echo -e "  ${BLUE}[Layer 5]${NC} Installing Plugin (Distribution Layer)..."
if [[ -d "$PERSONA_DIR/layer5-plugins" ]]; then
  PLUGIN_DEST="$CLAUDE_DIR/plugins/local/$PERSONA"
  mkdir -p "$PLUGIN_DEST"/{skills,hooks,agents}
  cp "$PERSONA_DIR/layer5-plugins/manifest.json" "$PLUGIN_DEST/" 2>/dev/null || true
  cp "$PERSONA_DIR/layer5-plugins/skills/"*.md "$PLUGIN_DEST/skills/" 2>/dev/null || true
  cp "$PERSONA_DIR/layer5-plugins/hooks/"*.sh "$PLUGIN_DEST/hooks/" 2>/dev/null || true
  chmod +x "$PLUGIN_DEST/hooks/"*.sh 2>/dev/null || true
  cp "$PERSONA_DIR/layer5-plugins/agents/"*.md "$PLUGIN_DEST/agents/" 2>/dev/null || true
fi
echo -e "  ${GREEN}✓${NC} Plugin installed at .claude/plugins/local/${PERSONA}/"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Installation Complete!                      ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo "  Persona   : ${PERSONA}"
echo "  CLAUDE.md : ${TARGET_DIR}/CLAUDE.md"
echo "  Skills    : ${CLAUDE_DIR}/skills/"
echo "  Hooks     : ${CLAUDE_DIR}/hooks/"
echo "  Agents    : ${CLAUDE_DIR}/agents/"
echo "  Plugin    : ${CLAUDE_DIR}/plugins/local/${PERSONA}/"
echo ""
echo "Next steps:"
echo "  1. Edit CLAUDE.md with your project-specific context"
echo "  2. Set required env vars (see .claude/plugins/local/${PERSONA}/manifest.json)"
echo "  3. Run 'claude' to start your first session"
echo ""
echo "Read the docs: https://github.com/yourusername/claude-code-workspace-starter"
echo ""
