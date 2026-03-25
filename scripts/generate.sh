#!/usr/bin/env bash
# generate.sh — generates MISSIONS.md and COMPLETED.md from .captain/*.jsonl
# Run from the project root (the directory containing .captain/).
# Both files are generated independently — a failure on one does not abort the other.
set -uo pipefail

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed." >&2
  echo "  macOS:  brew install jq" >&2
  echo "  Linux:  sudo apt install jq   OR   sudo yum install jq" >&2
  exit 1
fi

MISSIONS_JSONL=".captain/missions.jsonl"
COMPLETED_JSONL=".captain/completed.jsonl"

# ---------- helpers ----------

render_mission() {
  local record="$1"
  local include_completed="${2:-0}"

  local id title goal background notes depends_on body
  id=$(printf '%s\n' "$record" | jq -r '.id')
  title=$(printf '%s\n' "$record" | jq -r '.title')
  goal=$(printf '%s\n' "$record" | jq -r '.goal')
  background=$(printf '%s\n' "$record" | jq -r '.background')
  notes=$(printf '%s\n' "$record" | jq -r '.notes // empty')
  depends_on=$(printf '%s\n' "$record" | jq -r 'if (.depends_on | length) > 0 then .depends_on | join(", ") else empty end')
  body=$(printf '%s\n' "$record" | jq -r '.body // empty'; printf x)
  body="${body%x}"

  printf '## Mission %s: %s\n\n' "$id" "$title"
  printf '**Goal:** %s\n\n' "$goal"
  printf '**Background:** %s\n' "$background"

  if [ -n "$notes" ]; then
    printf '\n**Notes:** %s\n' "$notes"
  fi

  if [ -n "$depends_on" ]; then
    printf '\n**Depends on:** %s\n' "$depends_on"
  fi

  if [ -n "$body" ]; then
    printf '\n%s\n' "$body"
  fi

  if [ "$include_completed" = "1" ]; then
    local completed_at
    completed_at=$(printf '%s\n' "$record" | jq -r '.completed_at')
    printf '\n**Completed:** %s\n' "$completed_at"
  fi
}

# ---------- MISSIONS.md ----------
# Wrapped in a subshell so a parse error here does not prevent COMPLETED.md from being written.

(
  set -e
  {
    printf '<!-- This file is auto-generated from .captain/missions.jsonl — do not edit directly. To make changes, edit the JSONL files or ask Claude. -->\n\n'
    printf '# Outstanding Missions\n\n'
    printf 'See also: [GAPS.md](GAPS.md) — known code stubs to implement | [IDEAS.md](IDEAS.md) — long-term ideas\n'

    if [ -f "$MISSIONS_JSONL" ] && [ -s "$MISSIONS_JSONL" ]; then
      while IFS= read -r record; do
        if [ -z "$record" ]; then continue; fi
        printf '\n'
        render_mission "$record" 0
      done < <(jq -cs 'sort_by(.id)[]' "$MISSIONS_JSONL")
    fi
  } > MISSIONS.md
) || echo "Warning: failed to generate MISSIONS.md" >&2

# ---------- COMPLETED.md ----------
# Wrapped in a subshell so a parse error here does not prevent MISSIONS.md from being written.

(
  set -e
  {
    printf '<!-- This file is auto-generated from .captain/completed.jsonl — do not edit directly. To make changes, edit the JSONL files or ask Claude. -->\n\n'
    printf '# Completed Missions\n'

    if [ -f "$COMPLETED_JSONL" ] && [ -s "$COMPLETED_JSONL" ]; then
      while IFS= read -r record; do
        if [ -z "$record" ]; then continue; fi
        printf '\n'
        render_mission "$record" 1
      done < <(jq -cs 'sort_by(.id) | reverse | .[]' "$COMPLETED_JSONL")
    fi
  } > COMPLETED.md
) || echo "Warning: failed to generate COMPLETED.md" >&2
