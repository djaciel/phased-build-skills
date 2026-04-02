---
name: pbs-pr-hardening
description: "Use after completing all tasks in a phase, before closure — when the phase code needs adversarial review and PR preparation"
---

# PR Hardening

## Overview

Harden the phase deliverable into a reviewable, mergeable PR. This replaces the old validation step with a real adversarial code review cycle.

**Core principle:** The phase is not done when tasks are complete. It's done when the code can survive scrutiny from an independent reviewer and the PR is navigable by a human.

**Announce at start:** "I'm using the pbs-pr-hardening skill to review phase [N] and prepare it as a PR."

## When to Use

- After ALL tasks in a phase are completed and committed
- Before phase closure
- When you want a fresh, adversarial review of the phase's work

## The Iron Law

```
YOU ARE THE REVIEWER, NOT THE IMPLEMENTER.
REPORT ISSUES — DO NOT FIX THEM.
THE REVIEW REPORT IS THE DELIVERABLE — NOT FIXED CODE.
```

## Input

### Required Context (load in this order)
1. Phase spec: `.pbs-framework/phases/phase-XX/spec.md`
2. Phase tasks: `.pbs-framework/phases/phase-XX/tasks.md`
3. Decision Log: `.pbs-framework/03-decision-log.md`
4. Git diff for the entire phase: `git diff <phase-start-sha>..HEAD`

### Context Detection

If the user does not specify which phase:
1. Scan `.pbs-framework/phases/` (or `.pbs-framework/features/[name]/phases/`) for the latest phase directory
2. Read its `tasks.md` — verify ALL tasks are completed
3. If tasks are not all completed → STOP: "Not all tasks are complete. Complete remaining tasks before hardening."

## The Process

### Step 1: Spec Compliance Quick-Check

Before deep review, verify the basics:

1. For EACH acceptance criterion in spec.md:
   - Is it implemented? (Yes/No/Partial)
   - Is there a test? (Yes/No)
2. Run ALL validation commands from tasks.md
3. **REQUIRED:** Use superpowers:verification-before-completion — real output, not assumptions

If ANY acceptance criterion fails → record as `critical` finding and continue the review. Do NOT stop.

### Step 2: Adversarial Code Review

Review the phase's code changes with the mindset of an external reviewer who does NOT know the project history. Focus on:

**Architecture & Design:**
- Over-engineering: abstractions that serve only one use case
- Under-engineering: missing error handling, missing edge cases
- Contract violations: do module interfaces match the spec?
- Decisions without justification: code patterns that don't trace back to spec or Decision Log

**Code Quality:**
- Dead code: unused functions, unreachable branches, commented-out code
- Naming inconsistencies: do names match AGENTS.md conventions?
- DRY violations: duplicated logic that should be shared
- Type safety gaps (if applicable)

**Testing:**
- Tests that validate implementation details (fragile tests)
- Missing edge case coverage
- Tests that would pass even if the code was wrong (weak assertions)

**Security & Domain-Specific:**
- OWASP top 10 awareness
- Domain checks from AGENTS.md `risk_domain` (blockchain: reentrancy, overflow; finance: decimal precision, idempotency; etc.)

**Decision Delta Review:**
- Review task reports for Decision Deltas — were autonomous decisions adequately justified?
- Flag any decision that adds complexity without clear benefit

### Step 3: Generate Review Report

Generate `.pbs-framework/phases/phase-XX/review-report.md` using the `review-report.md.template`.

**Rules:**
- Frontmatter `status` starts as `in_progress`
- Every finding `Status` starts as `pending`
- Categorize severity accurately — not everything is critical
- Be specific: file:line, not vague descriptions
- Explain WHY each issue matters, not just WHAT is wrong
- Include a suggestion for HOW to fix (when not obvious)
- The "Spec Compliance Check" table comes from Step 1
- The "Resultado del Review" gives a clear verdict

**Issue Severity:**
- **critical:** Breaks acceptance criterion, contract, or security invariant. MUST be fixed before PR.
- **important:** Architecture problem, weak test, missing error handling. SHOULD be fixed.
- **minor:** Style, naming, optimization opportunity. Nice to have.

### Step 4: Generate PR Description

Generate `.pbs-framework/phases/phase-XX/pr-description.md` using the `pr-description.md.template`.

**Rules:**
- "Archivos clave" MUST be ordered by reading priority — the order a reviewer should follow to understand the change
- "Decisiones tecnicas nuevas" MUST include all decisions from task Decision Deltas that were approved
- "Que quedo fuera" MUST reference tech debt or deferred items
- "Como probar" MUST include actual commands that work

### Step 5: Present to Human

Report:
- Number of findings by severity
- Clear verdict: "Ready for PR? Yes / No / With fixes"
- Highlight any critical or important findings that need attention
- Point to review-report.md and pr-description.md locations

<HARD-GATE>
Do NOT fix any issues. Do NOT modify any code.
The review report is the deliverable. The human decides what happens next:
- If findings exist → invoke pbs-review-fixes to address them
- If no findings or only minor → proceed to pbs-phase-closure
This applies regardless of perceived simplicity of fixes.
</HARD-GATE>

## Common Mistakes

- **Fixing issues yourself** — you are the reviewer, not the implementer. Report only.
- **Marking everything as critical** — be honest about severity. Nitpicks are minor.
- **Vague findings** — "improve error handling" is useless. Say WHERE, WHAT is wrong, and WHY.
- **Skipping spec compliance** — Step 1 catches basic gaps before deep review.
- **Reviewing without running commands** — verification-before-completion is mandatory. Run the tests.
- **Missing the PR description** — the review report is for fixing; the PR description is for understanding. Both are required.

## Red Flags

- "This is fine, I'll just note it" → If it's a real issue, classify and report it properly.
- "The fix is obvious, let me just..." → NO. You are the reviewer. Report it.
- "This is just style" → If it violates AGENTS.md conventions, it's not just style.
- "I don't understand this code, but tests pass" → If you can't understand it, a reviewer won't either. Flag readability.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "The code works, so it must be fine" | Working code can still be fragile, over-engineered, or insecure. |
| "This finding is too small to report" | If it affects readability or maintainability, report it as minor. |
| "I'll fix this one thing since I see it" | Reviewer doesn't fix. Report it. |
| "The tests pass, quality must be fine" | Passing tests don't prove good design, readability, or security. |
| "Everything is critical" | If everything is critical, nothing is. Be precise about severity. |

## Integration

**Called after:** All pbs-task-execution tasks complete

**Required skills:**
- **REQUIRED:** superpowers:verification-before-completion — evidence before claims

**Transitions:**
- If critical/important findings → pbs-review-fixes (resolve findings, then return here for verification)
- If clean or only minor → pbs-phase-closure

**Language:** Write all `.pbs-framework/` documents in the language defined in AGENTS.md `framework_language` field.
