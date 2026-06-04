#!/bin/bash
# sync.sh - Copy shared config from repo to ~/.claude/
# Run AFTER git pull to apply changes from other computers
# Usage: ./shared-claude-config/sync.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
SHARED_DIR="$REPO_ROOT/shared-claude-config"

echo "=== Claude Code Sync ==="
echo "Repo:   $REPO_ROOT"
echo "Target: $CLAUDE_DIR"
echo ""

# Ensure ~/.claude/ exists
mkdir -p "$CLAUDE_DIR"

# 1. Sync settings.json
if [ -f "$SHARED_DIR/settings.json" ]; then
    cp "$SHARED_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    echo "  [OK] settings.json"
fi

# 2. Sync keybindings.json
if [ -f "$SHARED_DIR/keybindings.json" ]; then
    cp "$SHARED_DIR/keybindings.json" "$CLAUDE_DIR/keybindings.json"
    echo "  [OK] keybindings.json"
fi

# 3. Sync memory/
if [ -d "$SHARED_DIR/memory" ]; then
    mkdir -p "$CLAUDE_DIR/memory"
    cp -r "$SHARED_DIR/memory/"* "$CLAUDE_DIR/memory/" 2>/dev/null || true
    echo "  [OK] memory/"
fi

# 4. Sync scheduled-tasks/
if [ -d "$SHARED_DIR/scheduled-tasks" ]; then
    mkdir -p "$CLAUDE_DIR/scheduled-tasks"
    cp -r "$SHARED_DIR/scheduled-tasks/"* "$CLAUDE_DIR/scheduled-tasks/" 2>/dev/null || true
    echo "  [OK] scheduled-tasks/"
fi

# 5. Sync sessions/ (from repo to local)
if [ -d "$REPO_ROOT/sessions" ]; then
    mkdir -p "$CLAUDE_DIR/sessions"
    cp -r "$REPO_ROOT/sessions/"* "$CLAUDE_DIR/sessions/" 2>/dev/null || true
    count=$(ls -1 "$REPO_ROOT/sessions" 2>/dev/null | wc -l)
    echo "  [OK] sessions/ (${count} session(s))"
fi

echo ""
echo "Sync complete!"
echo "Tip: Run collect.sh before git commit to save your latest sessions."
