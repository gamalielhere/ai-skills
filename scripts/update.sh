#!/usr/bin/env bash
# Fast-forward all external upstreams, and link newly-added skills.
set -euo pipefail
if (( $# )); then echo 'Usage: ./scripts/update.sh' >&2; exit 2; fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
"$SCRIPT_DIR/sync.sh" --update
"$SCRIPT_DIR/install.sh"
"$SCRIPT_DIR/doctor.sh"
