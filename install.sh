#!/bin/bash
# Quick install script for macOS
# Copies templates to their target locations
# Supports English (default) and Chinese templates

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Language selection
LANG_DIR=""
echo "Select language / 选择语言:"
echo "  1) English (default)"
echo "  2) 中文"
read -r -p "Enter 1 or 2 [1]: " choice
case "$choice" in
  2) LANG_DIR="/zh" ; echo "→ 使用中文模板" ;;
  *) LANG_DIR="" ; echo "→ Using English templates" ;;
esac

TEMPLATES="$SCRIPT_DIR/templates$LANG_DIR"

# 1. Global Copilot instructions
COPILOT_DIR="$HOME/.copilot"
mkdir -p "$COPILOT_DIR"
cp "$TEMPLATES/copilot-instructions.md" "$COPILOT_DIR/copilot-instructions.md"
echo "✅ Copied copilot-instructions.md → ~/.copilot/"

# 2. Companion skill
SKILL_DIR="$COPILOT_DIR/skills/vscode-next-step-orchestrator"
mkdir -p "$SKILL_DIR"
cp "$TEMPLATES/skills/vscode-next-step-orchestrator/SKILL.md" "$SKILL_DIR/SKILL.md"
echo "✅ Copied SKILL.md → ~/.copilot/skills/vscode-next-step-orchestrator/"

# 3. VS Code user-level prompts
PROMPTS_DIR="$HOME/Library/Application Support/Code/User/prompts"
mkdir -p "$PROMPTS_DIR"
cp "$TEMPLATES/vscode-askquestions-global.instructions.md" "$PROMPTS_DIR/"
cp "$TEMPLATES/interactive-workflow.agent.md" "$PROMPTS_DIR/"
echo "✅ Copied instructions + agent → ~/Library/Application Support/Code/User/prompts/"

echo ""
echo "Done! Remember to add the settings snippet from examples/settings.json to your VS Code settings."
