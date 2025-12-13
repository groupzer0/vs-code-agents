# Using the Agents

## Overview

This repository provides a coordinated multi-agent system for software development, available for both **VS Code (GitHub Copilot)** and **Claude Code CLI**. Each agent focuses on a specific phase or concern with clear responsibilities, constraints, and handoffs.

### Typical Workflow

```
Orchestrator → Analyst → Architect → Planner → Critic → Implementer → QA → Retrospective
```

The Memory agent provides long-running context across sessions using `cloudmcp-manager` for persistent memory.

---

## Quick Start

### VS Code Installation

**Global (all workspaces):**
```powershell
.\scripts\install-vscode-global.ps1
```

**Per-repository:**
```powershell
.\scripts\install-vscode-repo.ps1 -RepoPath "C:\Path\To\Your\Repo"
```

### Claude Code Installation

**Global (all sessions):**
```powershell
.\scripts\install-claude-global.ps1
```

**Per-repository:**
```powershell
.\scripts\install-claude-repo.ps1 -RepoPath "C:\Path\To\Your\Repo"
```

---

## Directory Structure

```
.
├── vs-code-agents/          # VS Code / GitHub Copilot agents
│   └── *.agent.md
├── claude/                   # Claude Code CLI agents
│   └── *.md
├── scripts/                  # Installation scripts
│   ├── install-vscode-global.ps1
│   ├── install-vscode-repo.ps1
│   ├── install-claude-global.ps1
│   └── install-claude-repo.ps1
├── copilot-instructions.md   # GitHub Copilot instructions
├── CLAUDE.md                 # Claude Code instructions
└── USING-AGENTS.md           # This file
```

---

## Agent Catalog

### Primary Workflow Agents

| Agent | Role | Best For |
|-------|------|----------|
| **orchestrator** | Task coordination | Complex multi-step tasks |
| **analyst** | Pre-implementation research | Root cause analysis, requirements |
| **architect** | Design governance | ADRs, technical decisions |
| **planner** | Work package creation | Epic breakdown, milestones |
| **implementer** | Code execution | Production code, tests |
| **critic** | Plan validation | Review before implementation |
| **qa** | Test verification | Test strategy, coverage |
| **roadmap** | Strategic vision | Epic definition, prioritization |

### Support Agents

| Agent | Role | Best For |
|-------|------|----------|
| **memory** | Context continuity | Cross-session persistence |
| **skillbook** | Skill management | Learned strategy updates |
| **devops** | CI/CD pipelines | Build automation, deployment |
| **security** | Vulnerability assessment | Threat modeling, secure coding |
| **independent-thinker** | Assumption challenging | Alternative viewpoints |
| **high-level-advisor** | Strategic decisions | Prioritization, unblocking |
| **retrospective** | Reflector/learning | Outcome analysis, skill extraction |
| **explainer** | Documentation | PRDs, technical specs |
| **task-generator** | Task decomposition | Breaking epics into tasks |

---

## VS Code Usage

### Invoking Agents

In GitHub Copilot Chat:
```
@orchestrator Help me implement a new feature
@implementer Fix the bug in UserService.cs
@analyst Investigate why tests are failing
```

### Installation Locations

| Type | Location |
|------|----------|
| Global | `%APPDATA%\Code\User\prompts\` (Windows) |
| Global | `~/.config/Code/User/prompts/` (Linux/Mac) |
| Per-repo | `.github/agents/` |

### More Information

See the official documentation: https://code.visualstudio.com/docs/copilot/copilot-agents

---

## Claude Code Usage

### Invoking Agents

Using the Task tool:
```python
Task(subagent_type="analyst", prompt="Investigate why X fails")
Task(subagent_type="csharp-expert", prompt="Implement feature X")
Task(subagent_type="critic", prompt="Validate plan at .agents/planning/...")
```

### Installation Locations

| Type | Location |
|------|----------|
| Global | `~/.claude/agents/` |
| Per-repo | `.claude/agents/` |

### Important Notes

- Restart Claude Code after installing new agents
- Use `/agents` command to view available agents
- Project-level agents override global agents

---

## Memory System

All agents use `cloudmcp-manager` for cross-session memory (replaces Flowbaby).

### Memory Operations

| Operation | Tool | Purpose |
|-----------|------|---------|
| Search | `memory-search_nodes` | Find relevant context |
| Retrieve | `memory-open_nodes` | Get specific entities |
| Create | `memory-create_entities` | Store new knowledge |
| Update | `memory-add_observations` | Add to existing entities |
| Link | `memory-create_relations` | Connect related concepts |

### Entity Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `Feature-[Name]` | `Feature-Authentication` |
| Decision | `ADR-[Number]` | `ADR-001` |
| Pattern | `Pattern-[Name]` | `Pattern-StrategyTax` |
| Skill | `Skill-[Category]-[Number]` | `Skill-Build-001` |

---

## Workflow Patterns

### Standard Feature Development

```
orchestrator → analyst → architect → planner → critic → implementer → qa → retrospective
```

### Quick Fix Path

```
implementer → qa
```

### Strategic Decision Path

```
independent-thinker → high-level-advisor → task-generator
```

---

## Agent-by-Agent Guide

### Orchestrator – Task Coordination

**Role**: Routes work to specialized agents based on task requirements.

**Use when**:
- Starting complex multi-step tasks
- Unclear which agent should handle a request

**Handoffs to**: analyst, architect, planner, implementer (based on task)

---

### Analyst – Deep Technical Research

**Role**: Investigates unknowns, APIs, performance questions, and tricky tradeoffs.

**Use when**:
- Technical uncertainty exists
- Need API experiments, benchmarks, or comparative analysis

**Example prompts**:
- "Investigate why the cache is causing memory issues"
- "Research options for implementing OAuth 2.0"

**Handoffs to**: architect (design decisions), planner (scope changes)

---

### Architect – System & Design Decisions

**Role**: Maintains architecture, patterns, boundaries, and high-level design decisions.

**Use when**:
- Feature affects system structure or boundaries
- Need ADRs or architectural guidance

**Outputs**: ADRs in `.agents/architecture/ADR-NNN-*.md`

**Handoffs to**: planner (approved designs), analyst (more research needed)

---

### Planner – Implementation Planning

**Role**: Turns epics into concrete, implementation-ready plans.

**Use when**:
- Have a feature/epic and need a structured plan
- Requirements need to be clarified and broken into milestones

**Outputs**: Plans in `.agents/planning/NNN-*-plan.md`

**Handoffs to**: critic (REQUIRED before implementation)

---

### Critic – Plan Reviewer

**Role**: Critically reviews plans before implementation.

**Use when**:
- Plan is "done" and needs quality gate
- Before any implementation begins

**Outputs**: Critiques in `.agents/critique/NNN-*-critique.md`

**Handoffs to**: planner (revision needed), implementer (approved)

---

### Implementer / csharp-expert – Coding & Tests

**Role**: Writes and modifies code, implements approved plans, ensures tests exist and pass.

**Use when**:
- Plan has been approved
- Need to fix implementation issues

**Example prompts**:
- "Implement the UserService per the approved plan"
- "Add unit tests for the PaymentProcessor"

**Handoffs to**: qa (implementation complete), analyst (unknowns found)

---

### QA – Testing Strategy & Execution

**Role**: Designs test strategy, ensures coverage, runs tests.

**Use when**:
- Need a test plan before implementation
- Implementation done and needs test pass

**Outputs**: Test reports in `.agents/qa/NNN-*-test-report.md`

**Handoffs to**: implementer (tests fail), retrospective (all pass)

---

### Retrospective – Lessons Learned

**Role**: Runs post-implementation retrospectives focusing on process improvement.

**Use when**:
- Feature completed through QA
- Want to understand what went well/poorly

**Outputs**: Retrospectives in `.agents/retrospective/YYYY-MM-DD-*.md`

**Handoffs to**: skillbook (learnings to store), planner (process improvements)

---

### Memory – Context Management

**Role**: Retrieves/stores long-term context for coherence across sessions.

**Use when**:
- Resuming long-running effort
- Need explicit memory retrievals

---

### Skillbook – Skill Management

**Role**: Manages learned strategies with atomicity scoring and deduplication.

**Use when**:
- New strategy discovered that should be reused
- Need to update or tag existing skills

---

## Self-Improvement System

The agent system includes a continuous improvement loop:

```
Execution → Reflection → Skill Update → Improved Execution
    ↑                                          ↓
    └──────────────────────────────────────────┘
```

### Skill Citation Protocol

When applying learned strategies, cite skills:

```markdown
**Applying**: Skill-Build-001
**Strategy**: Use /m:1 /nodeReuse:false for CI builds
**Expected**: Avoid file locking errors

[Execute...]

**Result**: Build succeeded
**Skill Validated**: Yes
```

### Atomicity Scoring

Learnings are scored 0-100% for quality:

| Score | Quality | Action |
|-------|---------|--------|
| 95-100% | Excellent | Add immediately |
| 70-94% | Good | Accept with refinement |
| 40-69% | Needs Work | Refine before adding |
| <40% | Rejected | Too vague |

---

## Customizing Agents

Each agent file defines:
- **description**: Purpose of the agent
- **tools**: Allowed tools (file editing, tests, GitHub, etc.)
- **model**: AI model to use (opus, sonnet, haiku)
- **Handoffs**: Which agents can be called next
- **Responsibilities**: What the agent should do
- **Constraints**: What the agent must NOT do

To customize, edit the relevant agent file while keeping the handoff protocol intact.

---

## Putting It All Together

1. Start with **Orchestrator** or **Roadmap** for vision
2. Use **Planner** for concrete plans
3. **Architect / Analyst / Security / Critic** to refine and de-risk
4. **Implementer** for code and tests
5. **QA** for technical quality
6. **Retrospective** and **Skillbook** for continuous improvement
7. **Memory** throughout to keep context across sessions
