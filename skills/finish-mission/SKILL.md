---
name: finish-mission
description: Use when a mission's implementation is complete and committed, to update docs and mark it done.
---

# Finish Mission

Complete all post-implementation steps after a mission is done: update every relevant doc, then clean up mission and gap tracking.

## Steps

1. **Discover what documentation exists and what changed** — before updating anything, build a complete picture:
   - Run `git diff` (or `git log --name-only`) for the mission to see what files changed
   - List all documentation in the project: `README.md`, `docs/`, `CLAUDE.md`, deployment files, etc.
   - For each doc file found, assess whether it references or describes any changed area
   - Make a list of every doc that needs updating — don't start writing yet

2. **Update all relevant documentation** — before writing anything, apply the captain writing standard (`skills/writing-standard/RULES.md`): all content must be stateless (no session labels, back-references, first-person voice, temporal anchors, or documented misunderstandings) and free of stale concepts. Work through your list from step 1. Common candidates:
   - `README.md` — if the feature is user-visible or changes setup/usage
   - `CLAUDE.md` — if the implementation affects how Claude should work in this project
   - Everything in `docs/` — API docs, architecture docs, guides, deployment docs, runbooks, etc.
   - `deployment.md`, `setup.sh`, `INSTALL.md`, or similar — if deployment/setup steps changed
   - Any other `.md` or doc files that describe or reference the changed area
   - Run doc generation scripts if present (e.g. `cargo doc`, `typedoc`)

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

4. **Review all written content against the writing standard** — run `git diff` to confirm which docs were actually modified, then re-read each one and check against both directives from `skills/writing-standard/RULES.md`:
   - **Stateless:** no session-relative labels ("NEW:", "UPDATED:"), no back-references ("as discussed", "not like this [X]"), no first-person session voice, no temporal anchors ("recently added")
   - **No stale concepts:** no documented misunderstandings, no references to renamed or abandoned concepts — state only what is currently correct

   Fix any violations before proceeding. Do not advance to step 5 until all written content passes.

5. **Clean up tracking files** — use the mission management skills:
   - `captain:remove-mission` — invoke the **complete path** directly (this is always a completion, not a deletion — skip the "done or cancelling?" prompt and proceed straight to the Complete path steps)
   - `captain:remove-code-gap` — remove any gaps from `GAPS.md` resolved by this mission
   - `captain:save-code-gap` — record any new gaps discovered during implementation

## Notes

- **Discovery before editing** — always complete step 1 fully before writing any doc updates. The most common failure mode is updating only `CLAUDE.md` and missing `README.md`, `docs/`, deployment guides, and other project-specific docs.
- Check git diff rather than relying on what was mentioned during implementation — the diff is the source of truth.
- If a doc file doesn't exist, skip it rather than creating it (unless it's clearly needed).
