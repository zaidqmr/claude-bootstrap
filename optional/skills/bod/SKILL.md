---
name: bod
description: Beginning of day. Read Active Work + Heat Map + manifest checkpoints from last 24h + recent commits. Surface "what to focus on today" in under 60 seconds.
user-invocable: true
allowed-tools: Read, Bash, Grep
---

# /bod

A 60-second orientation when you sit down to work. Inspired by Vishal's `/bod`, calibrated to our memory architecture.

## 1. Pull state

```bash
# Active Work + Heat Map from global MEMORY.md
sed -n '/## ACTIVE WORK/,/## WORKSTREAM HEAT MAP/p' ~/.claude/projects/*/memory/MEMORY.md 2>/dev/null
sed -n '/## WORKSTREAM HEAT MAP/,/## SCHEDULED TASKS/p' ~/.claude/projects/*/memory/MEMORY.md 2>/dev/null

# Last 24h of manifest checkpoints across active workstreams
find ~ -name ".claude-manifest*.json" -mtime -1 2>/dev/null | while read m; do
  echo "=== $m ==="
  python3 -c "
import json
m = json.load(open('$m'))
print('Task:', m.get('task', '?'))
cps = m.get('checkpoints', [])[-3:]
for c in cps:
    print(f\"  - {c.get('at','?')[:10]}: {c.get('accomplished','?')}\")
"
done

# Recent commits across all active repos (last 7 days)
for repo_dir in $(find ~ -maxdepth 4 -name ".git" -type d 2>/dev/null | head -10); do
  repo="${repo_dir%/.git}"
  cd "$repo" 2>/dev/null && {
    commits=$(git log --since="7 days ago" --oneline 2>/dev/null | head -3)
    [ -n "$commits" ] && echo "=== $(basename $repo) ===" && echo "$commits"
  }
done
```

## 2. Produce orientation

```
Good morning. Here's where you are.

🔥 HOT today (need active work):
  - <pull from Active Work "Do today / this week" bucket>

⏳ WAITING (monitor):
  - <pull from "Waiting on others" bucket>

📋 LAST 3 CHECKPOINTS (across all workstreams):
  - <date> [<workstream>] <accomplished> → next: <next>

🎯 SUGGESTED FOCUS for today:
  - <top priority item from "Do today" bucket>
  - <secondary item>

Type /clear if yesterday's session context is loaded, then open the right workstream and go.
```

## 3. Optional · run /catchup on the suggested workstream

If the suggested focus is in a git repo, optionally invoke `/catchup` for that branch automatically.

## Why this exists

Most morning friction is "where was I?" + "what should I work on?" The manifest + Active Work pattern already has the data. `/bod` is the one-command read of that data + a prioritization nudge.

Pair with `/eod` to close the loop.
