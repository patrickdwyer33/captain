---
name: create-mission
description: Add a new mission to the project's MISSIONS.md. Use when the user wants to record a new mission, feature, or work item to track. Missions are stored as H2 sections in MISSIONS.md at the project root.
---

# Create Mission

Add a new mission entry to `MISSIONS.md` at the root of the current project.

## Steps

1. **Locate MISSIONS.md** — find `MISSIONS.md` at the root of the current working project (the nearest ancestor directory containing a `CLAUDE.md`, `package.json`, `Cargo.toml`, or `.git`). If none exists, create it with a `# Outstanding Missions` header and a `# Completed Missions` section.

2. **Determine the next mission number** — count existing `## Mission N:` headings in `MISSIONS.md` and increment by 1.

3. **Gather mission details** — if the user hasn't provided enough detail, ask:
   - Mission name (becomes the heading title after the number)
   - Goal (one sentence: what this accomplishes and why it matters)
   - Background (context, motivation, what triggered this)
   - Notes (constraints, dependencies, decisions already made — optional)
   - Depends on (optional) — "Does this mission depend on any other missions completing first? If so, list them by full heading (e.g., `Mission 3: Add rate limiting`). Leave blank if none."
   - Phases or sub-steps (optional — use if the mission has distinct stages)

4. **Write the entry** — insert into the `# Outstanding Missions` section of `MISSIONS.md` (before the `# Completed Missions` section) at the end of the active missions list, using this format:

```markdown
## Mission 3: Mission Name

**Goal:** One sentence describing what this accomplishes and why it matters.

**Background:** Context, motivation, history. What triggered this mission?

**Notes:** Constraints, decisions already made. (Optional — omit if nothing to say.)

**Depends on:** Mission 3: Name, Mission 5: Other Name (Optional — omit if no dependencies.)

**Phase 1 — First stage name**
- Sub-item one
- Sub-item two

**Phase 2 — Second stage name**
- Sub-item one
- Sub-item two
```

   - **Goal** and **Background** are required. **Notes** and **Depends on** are optional — omit entirely if nothing to say.
   - Omit phases if the mission is simple — use a flat bullet list after Background/Notes instead.

5. **Confirm** — tell the user the mission was added and show the new entry.

## Notes

- Never overwrite existing missions.
- Never reuse or reorder mission numbers — numbers are permanent identifiers, not rankings.
- Insert new missions at the end of the `# Outstanding Missions` section, just before the `# Completed Missions` section. Outstanding missions are ordered ascending (lowest number first, highest last).
- Use present-tense imperative phrasing for mission names (e.g. "Add rate limiting", not "Rate limiting added").
