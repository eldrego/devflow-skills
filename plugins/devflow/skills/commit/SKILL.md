---
name: commit
description: Creates atomic git commits with Conventional Commits messages (title, optional body, optional footer), adding the ticket reference from the branch name. Use whenever the user asks to commit, stage and commit, save or check in their work, split changes into commits, write or fix a commit message, or prepare changes for a PR.
summary: Turns your working tree into atomic Conventional Commits, one logical change each, with the ticket reference taken from the branch name. Shows the plan first, validates every message, never pushes.
version: 1.0.0
tags: [git, commits, conventional-commits, workflow]
keywords: [conventional commits, atomic commits, commit message, jira ticket, git history]
use_cases:
  - Split a messy working tree into clean atomic commits
  - Write Conventional Commits messages with the ticket from the branch name
  - Fix or validate a commit message
  - Prepare a branch's history for a pull request
docs_url: https://github.com/eldrego/devflow-skills
allowed-tools: Bash(git status *) Bash(git diff *) Bash(git log *) Bash(git branch *) Bash(git rev-parse *) Bash(git add *) Bash(git commit *) Bash(${CLAUDE_SKILL_DIR}/scripts/branch-ticket.sh *) Bash(${CLAUDE_SKILL_DIR}/scripts/check-commit-msg.sh *) Bash(bash ${CLAUDE_SKILL_DIR}/scripts/branch-ticket.sh *) Bash(bash ${CLAUDE_SKILL_DIR}/scripts/check-commit-msg.sh *)
---

# Atomic commits

Turn the working tree into a series of **atomic commits** — each one a single
logical change that builds, makes sense on its own, and can be reverted without
undoing anything else — with messages that follow Conventional Commits 1.0.0.

Requires: git, bash.

## Workflow

### 1. Read the project's conventions first

- Look for a commitlint config (`commitlint.config.*`, `.commitlintrc*`,
  `"commitlint"` in `package.json`) and `CONTRIBUTING.md`. If they define types,
  scopes, or length limits, **the project wins** over the rules below.
- Run `git log --oneline -15` to see the existing style and scopes in use.

### 2. Gather the state

```
git branch --show-current
git status
git diff
git diff --staged
```

- If something is **already staged**, ask whether to commit exactly what is
  staged, or to re-plan everything.
- If the branch is `main`, `master`, `develop`, or a release branch, **warn the
  user and offer to create a branch first** (e.g.
  `git switch -c feat/SB-142-auth-store`). Wait for their answer.

### 3. Get the ticket reference

Run this skill's `scripts/branch-ticket.sh`. It prints the ticket
(`SB-142` or `#123`) or nothing. If it prints a ticket, every commit gets a
`Refs: <ticket>` footer. If it prints nothing, add no ticket footer — **never
invent or guess a ticket**. See `references/conventional-commits.md`
("Ticket references from branch names") for the patterns it recognizes.

### 4. Group changes into atomic commits

- One reason to change per commit. A feature, its tests, and its docs belong
  together; an unrelated fix you noticed along the way does not.
- Dependency changes (`package.json` + lockfile) go in the **same commit as the
  code that needs them**, never as a separate "deps" commit.
- Pure formatting or renames go in their own `style:` / `refactor:` commit so
  they don't hide real changes in review.
- Order commits so each one works on its own: contracts/types before the code
  that uses them, refactors before the feature that relies on them.
- Never stage secrets or local-only files (`.env`, keys, credentials, editor
  files). `.env.example` is fine. Flag anything suspicious to the user.

### 5. When one file mixes unrelated changes — ask the user

Interactive git commands (`git add -p`, `git add -i`, `git rebase -i`, or
`git commit` without `-F`/`-m`) hang in this environment. **Do not use them.**
When a file contains changes that belong in different commits, stop and ask the
user which they prefer:

1. **Keep them together** in one commit (and mention both changes in the body).
2. **Partial staging by Claude**: build a patch with only the relevant hunks and
   stage it with `git apply --cached` — show which hunks go in which commit first.
3. **User stages it**: they run `git add -p <file>` in their own terminal, then
   tell you to continue.
4. **Leave the file out** of this round of commits.

### 6. Show the plan and wait for approval

Before staging anything, present the plan:

```
Branch: feat/SB-142-auth-store   Ticket: SB-142

1. feat(contracts): add auth session contract
   contracts/auth.ts
2. feat(auth): add Zustand auth store
   shell/src/store/authStore.ts, shell/src/app/app.tsx
3. fix(shell): prevent RemoteLoader remount on route change
   shell/src/components/RemoteLoader.tsx
```

Show the full message (title, body, footer) for each commit. Commit only after
the user approves; apply any edits they ask for.

### 7. Commit each group

For each planned commit, in order:

1. Stage exactly its files: `git add <paths>`.
2. Verify: `git diff --staged --name-only` matches the plan.
3. Write the message to `$(git rev-parse --git-dir)/COMMIT_CHANGES_MSG`.
4. Validate: run this skill's `scripts/check-commit-msg.sh <that file>`.
   Fix any errors it reports.
5. Commit: `git commit -F <that file>`.

If a pre-commit hook fails, the commit did not happen: fix the issue, re-stage,
and commit again. Never bypass hooks.

### 8. Report

Show `git log --oneline -n <number of commits made>` and `git status`. Do not push.

## Message format

```
<type>[(scope)][!]: <description>

[body]

[footer(s)]
```

**Title (required)**
- `type`: `feat` (new feature), `fix` (bug fix), `build`, `chore`, `ci`, `docs`,
  `perf`, `refactor`, `revert`, `style`, `test`.
- `scope` (optional): the area changed — in a monorepo, the app or library name
  (`shell`, `contracts`, `movies`).
- `description`: imperative mood ("add", not "added"/"adds"), lowercase first
  letter, no trailing period.
- Whole title: **72 characters or fewer**.

**Body (optional)**
- Add one when the *why* isn't obvious from the title: the problem, the cause,
  the approach, trade-offs. Skip it for trivial changes.
- Blank line after the title; wrap lines at 72 characters.
- Explain why, not what — the diff shows what.

**Footer (optional)**
- Git trailer format: `Token: value` or `Token #value`, one per line, after a
  blank line. Use `-` instead of spaces in tokens (`Reviewed-by`).
- `Refs: SB-142` — ticket from the branch (step 3).
- `Closes #123` — **only** when the user says the commit completes the issue
  (it auto-closes issues on merge).
- `BREAKING CHANGE: <what consumers must change>` — for breaking changes, together
  with `!` in the title (`feat(contracts)!: …`). Changes to shared contracts or
  public APIs are the usual source.

For the full type table, breaking-change rules, and complete examples, read
`references/conventional-commits.md`.

## Rules

- Commit only when the user asks. **Never push** unless they explicitly say so.
- Never use `--no-verify`, `--no-gpg-sign`, or otherwise skip hooks.
- Never amend, rebase, or force-push commits that have already been pushed.
- **No `Co-Authored-By`, "Generated with", or any other attribution lines** in
  commit messages.
- Never stage secrets.
