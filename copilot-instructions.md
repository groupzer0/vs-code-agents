# GitHub Copilot Instructions

This file provides instructions for GitHub Copilot when working with this agent system.

## Agent System Overview

This repository uses a coordinated multi-agent system for software development. Specialized agents handle different responsibilities with explicit handoff protocols and persistent memory.

## Agent Catalog

### Primary Workflow Agents

| Agent | Role | Best For | Output Directory |
|-------|------|----------|------------------|
| **orchestrator** | Task coordination | Complex multi-step tasks | N/A (routes to others) |
| **analyst** | Pre-implementation research | Root cause analysis, requirements | `.agents/analysis/` |
| **architect** | Design governance | ADRs, technical decisions | `.agents/architecture/` |
| **planner** | Work package creation | Epic breakdown, milestones | `.agents/planning/` |
| **implementer** | Code execution | Production code, tests | Source files |
| **critic** | Plan validation | Review before implementation | `.agents/critique/` |
| **qa** | Test verification | Test strategy, coverage | `.agents/qa/` |
| **roadmap** | Strategic vision | Epic definition, prioritization | `.agents/roadmap/` |

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

## Workflow Patterns

### Standard Feature Development

```text
orchestrator -> analyst -> architect -> planner -> critic -> implementer -> qa -> retrospective
```

### Quick Fix Path

```text
implementer -> qa
```

### Strategic Decision Path

```text
independent-thinker -> high-level-advisor -> task-generator
```

## Handoff Protocol

When handing off between agents:

1. **Announce**: "Completing [task]. Handing off to [agent] for [purpose]"
2. **Save Artifacts**: Store outputs in appropriate `.agents/` directory
3. **Route**: Use `@agent-name` mention or explicit delegation

## Memory System

Agents use `cloudmcp-manager` memory tools for cross-session continuity:

- `memory-search_nodes`: Find relevant context
- `memory-create_entities`: Store new knowledge
- `memory-add_observations`: Update existing entities
- `memory-create_relations`: Link related concepts

## Routing Heuristics

| Task Type | Primary Agent | Fallback |
|-----------|---------------|----------|
| C# implementation | implementer | - |
| Architecture review | architect | analyst |
| Task decomposition | task-generator | planner |
| Challenge assumptions | independent-thinker | critic |
| Test strategy | qa | implementer |
| Research/investigation | analyst | - |
| Strategic decisions | high-level-advisor | roadmap |
| Documentation/PRD | explainer | planner |
| CI/CD pipelines | devops | implementer |
| Security review | security | analyst |
| Post-project learning | retrospective | analyst |

## Best Practices

### For All Agents

1. **Memory First**: Retrieve context before multi-step reasoning
2. **Document Outputs**: Save artifacts to appropriate directories
3. **Clear Handoffs**: Announce next agent and purpose
4. **Store Learnings**: Update memory at milestones

### For Implementation

1. **Follow Plans**: The plan document is authoritative
2. **Surface Ambiguities**: Ask before assuming
3. **Test Everything**: No skipping hard tests
4. **Commit Atomically**: Small, conventional commits

## Self-Improvement System

The agent system includes a continuous improvement loop:

```text
Execution -> Reflection -> Skill Update -> Improved Execution
```

### Skill Citation Protocol

When applying learned strategies, cite skills:

```markdown
**Applying**: Skill-Build-001
**Strategy**: Use specific approach for this context
**Expected Outcome**: What should happen

[Execute...]

**Result**: Actual outcome
**Skill Validated**: Yes | No | Partial
```
