# devflow-commit

| Field | Value |
|---|---|
| Name | devflow-commit |
| Price | Free |
| Upload | `dist/devflow-commit-<version>.zip` |
| Logo | `agensi/logos/devflow-commit.png` (512×512; SVG source alongside) |
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

**Request:** "commit my changes" (three new files implementing a discount-code lookup, on branch `feat/discount-config`)

**Result:**

I committed your changes as one commit on `feat/discount-config`, and I didn't push.

`f3789ea feat(discounts): add discount code config and lookup`

It contains `config/discount-codes.json`, `src/discounts.js` and `test/discounts.test.js`. The message passed the commit-message check, and the working tree is clean. The branch name has no ticket key, so no `Refs:` footer was added.

**The commit message:**

```
feat(discounts): add discount code config and lookup

Load discount codes from config/discount-codes.json and validate
every entry (type, value range, minSubtotal, real expiry date,
no duplicate codes). Lookup is case-insensitive and trims input.
An invalid or unreadable config makes every code report as
unavailable instead of throwing.
```

On a branch like `feat/SB-142-discounts`, the same commit would end with `Refs: SB-142`. When the changes span several concerns (say, a feature plus an unrelated fix), it proposes one commit per concern and shows the full plan before committing anything.

## Limitations

- Never pushes, amends pushed commits, or skips hooks.
- Won't use interactive staging; when one file mixes unrelated changes it asks how to split it.
- Ticket detection covers Jira-style keys and GitHub issue numbers; set `git config devflow.ticketKeys "ABC"` to avoid false matches.

## FAQ

- **Does it follow my repo's commitlint config?** Yes. The project's types, scopes and limits win.
- **Does it add "Co-Authored-By" lines?** No, never.
