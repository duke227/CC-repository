#!/bin/bash
# collect.sh - 将本机 ~/.claude/ 中的新内容收集到仓库
# 在 git commit 之前运行此脚本
# 用法: ./shared-claude-config/collect.sh

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
SHARED_DIR="$REPO_ROOT/shared-claude-config"

echo "=== 收集本机 Claude Code 配置 ==="
echo "来源: $CLAUDE_DIR"
echo "目标: $SHARED_DIR"
echo ""

# 1. 收集 memory/
if [ -d "$CLAUDE_DIR/memory" ]; then
    mkdir -p "$SHARED_DIR/memory"
    new_count=0
    for f in "$CLAUDE_DIR/memory"/*; do
        if [ -f "$f" ]; then
            basename=$(basename "$f")
            if [ ! -f "$SHARED_DIR/memory/$basename" ]; then
                cp "$f" "$SHARED_DIR/memory/"
                echo "[NEW] memory/$basename"
                new_count=$((new_count + 1))
            fi
        fi
    done
    if [ $new_count -eq 0 ]; then
        echo "[OK] memory/ - 无新文件"
    fi
fi

# 2. 收集 scheduled-tasks/
if [ -d "$CLAUDE_DIR/scheduled-tasks" ]; then
    mkdir -p "$SHARED_DIR/scheduled-tasks"
    new_count=0
    for d in "$CLAUDE_DIR/scheduled-tasks"/*/; do
        if [ -d "$d" ]; then
            basename=$(basename "$d")
            if [ ! -d "$SHARED_DIR/scheduled-tasks/$basename" ]; then
                cp -r "$d" "$SHARED_DIR/scheduled-tasks/"
                echo "[NEW] scheduled-tasks/$basename"
                new_count=$((new_count + 1))
            fi
        fi
    done
    if [ $new_count -eq 0 ]; then
        echo "[OK] scheduled-tasks/ - 无新任务"
    fi
fi

echo ""
echo "[提示] settings.json 和 keybindings.json 不会被自动收集。"
echo "       如需更新，请直接编辑仓库中的文件："
echo "       $SHARED_DIR/settings.json"
echo ""
echo "收集完成！请 review 变更后 commit 并 push。"
