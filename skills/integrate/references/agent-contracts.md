# Integrate — agent contracts and convergence gate

## Handoff

The implementing agent receives: full approved plan, Git root, any explicit base reference, baseline status and relevant original changes, exact in/out scope, `AC-*` and `STEP-*` IDs, safety restrictions, and known test commands. Do not supply only a narrative summary. The implementer alone edits source.

## Review-only code-review agent

Instructions: Read and apply the currently installed `code-review/SKILL.md`. Review **only implementation-owned edits** plus relevant surrounding behavior; use a supplied comparison base for additional context without widening scope. Report concrete issues with severity, path:line, evidence, regression consequence and fix. Do not edit files. Output:

```text
CODE_REVIEW_VERDICT: PASS | FAIL | BLOCKED
REVIEWED_SNAPSHOT: <paths/diff identifier or recorded timestamp>
FINDINGS: <actionable list or none>
COVERAGE_LIMITATIONS: <any unreviewed files or inaccessible context>
```

- PASS means no blocking correctness, security, or functional issues found in the reviewed final snapshot. Minor nonblocking issues must be disclosed.
- FAIL means one or more actionable blocking defects were observed.
- BLOCKED means required source/diff context is unavailable or reviewer could not execute.

## Review-only qa-testing agent

Instructions: Read and apply `qa-testing/SKILL.md`; evaluate **every AC ID** against observed outcomes, execute reasonable test commands in a safe environment, record actual exit status and browser interactions. Do not edit source. Output:

```text
QA_VERDICT: PASS | FAIL | BLOCKED
TESTED_SNAPSHOT: <same snapshot identifier as code-review>
AC_RESULTS: AC-01 PASS/FAIL/BLOCKED ...
COMMANDS_AND_RESULTS: <exact commands, results, limitations>
REGRESSION_CHECKS: <passed/failed/blocked>
REPRO: <steps and observed/expected for failures>
```

- PASS means **all required acceptance criteria and essential regression checks were exercised and passed**, with actual evidence.
- FAIL means at least one required check genuinely failed.
- BLOCKED means one or more required checks could not be run, or necessary evidence is unavailable. Do not downgrade required checks to optional solely to claim PASS.

## Writing agent repair contract

Receive consolidated review and QA findings, their evidence, original plan boundaries, and snapshot ID. Fix only the concrete problems while preserving unrelated work and acceptance behavior. Add regression tests when needed. After changes, **invalidate both previous verdicts** and submit the fresh snapshot for a full review+QA round.

## Orchestration state machine

```text
UNAPPROVED PLAN -> NEEDS_INPUT (no project code changes)
APPROVED PLAN -> IMPLEMENT -> REVIEW_AND_QA
REVIEW_AND_QA -> PASS           (review PASS and QA PASS, same snapshot)
REVIEW_AND_QA -> FIX -> REVIEW_AND_QA  (any FAIL; rounds remaining)
REVIEW_AND_QA -> BLOCKED        (missing permissions, test environment, etc.)
REVIEW_AND_QA -> NEEDS_INPUT    (scope change or clarifications)
REVIEW_AND_QA -> FAILED         (max-rounds reached without both PASS)
```

Default is 5 gate rounds, maximum 10 if requested. Never run an unlimited loop, claim PASS from a tool that was never available, or apply unapproved scope changes.
