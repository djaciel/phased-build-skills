---
name: pbs-task-execution
description: "Use when implementing a single task from the current phase's tasks.md, in a fresh session with the phase spec ready"
---

# Task Execution

## Overview

Implement ONE task from the current phase's tasks.md. Fresh session per task. Human reviews diff before commit.

**Core principle:** The agent executes within strict boundaries — no modifications outside the task's scope, no autonomous architectural decisions, no "improvements" beyond what the task describes.

**Announce at start:** "I'm using the pbs-task-execution skill to implement task [ID] from phase [N]."

## When to Use

- Starting implementation of a specific task from tasks.md
- Resuming a task that was paused for human feedback
- Re-implementing a task after human requested changes to the approach

## The Iron Law

```
NO MODIFICATIONS OUTSIDE THE TASK'S SCOPE.
NO ARCHITECTURAL DECISIONS WITHOUT THE DECISION LOG.
DISCOVER SOMETHING OUT OF SCOPE? REPORT IT — DON'T DO IT.
```

## The Process

### Step 1: Load Context

1. Read the phase spec: `.pbs-framework/phases/phase-XX/spec.md`
   - Understand the phase objective, acceptance criteria, and contracts
   - Identify what this phase does NOT touch
2. Read the task definition from `.pbs-framework/phases/phase-XX/tasks.md`
   - Note the acceptance criteria, validation commands, and files to create/modify
3. Read ONLY the files listed in the task's "Archivos de contexto"
   - If a file is not listed, do NOT read it
   - If you think you need a file not listed, note it in the report — do NOT read it

### Step 2: Implement

1. Implement ONLY what the task describes — nothing more
2. **REQUIRED:** Use superpowers:test-driven-development
   - Write tests that verify EACH acceptance criterion
   - Follow the Red-Green-Refactor cycle strictly
3. Follow the contracts defined in the phase spec for any interfaces between modules
4. Follow ALL conventions from AGENTS.md
5. If a decision needs to be made that isn't covered by the Decision Log, STOP and report it in your output — do NOT decide autonomously

```
IMPORTANT: The tests are the law.
If your implementation makes existing tests fail,
change the implementation — not the tests.
```

### Step 3: Validate (Closed Loop)

1. Run the validation commands specified in the task definition, in order
2. **REQUIRED:** Use superpowers:verification-before-completion
   - Read actual command output — do not assume success
   - Provide evidence (real output) in your report

If ANY validation step fails:
1. Stop immediately
2. Identify the root cause (not the symptom)
3. Fix the issue — only the issue, do not refactor
4. Re-run ALL validation steps from the beginning
5. Only proceed when ALL steps pass

If a bug is complex: **REQUIRED BACKGROUND:** Use superpowers:systematic-debugging

### Step 4: Self-Review

Before reporting to the human, verify:

- [ ] Code fulfills ALL acceptance criteria from the task definition
- [ ] Each acceptance criterion has at least one test
- [ ] Did I touch files outside scope? If yes → revert those changes
- [ ] Did I make decisions not in the Decision Log? If yes → flag in report
- [ ] Did I refactor or "improve" anything not required? If yes → revert
- [ ] All validation commands pass with clean output

### Step 5: Report

Generate this structured report for the human:

```markdown
## Task Report — [Task ID]: [Task Name]

### What was implemented
[2-3 sentences describing what was built and why]

### Files created/modified
| File | Action | Description |
|------|--------|-------------|
| path/to/file | created/modified | One-line description |

### Tests created
| Test | What it validates |
|------|-------------------|
| test name/description | Which acceptance criterion it covers |

### Validation results
| Command | Result | Output |
|---------|--------|--------|
| [exact command] | pass/fail | [actual output — not summarized] |

### Decisions made
[Any decisions that should be added to the Decision Log.
If none: "No new decisions — all implementation followed existing specs."]

### Out-of-scope observations
[Anything discovered that belongs to other tasks or future phases.
If none: "Nothing out of scope observed."]

### Git diff summary
[Output of `git diff --stat`]
```

<HARD-GATE>
Do NOT commit code. The human reviews the diff and the report first.
Present the report, then WAIT for the human to approve before any commit.
This applies regardless of perceived simplicity or confidence level.
</HARD-GATE>

## Common Mistakes

- **Reading files not listed in context** — leads to scope creep and unnecessary coupling. Only read what's in "Archivos de contexto".
- **Writing tests after code** — violates TDD. The test must fail first, then the implementation makes it pass.
- **Committing without human review** — the hard gate exists because humans catch what agents miss. Never bypass it.
- **Modifying shared utilities "while you're there"** — even if the change is correct, it's outside scope. Report it.

## Red Flags

Signs the agent is about to violate the process — if you catch yourself thinking any of these, STOP:

- "I'll improve this file while I'm here" → NO. Only the task.
- "This refactor is small" → Out of scope. Report it.
- "Obviously we need this" → Is it in the spec? If not, report it.
- "The test is too simple to write" → TDD Iron Law applies. Write it.
- "I need to read more files to understand" → Only files in "Archivos de contexto".
- "Let me update the Decision Log myself" → Report the decision. Human updates the log.
- "I'll just fix this other bug I found" → Report it in out-of-scope observations.

## Common Rationalizations

| Excuse | Reality |
|--------|---------|
| "It's a one-line fix outside scope" | One-line fixes are still scope violations. Report it. |
| "The task implies this change" | If it's not explicit in the task, it's not in scope. |
| "Nobody will notice this improvement" | The human reviews every diff. They will notice — and lose trust. |
| "The existing code has a bug I should fix" | Report it in out-of-scope observations. Fixing it is a separate task. |
| "I need this utility for my implementation" | If the utility serves only this task, create it in scope. If it's shared, report the need. |
| "The test would pass anyway" | TDD requires seeing it fail first. No exceptions. |
| "I'll just commit since everything passes" | HARD GATE: human reviews before commit. Always. |
| "This decision is obvious" | If it's not in the Decision Log, it's not obvious enough. Report it. |

## Integration

**Required discipline skills:**
- **REQUIRED:** superpowers:test-driven-development — tests first, always
- **REQUIRED:** superpowers:verification-before-completion — evidence before claims

**Called by:**
- pbs-phase-planning — after human approves the plan, tasks are executed one by one

**May trigger:**
- superpowers:systematic-debugging — if a complex bug is found during implementation
- superpowers:requesting-code-review — (optional, requires full Superpowers) for critical tasks (blockchain, financial logic)

**Transitions:**
- If more tasks remain → next pbs-task-execution (fresh session)
- If this was the last task → pbs-phase-validation
