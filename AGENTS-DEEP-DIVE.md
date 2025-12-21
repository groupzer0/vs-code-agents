# VS Code Agents - Deep Dive Documentation

> This comprehensive guide covers advanced usage patterns, agent collaboration, memory systems, and the design philosophy behind this multi-agent workflow.
>
> **New users**: Start with [USING-AGENTS.md](USING-AGENTS.md) for quick setup.

---

## Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Agent Collaboration Patterns](#agent-collaboration-patterns)
3. [The Document-Driven Workflow](#the-document-driven-workflow)
4. [Flowbaby Memory Integration](#flowbaby-memory-integration)
5. [Agent Deep Dives](#agent-deep-dives)
6. [Customization Guide](#customization-guide)
7. [Troubleshooting & FAQ](#troubleshooting--faq)
8. [Agent Orchestration Playbook](#agent-orchestration-playbook)

---

## Design Philosophy

### Why Multiple Specialized Agents?

A single general-purpose AI tries to do everything—plan, code, test, review—often poorly. By splitting responsibilities:

1. **Each agent has clear constraints**: Planner can't write code, Implementer can't redesign
2. **Quality gates are built in**: Critic reviews before implementation, Security audits before production
3. **Handoffs create checkpoints**: Work is documented at each stage
4. **Specialization improves quality**: A security-focused agent catches vulnerabilities a general agent misses

### The Separation of Concerns

| Concern | Agent(s) | Key Constraint |
|---------|----------|----------------|
| **Vision** | Roadmap | Outcomes, not implementation |
| **Planning** | Planner | WHAT/WHY, never HOW (no code) |
| **Research** | Analyst | Analysis only, no fixes |
| **Design** | Architect | Patterns, not implementation details |
| **Quality** | Critic | Reviews, doesn't modify artifacts |
| **Security** | Security | Findings, doesn't implement remediations |
| **Implementation** | Implementer | Follows plans, doesn't redesign |
| **Testing** | QA | Test strategy, not business value |
| **Value** | UAT | Business value, not technical quality |
| **Release** | DevOps | Requires explicit user approval |

### Document-First Development

Every agent produces **Markdown documents** in `agent-output/`:

```text
agent-output/
├── planning/           # Plans with WHAT/WHY
├── analysis/           # Research findings
├── architecture/       # ADRs and design decisions
├── critiques/          # Plan reviews
├── security/           # Security assessments
├── qa/                 # Test strategies
├── uat/                # Value validation
├── retrospectives/     # Lessons learned
└── releases/           # Release documentation
```

**Why documents?**

- **Auditability**: See what was decided and why
- **Handoff context**: Next agent reads the artifacts
- **Memory anchors**: Flowbaby stores references to documents
- **Version control**: Track evolution of decisions

---

## Agent Collaboration Patterns

### Pattern 1: The Planning Pipeline

```text
┌──────────┐    ┌─────────┐    ┌───────────┐    ┌──────────┐
│ Roadmap  │───▶│ Planner │───▶│ Analyst/  │───▶│  Critic  │
│ (vision) │    │ (plan)  │    │ Architect │    │ (review) │
└──────────┘    └─────────┘    │ /Security │    └──────────┘
                               └───────────┘           │
                                                       ▼
                                               ┌──────────────┐
                                               │ Implementer  │
                                               │ (approved)   │
                                               └──────────────┘
```

**When to use**: Starting a new feature from scratch.

**Example flow**:
1. Select **Roadmap** → Define epic: "User authentication system"
2. Select **Planner** → Create plan from epic → `agent-output/planning/001-auth-plan.md`
3. Select **Analyst** → Research OAuth providers → `agent-output/analysis/001-auth-analysis.md`
4. Select **Architect** → Review design fit → updates plan or creates ADR
5. Select **Security** → Threat model → `agent-output/security/001-auth-security.md`
6. Select **Critic** → Final review → `agent-output/critiques/001-auth-plan-critique.md`
7. Select **Implementer** → Code when approved

### Pattern 2: The Implementation Loop

```text
┌─────────────┐    ┌──────┐    ┌──────┐    ┌────────┐
│ Implementer │───▶│  QA  │───▶│ UAT  │───▶│ DevOps │
│   (code)    │    │(test)│    │(value)    │(release)│
└─────────────┘    └──────┘    └──────┘    └────────┘
       ▲               │           │
       └───────────────┴───────────┘
              (fix issues)
```

**When to use**: Plan is approved, coding phase.

**Example flow**:
1. Select **Implementer** → Implement plan → code changes + tests
2. Select **QA** → Verify coverage → `agent-output/qa/001-auth-qa.md`
3. If gaps: back to Implementer
4. Select **UAT** → Validate value → `agent-output/uat/001-auth-uat.md`
5. If gaps: back to Implementer
6. Select **DevOps** → Release → requires user approval

### Pattern 3: The Investigation Branch

```text
┌─────────────┐    ┌─────────┐    ┌─────────────┐
│ Any Agent   │───▶│ Analyst │───▶│ Back to     │
│ hits unknown│    │(research)    │ calling agent
└─────────────┘    └─────────┘    └─────────────┘
```

**When to use**: Hit technical uncertainty during any phase.

**Example flow**:
1. With **Planner** selected, planning auth but unsure about JWT vs session tokens
2. Select **Analyst** → investigates → `agent-output/analysis/002-jwt-vs-sessions.md`
3. Findings go back to Planner to inform the plan

### Pattern 4: The Security Gate

```text
┌─────────────┐    ┌──────────┐    ┌─────────────┐
│ Any Phase   │───▶│ Security │───▶│ Continue or │
│ (sensitive) │    │ (audit)  │    │ Block       │
└─────────────┘    └──────────┘    └─────────────┘
```

**When to use**: Feature touches auth, sensitive data, external interfaces.

**Security can be invoked**:
- During planning (threat model)
- During implementation (code audit)
- Before production (final gate)

### Pattern 5: The Retrospective Cycle

```text
┌──────────┐    ┌───────────────┐    ┌────────────────────┐
│ Delivery │───▶│ Retrospective │───▶│ ProcessImprovement │
│ complete │    │ (lessons)     │    │ (evolve agents)    │
└──────────┘    └───────────────┘    └────────────────────┘
```

**When to use**: After feature delivery, to improve the workflow.

**Example flow**:
1. Feature shipped
2. Select **Retrospective** → captures what went well/poorly
3. Select **ProcessImprovement** → updates agent instructions if patterns emerge

---

## The Document-Driven Workflow

### Document Naming Convention

```text
NNN-feature-name-type.md
```

- **NNN**: Sequential number (001, 002, ...)
- **feature-name**: Descriptive name (auth-system, api-refactor)
- **type**: Document type (plan, analysis, critique, security, etc.)

**Examples**:
- `001-user-auth-plan.md`
- `001-user-auth-analysis.md`
- `001-user-auth-plan-critique.md`
- `001-user-auth-code-audit.md`

### Document Structure Standards

Every document should have:

1. **Changelog** (at top): Track revisions
2. **Value Statement** (plans): "As a [user] I want [X] so that [Y]"
3. **Clear Sections**: Standardized headings
4. **Status/Verdict**: Current state (APPROVED, BLOCKED, etc.)
5. **References**: Links to related documents

### Document Status Tracking

All agents now track and update document status fields. This provides at-a-glance visibility into document state:

| Status | Meaning |
|--------|---------|
| `Draft` | Initial creation, not yet reviewed |
| `In Progress` | Actively being worked on |
| `Pending Review` | Ready for next agent's review |
| `Approved` | Passed review gate |
| `Blocked` | Cannot proceed until issues resolved |
| `Released` | Committed and pushed |

Agents update status when:
- **Implementer**: Marks plan "In Progress" when starting implementation
- **Critic/QA/UAT**: Updates to "Approved" or "Blocked" after review
- **DevOps**: Updates to "Released" after successful release

### Open Question Gate

Plans may contain `OPEN QUESTION` items that require resolution before implementation.

**Question lifecycle:**
1. Planner marks unresolved questions as `OPEN QUESTION: [description]`
2. When resolved, Planner updates to `OPEN QUESTION [RESOLVED]: [description]` or `[CLOSED]`
3. Before handoff, Planner warns user if unresolved questions remain

**Implementer behavior:**
- Scans plans for unresolved `OPEN QUESTION` items
- If any exist, **halts and strongly recommends resolution** before proceeding
- Requires explicit user acknowledgment to proceed despite warning
- Documents user's decision in implementation doc

> [!CAUTION]
> Proceeding with unresolved open questions risks building on flawed assumptions. Always resolve or explicitly acknowledge before implementation.

### Handoff Protocol

When handing off between agents:

```markdown
## Handoff to [Next Agent]

**From**: [Current Agent]
**Artifact**: agent-output/[type]/NNN-feature-type.md
**Status**: [Ready for review / Blocked on X / Approved]
**Key Context**:
- [Important decision 1]
- [Important decision 2]
- [Open question]

**Recommended Action**: [What the next agent should do]
```

---

## Flowbaby Memory Integration

### What is Flowbaby?

[Flowbaby](https://github.com/groupzer0/flowbaby) is a VS Code extension that provides **workspace-scoped long-term memory** for GitHub Copilot. Unlike chat history (which is lost between sessions), Flowbaby stores memories in a local knowledge graph that persists across sessions.

**Key Features**:
- **Hybrid Graph-Vector Search**: Combines knowledge graph structure with vector similarity
- **Workspace Isolation**: Each workspace has separate memory
- **Privacy-First**: All data stays local; no cloud services
- **Agent Tools**: Exposes `#flowbabyStoreSummary` and `#flowbabyRetrieveMemory` for agents

### Why Flowbaby is Unique

Most "memory" solutions for AI agents fall into traps:

| Approach | Problem |
|----------|---------|
| Chat history | Lost between sessions, grows unbounded |
| Vector DB only | No structure, poor at relationships |
| Manual notes | Requires human effort, inconsistent |
| RAG on files | Noisy, retrieves irrelevant context |

**Flowbaby's approach**:
- **Structured summaries**: Agents store decisions, not raw logs
- **Knowledge graph**: Captures relationships between concepts
- **Semantic search**: Finds relevant context even with different wording
- **Automatic + Manual**: Can store automatically or on demand

### Installation

1. **Install from VS Code Marketplace**:
   - Open Extensions (`Ctrl+Shift+X`)
   - Search "Flowbaby"
   - Click Install

  Or install via command line:
  ```bash
  ext install flowbaby.flowbaby
  ```

2. **Initialize Workspace**:
   - Command Palette (`Ctrl+Shift+P`)
   - Run "Flowbaby: Initialize Workspace"

3. **Set API Key**:
   - Command Palette
   - Run "Flowbaby: Set API Key"
   - Enter your OpenAI/Anthropic key (used for local summarization)

**Links**:
- GitHub: https://github.com/groupzer0/flowbaby
- Marketplace: https://marketplace.visualstudio.com/items?itemName=flowbaby.flowbaby

### Memory Contract for Agents

All agents load the **`memory-contract` skill** which defines when and how to use Flowbaby memory. Agents function without Flowbaby but greatly benefit from its cross-session context.

> [!TIP]
> The full memory contract is in `vs-code-agents/skills/memory-contract/SKILL.md`. See [memory-contract-example.md](vs-code-agents/memory-contract-example.md) for usage examples.

**Core principles**:

1. **Retrieve at decision points**: Before making assumptions or choosing between options
2. **Store at value boundaries**: After decisions, completions, or discoveries
3. **Specific queries**: Ask hypothesis-driven questions, not vague category requests
4. **Acknowledge memory**: When retrieved memory influences response, say so

### Retrieval Patterns

**Good retrieval queries** are specific and contextual:

```json
#flowbabyRetrieveMemory {
  "query": "Previous decisions about authentication flow and security requirements for user login",
  "maxResults": 3
}
```

**Bad queries** are vague:
```json
#flowbabyRetrieveMemory {
  "query": "auth stuff",
  "maxResults": 3
}
```

### Storage Patterns

**Store when**:
- Completing a task or phase
- Making a significant decision
- Discovering a constraint or dead end
- Every 5 turns (even without milestone)

**Include**:
- Goal: What you were trying to do
- Outcome: What happened
- Decisions: What was decided
- Rationale: Why
- Artifacts: File paths to detailed docs

```json
#flowbabyStoreSummary {
  "topic": "Auth plan review complete",
  "context": "Completed critique of Plan 001 (user authentication). Found 2 critical issues: missing rate limiting and no threat model for password reset. Plan BLOCKED until addressed. See agent-output/critiques/001-auth-critique.md.",
  "decisions": [
    "Rate limiting required on all auth endpoints",
    "Threat model needed for password reset flow"
  ],
  "rationale": [
    "Without rate limiting, credential stuffing attacks are trivial",
    "Password reset is a common attack vector requiring explicit analysis"
  ],
  "metadata": {
    "status": "Active",
    "artifact": "agent-output/critiques/001-auth-critique.md"
  }
}
```

### Memory Enables Agent Collaboration

Without memory, each agent session starts fresh. With memory:

1. **Analyst** stores research findings
2. **Planner** retrieves findings when creating plan
3. **Security** retrieves prior threat models when auditing
4. **Implementer** retrieves constraints discovered during planning

Memory is the connective tissue that makes multi-agent workflows coherent.

---

## Agent Deep Dives

### Roadmap Agent

**Purpose**: Own product vision and ensure features align with business objectives.

**Key Responsibilities**:
- Define and maintain product roadmap
- Translate business needs into epics
- Validate that plans deliver stated value
- Guard the "Master Product Objective"

**Outputs**:
- Epic definitions
- Roadmap updates
- Value alignment assessments

**When NOT to use**:
- Implementation details
- Technical decisions
- Code review

---

### Planner Agent

**Purpose**: Transform epics into implementation-ready plans.

**Key Responsibilities**:
- Create structured plans with WHAT and WHY
- Define milestones and deliverables
- Identify unknowns requiring investigation
- Coordinate with Analyst, Architect, Security

**Critical Constraint**: **Never writes code or implementation details**.

Plans answer:
- WHAT are we building?
- WHY are we building it (value statement)?
- WHAT are the acceptance criteria?
- WHAT dependencies exist?

Plans do NOT contain:
- HOW to implement (code snippets, algorithms)
- Test case implementations
- Technical architecture (that's Architect's job)

**Outputs**:
- Plans in `agent-output/planning/NNN-feature-plan.md`

---

### Analyst Agent

**Purpose**: Deep technical investigation when unknowns arise.

**Key Responsibilities**:
- Research APIs, libraries, patterns
- Conduct experiments and benchmarks
- Analyze root causes
- Document findings with evidence

**Key Constraint**: **Investigates but doesn't fix**. Produces analysis docs, not code changes.

**When to invoke**:
- Technical uncertainty in planning
- Performance questions
- API/library evaluation
- Comparative analysis
- Root cause investigation

**Outputs**:
- Analysis docs in `agent-output/analysis/NNN-topic-analysis.md`

---

### Architect Agent

**Purpose**: Maintain system design coherence.

**Key Responsibilities**:
- Create and maintain Architecture Decision Records (ADRs)
- Define patterns and boundaries
- Review plans for architectural fit
- Guide cross-cutting concerns

**Key Constraint**: **Defines WHERE things live, not exact implementation**.

**Outputs**:
- ADRs in `agent-output/architecture/`
- Design guidance to Planner/Implementer

---

### Critic Agent

**Purpose**: Quality gate for plans before implementation.

**Key Responsibilities**:
- Review plans for clarity, completeness, scope
- Check architectural alignment
- Identify technical debt risks
- Track critique resolution

**Key Constraint**: **Reviews but doesn't modify**. Creates critique docs, doesn't edit plans.

**Review criteria**:
- Value statement present and clear?
- Aligned with roadmap and architecture?
- Scope appropriate (not too big/small)?
- Dependencies identified?
- No code in plan?

**Verdicts**:
- Issues → Recommend revision
- Clean → Approve for implementation

**Outputs**:
- Critiques in `agent-output/critiques/NNN-plan-critique.md`

---

### Security Agent

**Purpose**: Comprehensive security assessment and guidance.

The Security Agent has been significantly enhanced to provide truly objective, comprehensive security reviews. See [security.agent.md](vs-code-agents/security.agent.md) for the full specification.

**Five-Phase Framework**:
1. **Architectural Security**: Trust boundaries, STRIDE threat modeling, attack surface
2. **Code Security**: OWASP Top 10, language-specific vulnerabilities
3. **Dependency Security**: CVE scanning, supply chain risks
4. **Infrastructure Security**: Headers, TLS, container security
5. **Compliance**: OWASP ASVS, NIST, industry standards

**Key Constraint**: **Identifies and documents, doesn't fix**. Provides remediation guidance.

**Verdicts**:
- `APPROVED`: No blocking issues
- `APPROVED_WITH_CONTROLS`: OK with specific controls implemented
- `BLOCKED_PENDING_REMEDIATION`: Must fix before proceeding
- `REJECTED`: Fundamental design flaw

**Outputs**:
- Security findings in `agent-output/security/`

---

### Implementer Agent

**Purpose**: Write code that implements approved plans.

**Key Responsibilities**:
- Implement plan requirements
- Write and run tests
- Create implementation documentation
- Request clarification when plan is ambiguous

**Key Constraint**: **Follows the plan**. Doesn't redesign or expand scope.

**Outputs**:
- Code changes
- Tests
- Implementation docs

---

### QA Agent

**Purpose**: Ensure technical quality through testing.

**Key Responsibilities**:
- Design test strategy
- Verify test coverage
- Execute tests
- Identify gaps

**Key Constraint**: **Technical quality, not business value** (that's UAT).

**Outputs**:
- Test strategies in `agent-output/qa/`
- Test execution results

---

### UAT Agent

**Purpose**: Validate that implementation delivers business value.

**Key Responsibilities**:
- Read plan's value statement
- Verify implementation satisfies value statement
- Assess from user perspective
- Make release recommendation

**Key Constraint**: **Value, not technical quality** (that's QA).

**Verdicts**:
- `APPROVED FOR RELEASE`: Value delivered
- `NOT APPROVED`: Gaps in value delivery

**Outputs**:
- UAT results in `agent-output/uat/`

---

### DevOps Agent

**Purpose**: Manage releases safely.

**Key Responsibilities**:
- Verify packaging and versioning
- Execute release process
- Require explicit user approval

**Critical Constraint**: **Must ask user before releasing**. Never auto-releases.

**Outputs**:
- Release docs in `agent-output/releases/`

---

### Retrospective Agent

**Purpose**: Capture lessons after delivery.

**Key Responsibilities**:
- Facilitate retrospective
- Document what went well/poorly
- Identify process improvements
- Feed into ProcessImprovement

**Outputs**:
- Retrospectives in `agent-output/retrospectives/`

---

### ProcessImprovement Agent

**Purpose**: Evolve the agent workflow based on retrospectives.

**Key Responsibilities**:
- Analyze retrospective patterns
- Propose agent instruction changes
- Update `.agent.md` files (with user approval)

**Critical Constraint**: **Requires user approval** before modifying agent files.

---


## Skills System

Agents leverage **Claude Skills**—modular, reusable instruction sets that load on-demand via progressive disclosure. This keeps agent files lean while providing deep expertise when needed.

### How Skills Work (Progressive Disclosure)

Skills use a three-level loading system:

1. **Level 1 - Discovery**: Copilot reads skill `name` and `description` from YAML frontmatter (always loaded)
2. **Level 2 - Instructions**: When request matches, the full `SKILL.md` body loads into context
3. **Level 3 - Resources**: Scripts, examples, and references load only when explicitly referenced

This means agents can have access to many skills without consuming context until needed.

### Available Skills

| Skill | Purpose | Key Content |
|-------|---------|-------------|
| `memory-contract` | Unified Flowbaby memory contract | When/how to retrieve and store, anti-patterns |
| `architecture-patterns` | ADR templates, patterns, anti-patterns | Layered architecture, repository pattern, STRIDE |
| `code-review-checklist` | Pre/post-implementation review criteria | Value statement assessment, security checklist |
| `engineering-standards` | SOLID, DRY, YAGNI, KISS | Detection patterns, refactoring guidance |
| `release-procedures` | Two-stage release workflow, semver | Version consistency, platform constraints |
| `security-patterns` | OWASP Top 10, language vulnerabilities | Python, JavaScript, Java, Go specific patterns |
| `testing-patterns` | TDD workflow, test pyramid | Anti-patterns, coverage strategies, mocking |

### Skill Placement

Skills are placed in different directories depending on your VS Code version:

| Version | Location | Notes |
|---------|----------|-------|
| **VS Code Stable (1.107.1)** | `.claude/skills/` | Legacy location, still supported |
| **VS Code Insiders** | `.github/skills/` | New recommended location |

> [!NOTE]
> These locations are changing with upcoming VS Code releases. The `.github/skills/` location is becoming the standard. Check the [VS Code Agent Skills documentation](https://code.visualstudio.com/docs/copilot/customization/agent-skills) for the latest guidance.

### Creating Skills

Each skill is a directory with a `SKILL.md` file:

```text
vs-code-agents/skills/
└── my-skill/
    ├── SKILL.md           # Required: skill definition
    ├── references/        # Optional: detailed docs
    │   └── guide.md
    └── scripts/           # Optional: automation
        └── check.sh
```

**SKILL.md format:**

```yaml
---
name: my-skill
description: Brief description of when to use this skill
license: MIT
metadata:
  author: yourname
  version: "1.0"
---

# Skill Title

Detailed instructions, tables, code examples...
```

---

## Customization Guide

### Adding New Agents

1. Create `your-agent.agent.md` in `vs-code-agents/`
2. Follow the frontmatter format:
   ```yaml
   ---
   description: One-line description
   name: YourAgent
   tools: ['edit/createFile', 'search', ...]
   model: Claude 4.5 Sonnet (or preferred)
   handoffs:
     - label: Handoff Name
       agent: TargetAgent
       prompt: Suggested prompt
       send: false
   ---
   ```
3. Define Purpose, Responsibilities, Constraints
4. Include the Memory Contract section
5. Copy to `.github/agents/` in your workspace

### Modifying Existing Agents

**Safe to modify**:
- `description`: Update for clarity
- `model`: Change to preferred model
- `handoffs`: Add/remove handoff targets
- Response style preferences

**Modify with caution**:
- `tools`: Removing tools limits capability
- Constraints: Removing constraints changes behavior significantly

**Generally don't modify**:
- Core separation of concerns (e.g., making Planner write code)

### Creating Workspace-Specific Variants

You can have project-specific agent variants:

1. Copy agent from `vs-code-agents/` to `.github/agents/`
2. Modify for project needs
3. Project-specific agents override global agents with same name

---

## Troubleshooting & FAQ

### Agent Issues

**Q: Agent not appearing in Copilot**
- Check file location: `.github/agents/` for workspace, VS Code user folder for global
- Verify file extension is `.agent.md`
- Reload VS Code

**Q: Agent ignores constraints**
- Re-invoke with explicit constraint reminder
- Check if constraint is clear in the `.agent.md` file
- Models sometimes drift; be explicit

**Q: Agent tries to do another agent's job**
- Use explicit handoff: "Hand off to [Agent] for [task]"
- Reference the agent's constraints

### Memory Issues

**Q: Memory not working**
- Is Flowbaby installed? Check Extensions
- Is workspace initialized? Run "Flowbaby: Initialize Workspace"
- Is API key set? Run "Flowbaby: Set API Key"
- Check Output panel for Flowbaby errors

**Q: Retrievals return nothing**
- Broadens query: be less specific
- Check if any memory has been stored yet
- Each workspace has separate memory

**Q: Retrievals return irrelevant results**
- Make query more specific
- Include context about what you're looking for
- Reduce `maxResults` to prioritize relevance

### Workflow Issues

**Q: Plans have too much implementation detail**
- Remind Planner of constraint: "WHAT and WHY, not HOW"
- Check if Planner `.agent.md` has this constraint

**Q: Security review is superficial**
- Use the enhanced Security agent (v2)
- Request specific phases: "Conduct Phase 2 (Code Security Review)"
- Provide specific files/endpoints to review

**Q: Too many handoffs, losing context**
- Use Memory agent to maintain context
- Reference artifact paths explicitly
- Include key context in handoff prompts

### General FAQ

**Q: Do I need all 13 agents?**
No. Start with Planner + Implementer. Add others as needed.

**Q: Can I use this without Flowbaby?**
Yes, but agents won't remember across sessions. Each conversation starts fresh.

**Q: Why separate QA and UAT?**
- QA = Technical quality (tests pass, coverage adequate)
- UAT = Business value (feature solves the stated problem)

**Q: Why can't Planner write code?**
Keeping planning separate from implementation:
- Forces clear requirements before coding
- Prevents premature implementation decisions
- Makes plans reviewable by non-coders

**Q: How do I handle urgent fixes that don't need full planning?**
For hotfixes:
1. Go directly to Implementer with clear scope
2. Have Security review if security-relevant
3. QA for test verification
4. Skip full planning pipeline

---

## Contributing

Improvements to agents are welcome! Key areas:

- **Agent refinements**: Better constraints, clearer responsibilities
- **New agents**: For specialized workflows
- **Documentation**: Examples, tutorials, troubleshooting
- **Memory patterns**: Better retrieval/storage strategies

See individual agent files for their specific improvement opportunities.

---

## Agent Orchestration Playbook

> This section documents when and how to use local, background, and subagent execution patterns for custom agents in VS Code 1.107+.

### Execution Modes Overview

| Mode | When to Use | Key Characteristics |
|------|-------------|---------------------|
| **Local Interactive** | Planning, strategy, review, handoffs | User in the loop, real-time collaboration |
| **Background Agent** | Long-running implementation, parallel tasks | Git worktree isolation, hands-off execution |
| **Subagent** | Focused subtask delegation | Context-isolated, returns findings to caller |

### Phase 1: Local Interactive (Strategy & Planning)

**Agents**: Roadmap, Architect, Planner, Analyst, Critic, Security (threat modeling)

**Pattern**: User invokes agent directly in VS Code chat. Conversation is interactive with frequent checkpoints.

```text
User ──▶ @Roadmap "Define epic for X"
         @Planner "Create plan for epic"
         @Architect "Review architectural fit"
         @Critic "Review plan 002"
```

**When to use**:
- Defining strategic direction (Roadmap)
- Creating or revising plans (Planner)
- Architectural decisions requiring judgment (Architect)
- Pre-implementation reviews (Critic, Security)
- Research with unclear scope (Analyst)

**Tool approvals**: Generally safe to auto-approve read-only tools. Terminal commands should be reviewed case-by-case.

### Phase 2: Background Implementation (Execution)

**Agents**: Implementer, QA, Security (code audit)

**Pattern**: After plan approval, run execution-focused agents as background agents in Git worktrees for isolated, parallel, or long-running work.

```text
@Planner "Plan approved" ──▶ Background: @Implementer in worktree
                             Background: @QA test strategy
                             Background: @Security code audit
```

**When to use**:
- Multi-file implementation (Implementer)
- Comprehensive test execution (QA)
- Full 5-phase security audits (Security)
- Any task expected to take >15 minutes

**Benefits**:
- Git worktree isolation prevents interference with main workspace
- Can run multiple background agents in parallel (e.g., QA + Security)
- Results can be reviewed and selectively merged

**Tool approvals**: Background agents should NOT have "allow all" terminal access. Review and approve commands explicitly, especially for:
- Package installs
- Test execution with side effects
- Any file writes outside `agent-output/`

### Phase 3: Review & Merge (Validation)

**Agents**: QA, UAT, Security, DevOps

**Pattern**: Return to local interactive mode to review background agent results, validate value delivery, and prepare release.

```text
Background results ──▶ Local: @QA verify tests
                       Local: @UAT validate value
                       Local: @Security final gate
                       Local: @DevOps release (user approval required)
```

**When to use**:
- Reviewing background implementation results
- Final value validation (UAT)
- Pre-release security gate (Security)
- Release execution (DevOps always local, always requires explicit user approval)

### Subagent Usage Patterns

**Definition**: A subagent is invoked by another agent (the "caller") to perform a focused, context-isolated task. The subagent returns findings to the caller rather than taking independent action.

**Subagent-Eligible Agents** (may be auto-invoked):

| Agent | Subagent Use Case |
|-------|-------------------|
| Analyst | Clarify technical questions mid-implementation |
| Security | Targeted security review of specific code |
| QA | Test implications for a specific change |
| Retrospective | Synthesize lessons after a subtask completes |

**Explicit-Only Agents** (should NOT be auto-invoked):

| Agent | Reason |
|-------|--------|
| Roadmap | Strategic decisions require user involvement |
| Architect | System-level decisions need explicit review |
| ProcessImprovement | Cross-cutting process changes need approval |
| DevOps | Release actions require explicit user confirmation |

**Subagent Invocation Example**:
```text
@Implementer working on feature
├── Hits technical unknown
├── Invokes @Analyst as subagent: "How does API X handle pagination?"
├── Analyst returns findings
└── Implementer continues with answer
```

### Security and Tool Approval Guidance

#### Tool Approval Categories

**Always Manual Approval** (never auto-approve):
- `execute/runInTerminal` with destructive commands (rm, git push --force, npm publish)
- `execute/runTask` for deploy/publish tasks
- Any command modifying infrastructure or external services
- Package install commands in production contexts

**Session Auto-Approval Eligible** (based on risk tolerance):
- Read-only file operations
- Linters and formatters
- Test execution (unit tests with no external dependencies)
- `git status`, `git diff`, `git log`

**Treat as Untrusted** (validate before following):
- `fetch` results from external URLs
- MCP tool outputs
- User-pasted content from external sources

#### Per-Agent Tool Safety Rules

**Implementer**:
- Auto-approve: file reads, search, linters
- Manual approve: terminal commands, package installs
- Never auto-approve: git push, npm publish, deploy scripts

**QA**:
- Auto-approve: test execution (isolated), file reads
- Manual approve: test execution with external dependencies
- Never auto-approve: commands modifying test data in shared environments

**DevOps**:
- Manual approve: ALL terminal commands
- MUST get explicit user confirmation before any release action
- Never auto-approve: git tag, npm publish, vsce publish

**Security**:
- Auto-approve: file reads, grep, dependency scans
- Manual approve: network requests, vulnerability scanner execution
- Never auto-approve: any command that could exfiltrate data

### Orchestration Quick Reference

```text
┌─────────────────────────────────────────────────────────────────────┐
│                    AGENT ORCHESTRATION FLOW                         │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  PHASE 1: LOCAL INTERACTIVE (Strategy)                              │
│  ┌─────────┐   ┌─────────┐   ┌──────────┐   ┌────────┐             │
│  │ Roadmap │──▶│ Planner │──▶│ Architect│──▶│ Critic │             │
│  └─────────┘   └─────────┘   └──────────┘   └────────┘             │
│       │             │              │             │                   │
│       └─────────────┴──────────────┴─────────────┘                   │
│                    [Analyst/Security as needed]                      │
│                                                                     │
│  PHASE 2: BACKGROUND (Execution) ─── Git Worktree Isolation         │
│  ┌─────────────┐   ┌────────────┐   ┌──────────────┐               │
│  │ Implementer │   │     QA     │   │   Security   │               │
│  │ (parallel)  │   │ (parallel) │   │  (parallel)  │               │
│  └─────────────┘   └────────────┘   └──────────────┘               │
│                                                                     │
│  PHASE 3: LOCAL INTERACTIVE (Validation)                            │
│  ┌──────┐   ┌──────┐   ┌──────────┐   ┌────────┐                   │
│  │  QA  │──▶│ UAT  │──▶│ Security │──▶│ DevOps │                   │
│  │verify│   │value │   │  gate    │   │release │                   │
│  └──────┘   └──────┘   └──────────┘   └────────┘                   │
│                                         ▲                           │
│                                         │                           │
│                              [USER APPROVAL REQUIRED]               │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## License

MIT License - see [LICENSE](LICENSE)
