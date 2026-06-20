---
name: knowai-doc
description: >-
  Create any internal KnowAI document — company memo, strategy doc, explainer,
  brief, framework, review, roadmap, one-pager — in the locked KnowAI document
  style. Aeonik + JetBrains Mono, blue/ink/paper tokens, fixed structure
  (eyebrow → title → props row → welcome callout → optional status legend →
  Contents index → lettered section banners → numbered topic cards with
  field grids and status pills), single-column long-form, print-to-PDF ready.
  Use whenever someone asks to write, format, or design a KnowAI document so the
  whole team ships the same format. Reference template: template.html.
---

# KnowAI Document Format

A single locked HTML format for every internal KnowAI document, so any person on
the team produces a doc that looks like it came from the same company. Output is
one self-contained `.html` file the reader opens in a browser and prints to PDF
with Cmd+P.

## When to use

Any time the work is "a document": a company memo, a strategy doc, a framework, a
positioning brief, a review, an onboarding explainer, a roadmap, a one-pager, a
spec. If it's an Instagram carousel or a lead-magnet article, those have their
own formats — this skill is for **structured internal/external reference
documents** built as topic cards.

## How to build one

1. **Copy `template.html`** (in this skill folder) as the starting point. It
   carries the complete, locked `<style>` block — never rewrite the CSS, never
   restyle. Only fill in content.
2. **Gather the doc's metadata** before writing: title, one-line subtitle, the
   four props (Audience, Author/Owner, Last updated `YYYY-MM-DD`, Sections
   count), and the list of sections + topics.
3. **Write the content** into the fixed structure (below). Keep voice calm,
   specific, builder-led — short sentences, earned claims, no emoji in body copy.
4. **Save** to `~/Downloads/<Kebab-Case-Title>.html` and open it in the browser
   for review.

## The fixed structure (in order)

1. **Header** — `.eyebrow` (mono, blue, e.g. "Company memo · Canonical
   explainer") → `h1.page-title` → `.page-sub` (one sentence, what this doc is) →
   `.props` (4-cell grid: Audience / Author / Last updated / Sections).
2. **Welcome callout** (`.welcome`) — blue left-border panel. One paragraph:
   "How to read this." Explain the doc's shape and any status convention.
3. **Status legend** (`.legend`) — *optional*. Include only if topics carry
   status pills. Defines Live / Building / Planned (or your own set).
4. **Contents** (`.toc`) — 3-column grid of lettered section groups, each listing
   its numbered topics as anchor links (`#t1`, `#t2`, …). Header shows topic count.
5. **Section banners** (`.section-banner`) — one per section: `.eyebrow`
   ("Section A"), `h2` (section name), one-line `p` describing what's inside.
   The first/optional "Section 0 · …" is a "Start here" one-page summary.
6. **Topic cards** (`.topic`, `id="t{n}"`) — the workhorse. Each = numbered
   square + topic name + optional status pill, then a **field grid** of
   label/value pairs. Labels are mono uppercase ("What it is", "Why it exists",
   "How it works", "Reader takeaway", etc.). Values can hold paragraphs, `<ul>`,
   `<strong>`, inline `<code>`, and `<h4>` sub-heads.
7. **Footer** (`.footer`) — mono, centered: `Brand · Doc type · YYYY-MM-DD ·
   Last reviewed by [name]`.

## Locked design tokens (do not change)

- **Fonts** — Aeonik (sans, primary; weights 300/400/700) with `Inter Tight`
  fallback; JetBrains Mono for eyebrows, labels, props, status pills, footer.
  Aeonik loads from a local `fonts/` folder via `@font-face`; JetBrains Mono
  loads from Google Fonts. If Aeonik files aren't present it falls back to Inter
  Tight cleanly — leave the `@font-face` block in regardless.
- **Colour** — Blue `#146DF7` (the one accent: links, eyebrows, emphasis) ·
  Ink `#05121B` (text) · Paper `#F7F7F7` (page bg) · Surface `#FFFFFF` (cards).
  One blue accent only. When in doubt, look quiet.
- **Status pills** — `.live` green · `.building` amber · `.planned` indigo.
- **Layout** — 1440px shell, generous whitespace, hairline rules over heavy
  borders, soft shadows, rounded cards. Print CSS keeps cards from breaking.

## Voice rules (part of the format)

- Short sentences over long ones. Specific over abstract. Earned claims over
  confident claims. No emoji decoration in long-form copy.
- Every topic card should be able to end with a **Reader takeaway** — the single
  thing to remember from that block.
- Brand/name capitalisation is part of credibility — write names exactly
  (e.g. **KnowAI**: one word, capital K/A/I; never "Know AI" or "knowAI").

## Sharing this skill with the team

The whole folder (`SKILL.md` + `template.html`) is self-contained. To give it to
a teammate: drop the `knowai-doc/` folder into their `~/.claude/skills/`
directory (or the project's `.claude/skills/`), and it appears automatically.
For the fonts to embed in the rendered HTML, ship the Aeonik `fonts/` folder
alongside the generated `.html`; without it the doc still renders correctly on
the Inter Tight fallback.
