# AI Agent System

A coordinated multi-agent system for software development, available for both **VS Code (GitHub Copilot)** and **Claude Code CLI**.

## Features

- **17 specialized agents** for different development phases
- **Explicit handoff protocols** between agents
- **Cross-session memory** using cloudmcp-manager
- **Self-improvement system** with skill tracking and retrospectives
- **Installation scripts** for global or per-repository setup

## Quick Start

### VS Code

```powershell
# Global installation
.\scripts\install-vscode-global.ps1

# Per-repository installation
.\scripts\install-vscode-repo.ps1 -RepoPath "C:\Path\To\Repo"
```

### Claude Code

```powershell
# Global installation
.\scripts\install-claude-global.ps1

# Per-repository installation
.\scripts\install-claude-repo.ps1 -RepoPath "C:\Path\To\Repo"
```

## Directory Structure

```
├── vs-code-agents/          # VS Code / GitHub Copilot agents
├── claude/                   # Claude Code CLI agents
├── scripts/                  # Installation scripts
├── copilot-instructions.md   # GitHub Copilot instructions
├── CLAUDE.md                 # Claude Code instructions
└── USING-AGENTS.md           # Detailed usage guide
```

## Agents

| Agent | Purpose |
|-------|---------|
| orchestrator | Task coordination and routing |
| analyst | Pre-implementation research |
| architect | Design governance and ADRs |
| planner | Milestones and work packages |
| implementer | Production code and tests |
| critic | Plan validation |
| qa | Test strategy and verification |
| retrospective | Learning extraction |
| memory | Cross-session context |
| skillbook | Skill management |
| + 7 more... | See [USING-AGENTS.md](USING-AGENTS.md) |

## Documentation

- [USING-AGENTS.md](USING-AGENTS.md) - Comprehensive usage guide
- [copilot-instructions.md](copilot-instructions.md) - GitHub Copilot integration
- [CLAUDE.md](CLAUDE.md) - Claude Code integration

## License

MIT
