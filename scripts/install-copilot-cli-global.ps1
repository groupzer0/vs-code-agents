<#
.SYNOPSIS
    Installs GitHub Copilot CLI agents globally for all repositories.

.DESCRIPTION
    Copies Copilot CLI agent files to the user's global agents directory.

    WARNING: As of December 2025, there is a known bug (GitHub Issue #452) where
    user-level agents in ~/.copilot/agents/ are not loaded by Copilot CLI.
    Use install-copilot-cli-repo.ps1 for per-repository installation instead.

    See: https://github.com/github/copilot-cli/issues/452

.PARAMETER Force
    Overwrite existing agent files without prompting.

.EXAMPLE
    .\install-copilot-cli-global.ps1
    .\install-copilot-cli-global.ps1 -Force
#>

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Display warning about known bug
Write-Host ""
Write-Host "WARNING: Known Bug (GitHub Issue #452)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Yellow
Write-Host "User-level agents in ~/.copilot/agents/ are NOT currently loaded by" -ForegroundColor Yellow
Write-Host "Copilot CLI due to a known bug. This installation may not work." -ForegroundColor Yellow
Write-Host ""
Write-Host "Recommended: Use install-copilot-cli-repo.ps1 for per-repository installation." -ForegroundColor Yellow
Write-Host "See: https://github.com/github/copilot-cli/issues/452" -ForegroundColor Yellow
Write-Host ""

$Response = Read-Host "Continue with global installation anyway? (y/N)"
if ($Response -ne 'y' -and $Response -ne 'Y') {
    Write-Host "Installation cancelled. Use install-copilot-cli-repo.ps1 instead." -ForegroundColor Cyan
    exit 0
}

# Determine source and destination paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path (Split-Path -Parent $ScriptDir) "copilot-cli"

# Copilot CLI user agents directory
if ($env:XDG_CONFIG_HOME) {
    $DestDir = Join-Path $env:XDG_CONFIG_HOME ".copilot\agents"
} elseif ($env:USERPROFILE) {
    $DestDir = Join-Path $env:USERPROFILE ".copilot\agents"
} else {
    $DestDir = Join-Path $HOME ".copilot/agents"
}

Write-Host ""
Write-Host "GitHub Copilot CLI Global Agent Installer" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
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
    Write-Host "Creating destination directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
}

# Get agent files
$AgentFiles = Get-ChildItem -Path $SourceDir -Filter "*.agent.md"

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

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOTE: Due to bug #452, these agents may not be recognized until the" -ForegroundColor Yellow
Write-Host "issue is resolved. Test with: copilot --agent analyst --prompt 'test'" -ForegroundColor Yellow
Write-Host ""
Write-Host "If agents are not recognized, use repository-level installation:" -ForegroundColor Gray
Write-Host "  .\install-copilot-cli-repo.ps1 -RepoPath 'C:\path\to\repo'" -ForegroundColor Gray
