# Context7 MCP

**What it does:** Live, up-to-date framework/library documentation served as MCP tools. Instead of Claude guessing API shapes from training data (which goes stale), it queries Context7 for current docs at the moment of the question.

**When to install:** Always, unless you only work on completely proprietary internal code that has no external library surface.

## Install

```bash
claude mcp add --transport http context7 https://api.context7.com/mcp
```

Verify:
```bash
claude mcp list
# Should show: context7    http    https://api.context7.com/mcp    ✓
```

## Why this beats web search

- **Targeted**: queries the actual reference, not StackOverflow approximations
- **Versioned**: returns docs matching the specific version of the library you have installed
- **Faster**: structured response, not HTML parsing
- **Cheaper**: smaller context cost per query than a web fetch

## When to use it

Ask Claude things like:
- "How do I use server actions in Next.js 16?"
- "Show me the current signature of `prisma.$transaction`"
- "What's the right way to subscribe to Supabase changes in 2026?"

Context7 will be invoked automatically when Claude detects the question is about a library/framework.

## Cost / quota

Free tier: ~100 queries/day. Paid tier ~$5/mo for unlimited. Usually well within free tier even for heavy daily use.

## Source

- https://github.com/upstash/context7
- https://nimbalyst.com/blog/best-claude-code-mcp-servers/
