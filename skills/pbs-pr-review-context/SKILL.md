---
name: pbs-pr-review-context
description: "Use as the FIRST step when reviewing a PR — to reconstruct the PR's intent, map changed files, detect the stack, triage complexity, and produce a review-context.md that the rest of the pbs-pr-review-* skills consume."
---

# PR Review Context

## Overview

Build the foundation a reviewer needs to revise a PR without spending two days reading code. Run `git diff` locally, map files by responsibility, detect the stack, reconstruct intent from commits + PR metadata, triage complexity, and emit a `review-context.md` plus an adaptive review plan for the next pbs-pr-review-* passes.

**Core principle:** Reviewer enablement, not a comment bot. The output is a structured artifact for a HUMAN reviewer. No comments are posted to the PR. No code is modified in the reviewed repo.

**Announce at start:** "I'm using the pbs-pr-review-context skill to build review context for this PR."

## When to Use

- A teammate sent a PR and you must review it but don't want to spend 1-2 days reading code blindly
- You'll run other pbs-pr-review-* passes after this — they need `review-context.md` first
- The PR is non-trivial (or you suspect it is) and you need a triage signal before deciding how deep to go
- You're returning to a paused review and need to rebuild the mental map

## When NOT to Use

- The PR is a one-line typo or doc-only — read it and comment
- You authored the PR — use pbs-pr-hardening instead (author side, not reviewer side)
- You want a bot to post inline comments — this skill does not do that

## The Iron Law

```
GIT DIFF LOCAL ONLY. NO CODE MODIFICATIONS IN THE REVIEWED REPO.
THE OUTPUT IS review-context.md — NOT INLINE COMMENTS, NOT FIXES.
WITHOUT EVIDENCE, NO FINDING. WHEN IN DOUBT, RAISE A REVIEW-QUESTION.
```

## Input

### Required
- `branch` — the PR branch (e.g., `feat/onramp-validation`)
- `base` — the target branch (e.g., `main`, `develop`)
- Repo state: branch is fetched locally (`git fetch` if needed before running)

### Optional (enriches output if available)
- PR URL or number — if `gh` CLI is installed and authenticated, fetch PR description, ticket links, and the author's stated approach
- Ticket ID — improves intent reconstruction (Linear / Jira / etc.)

### Context to load (in this order)
1. `templates/pr-review-context.md.template` — the output structure
2. Manifest files at the repo root (`package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, etc.) — for stack detection
3. AGENTS.md / CLAUDE.md if present — for conventions referenced in findings
4. The PR description (via `gh pr view <branch>` or `gh pr view <number> --json title,body,commits`) — only if `gh` available
5. The actual diff: `git diff <base>...<branch>` — DO NOT read it blindly; use it to drive the next steps

## The Process

### Step 0: Pre-flight Checks

Before any analysis, verify:

1. Current directory is a git repo (`git rev-parse --show-toplevel`)
2. `branch` and `base` exist locally — if not, instruct the user to run `git fetch` and stop
3. The diff is non-empty — `git diff --quiet <base>...<branch>` should return non-zero; if the diff is empty, stop with: "No changes between base and branch. Nothing to review."

If `gh` CLI is available AND a PR URL/number was provided, fetch PR metadata. If not, continue without it — the workflow must not depend on `gh`.

### Step 1: List Changed Files

Run `git diff --name-status <base>...<branch>` to get the list of changed files with their status (A/M/D/R).

Stop and warn (do not block) if file count is unusually large (>200) — note in the review plan that commit-by-commit review may be advisable.

### Step 2: Classify Files by Responsibility

For each changed file, assign one of:
- **core** — contains the central business logic of the change
- **soporte** — helpers, utils, types, schemas supporting the core change
- **test** — unit / integration / e2e tests
- **boilerplate** — DTOs, exports, generated files, config, snapshots

Heuristics:
- Test paths or test-named files → test
- Files under `dto/`, `types/`, `schemas/`, `*.d.ts`, `*-generated.*`, `__snapshots__/` → boilerplate
- Files with the most diff lines AND not in the above categories → core
- The rest → soporte

Read ONLY the first 30-50 lines of each file to confirm classification — never read whole files at this stage.

### Step 3: Detect Stack

From manifest files and changed file extensions, fill the Stack table in the template:
- Language(s) (TypeScript, Python, Go, Solidity, etc.)
- Framework (Next.js, NestJS, Django, etc.)
- Runtime / build tool (Node, Bun, uv, pnpm, etc.)
- Database / ORM if visible in changed files
- Testing (Jest, Vitest, pytest, etc.)
- CI/CD (`.github/workflows/`, `.gitlab-ci.yml`)

Only record what you can see — leave cells blank if unknown rather than guessing.

### Step 4: Reconstruct Intent

Reconstruct, in ≤10 lines of plain language, what the PR is trying to achieve and how it approaches it.

Sources (in order of trust):
1. PR description (if available via `gh`)
2. Ticket link (if available)
3. Commit messages on the branch (`git log <base>..<branch> --pretty=format:'%h %s'`)
4. The `core` files identified in Step 2 — first 50 lines + main function signatures

Record under "Señales usadas para reconstruir la intención" which sources you used and which were unavailable. Do not invent intent — if signals are weak, say so explicitly and raise an open question.

### Step 5: Map Affected Flows

For each `core` file, identify the entry point (route/handler/job/CLI) and trace the call chain through `soporte` files. Produce either:
- A short prose description, OR
- An ASCII diagram (`[entry] → [service] → [model] → [output]`)

If the PR doesn't touch flows (e.g., docs, config), state "ninguno" — do not invent flows.

### Step 6: Apply Triage

Compute the classification using the heuristic in the template:

| Categoría | Criterio |
|-----------|----------|
| chico | ≤5 archivos sin lógica sensible |
| mediano | 6-20 archivos sin lógica sensible |
| grande | >20 archivos sin lógica sensible |
| sensible | toca cualquier área sensible (domina sobre las demás) |

**Sensitive areas (any match → sensible):** auth, pagos, datos sensibles, migraciones, permisos, jobs, queues, integraciones externas, contratos, wallets, tokens, balances.

Detect sensitive areas by file path keywords (e.g., `/auth/`, `/payments/`, `migrations/`, `/jobs/`, `wallet`, `token`) AND by code signals when reading core file headers (e.g., `@Post('/auth/login')`, contract addresses, balance arithmetic).

Sensitive overrides count — a 1-file PR that touches `migrations/` is `sensible`, not `chico`.

### Step 7: Generate Review Plan

Based on the triage, fill the Review plan table with profundidad `full`, `shallow`, or `skip` per pass:

- **chico**: consistency → shallow · general → shallow · security → skip (unless any single file looks risky)
- **mediano**: consistency → full · general → full · security → shallow
- **grande**: consistency → full · general → full · security → full · WARN: recommend commit-by-commit review
- **sensible**: ALL passes → full, regardless of file count

Justify each row in one short sentence — never leave the justification blank.

Also list best-practices skills to recommend manually (based on detected stack). Examples: `typescript-best-practices` if TS detected, `nodejs-best-practices` if Node, `vercel-react-best-practices` if Next.js, `solidity-security` if Solidity, etc. These are RECOMMENDATIONS for the human — this skill does NOT invoke them.

### Step 8: Generate review-context.md

Create the directory `.pbs-framework/reviews/<branch-slug>/` if missing. The `<branch-slug>` is the branch name with `/` replaced by `-` (e.g., `feat/onramp-validation` → `feat-onramp-validation`).

Fill in `templates/pr-review-context.md.template` and write to `.pbs-framework/reviews/<branch-slug>/review-context.md`.

Also detect validation commands from the repo (`npm test`, `pnpm test`, `pytest`, `cargo test`, lint commands from `package.json`/Makefile/CI) and fill Section 8.

### Step 9: Report to Human

Briefly report:
- Triage result and 1-line justification
- Counts: total files, core / soporte / test / boilerplate
- Number of best-practices skills recommended
- Path to `review-context.md`

<HARD-GATE>
The human MUST validate review-context.md before any other pbs-pr-review-* pass runs.
If the reviewer disagrees with the triage or the file classification, regenerate the affected sections.
Do NOT proceed to pbs-pr-review-consistency, pbs-pr-review-general, pbs-pr-review-security, or pbs-pr-review-reports until the context is approved.
This applies regardless of triage outcome.
</HARD-GATE>

## Common Mistakes

- **Reading whole files in Step 2** — classification only needs headers (first 30-50 lines). Reading entire files wastes context.
- **Inventing intent when signals are weak** — if PR description is empty and commits are uninformative, say so. Do NOT guess what the author meant.
- **Letting file count override sensitivity** — a 1-file PR touching `migrations/` is `sensible`, not `chico`. Sensitive always wins.
- **Auto-invoking best-practices skills** — Decision 5 of the spec: this skill only RECOMMENDS them in Section 6. The reviewer invokes them manually if desired.
- **Skipping the pre-flight checks** — if `git fetch` wasn't run, the diff may be stale or empty. Verify first.

## Red Flags

- "Let me just read the whole core file to be sure" → NO. Headers first. Functions later, only the ones that matter.
- "The diff is huge, let me skip triage" → NO. The triage is the whole point — without it the next passes have no plan.
- "The user said it's just a refactor, so chico" → Verify against the actual diff and sensitive-area heuristics. Stated intent does not override evidence.
- "I'll invoke typescript-best-practices now to save the reviewer a step" → NO. Recommend in the review plan. Reviewer invokes manually.
- "PR description says X, must be true" → PR descriptions can be outdated or misleading. Triangulate against commits and core files.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Triage is approximate, no need to justify each row" | The next passes consume the justification. Empty justification = pass runs blind. |
| "The PR has no description, I'll just describe what the diff does" | Describing the diff is not reconstructing intent. State that intent is uncertain and raise an open question. |
| "Classifying as `boilerplate` is subjective, I'll mark everything `core`" | Then the manual review guide is useless. Be specific: tests, snapshots, DTOs are NOT core. |
| "I'll write the review-context.md without running git diff — I already saw the PR" | The diff is the ground truth. Stale screen memory is not. Run it. |
| "If gh is not available, I can't reconstruct intent" | Commits + core file headers are enough for a first pass. State limitations explicitly in the output. |
| "The reviewer can fix the file classification themselves" | The HARD-GATE exists for that, but starting with a sloppy classification wastes their time. Be precise. |

## Integration

**Entry point:** This is the first skill in the pbs-pr-review-* workflow. No prerequisites.

**Required discipline skills:**
- **REQUIRED:** superpowers:verification-before-completion — read the actual `git diff` output and the actual file headers before classifying; do not assume.

**Called by:** the human reviewer at the start of a PR review.

**Calls next:**
- pbs-pr-review-reports — for the MVP path: context → reports (mínimum Reviewer Dossier, no specialized passes)
- pbs-pr-review-consistency / pbs-pr-review-general / pbs-pr-review-security — when the review plan marks them `full` or `shallow`

**Output contract:**
- File: `.pbs-framework/reviews/<branch-slug>/review-context.md`
- Other pbs-pr-review-* skills read this file FIRST and respect the `review-plan` (`full` / `shallow` / `skip`) per pass.

**Language:** Write all `.pbs-framework/reviews/` documents in the language defined in AGENTS.md `framework_language` field (default: the language the user is writing in).
