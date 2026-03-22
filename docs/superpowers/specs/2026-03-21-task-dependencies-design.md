# Task Dependencies Design

**Date:** 2026-03-21
**Status:** Approved

## Overview

Add an optional `**Depends on:**` field to the task format in `TASKS.md` that lists prerequisite tasks. When starting a task via `captain:start-task`, the skill checks whether any dependencies are still outstanding and asks the user to confirm before proceeding.

## Task Format Change

The `**Depends on:**` field is optional. When present, it appears after `**Notes:**` (or after `**Background:**` if `**Notes:**` is absent). It lists dependency tasks as comma-separated full headings.

```markdown
## Task 7: Add OAuth login

**Goal:** Allow users to sign in with Google so we can drop password management.

**Background:** Product decision to remove email/password auth by Q2.

**Notes:** Requires the user model to support external identity providers.

**Depends on:** Task 3: Add rate limiting, Task 5: Set up auth middleware
```

- Omit the field entirely when there are no dependencies.
- Use the full `Task N: Name` heading format to match task headings in `TASKS.md`.
- Multiple dependencies are comma-separated on a single line.

## Skill Changes

### `captain:create-task`

In step 3 (gather task details), add "Depends on" as an optional prompt item:

> "Does this task depend on any other tasks completing first? If so, list them by full heading (e.g., `Task 3: Add rate limiting`). Leave blank if none."

When the user provides dependencies, write the `**Depends on:**` field in the task entry. When the user provides none, omit the field entirely.

### `captain:start-task`

After reading the task spec in step 1, check for a `**Depends on:**` field. If present:

1. Parse each comma-separated dependency.
2. For each, scan the `# Outstanding Tasks` section of `TASKS.md` for a matching `## Task N: Name` heading.
3. If any dependencies are found in Outstanding Tasks:
   - Warn the user by listing the unmet dependencies by full heading.
   - Ask: *"These tasks are still outstanding. Do you want to continue anyway?"*
   - If the user declines, stop.
   - If the user confirms, proceed to brainstorming as normal.
4. If all dependencies are absent from Outstanding Tasks (i.e., completed or removed), proceed without any warning.

## Out of Scope

- Bidirectional tracking (`Required by:` field on dependency tasks) — not needed for the warning use case.
- Blocking enforcement — the skill warns and asks, but the user always has the final say.
- Dependency graphs or visualization — plain text references are sufficient.
