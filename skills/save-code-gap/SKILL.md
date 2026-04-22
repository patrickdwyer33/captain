---
name: save-code-gap
description: Save a code gap (stub, unimplemented function, or known shortcut) to GAPS.md at the project root. Use when discovering code that is stubbed out, returns placeholder values, or is explicitly marked as not yet implemented.
---

# Save Code Gap

Record a known code gap in `GAPS.md` at the root of the current project.

## What is a code gap?

A code gap is a function, route, or module that:
- Is stubbed out (returns fake/hardcoded success)
- Returns a 501 Not Implemented response
- Has a `TODO` or `FIXME` comment indicating missing implementation
- Is known to be incomplete but left for later

## Steps

1. **Locate GAPS.md** — find `GAPS.md` at the root of the current project. If it doesn't exist, create it with a `# Code Gaps` header.

2. **Gather gap details** — identify:
   - The function or endpoint name
   - The file/location (e.g. `vm-mcp`, `api/src/routes/projects.ts`)
   - A brief description of what's missing
   - How it should be implemented (the API, approach, or reference to use)

3. **Write the entry** — apply the captain writing standard (`skills/writing-standard/RULES.md`): describe what is unimplemented and how it should be implemented, not the session that discovered it. No "as discussed", no session context, no stale concepts. Append to the bullet list in `GAPS.md` using this format:

```markdown
- `identifier` (location): short description of what's missing — implementation hint (e.g. which API to call, what approach to use)
```

   Example:
   ```markdown
   - `update_firewall` (vm-mcp): stub returns fake success — implement via Linode Firewall API (`GET /linode/instances/{id}/firewalls`, `PUT /networking/firewalls/{id}/rules`, create+attach if none)
   ```

4. **Confirm** — tell the user the gap was saved.

## Notes

- One bullet per gap — don't combine multiple gaps into one entry.
- Keep the implementation hint actionable: name the specific API endpoint, pattern, or approach.
- Also check `CLAUDE.md` — some projects track gaps there too. Don't duplicate; `GAPS.md` is the canonical list.
