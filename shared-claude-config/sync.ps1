# Sync.ps1 - 将仓库中的共享配置同步到 ~/.claude/
# 在 git pull 之后运行此脚本
# 用法: .\shared-claude-config\sync.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ClaudeDir = "$env:USERPROFILE\.claude"
$SharedDir = "$PSScriptRoot"

Write-Host "=== Claude Code 配置同步 ===" -ForegroundColor Cyan
Write-Host "仓库: $RepoRoot"
Write-Host "目标: $ClaudeDir"
Write-Host ""

# 确保 ~/.claude/ 目录存在
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null

# 1. 同步 settings.json
if (Test-Path "$SharedDir\settings.json") {
    Copy-Item -Path "$SharedDir\settings.json" -Destination "$ClaudeDir\settings.json" -Force
    Write-Host "[OK] settings.json" -ForegroundColor Green
}

# 2. 同步 keybindings.json
if (Test-Path "$SharedDir\keybindings.json") {
    Copy-Item -Path "$SharedDir\keybindings.json" -Destination "$ClaudeDir\keybindings.json" -Force
    Write-Host "[OK] keybindings.json" -ForegroundColor Green
}

# 3. 同步 memory/ (合并：保留仓库中的文件 + 本地已有的文件)
if (Test-Path "$SharedDir\memory") {
    New-Item -ItemType Directory -Force -Path "$ClaudeDir\memory" | Out-Null
    Copy-Item -Path "$SharedDir\memory\*" -Destination "$ClaudeDir\memory\" -Force
    Write-Host "[OK] memory/" -ForegroundColor Green
}

# 4. 同步 scheduled-tasks/ (合并)
if (Test-Path "$SharedDir\scheduled-tasks") {
    New-Item -ItemType Directory -Force -Path "$ClaudeDir\scheduled-tasks" | Out-Null
    Copy-Item -Path "$SharedDir\scheduled-tasks\*" -Destination "$ClaudeDir\scheduled-tasks\" -Force
    Write-Host "[OK] scheduled-tasks/" -ForegroundColor Green
}

Write-Host ""
Write-Host "同步完成！" -ForegroundColor Cyan
Write-Host "提示：如果你在本机创建了新的 memory 或定时任务，运行 collect.ps1 将它们收集到仓库中。" -ForegroundColor Yellow
