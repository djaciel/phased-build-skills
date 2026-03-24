#!/usr/bin/env bash
# Run all explicit skill request tests
# Usage: ./run-all.sh [max-turns]
#
# Maps each prompt file to the skill it should trigger.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
MAX_TURNS="${1:-3}"

# Map: prompt-file-name → expected-skill-name
# (prompt filenames don't always match skill names)
declare -A SKILL_MAP=(
    ["start-brainstorming"]="exploration-brainstorming"
    ["start-discovery"]="exploration-discovery"
    ["generate-definitions"]="generating-definitions"
    ["plan-next-phase"]="phase-planning"
    ["implement-task"]="task-execution"
    ["validate-phase"]="phase-validation"
    ["close-phase"]="phase-closure"
    ["fix-blocker"]="fixing-issues"
    ["familiarize-codebase"]="codebase-familiarization"
    ["plan-feature"]="feature-planning"
    ["execute-spike"]="spike-execution"
    ["plan-spike"]="spike-planning"
    ["add-scope"]="add-scope"
)

echo "============================================"
echo "  Phased Build Skills — Explicit Request Tests"
echo "============================================"
echo ""
echo "Prompts to test: ${#SKILL_MAP[@]}"
echo "Max turns: $MAX_TURNS"
echo ""

PASSED=0
FAILED=0
SKIPPED=0
RESULTS=()

for prompt_name in "${!SKILL_MAP[@]}"; do
    skill="${SKILL_MAP[$prompt_name]}"
    prompt_file="$PROMPTS_DIR/${prompt_name}.txt"

    if [ ! -f "$prompt_file" ]; then
        echo "⚠️  SKIP: No prompt file: $prompt_file"
        SKIPPED=$((SKIPPED + 1))
        RESULTS+=("⚠️  $skill ← $prompt_name (no prompt)")
        continue
    fi

    echo "━━━ Testing: $skill (via $prompt_name.txt) ━━━"
    echo ""

    if "$SCRIPT_DIR/run-test.sh" "$skill" "$prompt_file" "$MAX_TURNS" 2>&1 | tee "/tmp/phased-build-explicit-${prompt_name}.log"; then
        PASSED=$((PASSED + 1))
        RESULTS+=("✅ $skill ← $prompt_name")
    else
        FAILED=$((FAILED + 1))
        RESULTS+=("❌ $skill ← $prompt_name")
    fi

    echo ""
done

echo ""
echo "============================================"
echo "  Summary"
echo "============================================"
for result in "${RESULTS[@]}"; do
    echo "  $result"
done
echo ""
echo "Passed:  $PASSED"
echo "Failed:  $FAILED"
echo "Skipped: $SKIPPED"
echo "Total:   ${#SKILL_MAP[@]}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo "Some tests failed."
    exit 1
else
    echo "All tests passed."
fi
