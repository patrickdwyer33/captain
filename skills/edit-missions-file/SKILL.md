---
name: edit-missions-file
description: Use when the user wants to directly edit MISSIONS.md or COMPLETED.md, or when about to write to either file.
---

# Edit Missions File

`MISSIONS.md` and `COMPLETED.md` are auto-generated from `.captain/missions.jsonl` and `.captain/completed.jsonl`. Direct edits will be overwritten the next time the generate script runs.

**Do not edit these files.** Instead, ask the user what change they want to make, then route to the appropriate skill:

| Intent | Skill |
|--------|-------|
| Add a new mission | `captain:create-mission` |
| Mark a mission done | `captain:remove-mission` (Complete path) |
| Cancel / delete a mission | `captain:remove-mission` (Delete path) |
| Start working on a mission | `captain:start-mission` |
| Edit a mission's title, goal, background, notes, or body | Edit `.captain/missions.jsonl` directly — find the record by `id`, update the field, then run `bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh` |

## When this applies

- User says "edit MISSIONS.md", "update MISSIONS.md", "change the mission file", etc.
- You are about to call `Edit` or `Write` on `MISSIONS.md` or `COMPLETED.md`

## Steps

1. **Stop** — do not edit the file.
2. **Explain** — tell the user the file is auto-generated from `.captain/missions.jsonl` and direct edits will be overwritten.
3. **Ask** — "What change would you like to make?" if the intent isn't already clear.
4. **Route** — use the table above to invoke the right skill or make the JSONL edit directly.
