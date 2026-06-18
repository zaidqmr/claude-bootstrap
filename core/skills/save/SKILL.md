---
name: save
description: Scan the session for memory-worthy details, write to long-term memory (workstream-aware), refresh Active Work + Heat Map, add a manifest checkpoint. The user types /clear next.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

# /save

End-of-session ritual. Run end-to-end without stopping for confirmation unless writing would overwrite an existing memory file with conflicting content.

## 1. Resolve memory targets (workstream-aware)

Detect the current workstream from CWD:

- If CWD is inside a folder that contains `_memory/MEMORY.md`, that folder is the **workstream**. Read both:
  - **GLOBAL_INDEX** = `~/.claude/projects/<project>/memory/MEMORY.md` (Anthropic auto-memory location)
  - **WORKSTREAM_INDEX** = `<workstream>/_memory/MEMORY.md`
- Else, only **GLOBAL_INDEX** is in scope. All writes go global.

Read both indexes + every CLAUDE.md in the hierarchy so you know what already exists. You will UPDATE existing or CREATE new — never duplicate.

## 2. Scan THIS conversation for memory-worthy items

**Save the conclusion, not the journey.** Memory captures only what was landed on + the reasoning that made it the chosen answer, in enough detail that a fresh session can act on it without rerunning the deliberation.

- 5 options discussed, 3 concluded → save the 3. The other 2 vanish.
- Position shifted X → Y → save Y + reasoning. Don't preserve the X→Y journey.
- Ideas raised and dropped without conclusion → NOT candidates.

**Detailing rule.** Reduce BREADTH (drop abandoned branches), keep DEPTH (full why on what stayed).

Classify each candidate into one **type** AND one **scope**:

**Types:**
- **user** — facts about user's role, preferences, knowledge, working style
- **feedback** — corrections OR validated approaches (confirmations are quieter; look for them)
- **project** — ongoing work, decisions, who-doing-what, NOT derivable from `git log`
- **reference** — pointers to external systems, documents, tools, canonical artifacts

**Scope:**
- **global** — applies across ≥2 workstreams
- **workstream** — only matters in this workstream

Default to workstream if plausible. Promote to global only when reuse is concrete.

## 3. SKIP (even if told to "save everything")

- Abandoned proposals, X→Y journeys
- Deliberation paths, false starts
- Ideas without conclusion
- Code patterns, file paths, project structure (derivable from disk)
- Font sizes, colors, layout (in source files)
- One-off task details (output is on disk)
- Step-by-step processes you just executed
- Anything already in a CLAUDE.md or MEMORY.md
- Anything that only makes sense inside this conversation

## 4. Dedupe (mandatory)

Search both indexes for similar titles + topic words. Near-match exists → UPDATE, don't add new.

## 5. Write each item

Target:
- **global:** `~/.claude/projects/<project>/memory/<type>_<topic_slug>.md`
- **workstream:** `<workstream>/_memory/<type>_<topic_slug>.md`

Frontmatter:
```
---
name: {short title, ≤80 chars}
description: {one-line hook, ≤140 chars}
type: {user | feedback | project | reference}
last_validated: {YYYY-MM-DD today}
---
```

Body:
- **First line:** 1–2 sentence TL;DR. Glanceable.
- **feedback** + **project** then require: `**Why:**` line + `**How to apply:**` line. Refuse to write if either is empty.
- **user** + **reference** — prose after TL;DR is fine.

Index entry (append ONE line to right MEMORY.md):
```
- [Title](file.md) — one-line hook
```

**HARD CAP**: ≤200 chars.

UPDATE: edit in place + bump `last_validated`.

## 6. Refresh Active Work + Heat Map

Open the global MEMORY.md. Update:

### Active Work — 3 buckets
- **Do today / this week** — user can act on it now
- **Waiting on others** — blocked on external input
- **Parked / deferred** — off the radar by choice

Promote between buckets as state changes. Remove when truly done.

Combined cap ≤12 bullets.

### Heat Map
Bump COLD workstreams touched this session to WARM. Drop HOT workstreams untouched 7+ days to WARM.

🔥 HOT · 🌡 WARM · 🟦 COOL · ❄️ COLD

### Workstream-local Active Work
If session worked inside a workstream with its own `CLAUDE.md`, refresh its `## Active in this workstream` section too.

## 7. Manifest checkpoint

```bash
python3 -c "
import json,datetime
with open('.claude-manifest.json') as f: m=json.load(f)
m.setdefault('checkpoints',[]).append({'at':datetime.datetime.utcnow().isoformat()+'Z','accomplished':'ACCOMPLISHED','next':'NEXT'})
with open('.claude-manifest.json','w') as f: json.dump(m,f,indent=2)
"
```

Replace ACCOMPLISHED (one sentence) + NEXT (logical next step). If no manifest in CWD, skip and note.

## 8. Report

```
Memory updated.

Workstream detected: <name or "none (global only)">

NEW (N):
- [scope/type] Title — hook → file

UPDATED (N):
- [scope/type] Title — what changed → file

SKIPPED:
- candidate — why

Active Work: <X items in 'Do today' / Y waiting / Z parked>
Heat Map: <any changes>

Manifest checkpoint: added (or "skipped, no manifest in CWD")

Ready. Type /clear when you want to wipe context.
```
