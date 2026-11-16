---
name: clean-js
description: Load before creating or editing any .js, .jsx, .ts, .tsx, .mjs or .cjs file. Applies opinionated JavaScript/TypeScript clean-code conventions (Node, React, Express, browser, microfrontends) and runs the project's linters on the result. Use for every task that writes JS/TS — implementing a plan, ticket, feature or fix, creating or changing functions, components, hooks, state stores (Zustand, Redux), routes, services, configs, modules, or tests (Vitest, Jest, Playwright, node:test), refactoring or tidying code, and reviewing code quality — even if the user doesn't mention clean code or style.
summary: Opinionated clean-code conventions for JavaScript and TypeScript (Node, React, Express, tests), applied whenever your agent writes or changes JS/TS. Your project's own config always wins.
version: 1.0.0
tags: [javascript, typescript, react, node, clean-code, testing]
keywords: [clean code, code style, refactoring, code smells, vitest, jest]
use_cases:
  - Write new JS/TS features in a consistent, clean style
  - Refactor or tidy existing JavaScript or TypeScript
  - Write tests that don't repeat the test config
  - Review JS/TS code quality against clear rules
docs_url: https://github.com/eldrego/devflow-skills
---

# Clean JS

Apply these conventions to all JavaScript/TypeScript you write or modify.
They are opinionated; follow them over general defaults.

Requires: bash. Optional: Biome or ESLint in the project (for automatic linting).

## Workflow

1. Before writing, check the project's existing style: Biome config
   (`biome.json`/`biome.jsonc`), ESLint config, Prettier config, `tsconfig.json`,
   and neighboring files. If the project's config conflicts with a rule below,
   the project wins — consistency within a codebase matters more than any
   individual rule.
2. Write the code following the core rules below.
3. Self-review against the checklist at the end of this file.
4. Run the linters on the files you changed: run this skill's
   `scripts/lint.sh` with the changed files as arguments, from the project
   root. It runs Biome and/or ESLint, whichever the project is configured for,
   **with safe auto-fixes, so it edits those files**. Fix what it reports and
   re-run until it is clean.

When refactoring, change structure without changing behavior. If behavior must
change, say so explicitly. Keep refactors scoped to what was asked.

## Writing tests

Before writing or editing tests, run this skill's `scripts/test-config.sh`
from the project root.
It prints the Vitest/Jest/Playwright config and global setup files. Anything
configured there applies to every test, so **do not repeat it inside test
files** — duplicated setup drifts out of sync and hides what a test is
actually about. In particular, don't repeat:

- Mock resets (`clearMocks`, `mockReset`, `restoreMocks`) → no
  `afterEach(() => vi.clearAllMocks())` / `jest.restoreAllMocks()`.
- Setup-file work: `@testing-library/jest-dom` imports, MSW
  `server.listen/resetHandlers/close`, RTL `cleanup()`, polyfills.
- `environment` / `testEnvironment` → no per-file `@vitest-environment` or
  `@jest-environment` docblocks that match the default.
- `globals: true` → follow the existing tests on whether to import
  `describe/it/expect`; don't mix styles.
- `testTimeout`, fake-timer config, `unstubGlobals`/`unstubEnvs`.
- Path aliases (`resolve.alias`, `moduleNameMapper`) → use the alias, not long
  relative imports.
- Playwright `use.baseURL` → `page.goto('/path')`, not full URLs;
  `storageState`/global setup auth → don't log in inside each test; don't
  override `retries`, `timeout`, or `viewport` per test without a reason.

Only add per-test setup for things that are genuinely specific to that test.
See `references/conventions.md` section 7 for test style rules.

## Core rules

**Variables**: `const` by default; `let` only when reassigned; never `var`.

**Control flow**: Use guard clauses and early returns instead of nested
`if/else`. Max nesting depth of 2 — deeper nesting hides the main path. No
nested ternaries; readers misparse them.

**Functions**: One job per function, roughly 30 lines max. More than 3
parameters → take a single options object so call sites are self-describing.
Prefer pure functions; push side effects (I/O, DOM, network) to the edges.

**Async**: `async/await` over `.then()` chains. Never leave a promise floating —
await it or handle it explicitly. Run independent work with `Promise.all`
instead of sequential awaits.

**Errors**: Never write an empty `catch`. Either handle the error meaningfully,
add context and rethrow (`throw new Error('Failed to load user', { cause: err })`),
or let it propagate. Throw `Error` objects, never strings.

**Naming**: Booleans read as questions (`isActive`, `hasAccess`, `canEdit`).
Functions are verbs (`fetchUsers`, `formatPrice`). Avoid abbreviations except
widely known ones (`id`, `url`, `db`). Magic numbers and strings become named
`UPPER_SNAKE_CASE` constants.

**Data**: Don't mutate function arguments or shared state; return new values
(spread, `map`, `filter`, `structuredClone`). Use optional chaining (`?.`) and
nullish coalescing (`??`) instead of long `&&` chains or `||` defaults that
break on `0` and `''`.

**Modules**: Named exports, not default exports — they keep names consistent
across imports and make refactoring safer. One main concern per file.

**Comments**: Explain *why*, not *what*. Delete commented-out code; git keeps
history.

For detailed rules on arrays, React, TypeScript, Node/Express, and testing,
read `references/conventions.md`. For before/after examples of these rules,
read `references/examples.md`. For design-level problems to avoid (duplicated
code, feature envy, speculative generality, prop drilling, and others), read
`references/code-smells.md` — these are judgement calls, not firm rules.

## Self-review checklist

- [ ] No `var`; `let` only where reassigned
- [ ] No nesting deeper than 2; no nested ternaries
- [ ] No function over ~30 lines or with more than 3 positional parameters
- [ ] No floating promises; independent awaits use `Promise.all`
- [ ] No empty `catch` blocks; only `Error` objects thrown
- [ ] No magic numbers/strings; names are descriptive
- [ ] No mutated arguments
- [ ] Named exports only
- [ ] Tests don't repeat anything from the test config or setup files
- [ ] Linters pass (or none were configured and you said so)
