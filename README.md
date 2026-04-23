# captain

Mission and project management skills for Claude Code.

## Prerequisites

The `superpowers` plugin must be installed before captain. Install it first:

```
claude plugin marketplace add obra/superpowers-marketplace
claude plugin install superpowers
```

The `compound-engineering-plugin` must also be installed. Captain's `finish-mission` skill invokes its `ce-compound` skill to capture reusable lessons to `docs/solutions/`.

```
claude plugin marketplace add EveryInc/compound-engineering-plugin
claude plugin install compound-engineering
```

`jq` must also be installed:
- macOS: `brew install jq`
- Linux: `sudo apt install jq` or `sudo yum install jq`

## Installation

```
claude plugin marketplace add patrickdwyer33/pattymarket
claude plugin install captain
```

## Auto-updates

Claude Code does not auto-update third-party plugins by default. To keep captain current, enable auto-updates after installing:

1. Run `/plugin` in Claude Code
2. Go to **Marketplaces** → **pattymarket**
3. Enable **Auto-update**

After enabling, captain will update on every session start. If you update but still see old skills, delete `~/.claude/plugins/cache/captain/` and restart.

## Skills

| Skill | Description |
|---|---|
| `captain:create-mission` | Add a new mission to the JSONL store; regenerates `MISSIONS.md` |
| `captain:remove-mission` | Complete or delete a mission in the JSONL store; regenerates `MISSIONS.md` and `COMPLETED.md` |
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
    - compound-engineering — https://github.com/EveryInc/compound-engineering-plugin
    - captain — https://github.com/patrickdwyer33/captain

Team members who open the project in Claude Code will see this requirement in their context.

## License

MIT
