---
name: remove-code-gap
description: Use when a previously stubbed or unimplemented function has been fully implemented and its GAPS.md entry should be removed.
---

# Remove Code Gap

Remove a resolved gap entry from `GAPS.md` at the root of the current project.

## Steps

1. **Locate GAPS.md** — find `GAPS.md` at the root of the current project.

2. **Identify the gap** — read the file and list current gaps if the user hasn't specified which one to remove. Ask for confirmation if there's any ambiguity.

3. **Remove the bullet** — delete the matching bullet line and any trailing blank line.

4. **Confirm** — tell the user the gap was removed and show the remaining gaps (if any).

## Notes

- Never remove the `# Code Gaps` header.
- If the gap doesn't exist, say so — don't silently do nothing.
- If the same gap appears in `CLAUDE.md` under a "Known Code Gaps" section, note it to the user — they may want to remove it there too.
