#!/usr/bin/env bash
# Create symlinks to local and cloned external skills. Never overwrite other skills.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
PROVIDER=all
DRY_RUN=0
usage() { echo 'Usage: ./scripts/install.sh [--provider all|codex|claude] [--dry-run]'; }
while (( $# )); do
  case "$1" in
    --provider) [[ $# -ge 2 ]] || { usage >&2; exit 2; }; PROVIDER="$2"; shift 2 ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
valid_provider "$PROVIDER"
install_to() {
  local label="$1" dir="$2" name path owner dest previous
  local seen="|"
  if (( !DRY_RUN )); then mkdir -p "$dir"; fi
  while IFS=$'\t' read -r name path owner; do
    # First provider wins: local > pstack > ponytail > thermos > superpowers.
    case "$seen" in *"|$name|"*) echo "[duplicate] $name from $owner; first occurrence wins" >&2; continue ;; esac
    seen="$seen$name|"
    dest="$dir/$name"
    if [[ -L "$dest" ]]; then
      previous="$(readlink "$dest")"
      if [[ "$previous" == "$path" ]]; then
        echo "[ok] $label/$name ($owner)"
      else
        echo "[conflict] $label/$name already links to '$previous'; not overwritten" >&2
      fi
    elif [[ -e "$dest" ]]; then
      echo "[conflict] $label/$name already exists; not overwritten" >&2
    elif (( DRY_RUN )); then
      echo "[dry-run] $label/$name -> $path"
    else
      ln -s "$path" "$dest"
      echo "[linked] $label/$name ($owner)"
    fi
  done < <(skill_entries)
}
if [[ "$PROVIDER" == all || "$PROVIDER" == codex ]]; then install_to Codex "$HOME/.agents/skills"; fi
if [[ "$PROVIDER" == all || "$PROVIDER" == claude ]]; then install_to Claude "$HOME/.claude/skills"; fi
echo 'Done. Restart an agent session if its skill selector does not refresh.'
