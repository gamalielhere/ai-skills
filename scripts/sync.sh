#!/usr/bin/env bash
# Clone approved upstream repositories locally, or fast-forward existing clones.
# Never executes upstream setup scripts, hooks, plugins, or install commands.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"
UPDATE=0
DRY_RUN=0
usage() { echo 'Usage: ./scripts/sync.sh [--update] [--dry-run]'; }
while (( $# )); do
  case "$1" in
    --update) UPDATE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
  esac
done
command -v git >/dev/null || { echo 'Git is required' >&2; exit 1; }

if (( !DRY_RUN )); then mkdir -p "$REPO_ROOT/external"; fi
fail=0
while IFS=$'\t' read -r key url subdir; do
  [[ "$key" =~ ^[a-z0-9-]+$ && "$subdir" != /* && "$subdir" != *..* ]] || { echo "Invalid source entry: $key" >&2; exit 2; }
  target="$REPO_ROOT/external/$key"
  if [[ ! -e "$target" ]]; then
    echo "[clone] $key <- $url"
    if (( !DRY_RUN )); then
      if ! git clone --quiet --depth 1 -- "$url" "$target"; then
        echo "[error] Could not clone $key; check your Git/network access" >&2
        fail=1
        continue
      fi
    fi
  elif [[ -d "$target/.git" ]]; then
    if (( UPDATE )); then
      echo "[update] $key (fast-forward only)"
      if (( !DRY_RUN )); then
        if [[ -n "$(git -C "$target" status --porcelain)" ]]; then
          echo "[skip] $key has local changes; update manually" >&2
          fail=1
          continue
        fi
        if ! git -C "$target" pull --ff-only --quiet; then
          echo "[error] Failed updating $key" >&2
          fail=1
          continue
        fi
      fi
    else
      echo "[ok] $key already cloned (use --update to fast-forward)"
    fi
  else
    echo "[error] $target exists but is not a Git clone; left untouched" >&2
    fail=1
    continue
  fi
  if (( !DRY_RUN )); then
    count=0
    if [[ -d "$target/$subdir" ]]; then
      for s in "$target/$subdir"/*/SKILL.md; do
        [[ -f "$s" ]] || continue
        count=$((count + 1))
      done
    fi
    if (( count == 0 )); then
      echo "[error] $key has no SKILL.md folders at '$subdir'. Check upstream layout." >&2
      fail=1
    else
      echo "[found] $key: $count skills"
    fi
  fi
done < <(sources)
if (( fail )); then exit 1; fi
echo 'External Git sources ready (or dry run complete).'
