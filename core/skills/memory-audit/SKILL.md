---
name: memory-audit
description: Scan global + workstream memory dirs. Surface oversize entries, duplicate titles, stale entries, broken index refs, missing required fields, and CLAUDE.md ↔ MEMORY.md placement drift. Read-only.
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
---

# /memory-audit

Run periodically (monthly is fine). Read-only — outputs a triage report, never moves or edits memory.

## 1. Discover memory dirs

Glob `_memory/MEMORY.md` from common roots + the global memory dir:

```python
import glob
DIRS = ["~/.claude/projects/<project>/memory"]  # adjust to your auto-memory path
for pat in [
    "~/*/_memory",
    "~/Documents/*/_memory",
    "~/Documents/*/*/_memory",
    "~/Downloads/*/_memory",
    "~/Downloads/*/*/_memory",
    "~/projects/*/_memory",
    "~/code/*/_memory",
]:
    DIRS += glob.glob(pat)
```

## 2. Run the structural audit

```python
import re, datetime, glob
from pathlib import Path
from collections import defaultdict

TODAY = datetime.date.today()
oversize_index_entries = []   # >200 chars
broken_refs = []
orphan_files = []
duplicate_titles = []
stale = []
missing_fields = []
all_names = defaultdict(list)

for d in DIRS:
    d = Path(d).expanduser()
    if not d.exists(): continue
    mem_md = d / "MEMORY.md"
    files = [f for f in d.glob("*.md") if f.name != "MEMORY.md"]
    refs = set()
    if mem_md.exists():
        text = mem_md.read_text(encoding="utf-8", errors="replace")
        for line in text.splitlines():
            if len(line.strip()) > 200 and line.lstrip().startswith("-"):
                oversize_index_entries.append((str(mem_md), len(line.strip()), line.strip()[:80]))
            for ref in re.findall(r'\(([\w_\-]+\.md)\)', line):
                refs.add(ref)
                if not (d / ref).exists():
                    broken_refs.append((str(mem_md), ref))
    for f in files:
        if mem_md.exists() and f.name not in refs:
            orphan_files.append(str(f))
        body = f.read_text(encoding="utf-8", errors="replace")
        m = re.match(r'^---\n(.*?)\n---\n(.*)$', body, re.S)
        fm, content = {}, body
        if m:
            for ln in m.group(1).split("\n"):
                if ":" in ln:
                    k,v = ln.split(":",1); fm[k.strip()] = v.strip()
            content = m.group(2)
        name = fm.get("name") or f.stem
        all_names[name.lower()].append(str(f))
        t = fm.get("type","")
        if t in ("feedback","project"):
            if "**Why:**" not in content or "**How to apply:**" not in content:
                missing_fields.append((str(f), t))
        lv = fm.get("last_validated")
        if lv:
            try:
                d_lv = datetime.date.fromisoformat(lv)
                if (TODAY - d_lv).days > 90:
                    stale.append((str(f), f"last_validated {lv}, {(TODAY-d_lv).days}d ago"))
            except: pass
        else:
            mt = datetime.date.fromtimestamp(f.stat().st_mtime)
            if (TODAY - mt).days > 90:
                stale.append((str(f), f"no last_validated, mtime {mt}, {(TODAY-mt).days}d ago"))

duplicate_titles = [(n, paths) for n, paths in all_names.items() if len(paths) > 1]

# Print structured report
```

## 3. Placement drift scan

After the structural audit, scan for prescriptive content in MEMORY.md and factual content in CLAUDE.md.

```python
PRESCRIPTIVE = re.compile(r'\b(always|never|must|don\'?t|do not|prefer|default to|use\s+\w+\s+not|stop\s+\w+ing)\b', re.I)
FACTUAL = re.compile(r'\b(currently|live at|deployed at|in flight|in progress|pending|done|shipped|wired|installed)\b', re.I)

# For every MEMORY.md, find index entries whose hook reads prescriptively
# For every CLAUDE.md (~/.claude/CLAUDE.md + every workstream's), find bullets that record changing facts
```

## 4. Report

```
Memory audit · YYYY-MM-DD
Scanned: N dirs, M memory files.

🔴 BROKEN INDEX REFS: N
  - <path>/MEMORY.md → <missing-ref.md>

🔴 ORPHAN FILES (on disk, not in MEMORY.md): N
  - <path>

🟡 OVERSIZE INDEX ENTRIES (>200 chars): N
  - [N chars] <path>: <preview>

🟡 DUPLICATE TITLES: N
  - 'title':
    - path A
    - path B

🟡 STALE (>90d since last_validated or mtime): N
  - <path> — <reason>

🟡 MISSING WHY/HOW (feedback/project missing required structure): N
  - [type] <path>

🟣 PLACEMENT DRIFT
  - MEMORY → CLAUDE candidates: <file>: <line>
  - CLAUDE → MEMORY candidates: <file>: <line>

=== Health: PASS | NEEDS FIXES ===
```

## 5. Recommended fixes (never auto-execute)

- Broken ref → delete index line OR restore file from `_archive/`
- Orphan → add to index OR move to `_archive/` if obsolete
- Oversize → rewrite hook in ≤180 chars; detail goes in file
- Duplicate → merge into one canonical, archive the other
- Stale → open, re-verify, bump `last_validated`. Or archive.
- Missing Why/How → open and add structure, OR convert type if it's actually reference
- Placement drift → consider moving; but feedback memories legitimately live in MEMORY.md with `Why`/`How` context

The user decides what to fix. This command never auto-moves or auto-edits.
