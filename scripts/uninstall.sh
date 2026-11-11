#!/usr/bin/env bash
# Unlink only symlinks owned by this repository. Never delete source trees.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
PROVIDER=all
while (( $# )); do
  case "$1" in
    --provider) [[ $# -ge 2 ]] || exit 2; PROVIDER="$2"; shift 2 ;;
    -h|--help) echo 'Usage: ./scripts/uninstall.sh [--provider all|codex|claude]'; exit 0 ;;
    *) exit 2 ;;
  esac
done
valid_provider "$PROVIDER"
remove_from() {
  local agent="$1" dir="$2" item target
  for item in "$dir"/*; do
    [[ -L "$item" ]] || continue
    target="$(readlink "$item")"
    case "$target" in
      "$REPO_ROOT/skills/"*|"$REPO_ROOT/external/"*)
        rm -- "$item"
        echo "[removed] $agent/$(basename "$item")" ;;
    esac
  done
}
if [[ "$PROVIDER" == all || "$PROVIDER" == codex ]]; then remove_from Codex "$HOME/.agents/skills"; fi
if [[ "$PROVIDER" == all || "$PROVIDER" == claude ]]; then remove_from Claude "$HOME/.claude/skills"; fi
echo 'Done. External clones and unrelated skills were not changed.'
