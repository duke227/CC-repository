#!/bin/bash
# sync.sh - 将仓库中的共享配置同步到 ~/.claude/
# 在 git pull 之后运行此脚本
# 用法: ./shared-claude-config/sync.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
SHARED_DIR="$REPO_ROOT/shared-claude-config"

echo "=== Claude Code 配置同步 ==="
echo "仓库: $REPO_ROOT"
echo "目标: $CLAUDE_DIR"
echo ""

# 确保 ~/.claude/ 目录存在
mkdir -p "$CLAUDE_DIR"

# 1. 同步 settings.json
if [ -f "$SHARED_DIR/settings.json" ]; then
    cp "$SHARED_DIR/settings.json" "$CLAUDE_DIR/settings.json"
    echo "[OK] settings.json"
fi

# 2. 同步 keybindings.json
if [ -f "$SHARED_DIR/keybindings.json" ]; then
    cp "$SHARED_DIR/keybindings.json" "$CLAUDE_DIR/keybindings.json"
    echo "[OK] keybindings.json"
fi

# 3. 同步 memory/ (合并)
if [ -d "$SHARED_DIR/memory" ]; then
    mkdir -p "$CLAUDE_DIR/memory"
    cp -r "$SHARED_DIR/memory/"* "$CLAUDE_DIR/memory/" 2>/dev/null || true
    echo "[OK] memory/"
fi

# 4. 同步 scheduled-tasks/ (合并)
if [ -d "$SHARED_DIR/scheduled-tasks" ]; then
    mkdir -p "$CLAUDE_DIR/scheduled-tasks"
    cp -r "$SHARED_DIR/scheduled-tasks/"* "$CLAUDE_DIR/scheduled-tasks/" 2>/dev/null || true
    echo "[OK] scheduled-tasks/"
fi

echo ""
echo "同步完成！"
echo "提示：如果你在本机创建了新的 memory 或定时任务，运行 collect.sh 将它们收集到仓库中。"
