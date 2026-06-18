#!/usr/bin/env bash
# Pull the latest version of the kit, then re-install /bootstrap.
# Safe to run at any time. Doesn't touch your existing CLAUDE.md, MEMORY.md, or other skills.

set -e

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$KIT_DIR"

echo "Pulling latest kit..."
git pull --ff-only

echo "Re-installing /bootstrap..."
bash "$KIT_DIR/install.sh"

cat <<EOF

Update complete.

The /bootstrap skill at ~/.claude/skills/bootstrap/ has been refreshed.
Your existing CLAUDE.md, MEMORY.md, and other skills are untouched.

To apply new optional skills, hooks, or MCPs added to the kit:
  $ claude
  > /bootstrap
  (it will detect a prior install and ask what to add)

EOF
