---
name: session-init
description: Force a task declaration before any work. Writes .claude-manifest.json with session_id + task + started_at. Skip if manifest already active.
user-invocable: true
allowed-tools: Read, Write, Bash
---

# /session-init

The session gate. Most users let CLAUDE.md trigger this automatically — this skill is here so you can re-init explicitly, or invoke it as a fresh-start ritual.

## 1. Check existing manifest

```bash
cat .claude-manifest.json 2>/dev/null
```

If exists with `"status": "active"`: tell user "Manifest already active for task: `<task>`. Resume that task or end it via /save first." Exit.

## 2. Ask the task

Say exactly: "What are you working on this session?"

Wait for user's answer. Do not proceed with any other work until they answer.

## 3. Write the manifest

```bash
SID=$(python3 -c 'import uuid; print(str(uuid.uuid4())[:8])')
HOST=$(hostname)
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
PROJ=$(basename "$PWD")

cat > .claude-manifest.json <<EOF
{
  "session_id": "$SID",
  "device": "$HOST",
  "project": "$PROJ",
  "task": "<user's answer verbatim>",
  "started_at": "$NOW",
  "status": "active",
  "checkpoints": []
}
EOF
```

Make sure `.claude-manifest*.json` is in `.gitignore`:

```bash
if [ -f .gitignore ] && ! grep -q "claude-manifest" .gitignore; then
  echo ".claude-manifest*.json" >> .gitignore
fi
```

## 4. Confirm

Tell the user: "Manifest created · session_id `<SID>` · task `<task>`. Ready to work."

## Why this exists

Without a declared task, sessions drift. Mid-session pivots lose context. `/clear` wipes everything with no recovery. The manifest:

- Forces clarity at session start
- Survives `/clear` (checkpoints persist)
- Recovers context after machine restart
- Gives `/save` a place to write checkpoints
- Lets you see, weeks later, what every past session was for

37+ checkpoints across a real production workflow validates the pattern.
