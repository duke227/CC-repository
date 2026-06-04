# Collect.ps1 - Copy local CC data into the repo for sharing across machines
# Run BEFORE git commit to save your latest sessions and config
# Usage: .\shared-claude-config\collect.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ClaudeDir = "$env:USERPROFILE\.claude"
$SharedDir = "$PSScriptRoot"
$LocalCwd = (Get-Location).Path

# Encode path the way CC does: "C:\foo\bar" -> "C--foo-bar"
$LocalEncoded = $LocalCwd -replace ':', '-' -replace '\\', '-'

Write-Host "=== Collect Claude Code Data ===" -ForegroundColor Cyan
Write-Host "From: $ClaudeDir"
Write-Host "To:   $RepoRoot"
Write-Host "Path: $LocalEncoded"
Write-Host ""

# 1. Collect memory/ (new files only, never overwrite)
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

# 2. Collect scheduled-tasks/ (new dirs only)
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

# 3. Collect sessions/ (overwrite to capture latest state)
if (Test-Path "$ClaudeDir\sessions") {
    New-Item -ItemType Directory -Force -Path "$RepoRoot\sessions" | Out-Null
    $syncedCount = 0
    Get-ChildItem "$ClaudeDir\sessions" -File | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination "$RepoRoot\sessions\" -Force
        $syncedCount++
    }
    Write-Host "  [OK] sessions/ - $syncedCount session(s)" -ForegroundColor Green
}

# 4. Collect projects/ (jsonl conversation files for THIS machine)
#    Each machine stores them under its own encoded path, so we keep them separate
if (Test-Path "$ClaudeDir\projects\$LocalEncoded") {
    $repoProjDir = "$RepoRoot\projects\$LocalEncoded"
    New-Item -ItemType Directory -Force -Path $repoProjDir | Out-Null
    $projCount = 0
    Get-ChildItem "$ClaudeDir\projects\$LocalEncoded" -File -Filter "*.jsonl" | ForEach-Object {
        Copy-Item -Path $_.FullName -Destination "$repoProjDir\" -Force
        $projCount++
    }
    Write-Host "  [OK] projects/$LocalEncoded/ - $projCount conversation(s)" -ForegroundColor Green
}

Write-Host ""
Write-Host "[Tip] settings.json and keybindings.json are NOT auto-collected." -ForegroundColor Yellow
Write-Host "      Edit them directly in: $SharedDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Done! Now run: git add -A && git commit -m 'update' && git push" -ForegroundColor Cyan
