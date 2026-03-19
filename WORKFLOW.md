# Phased Build Skills — Workflow Guide

Step-by-step guide for using the PBS skills in both scenarios: new projects from scratch and features in existing codebases.

---

## Workflow A: New Project from Scratch

```
┌─────────────────────────────────────────────────────────────┐
│ STAGE 0: EXPLORATION                                        │
│                                                             │
│ Step 1 → pbs-exploration-brainstorming                      │
│ Step 2 → pbs-exploration-discovery                          │
│          ├─ Blocks 1-7: investigate + identify spikes       │
│          ├─ pbs-spike-planning (generate spike specs)       │
│          ├─ PAUSE: run spikes in separate sessions          │
│          │   └─ pbs-spike-execution (per spike)             │
│          └─ RESUME: read spike results + close synthesis    │
│                                                             │
│ STAGE 1: DEFINITION                                         │
│                                                             │
│ Step 3 → pbs-generating-definitions                         │
│                                                             │
│ STAGE 2: CONSTRUCTION (repeat per phase)                    │
│                                                             │
│ Step 4 → pbs-phase-planning                                 │
│ Step 5 → pbs-task-execution (per task)                      │
│ Step 6 → pbs-phase-validation                               │
│ Step 7 → pbs-phase-closure                                  │
│          ↓                                                  │
│ Step 8 → Back to Step 4 for next phase, or DONE             │
└─────────────────────────────────────────────────────────────┘
```

### Step 1: Brainstorming — `pbs-exploration-brainstorming`

**What you do:**
1. Tell the AI your project idea (can be vague)
2. Answer questions ONE AT A TIME through 5 blocks:
   - Block 1: The Problem (what, who, why)
   - Block 2: Proposed Solution (happy path, differentiator)
   - Block 3: Scope and Limits (POC vs MVP, in/out)
   - Block 4: Users and Context (who uses it, how)
   - Block 5: Risks and Open Questions
3. Review the generated brainstorming synthesis

**Output:** `.pbs-framework/exploration/brainstorming-synthesis.md`

**Human gate:** Review and approve the synthesis. If gaps exist, iterate.

**Estimated time:** 2-4 hours across 1-3 sessions

**When done, say:** "The brainstorming synthesis is approved. Let's start technical discovery."

---

### Step 2: Discovery — `pbs-exploration-discovery`

**What you do:**
1. The AI reads the approved brainstorming synthesis
2. Investigate 7 blocks together:
   - Block 1: Stack and Technologies
   - Block 2: Integrations and External Data (VERIFY with real docs!)
   - Block 3: Tentative Architecture
   - Block 4: Design Patterns and Decisions
   - Block 5: Non-Functional Requirements
   - Block 6: Dev Tools and Environment
   - Block 7: Feasibility Spikes — identify uncertain questions, generate spike specs
3. If spikes are needed → **discovery pauses** (see Step 2b below)
4. After spikes → resume discovery, read results, close the synthesis

**Output:** `.pbs-framework/exploration/discovery-synthesis.md` + spike specs at `.pbs-framework/exploration/spikes/`

**Human gate:** Review and approve. Challenge any unverified claims.

**Estimated time:** 3-6 hours across 2-4 sessions (+ spike time)

**When done, say:** "The discovery synthesis is approved. Generate the project definitions."

---

### Step 2b: Spike Execution — `pbs-spike-execution` (separate sessions)

**When:** Discovery generated spike specs at `.pbs-framework/exploration/spikes/` and paused.

**What you do:**
1. Open a **new session** (don't contaminate the discovery session)
2. Tell the AI which spike to execute (e.g., "Execute spike-01")
3. The AI reads the spike spec and runs the experiment:
   - Code spike: writes minimal throwaway code, runs it, captures output
   - Integration spike: tests real APIs/services, captures responses
   - Research spike: verifies claims with primary sources
4. The AI writes results directly into the spike spec file (`## Results` section)
5. Review the results
6. Repeat for each spike (same or new sessions)

**Output per spike:** Updated spike spec file with results filled in

**Human gate:** Review spike results before returning to discovery.

**Estimated time:** 1-4 hours per spike (time-boxed)

**When all spikes are done, say:** (return to discovery session) "Spikes are done. Read the results and continue the synthesis."

**Important:**
- Each spike runs in its **own session** — don't mix with discovery
- Spike code is **throwaway** — it lives in `.pbs-framework/exploration/spikes/code/`
- If a spike is INCONCLUSIVE, discuss with the AI: re-spike, pivot, or accept the risk

---

### Step 3: Generating Definitions — `pbs-generating-definitions`

**What you do:**
1. The AI reads both approved syntheses
2. Generates 5 documents in `.pbs-framework/`:
   - `00-project-brief.md` — problem, scope, success criteria (1 page)
   - `01-system-overview.md` — entities, capabilities, integrations (LIGHT)
   - `02-technical-design.md` — stack, modules, data flow (LIGHT)
   - `03-decision-log.md` — decisions from discovery (min 3-5 entries)
   - `04-roadmap.md` — ALL phases, only Phase 1 detailed
3. Read all documents (target: < 30 minutes)

**Output:** 5 documents in `.pbs-framework/` + `phases/` directory

**Human gate:** Definition of Ready checklist:
- [ ] Can read all docs in < 30 minutes
- [ ] Phase 1 has concrete tasks
- [ ] No blocking ambiguities
- [ ] Each phase is 1-3 days
- [ ] Explicitly say: "Definitions are ready"

**When done, say:** "Definitions are ready. Let's plan Phase 1."

---

### Step 4: Phase Planning — `pbs-phase-planning`

**What you do:**
1. The AI reads all `.pbs-framework/` documents + previous closure report (if not Phase 1)
2. Generates:
   - `spec.md` — objective, acceptance criteria (Given/When/Then), contracts, testing strategy, exclusions
   - `tasks.md` — ordered tasks with dependencies, context files, validation commands
3. Review both documents

**Output:** `.pbs-framework/phases/phase-XX/spec.md` + `tasks.md`

**Human gate:** Approve BOTH spec and tasks before ANY implementation.

**Checklist before approving:**
- [ ] Every acceptance criterion is in Given/When/Then format
- [ ] Every task has validation commands
- [ ] No task touches 4+ output files
- [ ] Every task has context files listed
- [ ] Dependencies are explicit

**When done, say:** "Plan approved. Start T-01."

---

### Step 5: Task Execution — `pbs-task-execution` (repeat per task)

**What you do (per task):**
1. Tell the AI which task to implement (e.g., "Start T-01")
2. The AI implements using TDD:
   - Reads ONLY files listed in task's context
   - Writes tests FIRST (Red-Green-Refactor)
   - Runs validation commands with real output
   - Presents: implementation report + git diff
3. Review the diff and report

**Output per task:**
- Implemented code + tests
- Task report with validation evidence

**Human gate:** Review diff before committing. Check:
- [ ] Code matches acceptance criteria
- [ ] Tests validate criteria (not just exist)
- [ ] No files outside task scope were touched
- [ ] No autonomous decisions were made

**When done, say:** "Approved. Commit." then "Start T-02." (repeat for each task)

**If a bug is found:** The AI uses `systematic-debugging` automatically.

---

### Step 6: Phase Validation — `pbs-phase-validation`

**What you do:**
1. All tasks complete → tell the AI: "Validate this phase."
2. The AI runs 2-stage validation:
   - **Stage 1: Spec Compliance** — checks every acceptance criterion, runs all commands
   - **Stage 2: Code Quality** — only if Stage 1 passes (SOLID, security, test quality)
3. Review the validation report

**Output:** `.pbs-framework/phases/phase-XX/validation-report.md`

**Human gate:** Review the report. Decide:
- Blockers → fix with `pbs-fixing-issues`
- Tech debt → register in Tech Debt Register
- Skippable → ignore

**If blockers found:**
1. Say: "Fix blocker: [description]"
2. The AI uses `pbs-fixing-issues` (surgical minimum change)
3. Review the fix diff → approve
4. Say: "Re-validate the phase"
5. The AI re-runs `pbs-phase-validation`

**When clean, say:** "Validation passed. Close the phase."

---

### Step 7: Phase Closure — `pbs-phase-closure`

**What you do:**
1. The AI generates closure report reflecting REALITY (git log, not plan)
2. The AI updates global documents:
   - Decision Log (new decisions)
   - Roadmap (mark phase complete, detail next phase)
   - Tech Debt Register (if new debt)
   - Architecture Snapshot (if structure changed)
3. Review the closure report and document updates

**Output:** `.pbs-framework/phases/phase-XX/closure-report.md` + updated global docs

**Human gate:** Validate:
- [ ] Closure report reflects what was actually built
- [ ] Global documents are updated correctly
- [ ] Next phase is detailed in roadmap
- [ ] Surgical question for next phase makes sense

**When done, say:** "Closure approved. Let's plan Phase [N+1]." → Go back to Step 4.

---

### Step 8: Repeat or Done

- If roadmap has more phases → **Go to Step 4** (plan next phase)
- If roadmap is complete → **Project is done**

---

## Workflow B: Feature in Existing Codebase

```
┌─────────────────────────────────────────────────────────────┐
│ STAGE -1: FAMILIARIZATION                                   │
│                                                             │
│ Step 1 → pbs-codebase-familiarization                       │
│                                                             │
│ STAGE 0 (optional): LIGHTWEIGHT BRAINSTORMING               │
│                                                             │
│ Step 2 → pbs-exploration-brainstorming (lightweight mode)   │
│                                                             │
│ STAGE 1-2: PLANNING + CONSTRUCTION                          │
│                                                             │
│ Step 3 → pbs-feature-planning                               │
│ Step 4 → pbs-task-execution (per task)                      │
│ Step 5 → pbs-phase-validation                               │
│ Step 6 → pbs-phase-closure                                  │
│          ↓                                                  │
│ Step 7 → Next phase or DONE                                 │
└─────────────────────────────────────────────────────────────┘
```

### Step 1: Codebase Familiarization — `pbs-codebase-familiarization`

**What you do:**
1. Tell the AI: "I need to add [feature] to this project. Let's start by understanding the codebase."
2. The AI scans in 3 levels:
   - **Level 1: Surface** (15-30 min) — README, structure, stack, configs. NO code reading.
   - **Level 2: Environment** (30-60 min) — run project, run tests, verify everything works.
   - **Level 3: Impact Zone** (1-3 hours) — search by keywords, trace flows, map dependencies, find reference module.
3. Review the context map

**Output:** `.pbs-framework/features/[feature-name]/codebase-context-map.md`

**Human gate:** Validate the context map is accurate.

**When done, say:** "Context map approved."

**Skip levels if:**
- Already know the codebase → skip Level 1-2, go to Level 3
- Nothing changed since last time → quick Level 3 refresh
- Feature is trivial (< 4 hours) → skip the framework entirely

---

### Step 2 (Optional): Lightweight Brainstorming — `pbs-exploration-brainstorming`

**When to use:** Only if the feature needs conceptual exploration (unclear requirements, multiple approaches).

**What you do:**
1. The AI asks through Blocks 1-3 only (Problem, Solution, Scope)
2. Generates a feature brief

**Output:** `.pbs-framework/features/[feature-name]/feature-brief.md`

**Skip if:** Feature requirements are already clear.

---

### Step 3: Feature Planning — `pbs-feature-planning`

**What you do:**
1. The AI reads context map (+ feature brief if exists)
2. Generates:
   - **Impact Map** — direct changes, indirect impact, dependencies, migrations, tests at risk
   - **Mini-Roadmap** — 1-4 short phases (hours to 1 day each)
   - **Phase 1 detail** — spec.md + tasks.md
3. Review impact map and plan

**Output:**
- `.pbs-framework/features/[feature-name]/impact-map.md`
- `.pbs-framework/features/[feature-name]/roadmap.md`
- `.pbs-framework/features/[feature-name]/phases/phase-01/spec.md`
- `.pbs-framework/features/[feature-name]/phases/phase-01/tasks.md`

**Human gate:** Approve impact map + phase plan.

**Key difference from new project:** Every task MUST include:
- Pattern module reference (existing code to follow)
- "Existing tests still pass" as mandatory validation command

---

### Steps 4-7: Same Execution Cycle

Use the same skills as Workflow A:
- **Step 4:** `pbs-task-execution` per task (review diff → commit)
- **Step 5:** `pbs-phase-validation` (2-stage review)
  - Fix blockers with `pbs-fixing-issues` if needed
- **Step 6:** `pbs-phase-closure` (lighter closure report)
- **Step 7:** Next phase or DONE

**Key constraint:** "Existing tests still pass" is mandatory in EVERY validation.

---

## Fix Cycle (used within any workflow)

```
pbs-phase-validation finds blocker
        ↓
Human says: "Fix blocker: [description]"
        ↓
pbs-fixing-issues (surgical minimum change)
        ↓
Human reviews fix diff → approves
        ↓
Human says: "Re-validate the phase"
        ↓
pbs-phase-validation (re-run)
        ↓
PASS → continue to closure
FAIL → repeat fix cycle
```

---

## Spike Cycle (used within any workflow)

Spikes can happen during discovery OR mid-construction when you hit an unknown.

```
Uncertainty detected (discovery or mid-task)
        ↓
pbs-spike-planning (generate spike spec)
        ↓
Human reviews spike spec → approves
        ↓
Open NEW session
        ↓
pbs-spike-execution (run experiment, write results)
        ↓
Human reviews results → return to original session
        ↓
Continue with evidence
```

**From discovery:** spike specs go to `.pbs-framework/exploration/spikes/`
**From construction:** spike specs go to `.pbs-framework/phases/phase-XX/spikes/`

---

## When NOT to Use This Framework

| Scenario | What to do instead |
|----------|-------------------|
| Hotfix (< 1 hour) | Just fix it directly |
| Trivial feature (add field, change label) | Just do it |
| Exploratory spike | Run the spike; if it becomes a feature, start from Stage 0 |
| Project with < 3-4 files total | Overhead not justified |

**Rule of thumb:** < 4 hours = skip framework. > 4 hours = framework saves time.

---

## Quick Reference: What to Say at Each Gate

| Moment | What to say |
|--------|------------|
| After brainstorming | "The brainstorming synthesis is approved. Let's start technical discovery." |
| After discovery (spikes needed) | "Spikes are generated. Let me execute them in separate sessions." |
| After spike execution | (in discovery session) "Spikes are done. Read the results and continue the synthesis." |
| After discovery | "The discovery synthesis is approved. Generate the project definitions." |
| After definitions | "Definitions are ready. Let's plan Phase 1." |
| After plan review | "Plan approved. Start T-01." |
| After each task diff | "Approved. Commit." then "Start T-XX." |
| After all tasks done | "All tasks done. Validate this phase." |
| After validation (clean) | "Validation passed. Close the phase." |
| After validation (blockers) | "Fix blocker: [description]" |
| After fix | "Re-validate the phase." |
| After closure | "Closure approved. Let's plan Phase [N+1]." |
| After context map | "Context map approved." |
| After impact map | "Impact map and plan approved. Start T-01." |

---

## Superpowers Skills (used automatically)

These are discipline skills that pbs-skills invoke automatically — you don't need to trigger them:

| Skill | Used by | Purpose |
|-------|---------|---------|
| `test-driven-development` | pbs-task-execution, pbs-fixing-issues | TDD enforcement (test first, always) |
| `verification-before-completion` | pbs-task-execution, pbs-phase-validation, pbs-codebase-familiarization, pbs-generating-definitions, pbs-phase-closure | Evidence before claims |
| `systematic-debugging` | pbs-task-execution (when bugs found) | 4-phase debugging process |
| `requesting-code-review` | Optional (requires full Superpowers) | Structured review dispatch for critical tasks |
