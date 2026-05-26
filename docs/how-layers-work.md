# How the 5 Layers Work

A practical guide to the Claude Code architecture used in this starter kit.

---

## Layer 1 — CLAUDE.md (The Memory Layer)

**What it is**: A markdown file that Claude reads at the start of every session. It is your agent's constitution.

**How it's loaded**: Automatically. Claude Code reads `CLAUDE.md` from the project root at session start, every time. You don't invoke it — it's always there.

**What to put in it**:
- Architecture rules and constraints
- Naming conventions
- What Claude should always/never do
- Current sprint focus and team context
- Repo map

**The two levels**:
- `~/.claude/CLAUDE.md` — global, applies to all projects
- `.claude/CLAUDE.md` (or root `CLAUDE.md`) — project-specific, overrides or extends global

**File in this kit**: `personas/[persona]/layer1-memory/CLAUDE.md`

**Example**:
```markdown
## Core Rules
- NEVER commit secrets — use Vault / Secrets Manager
- All SQL via ORM — no raw queries
- Feature flags required for anything touching auth or billing
```

---

## Layer 2 — Skills (The Knowledge Layer)

**What it is**: Markdown files that contain deep, reusable expertise — loaded on-demand when relevant.

**How they're loaded**: Claude Code matches skill files against the current task description. When a match is found, the skill is loaded into context as an isolated chunk. This keeps the main context clean — you don't pay for skills you're not using.

**Format**:
```markdown
---
name: skill-name
description: one-line description used for matching
---

# Skill content
[Detailed instructions, checklists, templates, examples]
```

**Where to put them**: `.claude/skills/` (project-level)

**Files in this kit**: `personas/[persona]/layer2-skills/`

**Invocation**: Either automatic (Claude matches based on task) or explicit: `/skill-name` in your message.

---

## Layer 3 — Hooks (The Guardrail Layer)

**What it is**: Shell scripts that execute automatically in response to Claude Code events. Deterministic — not AI-driven.

**Events available**:
| Event | Fires when |
|---|---|
| `PreToolUse` | Before Claude calls a tool |
| `PostToolUse` | After Claude calls a tool |
| `SessionStart` | When a new Claude Code session begins |
| `Stop` | When Claude finishes a response |
| `SubagentStop` | When a subagent finishes |

**Configuration** — in `.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": ".claude/hooks/block-dangerous.sh" }]
      }
    ]
  }
}
```

**Exit codes** (for PreToolUse):
- Exit `0`: allow the tool call
- Exit `2` + JSON stdout `{"decision":"block","reason":"..."}`: block the tool call

**Files in this kit**: `personas/[persona]/layer3-hooks/`

---

## Layer 4 — Subagents (The Delegation Layer)

**What it is**: Isolated agents with their own context window, custom tools, and scoped permissions. The main agent delegates tasks to subagents; subagents cannot spawn further subagents.

**Why use them**: Keeps the main context clean. A code review agent, a security audit agent, and a documentation agent can each do their job in isolation without polluting each other's context.

**Format**:
```markdown
---
role: agent-name
description: what this agent does
tools:
  - Read
  - Bash
permissions:
  - read-only
  - Bash(git log *)
---

# Agent instructions
[Detailed mandate, process, output format]
```

**Where to put them**: `.claude/agents/`

**Files in this kit**: `personas/[persona]/layer4-subagents/`

---

## Layer 5 — Plugins (The Distribution Layer)

**What it is**: A bundled package of skills + hooks + agents with a manifest. Think npm packages for Claude Code capabilities.

**Why use them**: Lets you share a complete capability set across projects or with your team. Install once, use everywhere.

**Manifest format** — `manifest.json`:
```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "...",
  "skills": ["skills/my-skill.md"],
  "hooks": { "PreToolUse": [{ "matcher": "Bash", "command": "hooks/my-hook.sh" }] },
  "agents": ["agents/my-agent.md"],
  "requirements": { "env": [{ "name": "MY_API_KEY", "required": true }] }
}
```

**Where to put them**: `.claude/plugins/local/[plugin-name]/`

**Files in this kit**: `personas/[persona]/layer5-plugins/`

---

## How They Work Together

```
User prompt
    ↓
[Layer 1] CLAUDE.md loaded — rules and context always active
    ↓
[Layer 2] Relevant skill matched and loaded for this task
    ↓
[Layer 3] Hook fires before each tool call (PreToolUse)
    ↓
Claude calls tool
    ↓
[Layer 3] Hook fires after tool call (PostToolUse)
    ↓
[Layer 4] Main agent delegates to subagent for isolated review
    ↓
[Layer 5] Plugin provides additional skills/hooks from distributed package
    ↓
Response to user
```
