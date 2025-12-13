<#
.SYNOPSIS
    Installs VSCode agents globally for all workspaces.

.DESCRIPTION
    Copies VSCode agent files to the user's global prompts directory.
    Agents will be available in all VS Code workspaces.

.PARAMETER Force
    Overwrite existing agent files without prompting.

.EXAMPLE
    .\install-vscode-global.ps1
    .\install-vscode-global.ps1 -Force
#>

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Determine source and destination paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path (Split-Path -Parent $ScriptDir) "vs-code-agents"

# VS Code user prompts directory
if ($env:APPDATA) {
    $DestDir = Join-Path $env:APPDATA "Code\User\prompts"
} else {
    $DestDir = Join-Path $HOME ".config/Code/User/prompts"
}

Write-Host "VSCode Global Agent Installer" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
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

# Copy copilot-instructions.md if exists
$CopilotInstructions = Join-Path (Split-Path -Parent $ScriptDir) "copilot-instructions.md"
if (Test-Path $CopilotInstructions) {
    $DestCopilot = Join-Path $DestDir "copilot-instructions.md"
    Copy-Item -Path $CopilotInstructions -Destination $DestCopilot -Force
    Write-Host "  Installed copilot-instructions.md" -ForegroundColor Green
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Cyan
Write-Host "Agents are now available globally in VS Code." -ForegroundColor Cyan
Write-Host ""
Write-Host "Usage: @agent-name in Copilot Chat" -ForegroundColor Gray
