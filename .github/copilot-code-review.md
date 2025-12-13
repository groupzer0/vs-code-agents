# Code Review Instructions for Agent Consistency

When reviewing pull requests that modify agent files, pay close attention to **drift between VS Code and Claude versions** of agents.

## Agent Locations

- **VS Code agents**: `vs-code-agents/*.agent.md`
- **Claude agents**: `claude/*.md`

## Expected Differences (Acceptable)

These differences are expected and should NOT be flagged:

### Frontmatter
- **VS Code** uses: `description`, `tools`, `model` (e.g., `Claude Opus 4.5 (anthropic)`)
- **Claude** uses: `name`, `description`, `model` (e.g., `opus`, `sonnet`, `haiku`)

### Tool References
- **VS Code** references: `vscode`, `execute`, `read`, `edit`, `search`, `web`, `agent`, `todo`, MCP tool paths like `cloudmcp-manager/*`, `github/*`
- **Claude** references: `Read`, `Write`, `Edit`, `Grep`, `Glob`, `Bash`, `TodoWrite`, `Task`, MCP functions like `mcp__cloudmcp-manager__memory-*`

### Invocation Syntax
- **VS Code**: `@agent-name` mentions, `#runSubagent`
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
For implementer/csharp-expert agents, the hierarchy (Qualities → Principles → Practices → Wisdom → Patterns) must be identical.

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

- [ ] **Corresponding agent updated**: If `vs-code-agents/analyst.agent.md` changes, check if `claude/analyst.md` needs the same update
- [ ] **Core identity unchanged** or changed in both
- [ ] **Responsibilities match** between versions
- [ ] **Handoff targets consistent**
- [ ] **Memory protocol aligned**
- [ ] **Output directories match**
- [ ] **Constraints identical**

## Agent Mapping

| VS Code Agent | Claude Agent |
|---------------|--------------|
| `analyst.agent.md` | `analyst.md` |
| `architect.agent.md` | `architect.md` |
| `critic.agent.md` | `critic.md` |
| `devops.agent.md` | *(no equivalent)* |
| `explainer.agent.md` | `create-explainer.md` |
| `high-level-advisor.agent.md` | `high-level-advisor.md` |
| `implementer.agent.md` | `csharp-expert.md` |
| `independent-thinker.agent.md` | `independent-thinker.md` |
| `memory.agent.md` | `memory.md` |
| `orchestrator.agent.md` | *(built-in)* |
| `planner.agent.md` | `planner.md` |
| `qa.agent.md` | `qa.md` |
| `retrospective.agent.md` | `retrospective.md` |
| `roadmap.agent.md` | *(no equivalent)* |
| `security.agent.md` | *(no equivalent)* |
| `skillbook.agent.md` | `skillbook.md` |
| `task-generator.agent.md` | `generate-tasks.md` |
| *(no equivalent)* | `csharp-pod.md` |
| *(no equivalent)* | `feature-request-review.md` |

## Flagging Drift

When you detect drift, comment with:

```markdown
⚠️ **Agent Drift Detected**

The following inconsistency was found between VS Code and Claude versions:

| Aspect | VS Code (`file.agent.md`) | Claude (`file.md`) |
|--------|---------------------------|-------------------|
| [Aspect] | [VS Code version] | [Claude version] |

**Recommendation**: Update [file] to match [other file] for consistency.
```

## Sync Recommendations

If changes are made to one version, suggest updating the other:

```markdown
📝 **Sync Recommended**

This PR modifies `vs-code-agents/analyst.agent.md`. Consider updating `claude/analyst.md` to maintain consistency:

- [ ] Core identity updated
- [ ] Responsibilities synced
- [ ] Handoff protocol aligned
```
