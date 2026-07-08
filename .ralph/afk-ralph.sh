#!/bin/bash
#
# Ralph — AFK loop. Each iteration feeds Claude the recent commits + the open
# (non-done) issue files + prompt.md, streams the run live, and stops when Claude
# signals NO MORE TASKS. Completed issues are moved to issues/done/ by Claude
# itself (per prompt.md), so "what's done" is tracked by git + the done/ folder.
#
#   ./.ralph/afk-ralph.sh 20            # up to 20 iterations, in a docker sandbox
#   SANDBOX=0 ./.ralph/afk-ralph.sh 20  # run claude directly on the host instead
#
# Deliberately no `set -e`: one transient non-zero exit should not abort an
# unattended run — we log it and move to the next iteration.
set -uo pipefail

if ! [[ "${1:-}" =~ ^[0-9]+$ ]]; then
  echo "Usage: $0 <iterations>" >&2
  exit 1
fi
ITERATIONS="$1"

command -v jq >/dev/null || { echo "jq is required (brew/apt install jq)" >&2; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."   # project root: issues/ live here and `.` is what the sandbox mounts

# --- Model / effort / context ---------------------------------------------
# Override at call time, e.g.  MODEL=claude-sonnet-5 EFFORT=high ./.ralph/afk-ralph.sh 20
MODEL="${MODEL:-claude-opus-4-8[1m]}"
EFFORT="${EFFORT:-xhigh}"
COMMIT_COUNT="${COMMIT_COUNT:-5}"
LOG="$SCRIPT_DIR/afk.log"

# --- Runner ----------------------------------------------------------------
# Default: run each iteration inside an isolated Docker sandbox (Docker Desktop
# 4.50+), mounting the project root (`.`). Set SANDBOX=0 to run on the host.
if [ "${SANDBOX:-1}" = 1 ]; then
  command -v docker >/dev/null || { echo "docker not found; use SANDBOX=0 to run on the host" >&2; exit 1; }
  run() { docker sandbox run claude . -- "$@"; }
else
  run() { claude "$@"; }
fi

# --- jq filters over the stream-json event stream --------------------------
stream_text='select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text // empty'
final_result='select(.type == "result") | .result // empty'

instructions="$(cat "$SCRIPT_DIR/prompt.md")"

tmpfile=""
trap 'rm -f "$tmpfile"' EXIT   # backstop if killed mid-iteration

for ((i=1; i<=ITERATIONS; i++)); do
  echo "=== Ralph iteration $i/$ITERATIONS ===" | tee -a "$LOG"

  # Context prompt.md expects: recent commits + every open issue file (with its
  # path, so Claude knows which file to move to issues/done/). done/ is a subdir,
  # so issues/*.md never picks up already-completed issues.
  commits="$(git log -n "$COMMIT_COUNT" --format='%H%n%ad%n%B----' --date=short 2>/dev/null || echo 'No commits yet.')"
  issues="$(for f in issues/*.md; do [ -e "$f" ] || continue; printf '===== %s =====\n' "$f"; cat "$f"; printf '\n'; done)"
  [ -n "$issues" ] || issues="(no open issue files under issues/)"

  prompt="# RECENT COMMITS
$commits

# OPEN ISSUE FILES (from issues/)
$issues

$instructions"

  tmpfile="$(mktemp)"
  # Raw JSONL -> tmpfile (for the final-result check); live assistant text -> terminal + log.
  run -p "$prompt" \
      --model "$MODEL" --effort "$EFFORT" \
      --dangerously-skip-permissions \
      --output-format stream-json --verbose \
    | tee "$tmpfile" \
    | jq -rj --unbuffered "$stream_text" \
    | tee -a "$LOG"
  echo

  result="$(jq -rs "map(${final_result}) | .[-1] // empty" "$tmpfile")"
  rm -f "$tmpfile"; tmpfile=""

  if [[ "$result" == *"<promise>NO MORE TASKS</promise>"* ]]; then
    echo "No more AFK tasks after $i iterations."
    exit 0
  fi
done

echo "Reached the iteration cap ($ITERATIONS) without a NO MORE TASKS signal."
