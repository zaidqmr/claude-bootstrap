#!/usr/bin/env bash
# Drops /bootstrap skill into ~/.claude/skills/, nothing else.
#
# Two ways to run this:
#   A) Local: bash install.sh  (when you've already cloned the repo)
#   B) One-liner: curl -fsSL https://raw.githubusercontent.com/zaidqmr/claude-bootstrap/main/install.sh | bash
#      (works because the script self-clones the repo to ~/claude-bootstrap when piped)

set -e

REPO_URL="https://github.com/zaidqmr/claude-bootstrap"
TARGET_DIR="$HOME/claude-bootstrap"

# Detect curl-pipe mode: BASH_SOURCE is "bash" or empty when stdin-piped
is_piped=false
if [ "${BASH_SOURCE[0]:-bash}" = "bash" ] || [ -z "${BASH_SOURCE[0]:-}" ] || ! [ -f "${BASH_SOURCE[0]:-}" ]; then
  is_piped=true
fi

if $is_piped; then
  echo "Detected curl-pipe install."
  if [ -d "$TARGET_DIR/.git" ]; then
    echo "Found existing clone at $TARGET_DIR. Pulling latest..."
    cd "$TARGET_DIR"
    git pull --ff-only
  else
    echo "Cloning $REPO_URL to $TARGET_DIR..."
    git clone "$REPO_URL.git" "$TARGET_DIR"
    cd "$TARGET_DIR"
  fi
  # Re-exec from the cloned copy so KIT_DIR resolves correctly
  exec bash "$TARGET_DIR/install.sh"
fi

# Local mode (KIT_DIR is the directory this script lives in)
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"

mkdir -p "$SKILLS_DIR/bootstrap"

# Copy the bootstrap skill
cp "$KIT_DIR/bootstrap/SKILL.md" "$SKILLS_DIR/bootstrap/SKILL.md"

# Make backup script available to bootstrap
mkdir -p "$SKILLS_DIR/bootstrap/lib"
cp "$KIT_DIR/backup/backup.sh"  "$SKILLS_DIR/bootstrap/lib/backup.sh"
cp "$KIT_DIR/backup/restore.sh" "$SKILLS_DIR/bootstrap/lib/restore.sh"
chmod +x "$SKILLS_DIR/bootstrap/lib/"*.sh

# Make the kit dir discoverable to /bootstrap
echo "$KIT_DIR" > "$SKILLS_DIR/bootstrap/lib/KIT_DIR"

cat <<EOF

Installed: /bootstrap skill at $SKILLS_DIR/bootstrap/
Kit location: $KIT_DIR

Next:
  1. Open a Claude Code session:  cd ~ && claude
  2. Inside the session, type:    /bootstrap
  3. Answer the questions.

Nothing on your machine has changed except one new skill.
The /bootstrap command takes a backup before any further changes.

EOF
