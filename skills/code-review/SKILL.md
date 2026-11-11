---
name: code-review
description: Review an existing set of code changes for correctness, bugs, regressions, security issues, and missing tests. Use when asked to review a branch, diff, or pull request; do not use to implement changes.
---

# Code review

Review the actual diff and relevant surrounding code. Focus on actionable issues.

## Workflow

1. Identify the requested change and the comparison target. **Never assume `main` is the base branch.** If the user has not provided a reference branch, ask for one before doing a branch-to-branch review.
2. Inspect the diff relative to the provided reference (prefer the merge base if appropriate), and trace significant changes into their callers and tests.
3. Check correctness, regressions, edge cases, data handling, security, performance, and test coverage.
4. Run feasible read-only checks when available; clearly report what was and was not run.
5. Present findings ordered by severity, with file and line references, consequence, and a concrete suggested fix.
6. If no issues are found, say so plainly and mention important coverage gaps or uncertainties.

## Boundaries

- Review only: do not change files, create commits, or move Jira tickets unless explicitly instructed.
- Do not claim tests passed if they were not run.
- Do not manufacture findings merely to fill a list.
