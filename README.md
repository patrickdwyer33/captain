# captain

Task and project management skills for Claude Code.

## Prerequisites

The `superpowers` plugin must be installed before captain. Install it first:

```
claude plugin install github:obra/superpowers
```

## Installation

```
claude plugin install github:patrickdwyer33/captain
```

## Skills

| Skill | Description |
|---|---|
| `captain:create-task` | Add a new task to `TASKS.md` |
| `captain:remove-task` | Remove a task from `TASKS.md` |
| `captain:start-task` | Begin implementing a task; invokes `superpowers:brainstorming` |
| `captain:finish-task` | Post-implementation cleanup: update docs, remove task/gaps |
| `captain:save-code-gap` | Record a stub or unimplemented function in `GAPS.md` |
| `captain:remove-code-gap` | Remove a resolved gap from `GAPS.md` |
| `captain:init-project-docs` | Initialize standard project docs at the project root |

## Declaring as a Project Dependency

Claude Code has no native plugin dependency mechanism. Signal that a project requires captain by adding this to the project's `CLAUDE.md`:

    ## Required Plugins
    - superpowers — https://github.com/obra/superpowers
    - captain — https://github.com/patrickdwyer33/captain

Team members who open the project in Claude Code will see this requirement in their context.

## License

MIT
