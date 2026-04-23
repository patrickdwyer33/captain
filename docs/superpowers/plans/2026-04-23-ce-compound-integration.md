# ce-compound Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Integrate the `ce-compound` skill from `EveryInc/compound-engineering-plugin` into captain's `finish-mission` flow so reusable lessons are captured to `docs/solutions/` at mission completion.

**Architecture:** Restructure `finish-mission` to 5 steps with a new step 3 that identifies lesson candidates, asks the user to confirm, and invokes `/ce-compound` for each confirmed lesson with captain's writing standard injected. Captain owns `docs/solutions/` setup via `init-project-docs`; ce-compound's own discoverability patch becomes a no-op.

**Tech Stack:** Markdown skill files only — no runnable code, no test runner.

---

## File Structure

| Action | Path | Purpose |
|--------|------|---------|
| Modify | `skills/finish-mission/SKILL.md` | Insert new step 3 (lesson capture), renumber old 3→4 and 4→5 |
| Modify | `skills/init-project-docs/SKILL.md` | Create `docs/solutions/` in step 4; add Project Docs table row in both README and CLAUDE.md templates; add idempotent insertion for existing files |
| Modify | `README.md` | Add compound-engineering-plugin to Prerequisites, matching the superpowers pattern |

---

### Task 1: Insert lesson capture step into `finish-mission`

Restructure `finish-mission` from 4 steps to 5: insert the new lesson capture step as step 3, renumber the existing review gate (old step 3) to step 4, and the cleanup step (old step 4) to step 5. Update the "Do not advance to step 4" phrase in the review gate to "Do not advance to step 5" so it still points to cleanup.

**Files:**
- Modify: `skills/finish-mission/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/finish-mission/SKILL.md` and confirm the current structure has 4 steps:
1. Discover what documentation exists and what changed
2. Update all relevant documentation
3. Review all written content against the writing standard
4. Clean up tracking files

- [ ] **Step 2: Insert the new lesson capture step as step 3**

Insert this block immediately after the closing line of step 2 (the "Run doc generation scripts" bullet) and before the current step 3 ("Review all written content against the writing standard"). The outer fence below uses four backticks so the inner triple-backtick fences are preserved verbatim:

````markdown
3. **Identify compounding lessons and capture confirmed ones** — before reviewing doc updates, check whether this mission produced reusable knowledge worth preserving. This step invokes the `ce-compound` skill from the `compound-engineering-plugin` prerequisite.

   **Signal sources:** Read `git diff` for the mission's full scope, `git log --oneline` for the commit sequence (a chain of "fix" commits often signals a debugging lesson), and your working memory of the mission — specifically anything that surprised you, turned out wrong mid-stream, or established a new convention.

   **Candidate types:**
   - **Bug lesson** — a non-trivial debugging or fix with reusable prevention value
   - **Pattern/convention** — a design decision or code convention worth future adherence
   - **Gotcha** — a non-obvious constraint, workaround, or environment quirk discovered during the work

   **Skip lesson identification entirely** if the mission was mechanical — renames, version bumps, dependency updates, boilerplate. State this plainly and proceed to step 4.

   **Propose candidates to the user in batch form:**
   > Found N candidate lessons:
   > 1. [type]: one-line summary — why it's reusable
   > 2. [type]: one-line summary — why it's reusable
   >
   > Capture? Respond per lesson: `y` (full mode), `lightweight` (single-pass), or `n` (skip).

   **For each confirmed lesson (`y`)**, invoke `ce-compound` with captain's writing standard in the context arg:
   ```
   /ce-compound [lesson summary] — writing standard: output must be stateless (no "NEW:", "as discussed", first-person voice, temporal anchors, documented misunderstandings) and reflect current understanding only (no stale concepts, no traces of wrong paths)
   ```

   **For each lightweight-confirmed lesson**, invoke the same command with `--lightweight`:
   ```
   /ce-compound --lightweight [lesson summary] — writing standard: output must be stateless (no "NEW:", "as discussed", first-person voice, temporal anchors, documented misunderstandings) and reflect current understanding only (no stale concepts, no traces of wrong paths)
   ```

   If no candidates are found, state that plainly and proceed to step 4. The review gate in step 4 will cover any files ce-compound produced via `git diff`.

````

- [ ] **Step 3: Renumber the old step 3 (review gate) to step 4**

Change the heading from `3. **Review all written content against the writing standard**` to `4. **Review all written content against the writing standard**`.

Within the same step, change the closing phrase `Do not advance to step 4 until all written content passes.` to `Do not advance to step 5 until all written content passes.`.

- [ ] **Step 4: Renumber the old step 4 (cleanup) to step 5**

Change the heading from `4. **Clean up tracking files**` to `5. **Clean up tracking files**`.

- [ ] **Step 5: Verify the Notes section still references correct step numbers**

Read the Notes section (starts at line ~37). Confirm the first note still reads: `**Discovery before editing** — always complete step 1 fully before writing any doc updates.` — this refers to step 1 which is unchanged, so no edit needed. No other notes reference step numbers.

- [ ] **Step 6: Read the full file back and verify structure**

Read `skills/finish-mission/SKILL.md` and confirm:
- Step 1: Discover what documentation exists and what changed
- Step 2: Update all relevant documentation (with writing standard callout)
- Step 3: Identify compounding lessons and capture confirmed ones (NEW)
- Step 4: Review all written content against the writing standard (closing line now says "step 5")
- Step 5: Clean up tracking files
- Notes section intact, references "step 1"

- [ ] **Step 7: Commit**

```bash
git add skills/finish-mission/SKILL.md
git commit -m "feat: add ce-compound lesson capture step to finish-mission"
```

---

### Task 2: Add `docs/solutions/` directory creation to `init-project-docs`

Extend step 4 of `init-project-docs` (which currently handles `docs/` and `docs/notes/`) to also create `docs/solutions/` and place a `.gitkeep` in it. This gives captain ownership of the `docs/solutions/` directory so ce-compound's own discoverability patch becomes a no-op on captain-initialized projects.

**Files:**
- Modify: `skills/init-project-docs/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/init-project-docs/SKILL.md` and confirm step 4 currently reads:

```
4. **docs/ and docs/notes/** — check if the directories exist.
   - Create `docs/` if missing.
   - Create `docs/notes/` if missing.
   - Place a `.gitkeep` in `docs/notes/` if it's empty so it's tracked by git.
```

- [ ] **Step 2: Replace step 4 with the expanded version**

Replace the current step 4 block with:

```markdown
4. **docs/, docs/notes/, and docs/solutions/** — check if the directories exist.
   - Create `docs/` if missing.
   - Create `docs/notes/` if missing.
   - Create `docs/solutions/` if missing.
   - Place a `.gitkeep` in `docs/notes/` if it's empty so it's tracked by git.
   - Place a `.gitkeep` in `docs/solutions/` if it's empty so it's tracked by git.
```

- [ ] **Step 3: Read the file back and confirm step 4 matches the expanded version**

Read `skills/init-project-docs/SKILL.md` step 4 and verify it creates all three directories and places `.gitkeep` in the two that will be empty at init time.

- [ ] **Step 4: Commit**

```bash
git add skills/init-project-docs/SKILL.md
git commit -m "feat: create docs/solutions/ in init-project-docs"
```

---

### Task 3: Add `docs/solutions/` row to Project Docs tables in the "if missing" templates

Add one row to the Project Docs table in both the README.md (step 2) and CLAUDE.md (step 3) "if missing" templates so freshly initialized projects advertise `docs/solutions/` as a known knowledge artifact.

**Files:**
- Modify: `skills/init-project-docs/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/init-project-docs/SKILL.md`. Confirm both the README.md template (in step 2) and the CLAUDE.md template (in step 3) currently contain this Project Docs table:

```markdown
| File | Purpose |
| ---- | ------- |
| [MISSIONS.md](MISSIONS.md) | Structured mission backlog — numbered missions with phases and sub-items |
| [TODO.md](TODO.md) | Free-form scratchpad for quick notes, reminders, and in-progress thoughts |
| [GAPS.md](GAPS.md) | Known code stubs, unimplemented functions, and placeholder values |
| [IDEAS.md](IDEAS.md) | Long-term ideas and future directions, no commitment implied |
```

- [ ] **Step 2: Add the `docs/solutions/` row to the README template (step 2)**

In the README.md "if missing" template inside step 2, find the IDEAS.md row and insert this row immediately after it:

```markdown
     | [docs/solutions/](docs/solutions/) | Compounding knowledge — bug postmortems, patterns, and gotchas captured by ce-compound |
```

Preserve the indentation (5 spaces) matching the surrounding table rows inside the code fence.

- [ ] **Step 3: Add the `docs/solutions/` row to the CLAUDE.md template (step 3)**

In the CLAUDE.md "if missing" template inside step 3, find the IDEAS.md row and insert this row immediately after it:

```markdown
     | [docs/solutions/](docs/solutions/) | Compounding knowledge — bug postmortems, patterns, and gotchas captured by ce-compound |
```

Preserve the same 5-space indentation.

- [ ] **Step 4: Read the file back and verify both templates**

Read `skills/init-project-docs/SKILL.md` and confirm:
- The README.md template in step 2 now has 5 rows in the Project Docs table, ending with the `docs/solutions/` row
- The CLAUDE.md template in step 3 now has 5 rows in the Project Docs table, ending with the `docs/solutions/` row
- No other content was changed

- [ ] **Step 5: Commit**

```bash
git add skills/init-project-docs/SKILL.md
git commit -m "feat: advertise docs/solutions/ in Project Docs templates"
```

---

### Task 4: Add idempotent `docs/solutions/` row insertion to the "if exists" branches

Update the "if exists" branches of both step 2 (README.md) and step 3 (CLAUDE.md) so that an existing file gets the `docs/solutions/` row inserted into its Project Docs table when missing. This is the idempotent counterpart to Task 3.

**Files:**
- Modify: `skills/init-project-docs/SKILL.md`

- [ ] **Step 1: Read the current file**

Read `skills/init-project-docs/SKILL.md`. Confirm:
- Step 2 (README.md) currently ends its "if exists" branch with: `If it exists, leave it alone.`
- Step 3 (CLAUDE.md) currently ends its "if exists" branch with: `If it exists, check whether it contains a ## Documentation Standards section. If the section is missing, append the Documentation Standards block (shown in the "if missing" template above) to the end of the file.`

- [ ] **Step 2: Replace the README.md "if exists" line**

In step 2, replace `If it exists, leave it alone.` with (outer fence uses four backticks to preserve the inner triple-backtick fence):

````markdown
   - If it exists, check whether the Project Docs table contains a row for `docs/solutions/`. If the row is missing, insert it immediately after the `IDEAS.md` row:
     ```markdown
     | [docs/solutions/](docs/solutions/) | Compounding knowledge — bug postmortems, patterns, and gotchas captured by ce-compound |
     ```
     If the Project Docs table itself is missing from the file, warn the user rather than adding one — do not auto-insert the whole table.
````

- [ ] **Step 3: Extend the CLAUDE.md "if exists" branch**

In step 3, replace the current `If it exists, ...` line with (outer fence uses four backticks to preserve the inner triple-backtick fence):

````markdown
   - If it exists, perform two idempotent checks:
     - Check whether the Project Docs table contains a row for `docs/solutions/`. If the row is missing, insert it immediately after the `IDEAS.md` row:
       ```markdown
       | [docs/solutions/](docs/solutions/) | Compounding knowledge — bug postmortems, patterns, and gotchas captured by ce-compound |
       ```
       If the Project Docs table itself is missing from the file, warn the user rather than adding one.
     - Check whether the file contains a `## Documentation Standards` section. If the section is missing, append the Documentation Standards block (shown in the "if missing" template above) to the end of the file.
````

- [ ] **Step 4: Read the file back and verify both branches**

Read `skills/init-project-docs/SKILL.md` and confirm:
- Step 2 "if exists" branch performs the Project Docs table row check
- Step 3 "if exists" branch performs both checks: Project Docs row and Documentation Standards section
- No other content was changed

- [ ] **Step 5: Commit**

```bash
git add skills/init-project-docs/SKILL.md
git commit -m "feat: idempotent docs/solutions/ row insertion for existing files"
```

---

### Task 5: Add compound-engineering-plugin to captain's Prerequisites

Mirror exactly how `superpowers` is treated today: document the plugin as a prerequisite in README.md, with one sentence explaining why captain needs it.

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Read the current README**

Read `README.md` and confirm the Prerequisites section currently reads (outer fence uses four backticks to preserve the inner triple-backtick fence):

````markdown
## Prerequisites

The `superpowers` plugin must be installed before captain. Install it first:

```
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers
```

`jq` must also be installed:
- macOS: `brew install jq`
- Linux: `sudo apt install jq` or `sudo yum install jq`
````

- [ ] **Step 2: Add the compound-engineering-plugin prerequisite block**

Replace the entire Prerequisites section with (outer fence uses four backticks to preserve the inner triple-backtick fences):

````markdown
## Prerequisites

The `superpowers` plugin must be installed before captain. Install it first:

```
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers
```

The `compound-engineering-plugin` must also be installed. Captain's `finish-mission` skill invokes its `ce-compound` skill to capture reusable lessons to `docs/solutions/`.

```
claude plugin marketplace add EveryInc/compound-engineering-plugin
claude plugin install compound-engineering
```

`jq` must also be installed:
- macOS: `brew install jq`
- Linux: `sudo apt install jq` or `sudo yum install jq`
````

Note: verify the exact marketplace and plugin install commands for compound-engineering-plugin by checking its README before committing. If the install commands differ from the assumed `claude plugin marketplace add EveryInc/compound-engineering-plugin` / `claude plugin install compound-engineering` pattern, adjust to match what that plugin documents. Do not invent commands.

- [ ] **Step 3: Verify the install commands match the upstream plugin's documented commands**

Run:
```bash
gh api repos/EveryInc/compound-engineering-plugin/contents/README.md --jq '.content' | base64 -d | grep -iA3 'claude plugin'
```

Read the output. If the plugin documents different install commands than what Task 5 Step 2 assumed, edit README.md to match the upstream commands exactly.

- [ ] **Step 4: Update the "Declaring as a Project Dependency" section**

In the block that starts with `## Declaring as a Project Dependency`, the README currently lists:

```
    ## Required Plugins
    - superpowers — https://github.com/obra/superpowers
    - captain — https://github.com/patrickdwyer33/captain
```

Replace that block with:

```
    ## Required Plugins
    - superpowers — https://github.com/obra/superpowers
    - compound-engineering — https://github.com/EveryInc/compound-engineering-plugin
    - captain — https://github.com/patrickdwyer33/captain
```

- [ ] **Step 5: Read the file back and verify**

Read `README.md` and confirm:
- Prerequisites section lists superpowers, compound-engineering-plugin, and jq
- Install commands for compound-engineering-plugin match the upstream documentation (not the assumed pattern, if they differed)
- Required Plugins block includes compound-engineering

- [ ] **Step 6: Commit**

```bash
git add README.md
git commit -m "docs: add compound-engineering-plugin to Prerequisites"
```
