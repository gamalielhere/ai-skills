#!/usr/bin/env bash
# Initial setup from a stable checked-out path.
set -euo pipefail
if (( $# )); then echo 'Usage: ./scripts/setup.sh (for one provider, call sync.sh and install.sh --provider)' >&2; exit 2; fi
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
"$SCRIPT_DIR/sync.sh"
"$SCRIPT_DIR/install.sh"
"$SCRIPT_DIR/doctor.sh"
