---
name: catchup
description: Summarize what happened on this branch since I last touched it. Reads git log, manifest checkpoints, and any open PRs/issues, produces a 5-line orientation.
user-invocable: true
allowed-tools: Read, Bash, Grep
---

# /catchup

When you come back to a branch after a few days, this gives you the 5-line orientation so you can pick up without re-reading everything.

## 1. Identify the branch + last touch

```bash
git branch --show-current
git log -1 --format="%cd %s" --date=relative
```

## 2. Pull recent activity

```bash
# Commits since last week (or since branch diverged from main)
git log --oneline -20 HEAD ^main 2>/dev/null || git log --oneline -10

# What changed file-wise
git diff --stat HEAD~5..HEAD 2>/dev/null

# Open PRs from this branch
gh pr list --head "$(git branch --show-current)" --json number,title,url 2>/dev/null
```

## 3. Read manifest checkpoints

```bash
cat .claude-manifest.json 2>/dev/null | python3 -c "
import json,sys
m = json.load(sys.stdin)
cps = m.get('checkpoints', [])[-5:]
for c in cps:
    print(f\"  - {c.get('at','?')[:10]}: {c.get('accomplished','?')}\")
print()
print(f\"  next: {cps[-1].get('next', '?') if cps else '?'}\")
"
```

## 4. Print orientation

```
On branch: <name>
Last touched: <relative time>

5 recent commits:
  - <hash> <msg>
  ...

Files changed: <N files, +X/-Y lines>

Open PRs: <list with URLs>

Last 5 manifest checkpoints:
  - <date>: <accomplished>
  ...

Next per last checkpoint: <text>
```

Don't analyze. Just orient. The user can ask follow-ups.
