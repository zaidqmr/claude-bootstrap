---
name: ship
description: Guided pre-PR review and push. Lints, runs tests, checks for secrets, generates commit message, pushes, opens PR.
user-invocable: true
allowed-tools: Read, Bash, Grep
---

# /ship

End-to-end pre-merge gate. Stops at first failure so you can fix and re-run.

## 1. Sanity checks

```bash
git status
git diff --stat HEAD
git branch --show-current
```

If on `main`/`master`/`trunk`: stop. "Not pushing directly to main. Branch first."

## 2. Secret scan

```bash
# Quick grep for common secret shapes in staged changes
git diff --cached | grep -E "(AKIA[0-9A-Z]{16}|sk-[a-zA-Z0-9]{40,}|-----BEGIN.*PRIVATE KEY|password.*=.*['\"]\\w{8,})" && {
  echo "POTENTIAL SECRET in staged diff. Stop and review."
  exit 1
}
```

## 3. Run tests if available

```bash
# Detect test command from package.json/Makefile/etc
if [ -f package.json ] && grep -q '"test"' package.json; then npm test; fi
if [ -f Makefile ] && grep -qE '^test:' Makefile; then make test; fi
if [ -f pyproject.toml ] && grep -q "pytest" pyproject.toml; then pytest -q; fi
```

If tests fail: stop. Show output. Don't proceed.

## 4. Run linter/formatter if available

```bash
# Match common patterns
[ -f package.json ] && grep -q '"lint"' package.json && npm run lint
[ -f .ruff.toml ] || [ -f pyproject.toml ] && command -v ruff >/dev/null && ruff check .
```

## 5. Generate commit message

If there's no message yet, generate one in Conventional Commits format based on the diff:

```
<type>(<scope>): <subject>

<body explaining why, not what>
```

Show to user for approval before committing.

## 6. Commit + push

```bash
git add -p   # let user stage interactively (or git add . if they confirmed)
git commit -m "<approved message>"
git push -u origin "$(git branch --show-current)"
```

## 7. Open PR

```bash
gh pr create --fill --web
```

Or, if user is in a hurry:
```bash
gh pr create --fill
```

## Report

```
✅ Shipped.
Branch: <name>
Commits pushed: N
PR: <url>

Next: address review comments, then merge.
```
