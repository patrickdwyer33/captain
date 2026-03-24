# JSONL-Backed Missions Design

**Date:** 2026-03-24
**Status:** Approved

## Overview

Replace inline markdown editing of `MISSIONS.md` with a JSONL-backed data layer. Missions are stored as structured records in `.captain/missions.jsonl` and `.captain/completed.jsonl`. A bash script shipped with the captain plugin generates `MISSIONS.md` and `COMPLETED.md` from these files. Skills update the JSONL files and invoke the script rather than editing markdown directly.

## Data Layer

Two JSONL files live in `.captain/` at the project root (hidden directory):

**`.captain/missions.jsonl`** — one JSON object per line, outstanding missions:
```json
{"id": 1, "title": "Add OAuth login", "goal": "Allow users to sign in with Google.", "background": "Product decision to remove email/password auth by Q2.", "notes": "Requires the user model to support external identity providers.", "depends_on": ["Mission 3: Add rate limiting"], "body": "**Phase 1 — User model changes**\n- Add external_id and provider columns\n- Write migration\n"}
```

**`.captain/completed.jsonl`** — same format plus `completed_at` (ISO date string):
```json
{"id": 1, "title": "Add OAuth login", "goal": "Allow users to sign in with Google.", "background": "Product decision to remove email/password auth by Q2.", "completed_at": "2026-03-24"}
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
| `body` | no | Raw markdown for phases or flat bullets |
| `completed_at` | completed only | ISO date string added when mission completes |

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

**`MISSIONS.md` output format:**
```markdown
# Outstanding Missions

See also: [GAPS.md](GAPS.md) — known code stubs to implement | [IDEAS.md](IDEAS.md) — long-term ideas

## Mission 1: Title

**Goal:** ...

**Background:** ...

**Notes:** ... (omitted if absent)

**Depends on:** Mission 3: ..., Mission 5: ... (omitted if absent)

...body... (omitted if absent)
```

**`COMPLETED.md` output format:**
```markdown
# Completed Missions

## Mission 1: Title

**Goal:** ...

**Background:** ...

**Completed:** 2026-03-24
```

Completed missions are rendered in descending order (highest id first).

## Skill Changes

### `captain:create-mission`

1. Gather mission details interactively (same prompts as before)
2. Determine next id: count `## Mission N:` lines across both JSONL files and increment
3. Build JSON record and append to `.captain/missions.jsonl`:
   ```bash
   echo '{"id":N,"title":"...","goal":"...","background":"..."}' >> .captain/missions.jsonl
   ```
4. Run generate script
5. Confirm to user

### `captain:remove-mission` (complete)

1. Read the record from `.captain/missions.jsonl` using `jq`
2. Add `completed_at` field with today's date
3. Append to `.captain/completed.jsonl`
4. Remove the record from `.captain/missions.jsonl` (rewrite file with `jq`)
5. Run generate script
6. Confirm to user

### `captain:remove-mission` (delete/cancel)

1. Remove the record from `.captain/missions.jsonl` (rewrite file with `jq`)
2. Run generate script
3. Confirm to user

### `captain:start-mission`

No change — reads from `MISSIONS.md` as before (always fresh after any mutation).

### `captain:finish-mission`

No change — calls `captain:remove-mission` which handles the JSONL update.

### `captain:init-project-docs`

Additional steps for `.captain/` setup:
1. Create `.captain/` directory if missing
2. Create empty `.captain/missions.jsonl` if missing (touch)
3. Create empty `.captain/completed.jsonl` if missing (touch)
4. Add `.captain/` to `.gitignore` if not already present — wait, these files should be committed
5. Run generate script to produce initial `MISSIONS.md` and `COMPLETED.md`

The `.captain/` directory and its JSONL files are committed to the project repo (they are the source of truth).

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
- Validation of JSONL record integrity beyond what `jq` provides
- Any runtime other than bash + jq (both are available everywhere Claude Code runs)
