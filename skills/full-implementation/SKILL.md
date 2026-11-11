---
name: full-implementation
description: End-to-end approved software delivery: use implementation-planning to scope a change, ask for approval, then hand off to integrate for implementation and repeated code-review plus qa-testing. Invoke explicitly for a full feature or bugfix workflow.
argument-hint: "[--base REF] [--max-rounds N] <task>"
disable-model-invocation: true
---

# Full implementation — planning, approval, integration, verification

Use `/full-implementation` in Claude Code or `$full-implementation` in Codex to coordinate the **local** `implementation-planning` and `integrate` skills. This is an orchestrating skill; do not perform a superficial planning summary and claim the other skills ran.

## Inputs

- The feature, bug, or refactor request from the invoking message (including any supplied issue link/details).
- Optional `--base <ref>`: an **explicit** Git comparison reference for branch-level context; never default to `main`/`master`. Even without a base, review implementation-specific changes.
- Optional `--max-rounds <1..10>`: cap for review/QA → fixes → re-review cycles (default **5**).
- Optional `--plan <path>`: use a prior plan instead of creating a new one, but inspect it and verify approval before proceeding.

If multiple repositories or incompatible requirements are plausible, ask a focused question. Otherwise inspect the working repository and proceed.

## Phase A — load and run implementation-planning

1. Locate and read the **installed local** `implementation-planning/SKILL.md` and its `references/handoff-template.md` under the current agent's user skills directory (`~/.claude/skills` or `~/.agents/skills`). If missing, stop and give the installation fix; do not invent the child skill's content.
2. Invoke the child skill through the host's supported skill invocation mechanism if available; otherwise **explicitly follow the child's instructions**, state that nested invocation was unavailable, and do not imply it was separately invoked.
3. Inspect the project and produce the complete scoped plan using the handoff contract: `AC-*` acceptance criteria, `STEP-*` implementation steps, verification commands, in/out-of-scope boundaries, risks, unresolved questions, and comparison-base provenance.
4. Resolve blocking scope questions with the user. If the answers change the plan, revise it before seeking approval.
5. Share the plan, including any limitations, and request **explicit approval of this scope** before editing project code. Do not infer approval simply because the user invoked `/full-implementation`.
6. Mark the approved handoff `Status: APPROVED` and `Approved by user: yes`, and preserve the plan in the current conversation. For resumed work or cross-session `/integrate`, save a durable plan at a user-specified path or `${XDG_STATE_HOME:-$HOME/.local/state}/ai-skills/runs/<unique-run>/plan.md` (never require adding files to the project repository).

**Stop here until the approval is provided.** If the user already supplied an explicitly approved, unambiguous plan for the current repo, skip repeated approval and continue.

## Phase B — hand off to integrate

1. Locate and read the installed `integrate/SKILL.md` and its agent contracts. Invoke it using a native skill mechanism if supported, or execute its exact instructions in this coordinator context and disclose that fallback.
2. Pass the **approved plan**, its file path (if saved), current repository root, optional explicit `--base`, `--max-rounds`, and user constraints. Do not send only a one-line summary.
3. `/integrate` is responsible for all writes, independent reviews, QA, feedback loops and convergence criteria. Do not run a redundant parallel implementation loop here.
4. Surface any clarifying question, QA/environment blocker, conflicting change, risky scope expansion, or exhausted iteration budget to the user. Continue only after clarification or renewed scope approval.

## Completion report

Report: plan and original scope, touched files, acceptance criteria evidence, `code-review` status, `qa-testing` status, review rounds, commands run and results, any limitations, and final `PASS` / `BLOCKED` / `NEEDS_INPUT` / `FAILED` state. **Do not claim completion unless both independently reported PASS for the final change set.**

## Safety and authority

- Follow repository instructions and existing user edits. No unrequested commits, pushes, branch resets, destructive cleanup, deployment, production data mutations or Jira status changes.
- Prefer a dedicated writing agent and independent read-only reviewers; if native subagents are unavailable, use clearly separated passes and disclose that reviewers were not independent.
- Never hide failed tests or override a gate to produce a success message.
