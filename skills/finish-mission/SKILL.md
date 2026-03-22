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
