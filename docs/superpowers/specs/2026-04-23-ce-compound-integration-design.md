# ce-compound Integration into finish-mission

**Date:** 2026-04-23
**Status:** Approved

## Problem

Captain's `finish-mission` skill marks work complete and updates existing docs, but it produces no artifact capturing *what was learned* — debugging dead ends, discovered constraints, newly established patterns, environmental gotchas. Every finished mission is a knowledge-compounding opportunity lost.

## Goal

Integrate the `ce-compound` skill from the `EveryInc/compound-engineering-plugin` into captain's `finish-mission` flow so reusable lessons are captured to `docs/solutions/` at mission completion. Captain owns lesson identification and user confirmation; ce-compound owns structured capture and overlap detection.

## Dependency

`compound-engineering-plugin` becomes a hard prerequisite of captain, handled identically to how `superpowers` is handled today:
- Documented in README's Prerequisites list alongside `superpowers` and `jq`
- No formal `dependencies` field in `plugin.json` — captain invokes `/ce-compound` directly, the same way it invokes `superpowers:brainstorming`
- If the plugin is not installed, the invocation fails with the skill system's standard "skill not found" error — identical failure model to missing superpowers

## Architecture

### Flow

`finish-mission` restructures from 4 steps to 5. The lesson capture step is inserted before the writing standard review gate so the gate's `git diff` anchor automatically covers any files ce-compound produces.

| Step | Current | After integration |
| --- | --- | --- |
| 1 | Discover changed docs | (unchanged) |
| 2 | Update docs | (unchanged — retains writing standard callout) |
| 3 | Review gate | **NEW: Identify + capture lessons via ce-compound** |
| 4 | Cleanup | Review gate (now covers ce-compound output via git diff) |
| 5 | — | Cleanup |

### Signal sources for lesson identification

Claude reads three sources to propose candidate lessons:

1. `git diff` for the mission's full scope
2. `git log --oneline` for the commit sequence (a "fix" chain signals a debugging lesson)
3. Working memory of the mission — specifically things that surprised Claude, turned out wrong mid-stream, or established a new convention

`GAPS.md` is not a signal source — gaps are already captured elsewhere.

### Candidate types

- **Bug lesson** — a non-trivial debugging or fix with reusable prevention value
- **Pattern/convention** — a design decision or code convention worth future adherence
- **Gotcha** — a non-obvious constraint, workaround, or environment quirk

The skill explicitly skips lesson identification for mechanical missions (renames, version bumps, dependency updates, boilerplate).

### User confirmation UX

Batch confirmation. Claude presents all candidates in one message:

> Found N candidate lessons:
> 1. [type]: one-line summary — why it's reusable
> 2. [type]: one-line summary — why it's reusable
>
> Capture? Respond per lesson: `y` (full mode), `lightweight` (single-pass), or `n` (skip).

The user responds once with per-lesson choices. Captain then invokes ce-compound for each confirmed lesson.

### ce-compound mode per lesson

- **Full mode (default)** — four parallel research subagents, overlap detection, session historian, categorization. Overlap detection is the key feature: it merges into an existing solution doc rather than creating a duplicate, which serves captain's stateless philosophy at the cross-doc level.
- **Lightweight mode** — single-pass write, no subagents, no overlap detection. Available per-lesson when the user responds `lightweight`.

### Writing standard injection

Captain injects its stateless writing standard into the `/ce-compound [context]` argument as inline prose so ce-compound's output is biased correctly at write time. Exact format:

```
/ce-compound [lesson summary] — writing standard: output must be stateless (no "NEW:", "as discussed", first-person voice, temporal anchors, documented misunderstandings) and reflect current understanding only (no stale concepts, no traces of wrong paths)
```

For lightweight mode: `/ce-compound --lightweight [lesson summary] — writing standard: ...` with the same directive.

Passing a file reference (e.g., `writing-standard: skills/writing-standard/RULES.md`) was considered and rejected — ce-compound is a separate plugin and has no mechanism to resolve captain's skill-relative paths.

### Review gate coverage

The existing writing standard review gate (step 3 today, step 4 after integration) is already anchored to `git diff`. Any files ce-compound writes to `docs/solutions/` during step 3 appear in the diff and are automatically covered by the gate — no modification to the gate's instructions needed.

## `init-project-docs` changes

Captain owns `docs/solutions/` setup so ce-compound's own discoverability patch is a no-op on captain-initialized projects.

### Directory creation

In step 4 (which currently handles `docs/` and `docs/notes/`), add a sub-step:
- Create `docs/solutions/` if missing
- Place a `.gitkeep` in it if empty so it is tracked by git

### Project Docs table entry

Add one row to the Project Docs table in the "if missing" templates for both README.md (step 2) and CLAUDE.md (step 3):

```markdown
| [docs/solutions/](docs/solutions/) | Compounding knowledge — bug postmortems, patterns, and gotchas captured by ce-compound |
```

For existing files, step 2 and step 3 need idempotent handling: check for the row and insert it if missing.

## Skills Not Changed

- `create-mission`, `save-code-gap` — no lesson capture flow
- `finish-mission`'s step 1 (discover) and step 5 (cleanup) — structurally unchanged
- The writing standard reference doc at `skills/writing-standard/RULES.md` — unchanged; it is the source of truth for both captain's injection and any future reference

## Tradeoffs Accepted

- **Full mode cost.** Four parallel subagents per captured lesson is the default. Acceptable because finish-mission is a terminal, low-frequency step.
- **No second review gate.** ce-compound output passes through the existing gate only once (post-write). If ce-compound produces violations, the gate catches them and Claude fixes inline.
- **Two sources of truth for writing standard content.** Captain's injection text is a compressed paraphrase of `RULES.md`, not a pointer. If `RULES.md` changes, `finish-mission`'s injection string must be updated manually. This is a small drift risk worth the simplicity.

## Known Gaps

The `sync-standards` gap from the prior mission still applies: when captain updates, existing projects' CLAUDE.md `## Documentation Standards` section and Project Docs table do not auto-refresh. The same mechanism that would solve that gap would also keep the new `docs/solutions/` table row in sync.
