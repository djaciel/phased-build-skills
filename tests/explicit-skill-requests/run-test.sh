#!/usr/bin/env bash
# Test explicit skill requests (user names a skill directly)
# Usage: ./run-test.sh <skill-name> [prompt-file] [max-turns]
#
# Tests whether Claude invokes a skill when the user explicitly requests it.
# Also checks for premature action (Claude doing work BEFORE loading the skill).
#
# Set MODEL env var to override the default model (e.g., MODEL=opus)

set -e

SKILL_NAME="$1"
PROMPT_FILE="$2"
MAX_TURNS="${3:-5}"

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the phased-build-skills root (two levels up)
PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

# Default prompt file if not provided
if [ -z "$PROMPT_FILE" ]; then
    # Try to find a prompt that mentions the skill
    for f in "$PROMPTS_DIR"/*.txt; do
        if grep -qi "$SKILL_NAME" "$f" 2>/dev/null; then
            PROMPT_FILE="$f"
            break
        fi
    done
fi

if [ -z "$SKILL_NAME" ] || [ -z "$PROMPT_FILE" ] || [ ! -f "$PROMPT_FILE" ]; then
    echo "Usage: $0 <skill-name> [prompt-file] [max-turns]"
    echo "Example: $0 phase-planning"
    echo "Example: $0 phase-planning ./prompts/plan-next-phase.txt"
    echo "Example: MODEL=opus $0 phase-planning"
    echo ""
    echo "Available prompt files:"
    ls "$PROMPTS_DIR"/*.txt 2>/dev/null | xargs -I{} basename {} | sed 's/^/  /'
    exit 1
fi

TIMESTAMP=$(date +%s)
OUTPUT_DIR="/tmp/phased-build-tests/${TIMESTAMP}/explicit-requests/${SKILL_NAME}"
mkdir -p "$OUTPUT_DIR"

# Read prompt from file
PROMPT=$(cat "$PROMPT_FILE")

# Build model flag
MODEL_FLAG=""
if [ -n "$MODEL" ]; then
    MODEL_FLAG="--model $MODEL"
fi

echo "=== Explicit Skill Request Test ==="
echo "Skill:      $SKILL_NAME"
echo "Prompt:     $PROMPT_FILE"
echo "Max turns:  $MAX_TURNS"
echo "Model:      ${MODEL:-default}"
echo "Skills src: $PLUGIN_DIR/skills"
echo "Output:     $OUTPUT_DIR"
echo ""

# Copy prompt for reference
cp "$PROMPT_FILE" "$OUTPUT_DIR/prompt.txt"

# Create a minimal project directory with .pbs-framework/ structure
PROJECT_DIR="$OUTPUT_DIR/project"
mkdir -p "$PROJECT_DIR/.pbs-framework/phases/phase-01"
mkdir -p "$PROJECT_DIR/.pbs-framework/exploration"
mkdir -p "$PROJECT_DIR/.pbs-framework/features/test-feature/phases/phase-01"

# Create minimal framework files
cat > "$PROJECT_DIR/.pbs-framework/00-project-brief.md" << 'EOF'
# Project Brief
## Problema
Test project for explicit skill request validation.
## Tipo de Proyecto
- [x] POC
EOF

cat > "$PROJECT_DIR/.pbs-framework/04-roadmap.md" << 'EOF'
# Roadmap
## Fases
### Fase 1: Core — DETALLADA
- **Objetivo:** Build core functionality
- **Estado:** en progreso
EOF

# Symlink skills into the project's .claude/skills/ so Claude Code discovers them
mkdir -p "$PROJECT_DIR/.claude/skills"
for skill_dir in "$PLUGIN_DIR/skills"/*/; do
    skill_name=$(basename "$skill_dir")
    ln -sf "$skill_dir" "$PROJECT_DIR/.claude/skills/$skill_name"
done

# Initialize a git repo (Claude Code requires it)
cd "$PROJECT_DIR"
git init -q
git add -A
git commit -q -m "init" --allow-empty

# Run Claude
LOG_FILE="$OUTPUT_DIR/claude-output.json"

echo "Running claude -p with explicit request..."
echo "---"
echo "$PROMPT"
echo "---"
echo ""

# shellcheck disable=SC2086
timeout 300 claude -p "$PROMPT" \
    --dangerously-skip-permissions \
    --max-turns "$MAX_TURNS" \
    --verbose \
    --output-format stream-json \
    $MODEL_FLAG \
    > "$LOG_FILE" 2>&1 || true

echo ""
echo "=== Results ==="

# Use python to properly detect Skill tool invocations and premature actions
DETECTION=$(python3 << PYEOF
import json

skill_name = "$SKILL_NAME"
triggered = False
skills_found = []
first_skill_idx = None
premature_tools = []
block_idx = 0

with open("$LOG_FILE") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            data = json.loads(line)
        except:
            continue

        msg = data.get("message", {})
        content = msg.get("content", [])
        if not isinstance(content, list):
            continue

        for block in content:
            if block.get("type") != "tool_use":
                continue
            name = block.get("name", "")
            inp = block.get("input", {})
            block_idx += 1

            if name in ("Skill", "SlashCommand"):
                sk = inp.get("skill", inp.get("command", ""))
                if sk:
                    skills_found.append(sk)
                    if first_skill_idx is None:
                        first_skill_idx = block_idx
                    bare = sk.split(":")[-1] if ":" in sk else sk
                    if bare == skill_name:
                        triggered = True
            elif name not in ("TodoWrite",) and first_skill_idx is None:
                premature_tools.append(name)

print("TRIGGERED=" + ("true" if triggered else "false"))
print("SKILLS=" + ",".join(skills_found) if skills_found else "SKILLS=")
print("PREMATURE=" + ",".join(premature_tools) if premature_tools else "PREMATURE=")
PYEOF
)

eval "$DETECTION"

if [ "$TRIGGERED" = "true" ]; then
    echo "✅ PASS: Skill '$SKILL_NAME' was triggered"
else
    echo "❌ FAIL: Skill '$SKILL_NAME' was NOT triggered"
fi

echo ""
echo "Skills triggered in this run:"
if [ -n "$SKILLS" ]; then
    echo "$SKILLS" | tr ',' '\n' | sed 's/^/  /'
else
    echo "  (none)"
fi

# Check for premature action
echo ""
echo "Checking for premature action..."
if [ -n "$PREMATURE" ]; then
    echo "⚠️  WARNING: Tools invoked BEFORE Skill tool:"
    echo "$PREMATURE" | tr ',' '\n' | sort -u | sed 's/^/    /'
    echo ""
    echo "   This means Claude started working before loading the skill."
else
    echo "✅ OK: No premature tool invocations"
fi

# Show first assistant message
echo ""
echo "First assistant response (truncated):"
grep '"type":"assistant"' "$LOG_FILE" | head -1 | python3 -c "
import sys, json
try:
    line = sys.stdin.readline()
    data = json.loads(line)
    content = data.get('message', {}).get('content', [])
    if isinstance(content, list) and len(content) > 0:
        print(content[0].get('text', '')[:500])
    else:
        print(str(content)[:500])
except:
    print('  (could not extract)')
" 2>/dev/null || echo "  (could not extract)"

echo ""
echo "Full log: $LOG_FILE"

if [ "$TRIGGERED" = "true" ]; then
    exit 0
else
    exit 1
fi
