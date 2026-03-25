---
name: new-project
description: Use when starting a brand new project from scratch in ~/dev.
---

# New Project

Create a new project directory under `~/dev`, initialize git, create a private GitHub repo, and set up standard docs.

## Steps

1. **Get the project name** — ask the user for the project name if not provided. Use it as the directory name and GitHub repo name.

2. **Create the directory** — create `~/dev/<project-name>/`.

3. **Initialize git**
   ```bash
   cd ~/dev/<project-name>
   git init
   ```

4. **Create the GitHub repo** — create a private remote repo using `gh`:
   ```bash
   gh repo create <project-name> --private --source=. --remote=origin
   ```
   - If the user wants it public, pass `--public` instead. Ask if unsure.
   - If the user is working under a GitHub org, ask whether it should be personal or org-scoped (e.g. `gh repo create my-org/<project-name> --private ...`).

5. **Invoke `captain:init-project-docs`** — runs in the new project directory to create `README.md`, `CLAUDE.md`, `MISSIONS.md`, `TODO.md`, `GAPS.md`, `IDEAS.md`, and `docs/notes/`.

6. **Initial commit**
   ```bash
   git add .
   git commit -m "chore: initial project scaffold"
   git push -u origin main
   ```

7. **Confirm** — tell the user the project is ready, show the local path and the GitHub repo URL.

8. **Create missions for any additional instructions** — if the user provided any follow-up work alongside the project creation request (e.g. "create a project for X and also add Y and Z"), do not execute that work now. Instead, use `captain:create-mission` to record each item as a mission in the new project's `MISSIONS.md`.
   - Only create a mission if there is enough information to write a meaningful **Goal** and **Background**. If an instruction is too vague, skip it and note it to the user.
   - Do not create missions for setup steps already completed by this skill (git init, docs scaffold, etc.).

9. **Offer to start a mission** — after confirming the project is ready (and after creating any missions), ask the user: "Would you like to pick a mission to start with?"

## Notes

- Default branch is `main`.
- Default visibility is **private** — always confirm before creating a public repo.
- If `gh` is not authenticated, stop and tell the user to run `gh auth login` first.
- Do not scaffold any language-specific boilerplate (package.json, Cargo.toml, etc.) — this skill is docs and repo only. The user adds code next.
- Never execute post-setup work inline — always capture it as missions so nothing gets lost and work can be prioritized.
