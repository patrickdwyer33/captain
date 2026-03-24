# JSONL-Backed Missions Design

**Date:** 2026-03-24
**Status:** Approved

## Overview

Replace inline markdown editing of `MISSIONS.md` with a JSONL-backed data layer. Missions are stored as structured records in `.captain/missions.jsonl` and `.captain/completed.jsonl`. A bash script shipped with the captain plugin generates `MISSIONS.md` and `COMPLETED.md` from these files. Skills update the JSONL files and invoke the script rather than editing markdown directly.

**Dependency:** `jq` is required. Skills should check for it at the start of any operation and, if missing, show the user how to install it:
- macOS: `brew install jq`
- Linux: `sudo apt install jq` / `sudo yum install jq`

## Data Layer

Two JSONL files live in `.captain/` at the project root (hidden directory). Both files are committed to the project repo — they are the source of truth.

**`.captain/missions.jsonl`** — one JSON object per line, outstanding missions:
```json
{"id": 1, "title": "Add OAuth login", "goal": "Allow users to sign in with Google.", "background": "Product decision to remove email/password auth by Q2.", "notes": "Requires the user model to support external identity providers.", "depends_on": ["Mission 3: Add rate limiting"], "body": "**Phase 1 — User model changes**\n- Add external_id and provider columns\n- Write migration\n"}
```

**`.captain/completed.jsonl`** — full mission record with `completed_at` added (ISO date string). All original fields preserved:
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
| `body` | no | Raw markdown; all standard JSON escapes apply (`\n`, `\t`, `\\`, `\"`, etc.) |
| `completed_at` | completed only | ISO date string (`YYYY-MM-DD`) added when mission completes |

## JSONL Write Pattern

All skill mutations use a **read-pipe-write** pattern that avoids append-only operations. This sidesteps trailing-newline edge cases from hand-edited files and ensures every write validates all records through `jq`:

```bash
# Append a new record to a file:
{ cat .captain/missions.jsonl 2>/dev/null; printf '%s\n' "$NEW_RECORD"; } \
  | jq -c '.' > .captain/missions.jsonl.tmp \
  && mv .captain/missions.jsonl.tmp .captain/missions.jsonl

# Rewrite a file omitting a record:
jq -c --argjson id N 'select(.id != $id)' .captain/missions.jsonl \
  > .captain/missions.jsonl.tmp \
  && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
```

The `.tmp` + `mv` pattern ensures the original file is intact if the operation fails mid-write.

## Generate Script

**Location in repo:** `scripts/generate.sh`

**Stable invocation path (from project root):**
```bash
bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh
```

**Behavior:**
- Reads `.captain/missions.jsonl` → writes `MISSIONS.md`
- Reads `.captain/completed.jsonl` → writes `COMPLETED.md`
- Both files are generated independently — a parse error on one does not prevent the other from being written
- Missing or empty JSONL files produce headers-only output (see format below)
- Both output files are fully regenerated on every run — never hand-edited
- **Invariant:** after any skill mutation, the generate script is always run

**`MISSIONS.md` output format** — outstanding missions in ascending id order. The script unconditionally emits a blank line between consecutive sections:

```markdown
# Outstanding Missions

See also: [GAPS.md](GAPS.md) — known code stubs to implement | [IDEAS.md](IDEAS.md) — long-term ideas

## Mission 1: Title

**Goal:** ...

**Background:** ...

**Notes:** ... (omitted if field absent)

**Depends on:** Mission 3: ..., Mission 5: ... (omitted if field absent; array joined with `, `)

[body rendered verbatim, JSON-unescaped, preceded by a blank line] (omitted if field absent)
```

Empty file output:
```markdown
# Outstanding Missions

See also: [GAPS.md](GAPS.md) — known code stubs to implement | [IDEAS.md](IDEAS.md) — long-term ideas
```

**`COMPLETED.md` output format** — completed missions in descending id order. No See also line. Same blank-line spacing rules as `MISSIONS.md`:

```markdown
# Completed Missions

## Mission 1: Title

**Goal:** ...

**Background:** ...

**Notes:** ... (omitted if field absent)

**Depends on:** ... (omitted if field absent)

[body rendered verbatim, JSON-unescaped, preceded by a blank line] (omitted if field absent)

**Completed:** 2026-03-24
```

When `body` is absent, `**Completed:**` follows the last present field with a single blank line:
```markdown
## Mission 2: Fix login bug

**Goal:** ...

**Background:** ...

**Completed:** 2026-03-24
```

Empty file output:
```markdown
# Completed Missions
```

**Body rendering:** All standard JSON string unescaping is applied (`\n` → newline, etc.), then the content is written verbatim, preceded by a blank line. Trailing newlines in the body are preserved as-is. The script always emits a blank line after each section unconditionally — it does not rely on body content for spacing.

## Skill Changes

All skills must check for `jq` at the start and show install instructions if missing.

### `captain:create-mission`

1. Check for `jq`. If missing, show install instructions and abort.
2. If `.captain/`, `.captain/missions.jsonl`, or `.captain/completed.jsonl` don't exist, create them. (Both JSONL files must exist for id calculation to work correctly.)
3. Gather mission details interactively (same prompts as before)
4. Determine next id — max across both files + 1:
   ```bash
   MAX=$(jq -rs '[.[] | .id] | max // 0' .captain/missions.jsonl .captain/completed.jsonl)
   NEXT_ID=$((MAX + 1))
   ```
   Both files exist from step 2, so `jq -rs` always has valid inputs. An empty file contributes zero objects; `max // 0` handles the all-empty case.
5. Build the JSON record and write using the read-pipe-write pattern:
   ```bash
   NEW_RECORD=$(jq -cn --argjson id "$NEXT_ID" --arg title "..." --arg goal "..." \
     --arg background "..." '{id: $id, title: $title, goal: $goal, background: $background}')
   { cat .captain/missions.jsonl 2>/dev/null; printf '%s\n' "$NEW_RECORD"; } \
     | jq -c '.' > .captain/missions.jsonl.tmp \
     && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
   ```
   Optional fields (`notes`, `depends_on`, `body`) are included in the record only if provided.
6. Run: `bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh`
7. Confirm to user

### `captain:remove-mission` — branch selection

The skill begins by asking the user whether the mission was completed or cancelled/deleted:

> "Is Mission N done (move to Completed), or are you cancelling/deleting it?"

- If **completed**: follow the complete path below.
- If **cancelled/deleted**: follow the delete/cancel path below.

### `captain:remove-mission` (complete)

1. Check for `jq`. If missing, show install instructions and abort.
2. Validate the mission exists; abort with an error if not:
   ```bash
   jq -e --argjson id N 'select(.id == $id)' .captain/missions.jsonl > /dev/null \
     || { echo "Mission N not found"; exit 1; }
   ```
3. Build the completed record:
   ```bash
   TODAY=$(date +%Y-%m-%d)
   RECORD=$(jq -c --argjson id N --arg d "$TODAY" \
     'select(.id == $id) | . + {completed_at: $d}' .captain/missions.jsonl)
   ```
4. Append to `.captain/completed.jsonl`:
   ```bash
   { cat .captain/completed.jsonl 2>/dev/null; printf '%s\n' "$RECORD"; } \
     | jq -c '.' > .captain/completed.jsonl.tmp \
     && mv .captain/completed.jsonl.tmp .captain/completed.jsonl
   ```
5. Remove from `.captain/missions.jsonl`:
   ```bash
   jq -c --argjson id N 'select(.id != $id)' .captain/missions.jsonl \
     > .captain/missions.jsonl.tmp \
     && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
   ```
6. Run: `bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh`
7. Confirm to user

### `captain:remove-mission` (delete/cancel)

1. Check for `jq`. If missing, show install instructions and abort.
2. Validate the mission exists; abort with an error if not (same pattern as complete path step 2).
3. Remove from `.captain/missions.jsonl`:
   ```bash
   jq -c --argjson id N 'select(.id != $id)' .captain/missions.jsonl \
     > .captain/missions.jsonl.tmp \
     && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
   ```
4. Run: `bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh`
5. Confirm to user

### `captain:remove-mission` skill frontmatter

Update the `description:` field in `skills/remove-mission/SKILL.md` to reflect that it moves records between JSONL files rather than editing markdown sections.

### `captain:start-mission`

Run the generate script before reading `MISSIONS.md` to ensure it is current (handles hand-edited JSONL files):
```bash
bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh
```
Then proceed as before.

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
- Validation of JSONL record integrity beyond what `jq` provides (a parse error causes the skill to abort before any mutation)
- Any runtime other than bash + jq
