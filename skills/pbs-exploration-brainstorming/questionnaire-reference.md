# Exploration Brainstorming — Questionnaire Reference

Supporting reference for the exploration-brainstorming skill. Contains the full questionnaire and synthesis template.

---

## Full Questionnaire by Block

### Block 1: The Problem

| # | Question |
|---|----------|
| 1.1 | What concrete problem do you want to solve? Describe it in 2-3 sentences as if explaining to someone who knows nothing about the topic. |
| 1.2 | Why does this problem matter? What happens if no one solves it? |
| 1.3 | Who has this problem? (specific person, not "everyone") |
| 1.4 | How do they solve it today without your solution? What do they currently use? |
| 1.5 | What's most frustrating about current solutions? |
| 1.6 | Have you experienced this problem yourself? What's your personal connection? |

**Suggested prompt for the AI:**
> "I have this idea: [description]. Help me refine the problem it solves. Ask me questions that force me to be more specific about who has it, when it occurs, and why current solutions aren't enough."

### Block 2: Proposed Solution

| # | Question |
|---|----------|
| 2.1 | What's your solution idea in one sentence? |
| 2.2 | What would the system do in its simplest possible form? (the minimum happy path) |
| 2.3 | What would be the ideal outcome for the user? |
| 2.4 | How is this different from what already exists? What's the unique angle? |
| 2.5 | What must be true for this solution to work? (key assumptions) |
| 2.6 | What is this solution NOT? What does it explicitly not try to do? |

**Suggested prompt for the AI:**
> "My proposed solution is [description]. Play devil's advocate: what assumptions am I making that could be false? What could make this idea fail completely?"

### Block 3: Scope and Limits

| # | Question |
|---|----------|
| 3.1 | Is this a POC or MVP? Why? |
| 3.2 | What features are absolutely essential for the first cut? |
| 3.3 | What features sound tempting but do NOT belong in the first cut? |
| 3.4 | What's the simplest proof of success? ("If I can do X, the project works") |
| 3.5 | How much time are you willing to invest in the first version? |
| 3.6 | Are you building this for yourself, a client, or to validate a business? |

**Suggested prompt for the AI:**
> "I want to build [description]. Help me define the minimum viable scope. Give me your version of what to include in a first cut and what to leave out, explaining why."

### Block 4: Users and Context

| # | Question |
|---|----------|
| 4.1 | Who is the primary user? Describe with detail (role, technical experience, motivation). |
| 4.2 | Are there secondary users or stakeholders? |
| 4.3 | In what context would they use this? (desktop, mobile, CLI, automated, etc.) |
| 4.4 | How often would they use it? (once, daily, hourly, etc.) |
| 4.5 | What do they expect to get from the system? (a number, a report, an executed action, etc.) |

### Block 5: Risks and Open Questions

| # | Question |
|---|----------|
| 5.1 | What could go wrong with this project? (technically, conceptually, market-wise) |
| 5.2 | What don't you know yet that you need to investigate before starting? |
| 5.3 | Are there critical external dependencies? (third-party APIs, specific data, permissions) |
| 5.4 | What if the core idea doesn't work technically? Is there a plan B? |
| 5.5 | Are there legal, privacy, or regulatory constraints? |

**Suggested prompt for the AI:**
> "Here's my idea and scope: [summary]. Generate a list of the 10 most likely risks for this project, ordered by impact. For each, suggest a mitigation or a question I should answer before starting."

---

## Synthesis Template

Generate at `.pbs-framework/exploration/brainstorming-synthesis.md`:

```markdown
# Brainstorming Synthesis

## Date: [date]
## Sessions: [number and brief description of each]

---

## 1. The Problem
### Description
[2-3 clear sentences describing the problem]

### Who has it
[Description of the primary user and their context]

### How it's solved today
[Current solutions and their limitations]

---

## 2. Proposed Solution
### One-sentence description
[The refined idea, one line]

### What the system does (happy path)
[Description of the main flow in its simplest form]

### Expected outcome for the user
[What the user gets at the end]

### Differentiator
[What distinguishes this from existing solutions]

---

## 3. First Cut Scope
### Project type
- [ ] POC (validate technical feasibility)
- [ ] MVP (validate with real users)

### Included (must-have)
- [feature 1]
- [feature 2]

### Excluded (explicitly out of first cut)
- [feature A — reason it's out]
- [feature B — reason]

### Success criterion
[Minimum proof that this works: "If I can do X, the project succeeds"]

---

## 4. Key Assumptions
- Assumption 1: [description] — Validated: yes/no/pending
- Assumption 2: [description] — Validated: yes/no/pending

---

## 5. Identified Risks
| Risk | Impact (high/medium/low) | Proposed mitigation |
|------|--------------------------|---------------------|

---

## 6. Open Questions for Discovery
[Questions that cannot be answered with brainstorming and require technical investigation]
- Question 1: [specific question]
- Question 2: [specific question]

---

## 7. Explored and Discarded Ideas
| Idea | Reason for discarding |
|------|-----------------------|

---

## 8. Additional Notes
[Any insights, connections, or references that came up during brainstorming
and may be useful later]
```
