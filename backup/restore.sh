#!/usr/bin/env bash
# Restore ~/.claude/ from a specific snapshot.
# Usage: bash restore.sh <snapshot-name-or-path>
# Example: bash restore.sh pre-bootstrap-20260618-220451

set -e

if [ -z "$1" ]; then
  echo "Usage: bash restore.sh <snapshot-name-or-path>"
  echo ""
  echo "Available snapshots:"
  ls -1 "$HOME/.claude/backups/" 2>/dev/null | grep "^pre-bootstrap-" || echo "  (none)"
  exit 1
fi

SNAP="$1"
if [ -d "$HOME/.claude/backups/$SNAP" ]; then
  SNAP_DIR="$HOME/.claude/backups/$SNAP"
elif [ -d "$SNAP" ]; then
  SNAP_DIR="$SNAP"
else
  echo "ERROR: snapshot not found: $SNAP"
  exit 1
fi

if [ ! -x "$SNAP_DIR/rollback.sh" ]; then
  echo "ERROR: no rollback.sh in $SNAP_DIR"
  exit 1
fi

bash "$SNAP_DIR/rollback.sh"
