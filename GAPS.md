# Code Gaps

- `sync-standards` (captain plugin): no mechanism to update a project's CLAUDE.md `## Documentation Standards` section or Project Docs table when the captain plugin updates — implement via a new `captain:sync-standards` skill or a version-check step in `finish-mission`
- `writing-standard-drift` (`skills/finish-mission/SKILL.md`): the inline writing standard passed to `/ce-compound` in step 3 is a hand-maintained paraphrase of `skills/writing-standard/RULES.md` — if RULES.md changes, the inline paraphrase must be updated manually. Implement via a generate script that builds the SKILL.md injection text from RULES.md, or a pre-commit hook that diffs them.
