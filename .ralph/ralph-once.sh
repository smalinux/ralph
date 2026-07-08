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
EFFORT="${EFFORT:-xhigh}"
COMMIT_COUNT="${COMMIT_COUNT:-10}"

# Same context prompt.md expects: recent commits + open issue files (with paths).
commits="$(git log -n "$COMMIT_COUNT" --format='%H%n%ad%n%B----' --date=short 2>/dev/null || echo 'No commits yet.')"
issues="$(for f in issues/*.md; do [ -e "$f" ] || continue; printf '===== %s =====\n' "$f"; cat "$f"; printf '\n'; done)"
[ -n "$issues" ] || issues="(no open issue files under issues/)"
instructions="$(cat "$SCRIPT_DIR/prompt.md")"


prompt="# RECENT COMMITS
$commits

# OPEN ISSUE FILES (from issues/)
$issues

$instructions"


claude --dangerously-skip-permissions --model "$MODEL" --effort "$EFFORT" "$prompt"
