# Customizing Your Persona

After running `install.sh`, here's how to make the starter kit yours.

---

## Step 1 — Personalize CLAUDE.md (Do This First)

Open `CLAUDE.md` in your project root. Fill in every `[placeholder]`:

```markdown
## Project Identity
- **Company**: Acme Corp          ← replace this
- **Product**: Multi-tenant CRM   ← replace this
- **Current focus**: Q3 onboarding refactor  ← replace this
```

The sections that matter most:
1. **Project Identity** — Claude needs to know what you're building
2. **Stack** — exact versions and libraries you're using
3. **Core Rules** — the non-negotiables for your codebase
4. **Repo Map** — where things live

The rest can be filled in gradually as you work.

---

## Step 2 — Add a Custom Skill

Copy the template:
```bash
cp .claude/skills/code-review.md .claude/skills/my-skill.md
```

Edit the frontmatter:
```markdown
---
name: my-skill
description: [one sentence — used for automatic matching, be specific]
---

# My Skill

[Your instructions here]
```

**The description is critical** — it's what Claude uses to decide when to load this skill. Be specific:
- Bad: `description: helps with code`
- Good: `description: Guides Claude through reviewing Stripe webhook handlers for idempotency and signature verification`

Invoke it: `/my-skill` or Claude will auto-load it when relevant.

---

## Step 3 — Modify a Hook

Hook scripts are in `.claude/hooks/`. Each is a plain bash script.

**To change what a hook does**: edit the `.sh` file directly.

**To add a new hook**: create a new `.sh` file, then register it in `.claude/settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [{ "type": "command", "command": ".claude/hooks/my-hook.sh" }]
      }
    ]
  }
}
```

**Matcher patterns**:
- Tool name (exact): `"Bash"`, `"Write"`, `"Edit"`, `"Read"`
- Pipe-separated: `"Write|Edit"`
- Regex (for SessionStart): `".*"` matches everything

**Hook exit codes** (PreToolUse only):
```bash
# Allow the tool call
exit 0

# Block the tool call with a reason
echo '{"decision": "block", "reason": "Your reason here"}'
exit 2
```

---

## Step 4 — Add a Custom Agent

Create `.claude/agents/my-agent.md`:
```markdown
---
role: my-agent
description: What this agent does and when to use it
tools:
  - Read
  - Bash
permissions:
  - read-only
  - Bash(specific-command *)
---

# My Agent

[Agent instructions here]

## Process
1. [Step 1]
2. [Step 2]

## Output Format
[How to present results]
```

The main Claude agent will delegate to this agent when appropriate.

---

## Common Misconfigurations

### Hook not firing
1. Check `settings.json` is valid JSON: `python3 -m json.tool .claude/settings.json`
2. Check the hook script is executable: `ls -la .claude/hooks/` — should show `-rwxr-xr-x`
3. Check the matcher name matches exactly: `"Bash"` not `"bash"` (case-sensitive)
4. Check the command path is correct relative to the project root

### Skill not loading
1. Check the frontmatter is valid YAML (no tabs, consistent quotes)
2. Check the `name` field in frontmatter matches what you're invoking: `/name`
3. The `description` field must be present — it's used for matching
4. Files must be in `.claude/skills/` (not a subdirectory)

### Agent not delegating
1. The main Claude agent decides when to use subagents — it's not always automatic
2. Be explicit: "Use the [agent-name] agent to review this PR"
3. Check the agent file frontmatter has valid `role` and `tools` fields
4. Agents must be in `.claude/agents/`

---

## Testing Your Changes

1. Make a change to CLAUDE.md, a skill, or a hook
2. Start a new Claude Code session: `claude`
3. Ask Claude what it knows about the changed rule or skill
4. Verify the behavior is what you expected
5. Commit the config change to version control — it's code

---

## Adding a New Persona

1. Copy an existing persona directory: `cp -r personas/startup personas/agency`
2. Edit all five layers for the new persona
3. Add the persona to `install.sh` (the menu section)
4. Document it in `README.md`
