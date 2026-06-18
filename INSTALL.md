# Install · Claude Code bootstrap kit

One-page setup. Designed for someone who has Claude Code installed and wants a calibrated, opinionated workspace.

## Prerequisites

- Claude Code installed (`claude --version` should print 2.1.59 or higher)
- Python 3 available on PATH
- Git installed
- This folder on your machine

## Step 1 · Clone + run the installer

```bash
gh repo clone zaidqmr/claude-bootstrap
cd claude-bootstrap
bash install.sh
```

If `gh` isn't installed, fall back to plain git:

```bash
git clone https://github.com/zaidqmr/claude-bootstrap.git
cd claude-bootstrap
bash install.sh
```

This drops the `/bootstrap` skill into `~/.claude/skills/bootstrap/`. Nothing else is touched yet.

## Step 2 · Open Claude Code anywhere

```bash
cd ~
claude
```

When the session opens, the only thing on your machine that changed is one new skill. Your existing `~/.claude/CLAUDE.md`, settings, commands, sessions — all untouched.

## Step 3 · Run /bootstrap

In the Claude Code session:

```
/bootstrap
```

The skill will:

1. **Take a full backup** of `~/.claude/` to `~/.claude/backups/pre-bootstrap-<timestamp>/`. Will not proceed if the backup verification fails.
2. **Audit your machine** — reads your existing config, lists slash commands you have, scans recent CWDs from sessions, reads your git config, detects existing MCPs. Surfaces an inferred workflow profile.
3. **Ask you questions** based on what it found. Not a generic survey — only questions the audit couldn't answer. Examples:
   - "I see these 4 project folders touched in the last 30 days. Which are active workstreams?"
   - "I see you've manually run `git pull && pnpm install` ten times in recent shell history. Convert to a slash command?"
   - "You don't have a secrets-deny pack and your `~/.bashrc` exports API keys. Install the layered protection? (recommended yes)"
4. **Show a plan** as a diff: every file it will write, every change it will make.
5. **Wait for your confirmation** before any write.
6. **Apply changes** on your okay.
7. **Print first 5 things to try** + the rollback command if you want to undo.

## Step 4 (optional) · Roll back

If anything looks wrong:

```bash
bash ~/.claude/backups/pre-bootstrap-<timestamp>/rollback.sh
```

This restores `~/.claude/` to the state it was in before `/bootstrap` ran. Idempotent — safe to run multiple times.

## What happens if you re-run /bootstrap

It detects the previous run, asks if you want to add new pieces or reconfigure existing ones. It will not double-install skills. Re-running is safe.

## Where to look next

- `README.md` — what this kit is, design principles
- `RESEARCH.md` — sources backing every recommendation
- `core/skills/*/SKILL.md` — read these to understand the always-installed skills
- `optional/skills/*/SKILL.md` — read these to decide which to opt into

If you want the short version: just type `/bootstrap` and answer the questions. The kit handles the rest.
