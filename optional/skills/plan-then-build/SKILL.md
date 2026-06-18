---
name: plan-then-build
description: Force Explore → Plan → Implement → Commit gate for non-trivial work. Stops the "vibecoding" failure mode where Claude jumps to implementation before understanding.
user-invocable: true
allowed-tools: Read, Glob, Grep, Agent
---

# /plan-then-build

For work touching 3+ files, schema changes, migrations, refactors, auth/payment/database code, MCP permissions, production config, or multi-file features. Skip for one-file edits or read-only questions.

## 1. Explore (read-only, isolated context)

Spawn an Explore subagent:

```
Agent({
  subagent_type: "Explore",
  description: "Map the surface area for <task>",
  prompt: "<task description> — explore the relevant code, document the current structure, identify dependencies and risk points. Report a structured map: files involved, functions, dependencies, tests, config knobs. Do NOT propose changes."
})
```

Explore has its own context window — your main session stays clean.

## 2. Plan (synthesize, propose)

Once Explore returns, draft a plan IN THE MAIN SESSION:

```
PLAN

Goal: <one-sentence outcome>

Constraints:
  - <perf/security/compat constraint>

Approach: <2-3 sentence summary of the strategy>

Steps:
  1. <action> (files: <list>)
  2. <action> (files: <list>)
  3. ...

Risks:
  - <risk> → mitigation: <strategy>

Tests to add/modify:
  - <test description>

Out of scope:
  - <thing we'll explicitly NOT do>

Estimated diff size: <small/medium/large>
```

## 3. Show plan, gate on approval

Present plan to user. Wait for explicit "go" or revision request.

If user says revise: update plan, re-show.

If user says go: proceed to step 4.

## 4. Implement (write code)

Execute the plan step by step. After each step:
- Verify intermediate state (run tests, check files exist)
- Commit if the step is logically complete

## 5. Commit + ship

Use `/ship` to finalize (or commit + PR manually).

## Why this exists

The #1 failure mode of agentic coding is jumping to implementation before understanding the surface area. Explore→Plan→Implement→Commit forces a deliberate pause where the model commits to a story before writing code.

Battle-tested: Anthropic recommends this pattern; obra/superpowers ships it as their flagship workflow; multiple retrospectives put it in top-5 regret skills.

## When to skip

- One-file edit, single function tweak, copy fix
- Read-only question or research
- Mechanical rename or formatting

Plan-then-build for those is just friction.
