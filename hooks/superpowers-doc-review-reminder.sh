#!/usr/bin/env bash
# PostToolUse hook: remind Claude to run ce-doc-review after a superpowers
# spec or plan is written/edited. Matches docs/superpowers/{specs,plans}/*.md.
#
# Ships with the captain plugin. Captain requires the superpowers and
# compound-engineering plugins, so both sides of this handoff are guaranteed
# to be available when this hook fires.
#
# Cooldown: ce-doc-review auto-applies safe_auto fixes (via Edit) to the same
# file, which would otherwise re-trigger this hook. A per-path timestamp
# cooldown breaks the loop.

set -euo pipefail

input=$(cat)

file_path=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')
[[ -z "$file_path" ]] && exit 0

# Match only superpowers spec/plan docs (absolute or relative paths).
if ! [[ "$file_path" =~ docs/superpowers/(specs|plans)/[^/]+\.md$ ]]; then
  exit 0
fi

cooldown_dir="${HOME}/.claude/state"
cooldown_file="${cooldown_dir}/captain-superpowers-doc-review-cooldown.txt"
mkdir -p "$cooldown_dir"
touch "$cooldown_file"

now=$(date +%s)
cooldown_secs=600  # 10 minutes

last_fire=$(grep -F "${file_path}|" "$cooldown_file" 2>/dev/null | tail -1 | cut -d'|' -f2 || true)
if [[ -n "${last_fire:-}" ]] && (( now - last_fire < cooldown_secs )); then
  exit 0
fi

printf '%s|%s\n' "$file_path" "$now" >> "$cooldown_file"

doc_type="document"
if [[ "$file_path" == *"/specs/"* ]]; then
  doc_type="spec"
elif [[ "$file_path" == *"/plans/"* ]]; then
  doc_type="plan"
fi

jq -n --arg path "$file_path" --arg doc_type "$doc_type" '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: "A superpowers \($doc_type) was just written to `\($path)`. Ask the user whether they want to run the compound-engineering:ce-doc-review skill on it before continuing. If yes, invoke Skill(\"compound-engineering:ce-doc-review\", \"\($path)\"). If no, proceed with the original flow and do not ask again for this file. Do not run the review without the user'\''s explicit go-ahead."
  }
}'
