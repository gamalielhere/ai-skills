---
name: cleanup
description: Review a Git working tree or an explicitly selected branch diff with Ponytail review and Pstack unslop, then optionally coordinate agents to make approved, behavior-preserving cleanup edits. Default is read-only. Invoke as /cleanup in Claude Code or $cleanup in Codex.
argument-hint: "[--base BRANCH] [--apply] [--scope PATH]"
disable-model-invocation: true
---

# Cleanup: independent review first, controlled edits second

This skill is a coordinator, not a substitute for the actual upstream skills. The upstream instructions **must be read and applied** from the installed global skills paths before issuing findings or changes. Do not claim a framework ran if its instructions were unavailable.

## Arguments and defaults

- `/cleanup` -> review only (do not edit ANY files).
- `/cleanup --base <branch>` -> review the changes relative to that **explicit** base, plus currently uncommitted changes. Never assume `main`, `master`, or any other base.
- `/cleanup --scope <path>` -> limit review/edits to that path after checking its relationship to the Git root.
- `/cleanup --apply` -> request implementation, but **still propose a cleanup plan and obtain explicit approval before writing**.
- `/cleanup --base <branch> --apply` -> same behavior with selected comparison branch.

If a user asks to compare branches but did not supply a base, ask for the base instead of guessing it. If no base is given and no branch comparison is requested, inspect only staged, unstaged, and untracked working-tree changes. Never claim that working-tree changes represent the entire branch.

## Prerequisites: load actual upstream skills

Find these files by trying the host's personal skills directory (`~/.claude/skills/` for Claude Code, `~/.agents/skills/` for Codex):

1. `ponytail-review/SKILL.md` — the *primary* code review rubric; also read `ponytail/SKILL.md` for minimal-change principles if available.
2. `unslop/SKILL.md` — Pstack's **writing** cleanup rubric. Its application is limited to prose, documentation, comments, and user-facing explanatory text, **not** source-code structure or semantics.
3. `thermo-nuclear-review/SKILL.md` and/or `thermo-nuclear-code-quality-review/SKILL.md` — optional extra independent checks when risk or complexity justifies them.
4. `verification-before-completion/SKILL.md` — Superpowers' verification rubric, if available.

If Ponytail review or Pstack unslop is missing, explain which prerequisite is missing and stop. Suggest `~/workspace/ai-skills/scripts/setup.sh` or the actual directory where this skills repo lives. Do not silently use a made-up summary in place of a missing skill. If a skill's requested platform-specific feature is absent (hooks, agent presets), adapt only the Markdown instructions that can run in the host.

## Step 1: establish scope and guard the working tree

- Confirm the current directory is in a Git repository (`git rev-parse --show-toplevel`). Read `git status --short` and the current branch without changing it.
- For default scope, review `git diff --no-ext-diff`, `git diff --cached --no-ext-diff`, and the contents of *relevant* untracked, non-binary source/docs files; account for worktree changes, including staged work.
- For `--base BRANCH`, first check `git rev-parse --verify --end-of-options "BRANCH^{commit}"` (quote user-supplied branch names safely). Inspect the committed range with `git diff --no-ext-diff BRANCH...HEAD` **and** the current staged/unstaged changes. Do not use a guessed base, reset branches, change checkout, stash, or discard changes.
- Honor `--scope` for all reviews. Never include untracked binary files or secret/config credential contents in agent prompts. Summarize oversized diffs by bounded, targeted file reads, noting omissions.
- Record the initial `git status --short` and impacted file set. Preserve unrelated work and existing user changes throughout.

## Step 2: independent read-only analysis

Delegate via **native subagent tools if available**. For independent reviews, prefer two parallel *read-only* agents; if there is no subagent capability, run two explicitly separate rubric passes and disclose that these were not independent agents.

- **Reviewer A — Ponytail:** Read the installed `ponytail-review/SKILL.md` (and `ponytail/SKILL.md` if available). Evaluate the scoped diff with connected callers, tests, error paths, security, maintainability, and whether each line is needed. Report specific findings with severity, precise file/line, evidence, suggested minimal change, and regression risk. No edits.
- **Reviewer B — Pstack unslop:** Read the installed `unslop/SKILL.md`. Review *only prose* in the scoped changes: comments, docs, copy, inline guidance and generated descriptions. Suggest concrete rewrites consistent with its pattern rules. Keep technical meaning, API names, and necessary defensive explanations. No edits.
- **Optional reviewer C — Thermos:** Read the local thermo-nuclear review skill(s) for correctness/security and structural risks if the scope is nontrivial. No edits.

All reviewers must be told the **same base/scope and latest repository state**. Do not ask reviewers to rewrite source code in review mode. Keep independent review findings separate before synthesis. If an independent reviewer fails or is unavailable, note it; do not claim independent agreement.

## Step 3: consolidate and present a plan

Return one deduplicated report:

1. Correctness/security/test findings (if any), with supporting evidence.
2. Minimal behavior-preserving code cleanup proposals from Ponytail, with impact/risk.
3. Pstack unslop prose-only edits, if applicable; write "No prose issues" otherwise.
4. Optional Thermos findings, with their source.
5. Proposed **files to change**, tests/commands to run, and boundaries not to touch.

**Default STOP:** `/cleanup` ends here with no files changed. Even if a reviewer suggests refactoring, reviewers are advisory and read-only.

**Apply gate:** If `--apply` was requested or the user later asks to apply the report, first show the proposed edit scope and obtain explicit approval to modify those files. A previous read-only review is not approval. The user can approve selected findings only; never apply rejected changes.

## Step 4: apply approved edits with one writer agent

Only after approval:

- Dispatch **one implementation agent** to make the selected fixes, respecting original code semantics and user edits. Other agents must remain read-only. If native subagents are unavailable, implement directly and disclose that limitation.
- Minimize churn. Do not remove necessary validation, tests, or security controls merely to reduce line count. Unslop only edits prose/comments; Ponytail's review guides source cleanup.
- Avoid creating temporary worktrees unless specifically requested; don't clean up preexisting worktrees. Never commit, push, merge, reset, delete files broadly, or change Jira statuses without a separate explicit request.
- Stop and re-plan if the required edits go beyond approved files/scope, if `git status` changes unexpectedly, or if any reviewer recommends altering behavior.

## Step 5: independent verification

Run the project's relevant, available tests, lint, type checks, and/or build based on the actual code touched. Before claiming success, review `git diff --check`, relevant changes and `git status --short` against the initial baseline. If available, run a *different*, read-only verification agent using Ponytail or Thermos on the completed diff, and consult `verification-before-completion` instructions. Report what really ran, what failed, and what was skipped; do not make unverified guarantees.

Return a short change summary with file names, tests performed and results, remaining issues, and whether independent agent review ran. Leave changes uncommitted.

See [agent contracts](references/agent-contracts.md) for role prompts and common constraints.
