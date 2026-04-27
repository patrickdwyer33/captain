---
name: edit-missions-file
description: Use when the user wants to directly edit MISSIONS.md or COMPLETED.md, or when about to write to either file.
---

# Edit Missions File

`MISSIONS.md` and `COMPLETED.md` are auto-generated — do not edit them directly. Translate the intended change into the correct operation and execute it.

## Routing

| Intent | Action |
|--------|--------|
| Add a new mission | `captain:create-mission` |
| Mark a mission done | `captain:remove-mission` (Complete path) |
| Cancel / delete a mission | `captain:remove-mission` (Delete path) |
| Edit a mission's fields (title, goal, background, notes, body) | Edit the record in `.captain/missions.jsonl` directly, then run `bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate.sh"` |

## Steps

1. **Do not edit `MISSIONS.md` or `COMPLETED.md`.**
2. Infer the intent from what the user asked for.
3. Execute the corresponding action from the table above — no clarifying questions unless the intent is genuinely ambiguous.
4. If you edited the JSONL directly, briefly note that you made the change in the source file rather than the generated one.
