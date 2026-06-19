# claude-bootstrap

A self-contained kit that turns a Claude Code install into a calibrated, opinionated, well-organized workspace, tailored to the **specific person** running it.

Not a "copy this dotfiles repo" tool. The bootstrap skill audits what's already on your machine, asks you targeted questions, then implements your system based on your answers and your existing patterns.

## What it gives you

- **Backup-first**: Nothing gets touched until a full `~/.claude/` snapshot is taken and verified.
- **Audit**: Reads your existing config, work folders, shell history, and git identity to surface your actual patterns before recommending anything.
- **Calibrated questions**: Asks only what it couldn't infer. No generic onboarding script.
- **Mandatory safety pack**: Layered secrets-deny protection (Anthropic confirmed `.env` leak via `Bash(cat)` even when `.gitignore`'d).
- **Proven core skills**: session-init manifest protocol, `/save` (workstream-aware), `/memory-audit`, `/retrospective`.
- **Opt-in best-practice library**: `/catchup`, `/ship`, `/clear-handoff`, `/compact-at-50`, `/plan-then-build`, `/workstream-init`, `/model-router`, `/subagent-brief`, `/worktree-spawn`, `/extract-skill`, `/fewer-permission-prompts`, `/bod` (beginning of day), `/eod` (end of day), `/instinct-export` + `/instinct-import` (portable rules between machines), `/skill-health` (skill library audit), `/rules-distill` (extract rules from session).
- **Curated MCPs**: Context7 (live docs), Playwright (browser). Hard ceiling 4–6 MCPs total — research-backed.
- **Curated hooks**: block-dangerous-bash, protect-secrets, auto-format, conventional-commit. Block at submit, not at write.
- **Workstream-home pattern**: Each project owns its own `CLAUDE.md` + `_memory/` + `_scripts/`. Claude Code auto-loads hierarchically.
- **Active Work + Heat Map**: 3-bucket (Do today / Waiting / Parked) + workstream temperature board, refreshed on `/save`.
- **Anti-pattern guard**: README + bootstrap docs link to the research the kit is built on, so you absorb failure modes before adopting power tools.

## How it works

**Fastest path (one command):**

```bash
curl -fsSL https://raw.githubusercontent.com/zaidqmr/claude-bootstrap/main/install.sh | bash
```

That self-clones the repo to `~/claude-bootstrap` and installs the `/bootstrap` skill. Nothing else changes.

Then:

```bash
claude
> /bootstrap

  → Phase 0 · Backup snapshot of ~/.claude/
  → Phase 1 · Audit existing setup + work patterns
  → Phase 2 · Calibrated questions
  → Phase 3 · Context-specific deep research (spawns agents)
  → Phase 4 · Synthesize tailored install plan
  → Phase 4.5 · Judgment (per-skill INSTALL/OFFER/SKIP/DEFER calibrated to this user)
  → Phase 5 · Show plan as diff
  → Phase 6 · Implement on confirmation
  → Phase 7 · Report + rollback command + first 5 things to try
```

**Manual path (if you prefer to inspect first):**

```bash
git clone https://github.com/zaidqmr/claude-bootstrap.git
cd claude-bootstrap
bash install.sh
```

Then `claude` + `/bootstrap`.

## Updating later

```bash
cd path/to/claude-bootstrap
bash update.sh
```

Pulls the latest kit and re-installs `/bootstrap`. Your existing CLAUDE.md, MEMORY.md, and other skills are untouched.

## What's in this folder

```
README.md                  this file
INSTALL.md                 one-page setup for the recipient
RESEARCH.md                curated sources backing every design decision in this kit
install.sh                  drops /bootstrap into ~/.claude/skills/, nothing else
bootstrap/
  SKILL.md                 the /bootstrap skill — audit + ask + implement
backup/
  backup.sh                creates ~/.claude/backups/pre-bootstrap-<ts>/
  restore.sh               rolls back from any backup snapshot
core/
  templates/               CLAUDE.md, MEMORY.md, workstream scaffolds (path-portable)
  skills/                  always-installed: save, memory-audit, session-init, retrospective
  settings/                settings.json.template + mandatory secrets-deny-pack.json
optional/
  skills/                  opt-in during /bootstrap: catchup, ship, clear-handoff,
                           compact-at-50, plan-then-build, workstream-init, model-router,
                           subagent-brief, worktree-spawn, extract-skill,
                           fewer-permission-prompts
  hooks/                   block-dangerous-bash, protect-secrets, auto-format, commit-lint
  mcps/                    Context7 + Playwright install notes
examples/
  workstream_examples/     reference workstream CLAUDE.md + _memory/ for inspiration
```

## Design principles (from the research)

1. **CLAUDE.md is context, not enforcement.** Hard rules go in PreToolUse hooks.
2. **CLAUDE.md target <200 lines** per Anthropic. Bloat degrades adherence.
3. **`.claude/skills/<name>/SKILL.md`** is the canonical primitive (not `.claude/commands/`).
4. **4–6 MCPs max.** More degrades the agent into tool-search mode.
5. **Block at submit, not at write.** Mid-plan PreToolUse blocks confuse the agent.
6. **Subagents can't prompt for permission.** Restrict them to read-only tools.
7. **Auto-memory at `~/.claude/projects/<project>/memory/MEMORY.md`** loads first 200 lines or 25 KB.
8. **Sync only the durable subset** across machines. Never sync `projects/`, `history.jsonl`, `shell-snapshots/`, `.credentials.json`.
9. **`/compact` at 50%, not 95%.** Performance degrades past 60–70% fill.
10. **`/model opusplan`** for cost: Opus plans, Sonnet implements (60–80% cost cut).

Full research with sources in `RESEARCH.md`.

## Provenance

This kit is built on:
- Anthropic's official Claude Code docs (`code.claude.com`)
- Community curated lists (hesreallyhim/awesome-claude-code, obra/superpowers)
- Battle-tested anti-pattern posts (Shrivu Shankar, AI Codex, Substratia, codewithmukesh)
- A working production system (Zaid's setup) — the manifest protocol, workstream-home pattern, memory typology, Active Work + Heat Map, `/save`, `/memory-audit` are all extracted from a real daily-use system.

Hand it to anyone running Claude Code. The bootstrap calibrates the rest.
