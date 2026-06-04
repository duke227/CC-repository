# Collect.ps1 - 将本机 ~/.claude/ 中的新内容收集到仓库
# 在 git commit 之前运行此脚本
# 用法: .\shared-claude-config\collect.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$ClaudeDir = "$env:USERPROFILE\.claude"
$SharedDir = "$PSScriptRoot"

Write-Host "=== 收集本机 Claude Code 配置 ===" -ForegroundColor Cyan
Write-Host "来源: $ClaudeDir"
Write-Host "目标: $SharedDir"
Write-Host ""

# 1. 收集 memory/ (将本机新增的文件复制到仓库)
if (Test-Path "$ClaudeDir\memory") {
    New-Item -ItemType Directory -Force -Path "$SharedDir\memory" | Out-Null

    # 获取仓库中已有的 memory 文件列表
    $existing = @()
    if (Test-Path "$SharedDir\memory") {
        $existing = Get-ChildItem "$SharedDir\memory" -File | ForEach-Object { $_.Name }
    }

    # 复制本机中仓库没有的文件
    $newCount = 0
    Get-ChildItem "$ClaudeDir\memory" -File | ForEach-Object {
        if ($existing -notcontains $_.Name) {
            Copy-Item -Path $_.FullName -Destination "$SharedDir\memory\" -Force
            Write-Host "[NEW] memory/$($_.Name)" -ForegroundColor Green
            $newCount++
        }
    }

    if ($newCount -eq 0) {
        Write-Host "[OK] memory/ - 无新文件" -ForegroundColor Gray
    }
}

# 2. 收集 scheduled-tasks/
if (Test-Path "$ClaudeDir\scheduled-tasks") {
    New-Item -ItemType Directory -Force -Path "$SharedDir\scheduled-tasks" | Out-Null

    $existing = @()
    if (Test-Path "$SharedDir\scheduled-tasks") {
        $existing = Get-ChildItem "$SharedDir\scheduled-tasks" -Directory | ForEach-Object { $_.Name }
    }

    $newCount = 0
    Get-ChildItem "$ClaudeDir\scheduled-tasks" -Directory | ForEach-Object {
        if ($existing -notcontains $_.Name) {
            Copy-Item -Path $_.FullName -Destination "$SharedDir\scheduled-tasks\" -Recurse -Force
            Write-Host "[NEW] scheduled-tasks/$($_.Name)" -ForegroundColor Green
            $newCount++
        }
    }

    if ($newCount -eq 0) {
        Write-Host "[OK] scheduled-tasks/ - 无新任务" -ForegroundColor Gray
    }
}

# 3. 提示 settings.json
Write-Host ""
Write-Host "[提示] settings.json 和 keybindings.json 不会被自动收集。" -ForegroundColor Yellow
Write-Host "       如需更新，请直接编辑仓库中的文件：" -ForegroundColor Yellow
Write-Host "       $SharedDir\settings.json" -ForegroundColor Yellow

Write-Host ""
Write-Host "收集完成！请 review 变更后 commit 并 push。" -ForegroundColor Cyan
