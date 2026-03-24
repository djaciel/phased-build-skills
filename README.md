# Phased Build Skills

A set of skills that implement the **Phased Build Framework** — a structured approach to building software with AI where the human engineer stays in the loop at every step. Works with any AI coding agent that supports skills.

**Who it's for:** Solo developers and small teams building complex systems (blockchain, finance, critical infrastructure) with AI assistance, who need to understand every line of generated code.

**Key principle:** The AI generates, the human comprehends and validates. Speed is sacrificed for understanding when the domain demands it.

---

## Installation

### Option A: Using `npx skills` (recommended)

```bash
# Install PBS skills globally
npx skills add https://github.com/djaciel/phased-build-skills -y -g
```

PBS depends on 3 discipline skills from [Superpowers](https://github.com/obra/superpowers). You have two options:

```bash
# Option 1: Install full Superpowers (14+ skills — recommended)
npx skills add https://github.com/obra/superpowers -y -g

# Option 2: Install only the 3 skills PBS needs (bundled in vendor/)
npx skills add ./vendor/superpowers -y -g
```

If you already have Superpowers installed, skip this step.

### Option B: Manual copy/symlink

```bash
# Copy skills
cp -r phased-build-skills/skills/* your-project/.claude/skills/

# If you don't have Superpowers, also copy the vendor skills
cp -r phased-build-skills/vendor/superpowers/skills/* your-project/.claude/skills/
```

### What You Get

**Discipline skills (from [Superpowers](https://github.com/obra/superpowers), bundled in `vendor/`):**
| Skill | Purpose | Required |
|-------|---------|----------|
| test-driven-development | TDD Iron Law enforcement | Yes |
| verification-before-completion | Evidence before claims | Yes |
| systematic-debugging | 4-phase debugging process | Yes |

**PBS skills (this package):**
| Skill | Purpose |
|-------|---------|
| pbs-exploration-brainstorming | Structured brainstorming for new projects |
| pbs-exploration-discovery | Technical investigation and feasibility |
| pbs-generating-definitions | Generate all project definition documents |
| pbs-phase-planning | Plan a construction phase (spec + tasks) |
| pbs-task-execution | Implement one task with human gate |
| pbs-phase-validation | 2-stage review against phase spec |
| pbs-phase-closure | Close phase, update docs, handoff context |
| pbs-fixing-issues | Surgical fix for blockers |
| pbs-spike-planning | Generate structured spike specs for technical experiments |
| pbs-spike-execution | Execute feasibility spikes in dedicated sessions |
| pbs-codebase-familiarization | Progressive scan of existing codebase |
| pbs-feature-planning | Lighter planning for features in existing codebases |
| pbs-add-scope | Add new scope to a project in construction |

---

## Quick Start: New Project from Scratch

Example: building a crypto portfolio tracker.

### Step 1: Brainstorm the idea

```
You: I want to build a crypto portfolio tracker that pulls real-time prices
     and shows P&L per position. Let's brainstorm this.

→ AI activates pbs-exploration-brainstorming
→ Guides you through: Problem, Solution, Scope, Users, Risks
→ Generates: .pbs-framework/exploration/brainstorming-synthesis.md
→ YOU review and approve the synthesis
```

### Step 2: Technical discovery

```
You: The brainstorming synthesis is approved. Let's investigate the
     technical options.

→ AI activates pbs-exploration-discovery
→ Evaluates: CoinGecko vs CoinMarketCap API, DB options, stack
→ Generates spike specs if needed (does this API actually return what we need?)
→ PAUSES: you run spikes in separate sessions with pbs-spike-execution
→ Resume discovery: reads spike results, closes synthesis
→ Generates: .pbs-framework/exploration/discovery-synthesis.md
→ YOU review and approve the synthesis
```

### Step 3: Generate definitions

```
You: Both syntheses are approved. Generate the project definitions.

→ AI activates pbs-generating-definitions
→ Generates all .pbs-framework/ documents:
    00-project-brief.md
    01-system-overview.md
    02-technical-design.md
    03-decision-log.md
    04-roadmap.md
→ YOU read everything (< 30 min) and approve
```

### Step 4: Plan phase 1

```
You: Definitions look good. Let's plan phase 1.

→ AI activates pbs-phase-planning
→ Generates: .pbs-framework/phases/phase-01/spec.md
→ Generates: .pbs-framework/phases/phase-01/tasks.md
→ YOU review spec + tasks and approve
```

### Step 5: Implement tasks (one at a time)

```
You: Plan approved. Start T-01.

→ AI activates pbs-task-execution
→ Implements code + tests (TDD enforced)
→ Presents: diff + implementation report
→ YOU review the diff → approve → commit

You: Good. Start T-02.
→ Repeat for each task...
```

### Step 6: Validate the phase

```
You: All tasks done. Validate this phase.

→ AI activates pbs-phase-validation
→ Stage 1: Checks every acceptance criterion against spec
→ Stage 2: Code quality review
→ Presents: validation report with findings
→ YOU review → fix blockers with /pbs-fixing-issues if needed
```

### Step 7: Close the phase

```
You: Validation passed. Close the phase.

→ AI activates pbs-phase-closure
→ Generates: closure-report.md
→ Updates: Decision Log, Roadmap, Architecture Snapshot
→ Details next phase in roadmap
→ YOU validate the closure report
```

### Step 8: Repeat steps 4-7 for each phase

Until the roadmap is complete.

---

## Quick Start: Feature in Existing Codebase

Example: adding a notifications system to an existing Node.js app.

### Step 1: Familiarize with the codebase

```
You: I need to add notifications to this project.
     Let's start by understanding the codebase.

→ AI activates pbs-codebase-familiarization
→ Level 1: Surface scan (README, structure, stack)
→ Level 2: Environment (runs project, tests pass)
→ Level 3: Impact zone (files relevant to notifications)
→ Generates: codebase-context-map.md
→ YOU validate the context map
```

### Step 2: Plan the feature

```
You: Context map approved. Let's plan the notifications feature.

→ AI activates pbs-feature-planning
→ Generates: impact-map.md (what changes, what breaks)
→ Generates: mini-roadmap (1-4 short phases)
→ Generates: phase 1 spec + tasks
→ YOU review impact map + plan and approve
```

### Steps 3-6: Same execution cycle

Use `pbs-task-execution` → `pbs-phase-validation` → `pbs-phase-closure` — same as new projects, but lighter (shorter phases, lighter closure reports, always verifying existing tests don't break).

---

## Detailed Workflow Guide

For a step-by-step guide covering every stage, human gate, and expected output, see [WORKFLOW.md](WORKFLOW.md).

---

## Skill Reference

| Skill | Stage | Purpose | Human Gate |
|-------|-------|---------|------------|
| **pbs-exploration-brainstorming** | Stage 0 | Structured brainstorming sessions | Approve synthesis |
| **pbs-exploration-discovery** | Stage 0 | Technical investigation + feasibility | Approve synthesis |
| **pbs-generating-definitions** | Stage 1 | Generate all .pbs-framework/ documents | Approve all docs (Definition of Ready) |
| **pbs-phase-planning** | Stage 2 | Plan a phase: spec.md + tasks.md | Approve spec + tasks |
| **pbs-task-execution** | Stage 2 | Implement one task | Review diff before commit |
| **pbs-phase-validation** | Stage 2 | 2-stage review against spec | Review validation report |
| **pbs-phase-closure** | Stage 2 | Close phase, update docs | Validate closure report |
| **pbs-spike-planning** | Stage 0 / Stage 2 | Generate structured spike specs | Review spike spec |
| **pbs-spike-execution** | Stage 0 / Stage 2 | Execute spikes in dedicated sessions | Review spike results |
| **pbs-fixing-issues** | Stage 2 | Surgical fix for blockers | Review fix diff |
| **pbs-codebase-familiarization** | Stage -1 | Progressive scan of existing codebase | Validate context map |
| **pbs-feature-planning** | Stage 1 (light) | Plan feature with Impact Map | Approve impact map + plan |
| **pbs-add-scope** | Stage 2 | Add new scope to project in construction | Approve scope record + doc updates |
| superpowers:test-driven-development | Discipline | TDD enforcement | — |
| superpowers:systematic-debugging | Discipline | 4-phase debugging | — |
| superpowers:verification-before-completion | Discipline | Evidence before claims | — |

---

## Flow Diagrams

### New Project (Stage 0 → 1 → 2)

```
STAGE 0: EXPLORATION
┌──────────────────────────────────────────────────┐
│  /pbs-exploration-brainstorming                   │
│  ├─ Guided sessions by topic blocks              │
│  └─ Output: brainstorming-synthesis.md           │
│      ↓ [HUMAN GATE: approve synthesis]           │
│  /pbs-exploration-discovery                       │
│  ├─ Evaluate APIs, stack, architecture           │
│  ├─ /pbs-spike-planning for uncertain areas      │
│  └─ PAUSE if spikes needed                       │
│      ↓                                           │
│  /pbs-spike-execution (separate sessions)         │
│  ├─ Execute each spike, write results            │
│  └─ Return to discovery                          │
│      ↓                                           │
│  Resume discovery → close synthesis              │
│      ↓ [HUMAN GATE: approve synthesis]           │
└──────────────────┬───────────────────────────────┘
                   ▼
STAGE 1: DEFINITION
┌──────────────────────────────────────────────────┐
│  /pbs-generating-definitions                      │
│  ├─ Generates all .pbs-framework/ documents          │
│  └─ Definition of Ready checklist                │
│      ↓ [HUMAN GATE: read + approve all docs]     │
└──────────────────┬───────────────────────────────┘
                   ▼
STAGE 2: CONSTRUCTION (repeat per phase)
┌──────────────────────────────────────────────────┐
│  /pbs-phase-planning                              │
│  ├─ Generates spec.md + tasks.md                 │
│  └─ [HUMAN GATE: approve plan]                   │
│      ↓                                           │
│  /pbs-task-execution (per task)                   │
│  ├─ Implements code + tests (TDD)                │
│  └─ [HUMAN GATE: review diff → commit]           │
│      ↓                                           │
│  /pbs-phase-validation                            │
│  ├─ 2-stage: spec compliance + code quality      │
│  └─ [HUMAN GATE: review report]                  │
│      ↓                                           │
│  /pbs-phase-closure                               │
│  ├─ Closure report + doc updates                 │
│  └─ [HUMAN GATE: validate closure]               │
│      ↓                                           │
│  Roadmap complete? → Yes: DONE / No: next phase  │
└──────────────────────────────────────────────────┘
```

### Existing Codebase (Stage -1 → 0 → 1 → 2)

```
STAGE -1: FAMILIARIZATION
┌──────────────────────────────────────────────────┐
│  /pbs-codebase-familiarization                    │
│  ├─ Level 1: Surface (README, structure, stack)  │
│  ├─ Level 2: Environment (run project + tests)   │
│  ├─ Level 3: Impact zone (relevant files)        │
│  └─ Output: codebase-context-map.md              │
│      ↓ [HUMAN GATE: validate context map]        │
└──────────────────┬───────────────────────────────┘
                   ▼
STAGE 0 (optional): LIGHTWEIGHT EXPLORATION
┌──────────────────────────────────────────────────┐
│  /pbs-exploration-brainstorming (lightweight mode) │
│  └─ Output: feature-brief.md                     │
│      ↓ [HUMAN GATE: approve brief]               │
└──────────────────┬───────────────────────────────┘
                   ▼
STAGE 1-2: PLANNING + CONSTRUCTION
┌──────────────────────────────────────────────────┐
│  /pbs-feature-planning                            │
│  ├─ Generates impact-map.md                      │
│  ├─ Generates mini-roadmap (1-4 phases)          │
│  ├─ Details phase 1 spec + tasks                 │
│  └─ [HUMAN GATE: approve impact map + plan]      │
│      ↓                                           │
│  Same cycle: /pbs-task-execution →               │
│  /pbs-phase-validation → /pbs-phase-closure      │
│      ↓                                           │
│  Scope change mid-project?                       │
│  └─ /pbs-add-scope → update docs → new phases   │
│     → back to /pbs-phase-planning                │
└──────────────────────────────────────────────────┘
```

### Phase Execution Cycle

```
┌─────────────┐
│   PLAN      │  /pbs-phase-planning or /pbs-feature-planning
│             │  → spec.md + tasks.md
│             │  → [HUMAN APPROVES]
└──────┬──────┘
       ▼
┌─────────────┐     ┌─────────────────┐
│  IMPLEMENT  │────→│ /pbs-fixing-issues│ (if blocker found)
│             │←────│                 │
│  Per task:  │     └─────────────────┘
│ /pbs-task-  │     ┌─────────────────┐
│  → diff     │────→│  /systematic-   │ (if bug found)
│  → review   │←────│   debugging     │
│  → commit   │     └─────────────────┘
└──────┬──────┘
       ▼
┌─────────────┐
│  VALIDATE   │  /pbs-phase-validation
│             │  Stage 1: spec compliance
│             │  Stage 2: code quality
│             │  → [HUMAN REVIEWS REPORT]
└──────┬──────┘
       ▼
┌─────────────┐
│  CLOSE      │  /pbs-phase-closure
│             │  → closure-report.md
│             │  → update Decision Log, Roadmap
│             │  → detail next phase
│             │  → [HUMAN VALIDATES]
└──────┬──────┘
       ▼
  Next phase or DONE
```

---

## Human Gates Summary

| Point in Flow | What You Review | Estimated Time |
|---------------|----------------|----------------|
| Brainstorming synthesis | Does it capture the idea correctly? | 15-20 min |
| Discovery synthesis | Are technical decisions sound? | 15-20 min |
| Definition of Ready | Can you read all docs in < 30 min? No blocking ambiguities? | 20-30 min |
| Phase plan (spec + tasks) | Acceptance criteria complete? Tasks well-granulated? | 15-20 min |
| Each task diff + report | Does the code make sense? Tests correct? No autonomous decisions? | 10-15 min |
| Code review (optional, critical tasks) | Security checks pass? | 15-20 min |
| Phase validation report | Spec compliance OK? Code quality OK? | 10-15 min |
| Phase closure report | Reflects reality? Docs updated correctly? | 10-15 min |

**Total human review time per phase:** ~1.5-2 hours
**Total AI execution time per phase:** ~4-8 hours

**Ratio human:AI ≈ 1:4** — you invest 20-25% of total time reviewing and deciding, not writing.

---

## AGENTS.md Setup

Every project using this framework should have an `AGENTS.md` file at the root. Use the template at `templates/AGENTS.md.template`.

### What to include
- **Project:** name and one-line description
- **Stack:** language, framework, DB, testing
- **Conventions:** naming, error handling, module patterns, imports
- **Critical restrictions:** security rules, invariants that must never break
- **Risk domain:** (only if applicable) blockchain, finance, health-specific constraints
- **Project structure:** main directories and their purpose
- **Framework rules:** scope discipline, Decision Log compliance, TDD

### What NOT to include
- Implementation details (that's in the code)
- Long explanations (every line must pass: "if I remove this, will the agent make mistakes?")
- Temporary state (that's in the phase spec)

### When to update
- When the agent makes repeated mistakes that a convention would prevent
- When the stack changes
- When new critical restrictions are discovered

---

## When NOT to Use This Framework

- **Hotfixes** (< 1 hour) — just fix it
- **Trivial features** (add a field, change a label) — just do it
- **Exploratory spikes** — if the spike becomes a feature, start from Stage 0
- **Projects with < 3-4 files total** — overhead not justified

**Rule of thumb:** if it takes < 4 hours, skip the framework. If > 4 hours, the framework saves time and prevents mistakes.

---

## Superpowers Integration

### How they work together
- **PBS skills** handle process: exploration, planning, execution gates, validation, closure
- **Superpowers skills** handle discipline: TDD, debugging, verification, code review
- Both are loaded simultaneously — no conflicts

### Dependency management

The 3 required Superpowers skills are **bundled in `vendor/superpowers/`** so PBS works out of the box. If you also install full Superpowers, the installed versions take precedence (same skill names, same content).

### How skills reference each other
PBS skills reference Superpowers skills with the `superpowers:skill-name` format:
```markdown
**REQUIRED:** Use superpowers:test-driven-development
```

This tells the AI agent to follow that skill's rules. The skill must be installed (either from `vendor/` or from full Superpowers) for the agent to load the detailed rules.

### Required (bundled in vendor/)
- `test-driven-development` — enforced by pbs-task-execution, pbs-fixing-issues
- `verification-before-completion` — enforced by pbs-task-execution, pbs-phase-validation, pbs-generating-definitions, pbs-codebase-familiarization, pbs-phase-closure
- `systematic-debugging` — used when bugs are found during implementation or spikes

---

## Templates

Templates are **structural blueprints** that define the exact format and sections each skill must produce. They live in `templates/` and serve two purposes:

1. **For the skills:** Each skill's SKILL.md references its template(s) so the AI agent knows the exact structure to generate. The skill reads the template and fills it with real content based on the project context.
2. **For you:** Templates show you what to expect from each skill's output, so you know what to review at each human gate.

Each template file has a comment at the top explaining which skill generates it and where the output goes. Templates are NOT copied verbatim — they're guides that ensure consistent document structure across projects.

| Template | Generated by | Output location |
|----------|-------------|-----------------|
| AGENTS.md.template | generating-definitions | `AGENTS.md` |
| project-brief.md.template | generating-definitions | `.pbs-framework/00-project-brief.md` |
| system-overview.md.template | generating-definitions | `.pbs-framework/01-system-overview.md` |
| technical-design.md.template | generating-definitions | `.pbs-framework/02-technical-design.md` |
| decision-log.md.template | generating-definitions | `.pbs-framework/03-decision-log.md` |
| roadmap.md.template | generating-definitions | `.pbs-framework/04-roadmap.md` |
| phase-spec.md.template | phase-planning / feature-planning | `.pbs-framework/phases/phase-XX/spec.md` |
| phase-tasks.md.template | phase-planning / feature-planning | `.pbs-framework/phases/phase-XX/tasks.md` |
| closure-report.md.template | phase-closure | `.pbs-framework/phases/phase-XX/closure-report.md` |
| brainstorming-synthesis.md.template | exploration-brainstorming | `.pbs-framework/exploration/brainstorming-synthesis.md` |
| discovery-synthesis.md.template | exploration-discovery | `.pbs-framework/exploration/discovery-synthesis.md` |
| codebase-context-map.md.template | codebase-familiarization | `.pbs-framework/features/[name]/codebase-context-map.md` |
| feature-brief.md.template | exploration-brainstorming (lightweight) | `.pbs-framework/features/[name]/feature-brief.md` |
| impact-map.md.template | feature-planning | `.pbs-framework/features/[name]/impact-map.md` |
| spike-spec.md.template | exploration-discovery | `.pbs-framework/exploration/spikes/spike-XX-[name].md` |
| scope-record.md.template | add-scope | `.pbs-framework/scopes/SC-XX-[name]/scope-record.md` |

---

## Project Structure

```
phased-build-skills/
├── README.md                          # This file
├── skills/                            # PBS skills
│   ├── pbs-exploration-brainstorming/
│   │   ├── SKILL.md
│   │   └── questionnaire-reference.md
│   ├── pbs-exploration-discovery/
│   │   └── SKILL.md
│   ├── pbs-generating-definitions/
│   │   └── SKILL.md
│   ├── pbs-phase-planning/
│   │   └── SKILL.md
│   ├── pbs-task-execution/
│   │   └── SKILL.md
│   ├── pbs-phase-validation/
│   │   └── SKILL.md
│   ├── pbs-phase-closure/
│   │   └── SKILL.md
│   ├── pbs-fixing-issues/
│   │   └── SKILL.md
│   ├── pbs-spike-planning/
│   │   └── SKILL.md
│   ├── pbs-spike-execution/
│   │   └── SKILL.md
│   ├── pbs-codebase-familiarization/
│   │   └── SKILL.md
│   ├── pbs-feature-planning/
│   │   └── SKILL.md
│   └── pbs-add-scope/
│       └── SKILL.md
├── vendor/
│   └── superpowers/                    # Bundled Superpowers skills (fallback)
│       ├── README.md
│       └── skills/
│           ├── test-driven-development/
│           ├── verification-before-completion/
│           └── systematic-debugging/
├── templates/                          # Document templates
│   ├── AGENTS.md.template
│   ├── project-brief.md.template
│   ├── system-overview.md.template
│   ├── technical-design.md.template
│   ├── decision-log.md.template
│   ├── roadmap.md.template
│   ├── phase-spec.md.template
│   ├── phase-tasks.md.template
│   ├── closure-report.md.template
│   ├── brainstorming-synthesis.md.template
│   ├── discovery-synthesis.md.template
│   ├── codebase-context-map.md.template
│   ├── feature-brief.md.template
│   ├── impact-map.md.template
│   └── spike-spec.md.template
└── tests/
    ├── skill-triggering/
    │   ├── run-test.sh                 # Test one skill with a natural prompt
    │   ├── run-all.sh                  # Run all triggering tests
    │   └── prompts/                    # Natural prompts that should trigger each skill
    └── explicit-skill-requests/
        ├── run-test.sh                 # Test one skill with an explicit request
        ├── run-all.sh                  # Run all explicit request tests
        └── prompts/                    # Explicit /skill-name requests
```

---

## Tests

Tests verify that the AI agent correctly **triggers the right skill** when given a prompt. There are two test suites:

### Skill Triggering Tests (`tests/skill-triggering/`)

Test whether the agent activates the correct skill from a **natural language prompt** — without mentioning the skill name. For example, a prompt like *"I just reviewed the closure report from phase 1 and everything looks good. Now I need to start the next construction phase"* should trigger `pbs-phase-planning`.

Each prompt file in `prompts/` is named after the skill it should trigger (e.g., `phase-planning.txt` → expects `pbs-phase-planning`).

```bash
# Test a single skill
./tests/skill-triggering/run-test.sh phase-planning

# Test all skills
./tests/skill-triggering/run-all.sh

# Override model
MODEL=opus ./tests/skill-triggering/run-test.sh phase-planning
```

### Explicit Skill Request Tests (`tests/explicit-skill-requests/`)

Test whether the agent invokes the skill when the user **explicitly names it** (e.g., *"Use phase-planning to generate the spec"*). Also checks for **premature action** — the agent should load the skill BEFORE doing any work, not start implementing and then load the skill.

Prompt filenames here use natural action names (e.g., `plan-next-phase.txt`, `start-brainstorming.txt`) mapped to skill names internally.

```bash
# Test a single skill
./tests/explicit-skill-requests/run-test.sh phase-planning

# Test all skills
./tests/explicit-skill-requests/run-all.sh
```

### How tests work under the hood

1. Creates a temporary project directory in `/tmp/phased-build-tests/` with a minimal `.pbs-framework/` structure
2. Symlinks all skills into `.claude/skills/` so the agent discovers them
3. Initializes a git repo (required by the agent)
4. Runs `claude -p` with the prompt in non-interactive mode (`--dangerously-skip-permissions`, `--max-turns`, `--output-format stream-json`)
5. Parses the JSON output to detect `Skill` tool invocations
6. Reports PASS if the expected skill was triggered, FAIL otherwise
7. For explicit requests: also warns if the agent used other tools before loading the skill (premature action)

### Adding tests for new skills

1. Create a natural language prompt in `tests/skill-triggering/prompts/<skill-name>.txt`
2. Create an explicit request prompt in `tests/explicit-skill-requests/prompts/<action-name>.txt`
3. Add the mapping in `tests/explicit-skill-requests/run-all.sh` (`SKILL_MAP`)

---

## Contributing

Contributions welcome — open an issue first describing what you'd like to change. Follow existing SKILL.md files as reference and include test prompts for new or modified skills.
