# JSONL-Backed Missions Design

**Date:** 2026-03-24
**Status:** Approved

## Overview

Replace inline markdown editing of `MISSIONS.md` with a JSONL-backed data layer. Missions are stored as structured records in `.captain/missions.jsonl` and `.captain/completed.jsonl`. A Python 3 script shipped with the captain plugin generates `MISSIONS.md` and `COMPLETED.md` from these files. Skills update the JSONL files and invoke the script rather than editing markdown directly.

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
| `body` | no | Raw markdown for phases or flat bullets; all standard JSON escapes apply (`\n`, `\t`, `\\`, `\"`, etc.) |
| `completed_at` | completed only | ISO date string (`YYYY-MM-DD`) added when mission completes |

## Generate Script

**Location in repo:** `scripts/generate.py`

**Stable invocation path (from project root):**
```bash
python3 ~/.claude/plugins/marketplaces/captain/scripts/generate.py
```

**Behavior:**
- Reads `.captain/missions.jsonl` → writes `MISSIONS.md`
- Reads `.captain/completed.jsonl` → writes `COMPLETED.md`
- Both output files are fully regenerated on every run — never hand-edited
- Handles missing or empty JSONL files gracefully: `MISSIONS.md` contains `# Outstanding Missions` followed by a blank line and the See also line (no mission entries); `COMPLETED.md` contains only `# Completed Missions` with no entries. `COMPLETED.md` never has a See also line.
- Each file is generated independently; a parse error on one JSONL file exits with a non-zero code and skips writing that file's output, but does not affect the other file
- **Invariant:** after any skill mutation, the generate script is always run, so `MISSIONS.md` and `COMPLETED.md` are always current

**`MISSIONS.md` output format** — outstanding missions in ascending id order. Consecutive mission sections are separated by a blank line. The script unconditionally emits a blank line between sections regardless of whether a body field is present:
```markdown
# Outstanding Missions

See also: [GAPS.md](GAPS.md) — known code stubs to implement | [IDEAS.md](IDEAS.md) — long-term ideas

## Mission 1: Title

**Goal:** ...

**Background:** ...

**Notes:** ... (omitted if field absent)

**Depends on:** Mission 3: ..., Mission 5: ... (omitted if field absent; array joined with `", "` comma-space)

[body rendered verbatim, JSON-unescaped, preceded by a blank line] (omitted if field absent)
```

**`COMPLETED.md` output format** — completed missions in descending id order. No See also line. Consecutive sections separated by a blank line (unconditional, same as MISSIONS.md):
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

When `body` is absent, `**Completed:**` follows the last present field with a single blank line separator:
```markdown
## Mission 2: Fix login bug

**Goal:** ...

**Background:** ...

**Completed:** 2026-03-24
```

The `body` field rendering rule applies to both files: all standard JSON string unescaping is applied, then the content is written verbatim, preceded by a blank line. Trailing newlines in the body are preserved as-is. The script always emits a blank line after each section; it does not rely on body trailing content for spacing.

## Skill Changes

All JSON manipulation uses Python 3 (`python3`), which is available on all supported platforms. Skills read JSONL by parsing each non-blank line as a JSON object and write JSONL as newline-separated JSON objects (one per line, trailing newline after the last record, no blank lines between records).

### `captain:create-mission`

1. If `.captain/`, `.captain/missions.jsonl`, or `.captain/completed.jsonl` don't exist, create them before proceeding. Also check that `.captain/` is not in `.gitignore` and add an exclusion if needed. Creating both JSONL files ensures the id-calculation always has valid inputs.
2. Gather mission details interactively (same prompts as before)
3. Determine next id — find the max `id` across both JSONL files and add 1:
   ```python
   import json, os
   max_id = 0
   for path in ['.captain/missions.jsonl', '.captain/completed.jsonl']:
       try:
           for line in open(path):
               line = line.strip()
               if line:
                   max_id = max(max_id, json.loads(line)['id'])
       except FileNotFoundError:
           pass
   next_id = max_id + 1
   ```
4. Build the record dict and write it to `.captain/missions.jsonl` by reading all existing records, appending the new one, and rewriting the file:
   ```python
   import json
   try:
       records = [json.loads(l) for l in open('.captain/missions.jsonl') if l.strip()]
   except FileNotFoundError:
       records = []
   records.append({"id": next_id, "title": ..., "goal": ..., "background": ..., ...})
   with open('.captain/missions.jsonl', 'w') as f:
       f.write('\n'.join(json.dumps(r, ensure_ascii=False) for r in records))
       if records: f.write('\n')
   ```
5. Run: `python3 ~/.claude/plugins/marketplaces/captain/scripts/generate.py`
6. Confirm to user

### `captain:remove-mission` — branch selection

The skill begins by asking the user whether the mission was completed or cancelled/deleted:

> "Is Mission N done (move to Completed), or are you cancelling/deleting it?"

- If **completed**: follow the complete path below.
- If **cancelled/deleted**: follow the delete/cancel path below.

### `captain:remove-mission` (complete)

```python
import json, datetime

# Read missions
records = [json.loads(l) for l in open('.captain/missions.jsonl') if l.strip()]

# Validate
target = next((r for r in records if r['id'] == N), None)
if not target:
    raise SystemExit(f"Mission {N} not found")

# Build completed record
completed_record = dict(target, completed_at=datetime.date.today().isoformat())

# Append to completed.jsonl
try:
    done = [json.loads(l) for l in open('.captain/completed.jsonl') if l.strip()]
except FileNotFoundError:
    done = []
done.append(completed_record)
with open('.captain/completed.jsonl', 'w') as f:
    f.write('\n'.join(json.dumps(r, ensure_ascii=False) for r in done))
    if done: f.write('\n')

# Remove from missions.jsonl
remaining = [r for r in records if r['id'] != N]
with open('.captain/missions.jsonl', 'w') as f:
    f.write('\n'.join(json.dumps(r, ensure_ascii=False) for r in remaining))
    if remaining: f.write('\n')
```

Then run: `python3 ~/.claude/plugins/marketplaces/captain/scripts/generate.py`

Confirm to user.

### `captain:remove-mission` (delete/cancel)

```python
import json

records = [json.loads(l) for l in open('.captain/missions.jsonl') if l.strip()]

if not any(r['id'] == N for r in records):
    raise SystemExit(f"Mission {N} not found")

remaining = [r for r in records if r['id'] != N]
with open('.captain/missions.jsonl', 'w') as f:
    f.write('\n'.join(json.dumps(r, ensure_ascii=False) for r in remaining))
    if remaining: f.write('\n')
```

Then run: `python3 ~/.claude/plugins/marketplaces/captain/scripts/generate.py`

Confirm to user.

### `captain:remove-mission` skill frontmatter

Update the `description:` field in `skills/remove-mission/SKILL.md` to reflect that it moves records between JSONL files rather than editing markdown sections.

### `captain:start-mission`

Run the generate script before reading `MISSIONS.md` to ensure it is current, including when `.captain/missions.jsonl` was hand-edited without invoking a skill:
```bash
python3 ~/.claude/plugins/marketplaces/captain/scripts/generate.py
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
5. Run `python3 ~/.claude/plugins/marketplaces/captain/scripts/generate.py` to produce initial `MISSIONS.md` and `COMPLETED.md`

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
- Validation of JSONL record integrity beyond standard Python `json` parsing (a parse error will cause the skill to abort before any mutation — no silent data loss)
- Any runtime other than bash + Python 3 (both are available on all platforms where Claude Code runs)
