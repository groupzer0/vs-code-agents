<#
.SYNOPSIS
    Installs Claude Code agents to a specific repository.

.DESCRIPTION
    Copies Claude agent files to a repository's .claude/agents directory.
    Agents will only be available when Claude Code is run from that directory.

.PARAMETER RepoPath
    Path to the repository where agents should be installed.
    Defaults to current directory.

.PARAMETER Force
    Overwrite existing agent files without prompting.

.EXAMPLE
    .\install-claude-repo.ps1
    .\install-claude-repo.ps1 -RepoPath "C:\Projects\MyRepo"
    .\install-claude-repo.ps1 -Force
#>

param(
    [string]$RepoPath = (Get-Location).Path,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Determine source and destination paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path (Split-Path -Parent $ScriptDir) "claude"
$DestDir = Join-Path $RepoPath ".claude\agents"

Write-Host "Claude Code Repository Agent Installer" -ForegroundColor Cyan
Write-Host "=======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Source: $SourceDir"
Write-Host "Repository: $RepoPath"
Write-Host "Destination: $DestDir"
Write-Host ""

# Verify source exists
if (-not (Test-Path $SourceDir)) {
    Write-Error "Source directory not found: $SourceDir"
    exit 1
}

# Verify repo path is a git repository
$GitDir = Join-Path $RepoPath ".git"
if (-not (Test-Path $GitDir)) {
    Write-Warning "Target path does not appear to be a git repository"
    $Response = Read-Host "Continue anyway? (y/N)"
    if ($Response -ne 'y' -and $Response -ne 'Y') {
        exit 0
    }
}

# Create destination if needed
if (-not (Test-Path $DestDir)) {
    Write-Host "Creating .claude/agents directory..." -ForegroundColor Yellow
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

# Copy CLAUDE.md to repo root
$ClaudeMd = Join-Path (Split-Path -Parent $ScriptDir) "CLAUDE.md"
if (Test-Path $ClaudeMd) {
    $DestClaude = Join-Path $RepoPath "CLAUDE.md"
    Copy-Item -Path $ClaudeMd -Destination $DestClaude -Force
    Write-Host "  Installed CLAUDE.md to repo root" -ForegroundColor Green
}

# Create .agents directory structure
$AgentsDirs = @(
    ".agents/analysis",
    ".agents/architecture",
    ".agents/planning",
    ".agents/critique",
    ".agents/qa",
    ".agents/retrospective"
)

Write-Host ""
Write-Host "Creating .agents output directories..." -ForegroundColor Yellow

foreach ($Dir in $AgentsDirs) {
    $FullPath = Join-Path $RepoPath $Dir
    if (-not (Test-Path $FullPath)) {
        New-Item -ItemType Directory -Path $FullPath -Force | Out-Null

        # Create .gitkeep
        $GitKeep = Join-Path $FullPath ".gitkeep"
        "" | Out-File -FilePath $GitKeep -Encoding utf8

        Write-Host "  Created $Dir" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Cyan
Write-Host "Agents are now available in this repository." -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANT: Restart Claude Code to load new agents." -ForegroundColor Yellow
Write-Host ""
Write-Host "Remember to commit the new files:" -ForegroundColor Gray
Write-Host "  git add .claude CLAUDE.md .agents" -ForegroundColor Gray
Write-Host "  git commit -m 'feat: add Claude agent system'" -ForegroundColor Gray
