#!/usr/bin/env bash
# Drops /bootstrap skill into ~/.claude/skills/, nothing else.
# All other changes happen when the user runs /bootstrap inside Claude Code.

set -e

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

mkdir -p "$SKILLS_DIR/bootstrap"

# Copy the bootstrap skill
cp "$KIT_DIR/bootstrap/SKILL.md" "$SKILLS_DIR/bootstrap/SKILL.md"

# Make backup script available to bootstrap
mkdir -p "$SKILLS_DIR/bootstrap/lib"
cp "$KIT_DIR/backup/backup.sh"   "$SKILLS_DIR/bootstrap/lib/backup.sh"
cp "$KIT_DIR/backup/restore.sh"  "$SKILLS_DIR/bootstrap/lib/restore.sh"
chmod +x "$SKILLS_DIR/bootstrap/lib/"*.sh

# Make the kit dir discoverable to /bootstrap
echo "$KIT_DIR" > "$SKILLS_DIR/bootstrap/lib/KIT_DIR"

cat <<EOF

Installed: /bootstrap skill at $SKILLS_DIR/bootstrap/

Next:
  1. Open a Claude Code session anywhere:  cd ~ && claude
  2. Type:  /bootstrap
  3. Answer the questions.

Nothing on your machine has changed except one new skill.
The /bootstrap command takes a backup before any further changes.

EOF
