#!/bin/bash
#
# Ralph — ONE iteration, human-in-the-loop.
# Run it, watch what it does, check the commit, then run it again.
# This builds intuition before you go AFK with afk-ralph.sh.
#
#   ./.ralph/ralph-once.sh
#
set -euo pipefail


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."   # project root: issues/ live here


MODEL="${MODEL:-claude-opus-4-8[1m]}"
EFFORT="${EFFORT:-max}"
COMMIT_COUNT="${COMMIT_COUNT:-10}"


commits="$(git log -n "$COMMIT_COUNT" --format='%H%n%ad%n%B----' --date=short 2>/dev/null || echo 'No commits yet.')"
issues="$(for f in issues/*.md; do [ -e "$f" ] || continue; printf '===== %s =====\n' "$f"; awk 1 "$f"; echo; done)"
[ -n "$issues" ] || issues="(no open issue files under issues/)"
instructions="$(cat "$SCRIPT_DIR/api.md")"
progress="$(cat "$SCRIPT_DIR/progress.txt")"

prompt="
$commits
$issues
$progress
$instructions"


claude --dangerously-skip-permissions --model "$MODEL" --effort "$EFFORT" -p "$prompt"
