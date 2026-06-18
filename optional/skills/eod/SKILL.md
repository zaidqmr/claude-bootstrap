---
name: eod
description: End of day. Forces /save + manifest checkpoint + tomorrow's plan + any cross-workstream housekeeping. Run before you close the laptop.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash
---

# /eod

The closing ritual. Inspired by Vishal's `/eod`, calibrated to our manifest architecture.

## 1. Run /save first

```
Invoke the /save skill (or its logic).
```

This ensures memory is captured and Active Work is refreshed.

## 2. Confirm manifest checkpoint

The /save step should have added a checkpoint. Verify:

```bash
python3 -c "
import json
m = json.load(open('.claude-manifest.json'))
cps = m.get('checkpoints', [])
last = cps[-1] if cps else None
if last:
    print('Last checkpoint:', last.get('at', '?')[:19])
    print('Accomplished:', last.get('accomplished', '?'))
    print('Next:', last.get('next', '?'))
else:
    print('NO CHECKPOINTS — run /save first.')
"
```

## 3. Tomorrow's plan

Ask the user: "What's the single highest-leverage thing for tomorrow?"

Write to `./TOMORROW.md`:

```
Date: <YYYY-MM-DD>
Top priority: <user's answer>
Context: <auto-filled from current manifest task + last checkpoint>
Open blockers: <pull from Active Work "Waiting" bucket>
First action: <specific concrete step to start with>
```

This is the load-bearing artifact for tomorrow's `/bod`.

## 4. Cross-workstream housekeeping (optional)

Ask: "Anything to housekeeping before you close?"
- Promote any items from "Waiting on others" that got resolved
- Drop COLD workstreams that should be archived
- Pull stale items from Active Work that aren't actually moving

## 5. Mark session complete

```bash
python3 -c "
import json, datetime
with open('.claude-manifest.json') as f: m = json.load(f)
m.update({
    'status': 'completed',
    'completed_at': datetime.datetime.utcnow().isoformat() + 'Z',
    'eod_at': datetime.datetime.utcnow().isoformat() + 'Z'
})
with open('.claude-manifest.json', 'w') as f: json.dump(m, f, indent=2)
"
```

## 6. Report

```
EOD complete.

Saved: <N memory items, M Active Work refreshes>
Tomorrow's top priority: <task>
First action tomorrow: <step>

Run /bod when you sit down tomorrow.

Good night.
```

## Why this exists

Without `/eod`, sessions trail off and context is lost. The ritual forces three load-bearing acts: save memory, plan tomorrow's first action, mark the session complete. The TOMORROW.md artifact is what makes `/bod` instantly useful the next morning.
