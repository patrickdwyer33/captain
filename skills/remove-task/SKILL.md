---
name: remove-task
description: Remove a task from the project's TASKS.md. Use when a task is complete, cancelled, or no longer relevant. Removes the full H2 section for the task.
---

# Remove Task

Remove a task entry from `TASKS.md` at the root of the current project.

## Steps

1. **Locate TASKS.md** — find `TASKS.md` at the root of the current working project (nearest ancestor with `CLAUDE.md`, `package.json`, `Cargo.toml`, or `.git`).

2. **Identify the task** — read `TASKS.md` and list the available task headings (`## Task N: ...`) if the user hasn't specified which one to remove. The user may refer to a task by number or name. Ask to confirm if there's any ambiguity.

3. **Remove the section** — delete the entire `## Task N: Name` section: the heading line, description, all phases and bullets, and any trailing blank lines before the next section. Do NOT renumber remaining tasks.

4. **Confirm** — tell the user the task was removed and show the updated task list (remaining headings only).

## Notes

- Never remove the `# Tasks` file header.
- Never remove the trailing `See also:` footer line if present.
- If the task doesn't exist, say so — don't silently do nothing.
- If the task is partially done, ask the user whether to remove it fully or leave it.
