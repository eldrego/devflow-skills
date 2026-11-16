# Conventional Commits reference

Based on https://www.conventionalcommits.org/en/v1.0.0/

## Contents

1. Structure
2. Types
3. Scopes
4. Breaking changes
5. Footers
6. Ticket references from branch names
7. Complete examples
8. Common mistakes

---

## 1. Structure

```
<type>[optional scope][optional !]: <description>

[optional body]

[optional footer(s)]
```

From the spec:
- The type is followed by an optional scope in parentheses, an optional `!`,
  then a colon and a space.
- The description immediately follows the colon and space.
- The body starts one blank line after the description and is free-form.
- Footers start one blank line after the body (or the description, if there is
  no body). Each footer is a token, then `: ` or ` #`, then a value.
- Footer tokens use `-` instead of spaces (`Acked-by`), except
  `BREAKING CHANGE`, which may also be written `BREAKING-CHANGE`.

## 2. Types

The spec defines `feat` and `fix`. The others are the widely used set from
`@commitlint/config-conventional`.

| Type | Use for | Example title |
|---|---|---|
| `feat` | A new feature for the user or consumer | `feat(auth): add Zustand auth store` |
| `fix` | A bug fix | `fix(shell): prevent RemoteLoader remount on route change` |
| `perf` | A change that improves performance | `perf(movies): memoize poster grid rows` |
| `refactor` | Restructuring without changing behavior | `refactor(auth): extract token refresh helper` |
| `style` | Formatting only (whitespace, semicolons) | `style: apply biome formatting` |
| `test` | Adding or fixing tests only | `test(auth): cover expired token refresh` |
| `docs` | Documentation only | `docs: add docker setup guide` |
| `build` | Build system, bundler, Docker, dependencies | `build(docker): add nginx image for shell` |
| `ci` | CI configuration and scripts | `ci: cache pnpm store in GitHub Actions` |
| `chore` | Maintenance that fits nothing else | `chore: update .gitignore for env files` |
| `revert` | Reverting a previous commit | `revert: feat(auth): add Zustand auth store` |

Choosing between similar types:
- New behavior → `feat`. Broken behavior now correct → `fix`. Same behavior,
  better code → `refactor`. Same behavior, faster → `perf`.
- A dependency added *for a feature* is part of that `feat` commit, not `build`.

## 3. Scopes

- Optional. Use a noun for the area of the codebase, in lowercase.
- In an Nx / microfrontend monorepo, use the app or library name:
  `shell`, `movies`, `music`, `contracts`, `shell-e2e`.
- Within one app, a feature area works too: `auth`, `player`, `observability`.
- Be consistent with `git log`. Omit the scope when a change spans the whole
  repo.

## 4. Breaking changes

A breaking change is anything that forces consumers to change: removed or
renamed exports, changed function signatures, changed contract shapes, removed
config options, changed environment variables.

Mark it with `!` in the title **and** explain it in a `BREAKING CHANGE:` footer:

```
feat(contracts)!: rename AuthUser.id to AuthUser.userId

Aligns the contract with the identity provider's payload so remotes no
longer need to map fields.

BREAKING CHANGE: remotes reading `user.id` from the auth contract must
read `user.userId` instead.
Refs: SB-142
```

`!` alone is valid per the spec, but always add the footer so readers know what
to change.

## 5. Footers

| Footer | When |
|---|---|
| `Refs: SB-142` | Ticket found in the branch name (Jira-style key) |
| `Refs: #123` | Ticket found in the branch name (GitHub issue number) |
| `Closes #123` | Only when the user says this commit completes the issue |
| `BREAKING CHANGE: …` | Breaking changes (see section 4) |
| `Reviewed-by: Name` | Only if the user asks |

Never add `Co-Authored-By`, `Generated with …`, or other attribution lines.

## 6. Ticket references from branch names

`scripts/branch-ticket.sh` extracts the ticket. Rules, in order:

1. An uppercase Jira-style key anywhere in the branch (`SB-142`).
2. A lowercase Jira-style key at the start of a path segment, uppercased
   (`sb-142` → `SB-142`). Common branch words (`feat`, `fix`, `release`, `gh`,
   `issue`, `node`, …) are never treated as keys.
3. A GitHub issue number: a segment starting with digits (`123-fix-x`), or
   `issue-123`, `issues/123`, `gh-123`, `#123` → `#123`.
4. Otherwise nothing — no ticket footer.

Bot branches (`dependabot/…`, `renovate/…`) never produce a ticket.

To limit matching to your real Jira project keys (avoids false positives such as
`feature/tailwind-4-upgrade` → `TAILWIND-4`), set them per repo or globally:

```
git config devflow.ticketKeys "SB,STREAM"        # this repo
git config --global devflow.ticketKeys "SB"      # all repos
```

### Samples

| Branch name | Ticket | Footer |
|---|---|---|
| `feature/SB-142-auth-store` | `SB-142` | `Refs: SB-142` |
| `feat/sb-142-auth-store` | `SB-142` | `Refs: SB-142` |
| `SB-142-auth-store` | `SB-142` | `Refs: SB-142` |
| `SB-142` | `SB-142` | `Refs: SB-142` |
| `bugfix/STREAM-7_remount-loop` | `STREAM-7` | `Refs: STREAM-7` |
| `fix/PROJ2-88-null-session` | `PROJ2-88` | `Refs: PROJ2-88` |
| `jdoe/SB-301/new-relic` | `SB-301` | `Refs: SB-301` |
| `hotfix/sb-9` | `SB-9` | `Refs: SB-9` |
| `fix/123-remoteloader-remount` | `#123` | `Refs: #123` |
| `123-remoteloader-remount` | `#123` | `Refs: #123` |
| `issue-45-docker-build` | `#45` | `Refs: #45` |
| `feature/issue-45-docker` | `#45` | `Refs: #45` |
| `issues/45` | `#45` | `Refs: #45` |
| `gh-45-ci-cache` | `#45` | `Refs: #45` |
| `main` | — | none |
| `feature/auth-store` | — | none |
| `feature/oauth2-login` | — | none |
| `release/1.4.0` | — | none |
| `dependabot/npm_and_yarn/vite-7.0.1` | — | none |
| `feature/node-20-upgrade` | — | none |
| `feature/vite-7-upgrade` | — | none |
| `feature/tailwind-4-upgrade` | `TAILWIND-4` ⚠ | set `ticketKeys` to avoid |
| `feature/tailwind-4-upgrade` with `ticketKeys=SB` | — | none |
| `fix/STREAM-7-x` with `ticketKeys=SB` | — | none (not a listed key) |

When the plan is shown to the user, always state the detected ticket so a wrong
match can be corrected before committing.

## 7. Complete examples

Title only (trivial change):
```
docs: fix typo in docker setup guide
```

Title + footer:
```
ci: cache pnpm store in GitHub Actions

Refs: SB-150
```

Title + body + footer:
```
fix(shell): prevent RemoteLoader remount on route change

RemoteLoader created a new lazy component on every render because the
import factory was defined inline, so React treated it as a new type and
remounted the remote, losing its state. The factory is now memoized per
remote name.

Refs: SB-142
```

Feature with a dependency:
```
feat(observability): add New Relic browser agent

Initializes the agent before the app mounts and adds typed helpers for
custom events so remotes can report through the shell.

Refs: SB-301
```
(Files: `newrelic.ts`, `newrelicEvents.ts`, `main.tsx`, `package.json`,
`pnpm-lock.yaml`.)

Revert:
```
revert: feat(auth): add Zustand auth store

This reverts commit 1a2b3c4 because the store broke SSR in the movies
remote.

Refs: SB-142
```

## 8. Common mistakes

| Wrong | Right | Why |
|---|---|---|
| `Fix: Added login.` | `fix: add login` | lowercase type, imperative, no period |
| `feat(Auth): add store` | `feat(auth): add store` | lowercase scope |
| `feat:add store` | `feat: add store` | space after colon |
| `update stuff` | `fix(shell): handle missing remote url` | type required; be specific |
| `chore: deps` (separate commit) | dependency inside the `feat` commit | atomic: code + its dependency |
| `fix: fix auth and add docker and ci` | three commits | one change per commit |
| `Refs: SB-142` on `main` with no ticket | no footer | never invent tickets |
