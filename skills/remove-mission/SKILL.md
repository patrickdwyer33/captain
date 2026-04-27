---
name: remove-mission
description: Use when a mission is finished (move to Completed) or cancelled (delete it).
---

# Remove Mission

Move a completed mission to `.captain/completed.jsonl`, or permanently delete a cancelled mission from `.captain/missions.jsonl`. Regenerates `MISSIONS.md` and `COMPLETED.md` after any mutation.

## Steps

1. **Check for jq** — run `command -v jq`. If missing, show install instructions (same as `captain:create-mission` step 1) and abort.

2. **Identify the mission** — if the user hasn't specified which mission, read `MISSIONS.md` and list the available headings. Confirm if there's any ambiguity.

3. **Determine disposition** — ask: *"Is this mission done (move to Completed), or are you cancelling/deleting it?"*
   - If **completed**: follow the Complete path below.
   - If **cancelled/deleted**: follow the Delete path below.
   - When called from `captain:finish-mission`, always use the Complete path — skip this question.

### Complete path

4. **Validate the mission exists**:
   ```bash
   FOUND=$(jq -rs --argjson id N '[.[] | select(.id == $id)] | length' .captain/missions.jsonl)
   [ "$FOUND" -eq 0 ] && echo "Mission N not found" && exit 1
   ```
   (`N` is the integer mission id throughout this skill.)

5. **Build the completed record**:
   ```bash
   TODAY=$(date +%Y-%m-%d)
   RECORD=$(jq -c --argjson id N --arg d "$TODAY" \
     'select(.id == $id) | . + {completed_at: $d}' .captain/missions.jsonl)
   ```
   Since ids are unique, `select` produces exactly one record.

6. **Remove from `.captain/missions.jsonl` first** (before writing to completed.jsonl — if the append later fails, the user manually re-adds to completed.jsonl using the original id rather than dealing with a duplicate):
   ```bash
   jq -c --argjson id N 'select(.id != $id)' .captain/missions.jsonl \
     > .captain/missions.jsonl.tmp \
     && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
   ```

7. **Append to `.captain/completed.jsonl`**:
   ```bash
   { cat .captain/completed.jsonl 2>/dev/null; printf '%s\n' "$RECORD"; } \
     | jq -c '.' > .captain/completed.jsonl.tmp \
     && mv .captain/completed.jsonl.tmp .captain/completed.jsonl
   ```

8. **Regenerate markdown**:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate.sh"
   ```

9. **Confirm** — tell the user the mission was moved to Completed.

### Delete path

4. **Validate the mission exists** (same length-check as Complete path step 4).

5. **Remove from `.captain/missions.jsonl`**:
   ```bash
   jq -c --argjson id N 'select(.id != $id)' .captain/missions.jsonl \
     > .captain/missions.jsonl.tmp \
     && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
   ```

6. **Regenerate markdown**:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate.sh"
   ```

7. **Confirm** — tell the user the mission was permanently deleted.

## Notes

- Never remove the `.captain/` directory or JSONL files.
- Do NOT renumber missions — ids are permanent.
- If the mission doesn't exist in `.captain/missions.jsonl`, say so and abort.
