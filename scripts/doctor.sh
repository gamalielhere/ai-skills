#!/usr/bin/env bash
# Validate external source presence and global symlinks without modifying anything.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
PROVIDER=all
while (( $# )); do
  case "$1" in
    --provider) [[ $# -ge 2 ]] || exit 2; PROVIDER="$2"; shift 2 ;;
    -h|--help) echo 'Usage: ./scripts/doctor.sh [--provider all|codex|claude]'; exit 0 ;;
    *) exit 2 ;;
  esac
done
valid_provider "$PROVIDER"
errors=0
while IFS=$'\t' read -r key url subdir; do
  found=0
  for file in "$REPO_ROOT/external/$key/$subdir"/*/SKILL.md; do
    [[ -f "$file" ]] && found=1
  done
  if (( !found )); then echo "[missing source] $key — run ./scripts/sync.sh"; errors=$((errors+1)); fi
done < <(sources)
check_dir() {
  local agent="$1" dir="$2" name path owner dest actual seen="|"
  while IFS=$'\t' read -r name path owner; do
    case "$seen" in *"|$name|"*) continue ;; esac
    seen="$seen$name|"
    dest="$dir/$name"
    if [[ -L "$dest" ]]; then
      actual="$(readlink "$dest")"
      if [[ "$actual" == "$path" && -f "$dest/SKILL.md" ]]; then
        echo "[ok] $agent/$name ($owner)"
      else
        echo "[conflict] $agent/$name -> $actual; expected $path"
        errors=$((errors+1))
      fi
    elif [[ -e "$dest" ]]; then
      echo "[conflict] $agent/$name already exists as a regular file/directory"
      errors=$((errors+1))
    else
      echo "[missing] $agent/$name"
      errors=$((errors+1))
    fi
  done < <(skill_entries)
}
if [[ "$PROVIDER" == all || "$PROVIDER" == codex ]]; then check_dir Codex "$HOME/.agents/skills"; fi
if [[ "$PROVIDER" == all || "$PROVIDER" == claude ]]; then check_dir Claude "$HOME/.claude/skills"; fi
(( errors == 0 )) || { echo "$errors issue(s) detected."; exit 1; }
echo 'All linked skills and external sources verified.'
