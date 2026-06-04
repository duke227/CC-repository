#!/bin/bash
# sync.sh - Restore shared CC data from repo to this machine
# Run AFTER git pull to get sessions from other computers
# Usage: ./shared-claude-config/sync.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
SHARED_DIR="$REPO_ROOT/shared-claude-config"
LOCAL_CWD="$(pwd)"

# Encode path the way CC does
LOCAL_ENCODED="$(echo "$LOCAL_CWD" | sed 's/[:\\]/-/g')"

echo "=== Claude Code Sync ==="
echo "Repo:   $REPO_ROOT"
echo "Target: $CLAUDE_DIR"
echo "Path:   $LOCAL_ENCODED"
echo ""

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

# 5. Sync sessions/ with cwd fix
if [ -d "$REPO_ROOT/sessions" ]; then
    mkdir -p "$CLAUDE_DIR/sessions"
    session_count=0
    for f in "$REPO_ROOT/sessions"/*; do
        if [ -f "$f" ]; then
            basename=$(basename "$f")
            # Update cwd to match THIS machine's path using sed
            sed "s|\"cwd\":\"[^\"]*\"|\"cwd\":\"$LOCAL_CWD\"|g" "$f" > "$CLAUDE_DIR/sessions/$basename"
            session_count=$((session_count + 1))
        fi
    done
    echo "  [OK] sessions/ - ${session_count} session(s)"
fi

# 6. Merge projects/ - combine conversations from ALL machines
#    Each machine stores under its own encoded path, so we merge all into this machine's dir
if [ -d "$REPO_ROOT/projects" ]; then
    local_proj="$CLAUDE_DIR/projects/$LOCAL_ENCODED"
    mkdir -p "$local_proj"
    merged_count=0
    machine_count=0
    for remote_dir in "$REPO_ROOT/projects"/*/; do
        if [ -d "$remote_dir" ]; then
            machine_count=$((machine_count + 1))
            for jsonl in "$remote_dir"*.jsonl; do
                if [ -f "$jsonl" ]; then
                    cp "$jsonl" "$local_proj/"
                    merged_count=$((merged_count + 1))
                fi
            done
        fi
    done
    echo "  [OK] projects/ - merged ${merged_count} conversation(s) from ${machine_count} machine(s)"
fi

echo ""
echo "Sync complete!"
echo "Tip: Run collect.sh before git commit to save your latest sessions."
