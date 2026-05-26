# Claude Code Workspace Starter Kit

> A production-ready scaffold for Claude Code — structured across all 5 layers for three business personas: **Enterprise**, **SMB**, and **Startup**.

Free. Open-source. Drop it into any project in 30 seconds.

---

## What Is This?

Claude Code has a 5-layer architecture that, when used together, transforms it from a coding assistant into a full engineering platform. This starter kit gives you everything pre-configured for your team type.

```
Layer 1 — CLAUDE.md      → The Memory Layer     (always loaded, your agent's constitution)
Layer 2 — Skills         → The Knowledge Layer   (on-demand, modular context chunks)
Layer 3 — Hooks          → The Guardrail Layer   (deterministic, event-driven automation)
Layer 4 — Subagents      → The Delegation Layer  (isolated agents with scoped permissions)
Layer 5 — Plugins        → The Distribution Layer (bundled skills + hooks + agents)
```

---

## Choose Your Persona

| Persona | Best For | Key Themes |
|---|---|---|
| **Enterprise** | 100+ engineers, regulated industries | Compliance, audit trails, SOC2, change management |
| **SMB** | 5–50 people, B2B SaaS | Ship features, protect customers, pragmatic quality |
| **Startup** | 1–15 people, pre/post-launch | Velocity, MVPs, cost control, growth instrumentation |

---

## Quick Start

```bash
# Clone the repo
git clone https://github.com/sseshachala/claude-code-workspace-starter
cd claude-code-workspace-starter

# Run the installer
bash install.sh
```

The installer will:
1. Ask you to pick a persona
2. Copy the right `CLAUDE.md` to your project root
3. Copy skills, hooks, agents, and plugins to `.claude/`
4. Make all hook scripts executable
5. Merge `settings.json` with your existing Claude Code config

---

## What's Inside Each Persona

### Enterprise
- **Skills**: compliance-checker, architecture-review, incident-response, change-management, security-audit
- **Hooks**: pre-tool audit log, secrets blocker, post-tool SOC2 log, session banner
- **Agents**: security-officer, release-manager, documentation-agent
- **Plugin**: governance, SLA tracker, compliance gate, compliance bot

### SMB
- **Skills**: shipping-fast, customer-support-triage, feature-scoping, database-migrations, writing-docs
- **Hooks**: destructive command blocker, session work log, session context banner
- **Agents**: product-manager, support-agent, deploy-assistant
- **Plugin**: CRM integration, analytics queries, Slack notifier, onboarding helper

### Startup
- **Skills**: move-fast, mvp-scoping, cost-optimization, api-design, growth-hacking
- **Hooks**: cloud cost checker, commit reminder, async standup
- **Agents**: founding-engineer, growth-analyst, investor-update-writer
- **Plugin**: pitch deck assist, metrics dashboard, velocity tracker, launch coordinator

---

## Shared Components

All personas inherit from `shared/` — common skills (git-workflow, code-review, debugging, writing-tests) and hooks (secrets blocker, tool-use logger) that apply universally.

---

## Docs

- [How the 5 Layers Work](docs/how-layers-work.md)
- [Architecture Overview](docs/architecture.md)
- [Customizing Your Persona](docs/customizing-personas.md)

---

## License

MIT. Free forever. Contributions welcome.
