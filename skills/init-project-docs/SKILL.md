---
name: init-project-docs
description: Use when starting a new project or when standard project docs (MISSIONS.md, GAPS.md, IDEAS.md, CLAUDE.md, etc.) may be missing or structurally invalid.
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
     | [docs/solutions/](docs/solutions/) | Compounding knowledge — bug postmortems, patterns, and gotchas captured by ce-compound |
     ```
   - If it exists, check whether the Project Docs table contains a row for `docs/solutions/`. If the row is missing, insert it immediately after the `IDEAS.md` row:
     ```markdown
     | [docs/solutions/](docs/solutions/) | Compounding knowledge — bug postmortems, patterns, and gotchas captured by ce-compound |
     ```
     If the Project Docs table itself is missing from the file, warn the user rather than adding one — ask first; do not auto-insert the whole table.

3. **CLAUDE.md** — check if it exists.
   - If missing, create it with a `# <project-name> — Claude Code Context` header and the following content:
     ```markdown
     ## Project Docs

     | File | Purpose |
     | ---- | ------- |
     | [MISSIONS.md](MISSIONS.md) | Structured mission backlog — numbered missions with phases and sub-items |
     | [TODO.md](TODO.md) | Free-form scratchpad for quick notes, reminders, and in-progress thoughts |
     | [GAPS.md](GAPS.md) | Known code stubs, unimplemented functions, and placeholder values |
     | [IDEAS.md](IDEAS.md) | Long-term ideas and future directions, no commitment implied |
     | [docs/solutions/](docs/solutions/) | Compounding knowledge — bug postmortems, patterns, and gotchas captured by ce-compound |

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
     - Describe only the current state, not how the work evolved — a reader should not be able to infer what was tried, discarded, or corrected

     ## Overview

     ## Commands

     ## Key Patterns
     ```
   - If it exists, perform two idempotent checks:
     - Check whether the Project Docs table contains a row for `docs/solutions/`. If the row is missing, insert it immediately after the `IDEAS.md` row:
       ```markdown
       | [docs/solutions/](docs/solutions/) | Compounding knowledge — bug postmortems, patterns, and gotchas captured by ce-compound |
       ```
       If the Project Docs table itself is missing from the file, warn the user rather than adding one — ask first.
     - Check whether the file contains a `## Documentation Standards` section. If the section is missing, append the Documentation Standards block (shown in the "if missing" template above) to the end of the file.

4. **docs/, docs/notes/, and docs/solutions/** — check if the directories exist.
   - Create `docs/` if missing.
   - Create `docs/notes/` if missing.
   - Create `docs/solutions/` if missing.
   - Place a `.gitkeep` in `docs/notes/` if it's empty so it's tracked by git.
   - Place a `.gitkeep` in `docs/solutions/` if it's empty so it's tracked by git.

5. **MISSIONS.md** — check if it exists.
   - If missing, it will be created by the generate script in step 9. Do not create it manually.
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

9. **`.captain/` directory and JSONL files** — check if `.captain/` exists at the project root.
   - If missing, create it: `mkdir -p .captain`
   - Create `.captain/missions.jsonl` if missing: `touch .captain/missions.jsonl`
   - Create `.captain/completed.jsonl` if missing: `touch .captain/completed.jsonl`
   - Check `.gitignore`: if `.captain` or `.captain/` appears there, warn the user — these files are the source of truth and must be committed to the repo.
   - Run the generate script to produce `MISSIONS.md` and `COMPLETED.md`:
     ```bash
     bash "${CLAUDE_PLUGIN_ROOT}/scripts/generate.sh"
     ```

10. **Confirm** — report which files/directories were created, which already existed, and any structural issues found. Include the `.captain/` directory and JSONL files in the report.
