# Stateless Documentation Standard

**Date:** 2026-04-22
**Status:** Approved

## Problem

Claude Code writes docs and code comments that require the current conversation session to interpret. Examples: "NEW:" prefixes, "as discussed" back-references, clarifications written as "not like this [thing from conversation]", and stale concepts or misunderstandings left in place after correction. These artifacts are meaningless to anyone who wasn't in the session that produced them.

## Goal

Bake a stateless writing standard into captain's skill workflows so that all written output — mission fields, CLAUDE.md entries, doc updates, gap descriptions — is readable by anyone, regardless of whether they were in the writing session.

## Writing Standard

Two directives govern all documentation written under captain workflows.

### Directive 1: Stateless

Every doc must be fully readable by someone who was not in the conversation that produced it. All context lives in the doc; none lives in the session.

Specific rules:
- No session-relative labels: "NEW:", "UPDATED:", "CHANGED:" are banned. Describe what something is now, not that it changed.
- No conversational back-references: "as discussed", "not like this [X]", "per our conversation" are banned.
- Clarifications state the reason, not the trigger: "Use X instead of Y because Z" — not "we clarified that X is correct here."
- No first-person session voice: avoid "I added", "we decided", "I noted". State the fact directly.
- No implicit temporal anchors: "recently added", "just implemented", "at the time of writing" make no sense to a future reader. Drop them or replace with specifics.

### Directive 2: Remove Stale Concepts and Misunderstandings

Docs must reflect current understanding only. Anything corrected, superseded, or misread during the session must be purged — not documented as a correction.

Specific rules:
- If a misunderstanding was clarified, the final doc states only the correct thing. No trace of the wrong path.
- If a concept was renamed, replaced, or abandoned mid-session, remove all references to the old concept.
- Document the destination, not the journey.

## Architecture

### Writing Standard Reference Doc

`skills/writing-standard/RULES.md` — a single reference file inside captain that states both directives and their specific rules. This is not a skill; it is a reference doc that skills cite explicitly. It is the single source of truth for the standard within the plugin.

### CLAUDE.md Injection

`init-project-docs` stamps a condensed "Documentation Standards" section into the project's CLAUDE.md (both directives + specific rules as a checklist). The operation is idempotent: it adds the section if missing, skips if present.

Because CLAUDE.md is always loaded into Claude's context, the standard is visible on every message — not just when a captain skill fires.

**Known gap:** There is no mechanism to update a project's CLAUDE.md writing standard section when the captain plugin updates. A future `captain:sync-standards` skill or a version-check step in `finish-mission` could address this.

## Skill Changes

### `init-project-docs`

New step: ensure the writing standard section exists in CLAUDE.md. Create or append as needed. Skip if already present.

### `create-mission`

New reminder at step 3 (gathering mission details): apply the stateless writing standard before finalizing `goal`, `background`, `notes`, and `body`. These fields are most prone to absorbing session context.

### `save-code-gap`

New brief reminder when writing the gap entry: describe what is unimplemented and why — not the session that discovered it.

### `finish-mission`

Two additions:

**Early injection** (before step 2, doc updates): "Apply the captain writing standard as you write each doc. Do not carry session context into any written content."

**Review gate** (new step between step 2 and step 3, cleanup): Re-read every doc written or updated during this mission. Check each against both directives:
- Stateless: no session labels, back-references, first-person session voice, temporal anchors
- Clean: no stale concepts, no documented misunderstandings

Fix any violations before proceeding. The skill does not advance to `remove-mission` until written content passes this check.

## Skills Not Changed

- `start-mission` — invokes superpowers brainstorming; no direct doc writing
- `remove-mission` — moves data between JSONL files; no written content
- `remove-code-gap` — deletes entries; no written content
- `edit-missions-file` — routes to other operations; no direct writing
- `new-project` — calls `init-project-docs`, inherits the standard automatically
