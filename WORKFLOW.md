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
│ Step 6 → pbs-pr-hardening (code review + PR description)    │
│          ├─ pbs-review-fixes (if findings need resolution)  │
│ Step 7 → pbs-phase-closure (knowledge sync)                 │
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

**Output:** `.pbs-framework/phases/phase-XX/spec.md` + `tasks.md` + `tracker-summary.md`

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
- [ ] Decision delta: autonomous decisions understood and accepted

**When done, say:** "Approved. Commit." then "Start T-02." (repeat for each task)

**If a bug is found:** The AI uses `systematic-debugging` automatically.

---

### Step 6: PR Hardening — `pbs-pr-hardening` + `pbs-review-fixes`

**What you do:**
1. All tasks complete → tell the AI: "Harden this phase for PR."
2. The AI runs adversarial code review:
   - **Quick-check:** spec compliance (acceptance criteria, validation commands)
   - **Deep review:** architecture, code quality, testing, security, decision delta review
3. Generates two files:
   - `review-report.md` — findings with per-item states (pending/resolved/rejected/deferred)
   - `pr-description.md` — navigation guide for PR reviewers
4. Review the findings

**Output:** `.pbs-framework/phases/phase-XX/review-report.md` + `pr-description.md`

**Human gate:** Review findings. Decide:
- Critical/Important → resolve with `pbs-review-fixes`
- Minor → resolve, reject, or defer
- Clean → proceed to closure

**If findings need resolution:**
1. Say: "Resolve the review findings."
2. The AI uses `pbs-review-fixes` — iterates finding by finding:
   - **Fix:** implements minimum change, marks resolved
   - **Reject:** presents reasoning, you confirm
   - **Defer:** registers as tech debt
3. You arbitrate each finding — approve, override, or pause
4. After all findings resolved → review-report status changes to `resolved`

**When clean, say:** "Review resolved. Close the phase."

---

### Step 7: Phase Closure (Knowledge Sync) — `pbs-phase-closure`

**What you do:**
1. The AI generates closure report reflecting REALITY (git log, not plan)
2. The AI updates global documents:
   - Decision Log (new decisions)
   - Roadmap (mark phase complete, detail next phase)
   - Tech Debt Register (if new debt)
   - Architecture Snapshot (if structure changed)
3. Review the closure report and document updates

**Note:** Code quality was already validated by pbs-pr-hardening. Closure focuses on knowledge sync only.

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
│ Step 5 → pbs-pr-hardening + pbs-review-fixes                │
│ Step 6 → pbs-phase-closure (knowledge sync)                 │
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
- **Step 5:** `pbs-pr-hardening` (adversarial review + PR description)
  - Resolve findings with `pbs-review-fixes` if needed
- **Step 6:** `pbs-phase-closure` (knowledge sync)
- **Step 7:** Next phase or DONE

**Key constraint:** "Existing tests still pass" is mandatory in EVERY review.

---

## Workflow C: PR Review (review a teammate's PR)

Workflow A and B help an AUTHOR build and harden a PR. Workflow C helps a REVIEWER understand and review a PR somebody else opened, without spending 1-2 days reading code blindly. Same principle: AI assists, the human decides.

```
┌─────────────────────────────────────────────────────────────┐
│ STAGE R: REVIEWER ENABLEMENT                                │
│                                                             │
│ Step 1 → pbs-pr-review-context                              │
│          ├─ branch + base (gh optional for PR metadata)     │
│          ├─ git diff <base>...<branch> local                │
│          ├─ Map files, detect stack, reconstruct intent     │
│          ├─ Triage: chico / mediano / grande / sensible     │
│          └─ Output: review-context.md + review plan         │
│                                                             │
│ Branch by triage and review plan:                           │
│                                                             │
│ MVP path (chico, low-stakes):                               │
│ Step 2 → pbs-pr-review-reports                              │
│          → reviewer-dossier.md (minimal: synthesis +        │
│            manual review guide)                             │
│          → SHARE manually with the team / use as your map   │
│                                                             │
│ Full path (mediano / grande / sensible):                    │
│ Step 2a → pbs-pr-review-consistency                         │
│           (precedent search, textual citation required)     │
│ Step 2b → pbs-pr-review-general                             │
│           (quality, tests vs intent, recommend best-prac)   │
│ Step 2c → pbs-pr-review-security                            │
│           (threat model the deltas only)                    │
│           ↓                                                 │
│           findings.md (appended by each pass, no overwrite) │
│           ↓                                                 │
│ Step 3 → pbs-pr-review-reports                              │
│          ├─ reviewer-dossier.md (for the reviewer)          │
│          └─ developer-report.md (for the PR author,         │
│             human + LLM-actionable sections)                │
│                                                             │
│ Step 4 → SHARE the developer-report.md (or pieces of it)    │
│          with the PR author manually. No bot comments.      │
└─────────────────────────────────────────────────────────────┘
```

### Step 1: Build Review Context — `pbs-pr-review-context`

**What you do:**
1. Make sure the branch is fetched locally (`git fetch` if needed)
2. Tell the AI: "Build review context for branch `<branch>` against `<base>`."
3. The AI runs `git diff <base>...<branch>`, maps files, detects stack, reconstructs intent, applies triage, and produces a review plan
4. Optionally provide a PR URL / number if `gh` is installed — improves intent reconstruction

**Output:** `.pbs-framework/reviews/<branch-slug>/review-context.md`

**Human gate:** Validate the file classification, the reconstructed intent, and especially the triage classification.

**Triage rules (decided by the skill):**
- **chico** = ≤5 files without sensitive logic
- **mediano** = 6-20 files without sensitive logic
- **grande** = >20 files without sensitive logic
- **sensible** = touches auth, pagos, datos sensibles, migraciones, permisos, jobs, queues, integraciones externas, contratos, wallets, tokens, balances. Sensible always wins over file count.

**When done, say:** "Context approved. [Run reports for the MVP path / Run consistency / general / security per the plan]."

---

### Step 2 (MVP path): Generate Minimal Dossier — `pbs-pr-review-reports`

**Use when:** triage is `chico` or the review plan marks all specialized passes as `skip`/`shallow`.

**What you do:**
1. Tell the AI: "Generate the reviewer dossier from the context."
2. The AI produces only the Reviewer Dossier (no Developer Report — there are no findings to send the author yet)

**Output:** `.pbs-framework/reviews/<branch-slug>/reviewer-dossier.md`

**Human gate:** Read the dossier. Decide if you want to escalate to specialized passes or stop here.

---

### Step 2a: Consistency Pass — `pbs-pr-review-consistency`

**What you do:**
1. Tell the AI: "Run pbs-pr-review-consistency on this review."
2. The AI searches the codebase for precedents (types, fields, utilities, functions, schemas) that the PR may be duplicating or diverging from
3. **Findings require textual citation** of the precedent (file:line + snippet). Without citation → review-question, not finding
4. Appends findings to `findings.md` (never overwrites)

**Output:** Findings appended to `.pbs-framework/reviews/<branch-slug>/findings.md`

**Human gate:** Review the appended findings and review-questions. Demote, edit, or remove as needed.

**When done, say:** "Consistency done. [Run general / security / generate reports]."

---

### Step 2b: General Quality Pass — `pbs-pr-review-general`

**What you do:**
1. Tell the AI: "Run pbs-pr-review-general."
2. The AI inspects core files for: over/under-engineering, dead code, DRY violations, weak tests, missing edge cases
3. Compares tests against the reconstructed intent
4. Detects stack and recommends manual invocation of best-practices skills (typescript-best-practices, nodejs-best-practices, etc.) — **does NOT invoke them**

**Output:** Findings + a "Recomendado correr manualmente" section appended to `findings.md`

**Human gate:** Review the findings AND the recommended best-practices list. Decide which best-practices skills to run manually.

**When done, say:** "General done. [Run security / generate reports]."

---

### Step 2c: Security Pass — `pbs-pr-review-security`

**Use when:** triage is `sensible`, OR the PR introduces endpoints / auth / external calls / persisted data / jobs / crypto / secrets.

**What you do:**
1. Tell the AI: "Run pbs-pr-review-security."
2. The AI builds a lightweight threat model on the PR DELTAS only — not historic debt
3. Checklist: input validation, authn/authz, error leakage, data exposure, secrets/tokens, idempotency, external calls
4. Findings with textual citation; suspicions → review-questions

**Output:** Findings appended to `findings.md`

**Human gate:** Review the security findings carefully. Sensible PRs deserve manual confirmation.

**When done, say:** "Security done. Generate the reports."

---

### Step 3: Generate Reports — `pbs-pr-review-reports`

**What you do:**
1. Tell the AI: "Generate the reports."
2. The AI consumes `review-context.md` + `findings.md` and produces:
   - **Reviewer Dossier** — synthesis, manual review guide, P0/P1 findings elevated, review-questions, verdict, P2/info in appendix
   - **Developer Report** — human section (findings explained) + LLM-actionable section (copy-paste prompts per finding)

**Output:**
- `.pbs-framework/reviews/<branch-slug>/reviewer-dossier.md`
- `.pbs-framework/reviews/<branch-slug>/developer-report.md`

**Human gate:** READ the Reviewer Dossier in full BEFORE sharing the Developer Report or commenting on the PR. The Dossier is yours. The Developer Report is what the author sees.

---

### Step 4: Share with the Author

**No bots, no inline comments.** Open the PR in your provider (GitHub / GitLab / Bitbucket), comment with the verdict + acciones sugeridas, and share the `developer-report.md` with the author (pasted, attached, or linked).

The author runs their own agent with the LLM-actionable prompts to iterate fixes — or fixes manually. The next iteration of the PR can be re-reviewed by re-running pbs-pr-review-context (it re-bases on the new diff).

### Key Rules of Workflow C

- **No bot comments on the PR.** Output is local markdown files. Sharing is manual.
- **No auto-fix.** The skills never modify the reviewed repo.
- **Sin evidencia no hay finding.** Every finding requires a textual citation. Suspicions become review-questions.
- **The review plan is the contract.** Specialized passes respect `full` / `shallow` / `skip` from `review-context.md`.
- **Symmetry with pbs-pr-hardening.** Hardening is for the author of their own PR. Review is for someone else's PR. Both AI-assisted, both human-decided.

---

## Review Fix Cycle (used after PR Hardening)

```
pbs-pr-hardening generates review-report.md with findings
        ↓
Human says: "Resolve the review findings."
        ↓
pbs-review-fixes (iterate finding by finding)
  - Fix: implement minimum change → mark resolved
  - Reject: present reasoning → human confirms → mark rejected
  - Defer: register as tech debt → mark deferred
        ↓
Human arbitrates each finding
        ↓
All findings resolved → review-report status: resolved
        ↓
Continue to closure
```

## Surgical Fix Cycle (for ad-hoc blockers)

```
Blocker found (during review or ad-hoc)
        ↓
Human says: "Fix blocker: [description]"
        ↓
pbs-fixing-issues (surgical minimum change)
        ↓
Human reviews fix diff → approves
        ↓
Continue
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

## Add Scope Cycle (used within any workflow)

When new scope arrives mid-project — business logic changes, large new features, or pivots that require additional phases.

```
New scope identified (client request, pivot, new requirements)
        ↓
pbs-add-scope
  1. Generate Scope Record (what, why, impact, affected decisions)
        ↓
  Human reviews Scope Record → approves
        ↓
  2. Inline brainstorming (Blocks 1-3)
  3. Inline discovery (optional — human decides)
        ↓
  4. Update living documents additively
  5. Add new phases to roadmap
        ↓
  Human reviews all updates → approves
        ↓
pbs-phase-planning (for the new phases)
```

**Key rules:**
- Original exploration docs (`exploration/`) are NEVER modified
- Completed phases are FROZEN — never touched
- Living documents get ADDITIVE updates (SC-XX sections)
- Scope artifacts go to `.pbs-framework/scopes/SC-XX-nombre/`

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
| After all tasks done | "All tasks done. Harden this phase for PR." |
| After review (clean) | "Review resolved. Close the phase." |
| After review (findings) | "Resolve the review findings." |
| After review fixes | "Review resolved. Close the phase." |
| After closure | "Closure approved. Let's plan Phase [N+1]." |
| After context map | "Context map approved." |
| After impact map | "Impact map and plan approved. Start T-01." |
| New scope arrives | "We need to add [X] to the project. Let's document the scope change." |
| After scope record approved | "Scope record approved. Continue with brainstorming." |
| After add-scope complete | "Scope change approved. Let's plan Phase [N+1]." |
| Starting a PR review | "Build review context for branch `<branch>` against `<base>`." |
| After context approved (MVP) | "Context approved. Generate the minimal dossier with pbs-pr-review-reports." |
| After context approved (full) | "Context approved. Run pbs-pr-review-consistency / general / security per the review plan." |
| After each review pass | "Pass done. Run the next one." (consistency / general / security) |
| After all passes done | "All passes done. Generate the reports." |
| After dossier reviewed | "Dossier reviewed. Sharing the developer report with the author." |

---

## Superpowers Skills (used automatically)

These are discipline skills that pbs-skills invoke automatically — you don't need to trigger them:

| Skill | Used by | Purpose |
|-------|---------|---------|
| `test-driven-development` | pbs-task-execution, pbs-fixing-issues | TDD enforcement (test first, always) |
| `verification-before-completion` | pbs-task-execution, pbs-pr-hardening, pbs-review-fixes, pbs-codebase-familiarization, pbs-generating-definitions, pbs-phase-closure | Evidence before claims |
| `systematic-debugging` | pbs-task-execution (when bugs found) | 4-phase debugging process |
| `receiving-code-review` | pbs-review-fixes | Technical rigor in responding to review feedback |
