# Captain Writing Standard

All written content produced under captain workflows must follow these two directives.

## Directive 1: Stateless

Every doc must be fully readable by someone who was not in the conversation that produced it.

- All context lives in the doc; none lives in the session.
- No session-relative labels: "NEW:", "UPDATED:", "CHANGED:" are banned. Describe what something is now, not that it changed.
- No conversational back-references: "as discussed", "not like this [X]", "per our conversation" are banned.
- Clarifications state the reason, not the trigger: "Use X instead of Y because Z" — not "we clarified that X is correct here."
- No first-person session voice: avoid "I added", "we decided", "I noted". State the fact directly.
- No implicit temporal anchors: "recently added", "just implemented", "at the time of writing" make no sense to a future reader. Drop them or replace with specifics.

## Directive 2: Remove Stale Concepts and Misunderstandings

Docs must reflect current understanding only. Anything corrected, superseded, or misread during the session must be purged — not documented as a correction.

- If a misunderstanding was clarified, the final doc states only the correct thing. No trace of the wrong path. (e.g., if a function's behavior was misunderstood and then corrected, the doc states the correct behavior only — not "originally we thought X but actually it does Y.")
- If a concept was renamed, replaced, or abandoned mid-session, remove all references to the old concept. (e.g., if `JobRunner` was renamed to `TaskExecutor` during the session, the doc mentions only `TaskExecutor`.)
- Describe only the current state, not how the work evolved — a reader should not be able to infer what was tried, discarded, or corrected.
