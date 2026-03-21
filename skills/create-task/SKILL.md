---
name: create-task
description: Add a new task to the project's TASKS.md. Use when the user wants to record a new task, feature, or work item to track. Tasks are stored as H2 sections in TASKS.md at the project root.
---

# Create Task

Add a new task entry to `TASKS.md` at the root of the current project.

## Steps

1. **Locate TASKS.md** — find `TASKS.md` at the root of the current working project (the nearest ancestor directory containing a `CLAUDE.md`, `package.json`, `Cargo.toml`, or `.git`). If none exists, create it with a `# Outstanding Tasks` header and a `# Completed Tasks` section.

2. **Determine the next task number** — count existing `## Task N:` headings in `TASKS.md` and increment by 1.

3. **Gather task details** — if the user hasn't provided enough detail, ask:
   - Task name (becomes the heading title after the number)
   - Goal (one sentence: what this accomplishes and why it matters)
   - Background (context, motivation, what triggered this)
   - Notes (constraints, dependencies, decisions already made — optional)
   - Phases or sub-steps (optional — use if the task has distinct stages)

4. **Write the entry** — insert into the `# Outstanding Tasks` section of `TASKS.md` (before the `# Completed Tasks` section) at the end of the active tasks list, using this format:

```markdown
## Task 3: Task Name

**Goal:** One sentence describing what this accomplishes and why it matters.

**Background:** Context, motivation, history. What triggered this task?

**Notes:** Constraints, dependencies, decisions already made. (Optional — omit entirely if nothing to say.)

**Phase 1 — First stage name**
- Sub-item one
- Sub-item two

**Phase 2 — Second stage name**
- Sub-item one
- Sub-item two
```

   - **Goal** and **Background** are required. **Notes** is optional — omit entirely if nothing to say.
   - Omit phases if the task is simple — use a flat bullet list after Background/Notes instead.

5. **Confirm** — tell the user the task was added and show the new entry.

## Notes

- Never overwrite existing tasks.
- Never reuse or reorder task numbers — numbers are permanent identifiers, not rankings.
- Insert new tasks at the end of the `# Outstanding Tasks` section, just before the `# Completed Tasks` section. Outstanding tasks are ordered ascending (lowest number first, highest last).
- Use present-tense imperative phrasing for task names (e.g. "Add rate limiting", not "Rate limiting added").
