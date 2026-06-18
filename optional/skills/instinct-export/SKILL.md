---
name: instinct-export
description: Export your CLAUDE.md, global memory, and personal skills as a portable bundle. Used to clone your system to another machine (e.g. macOS to Windows).
user-invocable: true
allowed-tools: Read, Write, Bash, Glob
---

# /instinct-export

Solves the "I want this setup on my other machine" problem. Exports the durable subset of `~/.claude/` as a tarball + a path-agnostic manifest. Pair with `/instinct-import` on the target machine.

Inspired by Vishal's `/instinct-export`. Adapted to our memory architecture.

## 1. Identify what to export

```bash
EXPORT_DIR=$(mktemp -d)/instinct-export-$(date +%Y%m%d-%H%M%S)
mkdir -p "$EXPORT_DIR"/{config,skills,memory,settings}

# CLAUDE.md (path-templatized)
cat ~/.claude/CLAUDE.md | sed "s|$HOME|{{HOME}}|g" > "$EXPORT_DIR/config/CLAUDE.md"

# All personal skills
cp -r ~/.claude/skills/* "$EXPORT_DIR/skills/" 2>/dev/null

# Global memory (the auto-memory dir)
cp -r ~/.claude/projects/*/memory/* "$EXPORT_DIR/memory/" 2>/dev/null

# settings.json (with paths templatized + secrets stripped)
python3 <<EOF
import json, re, os
home = os.path.expanduser("~")
with open(os.path.expanduser("~/.claude/settings.json")) as f:
    s = json.load(f)
# Strip anything that looks user-specific
s.pop("plugins", None)
s_str = json.dumps(s, indent=2).replace(home, "{{HOME}}")
with open("$EXPORT_DIR/settings/settings.json", "w") as f:
    f.write(s_str)
EOF

# Hooks (if any)
mkdir -p "$EXPORT_DIR/hooks"
cp ~/.claude/hooks/* "$EXPORT_DIR/hooks/" 2>/dev/null
```

## 2. Build a manifest

```bash
cat > "$EXPORT_DIR/MANIFEST.json" <<EOF
{
  "exported_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source_machine": "$(hostname)",
  "source_os": "$(uname -s)",
  "source_user": "$(whoami)",
  "claude_version": "$(claude --version 2>/dev/null || echo unknown)",
  "contents": {
    "config_files": $(ls "$EXPORT_DIR/config" 2>/dev/null | wc -l),
    "skills": $(find "$EXPORT_DIR/skills" -name "SKILL.md" 2>/dev/null | wc -l),
    "memory_files": $(find "$EXPORT_DIR/memory" -name "*.md" 2>/dev/null | wc -l),
    "hooks": $(ls "$EXPORT_DIR/hooks" 2>/dev/null | wc -l)
  }
}
EOF
```

## 3. Choose what NOT to export

Always exclude:
- `~/.claude/.credentials.json` (auth tokens)
- `~/.claude/projects/*/` (per-project session state)
- `~/.claude/sessions/` (transcripts)
- `~/.claude/cache/`, `~/.claude/file-history/`, `~/.claude/paste-cache/`
- Any `.claude-manifest*.json` (session-specific)
- Workstream-local `_memory/` from other folders — those belong to their workstream, not the home directory

Optionally also exclude:
- Specific workstream-specific memory the user marks as "private to this machine"

Ask the user: "Anything in `~/.claude/skills/` or `~/.claude/projects/*/memory/` you DON'T want in the bundle?"

## 4. Package

```bash
OUTPUT="$HOME/Downloads/instinct-$(hostname)-$(date +%Y%m%d).tar.gz"
tar -czf "$OUTPUT" -C "$(dirname $EXPORT_DIR)" "$(basename $EXPORT_DIR)"
echo "Bundle: $OUTPUT"
echo "Size: $(du -h "$OUTPUT" | cut -f1)"
```

## 5. Report

```
✅ Instinct exported.

Bundle: <path>
Size: <size>
Contents:
  - <N> config files
  - <N> skills
  - <N> memory files
  - <N> hooks

To apply on another machine:
  1. Copy the tarball over (Drive, AirDrop, scp, USB)
  2. On the target machine: extract + run /instinct-import <path-to-bundle>
```

## Why this exists

Originally Zaid's problem: he built a sophisticated CLAUDE.md / memory / skills setup on his Windows machine and wanted to put the same scaffolding on Zeel's Mac (different content, same system). Vishal's repo formalizes this pattern as `/instinct-export`/`/instinct-import`.

This is the "Mac kit" problem solved correctly: not a static template, but a snapshot of your actual working system, made portable.
