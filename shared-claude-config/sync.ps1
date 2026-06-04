# Sync.ps1 - Copy shared config from repo to ~/.claude/
# Run AFTER git pull to apply changes from other computers
# Usage: .\shared-claude-config\sync.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ClaudeDir = "$env:USERPROFILE\.claude"
$SharedDir = "$PSScriptRoot"

Write-Host "=== Claude Code Sync ===" -ForegroundColor Cyan
Write-Host "Repo:   $RepoRoot"
Write-Host "Target: $ClaudeDir"
Write-Host ""

# Ensure ~/.claude/ exists
New-Item -ItemType Directory -Force -Path $ClaudeDir | Out-Null

# 1. Sync settings.json
if (Test-Path "$SharedDir\settings.json") {
    Copy-Item -Path "$SharedDir\settings.json" -Destination "$ClaudeDir\settings.json" -Force
    Write-Host "  [OK] settings.json" -ForegroundColor Green
}

# 2. Sync keybindings.json
if (Test-Path "$SharedDir\keybindings.json") {
    Copy-Item -Path "$SharedDir\keybindings.json" -Destination "$ClaudeDir\keybindings.json" -Force
    Write-Host "  [OK] keybindings.json" -ForegroundColor Green
}

# 3. Sync memory/
if (Test-Path "$SharedDir\memory") {
    New-Item -ItemType Directory -Force -Path "$ClaudeDir\memory" | Out-Null
    Copy-Item -Path "$SharedDir\memory\*" -Destination "$ClaudeDir\memory\" -Force
    Write-Host "  [OK] memory/" -ForegroundColor Green
}

# 4. Sync scheduled-tasks/
if (Test-Path "$SharedDir\scheduled-tasks") {
    New-Item -ItemType Directory -Force -Path "$ClaudeDir\scheduled-tasks" | Out-Null
    Copy-Item -Path "$SharedDir\scheduled-tasks\*" -Destination "$ClaudeDir\scheduled-tasks\" -Force
    Write-Host "  [OK] scheduled-tasks/" -ForegroundColor Green
}

# 5. Sync sessions/ (from repo to local)
if (Test-Path "$RepoRoot\sessions") {
    New-Item -ItemType Directory -Force -Path "$ClaudeDir\sessions" | Out-Null
    Copy-Item -Path "$RepoRoot\sessions\*" -Destination "$ClaudeDir\sessions\" -Force
    $count = (Get-ChildItem "$RepoRoot\sessions" -File).Count
    Write-Host "  [OK] sessions/ ($count session(s))" -ForegroundColor Green
}

Write-Host ""
Write-Host "Sync complete!" -ForegroundColor Cyan
Write-Host "Tip: Run collect.ps1 before git commit to save your latest sessions." -ForegroundColor Yellow
