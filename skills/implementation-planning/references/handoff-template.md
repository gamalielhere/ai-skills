# Implementation plan handoff contract

`/implementation-planning` produces this Markdown structure for `/integrate`. Keep the section headers and stable IDs; the content is filled from actual repository inspection. This is a template, **not** an approved plan.

```markdown
# Implementation Plan: <short objective>

## Metadata
- Status: DRAFT  # changed to APPROVED only after explicit user approval
- Plan ID: <slug or unique identifier>
- Repository: <absolute Git worktree root>
- Created: <date>
- Comparison base: <explicit ref, or "none: review implementation-only changes">
- Request: <original request or issue URL/ID if already provided>

## Objective
<What success means>

## In scope
- ...

## Out of scope
- ...

## Acceptance criteria
- AC-01: <observable behavior + expected result>
- AC-02: ...

## Repository context
- <relevant modules and observed conventions; cite actual paths>

## Implementation steps
- STEP-01: <files/areas, changes, associated AC IDs>
- STEP-02: ...

## Verification plan
- <exact available commands and relevant tests, plus manual/browser checks>
- <note any checks that cannot run with current setup>

## Risks and safeguards
- <migration, backwards compatibility, security, rollback, environment>

## Clarifications
- <answered questions; unresolved blocking questions MUST be settled before APPROVED>

## Approval
- Approved by user: no
- Approved scope: <scope summary; fill on approval>
```

Rules:
- A plan is ready to implement only if `Status: APPROVED` and `Approved by user: yes` represent real approval in the current conversation or documented handoff. Never self-approve.
- Never invent an approved plan or retroactively add scope. If the user changes the scope, revise the plan and seek approval for the change.
- If the plan is carried between sessions, keep a saved file under `${XDG_STATE_HOME:-$HOME/.local/state}/ai-skills/runs/<unique-run>/plan.md`, or use a user-selected path. Plans do not need to live inside the project repository.
- `/integrate` can accept the plan from the active conversation, a pasted plan, or `--plan PATH`; if provenance or approval is unclear, ask.
