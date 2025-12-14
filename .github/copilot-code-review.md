# Code Review Instructions for Agent Consistency

When reviewing pull requests that modify agent files, pay close attention to **drift between VS Code, Copilot CLI, and Claude versions** of agents.

## Agent Locations

- **VS Code agents**: `vs-code-agents/*.agent.md`
- **Copilot CLI agents**: `copilot-cli/*.agent.md`
- **Claude agents**: `claude/*.md`

## Expected Differences (Acceptable)

These differences are expected and should NOT be flagged:

### Frontmatter

- **VS Code** uses: `description`, `tools`, `model` (e.g., `Claude Opus 4.5 (anthropic)`)
- **Copilot CLI** uses: `name`, `description`, `tools` (no model - ignored by Copilot CLI)
- **Claude** uses: `name`, `description`, `model` (e.g., `opus`, `sonnet`, `haiku`)

### Tool References

- **VS Code** references: `vscode`, `execute`, `read`, `edit`, `search`, `web`, `agent`, `todo`, MCP tool paths like `cloudmcp-manager/*`, `github/*`, VS Code extension tools like `github.vscode-pull-request-github/*`
- **Copilot CLI** references: `shell`, `read`, `edit`, `search`, `web`, `agent`, `todo`, MCP tool paths like `cloudmcp-manager/*`, `github/*` (no `vscode` or VS Code extension tools)
- **Claude** references: `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Bash`, `TodoWrite`, `Task`, MCP functions like `mcp__cloudmcp-manager__memory-*`

### Invocation Syntax

- **VS Code**: `@agent-name` mentions, `#runSubagent`
- **Copilot CLI**: `copilot --agent agent-name`, `/agent agent-name`
- **Claude**: `Task(subagent_type="agent-name", prompt="...")`

## Must Be Consistent (Flag Drift)

These elements MUST remain consistent between versions. Flag any drift:

### 1. Core Identity & Mission

The agent's role, purpose, and core mission should be identical or semantically equivalent.

**Example - Check for consistency:**

```markdown
# VS Code
**Execution-Focused C# Expert** implementing production code...

# Claude
**Execution-Focused C# Expert** implementing production code...
```

### 2. Key Responsibilities

The numbered list of responsibilities should match.

### 3. Software Hierarchy of Needs

For implementer agents, the hierarchy (Qualities → Principles → Practices → Wisdom → Patterns) must be identical.

### 4. Handoff Protocol

Agent handoff targets and conditions should match:

- Which agents can be handed off to
- When handoffs occur
- Handoff announcement format

### 5. Memory Protocol

Memory entity naming conventions and operations should be consistent:

- Entity patterns (e.g., `Feature-[Name]`, `Skill-[Category]-[Number]`)
- Relation types
- Storage/retrieval guidance

### 6. Output Directories

Both versions should reference the same `.agents/` output structure.

### 7. Constraints & Rules

Any "DO NOT" rules or constraints must be identical.

### 8. Skill Citation Protocol

The skill citation format must match:

```markdown
**Applying**: [Skill-ID]
**Strategy**: [Description]
**Expected Outcome**: [What should happen]
```

### 9. Atomicity Scoring

Scoring thresholds and penalties must be identical for skillbook/retrospective agents.

## Review Checklist

When an agent file is modified, verify:

- [ ] **Corresponding agents updated**: If `vs-code-agents/analyst.agent.md` changes, check if `copilot-cli/analyst.agent.md` and `claude/analyst.md` need the same update
- [ ] **Core identity unchanged** or changed in all versions
- [ ] **Responsibilities match** between versions
- [ ] **Handoff targets consistent**
- [ ] **Memory protocol aligned**
- [ ] **Output directories match**
- [ ] **Constraints identical**

## Agent Mapping

All agents now have 1:1 parity across all three platforms:

| VS Code Agent | Copilot CLI Agent | Claude Agent |
|---------------|-------------------|--------------|
| `analyst.agent.md` | `analyst.agent.md` | `analyst.md` |
| `architect.agent.md` | `architect.agent.md` | `architect.md` |
| `critic.agent.md` | `critic.agent.md` | `critic.md` |
| `devops.agent.md` | `devops.agent.md` | `devops.md` |
| `explainer.agent.md` | `explainer.agent.md` | `explainer.md` |
| `high-level-advisor.agent.md` | `high-level-advisor.agent.md` | `high-level-advisor.md` |
| `implementer.agent.md` | `implementer.agent.md` | `implementer.md` |
| `independent-thinker.agent.md` | `independent-thinker.agent.md` | `independent-thinker.md` |
| `memory.agent.md` | `memory.agent.md` | `memory.md` |
| `orchestrator.agent.md` | `orchestrator.agent.md` | `orchestrator.md` |
| `planner.agent.md` | `planner.agent.md` | `planner.md` |
| `pr-comment-responder.agent.md` | `pr-comment-responder.agent.md` | `pr-comment-responder.md` |
| `qa.agent.md` | `qa.agent.md` | `qa.md` |
| `retrospective.agent.md` | `retrospective.agent.md` | `retrospective.md` |
| `roadmap.agent.md` | `roadmap.agent.md` | `roadmap.md` |
| `security.agent.md` | `security.agent.md` | `security.md` |
| `skillbook.agent.md` | `skillbook.agent.md` | `skillbook.md` |
| `task-generator.agent.md` | `task-generator.agent.md` | `task-generator.md` |

## Flagging Drift

When you detect drift, comment with:

```markdown
⚠️ **Agent Drift Detected**

The following inconsistency was found between agent versions:

| Aspect | VS Code | Copilot CLI | Claude |
|--------|---------|-------------|--------|
| [Aspect] | [VS Code version] | [Copilot CLI version] | [Claude version] |

**Recommendation**: Update [file(s)] to match for consistency.
```

## Sync Recommendations

If changes are made to one version, suggest updating the others:

```markdown
📝 **Sync Recommended**

This PR modifies `vs-code-agents/analyst.agent.md`. Consider updating these files to maintain consistency:

- [ ] `copilot-cli/analyst.agent.md` - Core identity, responsibilities, handoff protocol
- [ ] `claude/analyst.md` - Core identity, responsibilities, handoff protocol
```
