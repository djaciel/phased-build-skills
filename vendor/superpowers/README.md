# Vendored Superpowers Skills

These are copies of skills from [Superpowers](https://github.com/obra/superpowers) that PBS depends on. They are included here as a **fallback** so that PBS works out of the box without requiring a separate Superpowers installation.

## Included Skills

| Skill | Purpose | Used by |
|-------|---------|---------|
| test-driven-development | TDD Iron Law enforcement | pbs-task-execution, pbs-fixing-issues |
| verification-before-completion | Evidence before claims | pbs-task-execution, pbs-phase-validation, pbs-generating-definitions, pbs-codebase-familiarization, pbs-phase-closure |
| systematic-debugging | 4-phase debugging process | pbs-task-execution (when bugs found), pbs-spike-execution |

## When to use these vs. full Superpowers

- **Don't have Superpowers installed?** Install these: `npx skills add ./vendor/superpowers -y -g`
- **Already have Superpowers installed?** Skip this — your Superpowers installation already includes these skills (and more).

## Attribution

These skills are created by [Jesse Vincent (obra)](https://github.com/obra) and the Superpowers contributors. They are included here under the same license as the original project. For the full Superpowers suite (14+ skills), install from: https://github.com/obra/superpowers
