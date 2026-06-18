#!/usr/bin/env bash
# PreToolUse hook: reject Bash(git commit) without Conventional Commits format.
# Wire in ~/.claude/settings.json under hooks.PreToolUse with matcher "Bash".

set -e

INPUT=$(cat)
CMD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('command',''))")

# Only fire on git commit
echo "$CMD" | grep -qE "^git commit" || exit 0

# Extract -m message
MSG=$(echo "$CMD" | grep -oP -- "-m\s+['\"]\K[^'\"]+" | head -1)

[ -z "$MSG" ] && exit 0  # commit without -m (interactive editor) — allow, can't validate

# Conventional commit regex: type(scope)?: subject
if echo "$MSG" | grep -qE "^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9-]+\))?: .+"; then
  exit 0
fi

cat <<EOF >&2
❌ Commit message does not follow Conventional Commits.
Got: "$MSG"
Expected: <type>(<scope>): <subject>
Types: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

Example: feat(auth): add OAuth provider for GitHub
         fix(api): handle null in /users response

Either rewrite the message, or remove this hook from ~/.claude/settings.json.
EOF
exit 2
