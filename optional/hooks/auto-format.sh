#!/usr/bin/env bash
# PostToolUse hook: auto-format files after Edit/Write.
# Wire in ~/.claude/settings.json under hooks.PostToolUse with matcher "Edit|Write".
# Detects language by extension and runs the right formatter if installed.

set -e

INPUT=$(cat)
TARGET=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_input',{}).get('file_path',''))")

[ -z "$TARGET" ] && exit 0
[ ! -f "$TARGET" ] && exit 0

case "$TARGET" in
  *.ts|*.tsx|*.js|*.jsx)
    command -v prettier >/dev/null && prettier --write "$TARGET" 2>/dev/null || true
    command -v eslint >/dev/null && eslint --fix "$TARGET" 2>/dev/null || true
    ;;
  *.py)
    command -v ruff >/dev/null && ruff format "$TARGET" 2>/dev/null || true
    command -v black >/dev/null && black -q "$TARGET" 2>/dev/null || true
    ;;
  *.go)
    command -v gofmt >/dev/null && gofmt -w "$TARGET" 2>/dev/null || true
    ;;
  *.rs)
    command -v rustfmt >/dev/null && rustfmt "$TARGET" 2>/dev/null || true
    ;;
  *.json)
    command -v prettier >/dev/null && prettier --write "$TARGET" 2>/dev/null || true
    ;;
  *.md)
    command -v prettier >/dev/null && prettier --write "$TARGET" 2>/dev/null || true
    ;;
esac

exit 0
