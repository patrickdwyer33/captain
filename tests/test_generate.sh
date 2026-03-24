#!/usr/bin/env bash
# Tests for scripts/generate.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GENERATE="$SCRIPT_DIR/../scripts/generate.sh"
PASS=0
FAIL=0

assert_contains() {
  local file="$1" pattern="$2" label="$3"
  if grep -q -- "$pattern" "$file"; then
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
  if ! grep -q -- "$pattern" "$file"; then
    echo "  PASS: $label"
    PASS=$((PASS + 1))
  else
    echo "  FAIL: $label"
    echo "        did not expect '$pattern' in $file"
    cat "$file"
    FAIL=$((FAIL + 1))
  fi
}

setup() {
  TEST_TMPDIR=$(mktemp -d)
  mkdir -p "$TEST_TMPDIR/.captain"
  touch "$TEST_TMPDIR/.captain/missions.jsonl"
  touch "$TEST_TMPDIR/.captain/completed.jsonl"
  cd "$TEST_TMPDIR"
}

teardown() {
  rm -rf "$TEST_TMPDIR"
}

# --- Test 1: empty files produce headers only ---
echo "Test 1: empty files"
setup
bash "$GENERATE" || { echo "  FAIL: generate.sh exited non-zero"; FAIL=$((FAIL+1)); }
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
bash "$GENERATE" || { echo "  FAIL: generate.sh exited non-zero"; FAIL=$((FAIL+1)); }
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
bash "$GENERATE" || { echo "  FAIL: generate.sh exited non-zero"; FAIL=$((FAIL+1)); }
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
bash "$GENERATE" || { echo "  FAIL: generate.sh exited non-zero"; FAIL=$((FAIL+1)); }
FIRST=$(grep -n "^## Mission" MISSIONS.md | head -1)
assert_contains MISSIONS.md "## Mission 1: First" "Mission 1 present"
echo "$FIRST" | grep -q "Mission 1" && \
  { echo "  PASS: Mission 1 is first"; PASS=$((PASS+1)); } || \
  { echo "  FAIL: Mission 1 is not first (got: $FIRST)"; FAIL=$((FAIL+1)); }
teardown

# --- Test 5: completed missions sorted descending ---
echo "Test 5: descending sort for completed"
setup
printf '%s\n' '{"id":1,"title":"First","goal":"G","background":"B","completed_at":"2026-03-01"}' \
  > .captain/completed.jsonl
printf '%s\n' '{"id":3,"title":"Third","goal":"G","background":"B","completed_at":"2026-02-01"}' \
  >> .captain/completed.jsonl
printf '%s\n' '{"id":2,"title":"Second","goal":"G","background":"B","completed_at":"2026-01-01"}' \
  >> .captain/completed.jsonl
bash "$GENERATE" || { echo "  FAIL: generate.sh exited non-zero"; FAIL=$((FAIL+1)); }
FIRST=$(grep -n "^## Mission" COMPLETED.md | head -1)
LAST=$(grep -n "^## Mission" COMPLETED.md | tail -1)
echo "$FIRST" | grep -q "Mission 3" && \
  { echo "  PASS: Mission 3 (highest id) is first"; PASS=$((PASS+1)); } || \
  { echo "  FAIL: Mission 3 is not first (got: $FIRST)"; FAIL=$((FAIL+1)); }
echo "$LAST" | grep -q "Mission 1" && \
  { echo "  PASS: Mission 1 (lowest id) is last"; PASS=$((PASS+1)); } || \
  { echo "  FAIL: Mission 1 is not last (got: $LAST)"; FAIL=$((FAIL+1)); }
assert_contains COMPLETED.md "\*\*Completed:\*\* 2026-02-01" "completed_at rendered"
teardown

# --- Test 6: depends_on array joined with comma-space ---
echo "Test 6: depends_on join"
setup
printf '%s\n' '{"id":1,"title":"T","goal":"G","background":"B","depends_on":["Mission 2: A","Mission 3: B"]}' \
  > .captain/missions.jsonl
bash "$GENERATE" || { echo "  FAIL: generate.sh exited non-zero"; FAIL=$((FAIL+1)); }
assert_contains MISSIONS.md "Mission 2: A, Mission 3: B" "depends_on joined with comma-space"
teardown

# --- Summary ---
echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] || exit 1
