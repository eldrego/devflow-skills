# devflow-commit

| Field | Value |
|---|---|
| Name | devflow-commit |
| Price | Free |
| Upload | `dist/devflow-commit-<version>.zip` |
| Categories | Developer tools (first), Git, Productivity |
| Tags | git, conventional-commits, commits, workflow, jira |
| Compatibility | Requires git and bash (macOS or Linux). |
| Permissions | Terminal (git, bash); reads files; writes a commit message file in `.git/`. No network. |
| Docs link | https://github.com/eldrego/devflow-skills |

## Summary

Turns your working tree into atomic Conventional Commits, one logical change each, with the ticket reference taken from the branch name. Shows the plan first, validates every message, never pushes.

## Description

Turns a messy working tree into clean, atomic commits with Conventional Commits messages. Each commit is one logical change that builds on its own and can be reverted without undoing anything else.

- Splits your changes into separate commits by intent (feat, fix, refactor, test, docs)
- Writes a title, an optional body and an optional footer
- Reads the ticket from your branch name (`SB-142`, `#123`) and adds it to the footer, never guessing one
- Shows the full plan and waits for your approval before committing
- Checks every message with a bundled validator before committing

**Try it:** "commit my changes", "split this into commits", "fix my last commit message"

Works best in Claude Code; works in any agent that runs skills. Part of **devflow**: pairs with devflow-plan and devflow-review for a full plan → review → commit loop.

## See it in action

TODO: paste a real run (700+ characters): the request, the commit plan it showed, and the final `git log`.

## Limitations

- Never pushes, amends pushed commits, or skips hooks.
- Won't use interactive staging; when one file mixes unrelated changes it asks how to split it.
- Ticket detection covers Jira-style keys and GitHub issue numbers; set `git config devflow.ticketKeys "ABC"` to avoid false matches.

## FAQ

- **Does it follow my repo's commitlint config?** Yes. The project's types, scopes and limits win.
- **Does it add "Co-Authored-By" lines?** No, never.
