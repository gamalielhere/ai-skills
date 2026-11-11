#!/usr/bin/env bash
# Lightweight built-in validation for the locally composed implementation workflow.
# No network, no coding agents, no modifications to application repositories.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
for skill in implementation-planning integrate full-implementation code-review qa-testing; do
  file="$REPO_ROOT/skills/$skill/SKILL.md"
  [[ -f "$file" ]] || { echo "Missing $file" >&2; exit 1; }
  grep -q "^name: $skill$" "$file" || { echo "Invalid skill name: $skill" >&2; exit 1; }
  grep -q '^description: ' "$file" || { echo "Missing description: $skill" >&2; exit 1; }
done
[[ -f "$REPO_ROOT/skills/integrate/references/agent-contracts.md" ]]
[[ -f "$REPO_ROOT/skills/implementation-planning/references/handoff-template.md" ]]
for phrase in 'implementation-planning' 'integrate' 'explicit approval'; do
  grep -iq -- "$phrase" "$REPO_ROOT/skills/full-implementation/SKILL.md"
done
for phrase in 'code-review' 'qa-testing' 'Both PASS' 'max-rounds' 'BLOCKED'; do
  grep -q -- "$phrase" "$REPO_ROOT/skills/integrate/SKILL.md"
done
printf '%s\n' 'Local skill workflow metadata and handoff checks passed.'
