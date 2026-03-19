#!/usr/bin/env bash
# Run all skill triggering tests
# Usage: ./run-all.sh [max-turns]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"
MAX_TURNS="${1:-3}"

# All skills that have prompt files
SKILLS=()
for f in "$PROMPTS_DIR"/*.txt; do
    [ -f "$f" ] && SKILLS+=("$(basename "$f" .txt)")
done

if [ ${#SKILLS[@]} -eq 0 ]; then
    echo "No prompt files found in $PROMPTS_DIR"
    exit 1
fi

echo "============================================"
echo "  Phased Build Skills — Triggering Tests"
echo "============================================"
echo ""
echo "Skills to test: ${#SKILLS[@]}"
echo "Max turns: $MAX_TURNS"
echo ""

PASSED=0
FAILED=0
SKIPPED=0
RESULTS=()

for skill in "${SKILLS[@]}"; do
    prompt_file="$PROMPTS_DIR/${skill}.txt"

    if [ ! -f "$prompt_file" ]; then
        echo "⚠️  SKIP: No prompt file for $skill"
        SKIPPED=$((SKIPPED + 1))
        RESULTS+=("⚠️  $skill (no prompt)")
        continue
    fi

    echo "━━━ Testing: $skill ━━━"
    echo ""

    if "$SCRIPT_DIR/run-test.sh" "$skill" "$prompt_file" "$MAX_TURNS" 2>&1 | tee "/tmp/phased-build-test-${skill}.log"; then
        PASSED=$((PASSED + 1))
        RESULTS+=("✅ $skill")
    else
        FAILED=$((FAILED + 1))
        RESULTS+=("❌ $skill")
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
echo "Total:   ${#SKILLS[@]}"
echo ""

if [ $FAILED -gt 0 ]; then
    echo "Some tests failed."
    exit 1
else
    echo "All tests passed."
fi
