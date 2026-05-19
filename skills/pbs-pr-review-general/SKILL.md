---
name: pbs-pr-review-general
description: "Use after pbs-pr-review-context to review code quality in the PR's core files: over/under-engineering, dead code, DRY violations, weak tests vs reconstructed intent. Recommends stack-specific best-practices skills for the reviewer to invoke manually — does NOT invoke them automatically."
---

# PR Review General

## Overview

Inspect the `core` files of the PR for quality issues a human reviewer would catch on a careful read: over-engineering, missing error handling, dead code, duplicated logic, weak tests, missing edge case coverage. Recommend stack-specific best-practices skills for the reviewer to run manually based on the detected stack.

**Core principle:** Quality review with evidence. Every finding cites the offending line. Stack-specific lint is delegated to the reviewer's manual invocation of best-practices skills — this skill never invokes them.

**Announce at start:** "I'm using the pbs-pr-review-general skill to review code quality of the PR's core files."

## When to Use

- After pbs-pr-review-context, when the review plan marks this pass `full` or `shallow`
- The reviewer wants a generic quality pass before deciding which best-practices skills to invoke
- Tests are part of the PR and the reviewer wants them sanity-checked against the reconstructed intent

## When NOT to Use

- The review plan marks this pass `skip` — respect it
- The PR is docs-only or config-only — there's no logic to review
- `review-context.md` is missing — run pbs-pr-review-context first

## The Iron Law

```
SIN EVIDENCIA NO HAY FINDING. WHEN IN DOUBT → REVIEW-QUESTION.
THIS SKILL DOES NOT INVOKE OTHER SKILLS. IT RECOMMENDS THEM.
ONLY THE CORE FILES — SKIP TESTS UNLESS COMPARING AGAINST INTENT, SKIP BOILERPLATE.
```

## Input

### Required
- `.pbs-framework/reviews/<branch-slug>/review-context.md` (produced by pbs-pr-review-context)
- `git diff <base>...<branch>` — to focus on changed code in core files

### Output
- Append findings and review-questions to `.pbs-framework/reviews/<branch-slug>/findings.md`. NEVER overwrite — other passes append too.
- A "Recomendado correr manualmente" entry per detected stack-specific skill (no invocation).

### Schema of a finding (mandatory)
| Campo | Obligatorio |
|-------|-------------|
| id (`F-NN`, sequential across passes) | yes |
| pase (`general`) | yes |
| severidad (P0 / P1 / P2 / info) | yes |
| confianza (alta / media / baja) | yes |
| evidencia (archivo:linea + cita textual) | yes |
| impacto | yes |
| sugerencia (lenguaje natural) | yes |
| prompt-llm | optional |

## The Process

### Step 0: Read Review Plan

Read `review-context.md` Section 6. If this pass is `skip`, STOP. If `shallow`, cap each category below to top 3 findings. If `full`, no cap (but never report without evidence).

### Step 1: Identify Targets

From `review-context.md` Section 2:
- **Review:** files marked `core`
- **Review only against intent:** files marked `test` (do they actually test the reconstructed intent? are they weak assertions?)
- **Skip:** files marked `soporte` and `boilerplate` (other passes or the reviewer handles them)

### Step 2: Quality Checks on Core Files

For each core file, look for evidence of:

**Architecture & complexity:**
- Over-engineering: abstractions used in only one place; premature generalization; speculative configuration knobs
- Under-engineering: missing error handling on external calls; silent swallow of errors; no input validation on public functions
- Cyclomatic complexity: functions with deeply nested branches or many responsibilities

**Code hygiene:**
- Dead code: unused functions, unreachable branches, commented-out blocks
- Duplication: nearly identical logic across files (point to existing helper if obvious; otherwise raise review-question for pbs-pr-review-consistency to confirm)
- Naming inconsistencies vs AGENTS.md conventions (if present)

**Tests vs intent:**
- Tests that assert only `truthy`/`defined` rather than the actual expected value
- Tests that exercise the implementation but not the contract (testing internals)
- Missing edge cases from the intent (e.g., intent says "validate empty input" but no test covers empty input)
- Tests with no setup/teardown when state is shared

For each issue, capture the textual citation (snippet copied from the file with file:line). Without citation → review-question.

### Step 3: Detect Stack-Specific Skills to Recommend

Read `review-context.md` Section 3 (Stack detectado). For each technology, list the relevant best-practices skill the reviewer SHOULD invoke manually:

| Stack signal | Recommended skill |
|--------------|-------------------|
| TypeScript / JavaScript | `typescript-best-practices`, `modern-javascript-patterns` |
| Node.js backend | `nodejs-best-practices`, `nodejs-backend-patterns` |
| Next.js / React | `next-best-practices`, `vercel-react-best-practices`, `tailwind-css-patterns` |
| Python | `python-design-patterns`, `python-testing-patterns`, `async-python-patterns`, `python-performance-optimization` |
| Solidity / smart contracts | `solidity-security` |
| Trading / backtesting | `backtesting-frameworks` |

**This skill does NOT invoke them.** It only adds them to the recommendations section.

### Step 4: Classify and Severity

For each candidate with evidence:

- Missing error handling on critical path (auth, payments, data integrity) → P1 or P0 if loss is irreversible
- Silent error swallowing → P1
- Dead code → P2 or info
- Weak test assertion → P2 (P1 if it's the only test for a critical flow)
- Over-engineering / speculative abstraction → P2 (P1 if it actively obscures the code)
- Duplication within the PR (3+ near copies) → P1
- Naming convention violations → P2 (P1 if it's a public contract)

### Step 5: Append to findings.md

Append findings using the schema. Continue numbering from the last `F-NN` already in the file.

Add a clearly labeled subsection at the end:

```markdown
## Recomendado correr manualmente (pase: general)
- typescript-best-practices — stack detectado: TypeScript en archivos core
- nodejs-best-practices — stack detectado: Node.js + Express
- [skill N] — stack detectado: [signal]
```

### Step 6: Report to Human

Briefly report:
- Files reviewed (count of core; tests vs intent)
- Counts: findings P0/P1/P2/info, review-questions
- Skills recommended manually
- Path to `findings.md`

<HARD-GATE>
The human reviewer MUST review findings appended in this pass and the manual-recommendation list before pbs-pr-review-reports consumes them.
The reviewer decides whether to invoke any best-practices skill manually.
Do NOT proceed to pbs-pr-review-reports until findings.md is approved (or edited).
</HARD-GATE>

## Common Mistakes

- **Invoking typescript-best-practices automatically** — Decision 5 of the spec: manual only. This skill recommends, it does not invoke.
- **Reviewing boilerplate / DTOs** — other passes or the human handle. Skip them per the file classification.
- **Reporting "over-engineering" without evidence** — taste is not evidence. Cite the specific abstraction and explain why it's premature.
- **Confusing test coverage with test quality** — a test that runs is not a test that asserts. Read the actual assertions.
- **Overwriting findings.md** — append only.

## Red Flags

- "This pattern is bad practice everywhere" → If you can't cite the line in this PR, don't flag.
- "I'll just run typescript-best-practices myself to save the reviewer time" → NO. Recommend, don't invoke.
- "The reviewer will catch the weak tests" → If you see them, flag them. That's the point.
- "I don't know the stack well enough" → Recommend the best-practices skill and limit your findings to generic quality issues.
- "Style violations are not worth flagging" → If AGENTS.md is explicit about a convention, violations are P2.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Best-practices skills are stack-specific, I shouldn't try" | Correct — don't try. Recommend them and stop. |
| "I'll auto-invoke them, the reviewer will thank me" | No — the reviewer wants control over what runs. Stay manual. |
| "P0 means urgent, I'll mark this dead code P0" | Dead code is P2 unless it's actively dangerous. Don't inflate. |
| "I'll cite the suggestion as evidence" | The evidence is the offending code, not your sentence. Cite the snippet. |
| "Weak tests are a maintenance issue, not a review issue" | Weak tests for critical flows are a P1 review issue. Flag them. |
| "Tests against the intent require the spec, which I don't have" | The intent is in `review-context.md` Section 1. Compare against that. |

## Integration

**Required discipline skills:**
- **REQUIRED:** superpowers:verification-before-completion — every citation MUST come from reading the actual lines.

**Called after:** pbs-pr-review-context

**Calls next:** pbs-pr-review-consistency / pbs-pr-review-security (any order) or pbs-pr-review-reports

**Output contract:**
- Appends findings + recommendations to `.pbs-framework/reviews/<branch-slug>/findings.md`
- Numbering: continuous `F-NN` across passes; read existing entries first

**Language:** Write all `.pbs-framework/reviews/` documents in the language defined in AGENTS.md `framework_language` field.
