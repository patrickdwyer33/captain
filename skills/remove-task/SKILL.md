---
name: remove-task
description: Remove a task from the project's TASKS.md. Use when a task is complete, cancelled, or no longer relevant. Removes the full H2 section for the task.
---

# Remove Task

Move a completed task from the active section to the `# Completed` section of `TASKS.md`, or permanently delete a cancelled task.

## Steps

1. **Locate TASKS.md** — find `TASKS.md` at the root of the current working project (nearest ancestor with `CLAUDE.md`, `package.json`, `Cargo.toml`, or `.git`).

2. **Identify the task** — read `TASKS.md` and list the available task headings (`## Task N: ...`) if the user hasn't specified which one to remove. The user may refer to a task by number or name. Ask to confirm if there's any ambiguity.

3. **Determine disposition** — if the task is complete, move it to the `# Completed Tasks` section. If it is cancelled or no longer relevant, delete it permanently. When called from `captain:finish-task`, always move to Completed Tasks.

4. **Move or delete the section**:
   - **Move to Completed Tasks**: Remove the `## Task N: Name` section from the `# Outstanding Tasks` area, then insert it at the top of the `# Completed Tasks` section (just after the `# Completed Tasks` heading). Completed tasks are ordered descending — highest task number first.
   - **Delete**: Remove the entire `## Task N: Name` section (heading, description, all phases and bullets, trailing blank lines). Do NOT renumber remaining tasks.

5. **Confirm** — tell the user what happened and show the updated outstanding task list (remaining headings only).

## Notes

- Never remove the `# Outstanding Tasks` or `# Completed Tasks` section headers.
- Never remove the `See also:` footer line if present.
- If the task doesn't exist in either section, say so — don't silently do nothing.
- If the task is partially done, ask the user whether to move it to Completed or leave it active.
- Do NOT renumber tasks — numbers are permanent identifiers.
