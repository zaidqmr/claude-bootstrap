#!/usr/bin/env bash
# PreToolUse hook: protects .env, credentials, .ssh, .gnupg from being read by Read or Bash.
# Wire in ~/.claude/settings.json under hooks.PreToolUse with matcher "Read|Bash".
#
# This is a defense-in-depth layer on top of the secrets-deny-pack.json permission rules.
# Anthropic-confirmed leak: settings.json deny alone has been bypassed via Bash(cat:.env);
# this hook adds a second layer that fires regardless of permission rules.

set -e

INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))")

if [ "$TOOL" = "Read" ]; then
  TARGET=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))")
else
  TARGET=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))")
fi

# Secret file patterns
SECRET_PATTERNS=(
  "\\.env(\\..*)?$"
  "\\.env(\\..*)?[^/]*$"
  "credentials\\.(json|yaml|yml)"
  "credentials/"
  "secrets\\.(json|yaml|yml)"
  "secrets/"
  "\\.pem$"
  "\\.key$"
  "id_rsa"
  "id_ed25519"
  "\\.aws/credentials"
  "\\.ssh/"
  "\\.gnupg/"
)

for p in "${SECRET_PATTERNS[@]}"; do
  if echo "$TARGET" | grep -qE "$p"; then
    cat <<EOF >&2
🔐 Blocked attempt to access secret file pattern: $p
Tool: $TOOL
Target: $TARGET
This hook is in ~/.claude/settings.json. Remove only if you understand the risk.
EOF
    exit 2
  fi
done

exit 0
