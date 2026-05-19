---
name: pbs-pr-review-security
description: "Use after pbs-pr-review-context to build a lightweight threat model focused EXCLUSIVELY on what the PR introduces or changes. Does not audit historic debt. Reports security findings only with textual evidence, otherwise raises review-questions."
---

# PR Review Security

## Overview

Construct a lightweight threat model for the deltas the PR introduces — input validation, authn/authz, error exposure, secrets/tokens, idempotency, external calls — and report findings only when there is textual evidence in the changed code. Historic security debt in the repo is OUT of scope: this pass reviews what the PR adds or changes, not what was already broken.

**Core principle:** Delta-focused, not exhaustive. Threat model the diff, not the whole repo. Without evidence, raise a review-question.

**Announce at start:** "I'm using the pbs-pr-review-security skill to threat-model the PR deltas."

## When to Use

- After pbs-pr-review-context, when the review plan marks this pass `full` or `shallow`
- The PR introduces new endpoints, new auth flows, new external calls, new persisted data, new background jobs
- The triage marks the PR as `sensible` — security MUST always be `full` per the plan

## When NOT to Use

- The review plan marks this pass `skip` AND the triage is not `sensible` — respect the plan
- The PR is docs-only or config-only without secrets / permissions changes
- `review-context.md` is missing — run pbs-pr-review-context first

## The Iron Law

```
DELTA-ONLY: REVIEW WHAT THE PR INTRODUCES OR CHANGES.
NO REVIEWING HISTORIC SECURITY DEBT IN THIS PASS.
SIN EVIDENCIA NO HAY FINDING — WHEN IN DOUBT → REVIEW-QUESTION.
```

## Input

### Required
- `.pbs-framework/reviews/<branch-slug>/review-context.md` (produced by pbs-pr-review-context)
- `git diff <base>...<branch>` — to identify deltas (additions, modifications)

### Output
- Append findings and review-questions to `.pbs-framework/reviews/<branch-slug>/findings.md`. NEVER overwrite.

### Schema of a finding (mandatory)
| Campo | Obligatorio |
|-------|-------------|
| id (`F-NN`, sequential across passes) | yes |
| pase (`security`) | yes |
| severidad (P0 / P1 / P2 / info) | yes |
| confianza (alta / media / baja) | yes |
| evidencia (archivo:linea + cita textual del codigo cambiado) | yes |
| impacto | yes |
| sugerencia (lenguaje natural) | yes |
| prompt-llm | optional |

## The Process

### Step 0: Read Review Plan and Triage

Read `review-context.md` Sections 5 (Triage) and 6 (Review plan).

- If triage is `sensible` → ALWAYS run `full`, ignore any `skip`/`shallow` in the plan (sensible overrides).
- If plan is `skip` and triage is not `sensible` → STOP and report "skipped per review plan".
- If plan is `shallow` → cap each checklist item to top 2 findings.

### Step 1: Identify Delta Surface

From the diff, list:
- **New endpoints / routes / handlers** (controllers, route definitions)
- **New auth flows** (login, signup, password reset, OAuth, sessions)
- **New external calls** (HTTP clients, RPC, queues, webhooks, smart contract calls)
- **New persisted data** (DB writes, file uploads, cache writes)
- **New jobs / queues / scheduled tasks**
- **New cryptographic operations** (signing, hashing, encryption)
- **New input validation surfaces** (DTOs, schemas, parsers)
- **New error handlers / logging** (especially anything that returns user-facing errors)

If the diff has none of these AND triage is not `sensible`, you may early-exit with "no security-relevant deltas — no findings", and DO NOT invent findings.

### Step 2: Threat-Model the Deltas

For each delta from Step 1, ask the relevant questions and look for evidence in the changed lines:

**Input validation:**
- Does the new endpoint validate input shape, types, and ranges before using it?
- Is validation centralized (schema) or scattered (manual checks per field)?
- Any string concatenation into queries, commands, or paths? (SQL/command/path injection)
- File uploads: is MIME / size / extension validated server-side?

**Authentication / authorization:**
- Does the new endpoint require auth? Where is auth checked?
- Are roles / permissions enforced or only checked at UI level?
- Are auth tokens, session IDs, or API keys passed safely (not in URLs or logs)?
- Is authz checked AFTER authn (not skipped)?

**Error handling:**
- Are caught errors swallowed silently?
- Are stack traces or internal errors leaked to clients?
- Are validation errors and auth errors distinguishable to an attacker (timing or message differences)?

**Data exposure:**
- Are PII / secrets / tokens logged?
- Are they serialized in responses that the user shouldn't see?
- Are they persisted unencrypted where they shouldn't be?

**Secrets / tokens:**
- Are secrets committed to the repo (hardcoded keys, tokens, passwords)?
- Are env vars accessed in client-side code?
- Are tokens validated before use (signature, expiry, audience)?

**Idempotency:**
- Webhooks, payment callbacks, queue consumers: can they be replayed safely?
- Are retries safe (no duplicate side effects)?

**External calls:**
- Are timeouts configured?
- Is the failure mode safe (don't continue with partial state)?
- Are downstream errors handled distinctly from local errors?

For each issue found, capture the textual citation (snippet + file:line). Without citation → review-question.

### Step 3: Classify Severity

- Auth bypass / authz missing on a sensitive endpoint → P0
- Secret committed / exposed in response → P0
- Injection (SQL / command / path) → P0
- Missing input validation on a sensitive endpoint → P1
- Error leakage of internal details → P1
- Missing timeout / idempotency on payment/webhook handler → P1
- Verbose error responses in non-sensitive endpoints → P2
- Missing input validation on a non-sensitive endpoint → P2
- Logging style that may leak PII (uncertain) → review-question rather than finding

If triage is `sensible`, you may upgrade severity by one tier when the impact is high (e.g., P1 → P0 for auth missing on a payment endpoint).

### Step 4: Append to findings.md

Append findings using the schema. Continue numbering from the last `F-NN` already in the file.

If you found zero security-relevant issues, append a subsection:

```markdown
## Pase: security
Sin hallazgos de seguridad relevantes en los deltas de este PR.
Areas revisadas: [lista corta].
```

### Step 5: Report to Human

Briefly report:
- Delta surface counts (endpoints, auth, external, persisted, jobs, crypto, validation, error handlers)
- Counts: findings P0/P1/P2/info, review-questions
- Path to `findings.md`

<HARD-GATE>
The human reviewer MUST review findings appended in this pass before pbs-pr-review-reports consumes them.
For sensible PRs, the reviewer should validate the threat model coverage before signing off.
Do NOT proceed to pbs-pr-review-reports until findings.md is approved (or edited).
</HARD-GATE>

## Common Mistakes

- **Auditing historic debt** — out of scope. Only deltas the PR introduces or changes.
- **Inventing findings on chico/non-sensible PRs to look useful** — empty output is a valid result. Use the early-exit path.
- **Reporting "missing validation" without citing the line** — Iron Law violation. Demote to review-question.
- **Confusing client-side validation with server-side** — only server-side validation counts for security findings.
- **Overwriting findings.md** — append only.

## Red Flags

- "This existed before the PR but is dangerous, let me flag it" → NO. Out of scope. Note it in your final report as out-of-scope observation only.
- "I'll mark every endpoint missing validation as P0" → Severity depends on what the endpoint does. Not all endpoints are sensitive.
- "I'm not sure if this leaks PII, let me flag it anyway" → Demote to review-question.
- "Sensible triage means everything is P0" → No. Sensible means `full` review, not maximum severity for everything.
- "The framework probably handles auth" → If the changed code doesn't show auth being checked AND the route is sensitive, that's a finding.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "Security is everyone's job, I should flag historic issues too" | Out of scope for this pass. The PR review reviews the PR. |
| "Empty findings means I didn't try hard enough" | Empty findings on a chico non-sensible PR is correct. Don't invent. |
| "P0 makes the reviewer take it seriously" | Inflating P0 trains reviewers to ignore severities. Be precise. |
| "If I see a string concatenated into anything, it's injection" | Only if it touches a sink (query, command, path). Cite the sink. |
| "Idempotency only matters for payment endpoints" | Webhooks, queue consumers, and any retried operation need it. Check broadly. |
| "I'll skip the early-exit and pad with low-confidence findings" | Padding is noise. Early-exit is a feature. |

## Integration

**Required discipline skills:**
- **REQUIRED:** superpowers:verification-before-completion — every finding's citation must come from reading the actual lines, not memory.

**Called after:** pbs-pr-review-context

**Calls next:** pbs-pr-review-consistency / pbs-pr-review-general (any order) or pbs-pr-review-reports

**Output contract:**
- Appends findings to `.pbs-framework/reviews/<branch-slug>/findings.md`
- Numbering: continuous `F-NN` across passes; read existing entries first

**Language:** Write all `.pbs-framework/reviews/` documents in the language defined in AGENTS.md `framework_language` field.
