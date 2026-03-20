---
name: start-task
description: Use when the user wants to begin working on a task from the project's TASKS.md. Reads the task spec and kicks off brainstorming and implementation.
---

# Start Task

Begin implementing a task recorded in `TASKS.md` at the root of the current project.

## Steps

1. **Read the task spec** — find `TASKS.md` at the project root. List available tasks if the user hasn't specified which one. Read the full `## Task N: Name` section and extract:
   - **Goal** — why this task exists and what it accomplishes
   - **Background** — context and motivation
   - **Notes** — constraints and decisions (omit from context if absent)
   - Implementation detail — phases, sub-items, cross-references to `GAPS.md`

2. **Invoke `superpowers:brainstorming`** — pass the full task spec as structured context, explicitly calling out Goal, Background, Notes (if present), and implementation detail as separate inputs. Include this definition of done:

   > Definition of done:
   > 1. Implementation complete, all tests pass, changes committed.
   > 2. Invoke `captain:finish-task` to handle documentation updates and cleanup.

## Notes

- Keep the DONE criteria minimal — just implementation + calling `captain:finish-task`. Doc updates and cleanup are handled by `captain:finish-task`, not baked into the brainstorming plan.
- If the task is too large to complete in one session, update `TASKS.md` to reflect remaining phases instead of removing it, and skip `captain:finish-task` until the task is fully done.
