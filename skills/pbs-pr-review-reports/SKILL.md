---
name: pbs-pr-review-reports
description: "Use after pbs-pr-review-context (and optionally consistency/general/security) to produce the Reviewer Dossier (for the human reviewer) and the Developer Report (for the PR author, with human + LLM-actionable sections). Works in MVP mode with only review-context.md."
---

# PR Review Reports

## Overview

Consume `review-context.md` (always) and `findings.md` (if it exists) and emit two markdown artifacts: a Reviewer Dossier (audience: the human reviewer) and a Developer Report (audience: the PR author + their agent). Findings are prioritized by severity. P0/P1 elevate to the main body; P2/info live in the appendix. Without findings, only a minimal Reviewer Dossier is produced — the workflow is still useful at MVP.

**Core principle:** Two audiences, two reports. The reviewer needs a navigable map; the author needs actionable findings with copy-paste LLM prompts. Never collapse them into one document.

**Announce at start:** "I'm using the pbs-pr-review-reports skill to generate the reviewer dossier and developer report."

## When to Use

- After pbs-pr-review-context, even without other passes (MVP path: minimal dossier with synthesis + manual review guide)
- After pbs-pr-review-consistency / pbs-pr-review-general / pbs-pr-review-security have appended findings to `findings.md`
- Re-running after the reviewer added manual findings to `findings.md`

## When NOT to Use

- Before pbs-pr-review-context — there is no `review-context.md` to consume. Run context first.
- To post comments to GitHub/GitLab — this skill produces local markdown files only.

## The Iron Law

```
TWO REPORTS, TWO AUDIENCES. NEVER MERGE.
WITHOUT EVIDENCE THERE IS NO FINDING — DROP IT OR PROMOTE IT TO A REVIEW-QUESTION.
SEVERITY DRIVES PLACEMENT: P0/P1 IN THE MAIN BODY, P2/INFO IN THE APPENDIX.
```

## Input

### Required
- `.pbs-framework/reviews/<branch-slug>/review-context.md` (produced by pbs-pr-review-context)
- `templates/pr-review-reviewer-dossier.md.template`
- `templates/pr-review-developer-report.md.template`

### Optional
- `.pbs-framework/reviews/<branch-slug>/findings.md` — accumulated by consistency / general / security passes
- The reviewer's manual notes appended to `findings.md` (same schema)

### Schema of a finding (must be enforced)
| Campo | Obligatorio |
|-------|-------------|
| severidad (P0 / P1 / P2 / info) | yes |
| confianza (alta / media / baja) | yes |
| evidencia (archivo:linea + cita textual del codigo) | yes |
| impacto | yes |
| sugerencia (lenguaje natural, no codigo) | yes |
| prompt-llm | optional |

If a candidate finding lacks `evidencia` (no textual citation), it must be demoted to a `review-question` BEFORE being included in any report.

## The Process

### Step 0: Detect Mode

Check for `findings.md`:
- **MVP mode** (no findings.md): produce only the Reviewer Dossier with synthesis + manual review guide. DO NOT produce a Developer Report (nothing to send to the author yet).
- **Full mode** (findings.md exists): produce both reports.

In both modes, `review-context.md` is mandatory. If it's missing, STOP and instruct the user to run `pbs-pr-review-context` first.

### Step 1: Read and Validate Inputs

1. Read `review-context.md` — extract triage, intent, file map, stack, review plan, validation commands.
2. If findings.md exists, parse each finding and validate it has all required fields. Reject (don't include) any finding without `evidencia`. Log rejections in your final report so the reviewer can review them manually.

### Step 2: Prioritize Findings

For each valid finding:
- P0 / P1 → "Hallazgos elevados" section of the Reviewer Dossier AND "Findings que necesitan tu atención" section of the Developer Report
- P2 / info → Apéndice of both reports

Within each bucket, sort by `confianza` descending (alta > media > baja).

### Step 3: Build the Manual Review Guide

From `review-context.md` file classification:
- Take all `core` files in the order they appear in the triage's flow analysis (entry point first, then downstream).
- For each, write a one-line "Por qué leer" — the role of the file in the change.
- Estimate reading time per file (5-15 min for core, omit for boilerplate).
- List `boilerplate` / generated / snapshot files in the "Archivos que puedes saltar" sub-section.

### Step 4: Fill Reviewer Dossier

Use `templates/pr-review-reviewer-dossier.md.template`. Sections:
1. Síntesis humana — refined from `review-context.md` Section 1 + the actual findings landscape (≤10 lines)
2. Manual review guide — from Step 3
3. Hallazgos elevados — P0/P1 with full schema rendered
4. Review questions — copied from findings.md (any candidate finding without evidence demoted here)
5. Skills de best-practices recomendados — copied from review-context.md
6. Resultado del review — verdict (Sí / No / Con fixes) + reasoning + 1-3 acciones sugeridas
7. Apéndice: P2 / info

Write to `.pbs-framework/reviews/<branch-slug>/reviewer-dossier.md`.

### Step 5: Fill Developer Report (only in Full mode)

Use `templates/pr-review-developer-report.md.template`. Sections:
1. Resumen — 1-2 lines, what was reviewed
2. Findings que necesitan tu atención — P0/P1 with the full human-readable rendering
3. Review questions abiertas — open questions the author needs to clarify
4. Acciones sugeridas — prioritized list
5. Sección LLM-actionable — one ` ```text ` block per finding, autocontained prompt with: severidad, archivo:linea, evidencia, problema, impacto, sugerencia, restricciones (don't touch unrelated files, keep public contract, ask if ambiguous)

Write to `.pbs-framework/reviews/<branch-slug>/developer-report.md`.

### Step 6: Enforce Length Budget

Orientative budget: each report ≤500 lines.

If a report exceeds budget:
1. Move all P2/info to the appendix (already done by default — re-verify).
2. Compact evidencia citations to the minimal lines that still prove the finding.
3. If still over budget, add a "Nota del skill" at the top of the report stating it was truncated, list the IDs of any findings that were summarized rather than fully rendered.

NEVER drop a P0/P1 finding to save space. If P0/P1 alone exceeds budget, do not truncate — report the over-budget as-is.

### Step 7: Report to Human

Briefly report:
- Mode used (MVP or Full)
- Counts: P0 / P1 / P2 / info / review-questions
- Verdict from Section 6 of the Dossier
- Path(s) to the generated file(s)
- Any findings rejected for lack of evidence (so the reviewer can fix them manually)

<HARD-GATE>
The human reviewer MUST read the Reviewer Dossier before sharing the Developer Report with the PR author or commenting on the PR.
The Dossier is the reviewer's own working document; the Developer Report is what goes to the author.
If the reviewer disagrees with severity, evidence quality, or the verdict, regenerate after they edit findings.md manually.
</HARD-GATE>

## Common Mistakes

- **Producing a Developer Report in MVP mode** — without findings there is nothing to send to the author. Generate only the Dossier.
- **Including findings without textual evidence** — Iron Law violation. Demote to review-question or drop entirely.
- **Mixing P2/info into the main body** — clutters the reviewer's view. Appendix is mandatory for them.
- **Skipping the Manual Review Guide** — the main differentiator for the reviewer. Always include, even in MVP mode.
- **Generating LLM prompts with code** — prompts should describe the problem and direction; the author's agent writes the code. Concrete code in prompts couples the suggestion to one solution.

## Red Flags

- "I'll merge the Dossier and the Developer Report — same content anyway" → NO. Different audiences, different framing.
- "This finding has no citation but is clearly true" → Demote to review-question. The author needs to see evidence.
- "I'll drop the P2 findings to keep the report short" → NO. Move them to the appendix. The reviewer decides what to share.
- "The LLM prompt should include the exact code fix" → NO. Describe the problem and direction; the author's agent writes the code.
- "MVP mode is incomplete — let me invent some findings" → NO. MVP mode is a feature, not a gap. Synthesis + manual review guide is already useful.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "The reviewer can re-prioritize, no need to enforce P0/P1 placement" | The placement IS the prioritization. Reviewers skim main bodies, appendices get skipped. |
| "Findings without evidence are still useful as hunches" | Hunches go to review-questions, not findings. The schema requires evidence. |
| "I'll skip the synthesis since pbs-pr-review-context already wrote it" | The Dossier's synthesis refines context's based on what passes actually found. Refresh it. |
| "Length budget is a suggestion, I can ignore it" | Long reports become unread reports. Compress P2/info first, then warn loudly if still over. |
| "Developer Report doesn't need an LLM section for trivial findings" | The author may not have an agent, but if they do, every finding should have one. It's cheap. |
| "I'll generate both reports even in MVP mode for consistency" | Empty Developer Report wastes the author's time and signals false alarms. MVP = Dossier only. |

## Integration

**Required discipline skills:**
- **REQUIRED:** superpowers:verification-before-completion — before reporting "done", confirm both files exist and the schema is enforced.

**Called after:**
- pbs-pr-review-context — at minimum (MVP mode produces Dossier-only)
- pbs-pr-review-consistency / pbs-pr-review-general / pbs-pr-review-security — when findings.md exists (Full mode)

**Calls next:** none. This is the terminal skill of the workflow. The reviewer shares the Developer Report (or pieces of it) with the PR author manually.

**Output contract:**
- `.pbs-framework/reviews/<branch-slug>/reviewer-dossier.md` — always
- `.pbs-framework/reviews/<branch-slug>/developer-report.md` — only in Full mode

**Language:** Write all `.pbs-framework/reviews/` documents in the language defined in AGENTS.md `framework_language` field.
