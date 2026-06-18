---
name: clear-handoff
description: Write a 5-line handoff doc before /clear so the next session can resume without re-reading everything. Updates manifest checkpoint.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash
---

# /clear-handoff

Run this BEFORE typing `/clear`. Otherwise the context wipes and you lose the thread.

## 1. Read manifest

```bash
cat .claude-manifest.json
```

Pull the current task + most recent checkpoint.

## 2. Write a 5-line handoff

Compose a file at `./HANDOFF.md` (or `.claude-handoff.md` if you don't want to clutter the repo) with EXACTLY 5 lines:

```
Task: <current task from manifest>
Done: <one-line of what was accomplished this session>
Open: <what's not done that needs to happen>
Files: <up to 5 file paths the next session will need>
Next: <one specific action to take in the next session>
```

Show this to the user. Ask "Anything to change?"

## 3. Write manifest checkpoint

Same as `/save` step:

```bash
python3 -c "
import json,datetime
with open('.claude-manifest.json') as f: m=json.load(f)
m.setdefault('checkpoints',[]).append({
  'at': datetime.datetime.utcnow().isoformat()+'Z',
  'accomplished': 'ACCOMPLISHED',
  'next': 'NEXT',
  'kind': 'clear-handoff'
})
with open('.claude-manifest.json','w') as f: json.dump(m,f,indent=2)
"
```

Replace ACCOMPLISHED + NEXT from the handoff doc.

## 4. Tell the user

> "Handoff written to `./HANDOFF.md`. Manifest checkpoint added.
> Next session: `cat HANDOFF.md` first to resume.
> 
> Type /clear when ready."

Do NOT call /clear yourself. The user runs it manually.

## Why this exists

`/compact` summarizes but loses fidelity. `/clear` wipes cleanly but loses everything. The handoff doc is the middle ground: a tiny on-disk note that lets the next session catch up in 30 seconds.

5 lines is the magic number. More than that and you might as well re-read the session. Less and you forget what mattered.
