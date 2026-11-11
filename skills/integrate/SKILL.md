---
name: integrate
description: Implement a previously approved implementation-planning handoff, then iterate between code-review and qa-testing findings and targeted fixes until both pass or a stated stop condition is reached. Can run standalone or from full-implementation.
argument-hint: "[--plan PATH] [--base REF] [--max-rounds N]"
disable-model-invocation: true
---

# Integrate — implement, independently review, verify, repeat

`/integrate` in Claude Code or `$integrate` in Codex consumes the output of `implementation-planning`. It is a controlled implementation coordinator, **not** a generic request to edit files without a plan.

Read `references/agent-contracts.md` for delegation and PASS/FAIL/BLOCKED criteria before starting.

## Inputs and validation

- `--plan <path>`: approved Markdown plan saved by `implementation-planning`. Otherwise use the unambiguous approved plan in the active conversation; if none is available, ask the user for a plan/path or offer to run `implementation-planning`. Do not choose an unrelated prior plan based on filename/date alone.
- `--base <ref>`: optional explicit comparison ref. Do not assume `main`, `master`, or current branch origin. If supplied, validate that ref before using it.
- `--max-rounds <1..10>`: maximum review/QA rounds; default **5**. A limit prevents infinite agent recursion. Incomplete work at the limit is **NOT PASS**.
- An approved handoff must identify the repository, concrete in/out scope, AC IDs, implementation steps, verification plan, and actual user approval. Confirm the plan applies to the current repository and hasn't become stale; otherwise stop with a clarification request.
- If a critical requirement is missing, or a reviewer proposes material scope expansion or behavior change, clarify with the user and **revise/reapprove** the plan before continuing.

## 1. Prepare and protect the working tree

1. Read repository instructions and verify the Git root. Inspect `git status --short`, current branch, and existing code/tests. Never silently stash, checkout, reset or discard user changes.
2. Establish a **pre-implementation baseline**: capture initial tracked diff (staged and unstaged), untracked-file names, and relevant file contents/areas, without copying secrets. Record the approved scope and file set separately. For a clean tree, the subsequent diff is attributable to this run. For a dirty tree, track only edits this run makes; if edits overlap user changes and cannot be separated safely, request direction rather than guessing.
3. If supplied a branch comparison ref, validate it (e.g. `git rev-parse --verify --end-of-options "<ref>^{commit}"`) and use it **only as explicitly requested**. A branch comparison is not a substitute for identifying this run's changed lines.
4. Optionally store plan/review/QA run logs outside the target Git repository at `${XDG_STATE_HOME:-$HOME/.local/state}/ai-skills/runs/<unique-run>/`. Avoid leaking secret values into prompts or artifacts.
5. Establish current AC coverage and a task ledger keyed to the plan's `STEP-*` IDs. Do not change project files outside the approved scope except necessary tests or fixes within scope.

## 2. Implement the plan

1. Load the installed `implementation-planning/SKILL.md` to confirm the handoff contract, then follow the approved `STEP-*` ordering and repo patterns.
2. Use **one writing agent at a time**; native coding/delegation subagents are preferred if available. Implement the steps in manageable units, updating or adding appropriate tests. If subagent support is absent, implement directly and state this in the final report.
3. Run quick checks during implementation where safe. Do not declare success from these checks alone.
4. Keep track of files changed and any original edits that must be preserved. Never automatically commit, push, merge, deploy, or move Jira tickets.

## 3. Review + QA gate (required on every round)

**Always load the actual installed local `code-review/SKILL.md` and `qa-testing/SKILL.md` on each run.** If a tool supports direct child skill invocation, use it; otherwise load their instructions and execute them as two explicitly separate roles. Do not claim independent reviewers or native skill invocation when the runtime did not provide them.

For each round (up to `--max-rounds`, default 5):

1. **Freeze a logical review snapshot**: identify the current implementation-owned diff and changed files, associated AC IDs, and tests. Avoid including unrelated preexisting modifications. Do not let reviewer/QA agents edit source.
2. **Code-review pass** (review-only agent): review the implementation-owned diff with callers/tests using `code-review`'s correctness, security, regression, maintainability, and missing-test rubric. Explicitly tell the reviewer the exact review scope and whether `--base` was supplied. Produce `PASS`, `FAIL` or `BLOCKED`, with evidence, severity, file/line and fix suggestion for failures. Do not fake a branch base.
3. **QA-testing pass** (independent read-only agent): run test/build/lint/typecheck commands required by the plan and repo, plus manual/browser flows when available and authorized. Verify *each* `AC-*`, including key negative/regression cases. Return `PASS`, `FAIL` or `BLOCKED`, with commands, observed outputs, repro steps, and untested items. No live-production destructive testing.
4. Review and QA can run **in parallel only if both are read-only and inspect the same snapshot**. Otherwise run sequentially. Wait for **both** results before deciding.
5. **Both PASS on the same final snapshot** → deliver success summary and stop. The absence of findings is not a substitute for exercised acceptance checks. Unrun required tests must be marked `BLOCKED` rather than `PASS`.
6. If either is `FAIL`, deduplicate findings, map each to AC/STEP, assign the writing agent targeted fixes, and then **rerun both review and QA** against the new snapshot. Never merely ask the previously failing reviewer to recheck and reuse the other agent's stale PASS.
7. If either is `BLOCKED` (unavailable services, permission, required credentials, unresolvable conflict, unclear acceptance) request the missing detail/access or stop with an honest `BLOCKED` report. Do not manufacture passing results. If the user approves a new verification plan, update and reapprove the handoff, then resume.
8. If changes introduce new requirements, unsafe side effects, destructive migrations, or work beyond approved scope, stop and obtain plan revision/approval before further edits.
9. If the issue persists after the configured max rounds, **stop** with `FAILED` or `NEEDS_INPUT`. Summarize what was tried, unresolved problems, and next decisions; do not keep looping or auto-approve.

## 4. Finalization

- After a successful gate, recheck `git status --short` and the implementation-owned diff; if it changed since reviewers' snapshot, run the gate again (subject to the same round limit).
- Provide final plan/AC coverage and evidence: modified files, key implementation details, review-round count, final review verdict, final QA verdict, exact commands/results, any untested areas, and unresolved warnings. Distinguish `PASS`, `BLOCKED`, `FAILED`, and `NEEDS_INPUT`.
- Preserve all unrelated user work. Do not commit, push or move Jira issues unless explicitly asked.

## Tooling caveat

These are **instruction-based skills**. They coordinate using the coding agent's actual tools and optional native subagents; installing `SKILL.md` files alone is not a background worker, CI engine, or guaranteed parallel-agent runtime. If native reviewers are missing, say so and use separate passes; never label a simulated pass as an independent agent.
