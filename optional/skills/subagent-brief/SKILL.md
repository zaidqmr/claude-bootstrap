---
name: subagent-brief
description: Structured template for briefing parallel subagents. Each agent starts with a fresh context — this skill forces you to write a self-contained brief so the agent doesn't stall on missing context.
user-invocable: true
allowed-tools: Read, Agent
---

# /subagent-brief

When you spawn a subagent (via Agent tool or Task()), it gets a fresh context window. No memory of this conversation. If your brief assumes context the agent doesn't have, it'll stall or hallucinate.

This skill is a template + checklist for the brief.

## The 6-part brief template

```
GOAL · what you want the agent to accomplish (1 sentence)
WHY · why this matters / what depends on it (1 sentence)
CONTEXT · what the agent needs to know that isn't in the code (3-5 bullets)
INPUTS · specific files/paths/data the agent should read
CONSTRAINTS · don't-touch list, format requirements, length cap
DELIVERABLE · the exact shape of the response you want back
```

## Always-include guard

Every subagent brief should start with:

```
SESSION GATE: manifest is active for parent task '<task>'. Proceed as a sub-agent. 
Do not ask "what are you working on this session" — the manifest is already in place.
Write any state changes to .claude-manifest-<your-session-id>.json with is_sub_agent: true.
```

This prevents the agent from stalling on the session-gate check that fires when CLAUDE.md autoloads.

## Anti-pattern guards

- **Don't dispatch >4 parallel agents on one machine.** Rate limits + merge complexity.
- **Big subagent output kills parent context.** Cap with `report under N words`, or have agent write to a file and return only the path.
- **Subagents can't ask permission.** Restrict to read-only tools (`allowed-tools: Read, Grep, Glob` only) unless they really need to write.
- **Brief is the only context they get.** Write self-contained, don't reference prior conversation.

## Example brief (good)

```
Agent({
  subagent_type: "general-purpose",
  description: "Audit dependencies for security issues",
  prompt: `
SESSION GATE: manifest is active for parent task 'Q3 security audit'. Proceed as sub-agent.

GOAL · find dependencies with known CVEs in the Node monorepo at /repo/services/
WHY · we ship to production Friday and a CVE found post-release is a P0
CONTEXT
  - Monorepo uses pnpm
  - Services in /repo/services/*; each has package.json
  - We deploy to AWS Lambda; Node 22 only
INPUTS
  - /repo/services/*/package.json
  - Don't read node_modules
CONSTRAINTS
  - Read-only; don't modify any file
  - Report in under 300 words
  - Use 'npm audit' style severity (low/moderate/high/critical)
DELIVERABLE
  Format:
    service-name | dependency | current | safe | severity | CVE link
  Critical and high only. Skip low/moderate unless ≤3 total.
  `
})
```

## Example brief (bad)

```
Agent({
  prompt: "look at the deps and tell me what's wrong"
})
```

Too vague. Agent will explore everything, burn context, return a wall of text.

## Why this exists

In the community retrospective rankings, "I shipped a custom subagent for everything and the orchestrator lost context" is a top-5 mistake. The fix is fewer, better-briefed agents — not more. This skill forces the briefing discipline.
