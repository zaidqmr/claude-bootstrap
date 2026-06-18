---
name: instinct-import
description: Apply an /instinct-export bundle from another machine. Path-translates Windows to Mac/Linux (or vice versa). Backup-first. Never overwrites without confirmation.
user-invocable: true
allowed-tools: Read, Write, Bash, Edit
---

# /instinct-import

Apply a bundle exported via `/instinct-export` (likely from your other machine) to this one. Handles path translation between Windows/macOS/Linux.

## 1. Locate the bundle

User provides the tarball path. Or auto-detect in common places:
- `~/Downloads/instinct-*.tar.gz`
- `~/iCloud Drive/instinct-*.tar.gz`
- `~/Drive/instinct-*.tar.gz`

Default: ask the user to drop the path.

## 2. Mandatory backup of current state

Same protocol as `/bootstrap` Phase 0:

```bash
bash ~/.claude/skills/bootstrap/lib/backup.sh
```

Capture the SNAPSHOT_PATH. If backup fails, STOP.

## 3. Extract bundle to temp

```bash
TMPDIR=$(mktemp -d)
tar -xzf <bundle-path> -C "$TMPDIR"
BUNDLE="$TMPDIR/$(ls $TMPDIR | head -1)"
cat "$BUNDLE/MANIFEST.json"
```

Show manifest to user. Confirm: "Source machine was `<hostname>` on `<os>`, exported `<date>`. Apply to this machine?"

## 4. Path-translate

```python
import os, re
TARGET_HOME = os.path.expanduser("~")
TARGET_USER = os.environ.get("USER") or os.environ.get("USERNAME")

# Translate {{HOME}} placeholder → this machine's actual home dir
# Also translate any hardcoded paths from source machine

for root, dirs, files in os.walk("$BUNDLE"):
    for f in files:
        if f.endswith(".md") or f.endswith(".json"):
            p = os.path.join(root, f)
            txt = open(p, encoding="utf-8").read()
            txt = txt.replace("{{HOME}}", TARGET_HOME)
            # Source-OS-specific path patterns
            txt = re.sub(r"C:\\\\Users\\\\[^\\\\]+\\\\", f"{TARGET_HOME}/", txt)
            txt = re.sub(r"/Users/[^/]+/", f"{TARGET_HOME}/", txt)
            txt = re.sub(r"/home/[^/]+/", f"{TARGET_HOME}/", txt)
            open(p, "w", encoding="utf-8").write(txt)
```

## 5. Show diff plan

For each file the bundle would write or merge:
- **New file:** "will create at `<dest>`"
- **Overwrite:** show diff against current content; ask user merge/overwrite/skip per file
- **Skill conflict:** if a skill with the same name already exists, ask: keep existing / replace / keep both with suffix

Never silently overwrite.

## 6. Apply

For each approved file:
1. Backup current target file to `${SNAPSHOT_PATH}/manual-merges/<filename>` if it existed
2. Write the bundle file to the target path
3. Log to `${SNAPSHOT_PATH}/import_log.tsv`

## 7. Refresh shell-relative bits

- `chmod +x` any imported `.sh` files
- Re-link any `@-imports` in CLAUDE.md to ensure relative paths still resolve

## 8. Report

```
✅ Instinct imported.

Backup: <SNAPSHOT_PATH>
Rollback: bash <SNAPSHOT_PATH>/rollback.sh

Applied:
  - <N> config files
  - <N> skills (M new, K replaced)
  - <N> memory files
  - <N> hooks

Path translations: <Windows→Mac | Mac→Linux | etc.>

Next:
  - Open Claude Code and confirm the imported skills/CLAUDE.md load correctly
  - If anything looks wrong: bash <SNAPSHOT_PATH>/rollback.sh
```

## Why this exists

`/instinct-export` produces the bundle. `/instinct-import` is the other half of the loop. Together they solve the multi-machine sync problem cleanly without needing a dotfiles repo + careful symlink discipline. Backup-first, diff-show, file-by-file confirmation — never the "blow away ~/.claude/ and restore" anti-pattern that causes data loss.
