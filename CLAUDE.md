# Claude Code Agent Instructions

This file provides instructions for Claude Code when using the agent system.

## Agent System Overview

This repository provides a coordinated multi-agent system for software development. Specialized agents handle different responsibilities with explicit handoff protocols and persistent memory using `cloudmcp-manager`.

## Agent Catalog

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **orchestrator** | Task coordination | Complex multi-step tasks |
| **implementer** | Production code, .NET patterns | Writing/reviewing C# code |
| **analyst** | Research, root cause analysis, feature review | Investigating issues, evaluating requests |
| **architect** | ADRs, design governance | Technical decisions |
| **planner** | Milestones, work packages | Breaking down epics |
| **critic** | Plan validation | Before implementation |
| **qa** | Test strategy, verification | After implementation |
| **explainer** | PRDs, feature docs | Documenting features |
| **task-generator** | Atomic task breakdown | After PRD created |
| **high-level-advisor** | Strategic decisions | Major direction choices |
| **independent-thinker** | Challenge assumptions | Getting unfiltered feedback |
| **memory** | Cross-session context | Retrieving/storing knowledge |
| **skillbook** | Skill management | Managing learned strategies |
| **retrospective** | Learning extraction | After task completion |
| **devops** | CI/CD pipelines | Build automation, deployment |
| **roadmap** | Strategic vision | Epic definition, prioritization |
| **security** | Vulnerability assessment | Threat modeling, secure coding |
| **pr-comment-responder** | PR review handler | Addressing bot/human review comments |

## Standard Workflows

**Feature Development:**
```
analyst → architect → planner → critic → implementer → qa → retrospective
```

**Quick Fix:**
```
implementer → qa
```

**Strategic Decision:**
```
independent-thinker → high-level-advisor → task-generator
```

## Invocation Examples

```python
# Research before implementation
Task(subagent_type="analyst", prompt="Investigate why X fails")

# Design review before coding
Task(subagent_type="architect", prompt="Review design for feature X")

# Implementation
Task(subagent_type="implementer", prompt="Implement feature X per plan")

# Plan validation (required before implementation)
Task(subagent_type="critic", prompt="Validate plan at .agents/planning/...")

# Code review after writing
Task(subagent_type="architect", prompt="Review code quality")
Task(subagent_type="implementer", prompt="Review implementation")

# Extract learnings
Task(subagent_type="retrospective", prompt="Analyze what we learned")
```

## Memory Protocol

All agents use `cloudmcp-manager` for cross-session memory:

```python
# Search for context
mcp__cloudmcp-manager__memory-search_nodes(query="[topic]")

# Store learnings
mcp__cloudmcp-manager__memory-add_observations(...)
mcp__cloudmcp-manager__memory-create_entities(...)
```

## Skill Citation

When applying learned strategies, cite skills:

```markdown
**Applying**: Skill-Build-001
**Strategy**: Use /m:1 /nodeReuse:false for CI builds
**Expected**: Avoid file locking errors

[Execute...]

**Result**: Build succeeded
**Skill Validated**: Yes
```

## Output Directories

Agents save artifacts to `.agents/`:
- `analysis/` - Analyst findings
- `architecture/` - ADRs
- `planning/` - Plans and PRDs
- `critique/` - Plan reviews
- `qa/` - Test strategies and reports
- `retrospective/` - Learning extractions

## Best Practices

1. **Memory First**: Retrieve context before multi-step reasoning
2. **Document Outputs**: Save artifacts to appropriate directories
3. **Clear Handoffs**: Announce next agent and purpose
4. **Store Learnings**: Update memory at milestones
5. **Test Everything**: No skipping hard tests
6. **Commit Atomically**: Small, conventional commits
