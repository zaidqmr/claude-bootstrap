---
name: worktree-spawn
description: One-command parallel feature start using git worktrees. Creates a worktree, opens a Claude Code session there, scaffolds a manifest for the feature.
user-invocable: true
allowed-tools: Read, Bash
---

# /worktree-spawn

For parallel feature work without branch-switching context loss.

## 1. Get inputs

- Branch name (e.g. `feat/oauth-rework`)
- Base branch (default: current branch or `main`)
- Worktree path (default: `../<repo>-<branch-slug>`)

## 2. Create the worktree

```bash
git worktree add <path> -b <branch> <base>
```

## 3. Sync deps (per stack)

```bash
cd <path>

# Node
if [ -f package.json ]; then
  if command -v pnpm >/dev/null; then pnpm install
  elif command -v yarn >/dev/null; then yarn install
  else npm install; fi
fi

# Python
if [ -f pyproject.toml ] || [ -f requirements.txt ]; then
  python3 -m venv .venv 2>/dev/null || true
  . .venv/bin/activate 2>/dev/null || true
  [ -f pyproject.toml ] && pip install -e . 2>/dev/null
  [ -f requirements.txt ] && pip install -r requirements.txt 2>/dev/null
fi

# Rust
[ -f Cargo.toml ] && cargo build 2>/dev/null

# Go
[ -f go.mod ] && go mod download 2>/dev/null
```

## 4. Init a manifest for this feature

```bash
cd <path>
SID=$(python3 -c 'import uuid; print(str(uuid.uuid4())[:8])')
python3 -c "
import json, datetime
m = {
    'session_id': '$SID',
    'device': '$(hostname)',
    'project': '$(basename $PWD)',
    'task': 'Feature work on branch $(git branch --show-current)',
    'started_at': datetime.datetime.utcnow().isoformat() + 'Z',
    'status': 'active',
    'worktree': '$PWD',
    'parent_repo': '$(git rev-parse --show-toplevel)',
    'checkpoints': []
}
open('.claude-manifest.json', 'w').write(json.dumps(m, indent=2))
"
```

## 5. Report

```
✅ Worktree spawned.

Branch: <name>
Path: <path>
Manifest: <path>/.claude-manifest.json

Next:
  cd <path>
  claude

Existing session in the main checkout is unaffected.
```

## Removing later

When done with the feature:

```bash
git worktree remove <path>
git branch -D <branch>  # if branch is also done
```

## Why this exists

Switching branches in your main checkout invalidates the entire Claude session's context (different files on disk). Worktrees keep each feature in its own directory with its own session.

Anthropic's `claude --worktree` was added mid-2025; teams running 4–8 concurrent worktrees per dev is now common.

## Source
- https://code.claude.com/docs/en/worktrees
- https://developersdigest.tech/blog/git-worktrees-claude-code-parallel-agents-guide
