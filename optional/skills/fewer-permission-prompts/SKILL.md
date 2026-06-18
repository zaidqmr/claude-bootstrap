---
name: fewer-permission-prompts
description: Scan recent transcripts for read-only Bash/MCP calls you've approved many times, propose an allowlist for ~/.claude/settings.json so they auto-allow next time.
user-invocable: true
allowed-tools: Read, Edit, Bash, Grep
---

# /fewer-permission-prompts

Annoying truth: every "may I run `ls`?" prompt adds friction without adding safety. This skill scans your past sessions, finds the boring read-only ops you've approved 5+ times, and proposes an allowlist update.

Anthropic ships a related built-in skill. This is a tailored version.

## 1. Scan transcripts

Read recent session transcripts:

```bash
ls -lt ~/.claude/projects/*/  2>/dev/null | head -20
# Look at the .jsonl files for tool calls + permission decisions
```

For each Bash and MCP tool call, count:
- How many times it was approved
- How many times denied
- What the specifier was (e.g. `Bash(ls)`, `Bash(git status)`, `Bash(grep)`)

## 2. Propose allowlist

Filter to:
- **≥5 approvals**, zero denials → strong allow candidate
- Read-only operations (ls, grep, head, tail, wc, find with -print only, git status/log/diff, gh pr view, etc.)
- NOT including any secrets paths (.env, credentials, .ssh, etc.)
- NOT including any destructive ops (rm, mv, > redirect, sed -i, gh pr merge, git push)

Present the list:

```
Found 12 read-only operations approved ≥5 times each that aren't in your allow list:

  Bash(ls)                              approved 47 times
  Bash(ls:*)                             approved 31 times
  Bash(git status)                       approved 28 times
  Bash(git log:--oneline)                approved 22 times
  Bash(grep)                              approved 19 times
  ...

Add to ~/.claude/settings.json permissions.allow? (yes / no / pick individually)
```

## 3. Apply if approved

Merge into `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "Bash(ls)",
      "Bash(ls:*)",
      "Bash(git status)",
      ...
    ]
  }
}
```

Always back up the file first to `~/.claude/backups/permissions-<ts>/settings.json.bak`.

## 4. Report

```
✅ Updated ~/.claude/settings.json
  Added N rules to permissions.allow
  Backup: <path>

Next session should have ~<estimate>% fewer permission prompts.

If anything feels too permissive, edit the file or restore from backup.
```

## Safety

- Never auto-add anything matching `Bash(rm:*)`, `Bash(curl:*)`, `Bash(wget:*)`, `Bash(sudo:*)`, `Bash(*>*)`, or write-ops in MCP tools
- Never auto-add anything that touches `.env`, secrets, ssh, credentials paths
- Show the list before writing
- Always backup

## Source
- Anthropic ships a related skill named `fewer-permission-prompts` already
- https://dev.to/klement_gunndu/lock-down-claude-code-with-5-permission-patterns-4gcn
