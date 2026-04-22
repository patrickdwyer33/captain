# Stateless Documentation Standard Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bake a stateless writing standard into captain's skill workflows so all written output is readable by anyone, not just the person who was in the writing session.

**Architecture:** Create a single reference doc (`skills/writing-standard/RULES.md`) as the source of truth for the standard, inject the standard into project CLAUDE.md via `init-project-docs`, and add early reminders + a review gate to the skills that write content.

**Tech Stack:** Markdown skill files only — no code, no test runner.

---

## File Structure

| Action | Path | Purpose |
|--------|------|---------|
| Create | `skills/writing-standard/RULES.md` | Single source of truth for the stateless writing standard |
| Modify | `skills/finish-mission/SKILL.md` | Add early injection + review gate step |
| Modify | `skills/create-mission/SKILL.md` | Add writing standard reminder at step 3 |
| Modify | `skills/save-code-gap/SKILL.md` | Add brief reminder when writing the gap entry |
| Modify | `skills/init-project-docs/SKILL.md` | Add writing standard injection to CLAUDE.md step |

---

### Task 1: Create the writing standard reference doc

**Files:**
- Create: `skills/writing-standard/RULES.md`

- [ ] **Step 1: Create the file with the full writing standard**

Create `skills/writing-standard/RULES.md` with this exact content:

```markdown
# Captain Writing Standard

All written content produced under captain workflows must follow these two directives.

## Directive 1: Stateless

Every doc must be fully readable by someone who was not in the conversation that produced it. All context lives in the doc; none lives in the session.

- No session-relative labels: "NEW:", "UPDATED:", "CHANGED:" are banned. Describe what something is now, not that it changed.
- No conversational back-references: "as discussed", "not like this [X]", "per our conversation" are banned.
- Clarifications state the reason, not the trigger: "Use X instead of Y because Z" — not "we clarified that X is correct here."
- No first-person session voice: avoid "I added", "we decided", "I noted". State the fact directly.
- No implicit temporal anchors: "recently added", "just implemented", "at the time of writing" make no sense to a future reader. Drop them or replace with specifics.

## Directive 2: Remove Stale Concepts and Misunderstandings

Docs must reflect current understanding only. Anything corrected, superseded, or misread during the session must be purged — not documented as a correction.

- If a misunderstanding was clarified, the final doc states only the correct thing. No trace of the wrong path.
- If a concept was renamed, replaced, or abandoned mid-session, remove all references to the old concept.
- Document the destination, not the journey.
```

- [ ] **Step 2: Verify the file reads back correctly**

Read `skills/writing-standard/RULES.md` and confirm both directives and all bullet points are present.

- [ ] **Step 3: Commit**

```bash
git add skills/writing-standard/RULES.md
git commit -m "feat: add writing standard reference doc"
```

---

### Task 2: Add early injection to `finish-mission`

Add a writing standard reminder at the top of step 2 (before Claude writes any docs) so the rule is active during writing, not just checked after.

**Files:**
- Modify: `skills/finish-mission/SKILL.md:18` (step 2 heading)

- [ ] **Step 1: Read the current file**

Read `skills/finish-mission/SKILL.md` and confirm step 2 currently begins with:
```
2. **Update all relevant documentation** — work through your list from step 1. Common candidates:
```

- [ ] **Step 2: Add the writing standard callout to step 2**

Replace the step 2 opening line with:

```markdown
2. **Update all relevant documentation** — before writing anything, apply the captain writing standard (`skills/writing-standard/RULES.md`): all content must be stateless (no session labels, back-references, first-person voice, or temporal anchors) and free of stale concepts. Work through your list from step 1. Common candidates:
```

- [ ] **Step 3: Read the file back and confirm the callout is present**

Read `skills/finish-mission/SKILL.md` and confirm the writing standard reference appears in step 2.

- [ ] **Step 4: Commit**

```bash
git add skills/finish-mission/SKILL.md
git commit -m "feat: inject writing standard reminder into finish-mission step 2"
```

---

### Task 3: Add review gate to `finish-mission`

Add a new step 3 between doc updates and cleanup. The skill must not advance to `remove-mission` until written content passes the check.

**Files:**
- Modify: `skills/finish-mission/SKILL.md` (insert new step 3, renumber old step 3 to step 4)

- [ ] **Step 1: Read the current file**

Read `skills/finish-mission/SKILL.md` and confirm step 3 currently reads:
```
3. **Clean up tracking files** — use the mission management skills:
```

- [ ] **Step 2: Insert the review gate as new step 3**

Insert the following block immediately before the current step 3 (`Clean up tracking files`):

```markdown
3. **Review all written content against the writing standard** — re-read every doc written or updated in step 2 and check each against both directives from `skills/writing-standard/RULES.md`:
   - **Stateless:** no session-relative labels ("NEW:", "UPDATED:"), no back-references ("as discussed", "not like this [X]"), no first-person session voice, no temporal anchors ("recently added")
   - **Clean:** no stale concepts, no documented misunderstandings — state only what is currently correct

   Fix any violations before proceeding. Do not advance to step 4 until all written content passes.

```

- [ ] **Step 3: Renumber the old step 3 to step 4**

Change the old `3. **Clean up tracking files**` heading to `4. **Clean up tracking files**`.

- [ ] **Step 4: Read the file back and verify structure**

Read `skills/finish-mission/SKILL.md` and confirm:
- Step 2 has the writing standard callout
- Step 3 is the new review gate
- Step 4 is "Clean up tracking files"
- The Notes section still refers to step 1 (unchanged)

- [ ] **Step 5: Commit**

```bash
git add skills/finish-mission/SKILL.md
git commit -m "feat: add writing standard review gate to finish-mission"
```

---

### Task 4: Add writing standard reminder to `create-mission`

Add a reminder at step 3 (gather mission details) so Claude applies the standard when writing `goal`, `background`, `notes`, and `body`.

**Files:**
- Modify: `skills/create-mission/SKILL.md:27` (step 3)

- [ ] **Step 1: Read the current file**

Read `skills/create-mission/SKILL.md` and confirm step 3 starts with:
```
3. **Gather mission details** — ask the user for:
```
and lists Title, Goal, Background, Notes, Depends on, Body.

- [ ] **Step 2: Add the writing standard note after the field list in step 3**

After the Body bullet point and before step 4, insert:

```markdown
   > **Writing standard:** Apply `skills/writing-standard/RULES.md` when writing these fields. `goal`, `background`, `notes`, and `body` must be stateless (no "as discussed", no session labels, no first-person voice) and reflect current understanding only — no stale concepts or documented misunderstandings.
```

- [ ] **Step 3: Read the file back and confirm**

Read `skills/create-mission/SKILL.md` and confirm the writing standard note appears between the Body bullet and step 4.

- [ ] **Step 4: Commit**

```bash
git add skills/create-mission/SKILL.md
git commit -m "feat: add writing standard reminder to create-mission step 3"
```

---

### Task 5: Add writing standard reminder to `save-code-gap`

Add a brief reminder at step 3 (write the entry) so gap descriptions are stateless and reflect current understanding.

**Files:**
- Modify: `skills/save-code-gap/SKILL.md:28` (step 3)

- [ ] **Step 1: Read the current file**

Read `skills/save-code-gap/SKILL.md` and confirm step 3 starts with:
```
3. **Write the entry** — append to the bullet list in `GAPS.md` using this format:
```

- [ ] **Step 2: Add the writing standard note to step 3**

Replace the step 3 opening line with:

```markdown
3. **Write the entry** — apply the captain writing standard (`skills/writing-standard/RULES.md`): describe what is unimplemented and why, not the session that discovered it. No "as discussed", no session context, no stale concepts. Append to the bullet list in `GAPS.md` using this format:
```

- [ ] **Step 3: Read the file back and confirm**

Read `skills/save-code-gap/SKILL.md` and confirm the writing standard reference appears in step 3.

- [ ] **Step 4: Commit**

```bash
git add skills/save-code-gap/SKILL.md
git commit -m "feat: add writing standard reminder to save-code-gap"
```

---

### Task 6: Add CLAUDE.md writing standard injection to `init-project-docs`

`init-project-docs` must ensure the writing standard section exists in CLAUDE.md — whether the file is new or pre-existing. The operation is idempotent.

**Files:**
- Modify: `skills/init-project-docs/SKILL.md` (step 3, CLAUDE.md handling)

The writing standard section to inject into CLAUDE.md:

```markdown
## Documentation Standards

All written content in this project — docs, mission fields, gap descriptions, code comments — must follow two directives.

**Stateless:** Every doc must be readable by someone who was not in the conversation that produced it.
- No session-relative labels ("NEW:", "UPDATED:", "CHANGED:")
- No conversational back-references ("as discussed", "not like this [X]", "per our conversation")
- Clarifications state the reason, not the trigger ("Use X because Y" — not "we clarified X")
- No first-person session voice ("I added", "we decided")
- No implicit temporal anchors ("recently added", "just implemented")

**Remove stale concepts and misunderstandings:** Docs reflect current understanding only.
- If a misunderstanding was clarified, state only the correct thing — no trace of the wrong path
- If a concept was renamed or abandoned, remove all references to the old concept
- Document the destination, not the journey
```

- [ ] **Step 1: Read the current file**

Read `skills/init-project-docs/SKILL.md` and confirm step 3 (CLAUDE.md) has two branches:
- "If missing, create it with..."
- "If it exists, leave it alone."

- [ ] **Step 2: Update the "if missing" branch to include the writing standard section**

In step 3, the "if missing" case creates CLAUDE.md with a header + Project Docs table + Overview/Commands/Key Patterns sections. Add the Documentation Standards section after the Project Docs table and before `## Overview`. The new "if missing" template becomes:

````markdown
   - If missing, create it with a `# <project-name> — Claude Code Context` header and the following content:
     ```markdown
     ## Project Docs

     | File | Purpose |
     | ---- | ------- |
     | [MISSIONS.md](MISSIONS.md) | Structured mission backlog — numbered missions with phases and sub-items |
     | [TODO.md](TODO.md) | Free-form scratchpad for quick notes, reminders, and in-progress thoughts |
     | [GAPS.md](GAPS.md) | Known code stubs, unimplemented functions, and placeholder values |
     | [IDEAS.md](IDEAS.md) | Long-term ideas and future directions, no commitment implied |

     ## Documentation Standards

     All written content in this project — docs, mission fields, gap descriptions, code comments — must follow two directives.

     **Stateless:** Every doc must be readable by someone who was not in the conversation that produced it.
     - No session-relative labels ("NEW:", "UPDATED:", "CHANGED:")
     - No conversational back-references ("as discussed", "not like this [X]", "per our conversation")
     - Clarifications state the reason, not the trigger ("Use X because Y" — not "we clarified X")
     - No first-person session voice ("I added", "we decided")
     - No implicit temporal anchors ("recently added", "just implemented")

     **Remove stale concepts and misunderstandings:** Docs reflect current understanding only.
     - If a misunderstanding was clarified, state only the correct thing — no trace of the wrong path
     - If a concept was renamed or abandoned, remove all references to the old concept
     - Document the destination, not the journey

     ## Overview

     ## Commands

     ## Key Patterns
     ```
````

- [ ] **Step 3: Update the "if it exists" branch**

Replace "If it exists, leave it alone." with:

```markdown
   - If it exists, check whether it contains a `## Documentation Standards` section. If the section is missing, append the Documentation Standards block (shown above in the "if missing" template) to the end of the file.
```

- [ ] **Step 4: Read the file back and verify both branches**

Read `skills/init-project-docs/SKILL.md` step 3 and confirm:
- The "if missing" template includes `## Documentation Standards` between the Project Docs table and `## Overview`
- The "if it exists" branch checks for the section and appends it if missing

- [ ] **Step 5: Commit**

```bash
git add skills/init-project-docs/SKILL.md
git commit -m "feat: inject documentation standards into CLAUDE.md via init-project-docs"
```

---

### Task 7: Save the known gap

The plugin has no mechanism to sync the CLAUDE.md writing standard section when captain updates. Record this as a gap.

**Files:**
- Modify: `GAPS.md` (or create if missing at captain project root)

- [ ] **Step 1: Check whether GAPS.md exists at the captain project root**

Run:
```bash
ls /Users/patrick/dev/captain/GAPS.md
```

If missing, create it:
```bash
echo "# Code Gaps" > /Users/patrick/dev/captain/GAPS.md
```

- [ ] **Step 2: Append the gap entry**

Append to `GAPS.md`:

```markdown
- `sync-standards` (captain plugin): no mechanism to update a project's CLAUDE.md `## Documentation Standards` section when the captain plugin updates — implement via a new `captain:sync-standards` skill or a version-check step in `finish-mission`
```

- [ ] **Step 3: Commit**

```bash
git add GAPS.md
git commit -m "chore: record sync-standards gap"
```
