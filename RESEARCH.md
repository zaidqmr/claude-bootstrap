# Research backing this kit

Every recommendation in this kit traces to either Anthropic's official Claude Code docs, battle-tested community retrospectives, or a working production system. This file is the source dump.

Generated June 2026 from three parallel research passes. Re-verify periodically — Anthropic ships breaking changes regularly.

---

## Anthropic Official Guidance (mid-2026)

### Docs location

Docs moved from `docs.anthropic.com/en/docs/claude-code/` to `code.claude.com/docs/en/` (301 redirects). Always start at `code.claude.com/docs/en/`.

### CLAUDE.md

- **Canonical load order** (broad → specific):
  - Managed policy (OS-specific managed paths)
  - User: `~/.claude/CLAUDE.md`
  - Project: `./CLAUDE.md` or `./.claude/CLAUDE.md`
  - Local (gitignored): `./CLAUDE.local.md`
- **Loading**: Claude walks up from CWD and concatenates all ancestor CLAUDE.md files. Subdirectory CLAUDE.md files load on demand when Claude reads files there.
- **Size**: "target under 200 lines per CLAUDE.md file. Longer files consume more context and reduce adherence."
- **Imports**: `@path/to/file` syntax, relative-to-the-file, max depth 4 hops.
- **AGENTS.md**: Claude reads CLAUDE.md, not AGENTS.md. Use `@AGENTS.md` import.
- **CLAUDE.md is context, not enforcement**: *"Claude treats them as context, not enforced configuration. To block an action regardless of what Claude decides, use a PreToolUse hook instead."*

### Auto-memory (NEW, v2.1.59+)

- Location: `~/.claude/projects/<project>/memory/MEMORY.md`
- Load budget: "The first 200 lines of MEMORY.md, or the first 25KB, whichever comes first."
- Topic files alongside MEMORY.md load on demand.
- Toggles: `autoMemoryEnabled: false`, env var `CLAUDE_CODE_DISABLE_AUTO_MEMORY=1`.

### Skills (replaces commands)

- Location: `~/.claude/skills/<name>/SKILL.md` (personal), `./.claude/skills/<name>/SKILL.md` (project)
- `.claude/commands/*.md` is legacy-but-supported. Skills win if name collides.
- Frontmatter fields: `name`, `description`, `when_to_use`, `argument-hint`, `arguments`, `disable-model-invocation`, `user-invocable`, `allowed-tools`, `disallowed-tools`, `model`, `effort`, `context: fork`, `agent`, `hooks`, `paths`, `shell`.
- Size: "Keep SKILL.md under 500 lines."

### Hooks

- Events: SessionStart, Setup, UserPromptSubmit, UserPromptExpansion, PreToolUse, PermissionRequest, PermissionDenied, PostToolUse, PostToolUseFailure, PostToolBatch, Notification, MessageDisplay, SubagentStart, SubagentStop, TaskCreated, TaskCompleted, Stop, StopFailure, TeammateIdle, InstructionsLoaded, ConfigChange, CwdChanged, FileChanged, WorktreeCreate, WorktreeRemove, PreCompact, PostCompact, Elicitation, ElicitationResult, SessionEnd.
- **PreToolUse is the ONLY deterministic enforcement layer** (works even in bypassPermissions / `--dangerously-skip-permissions`).
- PostToolUse cannot undo; use for reacting/formatting/logging.

### MCP

- 5-tier settings precedence: Managed → CLI args → `.claude/settings.local.json` → `.claude/settings.json` → `~/.claude/settings.json`
- Add: `claude mcp add --transport <type> <name> <url-or-command>`
- Three scopes: local (per-project, private), project (`.mcp.json`, committed for team), user (cross-project)
- **Connect criterion** (Anthropic): "Connect a server when you find yourself copying data into chat from another tool."

### Subagents

- "Subagents cannot present interactive permission prompts. If a subagent invokes a tool that matches an ask rule, the call is treated as denied." → restrict subagents to read-only tools.
- Each subagent gets a *fresh* context — brief explicitly.
- Built-in agents: Explore (Haiku, read-only), Plan (read-only), general-purpose (all tools).

### Plan mode

- Activated via `Shift+Tab Shift+Tab` or `/plan` (v2.1.0+)
- "Read-only research + proposed plan, no writes/side effects until approved."
- When: ≥3 files touched, schema changes, migrations, refactors, auth/payment/db code, MCP perms, production config

### Bundled skills

Anthropic ships these by default: `/code-review`, `/debug`, `/loop`, `/batch`, `/claude-api`, `/run`, `/verify`, `/run-skill-generator`, `/fewer-permission-prompts`.

### Direct quotes worth preserving

- *"CLAUDE.md content is delivered as a user message after the system prompt, not as part of the system prompt itself."*
- *"Claude Code watches your settings files and reloads them when they change."*
- *"target under 200 lines per CLAUDE.md file."*
- *"If the instruction is something that must run at a specific point, such as before every commit or after each file edit, write it as a hook instead."*

### Sources
- https://code.claude.com/docs/en/memory
- https://code.claude.com/docs/en/hooks
- https://code.claude.com/docs/en/slash-commands
- https://code.claude.com/docs/en/settings
- https://code.claude.com/docs/en/permissions
- https://code.claude.com/docs/en/sub-agents
- https://code.claude.com/docs/en/mcp
- https://code.claude.com/docs/en/best-practices
- https://code.claude.com/docs/en/common-workflows

---

## Community Ecosystem (curated, high signal)

### Top awesome-* repos

- **hesreallyhim/awesome-claude-code** (~47k★) — canonical hand-curated list. https://github.com/hesreallyhim/awesome-claude-code
- **obra/superpowers** (~94k★, accepted into Anthropic skills marketplace) — 14-skill agentic methodology (TDD, brainstorm, plan, worktrees, code review). https://github.com/obra/superpowers
- **rohitg00/awesome-claude-code-toolkit** — 135 agents / 35 skills / 42 commands / 20 hooks / 14 MCP configs. Firehose; mine for ideas.
- **OneRedOak/claude-code-workflows** — working repo configs from an AI-native startup. https://github.com/OneRedOak/claude-code-workflows

### Battle-tested MCP servers

- **Context7** — live framework docs. `npx -y @upstash/context7-mcp`. **Recommend default install.**
- **Playwright MCP** (Microsoft) — accessibility-tree browser automation. **Recommend if any UI work.**
- **GitHub MCP** — official, PR/issue/repo ops.
- **Postgres MCP** — schema + read-only queries.
- **Brave Search MCP** — current web/news lookups when WebSearch insufficient.
- **DO NOT install Filesystem MCP** — redundant with built-in Read/Edit/Write/Glob/Grep.
- **Hard ceiling: 4–6 MCPs total.** Past ~10% context spent on tool descriptions, Claude switches to tool-search mode and degrades.

### Hook patterns

- **block-dangerous-bash** (PreToolUse) — regex-blocks `rm -rf /`, `curl | sh`, AWS-key shapes
- **protect-secrets** (PreToolUse) — refuses to touch `.env`, `*.pem`, `credentials.json`
- **auto-lint/format on write** (PostToolUse) — fires ESLint/Prettier/ruff after each save
- **Conventional-commit lint** (PreToolUse on `git commit`) — rejects non-conformant messages
- **Block at submit, not at write** — validate at commit gate; mid-plan PreToolUse blocks confuse the agent

### Anti-patterns (per community)

- **Kitchen-sink session** — mixing unrelated tasks pollutes context; `/clear` between
- **Correct-then-correct-again loop** — after 2 failed corrections, `/clear` and rewrite the prompt
- **Bloated CLAUDE.md** — 1,200+ words almost never works; rules buried on "page 3" get overridden
- **Conflicting rules in CLAUDE.md** (e.g., "never comment" + "always document")
- **Long custom slash command lists** — hidden complexity
- **Custom subagents for everything** — prefer `Task()` so orchestrator keeps holistic context
- **Block-at-write hooks** — frustrate mid-plan; gate at commit
- **20+ MCP servers** — agent burns context parsing tool descriptions; degradation starts at ~40% context fill
- **Relying on `/compact`** — prefer `/clear` + a handoff doc

### Sources
- https://blog.sshh.io/p/how-i-use-every-claude-code-feature (Shrivu Shankar, the single best opinionated post)
- https://www.aicodex.to/articles/claude-code-antipatterns
- https://www.substratia.io/blog/context-management-guide/
- https://dev.to/olivia_craft/7-claudemd-patterns-that-stop-claude-from-drifting-off-script-4dka
- https://codewithmukesh.com/blog/anatomy-of-the-claude-folder/
- https://nimbalyst.com/blog/best-claude-code-mcp-servers/
- https://claudefa.st/blog/tools/resources/awesome-claude-code

---

## Advanced Patterns (mid-2026)

### Multi-machine sync

- **Best approach**: Git-backed dotfiles repo symlinking ONLY the durable subset (`CLAUDE.md`, `settings.json`, `skills/`, `agents/`, `hooks/`).
- **Never sync**: `~/.claude/projects/`, `history.jsonl`, `shell-snapshots/`, `todos/`, `.credentials.json`, `statsig/`, `cache/`
- **3-way sync (last-sync snapshot)** avoids silent overwrite of MEMORY.md from two machines
- Sources: nickang.com/how-to-sync-claude-code-global-files; github.com/elizabethfuentes12/claude-code-dotfiles

### Team config sharing

- Project `./.claude/` committed to repo. Personal overrides in `.claude/settings.local.json` (gitignored).
- For multi-repo orgs, ship a **Plugin** — single versioned bundle of skills/agents/hooks/MCP.
- `.claude/settings.local.json` MUST be in `.gitignore`.
- Don't put secrets in CLAUDE.md — ships to every contributor.

### Cost / token management

- **`/model opusplan`** (Opus plans, Sonnet implements) cuts 60–80% of spend at near-zero quality loss.
- Manually `/compact` at ~50% context (auto-compact at 95% is too late).
- `/clear` between unrelated tasks to reset cache cleanly.
- Cache TTL: 5 min (1.25× write) or 1 hr (2× write). Pauses >5 min between turns are the #1 silent cost driver.
- Don't fidget with CLAUDE.md mid-session — invalidates the prefix cache.
- Keep CLAUDE.md under 300 lines (200 ideal).
- Sources: code.claude.com/docs/en/costs; mindstudio.ai/blog/prompt-caching-claude-code-save-tokens

### Long-running tasks

- Anthropic's native **Tasks** system (Ctrl+T) persists across sessions
- Combine with a manifest/checkpoint log + git commit after every phase
- `/goal` autonomous mode runs hours unattended — pair with hard phase gates
- Sessions >30 min or >20 files hit a different failure mode — decompose into bounded phases

### Subagent orchestration

- Orchestrator (Opus) plans + reviews; specialists (Sonnet/Haiku) execute.
- Six patterns: orchestrator, fan-out, validation chain, specialist routing, watchdog, dynamic-workflow.
- Subagent results can silently overflow parent context — cap results, write large output to file, return summary path.
- Don't dispatch >4 parallel agents on one machine.

### Sensitive data handling

- **Don't trust `.gitignore` or `.claudeignore`** — Claude reads `.env` via `Bash(cat)` even when forbidden (confirmed bug 2026).
- Real fix is layered: `permissions.deny` for `Read(./.env*)` **plus** `Bash(cat:.env*)` deny **plus** OS-level sandboxing for Bash.
- Never paste secrets into CLAUDE.md/MEMORY.md.
- Auto-loads `.env`, `.env.local`, `.env.production` on session start without notice.
- Sources: theregister.com/2026/01/28/claude_code_ai_secrets_files; eve.gd/2026/04/19/claude-code-can-consume-transmit-env-files

### Worktree workflows

- `claude --worktree` creates `.claude/worktrees/<branch>/` automatically
- Teams running 4–8 concurrent worktrees per dev reliably in mid-2026
- One feature per worktree, one Claude session per worktree
- `node_modules` per worktree wastes disk — symlink or use pnpm

### CI integration

- `anthropics/claude-code-action@v1` via `/install-github-app`
- **June 2026 security flaw**: malicious GitHub issue could hijack repo via the action. Pin versions, sandbox runners, restrict prompt-injection surface.
- Sources: code.claude.com/docs/en/github-actions; thehackernews.com/2026/06/claude-code-github-action-flaw

### Top regret skills (build these first)

Ranked by frequency in retrospectives:

1. **session-init/manifest** — task declaration + checkpoint log
2. **/compact-at-50** — auto-trigger compact at 50% context
3. **plan-then-build** — force Explore→Plan→Implement→Commit gate
4. **retrospective** — end-of-session "what did you learn"
5. **secrets-deny pack** — pre-shipped deny rules for `.env`, `id_rsa`, `*.pem`, `credentials*`
6. **model-router** — `/model opusplan` default
7. **subagent-brief template** — fresh-context briefing skeleton
8. **worktree-spawn** — one-command parallel feature start
9. **CLAUDE.md-guard** — lint to keep CLAUDE.md <300 lines
10. **Context7-style docs MCP** — kills wasted token spend on web doc fetches

This kit ships ALL TEN of those.

---

## Comparison: vishalmotionwork-lang/claude-code-windows-setup

A community-shared Claude Code setup (773 files, June 2026) reviewed for novel patterns worth adopting.

### What's in it
- Per-language reviewers + build-resolvers (cpp, go, rust, java, kotlin, python, typescript, flutter, pytorch — each its own agent)
- "GSD" (Get Shit Done) framework — 30+ specialist agents (gsd-planner, gsd-debugger, gsd-executor, gsd-verifier, gsd-doc-writer, etc.) + templates for every artifact type + custom JS tooling at `get-shit-done/bin/`
- Daily rituals: `/bod`, `/eod`, `/aside`, `/checkpoint`, `/learn`, `/evolve`
- `/instinct-export`, `/instinct-import`, `/instinct-status` — portable rules between machines
- Multi-* commands: `/multi-frontend`, `/multi-backend`, `/multi-execute`, `/multi-plan`, `/multi-workflow`, `/orchestrate`, `/devfleet`
- `/skill-create`, `/skill-health` — skill lifecycle
- `/rules-distill` — distill rules from session
- BLOCKING startup protocol that reads all `feedback_*.md` files before responding
- Per-project `CONTEXT.md`, `SESSION.md`, `DECISIONS.md` pattern (more granular than our per-workstream MEMORY.md)
- Auto-create project folder on first mention
- Conventional Commits enforcement
- `code-review-graph` MCP

### What we ADOPTED (added to this kit)

| Vishal pattern | Our adoption | Where |
|---|---|---|
| `/bod` daily ritual | `/bod` skill | `optional/skills/bod/SKILL.md` |
| `/eod` daily ritual | `/eod` skill | `optional/skills/eod/SKILL.md` |
| `/instinct-export` | `/instinct-export` skill | `optional/skills/instinct-export/SKILL.md` |
| `/instinct-import` | `/instinct-import` skill | `optional/skills/instinct-import/SKILL.md` |
| `/skill-health` | `/skill-health` skill | `optional/skills/skill-health/SKILL.md` |
| `/rules-distill` | `/rules-distill` skill | `optional/skills/rules-distill/SKILL.md` |
| Per-language reviewers (concept) | Deferred — `/bootstrap` Phase 3 research surfaces language-specific options based on detected stack | `bootstrap/SKILL.md` Phase 3 |

### What we DELIBERATELY DID NOT adopt (anti-patterns or out-of-scope)

- **30+ specialist agents** — research consensus is "custom subagent zoo" is a top anti-pattern; prefer built-in Explore/Plan agents + `Task()` for one-offs
- **GSD JS tooling** — heavy; introduces a parallel system that has to be maintained
- **Per-project `CONTEXT.md`/`SESSION.md`/`DECISIONS.md`** — overlaps with our manifest + workstream `_memory/` pattern. Our pattern is leaner.
- **BLOCKING startup that reads all `feedback_*.md`** — Anthropic's `200 lines or 25KB` budget makes this expensive and unnecessary; our auto-memory loading is sufficient
- **Multi-* command suite** — overlaps with built-in Task() subagent system + `/subagent-brief`
- **Auto-install plugins via settings.json** — too aggressive; our kit asks per skill

### Why our kit is leaner

Vishal's repo is 773 files and packs nearly every imaginable workflow as a custom agent. Research strongly advises against this approach:
- Past ~10% context spent on tool descriptions, the agent degrades into tool-search mode
- Custom subagents for everything fragments orchestrator context
- Maintenance burden compounds — most users abandon 80% of installed skills

Our kit ships 4 always-installed core skills + 17 opt-in optional skills + 4 hooks + 2 MCP recommendations. The `/bootstrap` Judgment phase calibrates which of those 17 the user actually gets. Most users end up with 4-8 active skills, not 50+.

If a user actively wants Vishal's maximalist methodology, they can install his repo on top of ours — they don't conflict.

## Provenance of this kit's design choices

- **Workstream-home pattern** (`<workstream>/_memory/ + _scripts/ + _archive/`): synthesized from community workspace patterns + a working production system. Battle-tested across 10 workstreams + 190 memory files.
- **Memory typology** (user/feedback/project/reference): from a working production system. Maps cleanly to Anthropic's auto-memory but adds structure.
- **3-bucket Active Work** (Do today / Waiting / Parked): production-tested categorization. Generic "todo list" loses signal; status flags don't.
- **Workstream Heat Map** (🔥🌡🟦❄️): production pattern. Tells the user at a glance which workstream is hot vs parked.
- **Session-gate manifest** (`.claude-manifest.json`): production pattern with 37+ checkpoints of evidence. Matches Anthropic's #1 regret skill (session-init/manifest).
- **`/save` with Why:/How: enforcement**: extracted from a working `/save` skill. Forces structure that future-you needs.
- **`/memory-audit` with placement drift scan**: extracted; placement drift check is novel and surfaces real misplacement.
- **Workstation vs Skill distinction**: codified from Jeff (YouTuber)'s "Is this a place I work or a thing I do?" framing.

All of the above are folded into this kit so a new user gets them on day 1 — without having to derive them across months of trial and error.
