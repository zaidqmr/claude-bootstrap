---
name: skill-health
description: Audit installed skills for staleness, conflicts, unused, missing frontmatter, oversized. Read-only triage report.
user-invocable: true
allowed-tools: Read, Glob, Bash, Grep
---

# /skill-health

Like `/memory-audit` but for `~/.claude/skills/`. Surfaces drift in your skill library. Read-only.

## 1. Scan skill dirs

```bash
SKILL_ROOTS=(
  "$HOME/.claude/skills"
  "$HOME/.claude/commands"   # legacy
)
for d in $(find "${SKILL_ROOTS[@]}" -name "SKILL.md" -o -name "*.md" 2>/dev/null); do
  echo "$d"
done
```

## 2. Per-skill checks

For each skill file:

```python
checks = {
    "has_frontmatter": False,
    "has_name": False,
    "has_description": False,
    "size_ok": True,           # <500 lines per Anthropic recommendation
    "last_used": None,         # mtime as proxy
    "duplicates": [],          # other files with same `name:` frontmatter
}
```

Read frontmatter. If missing required fields, flag.
Check size: if >500 lines, flag (Anthropic recommendation).
Check `last_used`: if mtime >90 days AND not referenced from CLAUDE.md or another skill, flag as unused candidate.
Cross-check `name:` field across all skills for duplicates.

## 3. Conflict detection

Two skills with the same `name:` in different directories → which one wins is order-dependent. Flag.

Skill in `commands/` AND `skills/` with same name → skills wins per Anthropic; commands version is dead weight. Flag.

## 4. Report

```
Skill health · YYYY-MM-DD
Scanned: <N> skills across <M> directories.

🔴 MISSING REQUIRED FRONTMATTER: N
  - <path> — missing: name, description

🔴 NAME CONFLICTS (two skills, same name field): N
  - 'name':
    - <path A>
    - <path B>

🔴 LEGACY/NEW DUPES (commands/ + skills/ overlap): N
  - <name>:
    - commands version: <path>
    - skills version: <path>    ← this one wins

🟡 OVERSIZE (>500 lines): N
  - <path> — <N> lines

🟡 STALE (mtime >90d, no references): N
  - <path> — last modified <date>, not in CLAUDE.md, not invoked by other skills

🟡 MISSING DESCRIPTION (skill won't auto-invoke): N
  - <path>

=== Health: PASS | NEEDS FIXES ===
```

## 5. Suggested fixes (no auto-action)

- Missing frontmatter → open and add
- Name conflicts → rename one, or delete the dead one
- Legacy dupes → delete the commands/ version (skills/ wins)
- Oversize → split into multiple skills or move detail to reference files
- Stale → archive to `~/.claude/skills/_archive/` or delete if obviously dead
- Missing description → Claude can't decide to auto-invoke without it; add one even if you only call it manually

User decides what to act on. This command never auto-moves or auto-edits skills.

## Why this exists

Skill libraries accumulate. Same way memory does. Without periodic audit, you end up with 30 skills you forgot you wrote, 3 of which have name collisions, 5 of which are dead. `/skill-health` makes that visible monthly so the library stays small + signal-heavy.

Pair with `/extract-skill` (creates them) and `/memory-audit` (audits memory). Together they keep the harness healthy.
