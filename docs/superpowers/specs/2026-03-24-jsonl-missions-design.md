# JSONL-Backed Missions Design

**Date:** 2026-03-24
**Status:** Approved

## Overview

Replace inline markdown editing of `MISSIONS.md` with a JSONL-backed data layer. Missions are stored as structured records in `.captain/missions.jsonl` and `.captain/completed.jsonl`. A bash script shipped with the captain plugin generates `MISSIONS.md` and `COMPLETED.md` from these files. Skills update the JSONL files and invoke the script rather than editing markdown directly.

## Data Layer

Two JSONL files live in `.captain/` at the project root (hidden directory). Both files are committed to the project repo — they are the source of truth.

**`.captain/missions.jsonl`** — one JSON object per line, outstanding missions:
```json
{"id": 1, "title": "Add OAuth login", "goal": "Allow users to sign in with Google.", "background": "Product decision to remove email/password auth by Q2.", "notes": "Requires the user model to support external identity providers.", "depends_on": ["Mission 3: Add rate limiting"], "body": "**Phase 1 — User model changes**\n- Add external_id and provider columns\n- Write migration\n"}
```

**`.captain/completed.jsonl`** — full mission record copied from `missions.jsonl` with `completed_at` added (ISO date string). All fields from the original record are preserved:
```json
{"id": 1, "title": "Add OAuth login", "goal": "Allow users to sign in with Google.", "background": "Product decision to remove email/password auth by Q2.", "notes": "Requires the user model to support external identity providers.", "depends_on": ["Mission 3: Add rate limiting"], "body": "**Phase 1 — ...**\n- ...\n", "completed_at": "2026-03-24"}
```

**Field reference:**

| Field | Required | Notes |
|---|---|---|
| `id` | yes | Permanent integer identifier, never reused |
| `title` | yes | Imperative present-tense name |
| `goal` | yes | One sentence: what this accomplishes and why |
| `background` | yes | Context and motivation |
| `notes` | no | Constraints, decisions already made |
| `depends_on` | no | Array of `"Mission N: Title"` strings |
| `body` | no | Raw markdown for phases or flat bullets (JSON-escaped `\n` for newlines) |
| `completed_at` | completed only | ISO date string (`YYYY-MM-DD`) added when mission completes |

## Generate Script

**Location in repo:** `scripts/generate.sh`

**Stable invocation path (from project root):**
```bash
bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh
```

**Behavior:**
- Reads `.captain/missions.jsonl` → writes `MISSIONS.md`
- Reads `.captain/completed.jsonl` → writes `COMPLETED.md`
- Both output files are fully regenerated on every run — never hand-edited
- Handles missing or empty JSONL files gracefully (produces headers-only output)
- **Invariant:** after any skill mutation, the generate script is always run, so `MISSIONS.md` and `COMPLETED.md` are always current

**`MISSIONS.md` output format** — outstanding missions in ascending id order (lowest first):
```markdown
# Outstanding Missions

See also: [GAPS.md](GAPS.md) — known code stubs to implement | [IDEAS.md](IDEAS.md) — long-term ideas

## Mission 1: Title

**Goal:** ...

**Background:** ...

**Notes:** ... (omitted if field absent)

**Depends on:** Mission 3: ..., Mission 5: ... (omitted if field absent)

[body rendered verbatim, JSON-unescaped, preceded by a blank line] (omitted if field absent)
```

**`COMPLETED.md` output format** — completed missions in descending id order (highest id first). Sort key is `id`, not `completed_at` — this is intentional; id order is stable and predictable.
```markdown
# Completed Missions

## Mission 1: Title

**Goal:** ...

**Background:** ...

**Notes:** ... (omitted if field absent)

**Depends on:** ... (omitted if field absent)

[body rendered verbatim, JSON-unescaped, preceded by a blank line] (omitted if field absent)

**Completed:** 2026-03-24

(If `body` is absent, `**Completed:**` follows immediately after the last present field, separated by a blank line.)
```

The `body` field is emitted as raw markdown: JSON string unescaping is applied (so `\n` becomes a real newline), then the content is written verbatim, preceded by a blank line. If the unescaped body already ends with a newline, no additional newline is appended — the blank line separator before the next field (or end of section) is still exactly one blank line.

## Skill Changes

### `captain:create-mission`

1. If `.captain/`, `.captain/missions.jsonl`, or `.captain/completed.jsonl` don't exist, create them before proceeding (don't require user to run `init-project-docs` first). Creating both JSONL files ensures the id-calculation jq command always has valid inputs.
2. Gather mission details interactively (same prompts as before)
3. Determine next id: find the maximum `id` across both JSONL files and add 1. Both files are guaranteed to exist after step 1 (even if empty), so the command always has valid inputs. On an empty file, `jq` produces `null` from `max`, and `// 0` yields 0:
   ```bash
   jq -rs '[.[] | .id] | max // 0' .captain/missions.jsonl .captain/completed.jsonl
   ```
   Then add 1. Result for two empty files: `0 + 1 = 1`.
4. Build JSON record and append to `.captain/missions.jsonl`. Only prepend a newline guard if the file is non-empty (a leading blank line breaks JSONL parsers):
   ```bash
   [ -s .captain/missions.jsonl ] && printf '\n' >> .captain/missions.jsonl
   echo '{"id":N,...}' >> .captain/missions.jsonl
   ```
   The same newline guard pattern applies when appending to `.captain/completed.jsonl`.
5. Run generate script: `bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh`
6. Confirm to user

### `captain:remove-mission` — branch selection

The skill begins by asking the user whether the mission was completed or cancelled/deleted:

> "Is Mission N done (move to Completed), or are you cancelling/deleting it?"

- If **completed**: follow the complete path below.
- If **cancelled/deleted**: follow the delete/cancel path below.

### `captain:remove-mission` (complete)

1. Read the full record from `.captain/missions.jsonl` using `jq` (match by id)
2. Add `completed_at` field with today's ISO date obtained via `$(date +%Y-%m-%d)` (all original fields preserved)
3. Append the full updated record to `.captain/completed.jsonl` (with preceding newline guard — only if file is non-empty)
4. Rewrite `.captain/missions.jsonl` without the completed record:
   ```bash
   jq -c '. | select(.id != N)' .captain/missions.jsonl > .captain/missions.jsonl.tmp && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
   ```
5. Run: `bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh`
6. Confirm to user

### `captain:remove-mission` (delete/cancel)

1. Rewrite `.captain/missions.jsonl` without the deleted record (same jq pattern as above)
2. Run: `bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh`
3. Confirm to user

### `captain:remove-mission` skill frontmatter

Update the `description:` field in `skills/remove-mission/SKILL.md` to reflect that it moves records between JSONL files rather than editing markdown sections.

### `captain:start-mission`

No change — reads from `MISSIONS.md` as before. Because the generate script is always run after any mutation, `MISSIONS.md` is guaranteed to be current.

### `captain:finish-mission`

No change — calls `captain:remove-mission`, which handles the JSONL update and script invocation.

### `captain:init-project-docs`

Additional steps for `.captain/` setup:
1. Create `.captain/` directory if missing
2. Create empty `.captain/missions.jsonl` if missing
3. Create empty `.captain/completed.jsonl` if missing
4. Ensure `.captain/` is NOT in `.gitignore` — these files are the source of truth and must be committed
5. Run `bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh` to produce initial `MISSIONS.md` and `COMPLETED.md`

### `captain:new-project`

No change — calls `captain:init-project-docs`.

## File Ownership

| File | Owner | Hand-editable? |
|---|---|---|
| `.captain/missions.jsonl` | Skills + user | Yes (source of truth) |
| `.captain/completed.jsonl` | Skills + user | Yes (source of truth) |
| `MISSIONS.md` | Generate script | No — regenerated on every run |
| `COMPLETED.md` | Generate script | No — regenerated on every run |

## Out of Scope

- Migration of existing `MISSIONS.md` files to JSONL (users start fresh or migrate manually)
- A dedicated migration script
- Validation of JSONL record integrity beyond what `jq` provides (a `jq` parse error on a corrupted line will cause the skill to abort before any mutation — no silent data loss)
- Any runtime other than bash + jq (both are available everywhere Claude Code runs)
