# captain

Mission and project management skills for Claude Code.

## Prerequisites

The `superpowers` plugin must be installed before captain. Install it first:

```
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers
```

## Installation

```
claude plugin marketplace add patrickdwyer33/captain
claude plugin install captain
```

## Skills

| Skill | Description |
|---|---|
| `captain:create-mission` | Add a new mission to `MISSIONS.md` |
| `captain:remove-mission` | Move a completed mission to the Completed Missions section, or delete a cancelled mission |
| `captain:start-mission` | Begin implementing a mission; invokes `superpowers:brainstorming` |
| `captain:finish-mission` | Post-implementation cleanup: update docs, move mission to Completed, clean gaps |
| `captain:save-code-gap` | Record a stub or unimplemented function in `GAPS.md` |
| `captain:remove-code-gap` | Remove a resolved gap from `GAPS.md` |
| `captain:init-project-docs` | Initialize standard project docs at the project root |
| `captain:new-project` | Scaffold a new project in `~/dev` with a git repo, private GitHub remote, and standard docs |

## Declaring as a Project Dependency

Claude Code has no native plugin dependency mechanism. Signal that a project requires captain by adding this to the project's `CLAUDE.md`:

    ## Required Plugins
    - superpowers — https://github.com/obra/superpowers
    - captain — https://github.com/patrickdwyer33/captain

Team members who open the project in Claude Code will see this requirement in their context.

## License

MIT
