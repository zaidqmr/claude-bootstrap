---
name: bootstrap
description: Audits the user's existing Claude Code setup + work patterns, asks calibrated questions, deep-researches skills/MCPs/patterns specific to their actual work, then installs a tailored Claude Code system. Backup-first. Never touches files until the user confirms the plan.
when_to_use: First-time setup on a fresh machine, or when the user wants a clean redesign of their existing Claude Code workspace.
user-invocable: true
disable-model-invocation: false
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, WebSearch, WebFetch, Agent
---

# /bootstrap

Calibrates Claude Code to the **specific person** running this command. Not a generic install.

Seven phases, in order. Do not skip any. Do not write or move ANY file until Phase 6.

---

## Phase 0 · Backup (mandatory, blocking)

Before reading ANY file or asking ANY question, take a full backup of `~/.claude/`.

Run the bundled backup script:

```bash
bash ${CLAUDE_SKILL_DIR}/lib/backup.sh
```

Capture the `SNAPSHOT_PATH=...` line from stdout. Store it as `BACKUP_PATH`.

If the script exits non-zero, **STOP**. Tell the user:
> "Backup failed: <error>. I won't make any changes until backup succeeds. Try checking disk space or permissions on ~/.claude/, then re-run /bootstrap."

Don't continue. Don't try to "skip the backup just this once."

Once backup succeeds, tell the user:
> "Backup complete at `<BACKUP_PATH>`. If anything goes wrong, restore with: `bash <BACKUP_PATH>/rollback.sh`. Now starting the audit."

---

## Phase 1 · Audit

Read the user's existing setup AND their work patterns. Read-only — do not write anything yet.

### 1.1 · Current Claude Code config

```bash
ls -la ~/.claude/                              # what dirs/files exist
cat ~/.claude/CLAUDE.md 2>/dev/null             # existing constitution (if any)
cat ~/.claude/settings.json 2>/dev/null         # hooks, permissions, plugins
cat ~/.claude/settings.local.json 2>/dev/null   # local overrides
ls ~/.claude/commands/ 2>/dev/null              # legacy slash commands
ls ~/.claude/skills/ 2>/dev/null                # new-format skills
ls ~/.claude/agents/ 2>/dev/null                # subagents
ls ~/.claude/rules/ 2>/dev/null                 # path-scoped rules
claude mcp list 2>/dev/null                     # installed MCP servers
claude --version                                # version check
ls ~/.claude/projects/ 2>/dev/null              # which CWDs they've worked in
```

Record:
- Whether they have a CLAUDE.md yet (and size if so)
- Whether they have a session-gate/manifest protocol (look for `.claude-manifest.json` references in CLAUDE.md)
- Existing skills/commands by name
- Existing MCPs by name
- Settings shape (auto mode? hooks? permissions?)

### 1.2 · Work patterns

```bash
# Recent CWDs Claude has been opened in
ls -lt ~/.claude/projects/ | head -20

# Most recent shell history (last 200 commands)
tail -200 ~/.bash_history 2>/dev/null || tail -200 ~/.zsh_history 2>/dev/null || echo "no shell history found"

# Git identity (used for committer signature, indicates work email pattern)
git config --global user.name
git config --global user.email
git config --global --list 2>/dev/null | head -20

# Home dir top-level — what folders does this person actually have?
ls -la ~/ | head -40

# Common work-folder locations
for d in ~/Documents ~/Downloads ~/projects ~/code ~/work ~/dev ~/repos; do
  if [ -d "$d" ]; then
    echo "=== $d ==="
    ls -lt "$d" | head -10
  fi
done
```

Look for:
- **Active project folders** (folders touched in last 30 days that contain code, docs, content)
- **Repeated shell commands** (same command run ≥3 times in recent history — slash-command candidates)
- **Tech stack signals** (`package.json` → Node; `requirements.txt`/`pyproject.toml` → Python; `Cargo.toml` → Rust; `go.mod` → Go; `*.tf` → Terraform; `dockerfile` → containers; `*.figma` → design; `*.mp4`/`*.psd` → media)
- **Discipline** (designer? engineer? writer? PM? founder? mixed?)
- **Existing organization habits** (per-project folders? monorepo? everything in Downloads?)

### 1.3 · Synthesize the audit

Produce a structured profile:

```
AUDIT FINDINGS

Identity:
  - Name (from git): <name>
  - Email (from git): <email>
  - Machine: <hostname>
  - OS: <macOS/Linux/Windows>
  - Claude Code: <version>

Existing Claude Code setup:
  - CLAUDE.md: <exists at ~/.claude/CLAUDE.md, N lines | none>
  - Session-gate protocol: <yes/no>
  - Skills installed: <list, or "none">
  - Commands installed: <list, or "none">
  - Agents: <list, or "none">
  - MCPs: <list, or "none">
  - Permissions mode: <auto/default/plan/bypassPermissions>
  - Hooks: <list events with handlers, or "none">

Inferred work profile:
  - Primary role: <engineer / designer / writer / founder / mixed — based on file types>
  - Tech stack signals: <e.g. "Node + TS + Next.js + Postgres" or "Python + Django + AWS">
  - Active project folders (touched in last 30 days): <list with last-touched date>
  - Recurring shell commands worth converting: <list of commands seen ≥3 times>
  - Existing organization pattern: <per-project folders / monorepo / scattered>

Notable gaps:
  - <e.g. "no secrets-deny pack and `.env` files in 3 active projects">
  - <e.g. "no session-gate, but you frequently /clear mid-session per session logs">
  - <e.g. "no MCPs installed; live-docs lookup is being done via web search every session">
```

**Present this profile to the user. Pause. Wait for them to read it.**

Say: "Does this look right? Anything I got wrong, or any project/role I missed?"

Update the profile based on their corrections.

---

## Phase 2 · Ask (calibrated questions only)

Ask ONLY what the audit couldn't answer. Don't ask generic onboarding questions. Examples — pick the ones that match what you found:

**Workflow rhythm**
- "I see 4 project folders touched in last 30 days. Which are active workstreams vs one-off?"
- "Your shell history shows `<command>` repeated N times. Convert to a slash command? What should it be called?"
- "Do you work on multiple machines? (For sync strategy.)"

**Tech stack**
- "I see Next.js + Postgres signals in `<folder>`. Should I install the Context7 MCP for live framework docs?"
- "I see UI work signals (Tailwind, .tsx files, design folders). Should I install Playwright MCP for browser automation?"
- "I see Terraform/k8s signals. Should I install the relevant MCPs and skills for infra work?"

**Discipline + safety**
- "I see `.env` files in active projects. The secrets-deny pack is **strongly recommended** (Anthropic's auto-load of `.env` files via `Bash(cat)` is a known leak). Install? (default: yes)"
- "Do you commit through Conventional Commits? (For commit-lint hook.)"
- "How aggressive should auto-mode be? (none / careful / aggressive)"

**Memory + workspace**
- "Want the session-gate manifest protocol? (Forces you to declare what each session is for. Battle-tested across 37+ sessions in production setups.)"
- "Want the workstream-home pattern? (Each project owns its CLAUDE.md + _memory/ + _scripts/.)"
- "Want Active Work + Heat Map sections in MEMORY.md? (Shows what's hot vs parked at a glance.)"

**Opt-in library**
For each optional skill, briefly describe it and ask yes/no:
- `/catchup` — "what happened on this branch since I last touched it"
- `/ship` — guided pre-PR review and push
- `/clear-handoff` — write a 5-line handoff doc before `/clear`
- `/compact-at-50` — auto-compact at 50% context, not 95%
- `/plan-then-build` — force Explore → Plan → Implement gate
- `/workstream-init` — scaffold a new workstream folder
- `/model-router` — `/model opusplan` as default (Opus plans, Sonnet implements)
- `/worktree-spawn` — one-command parallel feature start
- `/extract-skill` — "if I said this twice, make it a skill" reflex
- `/subagent-brief` — structured fresh-context briefing for parallel agents
- `/retrospective` — end-of-session learning loop
- `/fewer-permission-prompts` — scan transcripts, allowlist safe ops

Record their answers as `USER_PROFILE`.

---

## Phase 3 · Deep research (★ context-specific ★)

Now that you have the full picture (audit + answers), do a SECOND round of research specifically calibrated to THIS user's context. Generic best-practices research already happened when this kit was built — that's in `RESEARCH.md`. This phase is HIS research.

Spawn parallel Agent tasks based on what the audit + answers showed:

**If tech stack contains web frontend (React/Next/Vue/Svelte):**
Spawn an agent: "Research the best Claude Code skills, MCPs, and hooks specifically for `<framework>` developers in mid-2026. Report top picks with sources."

**If tech stack contains backend (Django/FastAPI/Node API/Go API/Rails):**
Spawn an agent: "Best Claude Code patterns for `<stack>` API work — testing, migrations, deploys, observability."

**If tech stack contains infrastructure (Terraform/k8s/Docker/AWS/GCP):**
Spawn an agent: "Best Claude Code skills/MCPs for infra-as-code work in `<tools>`. What do practitioners ship?"

**If tech stack contains data (notebooks/dbt/Spark/SQL):**
Spawn an agent: "Best Claude Code setup for data engineering / analytics work — what skills/MCPs/hooks?"

**If role is writer / content / non-engineering:**
Spawn an agent: "Best Claude Code patterns for non-developer power users — content workflows, document automation, voice extraction. What works?"

**If role is designer:**
Spawn an agent: "Best Claude Code patterns for designers — Figma MCPs, asset workflows, design-to-code handoff."

**Always also spawn:**
Spawn an agent: "What are the highest-leverage skills the Claude Code community shipped in the last 90 days? Focus on what's battle-tested and what's still hyped-but-broken."

Each research agent should report:
- Top 3–5 specific recommendations
- Source URLs
- Anti-patterns specific to this domain
- Skills/MCPs that are hyped but not actually useful (skip list)

When all agents return, synthesize their findings into `CONTEXT_RESEARCH`.

**Show CONTEXT_RESEARCH to the user as a brief summary.**

> "Based on the audit + your answers, I found these context-specific recommendations:
> - <Top 3 from each agent>
> Want me to include any of these in the install plan?"

Update `USER_PROFILE` with their picks.

---

## Phase 4 · Synthesize the plan

Combine `USER_PROFILE` + `CONTEXT_RESEARCH` into a single install plan. Structure:

```
INSTALL PLAN

A. Always-installed (proven core):
   1. Root CLAUDE.md (drop-in, with session gate)
   2. Global MEMORY.md (with Active Work + Scheduled Tasks + Heat Map sections)
   3. settings.json with mandatory secrets-deny pack
   4. /save skill (workstream-aware)
   5. /memory-audit skill
   6. /session-init skill
   7. /retrospective skill

B. User-opted (from Phase 2 questions):
   <list of opt-in skills with paths>
   <list of hooks with paths>
   <list of MCPs to install with commands>

C. Context-specific (from Phase 3 research):
   <list of additional skills/MCPs/configs surfaced from research, that user opted into>

D. Workstreams to scaffold:
   <list of folders the user identified as workstreams; for each:>
   - <path>/CLAUDE.md (workstream scope + load order)
   - <path>/_memory/MEMORY.md (workstream-local index)
   - <path>/_memory/ (empty, will populate via /save)

E. Existing files to preserve:
   <list of files in the current ~/.claude/ that we will NOT overwrite, with reason>

F. Existing files to merge:
   <list of files where we'll merge our additions into their existing content (e.g. settings.json)>
   For each: show the BEFORE and AFTER side-by-side.
```

---

## Phase 5 · Show plan as diff

Present the plan to the user. For every file that will be created or modified, show:

- **New file:** the full content that will be written
- **Modified file:** unified diff against current content
- **Moved file:** source → destination
- **Untouched file:** explicit list of what's NOT being changed (so they know nothing is being silently overwritten)

Ask: "Apply this plan? Reply `yes`, `no`, or `change X` to revise specific parts."

If they say no, stop. If they say change X, revise the plan and re-show.

---

## Phase 6 · Implement

Only execute writes/moves after explicit "yes".

For each item in the plan:
1. Write/edit the file
2. If the file already exists and is being overwritten, first copy it to `${BACKUP_PATH}/manual-merges/<filename>` so the merge is recoverable
3. Log the action to `${BACKUP_PATH}/install_log.tsv` (timestamp + action + path)

After all writes:
- For each MCP the user opted into, run the `claude mcp add` command (or print it for the user to run, if you can't execute it from inside a Claude session — depends on Claude Code version)
- For each hook, verify it's syntactically valid by reading it back
- Re-read settings.json to verify it parses

---

## Phase 7 · Report + first 5 things to try

Print to the user:

```
✅ Bootstrap complete.

Backup snapshot:  <BACKUP_PATH>
Rollback command: bash <BACKUP_PATH>/rollback.sh
Install log:      <BACKUP_PATH>/install_log.tsv

INSTALLED
  Core skills: <list>
  Opt-in skills: <list>
  Hooks: <list>
  MCPs: <list>
  Workstreams scaffolded: <list>

FIRST 5 THINGS TO TRY

1. End this session with `/save` — confirms memory-aware save works.
2. Type `/clear`, then start fresh in a workstream folder. Claude should auto-load that workstream's CLAUDE.md + _memory/MEMORY.md.
3. Try `/<one of the opt-in skills you chose>` to confirm it loads.
4. Run `/memory-audit` to see your current (clean) baseline.
5. If you added an MCP, ask Claude to use it in a relevant task.

WHAT NOT TO DO IN THE FIRST WEEK

- Don't add 10 more MCPs. Hard ceiling is 4–6 total.
- Don't bloat CLAUDE.md. Stay under 200 lines.
- Don't custom-build subagents for every workflow. Use Task() with the built-in Explore/Plan agents.
- Don't rely on `/compact` at 95% — run `/compact-at-50` instead.

If something feels wrong: `bash <BACKUP_PATH>/rollback.sh` puts everything back.
```

---

## Failure handling

- **Phase 0 fails (backup)** → stop, surface error, do not proceed
- **Phase 1 fails (missing tools)** → surface what's missing, ask user to install or skip that subsection
- **Phase 2 abandoned** → user can re-run /bootstrap; backup remains
- **Phase 3 research agent errors** → continue with whatever did return; note in plan what couldn't be researched
- **Phase 5 user says no** → stop cleanly, no writes happened; backup still exists for safety
- **Phase 6 partial failure** → stop on first error, surface what was already written, suggest rollback

## Re-run safety

If `/bootstrap` is run again:
1. Detect prior install via `${BACKUP_PATH}/install_log.tsv` from previous runs
2. Ask: "Add new pieces, reconfigure existing, or full reinstall?"
3. Never double-install the same skill
4. Always take a fresh backup before any change
