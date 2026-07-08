#!/bin/bash
#
# Ralph — AFK loop. Just runs ralph-once.sh N times in a row.
#
#   ./.ralph/afk-ralph.sh 20     # run 20 iterations
#
# No `set -e`: one transient non-zero exit shouldn't abort the whole run.
set -uo pipefail

if ! [[ "${1:-}" =~ ^[0-9]+$ ]]; then
  echo "Usage: $0 <iterations>" >&2
  exit 1
fi
ITERATIONS="$1"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for ((i=1; i<=ITERATIONS; i++)); do
  echo "=== Ralph iteration $i/$ITERATIONS ==="
  "$SCRIPT_DIR/ralph-once.sh"
done
