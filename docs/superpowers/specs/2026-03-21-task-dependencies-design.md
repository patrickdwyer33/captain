# Mission Dependencies Design

**Date:** 2026-03-21
**Status:** Approved

## Overview

Add an optional `**Depends on:**` field to the mission format in `MISSIONS.md` that lists prerequisite missions. When starting a mission via `captain:start-mission`, the skill checks whether any dependencies are still outstanding and asks the user to confirm before proceeding.

## Mission Format Change

The canonical field order for a mission entry is:

```
Goal → Background → Notes (optional) → Depends on (optional) → Phases or flat bullets (optional)
```

The `**Depends on:**` field always appears after `**Notes:**` (or after `**Background:**` if Notes is absent), and always before any phases or sub-items. It lists dependency missions as comma-separated full `Mission N: Name` headings.

```markdown
## Mission 7: Add OAuth login

**Goal:** Allow users to sign in with Google so we can drop password management.

**Background:** Product decision to remove email/password auth by Q2.

**Notes:** Requires the user model to support external identity providers.

**Depends on:** Mission 3: Add rate limiting, Mission 5: Set up auth middleware

**Phase 1 — User model changes**
- Add external_id and provider columns
- Write migration

**Phase 2 — OAuth flow**
- Integrate Google OAuth library
- Add callback route
```

- Omit the field entirely when there are no dependencies.
- Use the full `Mission N: Name` heading format — exact string match against `## Mission N: Name` headings.
- Multiple dependencies are comma-separated on a single line.

## Skill Changes

### `captain:create-mission`

**Step 3 (gather mission details):** Add "Depends on" as the 5th optional prompt item, after Notes and before Phases:

1. Mission name
2. Goal
3. Background
4. Notes (optional)
5. **Depends on** (optional) — *"Does this mission depend on any other missions completing first? If so, list them by full heading (e.g., `Mission 3: Add rate limiting`). Leave blank if none."*
6. Phases or sub-steps (optional)

If the user provides mission details upfront without being prompted interactively, treat "Depends on" the same as Notes and Phases — include it if provided, omit it otherwise.

**Step 4 (write the entry):** The canonical format block is now:

```markdown
## Mission N: Mission Name

**Goal:** One sentence describing what this accomplishes and why it matters.

**Background:** Context, motivation, history. What triggered this mission?

**Notes:** Constraints, decisions already made. (Optional — omit if nothing to say.)

**Depends on:** Mission 3: Name, Mission 5: Other Name (Optional — omit if no dependencies.)

**Phase 1 — First stage name**
- Sub-item one
- Sub-item two

**Phase 2 — Second stage name**
- Sub-item one
- Sub-item two
```

### `captain:start-mission`

After reading the mission spec in step 1, check for a `**Depends on:**` field. If present:

1. Parse each comma-separated dependency as a full `Mission N: Name` string.
2. For each, scan `# Outstanding Missions` in `MISSIONS.md` for a matching `## Mission N: Name` heading (exact string match).
3. Classify each dependency:
   - **Unmet** — found in `# Outstanding Missions`
   - **Satisfied** — not found in `# Outstanding Missions` (completed, cancelled, or never existed — all treated as satisfied; no error)
4. If any dependencies are **unmet**:
   - List them by full heading.
   - Ask: *"These missions are still outstanding. Do you want to continue anyway?"*
   - If the user declines, stop.
   - If the user confirms, proceed to brainstorming as normal.
5. If all dependencies are satisfied, proceed without any warning.

**Note:** A dependency heading that doesn't appear anywhere in MISSIONS.md (neither Outstanding nor Completed) is silently treated as satisfied — it was likely cancelled or cleaned up. No error is raised.

## Out of Scope

- Bidirectional tracking (`Required by:` field on dependency missions) — not needed for the warning use case.
- Blocking enforcement — the skill warns and asks, but the user always has the final say.
- Fuzzy or partial dependency matching — exact string match only.
- Dependency graphs or visualization — plain text references are sufficient.
