---
name: retrospective
description: End-of-session learning loop. Scan what happened, surface any pattern that should become a CLAUDE.md rule, a slash command, or a memory entry. Updates CLAUDE.md and global memory accordingly.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Grep
---

# /retrospective

A heavier-touch version of `/save` for sessions where you actually learned something architectural about how you work.

Run when:
- You corrected yourself 2+ times on the same thing this session
- You realized "I keep doing X manually" (extract-skill candidate)
- A workflow felt frictional and you found a better one
- An anti-pattern was avoided thanks to a guard you wish was automated

Don't run after every session — `/save` handles routine memory.

## 1. Scan the session

Read the conversation. Look for:

**Repeated corrections** — the user told you the same thing twice (or implicitly the second time by frustration). Flag as candidate global feedback memory.

**Manual workflows** — the user ran the same command sequence ≥2 times in this session, or said something like "every time I do X". Flag as slash-command candidate.

**Discovered patterns** — a new way of doing something that worked better than the previous approach. Flag as candidate `feedback` or `reference` memory.

**Avoided antipatterns** — something that almost broke but didn't. The thing that almost broke is a candidate for a guard hook or settings deny rule.

**Stale CLAUDE.md rules** — instructions in CLAUDE.md that contradict what actually happened in this session. Flag for review.

## 2. Propose updates

Present a structured report:

```
Retrospective findings

REPEATED CORRECTIONS (candidates for global feedback memory):
  - "<correction>" → propose: feedback_<slug>.md
  
MANUAL WORKFLOWS (candidates for slash commands):
  - <command sequence> → propose: /<command-name>
  
DISCOVERED PATTERNS (candidates for memory or CLAUDE.md):
  - <pattern> → propose: <type>_<slug>.md or CLAUDE.md section
  
AVOIDED ANTIPATTERNS (candidates for guards):
  - <antipattern> → propose: settings deny rule | PreToolUse hook
  
STALE CLAUDE.md RULES (candidates for revision):
  - "<rule>" in <file> contradicts behavior this session
```

Ask user which to act on. Get yes/no per item.

## 3. Implement the approved updates

For each approved item:

- **Memory update** → invoke `/save` logic with that specific item
- **CLAUDE.md update** → edit the right CLAUDE.md (global or workstream) inline
- **Slash command** → scaffold `~/.claude/skills/<name>/SKILL.md` with frontmatter, ask user to fill in the body
- **Hook** → scaffold the hook in `~/.claude/settings.json`, ask user to confirm before merging
- **Settings deny rule** → add to the deny array in `~/.claude/settings.json`

For every change, show diff before writing. Backup the touched file to `~/.claude/backups/retrospective-<ts>/`.

## 4. Manifest checkpoint

Add a "retrospective" entry to the manifest:

```bash
python3 -c "
import json,datetime
with open('.claude-manifest.json') as f: m=json.load(f)
m.setdefault('checkpoints',[]).append({
  'at': datetime.datetime.utcnow().isoformat()+'Z',
  'accomplished': 'Retrospective: <one-line summary of what was learned>',
  'next': '<what to test in next session>',
  'kind': 'retrospective'
})
with open('.claude-manifest.json','w') as f: json.dump(m,f,indent=2)
"
```

## 5. Report

```
Retrospective applied.

Memory updates: N
CLAUDE.md edits: N
New skills scaffolded: <list>
New hooks/deny rules: <list>
Backup: ~/.claude/backups/retrospective-<ts>/

Test in next session:
- <thing 1>
- <thing 2>
```

## Why this exists

`/save` captures session output. `/retrospective` captures session *meta-learning* — the patterns about how you work, what trips you up, what's missing from your tools. Most experienced users say this is what separates a Claude Code setup that compounds from one that stagnates.

Don't run it every session. Run it when a session taught you something about how you work, not just what you did.
