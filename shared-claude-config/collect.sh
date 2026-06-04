#!/bin/bash
# collect.sh - Copy local ~/.claude/* into the repo for sharing
# Run BEFORE git commit when you have new sessions/memories/tasks
# Usage: ./shared-claude-config/collect.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
SHARED_DIR="$REPO_ROOT/shared-claude-config"

echo "=== Collect Claude Code Data ==="
echo "From: $CLAUDE_DIR"
echo "To:   $REPO_ROOT"
echo ""

# 1. Collect memory/
if [ -d "$CLAUDE_DIR/memory" ]; then
    mkdir -p "$SHARED_DIR/memory"
    new_count=0
    for f in "$CLAUDE_DIR/memory"/*; do
        if [ -f "$f" ]; then
            basename=$(basename "$f")
            if [ ! -f "$SHARED_DIR/memory/$basename" ]; then
                cp "$f" "$SHARED_DIR/memory/"
                echo "  [NEW] memory/$basename"
                new_count=$((new_count + 1))
            fi
        fi
    done
    if [ $new_count -eq 0 ]; then echo "  [OK] memory/ - no new files"; fi
fi

# 2. Collect scheduled-tasks/
if [ -d "$CLAUDE_DIR/scheduled-tasks" ]; then
    mkdir -p "$SHARED_DIR/scheduled-tasks"
    new_count=0
    for d in "$CLAUDE_DIR/scheduled-tasks"/*/; do
        if [ -d "$d" ]; then
            basename=$(basename "$d")
            if [ ! -d "$SHARED_DIR/scheduled-tasks/$basename" ]; then
                cp -r "$d" "$SHARED_DIR/scheduled-tasks/"
                echo "  [NEW] scheduled-tasks/$basename"
                new_count=$((new_count + 1))
            fi
        fi
    done
    if [ $new_count -eq 0 ]; then echo "  [OK] scheduled-tasks/ - no new tasks"; fi
fi

# 3. Collect sessions/ (overwrites same-name files)
if [ -d "$CLAUDE_DIR/sessions" ]; then
    mkdir -p "$REPO_ROOT/sessions"
    synced=0
    for f in "$CLAUDE_DIR/sessions"/*; do
        if [ -f "$f" ]; then
            cp "$f" "$REPO_ROOT/sessions/"
            synced=$((synced + 1))
        fi
    done
    echo "  [OK] sessions/ - collected ${synced} session(s)"
fi

echo ""
echo "[Tip] settings.json and keybindings.json are NOT auto-collected."
echo "      Edit them directly in the repo: $SHARED_DIR"
echo ""
echo "Done! Now run: git add -A && git commit -m 'update' && git push"
