# Collect.ps1 - Copy local ~/.claude/* into the repo for sharing
# Run BEFORE git commit when you have new sessions/memories/tasks
# Usage: .\shared-claude-config\collect.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ClaudeDir = "$env:USERPROFILE\.claude"
$SharedDir = "$PSScriptRoot"

Write-Host "=== Collect Claude Code Data ===" -ForegroundColor Cyan
Write-Host "From: $ClaudeDir"
Write-Host "To:   $RepoRoot"
Write-Host ""

# 1. Collect memory/
if (Test-Path "$ClaudeDir\memory") {
    New-Item -ItemType Directory -Force -Path "$SharedDir\memory" | Out-Null
    $existing = @()
    if (Test-Path "$SharedDir\memory") {
        $existing = Get-ChildItem "$SharedDir\memory" -File | ForEach-Object { $_.Name }
    }
    $newCount = 0
    Get-ChildItem "$ClaudeDir\memory" -File | ForEach-Object {
        if ($existing -notcontains $_.Name) {
            Copy-Item -Path $_.FullName -Destination "$SharedDir\memory\" -Force
            Write-Host "  [NEW] memory/$($_.Name)" -ForegroundColor Green
            $newCount++
        }
    }
    if ($newCount -eq 0) { Write-Host "  [OK] memory/ - no new files" -ForegroundColor Gray }
}

# 2. Collect scheduled-tasks/
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
            Write-Host "  [NEW] scheduled-tasks/$($_.Name)" -ForegroundColor Green
            $newCount++
        }
    }
    if ($newCount -eq 0) { Write-Host "  [OK] scheduled-tasks/ - no new tasks" -ForegroundColor Gray }
}

# 3. Collect sessions/ (overwrites same-name files)
if (Test-Path "$ClaudeDir\sessions") {
    New-Item -ItemType Directory -Force -Path "$RepoRoot\sessions" | Out-Null
    $syncedCount = 0
    Get-ChildItem "$ClaudeDir\sessions" -File | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination "$RepoRoot\sessions\" -Force
        $syncedCount++
    }
    Write-Host "  [OK] sessions/ - collected $syncedCount session(s)" -ForegroundColor Green
}

Write-Host ""
Write-Host "[Tip] settings.json and keybindings.json are NOT auto-collected." -ForegroundColor Yellow
Write-Host "      Edit them directly in the repo: $SharedDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Done! Now run: git add -A && git commit -m 'update' && git push" -ForegroundColor Cyan
