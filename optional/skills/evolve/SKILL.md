---
name: evolve
description: Heavy-touch system evolution pass. Scans recent corrections + manifest checkpoints + memory writes, surfaces patterns, proposes CLAUDE.md / skill / hook updates. Run monthly or when the system feels stale.
user-invocable: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# /evolve

The deepest learning pass. Where `/save` captures a single session and `/retrospective` looks at one session's meta-lessons, `/evolve` looks across multiple sessions to find patterns the baseline doesn't yet encode.

Run when:
- Monthly housekeeping
- The system feels stale (corrections keep repeating)
- After 30+ manifest checkpoints since last `/evolve`
- Before a major handoff (e.g. cloning the setup to another machine via `/instinct-export`)

## 1. Gather inputs

```bash
# Last 30 manifest checkpoints across all active workstreams
find ~ -name ".claude-manifest*.json" -mtime -90 2>/dev/null | while read m; do
  python3 -c "
import json
m = json.load(open('$m'))
for cp in m.get('checkpoints', [])[-30:]:
    print(f\"{cp.get('at','?')[:10]}\t{cp.get('accomplished','?')[:200]}\")
"
done | sort

# Recent memory writes (last 60 days)
find ~/.claude/projects/*/memory ~/Downloads/Know\ AI/*/_memory -name "*.md" -mtime -60 2>/dev/null

# Recent skill writes
find ~/.claude/skills -name "SKILL.md" -mtime -60 2>/dev/null

# Last 30 days of /save outputs from session transcripts
grep -l "/save" ~/.claude/projects/*/*.jsonl 2>/dev/null | head -30
```

## 2. Pattern detection

Look for:

**Repeated corrections** — across multiple sessions the user said the same thing 2+ times. Each is a CLAUDE.md rule candidate (graduate it from memory to constitution).

**Repeated workflows** — user manually ran the same multi-step command sequence 3+ times across sessions. Each is a skill candidate (use `/extract-skill` logic).

**Drifted rules** — feedback memories say "always X" but recent sessions show user doing Y. Either the rule changed or the rule is being ignored. Surface for review.

**Dead skills** — `~/.claude/skills/<x>/SKILL.md` exists but hasn't been invoked in 60+ days. Candidate for archive.

**Memory bloat** — global MEMORY.md grew past 25KB or 200 lines (Anthropic's auto-load cap). Some entries need to demote to workstream or archive.

**Workstream drift** — workstream heat-map shows things as HOT but last touched is 30+ days. Re-categorize.

**Hook gaps** — same destructive action almost happened 2+ times and was caught manually. Candidate for PreToolUse hook.

## 3. Propose updates

Surface as a structured list:

```
EVOLUTION PROPOSALS · YYYY-MM-DD

📈 PROMOTE memory → CLAUDE.md (rule corrected 2+ times)
  [1] feedback_browser_brave.md (mentioned in 4 checkpoints since 2026-04)
      → propose: add to CLAUDE.md global rules section
  
🆕 NEW SKILL CANDIDATES (workflow repeated 3+ times)
  [2] "git pull && pnpm install && pnpm typecheck" — seen in 5 sessions
      → propose: /pull-sync skill
  
⚠️ DRIFTED RULES (rule says X, behavior shows Y)
  [3] feedback_no_em_dashes.md says no em-dashes, but 3 docs shipped with them this month
      → propose: review whether rule still applies, or add a hook to enforce
  
💤 DEAD SKILLS (60+ days no invocation)
  [4] ~/.claude/skills/<x>/SKILL.md last invoked 2026-04-12
      → propose: archive to ~/.claude/skills/_archive/

📦 MEMORY OVERFLOW (global MEMORY.md > 24KB)
  Current: 28.4KB / 240 lines
  → propose: demote N workstream-specific entries to their workstream _memory/

🌡️ HEAT MAP DRIFT (workstream marked HOT but stale)
  [5] `<workstream>/` marked 🔥 HOT but last touched 32 days ago
      → propose: drop to ❄️ COLD
```

Show user. Ask: "Approve which proposals? (1,2,3 / all / none / explain N)"

## 4. Apply approved updates

For each approved proposal:

- **Promote to CLAUDE.md** → backup `~/.claude/CLAUDE.md`, then edit it inline to add the rule. Update the feedback memory's frontmatter to note "promoted to CLAUDE.md YYYY-MM-DD."
- **New skill** → scaffold `~/.claude/skills/<name>/SKILL.md`. Use `/extract-skill` logic.
- **Drifted rule** → don't auto-decide; flag for user review with proposed options.
- **Dead skill** → move to `~/.claude/skills/_archive/`.
- **Memory overflow** → list candidates for demotion, ask which to move.
- **Heat map** → edit MEMORY.md inline.

## 5. Manifest checkpoint

```bash
python3 -c "
import json, datetime
with open('.claude-manifest.json') as f: m = json.load(f)
m.setdefault('checkpoints', []).append({
    'at': datetime.datetime.utcnow().isoformat() + 'Z',
    'accomplished': 'Evolved system: <N proposals approved, M applied>',
    'next': 'Watch for the same correction patterns next month',
    'kind': 'evolve'
})
with open('.claude-manifest.json', 'w') as f: json.dump(m, f, indent=2)
"
```

## 6. Report

```
System evolved.

Promoted to CLAUDE.md: N rules
New skills scaffolded: <list>
Drifted rules flagged: N (review needed)
Dead skills archived: N
Memory entries demoted: N
Heat map updates: N

Baseline updated. Next /evolve: ~30 days.

Backups for everything modified: ~/.claude/backups/evolve-<ts>/
```

## Why this exists

The `/save` + `/retrospective` + `/memory-audit` + `/skill-health` quartet maintains the system. `/evolve` is the deeper pass that actually EVOLVES the baseline: rules graduate from memory to CLAUDE.md, workflows graduate from manual to skill, dead weight gets archived. Without periodic `/evolve`, the baseline calcifies and corrections keep repeating.

Pair with the Self-Improvement Protocol in the global CLAUDE.md (§9). That section makes the system listen for corrections; this skill makes the system grow from them.
