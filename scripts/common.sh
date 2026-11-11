#!/usr/bin/env bash
# Shared helpers. Bash 3.2 compatible (macOS system Bash).
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"

sources() {
  local key url subdir
  while IFS=$'\t' read -r key url subdir || [[ -n "${key:-}" ]]; do
    [[ -n "${key:-}" && "$key" != \#* ]] || continue
    printf '%s\t%s\t%s\n' "$key" "$url" "$subdir"
  done < "$REPO_ROOT/sources.tsv"
}

# Print skill-name, absolute source path, provenance. Local first, then sources.tsv order.
skill_entries() {
  local entry name root key url subdir source
  for entry in "$REPO_ROOT"/skills/*; do
    [[ -d "$entry" && -f "$entry/SKILL.md" ]] || continue
    printf '%s\t%s\t%s\n' "$(basename "$entry")" "$(cd "$entry" && pwd -P)" local
  done
  while IFS=$'\t' read -r key url subdir; do
    root="$REPO_ROOT/external/$key/$subdir"
    [[ -d "$root" ]] || continue
    for entry in "$root"/*; do
      [[ -d "$entry" && -f "$entry/SKILL.md" ]] || continue
      printf '%s\t%s\t%s\n' "$(basename "$entry")" "$(cd "$entry" && pwd -P)" "$key"
    done
  done < <(sources)
}

valid_provider() {
  case "$1" in all|codex|claude) ;; *) echo "Invalid provider: $1" >&2; return 2 ;; esac
}
