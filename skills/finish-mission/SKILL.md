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

3. **Clean up tracking files** — use the mission management skills:
   - `captain:remove-mission` — invoke the **complete path** directly (this is always a completion, not a deletion — skip the "done or cancelling?" prompt and proceed straight to the Complete path steps)
   - `captain:remove-code-gap` — remove any gaps from `GAPS.md` resolved by this mission
   - `captain:save-code-gap` — record any new gaps discovered during implementation

## Notes

- **Discovery before editing** — always complete step 1 fully before writing any doc updates. The most common failure mode is updating only `CLAUDE.md` and missing `README.md`, `docs/`, deployment guides, and other project-specific docs.
- Check git diff rather than relying on what was mentioned during implementation — the diff is the source of truth.
- If a doc file doesn't exist, skip it rather than creating it (unless it's clearly needed).
