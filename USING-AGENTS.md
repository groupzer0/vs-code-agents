# Using the Agents

This file contains a high-level overview of these agents and how to get started using them quickly. However, you may find you want or need more guidance. In that case, see the AGENTS-DEEP-DEIVE.md file.

## Overview

This repo defines a set of `.agent.md` files that configure specialized AI personas ("agents") for a structured software delivery workflow. Each agent focuses on a specific phase or concern (planning, implementation, QA, UAT, DevOps, etc.), with clear responsibilities, constraints, and handoffs.

A typical high-level workflow looks like:

Roadmap → Planner → (Analyst, Architect, Critic, Security) → Implementer → QA → UAT → DevOps → Retrospective → ProcessImprovement

**All agents use Flowbaby memory** via the `memory-contract` skill to provide long-running context across sessions. Agents function without Flowbaby but greatly benefit from its cross-session context. Install the [Flowbaby VS Code extension](https://github.com/groupzer0/flowbaby) to enable memory functions. 

## Where to Put These Files

There are two simple ways to make these agents available to VS Code:

1. **Per-workspace (recommended for a single project)**  
  Place the `.agent.md` files under `.github/agents/` in your repository. They will only apply to that workspace.

2. **Global (available in every workspace)**  
  Place the `.agent.md` files in your VS Code user directory (for example, under an `agents/` folder inside your Code `User` settings directory). They will then be available in all workspaces.

In this repo, the source copies live under `vs-code-agents/`; you can copy or sync from there into `.github/agents/` or your user-level agents folder.

For more guidance on GitHub Copilot agents in VS Code, see the official documentation: https://code.visualstudio.com/docs/copilot/copilot-agents

## Using with GitHub Copilot CLI

These agents were originally written for GitHub Copilot in VS Code, but you can also use them with the GitHub Copilot CLI.

- Place your `.agent.md` files under `.github/agents/` in each repository where you run the CLI.
- Then invoke an agent with a command like:

```bash
copilot --agent planner --prompt "Create a plan for adding user authentication"
```

### Known limitation (user-level agents)

The Copilot CLI has a known upstream bug ([github/copilot-cli#452](https://github.com/github/copilot-cli/issues/452)) where **user-level agents in `~/.copilot/agents/` are not loaded**, even though they are documented. This behavior and workaround were originally reported and documented by @rjmurillo.

**Workaround:**

- Use per-repository agents under `.github/agents/` instead of relying on `~/.copilot/agents/`.
- If you prefer a single source of truth, you can keep your agents in one folder and copy or symlink them into each repo’s `.github/agents/` directory.

Once the upstream bug is fixed, this section can be updated to reflect the restored user-level behavior.

## Customizing Agents

Each `.agent.md` file defines:

- A **description** and **purpose**
- Allowed **tools** (editing files, running tests, using GitHub, etc.)
- **Handoffs** to other agents
- Detailed **responsibilities** and **constraints**

To customize:

- Edit the relevant `.agent.md` file to adjust:
  - Description and Purpose
  - Allowed tools
  - Handoff targets and prompts
- Keep responsibilities and constraints intact unless you intentionally want to change your development process (e.g., Planner must not edit code, QA owns test strategy docs, etc.).

Custom agents give you:

- **Separation of concerns**: planning vs coding vs QA vs UAT vs DevOps
- **Repeatable workflow**: each phase of work is clearly owned by one agent
- **Safety and clarity**: it's explicit who may edit what, and when

---

## Skills

Agents can load **Skills**—modular, reusable instruction sets that provide specialized knowledge on-demand. Skills are stored in the `vs-code-agents/skills/` directory.

### Available Skills

| Skill | Purpose |
|-------|---------|  
| `memory-contract` | Unified Flowbaby memory retrieval/storage contract |
| `architecture-patterns` | ADR templates, patterns, anti-pattern detection |
| `code-review-checklist` | Pre/post-implementation review criteria |
| `engineering-standards` | SOLID, DRY, YAGNI, KISS with detection patterns |
| `release-procedures` | Two-stage release workflow, semver, platform constraints |
| `security-patterns` | OWASP Top 10, language-specific vulnerabilities |
| `testing-patterns` | TDD workflow, test pyramid, coverage strategies |

### Skill Placement

Skills are placed in different directories depending on your VS Code version:

| Version | Location |
|---------|----------|
| **VS Code Stable (1.107.1)** | `.claude/skills/` |
| **VS Code Insiders** | `.github/skills/` |

> [!NOTE]
> These locations are changing with upcoming VS Code releases. The `.github/skills/` location is becoming the standard. Check the [VS Code Agent Skills documentation](https://code.visualstudio.com/docs/copilot/customization/agent-skills) for the latest guidance.

---

## Agent-by-Agent Guide

### Roadmap – Product Vision & Epics

**Role**: Owns product vision and outcome-focused epics, maintains the product roadmap.

**Use when**:
- Defining or revising product direction and epics
- Checking if a plan/feature still aligns with the Master Product Objective

**Example handoff prompts**:
- To Architect: "Epic requires architectural assessment and documentation before planning."
- To Planner: "Epic is ready for detailed implementation planning."

**Tips**:
- Talk about **user outcomes and business value**, not implementation details.
- Use Roadmap to sanity-check that a proposed change is actually worth building.

---

### Planner – High-Rigor Implementation Planning

**Role**: Turns roadmap epics into concrete, implementation-ready plans (WHAT/WHY, not HOW).

**Use when**:
- You have a feature/epic and need a structured plan before coding.
- Requirements or scope need to be clarified and broken into milestones.

**Example handoff prompts**:
- To Roadmap: "Validate that plan delivers epic outcomes defined in roadmap."
- To Architect: "Please review this plan to ensure it aligns with the architecture."
- To Analyst: "I've encountered technical unknowns that require deep investigation. Please analyze."
- To Critic: "Plan is complete. Please review for clarity, completeness, and architectural alignment."

**Tips**:
- Expect a **Value Statement** like: "As a [user] I want [objective] so that [value]."
- Planner writes **no code** and defines **no test cases**; it shapes the work for others.

---

### Analyst – Deep Technical/Context Research

**Role**: Investigates unknowns, APIs, performance questions, and tricky tradeoffs.

**Use when**:
- The Planner or Implementer hits technical uncertainty.
- You need API experiments, benchmarks, or comparative analysis.

**Example handoff-style prompts**:
- From Planner: "I've encountered technical unknowns that require deep investigation. Please analyze."
- From Implementer: "I've encountered technical unknowns during implementation. Please investigate."

**Tips**:
- Use Analyst to **de-risk decisions** before committing to an approach.
- Expect analysis docs that other agents then consume—not direct code changes.

---

### Architect – System & Design Decisions

**Role**: Maintains architecture, patterns, boundaries, and high-level design decisions.

**Use when**:
- A feature affects system structure, boundaries, or cross-cutting concerns.
- You need ADRs or architectural guidance for a plan.

**Example handoff prompts**:
- From Roadmap: "Epic requires architectural assessment and documentation before planning."
- From Planner: "Please review this plan to ensure it aligns with the architecture."
- From Retrospective: "Retrospective reveals architectural patterns that should be documented."

**Tips**:
- Use Architect to define **where** things live and how they interact, not the exact code.
- Have Architect bless or adjust big structural changes before coding.

---

### Critic – Plan Reviewer & Program Manager

**Role**: Critically reviews plans (and sometimes architecture/roadmap) before implementation.

**Use when**:
- A plan is "done" and you need a quality gate before implementation.

**Example handoff prompts**:
- To Planner: "Please revise the plan based on my critique findings."
- To Analyst: "Plan reveals research gaps or unverified assumptions. Please investigate."
- To Implementer: "Plan is sound and ready for implementation. Please begin implementation now."

**Tips**:
- Expect structured critiques focusing on **clarity, completeness, scope, and alignment**, not code style.
- Treat Critic as your pre‑implementation "red team" for plans.

---

### Implementer – Coding & Tests

**Role**: Writes and modifies code, implements the approved plan, and ensures tests exist and pass.

**Use when**:
- The plan has been approved and you’re ready to make code changes.
- You need to fix implementation issues uncovered by QA/UAT.

**Example handoff prompts**:
- To Analyst: "I've encountered technical unknowns during implementation. Please investigate."
- To Planner: "The plan has ambiguities or conflicts. Please clarify."
- To QA: "Implementation is complete. Please verify test coverage and execute tests."

**Tips**:
- Provide the **plan file path** and any existing analysis/architecture links.
- Expect the Implementer to: update code and tests, run tests, and produce an implementation doc—without editing QA/UAT docs directly.

---

### QA – Testing Strategy & Execution

**Role**: Designs test strategy, ensures coverage, and runs tests to validate technical quality.

**Use when**:
- You need a test plan before implementation.
- Implementation is done and you want a thorough technical test pass.

**Example handoff prompts**:
- To Planner: "Testing infrastructure is missing or inadequate. Please update plan to include required test frameworks, libraries, and configuration."
- To Implementer: "Implementation has test coverage gaps or test failures. Please address."
- To UAT: "Implementation is completed and QA passed. Please review."

**Tips**:
- QA focuses on **tests, coverage, and technical risk**, not business value.
- Use QA to design/execute tests and verify they’re meaningful, not just green.

---

### UAT – Product Owner / Value Validation

**Role**: Validates that implementation delivers the plan’s **value statement** and user outcomes.

**Use when**:
- QA is complete and you want to confirm that the feature actually solves the intended problem.

**Example handoff prompts**:
- To Planner: "Implementation does not deliver stated value. Plan revision may be needed."
- To Implementer: "Implementation has gaps in value delivery. Please address UAT findings."
- To DevOps: "Implementation complete with release decision. Please manage release steps."

**Tips**:
- UAT reads the plan’s value statement and **assesses code against that**, not just tests.
- Expect a clear decision: **APPROVED FOR RELEASE** or **NOT APPROVED**, with evidence.

---

### DevOps – Packaging & Release

**Role**: Ensures packaging/versioning is correct and executes releases (with explicit user approval).

**Use when**:
- QA and UAT are complete and you’re ready to prepare/publish a release.

**Example handoff prompts**:
- To Implementer: "Packaging issues or version mismatches detected. Please fix before release."
- To Retrospective: "Release complete. Please capture deployment lessons learned."

**Tips**:
- DevOps checks versions, packaging, tags, registry publish, etc.
- It **must** ask you for a final "yes" before releasing.

---

### Security – Security Audits & Guidance

**Role**: Security specialist reviewing plans and code for vulnerabilities and compliance.

**Use when**:
- A feature touches sensitive data, auth, or external interfaces.
- You want a targeted security audit or threat model.

**Example handoff prompts**:
- To Analyst: "Security finding requires deep technical investigation."
- To Planner: "Security risks require plan revision."
- To Implementer: "Security remediation requires code changes."

**Tips**:
- Use Security early (during planning/architecture) and again after implementation.
- Expect reports with prioritized risks and concrete remediation guidance.

---

### Retrospective – Lessons Learned

**Role**: Runs post‑implementation/post‑release retrospectives focusing on process, not blame.

**Use when**:
- A plan/feature has gone through QA, UAT, and (optionally) deployment.
- You want to understand what went well/poorly in your **workflow**.

**Example handoff prompts**:
- To Architect: "Retrospective reveals architectural patterns that should be documented."
- To Planner: "Retrospective identifies process improvements for future planning."
- To Roadmap: "Retrospective is closed for this plan. Please update the roadmap accordingly."

**Tips**:
- Use this to feed continuous improvement, not to fix code.
- Expect structured retrospectives and clear process-improvement candidates.

---

### ProcessImprovement – Evolving Agents & Workflow

**Role**: Reads retrospectives and updates the **agent instructions/workflow** (with your approval).

**Use when**:
- You have retrospectives and want to evolve how the agents work together.

**Example handoff prompt**:
- To Planner: "Previous work iteration is complete. Ready to start something new."

**Tips**:
- This is the only agent that should routinely edit `.agent.md` files (after you approve changes).
- Use it to keep your multi‑agent workflow sharp and aligned with real-world lessons.

---


## Putting It All Together

- Start with **Roadmap** for vision, then **Planner** for a concrete plan.
- Use **Architect / Analyst / Security / Critic** to refine and de‑risk the plan and architecture.
- Hand off to **Implementer** for code and tests, then **QA** for technical quality, **UAT** for value, **DevOps** for release.
- Afterward, let **Retrospective** and **ProcessImprovement** update how you work next time.
- **All agents use Flowbaby memory** via the `memory-contract` skill. Agents function without Flowbaby but greatly benefit from its cross-session context.
