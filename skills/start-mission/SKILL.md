---
name: start-mission
description: Use when the user wants to begin working on a mission from the project's MISSIONS.md.
---

# Start Mission

Begin implementing a mission recorded in `MISSIONS.md` at the root of the current project.

## Steps

1. **Regenerate MISSIONS.md** — run the generate script first to ensure `MISSIONS.md` reflects the current state of `.captain/missions.jsonl`, including any hand-edits the user may have made:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate.sh"
   ```
   If the generate script fails (e.g. jq not installed or corrupt JSONL), warn the user and proceed with whatever `MISSIONS.md` currently contains.

2. **Read the mission spec** — find `MISSIONS.md` at the project root. List available missions if the user hasn't specified which one. Read the full `## Mission N: Name` section and extract:
   - **Goal** — why this mission exists and what it accomplishes
   - **Background** — context and motivation
   - **Notes** — constraints and decisions (omit from context if absent)
   - **Depends on** — prerequisite missions (omit from context if absent)
   - Implementation detail — phases, sub-items, cross-references to `GAPS.md`

3. **Check dependencies** — if a `**Depends on:**` field is present:
   - Parse each comma-separated dependency as a full `Mission N: Name` string.
   - For each, scan `# Outstanding Missions` in `MISSIONS.md` for a matching `## Mission N: Name` heading (exact string match).
   - If any are found in Outstanding Missions (unmet dependencies):
     - List them by full heading.
     - Ask: *"These missions are still outstanding. Do you want to continue anyway?"*
     - If the user declines, stop.
     - If the user confirms, proceed to step 4.
   - A dependency not found in `# Outstanding Missions` is treated as satisfied (completed or removed) — proceed without warning.

4. **Invoke `superpowers:brainstorming`** — pass the full mission spec as structured context, explicitly calling out Goal, Background, Notes (if present), Depends on (if present), and implementation detail as separate inputs. Include this definition of done:

   > Definition of done:
   > 1. Implementation complete, all tests pass, changes committed.
   > 2. Invoke `captain:finish-mission` to handle documentation updates and cleanup.

## Notes

- Keep the DONE criteria minimal — just implementation + calling `captain:finish-mission`. Doc updates and cleanup are handled by `captain:finish-mission`, not baked into the brainstorming plan.
- If the mission is too large to complete in one session, update `MISSIONS.md` to reflect remaining phases instead of removing it, and skip `captain:finish-mission` until the mission is fully done.
