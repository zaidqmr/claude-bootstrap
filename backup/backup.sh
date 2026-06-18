#!/usr/bin/env bash
# Full snapshot of ~/.claude/ before any bootstrap-driven changes.
# Verifies the backup before exiting. Refuses to overwrite an existing snapshot.

set -e

TS=$(date +%Y%m%d-%H%M%S)
BACKUP_ROOT="$HOME/.claude/backups"
SNAPSHOT="$BACKUP_ROOT/pre-bootstrap-$TS"

if [ -d "$SNAPSHOT" ]; then
  echo "ERROR: snapshot dir already exists: $SNAPSHOT"
  exit 1
fi

mkdir -p "$SNAPSHOT"

# 1. tarball of ~/.claude/ (excluding the backups dir itself + cache/transient)
EXCLUDES=(
  --exclude="$HOME/.claude/backups"
  --exclude="$HOME/.claude/cache"
  --exclude="$HOME/.claude/file-history"
  --exclude="$HOME/.claude/image-cache"
  --exclude="$HOME/.claude/paste-cache"
  --exclude="$HOME/.claude/session-env"
  --exclude="$HOME/.claude/shell-snapshots"
  --exclude="$HOME/.claude/telemetry"
)

tar -czf "$SNAPSHOT/claude.tar.gz" "${EXCLUDES[@]}" -C "$HOME" ".claude" 2>/dev/null

# 2. Manifest of what was captured
{
  echo "snapshot: pre-bootstrap-$TS"
  echo "at: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
  echo "machine: $(hostname)"
  echo "user: $(whoami)"
  echo "claude_dir: $HOME/.claude"
  echo "claude_version: $(claude --version 2>/dev/null || echo unknown)"
  echo "tar_size_bytes: $(wc -c < "$SNAPSHOT/claude.tar.gz")"
  echo "file_count: $(tar -tzf "$SNAPSHOT/claude.tar.gz" | wc -l)"
} > "$SNAPSHOT/manifest.txt"

# 3. Rollback script bound to this snapshot
cat > "$SNAPSHOT/rollback.sh" <<EOF
#!/usr/bin/env bash
# Restore ~/.claude/ from snapshot pre-bootstrap-$TS.
# Idempotent and safe to re-run.

set -e
SNAPSHOT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
TS_RESTORE=\$(date +%Y%m%d-%H%M%S)
TMPDIR=\$(mktemp -d)
SAFETY="$HOME/.claude/backups/before-rollback-\$TS_RESTORE"

# Safety: keep what's currently on disk before nuking it
mkdir -p "\$SAFETY"
tar -czf "\$SAFETY/claude.tar.gz" --exclude="$HOME/.claude/backups" --exclude="$HOME/.claude/cache" -C "$HOME" ".claude" 2>/dev/null
echo "Current state archived to: \$SAFETY/claude.tar.gz"

# Restore
tar -xzf "\$SNAPSHOT_DIR/claude.tar.gz" -C "$HOME"
echo "Restored ~/.claude/ from snapshot pre-bootstrap-$TS"
echo "Backup-of-current-state at: \$SAFETY"
EOF
chmod +x "$SNAPSHOT/rollback.sh"

# 4. Verify backup
if [ ! -s "$SNAPSHOT/claude.tar.gz" ]; then
  echo "ERROR: backup tarball is empty"
  exit 2
fi

EXPECTED=$(tar -tzf "$SNAPSHOT/claude.tar.gz" | wc -l)
if [ "$EXPECTED" -lt 5 ]; then
  echo "ERROR: backup tarball has too few files ($EXPECTED)"
  exit 3
fi

echo "BACKUP OK"
echo "snapshot: $SNAPSHOT"
echo "size: $(du -h "$SNAPSHOT/claude.tar.gz" | cut -f1)"
echo "files: $EXPECTED"
echo "rollback: bash $SNAPSHOT/rollback.sh"

# Return the snapshot path on stdout so /bootstrap can capture it
echo ""
echo "SNAPSHOT_PATH=$SNAPSHOT"
