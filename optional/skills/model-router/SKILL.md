---
name: model-router
description: Configure /model opusplan as default — Opus plans, Sonnet implements. 60-80% cost cut at near-zero quality loss for most tasks.
user-invocable: true
allowed-tools: Read, Bash
---

# /model-router

Configures and explains Anthropic's `opusplan` model mode + when to switch.

## What it does

`/model opusplan` makes Claude Code:
- Plan tasks (decompose, decide approach) using **Opus**
- Execute mechanical work (edits, tests, refactors) using **Sonnet**

Token cost drops 60–80% vs all-Opus on multi-step work, with no measurable quality loss on the implementation steps (Opus's planning advantage is what matters for the hard parts).

## Setup

Run once:

```bash
# In a Claude Code session:
/model opusplan
```

This persists for the session. To make it default, add to `~/.claude/settings.json`:

```json
{
  "modelMode": "opusplan"
}
```

(Confirm key name with `claude --help` for your version.)

## When to switch out

- **`/model haiku`** — mechanical/large-scale renames, bulk formatting, file moves where speed matters more than reasoning
- **`/model opus`** — pure-planning sessions, deep code review, architecture decisions, research synthesis
- **`/model sonnet`** — default fallback if opusplan is unavailable on your plan

## When to stay on opusplan

- Any task with ≥2 distinct steps
- Refactors, migrations, feature implementation
- Test writing where the test design needs thought
- Multi-file changes

## Sources
- https://code.claude.com/docs/en/costs
- https://marmelab.com/blog/2026/04/24/claude-code-tips-i-wish-id-had-from-day-one.html
- https://claudefa.st/blog/guide/development/usage-optimization
