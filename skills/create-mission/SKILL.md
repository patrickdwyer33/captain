---
name: create-mission
description: Add a new mission to the project's JSONL mission store. Creates .captain/missions.jsonl if needed, calculates the next id, appends the new record, and regenerates MISSIONS.md.
---

# Create Mission

Add a new mission to the JSONL data layer at `.captain/missions.jsonl` and regenerate `MISSIONS.md`.

## Steps

1. **Check for jq** — run `command -v jq` to verify jq is installed. If missing, tell the user:
   > jq is required by captain. Install it first:
   > - macOS: `brew install jq`
   > - Linux: `sudo apt install jq` or `sudo yum install jq`
   Then abort.

2. **Ensure `.captain/` exists** — if `.captain/`, `.captain/missions.jsonl`, or `.captain/completed.jsonl` are missing, create them:
   ```bash
   mkdir -p .captain
   touch .captain/missions.jsonl
   touch .captain/completed.jsonl
   ```
   Also check that `.captain/` is not listed in `.gitignore`. If it is, warn the user that the JSONL files must be committed and ask them to remove the exclusion.

3. **Gather mission details** — ask the user for:
   - **Title** — imperative present-tense name (e.g. "Add OAuth login")
   - **Goal** — one sentence: what this accomplishes and why it matters
   - **Background** — context, motivation, what triggered this
   - **Notes** — constraints, decisions already made (optional — skip if nothing to say)
   - **Depends on** — "Does this depend on other missions completing first? If so, list them as `Mission N: Title`. Leave blank if none." (optional)
   - **Body** — phases or sub-steps (optional — use if the mission has distinct stages or a task list)

4. **Determine the next id** — find the max `id` across both JSONL files and add 1. Abort if jq exits non-zero (corrupt file):
   ```bash
   MAX=$(jq -rs '[.[] | .id] | max // 0' .captain/missions.jsonl .captain/completed.jsonl) \
     || { echo "Failed to read JSONL — check for corruption"; exit 1; }
   NEXT_ID=$((MAX + 1))
   ```

5. **Build the JSON record** — start with required fields, then conditionally add optional ones:
   ```bash
   NEW_RECORD=$(jq -cn \
     --argjson id "$NEXT_ID" \
     --arg title "TITLE" \
     --arg goal "GOAL" \
     --arg background "BACKGROUND" \
     '{id: $id, title: $title, goal: $goal, background: $background}')

   # Add optional string fields only if provided:
   [ -n "$NOTES" ] && NEW_RECORD=$(printf '%s\n' "$NEW_RECORD" | jq -c --arg v "$NOTES" '. + {notes: $v}')
   [ -n "$BODY"  ] && NEW_RECORD=$(printf '%s\n' "$NEW_RECORD" | jq -c --arg v "$BODY"  '. + {body: $v}')

   # Add depends_on if provided (as a JSON array, e.g. '["Mission 3: Add rate limiting"]'):
   [ -n "$DEPENDS_ON" ] && NEW_RECORD=$(printf '%s\n' "$NEW_RECORD" | jq -c --argjson v "$DEPENDS_ON" '. + {depends_on: $v}')
   ```
   For the `body` field: if the user supplied multi-line content, JSON-escape newlines as `\n` when building the string (jq `--arg` handles this automatically).

6. **Write the record** — append using the read-pipe-write pattern:
   ```bash
   { cat .captain/missions.jsonl 2>/dev/null; printf '%s\n' "$NEW_RECORD"; } \
     | jq -c '.' > .captain/missions.jsonl.tmp \
     && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
   ```

7. **Regenerate markdown** — run:
   ```bash
   bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh
   ```

8. **Confirm** — tell the user the mission was added and show the new entry from `MISSIONS.md`.

## Notes

- Never reuse mission ids — ids are permanent identifiers.
- The `body` field stores raw markdown with JSON-escaped newlines. When the user provides multi-line content, pass it to jq via `--arg` (which auto-escapes) rather than embedding raw newlines in the JSON string.
- Optional fields are omitted from the record entirely when not provided — do not store empty strings.
