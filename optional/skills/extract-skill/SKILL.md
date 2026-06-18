---
name: extract-skill
description: "If I said this twice, make it a skill" reflex. Scans the session for a workflow you ran 2+ times, scaffolds a new SKILL.md so next time it's one command.
user-invocable: true
allowed-tools: Read, Write, Grep
---

# /extract-skill

A reflex command. When you realize "I keep doing X manually" — `/extract-skill` turns X into a slash command in 90 seconds.

## 1. Identify the candidate

Either:
- **User-provided:** they tell you what to extract ("I keep running git pull && pnpm install && pnpm typecheck")
- **Auto-detect:** scan recent shell history + this conversation for a workflow ≥2 occurrences

If auto-detecting, surface candidates as a numbered list, ask user to pick.

## 2. Distill the workflow

Ask:
- **Skill name** (slug-friendly)
- **One-line description** (what it does for future-you searching)
- **Inputs** (does the skill take arguments?)
- **Steps** (what exactly runs, in order)
- **Output format** (what does the user see after?)

## 3. Scaffold

Write `~/.claude/skills/<slug>/SKILL.md`:

```markdown
---
name: <slug>
description: <one-line description>
user-invocable: true
allowed-tools: <inferred from steps: Read, Bash, etc.>
---

# /<slug>

<one-paragraph: what this does, when to use it>

## Steps

1. <step 1>
2. <step 2>
...

## Report

<format of output to user>
```

## 4. Test prompt

Tell user: "Drafted /<slug>. Try it now: type `/<slug>` and see if it does what you intended. If it works, you're done. If not, edit `~/.claude/skills/<slug>/SKILL.md` directly."

## 5. Add to manifest

```bash
python3 -c "
import json, datetime
with open('.claude-manifest.json') as f: m = json.load(f)
m.setdefault('checkpoints', []).append({
    'at': datetime.datetime.utcnow().isoformat() + 'Z',
    'accomplished': 'Extracted workflow into /<slug> skill',
    'next': 'Test the new skill in next session',
    'kind': 'extract-skill'
})
with open('.claude-manifest.json', 'w') as f: json.dump(m, f, indent=2)
"
```

## Why this exists

The community retrospective is unanimous: experienced users say "the skills I built in the first month are the ones I still use; everything I built later was either over-engineered or duplicate." The reflex of "twice = skill" prevents both extremes.

Pair with `/retrospective` — that one identifies candidates, this one acts on them.
