<#
.SYNOPSIS
    Installs Claude Code agents globally.

.DESCRIPTION
    Copies Claude agent files to the user's ~/.claude/agents directory.
    Agents will be available in all Claude Code sessions.

.PARAMETER Force
    Overwrite existing agent files without prompting.

.EXAMPLE
    .\install-claude-global.ps1
    .\install-claude-global.ps1 -Force
#>

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Determine source and destination paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path (Split-Path -Parent $ScriptDir) "claude"

# Claude agents directory
$DestDir = Join-Path $HOME ".claude\agents"

Write-Host "Claude Code Global Agent Installer" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Source: $SourceDir"
Write-Host "Destination: $DestDir"
Write-Host ""

# Verify source exists
if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory not found: $SourceDir"
    exit 1
}

# Create destination if needed
if (-not (Test-Path $DestDir)) {
    Write-Host "Creating ~/.claude/agents directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
}

# Get agent files
$AgentFiles = Get-ChildItem -Path $SourceDir -Filter "*.md"

if ($AgentFiles.Count -eq 0) {
    Write-Warning "No agent files found in source directory"
    exit 0
}

Write-Host "Found $($AgentFiles.Count) agent files to install:" -ForegroundColor Green

foreach ($File in $AgentFiles) {
    $DestPath = Join-Path $DestDir $File.Name
    $Exists = Test-Path $DestPath

    if ($Exists -and -not $Force) {
        $Response = Read-Host "  $($File.Name) exists. Overwrite? (y/N)"
        if ($Response -ne 'y' -and $Response -ne 'Y') {
            Write-Host "  Skipping $($File.Name)" -ForegroundColor Yellow
            continue
        }
    }

    Copy-Item -Path $File.FullName -Destination $DestPath -Force
    $Status = if ($Exists) { "Updated" } else { "Installed" }
    Write-Host "  $Status $($File.Name)" -ForegroundColor Green
}

# Copy CLAUDE.md to ~/.claude
$ClaudeMd = Join-Path (Split-Path -Parent $ScriptDir) "CLAUDE.md"
$ClaudeDir = Join-Path $HOME ".claude"
if (Test-Path $ClaudeMd) {
    $DestClaude = Join-Path $ClaudeDir "CLAUDE.md"
    Copy-Item -Path $ClaudeMd -Destination $DestClaude -Force
    Write-Host "  Installed CLAUDE.md to ~/.claude/" -ForegroundColor Green
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Cyan
Write-Host "Agents are now available globally in Claude Code." -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Restart Claude Code to load new agents." -ForegroundColor Yellow
Write-Host ""
Write-Host "Usage: Task(subagent_type='agent-name', prompt='...')" -ForegroundColor Gray
