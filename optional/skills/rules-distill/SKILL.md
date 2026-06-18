---
name: rules-distill
description: Lighter than /retrospective. Scans this session for any rule-shaped statement (correction, preference, "always X", "never Y") and proposes them as feedback memories.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash
---

# /rules-distill

A focused subset of `/retrospective`. Where `/retrospective` looks at architecture, slash commands, anti-patterns, AND rules, `/rules-distill` only looks at rules. Use when you know you got corrected on something specific.

Inspired by Vishal's `/rules-distill`.

## 1. Scan the session for rule-shaped statements

Look for patterns like:
- "always X" / "never Y"
- "don't do X, do Y instead"
- "from now on, X"
- "I prefer X over Y"
- "stop doing X"
- "the right way is X"

Each occurrence → a candidate feedback memory.

## 2. For each candidate, ask:

- Is this a rule (prescriptive, stable) or a one-off task constraint? Rules → save. Task constraints → skip.
- Is the user telling you about HIS preference, or HE'S asking what's standard? His preference → save. Generic asking → skip.
- Is this scope global (any session) or workstream-local (only when working in X)?

## 3. Propose

Present as:

```
Rule candidates found this session:

[1] "Use Brave for headless PDF rendering, not Chrome"
    Scope: global  |  Type: feedback
    File: feedback_brave_headless_pdf.md
    Why: <inferred from context>
    How to apply: <inferred>

[2] "Don't ask for Ctrl+V — drive paste programmatically"
    Scope: reel-insights workstream  |  Type: feedback
    File: <workstream>/_memory/feedback_self_paste.md
    Why: <inferred>
    How to apply: <inferred>

Approve? (y / n / pick subset like 1,2)
```

## 4. Write approved candidates

Use the `/save` logic for the approved items. Each becomes a feedback memory with required `**Why:**` + `**How to apply:**` fields.

## 5. Manifest checkpoint

```bash
python3 -c "
import json, datetime
with open('.claude-manifest.json') as f: m = json.load(f)
m.setdefault('checkpoints', []).append({
    'at': datetime.datetime.utcnow().isoformat() + 'Z',
    'accomplished': 'Distilled N rules from session into feedback memories',
    'next': 'Test in next session that the rules apply automatically',
    'kind': 'rules-distill'
})
with open('.claude-manifest.json', 'w') as f: json.dump(m, f, indent=2)
"
```

## 6. Report

```
Distilled N rules.

Saved as feedback memories:
- [global] file1.md
- [workstream] file2.md

Skipped (not rule-shaped or one-off):
- "<candidate>" — <reason>

Test next session: <which behavior should now happen automatically>
```

## When to use which

- **`/save`** — captured everything memory-worthy from a session (multiple types)
- **`/rules-distill`** — just want to codify the rules I expressed today (only feedback type)
- **`/retrospective`** — broader meta-learning loop (rules + slash command candidates + anti-patterns + stale CLAUDE.md)

Pick based on what you want to capture.
