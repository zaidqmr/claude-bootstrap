#!/usr/bin/env bash
# PreToolUse hook: blocks obviously dangerous Bash commands.
# Wire in ~/.claude/settings.json under hooks.PreToolUse with matcher "Bash".
# Hook stdin: JSON payload with tool_input.command
# Hook stdout/exit: exit 2 + stderr blocks; exit 0 + JSON allows/denies/asks

set -e

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import sys, json; d = json.load(sys.stdin); print(d.get('tool_input', {}).get('command', ''))")

# Blocklist patterns
BLOCK_PATTERNS=(
  "rm -rf /"
  "rm -rf /\*"
  "rm -rf ~"
  "rm -rf \\\$HOME"
  ":(){:|:&};:"                     # fork bomb
  "mkfs\\."
  "dd if=.* of=/dev/"
  "> /dev/sd"
  "chmod -R 777 /"
  "chown -R .* /"
  "curl .* \| bash"
  "curl .* \| sh"
  "wget .* \| bash"
  "wget .* \| sh"
  "AKIA[0-9A-Z]{16}"                # AWS access key shape
  "git push --force.*main"
  "git push --force.*master"
  "git push -f.*main"
  "git push -f.*master"
)

for p in "${BLOCK_PATTERNS[@]}"; do
  if echo "$CMD" | grep -qE "$p"; then
    cat <<EOF >&2
🚫 Blocked dangerous command pattern: $p
Command: $CMD
This hook is in ~/.claude/settings.json. Remove it if you want to allow this.
EOF
    exit 2
  fi
done

# Allow
exit 0
