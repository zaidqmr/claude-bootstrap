# Playwright MCP

**What it does:** Browser automation via accessibility tree (not pixels). Microsoft-maintained. Lets Claude drive a real browser — navigate, click, fill forms, read DOM, take screenshots — without screenshot-loop overhead.

**When to install:** Any time you do UI work (Next.js, React, Vue, Svelte), e2e testing, web scraping with auth, or repeatable browser tasks.

## Install

```bash
claude mcp add --transport stdio playwright -- npx @playwright/mcp@latest
```

First run will install browser binaries; let it.

Verify:
```bash
claude mcp list
# Should show: playwright    stdio    npx @playwright/mcp@latest    ✓
```

## Why this beats the Claude browser extension

The browser extension (separate product) is slow, unreliable, and burns tokens because it screenshot-loops on every action. Playwright MCP works on the accessibility tree directly — much faster, deterministic, doesn't blow up usage.

## When to use it

- "Open localhost:3000, click 'Sign in with Google', screenshot after redirect"
- "Run the login flow and check the dashboard renders"
- "Fill the contact form and submit, report any console errors"
- "Scrape the last 10 posts from <internal-tool>"

## Cost / quota

MCP itself is free. Browser runtime costs (CPU/memory) are local.

## Source

- https://github.com/microsoft/playwright-mcp
- https://nimbalyst.com/blog/best-claude-code-mcp-servers/
