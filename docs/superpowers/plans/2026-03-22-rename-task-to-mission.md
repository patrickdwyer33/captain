# Rename Task → Mission Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rename every "task" concept to "mission" across all captain skill files and documentation — skill directory names, SKILL.md content, file references (TASKS.md → MISSIONS.md), section headers, and README.

**Architecture:** Pure rename — no logic changes. Each skill directory is renamed with `git mv`, then its SKILL.md content is updated. Supporting files (init-project-docs, README, design spec) are updated last. A final grep pass verifies no old terms remain.

**Tech Stack:** Markdown, git

---

### Rename substitutions reference

This table defines every substitution applied throughout all files:

| Old | New |
|-----|-----|
| `TASKS.md` | `MISSIONS.md` |
| `# Outstanding Tasks` | `# Outstanding Missions` |
| `# Completed Tasks` | `# Completed Missions` |
| `## Task N:` | `## Mission N:` |
| `captain:create-task` | `captain:create-mission` |
| `captain:remove-task` | `captain:remove-mission` |
| `captain:start-task` | `captain:start-mission` |
| `captain:finish-task` | `captain:finish-mission` |
| `create-task` | `create-mission` |
| `remove-task` | `remove-mission` |
| `start-task` | `start-mission` |
| `finish-task` | `finish-mission` |
| `Task N:` (in headings/format) | `Mission N:` |
| `task` (general noun) | `mission` |
| `tasks` (plural noun) | `missions` |
| `Task` (capitalized noun) | `Mission` |
| `Tasks` (capitalized plural) | `Missions` |

Skill directory names also change: `skills/create-task/` → `skills/create-mission/`, etc.

---

### Task 1: Rename create-task skill

**Files:**
- Rename: `skills/create-task/` → `skills/create-mission/`
- Modify: `skills/create-mission/SKILL.md`

- [ ] **Step 1: Rename the directory**

```bash
git mv skills/create-task skills/create-mission
```

- [ ] **Step 2: Replace SKILL.md content**

Write the following to `skills/create-mission/SKILL.md`:

```markdown
---
name: create-mission
description: Add a new mission to the project's MISSIONS.md. Use when the user wants to record a new mission, feature, or work item to track. Missions are stored as H2 sections in MISSIONS.md at the project root.
---

# Create Mission

Add a new mission entry to `MISSIONS.md` at the root of the current project.

## Steps

1. **Locate MISSIONS.md** — find `MISSIONS.md` at the root of the current working project (the nearest ancestor directory containing a `CLAUDE.md`, `package.json`, `Cargo.toml`, or `.git`). If none exists, create it with a `# Outstanding Missions` header and a `# Completed Missions` section.

2. **Determine the next mission number** — count existing `## Mission N:` headings in `MISSIONS.md` and increment by 1.

3. **Gather mission details** — if the user hasn't provided enough detail, ask:
   - Mission name (becomes the heading title after the number)
   - Goal (one sentence: what this accomplishes and why it matters)
   - Background (context, motivation, what triggered this)
   - Notes (constraints, dependencies, decisions already made — optional)
   - Depends on (optional) — "Does this mission depend on any other missions completing first? If so, list them by full heading (e.g., `Mission 3: Add rate limiting`). Leave blank if none."
   - Phases or sub-steps (optional — use if the mission has distinct stages)

4. **Write the entry** — insert into the `# Outstanding Missions` section of `MISSIONS.md` (before the `# Completed Missions` section) at the end of the active missions list, using this format:

```markdown
## Mission 3: Mission Name

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

   - **Goal** and **Background** are required. **Notes** and **Depends on** are optional — omit entirely if nothing to say.
   - Omit phases if the mission is simple — use a flat bullet list after Background/Notes instead.

5. **Confirm** — tell the user the mission was added and show the new entry.

## Notes

- Never overwrite existing missions.
- Never reuse or reorder mission numbers — numbers are permanent identifiers, not rankings.
- Insert new missions at the end of the `# Outstanding Missions` section, just before the `# Completed Missions` section. Outstanding missions are ordered ascending (lowest number first, highest last).
- Use present-tense imperative phrasing for mission names (e.g. "Add rate limiting", not "Rate limiting added").
```

- [ ] **Step 3: Verify no old terms remain in this file**

```bash
grep -i "task" skills/create-mission/SKILL.md
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add skills/create-mission/
git commit -m "feat: rename create-task skill to create-mission"
```

---

### Task 2: Rename remove-task skill

**Files:**
- Rename: `skills/remove-task/` → `skills/remove-mission/`
- Modify: `skills/remove-mission/SKILL.md`

- [ ] **Step 1: Rename the directory**

```bash
git mv skills/remove-task skills/remove-mission
```

- [ ] **Step 2: Replace SKILL.md content**

Write the following to `skills/remove-mission/SKILL.md`:

```markdown
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
```

- [ ] **Step 3: Verify no old terms remain**

```bash
grep -i "task" skills/remove-mission/SKILL.md
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add skills/remove-mission/
git commit -m "feat: rename remove-task skill to remove-mission"
```

---

### Task 3: Rename start-task skill

**Files:**
- Rename: `skills/start-task/` → `skills/start-mission/`
- Modify: `skills/start-mission/SKILL.md`

- [ ] **Step 1: Rename the directory**

```bash
git mv skills/start-task skills/start-mission
```

- [ ] **Step 2: Replace SKILL.md content**

Write the following to `skills/start-mission/SKILL.md`:

```markdown
---
name: start-mission
description: Use when the user wants to begin working on a mission from the project's MISSIONS.md. Reads the mission spec and kicks off brainstorming and implementation.
---

# Start Mission

Begin implementing a mission recorded in `MISSIONS.md` at the root of the current project.

## Steps

1. **Read the mission spec** — find `MISSIONS.md` at the project root. List available missions if the user hasn't specified which one. Read the full `## Mission N: Name` section and extract:
   - **Goal** — why this mission exists and what it accomplishes
   - **Background** — context and motivation
   - **Notes** — constraints and decisions (omit from context if absent)
   - **Depends on** — prerequisite missions (omit from context if absent)
   - Implementation detail — phases, sub-items, cross-references to `GAPS.md`

2. **Check dependencies** — if a `**Depends on:**` field is present:
   - Parse each comma-separated dependency as a full `Mission N: Name` string.
   - For each, scan `# Outstanding Missions` in `MISSIONS.md` for a matching `## Mission N: Name` heading (exact string match).
   - If any are found in Outstanding Missions (unmet dependencies):
     - List them by full heading.
     - Ask: *"These missions are still outstanding. Do you want to continue anyway?"*
     - If the user declines, stop.
     - If the user confirms, proceed to step 3.
   - A dependency not found in `# Outstanding Missions` is treated as satisfied (completed or removed) — proceed without warning.

3. **Invoke `superpowers:brainstorming`** — pass the full mission spec as structured context, explicitly calling out Goal, Background, Notes (if present), Depends on (if present), and implementation detail as separate inputs. Include this definition of done:

   > Definition of done:
   > 1. Implementation complete, all tests pass, changes committed.
   > 2. Invoke `captain:finish-mission` to handle documentation updates and cleanup.

## Notes

- Keep the DONE criteria minimal — just implementation + calling `captain:finish-mission`. Doc updates and cleanup are handled by `captain:finish-mission`, not baked into the brainstorming plan.
- If the mission is too large to complete in one session, update `MISSIONS.md` to reflect remaining phases instead of removing it, and skip `captain:finish-mission` until the mission is fully done.
```

- [ ] **Step 3: Verify no old terms remain**

```bash
grep -i "task" skills/start-mission/SKILL.md
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add skills/start-mission/
git commit -m "feat: rename start-task skill to start-mission (with dependency check)"
```

---

### Task 4: Rename finish-task skill

**Files:**
- Rename: `skills/finish-task/` → `skills/finish-mission/`
- Modify: `skills/finish-mission/SKILL.md`

- [ ] **Step 1: Rename the directory**

```bash
git mv skills/finish-task skills/finish-mission
```

- [ ] **Step 2: Replace SKILL.md content**

Write the following to `skills/finish-mission/SKILL.md`:

```markdown
---
name: finish-mission
description: Use when implementation of a mission is complete and committed, to handle all documentation updates and cleanup. Invoked as the final step of start-mission.
---

# Finish Mission

Complete all post-implementation steps after a mission is done: update every relevant doc, then clean up mission and gap tracking.

## Steps

1. **Update all project documentation** — look at what changed (git diff for the mission, or ask the user which mission was completed). Update every file that references the changed area:
   - `README.md` — if the feature is user-visible or changes setup/usage
   - `CLAUDE.md` — if the implementation affects how Claude should work in this project
   - Deployment docs (`docs/`, `deployment.md`, `setup.sh`, etc.) — if deployment steps changed
   - Any other `.md` files that describe or reference the changed area
   - Run doc generation scripts if present (e.g. `cargo doc`, `typedoc`)

2. **Clean up tracking files** — use the mission management skills:
   - `captain:remove-mission` — move the completed mission from the active section to the `# Completed` section of `MISSIONS.md`
   - `captain:remove-code-gap` — remove any gaps from `GAPS.md` resolved by this mission
   - `captain:save-code-gap` — record any new gaps discovered during implementation

## Notes

- Don't assume which docs need updating — look at what actually changed and be comprehensive. Check git diff rather than relying on what was mentioned during implementation.
- If a doc file doesn't exist, skip it rather than creating it (unless it's clearly needed).
```

- [ ] **Step 3: Verify no old terms remain**

```bash
grep -i "task" skills/finish-mission/SKILL.md
```

Expected: no output.

- [ ] **Step 4: Commit**

```bash
git add skills/finish-mission/
git commit -m "feat: rename finish-task skill to finish-mission"
```

---

### Task 5: Update init-project-docs skill

**Files:**
- Modify: `skills/init-project-docs/SKILL.md`

- [ ] **Step 1: Replace SKILL.md content**

Write the following to `skills/init-project-docs/SKILL.md`:

```markdown
---
name: init-project-docs
description: Initialize standard project docs (MISSIONS.md, TODO.md, GAPS.md, IDEAS.md, README.md, CLAUDE.md, docs/notes/) at the project root if they don't exist, and verify existing files conform to the expected structure. Use when starting work on a project or when these files may be missing.
---

# Init Project Docs

Ensure all standard project documentation files and directories exist at the project root and conform to the expected structure.

## Steps

1. **Locate the project root** — the nearest ancestor directory containing `CLAUDE.md`, `package.json`, `Cargo.toml`, or `.git`.

2. **README.md** — check if it exists.
   - If missing, create it with a `# <project-name>` header (derive name from the directory name), a brief placeholder description, and the following blurb about the other root docs:
     ```markdown
     ## Project Docs

     | File | Purpose |
     | ---- | ------- |
     | [MISSIONS.md](MISSIONS.md) | Structured mission backlog — numbered missions with phases and sub-items |
     | [TODO.md](TODO.md) | Free-form scratchpad for quick notes, reminders, and in-progress thoughts |
     | [GAPS.md](GAPS.md) | Known code stubs, unimplemented functions, and placeholder values |
     | [IDEAS.md](IDEAS.md) | Long-term ideas and future directions, no commitment implied |
     ```
   - If it exists, leave it alone.

3. **CLAUDE.md** — check if it exists.
   - If missing, create it with a `# <project-name> — Claude Code Context` header and the following blurb followed by placeholder sections:
     ```markdown
     ## Project Docs

     | File | Purpose |
     | ---- | ------- |
     | [MISSIONS.md](MISSIONS.md) | Structured mission backlog — numbered missions with phases and sub-items |
     | [TODO.md](TODO.md) | Free-form scratchpad for quick notes, reminders, and in-progress thoughts |
     | [GAPS.md](GAPS.md) | Known code stubs, unimplemented functions, and placeholder values |
     | [IDEAS.md](IDEAS.md) | Long-term ideas and future directions, no commitment implied |

     ## Overview

     ## Commands

     ## Key Patterns
     ```
   - If it exists, leave it alone.

4. **docs/ and docs/notes/** — check if the directories exist.
   - Create `docs/` if missing.
   - Create `docs/notes/` if missing.
   - Place a `.gitkeep` in `docs/notes/` if it's empty so it's tracked by git.

5. **MISSIONS.md** — check if it exists.
   - If missing, create it:
     ```markdown
     # Outstanding Missions

     See also: [GAPS.md](GAPS.md) — known code stubs to implement | [IDEAS.md](IDEAS.md) — long-term ideas

     # Completed Missions
     ```
   - If it exists, verify:
     - Has a `# Outstanding Missions` header
     - Has a `# Completed Missions` section (add it at the bottom if missing)
     - All mission headings follow the format `## Mission N: Mission Name` (sequential integers, colon separator)
     - Has the `See also:` footer line after `# Outstanding Missions` (add it if missing)
     - Warn the user about any headings that don't conform but do NOT auto-rename them — ask first.

6. **TODO.md** — check if it exists.
   - If missing, create it with only a `# TODO` header and nothing else. This file has no enforced structure — it's a free-form scratchpad.
   - If it exists, leave it alone — there is no enforced structure.

7. **GAPS.md** — check if it exists.
   - If missing, create it:
     ```markdown
     # Code Gaps
     ```
   - If it exists, verify:
     - Has a `# Code Gaps` header (add it if missing)
     - Entries are bullet points in the format: `` - `identifier` (location): description — implementation hint ``
     - Warn the user about malformed entries but do NOT auto-edit — ask first.

8. **IDEAS.md** — check if it exists.
   - If missing, create it with only a `# Ideas` header and nothing else.
   - If it exists, leave it alone — there is no enforced structure.

9. **Confirm** — report which files/directories were created, which already existed, and any structural issues found.
```

- [ ] **Step 2: Verify no old terms remain**

```bash
grep -i "task" skills/init-project-docs/SKILL.md
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add skills/init-project-docs/SKILL.md
git commit -m "feat: update init-project-docs for mission rename"
```

---

### Task 6: Update README.md

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Replace README.md content**

Write the following to `README.md`:

```markdown
# captain

Mission and project management skills for Claude Code.

## Prerequisites

The `superpowers` plugin must be installed before captain. Install it first:

```
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers
```

## Installation

```
claude plugin marketplace add patrickdwyer33/captain
claude plugin install captain
```

## Skills

| Skill | Description |
|---|---|
| `captain:create-mission` | Add a new mission to `MISSIONS.md` |
| `captain:remove-mission` | Move a completed mission to the Completed Missions section, or delete a cancelled mission |
| `captain:start-mission` | Begin implementing a mission; invokes `superpowers:brainstorming` |
| `captain:finish-mission` | Post-implementation cleanup: update docs, move mission to Completed, clean gaps |
| `captain:save-code-gap` | Record a stub or unimplemented function in `GAPS.md` |
| `captain:remove-code-gap` | Remove a resolved gap from `GAPS.md` |
| `captain:init-project-docs` | Initialize standard project docs at the project root |

## Declaring as a Project Dependency

Claude Code has no native plugin dependency mechanism. Signal that a project requires captain by adding this to the project's `CLAUDE.md`:

    ## Required Plugins
    - superpowers — https://github.com/obra/superpowers
    - captain — https://github.com/patrickdwyer33/captain

Team members who open the project in Claude Code will see this requirement in their context.

## License

MIT
```

- [ ] **Step 2: Verify no old terms remain**

```bash
grep -i "task" README.md
```

Expected: no output.

- [ ] **Step 3: Commit**

```bash
git add README.md
git commit -m "docs: update README for mission rename"
```

---

### Task 7: Update task-dependencies design spec

**Files:**
- Modify: `docs/superpowers/specs/2026-03-21-task-dependencies-design.md`

- [ ] **Step 1: Replace spec content**

Write the following to `docs/superpowers/specs/2026-03-21-task-dependencies-design.md`:

```markdown
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
```

- [ ] **Step 2: Verify no old terms remain**

```bash
grep -i "task" docs/superpowers/specs/2026-03-21-task-dependencies-design.md
```

Expected: no output (the filename itself contains the date, not "task", so this is fine).

- [ ] **Step 3: Commit**

```bash
git add docs/superpowers/specs/2026-03-21-task-dependencies-design.md
git commit -m "docs: update mission-dependencies spec for mission rename"
```

---

### Task 8: Final verification

**Files:** All modified files

- [ ] **Step 1: Grep entire repo for old task-specific terms**

```bash
grep -ri "\btask\b" skills/ README.md docs/superpowers/specs/
```

Expected: no output. Any matches indicate a missed substitution — fix and commit before proceeding.

- [ ] **Step 2: Verify all four skill directories exist under the new names**

```bash
ls skills/
```

Expected output includes: `create-mission/`, `remove-mission/`, `start-mission/`, `finish-mission/`, `init-project-docs/`, `save-code-gap/`, `remove-code-gap/`

Expected output does NOT include: `create-task/`, `remove-task/`, `start-task/`, `finish-task/`

- [ ] **Step 3: Verify all SKILL.md frontmatter names are correct**

```bash
grep "^name:" skills/*/SKILL.md
```

Expected:
```
skills/create-mission/SKILL.md:name: create-mission
skills/finish-mission/SKILL.md:name: finish-mission
skills/init-project-docs/SKILL.md:name: init-project-docs
skills/remove-code-gap/SKILL.md:name: remove-code-gap
skills/remove-mission/SKILL.md:name: remove-mission
skills/save-code-gap/SKILL.md:name: save-code-gap
skills/start-mission/SKILL.md:name: start-mission
```
