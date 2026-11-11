---
name: qa-testing
description: Validate a software change against acceptance criteria, including targeted automated tests and browser-based flows when an available test environment permits. Use when the user requests QA, regression validation, or a test plan.
---

# QA testing

## Workflow

1. Identify acceptance criteria and relevant changed behavior.
2. Discover the repository's existing test commands, test data, fixtures, and local application setup.
3. Create a test matrix: happy path, error states, boundaries, accessibility, and regressions.
4. Run safe, feasible checks. Use browser automation only if the environment and application are available and authorized.
5. Record steps to reproduce failures and exact observed versus expected results.
6. Summarize passed, failed, blocked, and untested scenarios separately.

## Boundaries

- Never claim a browser flow passed without exercising it.
- Do not make destructive changes to production or live data.
- Do not commit files or move tickets without explicit permission.
