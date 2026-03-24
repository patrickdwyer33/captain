# JSONL-Backed Missions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace inline markdown editing of MISSIONS.md with a JSONL-backed data layer where skills mutate `.captain/missions.jsonl` / `.captain/completed.jsonl` and a generate script produces the markdown files.

**Architecture:** A new `scripts/generate.sh` (bash + jq) reads the two JSONL files and writes `MISSIONS.md` and `COMPLETED.md`. Six skill files are updated to use this data layer instead of editing markdown directly. No new directories other than `scripts/` are required in the repo.

**Tech Stack:** bash, jq (required — installed separately by user)

---

## File Map

| File | Action | Responsibility |
|---|---|---|
| `scripts/generate.sh` | **Create** | Reads JSONL → writes MISSIONS.md + COMPLETED.md |
| `tests/test_generate.sh` | **Create** | Bash tests for generate.sh |
| `skills/create-mission/SKILL.md` | **Rewrite** | JSONL append + id calculation |
| `skills/remove-mission/SKILL.md` | **Rewrite** | JSONL remove/complete paths |
| `skills/finish-mission/SKILL.md` | **Update** | Call complete path directly |
| `skills/start-mission/SKILL.md` | **Update** | Run generate script before reading |
| `skills/init-project-docs/SKILL.md` | **Update** | Create .captain/ dir + JSONL files |
| `README.md` | **Update** | Add jq prerequisite |

---

## Task 1: Create `scripts/generate.sh`

**Files:**
- Create: `scripts/generate.sh`

The script takes no arguments. It is always run from the project root (the directory containing `.captain/`). It generates `MISSIONS.md` and `COMPLETED.md` independently — a failure on one does not abort the other.

- [ ] **Step 1: Create `scripts/` directory and write `scripts/generate.sh`**

```bash
mkdir -p /Users/patrick/dev/captain/scripts
```

Write `scripts/generate.sh`:

```bash
#!/usr/bin/env bash
# generate.sh — generates MISSIONS.md and COMPLETED.md from .captain/*.jsonl
# Run from the project root (the directory containing .captain/).
# Both files are generated independently — a failure on one does not abort the other.
set -uo pipefail

if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed." >&2
  echo "  macOS:  brew install jq" >&2
  echo "  Linux:  sudo apt install jq   OR   sudo yum install jq" >&2
  exit 1
fi

MISSIONS_JSONL=".captain/missions.jsonl"
COMPLETED_JSONL=".captain/completed.jsonl"

# ---------- helpers ----------

render_mission() {
  local record="$1"
  local include_completed="${2:-0}"

  local id title goal background notes depends_on body
  id=$(printf '%s\n' "$record" | jq -r '.id')
  title=$(printf '%s\n' "$record" | jq -r '.title')
  goal=$(printf '%s\n' "$record" | jq -r '.goal')
  background=$(printf '%s\n' "$record" | jq -r '.background')
  notes=$(printf '%s\n' "$record" | jq -r '.notes // empty')
  depends_on=$(printf '%s\n' "$record" | jq -r 'if (.depends_on | length) > 0 then .depends_on | join(", ") else empty end')
  body=$(printf '%s\n' "$record" | jq -r '.body // empty')

  printf '## Mission %s: %s\n\n' "$id" "$title"
  printf '**Goal:** %s\n\n' "$goal"
  printf '**Background:** %s\n' "$background"

  if [ -n "$notes" ]; then
    printf '\n**Notes:** %s\n' "$notes"
  fi

  if [ -n "$depends_on" ]; then
    printf '\n**Depends on:** %s\n' "$depends_on"
  fi

  if [ -n "$body" ]; then
    printf '\n%s\n' "$body"
  fi

  if [ "$include_completed" = "1" ]; then
    local completed_at
    completed_at=$(printf '%s\n' "$record" | jq -r '.completed_at')
    printf '\n**Completed:** %s\n' "$completed_at"
  fi
}

# ---------- MISSIONS.md ----------
# Wrapped in a subshell so a parse error here does not prevent COMPLETED.md from being written.

(
  set -e
  {
    printf '# Outstanding Missions\n\n'
    printf 'See also: [GAPS.md](GAPS.md) — known code stubs to implement | [IDEAS.md](IDEAS.md) — long-term ideas\n'

    if [ -f "$MISSIONS_JSONL" ] && [ -s "$MISSIONS_JSONL" ]; then
      while IFS= read -r record; do
        [ -z "$record" ] && continue
        printf '\n'
        render_mission "$record" 0
      done < <(jq -cs 'sort_by(.id)[]' "$MISSIONS_JSONL")
    fi
  } > MISSIONS.md
) || echo "Warning: failed to generate MISSIONS.md" >&2

# ---------- COMPLETED.md ----------
# Wrapped in a subshell so a parse error here does not prevent MISSIONS.md from being written.

(
  set -e
  {
    printf '# Completed Missions\n'

    if [ -f "$COMPLETED_JSONL" ] && [ -s "$COMPLETED_JSONL" ]; then
      while IFS= read -r record; do
        [ -z "$record" ] && continue
        printf '\n'
        render_mission "$record" 1
      done < <(jq -cs 'sort_by(.id) | reverse | .[]' "$COMPLETED_JSONL")
    fi
  } > COMPLETED.md
) || echo "Warning: failed to generate COMPLETED.md" >&2
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x /Users/patrick/dev/captain/scripts/generate.sh
```

- [ ] **Step 3: Verify it runs without error on an empty project**

```bash
cd /tmp && mkdir -p captain-test/.captain
touch captain-test/.captain/missions.jsonl captain-test/.captain/completed.jsonl
cd captain-test && bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh || \
  bash /Users/patrick/dev/captain/scripts/generate.sh
cat MISSIONS.md
cat COMPLETED.md
```

Expected `MISSIONS.md`:
```
# Outstanding Missions

See also: [GAPS.md](GAPS.md) — known code stubs to implement | [IDEAS.md](IDEAS.md) — long-term ideas
```

Expected `COMPLETED.md`:
```
# Completed Missions
```

- [ ] **Step 4: Commit**

```bash
cd /Users/patrick/dev/captain
git add scripts/generate.sh
git commit -m "feat: add generate.sh to build MISSIONS.md and COMPLETED.md from JSONL"
```

---

## Task 2: Test `scripts/generate.sh`

**Files:**
- Create: `tests/test_generate.sh`

- [ ] **Step 1: Create `tests/` directory and write `tests/test_generate.sh`**

```bash
mkdir -p /Users/patrick/dev/captain/tests
```

Write `tests/test_generate.sh`:

```bash
#!/usr/bin/env bash
# Tests for scripts/generate.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATE="$SCRIPT_DIR/../scripts/generate.sh"
PASS=0
FAIL=0

assert_contains() {
  local file="$1" pattern="$2" label="$3"
  if grep -q "$pattern" "$file"; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label"
    echo "        expected '$pattern' in $file"
    cat "$file"
    FAIL=$((FAIL + 1))
  fi
}

assert_not_contains() {
  local file="$1" pattern="$2" label="$3"
  if ! grep -q "$pattern" "$file"; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label"
    echo "        did not expect '$pattern' in $file"
    FAIL=$((FAIL + 1))
  fi
}

setup() {
  TMPDIR=$(mktemp -d)
  mkdir -p "$TMPDIR/.captain"
  touch "$TMPDIR/.captain/missions.jsonl"
  touch "$TMPDIR/.captain/completed.jsonl"
  cd "$TMPDIR"
}

teardown() {
  rm -rf "$TMPDIR"
}

# --- Test 1: empty files produce headers only ---
echo "Test 1: empty files"
setup
bash "$GENERATE"
assert_contains     MISSIONS.md  "^# Outstanding Missions"         "MISSIONS.md has header"
assert_contains     MISSIONS.md  "See also:"                       "MISSIONS.md has See also line"
assert_not_contains MISSIONS.md  "^## Mission"                     "MISSIONS.md has no mission entries"
assert_contains     COMPLETED.md "^# Completed Missions"           "COMPLETED.md has header"
assert_not_contains COMPLETED.md "^## Mission"                     "COMPLETED.md has no entries"
assert_not_contains COMPLETED.md "See also:"                       "COMPLETED.md has no See also line"
teardown

# --- Test 2: single mission with required fields only ---
echo "Test 2: single mission"
setup
printf '%s\n' '{"id":1,"title":"Add auth","goal":"Allow login.","background":"Users need accounts."}' \
  > .captain/missions.jsonl
bash "$GENERATE"
assert_contains MISSIONS.md "^## Mission 1: Add auth"     "mission heading"
assert_contains MISSIONS.md "^\*\*Goal:\*\* Allow login." "goal field"
assert_contains MISSIONS.md "^\*\*Background:\*\* Users"  "background field"
assert_not_contains MISSIONS.md "\*\*Notes:\*\*"          "no notes when absent"
assert_not_contains MISSIONS.md "\*\*Depends on:\*\*"     "no depends_on when absent"
teardown

# --- Test 3: mission with all optional fields ---
echo "Test 3: all optional fields"
setup
printf '%s\n' '{"id":1,"title":"Add auth","goal":"Allow login.","background":"Context.","notes":"Use OAuth.","depends_on":["Mission 2: Set up DB"],"body":"- Step one\n- Step two\n"}' \
  > .captain/missions.jsonl
bash "$GENERATE"
assert_contains MISSIONS.md "\*\*Notes:\*\* Use OAuth."              "notes field"
assert_contains MISSIONS.md "\*\*Depends on:\*\* Mission 2: Set up DB" "depends_on field"
assert_contains MISSIONS.md "- Step one"                              "body rendered"
teardown

# --- Test 4: multiple missions sorted ascending ---
echo "Test 4: ascending sort"
setup
printf '%s\n' '{"id":3,"title":"Third","goal":"G3","background":"B3"}' \
  > .captain/missions.jsonl
printf '%s\n' '{"id":1,"title":"First","goal":"G1","background":"B1"}' \
  >> .captain/missions.jsonl
printf '%s\n' '{"id":2,"title":"Second","goal":"G2","background":"B2"}' \
  >> .captain/missions.jsonl
bash "$GENERATE"
FIRST=$(grep -n "^## Mission" MISSIONS.md | head -1)
assert_contains MISSIONS.md "## Mission 1: First" "Mission 1 present"
echo "$FIRST" | grep -q "Mission 1" && \
  { echo "  PASS: Mission 1 is first"; PASS=$((PASS+1)); } || \
  { echo "  FAIL: Mission 1 is not first (got: $FIRST)"; FAIL=$((FAIL+1)); }
teardown

# --- Test 5: completed missions sorted descending ---
echo "Test 5: descending sort for completed"
setup
printf '%s\n' '{"id":1,"title":"First","goal":"G","background":"B","completed_at":"2026-01-01"}' \
  > .captain/completed.jsonl
printf '%s\n' '{"id":3,"title":"Third","goal":"G","background":"B","completed_at":"2026-03-01"}' \
  >> .captain/completed.jsonl
printf '%s\n' '{"id":2,"title":"Second","goal":"G","background":"B","completed_at":"2026-02-01"}' \
  >> .captain/completed.jsonl
bash "$GENERATE"
FIRST=$(grep -n "^## Mission" COMPLETED.md | head -1)
echo "$FIRST" | grep -q "Mission 3" && \
  { echo "  PASS: Mission 3 (highest id) is first"; PASS=$((PASS+1)); } || \
  { echo "  FAIL: Mission 3 is not first (got: $FIRST)"; FAIL=$((FAIL+1)); }
assert_contains COMPLETED.md "\*\*Completed:\*\* 2026-03-01" "completed_at rendered"
teardown

# --- Test 6: depends_on array joined with comma-space ---
echo "Test 6: depends_on join"
setup
printf '%s\n' '{"id":1,"title":"T","goal":"G","background":"B","depends_on":["Mission 2: A","Mission 3: B"]}' \
  > .captain/missions.jsonl
bash "$GENERATE"
assert_contains MISSIONS.md "Mission 2: A, Mission 3: B" "depends_on joined with comma-space"
teardown

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
```

- [ ] **Step 2: Run the tests**

```bash
cd /Users/patrick/dev/captain
bash tests/test_generate.sh
```

Expected: all tests pass, `Results: N passed, 0 failed`

- [ ] **Step 3: Fix any failures before proceeding**

- [ ] **Step 4: Commit**

```bash
git add tests/test_generate.sh
git commit -m "test: add generate.sh test suite"
```

---

## Task 3: Update `skills/create-mission/SKILL.md`

**Files:**
- Modify: `skills/create-mission/SKILL.md`

Replace the current skill (which edits MISSIONS.md directly) with the JSONL-based approach from the spec.

- [ ] **Step 1: Rewrite `skills/create-mission/SKILL.md`**

```markdown
---
name: create-mission
description: Add a new mission to the project's JSONL mission store. Creates .captain/missions.jsonl if needed, calculates the next id, appends the new record, and regenerates MISSIONS.md.
---

# Create Mission

Add a new mission to the JSONL data layer at `.captain/missions.jsonl` and regenerate `MISSIONS.md`.

## Steps

1. **Check for jq** — run `command -v jq` to verify jq is installed. If missing, tell the user:
   > jq is required by captain. Install it first:
   > - macOS: `brew install jq`
   > - Linux: `sudo apt install jq` or `sudo yum install jq`
   Then abort.

2. **Ensure `.captain/` exists** — if `.captain/`, `.captain/missions.jsonl`, or `.captain/completed.jsonl` are missing, create them:
   ```bash
   mkdir -p .captain
   touch .captain/missions.jsonl
   touch .captain/completed.jsonl
   ```
   Also check that `.captain/` is not listed in `.gitignore`. If it is, warn the user that the JSONL files must be committed and ask them to remove the exclusion.

3. **Gather mission details** — ask the user for:
   - **Title** — imperative present-tense name (e.g. "Add OAuth login")
   - **Goal** — one sentence: what this accomplishes and why it matters
   - **Background** — context, motivation, what triggered this
   - **Notes** — constraints, decisions already made (optional — skip if nothing to say)
   - **Depends on** — "Does this depend on other missions completing first? If so, list them as `Mission N: Title`. Leave blank if none." (optional)
   - **Body** — phases or sub-steps (optional — use if the mission has distinct stages or a task list)

4. **Determine the next id** — find the max `id` across both JSONL files and add 1. Abort if jq exits non-zero (corrupt file):
   ```bash
   MAX=$(jq -rs '[.[] | .id] | max // 0' .captain/missions.jsonl .captain/completed.jsonl) \
     || { echo "Failed to read JSONL — check for corruption"; exit 1; }
   NEXT_ID=$((MAX + 1))
   ```

5. **Build the JSON record** — start with required fields, then conditionally add optional ones:
   ```bash
   NEW_RECORD=$(jq -cn \
     --argjson id "$NEXT_ID" \
     --arg title "TITLE" \
     --arg goal "GOAL" \
     --arg background "BACKGROUND" \
     '{id: $id, title: $title, goal: $goal, background: $background}')

   # Add optional string fields only if provided:
   [ -n "$NOTES" ] && NEW_RECORD=$(printf '%s\n' "$NEW_RECORD" | jq -c --arg v "$NOTES" '. + {notes: $v}')
   [ -n "$BODY"  ] && NEW_RECORD=$(printf '%s\n' "$NEW_RECORD" | jq -c --arg v "$BODY"  '. + {body: $v}')

   # Add depends_on if provided (as a JSON array, e.g. '["Mission 3: Add rate limiting"]'):
   [ -n "$DEPENDS_ON" ] && NEW_RECORD=$(printf '%s\n' "$NEW_RECORD" | jq -c --argjson v "$DEPENDS_ON" '. + {depends_on: $v}')
   ```
   For the `body` field: if the user supplied multi-line content, JSON-escape newlines as `\n` when building the string (jq `--arg` handles this automatically).

6. **Write the record** — append using the read-pipe-write pattern:
   ```bash
   { cat .captain/missions.jsonl 2>/dev/null; printf '%s\n' "$NEW_RECORD"; } \
     | jq -c '.' > .captain/missions.jsonl.tmp \
     && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
   ```

7. **Regenerate markdown** — run:
   ```bash
   bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh
   ```

8. **Confirm** — tell the user the mission was added and show the new entry from `MISSIONS.md`.

## Notes

- Never reuse mission ids — ids are permanent identifiers.
- The `body` field stores raw markdown with JSON-escaped newlines. When the user provides multi-line content, pass it to jq via `--arg` (which auto-escapes) rather than embedding raw newlines in the JSON string.
- Optional fields are omitted from the record entirely when not provided — do not store empty strings.
```

- [ ] **Step 2: Verify the file looks correct**

Read `skills/create-mission/SKILL.md` and confirm all 8 steps are present with correct jq commands.

- [ ] **Step 3: Commit**

```bash
git add skills/create-mission/SKILL.md
git commit -m "feat: update create-mission to use JSONL data layer"
```

---

## Task 4: Update `skills/remove-mission/SKILL.md`

**Files:**
- Modify: `skills/remove-mission/SKILL.md`

Replace direct markdown editing with JSONL mutations. The skill has two paths: complete (moves to completed.jsonl) and delete/cancel (removes from missions.jsonl only).

- [ ] **Step 1: Rewrite `skills/remove-mission/SKILL.md`**

```markdown
---
name: remove-mission
description: Remove a mission from the JSONL mission store. Moves completed missions to .captain/completed.jsonl and regenerates both MISSIONS.md and COMPLETED.md. Permanently deletes cancelled missions.
---

# Remove Mission

Move a completed mission to `.captain/completed.jsonl`, or permanently delete a cancelled mission from `.captain/missions.jsonl`. Regenerates `MISSIONS.md` and `COMPLETED.md` after any mutation.

## Steps

1. **Check for jq** — run `command -v jq`. If missing, show install instructions (same as `captain:create-mission` step 1) and abort.

2. **Identify the mission** — if the user hasn't specified which mission, read `MISSIONS.md` and list the available headings. Confirm if there's any ambiguity.

3. **Determine disposition** — ask: *"Is this mission done (move to Completed), or are you cancelling/deleting it?"*
   - If **completed**: follow the Complete path below.
   - If **cancelled/deleted**: follow the Delete path below.
   - When called from `captain:finish-mission`, always use the Complete path — skip this question.

### Complete path

4. **Validate the mission exists**:
   ```bash
   FOUND=$(jq -rs --argjson id N '[.[] | select(.id == $id)] | length' .captain/missions.jsonl)
   [ "$FOUND" -eq 0 ] && echo "Mission N not found" && exit 1
   ```
   (`N` is the integer mission id throughout this skill.)

5. **Build the completed record**:
   ```bash
   TODAY=$(date +%Y-%m-%d)
   RECORD=$(jq -c --argjson id N --arg d "$TODAY" \
     'select(.id == $id) | . + {completed_at: $d}' .captain/missions.jsonl)
   ```
   Since ids are unique, `select` produces exactly one record.

6. **Remove from `.captain/missions.jsonl` first** (before writing to completed.jsonl — if the append later fails, the user manually re-adds to completed.jsonl using the original id rather than dealing with a duplicate):
   ```bash
   jq -c --argjson id N 'select(.id != $id)' .captain/missions.jsonl \
     > .captain/missions.jsonl.tmp \
     && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
   ```

7. **Append to `.captain/completed.jsonl`**:
   ```bash
   { cat .captain/completed.jsonl 2>/dev/null; printf '%s\n' "$RECORD"; } \
     | jq -c '.' > .captain/completed.jsonl.tmp \
     && mv .captain/completed.jsonl.tmp .captain/completed.jsonl
   ```

8. **Regenerate markdown**:
   ```bash
   bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh
   ```

9. **Confirm** — tell the user the mission was moved to Completed.

### Delete path

4. **Validate the mission exists** (same length-check as Complete path step 4).

5. **Remove from `.captain/missions.jsonl`**:
   ```bash
   jq -c --argjson id N 'select(.id != $id)' .captain/missions.jsonl \
     > .captain/missions.jsonl.tmp \
     && mv .captain/missions.jsonl.tmp .captain/missions.jsonl
   ```

6. **Regenerate markdown**:
   ```bash
   bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh
   ```

7. **Confirm** — tell the user the mission was permanently deleted.

## Notes

- Never remove the `.captain/` directory or JSONL files.
- Do NOT renumber missions — ids are permanent.
- If the mission doesn't exist in `.captain/missions.jsonl`, say so and abort.
```

- [ ] **Step 2: Verify the file looks correct**

Read `skills/remove-mission/SKILL.md` and confirm both paths (Complete and Delete) are present with correct jq commands and step numbering.

- [ ] **Step 3: Commit**

```bash
git add skills/remove-mission/SKILL.md
git commit -m "feat: update remove-mission to use JSONL data layer"
```

---

## Task 5: Update `skills/finish-mission/SKILL.md` and `skills/start-mission/SKILL.md`

**Files:**
- Modify: `skills/finish-mission/SKILL.md`
- Modify: `skills/start-mission/SKILL.md`

Small targeted changes to both skills.

- [ ] **Step 1: Update `skills/finish-mission/SKILL.md`**

The only change: step 2 currently says to call `captain:remove-mission`. Update it to explicitly invoke the **complete path** of `captain:remove-mission` (skipping the branch-selection prompt, since finishing a mission always means completion):

Find the line in step 2 that says:
```
- `captain:remove-mission` — move the completed mission from the active section to the `# Completed` section of `MISSIONS.md`
```

Replace with:
```
- `captain:remove-mission` — invoke the **complete path** directly (this is always a completion, not a deletion — skip the "done or cancelling?" prompt and proceed straight to the Complete path steps)
```

- [ ] **Step 2: Update `skills/start-mission/SKILL.md`**

Insert a new step **before** the current Step 1 ("Read the mission spec"):

```markdown
1. **Regenerate MISSIONS.md** — run the generate script first to ensure `MISSIONS.md` reflects the current state of `.captain/missions.jsonl`, including any hand-edits the user may have made:
   ```bash
   bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh
   ```
   If the generate script fails (e.g. jq not installed or corrupt JSONL), warn the user and proceed with whatever `MISSIONS.md` currently contains.
```

Renumber the existing steps 1–3 to 2–4.

- [ ] **Step 3: Verify both files**

Read each file and confirm the changes are present.

- [ ] **Step 4: Commit**

```bash
git add skills/finish-mission/SKILL.md skills/start-mission/SKILL.md
git commit -m "feat: finish-mission uses complete path, start-mission regenerates first"
```

---

## Task 6: Update `skills/init-project-docs/SKILL.md`

**Files:**
- Modify: `skills/init-project-docs/SKILL.md`

Add `.captain/` setup steps. The existing steps (README.md, CLAUDE.md, MISSIONS.md, etc.) remain unchanged.

- [ ] **Step 1: Add `.captain/` setup to `skills/init-project-docs/SKILL.md`**

After the current step 8 (IDEAS.md), insert a new step 9:

```markdown
9. **`.captain/` directory and JSONL files** — check if `.captain/` exists at the project root.
   - If missing, create it: `mkdir -p .captain`
   - Create `.captain/missions.jsonl` if missing: `touch .captain/missions.jsonl`
   - Create `.captain/completed.jsonl` if missing: `touch .captain/completed.jsonl`
   - Check `.gitignore`: if `.captain` or `.captain/` appears there, warn the user — these files are the source of truth and must be committed to the repo.
   - Run the generate script to produce `MISSIONS.md` and `COMPLETED.md`:
     ```bash
     bash ~/.claude/plugins/marketplaces/captain/scripts/generate.sh
     ```
```

Update step 10 (was step 9, Confirm) to mention the `.captain/` files in the report.

- [ ] **Step 2: Also update the MISSIONS.md check in step 5**

The existing step 5 creates `MISSIONS.md` directly if missing. Since `MISSIONS.md` is now generated from JSONL, update the "If missing, create it" note:

Find:
```
   - If missing, create it:
     ```markdown
     # Outstanding Missions
     ...
```

Replace with:
```
   - If missing, it will be created by the generate script in step 9. Do not create it manually.
```

- [ ] **Step 3: Verify the file**

Read `skills/init-project-docs/SKILL.md` and confirm the new step 9 is correct and step 5 no longer manually creates MISSIONS.md.

- [ ] **Step 4: Commit**

```bash
git add skills/init-project-docs/SKILL.md
git commit -m "feat: init-project-docs creates .captain/ dir and JSONL files"
```

---

## Task 7: Update `README.md`

**Files:**
- Modify: `README.md`

Add jq as a prerequisite and update the skill descriptions.

- [ ] **Step 1: Add jq to Prerequisites section in `README.md`**

Find the `## Prerequisites` section. Add jq:

```markdown
## Prerequisites

The `superpowers` plugin must be installed before captain. Install it first:

```
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers
```

`jq` must also be installed:
- macOS: `brew install jq`
- Linux: `sudo apt install jq` or `sudo yum install jq`
```

- [ ] **Step 2: Update the Skills table**

Update the descriptions for `captain:create-mission` and `captain:remove-mission` to reflect the JSONL data layer:

| Skill | Description |
|---|---|
| `captain:create-mission` | Add a new mission to the JSONL store; regenerates `MISSIONS.md` |
| `captain:remove-mission` | Complete or delete a mission in the JSONL store; regenerates `MISSIONS.md` and `COMPLETED.md` |

- [ ] **Step 3: Verify**

Read `README.md` and confirm jq is in Prerequisites and descriptions are updated.

- [ ] **Step 4: Commit**

```bash
git add README.md
git commit -m "docs: add jq prerequisite and update skill descriptions"
```

---

## Task 8: End-to-end smoke test

Verify the full flow works together on a fresh test project.

- [ ] **Step 1: Set up a clean test project**

```bash
mkdir -p /tmp/e2e-captain-test
cd /tmp/e2e-captain-test
git init
```

- [ ] **Step 2: Run generate.sh on empty state**

```bash
mkdir -p .captain
touch .captain/missions.jsonl .captain/completed.jsonl
bash /Users/patrick/dev/captain/scripts/generate.sh
cat MISSIONS.md
cat COMPLETED.md
```

Expected: headers-only output as specified.

- [ ] **Step 3: Simulate create-mission**

```bash
# Compute next id
MAX=$(jq -rs '[.[] | .id] | max // 0' .captain/missions.jsonl .captain/completed.jsonl)
NEXT_ID=$((MAX + 1))  # Should be 1

# Build record
NEW_RECORD=$(jq -cn --argjson id 1 --arg title "Add auth" --arg goal "Allow login." --arg background "Users need accounts." \
  '{id: $id, title: $title, goal: $goal, background: $background}')

# Append
{ cat .captain/missions.jsonl 2>/dev/null; printf '%s\n' "$NEW_RECORD"; } \
  | jq -c '.' > .captain/missions.jsonl.tmp \
  && mv .captain/missions.jsonl.tmp .captain/missions.jsonl

# Regenerate
bash /Users/patrick/dev/captain/scripts/generate.sh
cat MISSIONS.md
```

Expected: `## Mission 1: Add auth` appears in `MISSIONS.md`.

- [ ] **Step 4: Simulate remove-mission (complete)**

```bash
TODAY=$(date +%Y-%m-%d)
RECORD=$(jq -c --argjson id 1 --arg d "$TODAY" \
  'select(.id == $id) | . + {completed_at: $d}' .captain/missions.jsonl)

# Remove from missions
jq -c --argjson id 1 'select(.id != $id)' .captain/missions.jsonl \
  > .captain/missions.jsonl.tmp && mv .captain/missions.jsonl.tmp .captain/missions.jsonl

# Append to completed
{ cat .captain/completed.jsonl 2>/dev/null; printf '%s\n' "$RECORD"; } \
  | jq -c '.' > .captain/completed.jsonl.tmp \
  && mv .captain/completed.jsonl.tmp .captain/completed.jsonl

# Regenerate
bash /Users/patrick/dev/captain/scripts/generate.sh
cat MISSIONS.md
cat COMPLETED.md
```

Expected: mission absent from `MISSIONS.md`, present in `COMPLETED.md` with `**Completed:**` date.

- [ ] **Step 5: Clean up**

```bash
rm -rf /tmp/e2e-captain-test
```

- [ ] **Step 6: Final commit and push**

```bash
cd /Users/patrick/dev/captain
git log --oneline -10
```

Verify all task commits are present. Then push:

```bash
git push
```
