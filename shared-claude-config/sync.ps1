# Sync.ps1 - Restore shared CC data from repo to this machine
# Run AFTER git pull to get sessions from other computers
# Usage: .\shared-claude-config\sync.ps1

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$ClaudeDir = "$env:USERPROFILE\.claude"
$SharedDir = "$PSScriptRoot"
$LocalCwd = (Get-Location).Path

# Encode path the way CC does
$LocalEncoded = $LocalCwd -replace ':', '-' -replace '\\', '-'

Write-Host "=== Claude Code Sync ===" -ForegroundColor Cyan
Write-Host "Repo:   $RepoRoot"
Write-Host "Target: $ClaudeDir"
Write-Host "Path:   $LocalEncoded"
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

# 5. Sync sessions/ with cwd fix
#    Each session file has a "cwd" field from the machine that created it.
#    We update it to THIS machine's cwd so CC finds the conversations.
if (Test-Path "$RepoRoot\sessions") {
    New-Item -ItemType Directory -Force -Path "$ClaudeDir\sessions" | Out-Null
    $sessionCount = 0
    Get-ChildItem "$RepoRoot\sessions" -File | ForEach-Object {
        $dest = "$ClaudeDir\sessions\$($_.Name)"
        $content = Get-Content $_.FullName -Raw -Encoding UTF8
        # Update cwd to match this machine's path
        $content = $content -replace '"cwd":"[^"]*"', """cwd"":""$($LocalCwd -replace '\\', '\\')"""
        Set-Content -Path $dest -Value $content -Encoding UTF8 -NoNewline
        $sessionCount++
    }
    Write-Host "  [OK] sessions/ - $sessionCount session(s)" -ForegroundColor Green
}

# 6. Merge projects/ - combine conversations from ALL machines
#    CC stores conversations under projects/<encoded-path>/<sessionId>.jsonl
#    Each machine has a different encoded path, so we merge all into this machine's dir.
if (Test-Path "$RepoRoot\projects") {
    $localProjDir = "$ClaudeDir\projects\$LocalEncoded"
    New-Item -ItemType Directory -Force -Path $localProjDir | Out-Null
    $mergedCount = 0
    Get-ChildItem "$RepoRoot\projects" -Directory | ForEach-Object {
        $remoteEncoded = $_.Name
        Get-ChildItem $_.FullName -File -Filter "*.jsonl" | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination "$localProjDir\" -Force
            $mergedCount++
        }
    }
    $machineCount = (Get-ChildItem "$RepoRoot\projects" -Directory).Count
    Write-Host "  [OK] projects/ - merged $mergedCount conversation(s) from $machineCount machine(s)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Sync complete!" -ForegroundColor Cyan
Write-Host "Tip: Run collect.ps1 before git commit to save your latest sessions." -ForegroundColor Yellow
