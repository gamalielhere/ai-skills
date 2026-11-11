---
name: implementation-planning
description: Design a scoped, repository-grounded implementation plan and acceptance criteria for a software feature, fix, or refactor; hand off an approved plan to the integrate skill. Planning is read-only for application code.
---

# Implementation planning

Create a project-aware plan grounded in the actual repository, not a generic checklist. This skill plans only; implementation belongs to `integrate`.

## Workflow

1. Summarize the request, success criteria, constraints, and current behavior. Read repository instructions (`AGENTS.md`, `CLAUDE.md`, README, etc.) and inspect relevant actual files. Be clear and concise when creating a description. Possibly ask the user to decide whether you generate it for a person to read, or to generate it to be fed to an AI agent.
2. Identify affected modules, public interfaces, dependencies, state management, API boundaries, and existing test conventions. Avoid assumptions about languages/frameworks.
3. Identify unanswered questions, risks, and hidden requirements. Ask the user **only for clarifications that affect scope or correctness**, before finalizing the plan. Do not invent answers.
4. Produce an ordered, reasonably sized scope and implementation steps with stable IDs, explicit in/out-of-scope boundaries, and independently testable acceptance criteria.
5. Include a verification matrix: existing unit/integration/e2e commands, manual/browser checks when appropriate, meaningful edge cases, and any unavailable prerequisites. Specify rollback/migration considerations where applicable.
6. Use the handoff schema in `references/handoff-template.md` so `integrate` can pick up this plan unambiguously. Deliver the plan in the conversation; for multi-session handoff, also save it outside the repository under `${XDG_STATE_HOME:-$HOME/.local/state}/ai-skills/runs/<unique-run>/plan.md`, or at the path the user specifies.
7. Mark the plan **DRAFT** and request explicit approval before application code changes, unless the user has already explicitly approved this **particular finalized scope**. Update to **APPROVED** only after real approval. A user invoking `/full-implementation` alone is not approval of an unseen plan.

## Boundaries

- Do not edit project source, project tests, Git refs, or project configuration while in planning-only mode; writing the plan artifact outside the project is permitted.
- Do not create commits, push, move Jira cards, or reset/stash changes without direct instruction.
- If an existing plan is ambiguous or incompatible with the current repository state, stop and request a revision rather than silently adapting its scope.
