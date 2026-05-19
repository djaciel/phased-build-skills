---
name: pbs-pr-review-consistency
description: "Use after pbs-pr-review-context to find precedents in the codebase for elements the PR introduces (types, fields, utilities, functions). Reports inconsistency findings only when a textual citation of the precedent is available — otherwise raises a review-question."
---

# PR Review Consistency

## Overview

Detect when a PR introduces a new element (type, field, utility, function, schema) that has an existing precedent in the codebase, and the PR diverges from that precedent. The skill MUST cite the precedent textually (file:line + snippet copied verbatim) before declaring a finding. Without a citation, the candidate becomes a review-question rather than a finding.

**Core principle:** Precedent search is the differentiator of pbs-pr-review-* vs commercial tools. The value is "memory of the codebase", not lint. Without textual evidence, the agent is hallucinating.

**Announce at start:** "I'm using the pbs-pr-review-consistency skill to look for precedents in the codebase."

## When to Use

- After pbs-pr-review-context has produced `review-context.md` and the review plan marks this pass `full` or `shallow`
- The PR introduces new types, fields, utilities, functions, or schemas that may have precedents
- The reviewer suspects duplicated logic, divergent naming, or inconsistent types

## When NOT to Use

- The review plan marks this pass `skip` — respect the plan
- The PR is purely a refactor with no new elements (renames don't need precedent search)
- `review-context.md` does not exist — run pbs-pr-review-context first

## The Iron Law

```
SIN CITA TEXTUAL DEL PRECEDENTE NO HAY FINDING.
SIN EVIDENCIA → REVIEW-QUESTION, NO FINDING.
NEVER READ ENTIRE FILES — SEARCH FIRST, READ HEADERS, READ THE EXACT FUNCTION.
```

## Input

### Required
- `.pbs-framework/reviews/<branch-slug>/review-context.md` (produced by pbs-pr-review-context)
- `git diff <base>...<branch>` — to enumerate new elements

### Output
- Append findings (and review-questions for unverified suspicions) to `.pbs-framework/reviews/<branch-slug>/findings.md`. **NEVER overwrite** the file — other passes also append.
- If `findings.md` does not exist, create it with a header but DO NOT touch entries from other passes.

### Schema of a finding (mandatory)
| Campo | Obligatorio |
|-------|-------------|
| id (`F-NN`, sequential across all passes) | yes |
| pase (`consistency`) | yes |
| severidad (P0 / P1 / P2 / info) | yes |
| confianza (alta / media / baja) | yes |
| evidencia (archivo:linea + cita textual del precedente) | yes |
| impacto | yes |
| sugerencia (lenguaje natural, no codigo) | yes |
| prompt-llm | optional |

## The Process

### Step 0: Read Review Plan

Read `review-context.md` Section 6. If `pbs-pr-review-consistency` is `skip`, STOP and report "skipped per review plan". If `shallow`, perform Steps 1-3 but cap each precedent search at 2 candidates. If `full`, proceed normally.

### Step 1: Enumerate New Elements

From the diff, list candidates worth a precedent search:
- New type / interface / class declarations
- New field on an existing type (column on a DB model, property on a DTO)
- New utility / helper / pure function
- New schema (Zod / JSON schema / Yup / GraphQL)
- New constants or enums

Skip: imports, exports, formatting changes, tests, generated code.

Cap the list by the review plan: `shallow` = top 5 most prominent (largest diff size on the core files), `full` = all up to 30 (warn if more).

### Step 2: Search Precedents (Layered)

For each candidate, search by layers — never read whole files:

1. **grep / ripgrep** for the name and close variants (singular/plural, camelCase/snake_case).
2. If matches found, **read the first 30-50 lines** of each matching file to confirm it's a real precedent (not a coincidence).
3. If confirmed, **read the exact lines containing the precedent** to capture the textual citation.

Stop searching as soon as you have 1-3 confirmed precedents — quality over quantity.

### Step 3: Compare and Classify

For each candidate with confirmed precedents:

- **Same shape, different name** → finding `naming-inconsistency`, severidad P2 (unless naming is part of a contract — then P1).
- **Different type for the same conceptual field** (e.g., `customerId: string` here vs `customerId: UUID` elsewhere) → finding `type-inconsistency`, severidad P1.
- **Logic duplicated** (>80% similarity in body) → finding `duplication`, severidad P1 (or P0 if the precedent has known invariants the new copy lacks).
- **Different validation rules for the same field** → finding `validation-inconsistency`, severidad P1.
- **Suspicion without confirmable precedent** → **review-question**, NOT finding.

Each finding MUST include the textual citation of the precedent (snippet copied verbatim from the file, with file:line).

### Step 4: Append to findings.md

If `findings.md` doesn't exist, create it with:
```markdown
# Findings — PR: [branch]
## Pase: consistency | general | security
<!-- Findings are appended by each pass. Do not rewrite this file. -->
```

Append each finding with all required schema fields. Use the next available `F-NN` (read existing entries, continue numbering).

Then append review-questions in a separate sub-section:
```markdown
## Review questions (pase: consistency)
- Q-NN: [pregunta concreta para el autor]
```

### Step 5: Report to Human

Briefly report:
- Candidates evaluated, precedents found, candidates without precedent
- Counts: findings P0/P1/P2/info, review-questions
- Path to `findings.md`

<HARD-GATE>
The human reviewer MUST review the findings appended in this pass before pbs-pr-review-reports consumes them.
The reviewer may demote findings, edit citations, or move items between findings and review-questions.
Do NOT proceed to pbs-pr-review-reports until the reviewer has approved (or edited) findings.md.
</HARD-GATE>

## Common Mistakes

- **Reporting a finding without textual citation** — Iron Law violation. Demote to review-question.
- **Reading entire files** — always search → headers → exact lines. Whole-file reads waste context and miss the target.
- **Confusing coincidental name matches with real precedents** — `validate` is too generic. Confirm by reading 30-50 lines.
- **Sending shallow precedent search when plan says full** — respect the plan or escalate.
- **Overwriting findings.md** — other passes append. ALWAYS append, never replace.

## Red Flags

- "I'm 80% sure this duplicates Onramp.validate, but I haven't read it" → READ IT. No citation, no finding.
- "Naming is subjective, P1" — Severity depends on whether naming is part of a public contract. Default P2 for internal naming.
- "Let me grep the whole repo for every word" → Cap the candidate list per the review plan. Don't blow up scope.
- "The precedent looks similar but uses a different type — must be wrong" → Different types can be intentional. Raise as review-question first, finding second.
- "I'll skip the review plan and run full anyway" → The plan exists to avoid wasted work on chico PRs.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Citing the full snippet is too verbose" | The reviewer needs the snippet to validate the finding. Cite it. |
| "I remember seeing this pattern, evidence is implicit" | Memory is not evidence. Read the file. |
| "If there's no precedent, I should still warn" | If there's no precedent, there's no inconsistency. Don't warn — that's noise. |
| "Generics like `validate` always have precedents" | Maybe, but generics with different responsibilities aren't real precedents. Read enough to confirm. |
| "P0 means the reviewer will pay attention" | Severity is about real impact. Inflating severities trains reviewers to ignore them. |
| "I'll rewrite findings.md to clean up other passes' formatting" | NEVER. Append only. Other passes own their entries. |

## Integration

**Required discipline skills:**
- **REQUIRED:** superpowers:verification-before-completion — every citation MUST be confirmed by reading the actual lines, not memory.

**Called after:** pbs-pr-review-context (mandatory)

**Calls next:** pbs-pr-review-general / pbs-pr-review-security (in any order) or pbs-pr-review-reports (when all selected passes are done)

**Output contract:**
- Appends findings (with mandatory citation) and review-questions to `.pbs-framework/reviews/<branch-slug>/findings.md`
- Numbering: continuous `F-NN` across all passes; read existing entries before assigning the next number

**Language:** Write all `.pbs-framework/reviews/` documents in the language defined in AGENTS.md `framework_language` field.
