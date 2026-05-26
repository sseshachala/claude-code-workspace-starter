# Architecture Overview

## The 5-Layer Stack

```
┌─────────────────────────────────────────────────────────────────────┐
│  USER PROMPT                                                        │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  LAYER 1 — CLAUDE.md (Memory Layer)                                 │
│  Always loaded. Sets rules, conventions, context, repo map.         │
│  Files: CLAUDE.md (root), ~/.claude/CLAUDE.md (global)              │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  LAYER 2 — SKILLS (Knowledge Layer)                                 │
│  On-demand. Matched by description, loaded as context chunks.       │
│  Files: .claude/skills/*.md                                         │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  LAYER 3 — HOOKS (Guardrail Layer)                                  │
│  Deterministic. Fires on events: PreToolUse, PostToolUse,           │
│  SessionStart, Stop. Configured in .claude/settings.json.           │
│  Files: .claude/hooks/*.sh                                          │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  LAYER 4 — SUBAGENTS (Delegation Layer)                             │
│  Isolated context. Custom tools. Scoped permissions.               │
│  Cannot spawn further subagents.                                    │
│  Files: .claude/agents/*.md                                         │
└─────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│  LAYER 5 — PLUGINS (Distribution Layer)                             │
│  Bundled skills + hooks + agents. Shareable across projects/teams.  │
│  Files: .claude/plugins/local/[name]/manifest.json                  │
└─────────────────────────────────────────────────────────────────────┘
```

## Persona Comparison

| Dimension | Enterprise | SMB | Startup |
|---|---|---|---|
| Team size | 100+ | 5–50 | 1–15 |
| Primary goal | Compliance + quality | Ship + protect customers | Speed + validation |
| Layer 1 focus | SOC2 rules, naming, audit | Customer-first rules, ORM mandates | Hypothesis-first, cost discipline |
| Layer 2 skills | compliance, architecture, incident | shipping-fast, support, migrations | mvp-scoping, cost-opt, growth |
| Layer 3 hooks | audit log, secrets, SOC2 log | destructive blocker, notify | cost check, commit reminder |
| Layer 4 agents | security officer, release mgr, doc agent | product manager, support, deploy | founding engineer, growth analyst, investor |
| Layer 5 plugin | governance, SLA, compliance bot | CRM, analytics, onboarding | pitch deck, metrics, launch |

## File Layout After Install

```
your-project/
├── CLAUDE.md                          ← Layer 1 (copied from persona)
└── .claude/
    ├── settings.json                  ← Layer 3 config (hook wiring)
    ├── skills/                        ← Layer 2
    │   ├── git-workflow.md            ← shared
    │   ├── code-review.md             ← shared
    │   ├── debugging.md               ← shared
    │   ├── writing-tests.md           ← shared
    │   └── [persona-specific].md      ← persona skills
    ├── hooks/                         ← Layer 3 scripts
    │   ├── block-secrets.sh           ← shared
    │   ├── log-tool-use.sh            ← shared
    │   ├── session-summary.sh         ← shared
    │   └── [persona-specific].sh      ← persona hooks
    ├── agents/                        ← Layer 4
    │   ├── code-reviewer.md           ← shared
    │   ├── test-writer.md             ← shared
    │   └── [persona-specific].md      ← persona agents
    └── plugins/
        └── local/
            └── [persona]/             ← Layer 5
                ├── manifest.json
                ├── skills/
                ├── hooks/
                └── agents/
```

## Design Principles

**Layered, not monolithic**: Each layer has a single responsibility. CLAUDE.md sets rules — it doesn't run scripts. Hooks enforce guardrails — they don't contain business knowledge. Skills hold knowledge — they don't have side effects.

**Persona-specific, shared foundation**: All personas share the same base skills (git, code review, debugging, tests) and hooks (secrets blocker, tool logger). The persona layer adds the opinionated, context-specific layer on top.

**Everything is a file**: No proprietary config formats. CLAUDE.md is markdown. Skills are markdown. Hook configs are JSON. Hooks are bash scripts. All readable, all editable, all version-controllable.
