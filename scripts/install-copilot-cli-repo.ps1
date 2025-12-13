<#
.SYNOPSIS
    Installs GitHub Copilot CLI agents to a specific repository.

.DESCRIPTION
    Copies Copilot CLI agent files to a repository's .github/agents directory.
    Agents will be available when running Copilot CLI from that repository.

    Note: This is the recommended installation method. Global installation
    (~/.copilot/agents/) has a known bug (GitHub Issue #452) that prevents
    user-level agents from loading.

.PARAMETER RepoPath
    Path to the repository where agents should be installed.
    Defaults to current directory.

.PARAMETER Force
    Overwrite existing agent files without prompting.

.EXAMPLE
    .\install-copilot-cli-repo.ps1
    .\install-copilot-cli-repo.ps1 -RepoPath "C:\Projects\MyRepo"
    .\install-copilot-cli-repo.ps1 -Force
#>

param(
    [string]$RepoPath = (Get-Location).Path,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# Determine source and destination paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourceDir = Join-Path (Split-Path -Parent $ScriptDir) "copilot-cli"
$DestDir = Join-Path $RepoPath ".github\agents"

Write-Host "GitHub Copilot CLI Repository Agent Installer" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
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
    Write-Host "Creating .github/agents directory..." -ForegroundColor Yellow
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

# Copy copilot-instructions.md to .github
$CopilotInstructions = Join-Path (Split-Path -Parent $ScriptDir) "copilot-instructions.md"
$GithubDir = Join-Path $RepoPath ".github"
if (Test-Path $CopilotInstructions) {
    $DestCopilot = Join-Path $GithubDir "copilot-instructions.md"
    $CopilotExists = Test-Path $DestCopilot

    if ($CopilotExists -and -not $Force) {
        # Append to existing file to preserve user customizations
        $NewContent = Get-Content -Path $CopilotInstructions -Raw
        Add-Content -Path $DestCopilot -Value "`n`n# --- Appended by install-copilot-cli-repo.ps1 ---`n"
        Add-Content -Path $DestCopilot -Value $NewContent
        Write-Host "  Appended to existing copilot-instructions.md in .github/" -ForegroundColor Green
    } else {
        Copy-Item -Path $CopilotInstructions -Destination $DestCopilot -Force
        $Status = if ($CopilotExists) { "Replaced" } else { "Installed" }
        Write-Host "  $Status copilot-instructions.md in .github/" -ForegroundColor Green
    }
}

# Create .agents directory structure
$AgentsDirs = @(
    ".agents/analysis",
    ".agents/architecture",
    ".agents/planning",
    ".agents/critique",
    ".agents/qa",
    ".agents/retrospective",
    ".agents/roadmap",
    ".agents/devops",
    ".agents/security",
    ".agents/sessions"
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
Write-Host "Usage:" -ForegroundColor Gray
Write-Host "  copilot --agent analyst --prompt 'your task'" -ForegroundColor Gray
Write-Host "  copilot --agent implementer --prompt 'implement feature X'" -ForegroundColor Gray
Write-Host ""
Write-Host "Interactive mode:" -ForegroundColor Gray
Write-Host "  copilot" -ForegroundColor Gray
Write-Host "  /agent analyst" -ForegroundColor Gray
Write-Host ""
Write-Host "Remember to commit the new files:" -ForegroundColor Gray
Write-Host "  git add .github/agents .agents" -ForegroundColor Gray
Write-Host "  git commit -m 'feat: add Copilot CLI agent system'" -ForegroundColor Gray
