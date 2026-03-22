---
name: remove-mission
description: Remove a mission from the project's MISSIONS.md. Use when a mission is complete, cancelled, or no longer relevant. Removes the full H2 section for the mission.
---

# Remove Mission

Move a completed mission from the active section to the `# Completed` section of `MISSIONS.md`, or permanently delete a cancelled mission.

## Steps

1. **Locate MISSIONS.md** — find `MISSIONS.md` at the root of the current working project (nearest ancestor with `CLAUDE.md`, `package.json`, `Cargo.toml`, or `.git`).

2. **Identify the mission** — read `MISSIONS.md` and list the available mission headings (`## Mission N: ...`) if the user hasn't specified which one to remove. The user may refer to a mission by number or name. Ask to confirm if there's any ambiguity.

3. **Determine disposition** — if the mission is complete, move it to the `# Completed Missions` section. If it is cancelled or no longer relevant, delete it permanently. When called from `captain:finish-mission`, always move to Completed Missions.

4. **Move or delete the section**:
   - **Move to Completed Missions**: Remove the `## Mission N: Name` section from the `# Outstanding Missions` area, then insert it at the top of the `# Completed Missions` section (just after the `# Completed Missions` heading). Completed missions are ordered descending — highest mission number first.
   - **Delete**: Remove the entire `## Mission N: Name` section (heading, description, all phases and bullets, trailing blank lines). Do NOT renumber remaining missions.

5. **Confirm** — tell the user what happened and show the updated outstanding mission list (remaining headings only).

## Notes

- Never remove the `# Outstanding Missions` or `# Completed Missions` section headers.
- Never remove the `See also:` footer line if present.
- If the mission doesn't exist in either section, say so — don't silently do nothing.
- If the mission is partially done, ask the user whether to move it to Completed or leave it active.
- Do NOT renumber missions — numbers are permanent identifiers.
