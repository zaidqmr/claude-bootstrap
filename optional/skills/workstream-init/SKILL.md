---
name: workstream-init
description: Scaffold a new workstream folder with CLAUDE.md + _memory/MEMORY.md + _scripts/ + _archive/. Asks for the workstream name, scope, and a few local rules.
user-invocable: true
allowed-tools: Read, Write, Bash
---

# /workstream-init

When you start working on a new ongoing area (not a one-off task), scaffold it as a workstream so the rules + memory + scripts live together.

## 1. Identify the parent directory

```bash
pwd
```

The workstream folder will be created inside this directory unless the user specifies otherwise.

## 2. Ask the user

- What's the workstream called? (slug-friendly, e.g. `_outreach`, `client-acme`, `blog`)
- One-sentence scope: what work happens here?
- Any local rules that are workstream-specific? (3 max)
- Any canonical reference files this workstream needs? (paths to existing docs)

## 3. Scaffold

```bash
WORKSTREAM_DIR="<parent>/<slug>"
mkdir -p "$WORKSTREAM_DIR/_memory" "$WORKSTREAM_DIR/_scripts" "$WORKSTREAM_DIR/_archive"
```

Write `$WORKSTREAM_DIR/CLAUDE.md` from the template, filling in:
- Workstream name (from user)
- Scope sentence (from user)
- Load order line (auto)
- Canonical artifacts (from user)
- Local rules (from user)
- Active in this workstream section (empty buckets)

Write `$WORKSTREAM_DIR/_memory/MEMORY.md` from the empty workstream MEMORY template.

## 4. Update global state

Add a row to the global MEMORY.md WORKSTREAM HEAT MAP:

```
| <name> | 🌡 WARM | <today> | <one-line pattern> |
```

(WARM because you're starting it now. It'll go HOT or COLD based on actual touches.)

## 5. Update global CLAUDE.md routing (optional)

If you maintain a routing/workstream list in the global CLAUDE.md (some users do, some don't), add the new workstream.

## 6. Tell the user

```
✅ Workstream scaffolded.

Path: <WORKSTREAM_DIR>
Files created:
  - CLAUDE.md (workstream constitution)
  - _memory/MEMORY.md (empty index)
  - _scripts/ (build scripts go here)
  - _archive/ (superseded outputs go here)

Heat map updated: workstream added as WARM.

Next:
  - cd <WORKSTREAM_DIR>
  - claude
  - The workstream's CLAUDE.md + _memory/MEMORY.md auto-load.
```
