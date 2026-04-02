#!/usr/bin/env bash
# Test skill triggering with natural prompts
# Usage: ./run-test.sh <skill-name> [prompt-file] [max-turns]
#
# Tests whether Claude triggers a skill based on a natural prompt
# (without explicitly mentioning the skill name)
#
# Set MODEL env var to override the default model (e.g., MODEL=opus)

set -e

SKILL_NAME="$1"
PROMPT_FILE="$2"
MAX_TURNS="${3:-5}"

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Get the phased-build-skills root (two levels up from tests/skill-triggering)
PLUGIN_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROMPTS_DIR="$SCRIPT_DIR/prompts"

# Default prompt file if not provided
if [ -z "$PROMPT_FILE" ]; then
    PROMPT_FILE="$PROMPTS_DIR/${SKILL_NAME}.txt"
fi

if [ -z "$SKILL_NAME" ] || [ ! -f "$PROMPT_FILE" ]; then
    echo "Usage: $0 <skill-name> [prompt-file] [max-turns]"
    echo "Example: $0 phase-planning"
    echo "Example: $0 phase-planning ./custom-prompt.txt 5"
    echo "Example: MODEL=opus $0 phase-planning"
    echo ""
    echo "Available skills:"
    ls "$PROMPTS_DIR"/*.txt 2>/dev/null | xargs -I{} basename {} .txt | sed 's/^/  /'
    exit 1
fi

TIMESTAMP=$(date +%s)
OUTPUT_DIR="/tmp/phased-build-tests/${TIMESTAMP}/skill-triggering/${SKILL_NAME}"
mkdir -p "$OUTPUT_DIR"

# Read prompt from file
PROMPT=$(cat "$PROMPT_FILE")

# Build model flag
MODEL_FLAG=""
if [ -n "$MODEL" ]; then
    MODEL_FLAG="--model $MODEL"
fi

echo "=== Skill Triggering Test ==="
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

# Create minimal framework files so skills that read them don't fail
cat > "$PROJECT_DIR/.pbs-framework/00-project-brief.md" << 'EOF'
# Project Brief
## Problema
Test project for skill triggering validation.
## Tipo de Proyecto
- [x] POC
## Alcance
### Incluido
- Core functionality
### Excluido
- Nothing for now
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
git -c commit.gpgsign=false commit -q -m "init" --allow-empty

# Run Claude
LOG_FILE="$OUTPUT_DIR/claude-output.json"

echo "Running claude -p with natural prompt..."
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

# Use python to properly detect Skill tool invocations (avoids matching Bash "command" fields)
DETECTION=$(python3 << PYEOF
import json, sys

skill_name = "$SKILL_NAME"
triggered = False
skills_found = []

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

            # Skill tool: input has "skill" or "command" field
            if name in ("Skill", "SlashCommand"):
                sk = inp.get("skill", inp.get("command", ""))
                if sk:
                    skills_found.append(sk)
                    # Match with or without namespace prefix and pbs- prefix
                    bare = sk.split(":")[-1] if ":" in sk else sk
                    if bare == skill_name or bare == "pbs-" + skill_name:
                        triggered = True

print("TRIGGERED=" + ("true" if triggered else "false"))
print("SKILLS=" + ",".join(skills_found) if skills_found else "SKILLS=")
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
