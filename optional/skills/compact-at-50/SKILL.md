---
name: compact-at-50
description: Recommend or trigger /compact when context fills past 50%, not 95%. Performance degrades past 60-70% — auto-compact at 95% is too late.
user-invocable: true
allowed-tools: Read, Bash
---

# /compact-at-50

A monitoring + nudge skill. Watches your context fill rate, suggests `/compact` proactively.

## How to use it

Two modes:

**Mode 1 · Manual check**
Run `/compact-at-50` periodically during long sessions. It checks current context usage and tells you if you're past 50%.

**Mode 2 · Auto-nudge (recommended)**
Install as a hook by adding to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "claude-code --check-context --threshold 0.5 || true"
          }
        ]
      }
    ]
  }
}
```

Note: Exact command depends on your Claude Code version's introspection API. If unavailable, run manually.

## The logic

```python
# Claude Code exposes context usage; check it
usage = get_context_usage()  # 0.0 to 1.0
if usage > 0.70:
    print("⚠ Context at {:.0%}. Performance degrades fast past 70%. Run /compact NOW.".format(usage))
elif usage > 0.50:
    print("ℹ Context at {:.0%}. Consider /compact before next non-trivial task.".format(usage))
else:
    print("✓ Context at {:.0%}. Plenty of room.".format(usage))
```

## Why 50%, not 95%

Anthropic auto-compacts at 95%. By then, the agent has already started degrading:

- ≥40% context spent on tool descriptions → degradation
- ≥60-70% context fill → accuracy drops noticeably
- 95% → agent is already making mistakes from the bloat

50% is "still snappy + room to plan a /compact deliberately, not panicked." 70% is "compact NOW or accept the drop in quality."

## Source
- https://www.aicodex.to/articles/claude-code-antipatterns
- https://www.substratia.io/blog/context-management-guide/
