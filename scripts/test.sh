#!/usr/bin/env bash
# Offline smoke tests, with fake external checkouts. Does not touch real HOME.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
TEST_HOME="$(mktemp -d)"
MOCKS=()
cleanup() {
  local key
  export HOME="$TEST_HOME"
  "$SCRIPT_DIR/uninstall.sh" >/dev/null 2>&1 || true
  for key in "${MOCKS[@]}"; do rm -rf "$REPO_ROOT/external/$key"; done
  rmdir "$REPO_ROOT/external" 2>/dev/null || true
  rm -rf "$TEST_HOME"
}
trap cleanup EXIT
export HOME="$TEST_HOME"

# Create synthetic source skills only if no actual clone is present.
while IFS=$'\t' read -r key url subdir; do
  if [[ ! -e "$REPO_ROOT/external/$key" ]]; then
    MOCKS+=("$key")
    mkdir -p "$REPO_ROOT/external/$key/$subdir/test-$key"
    printf '%s\n' '---' "name: test-$key" "description: test skill from $key" '---' "# Test $key" > "$REPO_ROOT/external/$key/$subdir/test-$key/SKILL.md"
  fi
done < <(sources)

"$SCRIPT_DIR/install.sh" >/dev/null
[[ -L "$HOME/.claude/skills/cleanup" && -L "$HOME/.agents/skills/cleanup" ]]
# The two workflow skills must be globally discoverable and resolve to local source files.
for skill in full-implementation integrate implementation-planning code-review qa-testing; do
  for agent in .agents .claude; do
    [[ -L "$HOME/$agent/skills/$skill" ]]
    [[ -f "$HOME/$agent/skills/$skill/SKILL.md" ]]
  done
done
[[ -f "$HOME/.claude/skills/integrate/references/agent-contracts.md" ]]
[[ -f "$HOME/.agents/skills/implementation-planning/references/handoff-template.md" ]]
[[ -f "$HOME/.claude/skills/cleanup/SKILL.md" ]]
while IFS=$'\t' read -r key url subdir; do
  [[ -d "$REPO_ROOT/external/$key/$subdir" ]]
  found=0
  for file in "$REPO_ROOT/external/$key/$subdir"/*/SKILL.md; do
    [[ -f "$file" ]] || continue
    name="$(basename "$(dirname "$file")")"
    if [[ -L "$HOME/.agents/skills/$name" && -L "$HOME/.claude/skills/$name" ]]; then found=1; break; fi
  done
  (( found == 1 )) || { echo "No linked skill from $key" >&2; exit 1; }
done < <(sources)
"$SCRIPT_DIR/doctor.sh" >/dev/null
"$SCRIPT_DIR/install.sh" >/dev/null # idempotent
# Verify existing user-created files are never overwritten.
mkdir -p "$HOME/.agents/skills"
printf 'owned by user\n' > "$HOME/.agents/skills/owner-guard"
"$SCRIPT_DIR/install.sh" >/dev/null
[[ "$(cat "$HOME/.agents/skills/owner-guard")" == 'owned by user' ]]
"$SCRIPT_DIR/uninstall.sh" >/dev/null
[[ -f "$HOME/.agents/skills/owner-guard" ]]
[[ ! -e "$HOME/.agents/skills/cleanup" && ! -L "$HOME/.agents/skills/cleanup" ]]
[[ ! -e "$HOME/.claude/skills/cleanup" && ! -L "$HOME/.claude/skills/cleanup" ]]
[[ ! -e "$HOME/.claude/skills/full-implementation" && ! -L "$HOME/.claude/skills/full-implementation" ]]
[[ ! -e "$HOME/.agents/skills/integrate" && ! -L "$HOME/.agents/skills/integrate" ]]
echo 'Offline smoke tests passed. No real user skill directories were touched.'
