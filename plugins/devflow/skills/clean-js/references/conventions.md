# Detailed conventions

## Contents

1. Arrays and iteration
2. Objects and immutability
3. Functions
4. React
5. TypeScript
6. Node and Express
7. Testing

---

## 1. Arrays and iteration

- Prefer `map`, `filter`, `find`, `some`, `every` over manual `for` loops when
  they express the intent directly.
- Use `for...of` when you need `await` inside the loop, early `break`, or when a
  chain of array methods would be harder to read.
- Don't use `reduce` for something `map`/`filter` or a plain loop does more
  clearly. `reduce` is for folding into a single value.
- Don't use `forEach` with `async` callbacks — it doesn't wait. Use
  `for...of` (sequential) or `Promise.all(items.map(...))` (parallel).
- Use `Object.groupBy` / `Map` for grouping when supported by the runtime.

## 2. Objects and immutability

- Destructure parameters and return values when it improves readability.
- Return new objects/arrays instead of mutating: `{ ...user, name }`,
  `[...items, item]`, `items.filter(...)`.
- Use `Object.freeze` for constant lookup tables that must not change.
- Prefer a lookup object or `Map` over long `switch`/`if-else` chains that map
  values to values.

## 3. Functions

- Default parameters instead of `x = x || default` inside the body.
- Arrow functions for callbacks and short helpers; `function` declarations for
  top-level named functions (hoisting and clearer stack traces).
- A function should operate at one level of abstraction. If it mixes
  high-level steps with low-level details, extract the details.
- Boolean flag parameters (`render(true)`) are a smell — split into two
  functions or use an options object with a named key.

## 4. React

- One component per file; file name matches the component (`UserCard.jsx`).
- Function components and hooks only; no class components in new code.
- Extract reusable stateful logic into custom hooks (`useUsers`, `useDebounce`).
- Keep components small: if JSX exceeds ~80 lines, extract subcomponents.
- Derive values during render instead of syncing them into state with
  `useEffect`. Reach for `useEffect` only for real side effects.
- Always provide stable, unique `key`s — never array indexes for lists that can
  reorder.
- Don't create inline objects/functions in props of memoized children unless
  wrapped in `useMemo`/`useCallback`; otherwise don't prematurely memoize.
- Early-return loading and error states before the main JSX.

## 5. TypeScript

- No `any`. Use `unknown` and narrow it, or write a proper type.
- Let inference work for local variables; annotate function parameters and
  exported return types.
- Use `type` for unions and compositions; `interface` for object shapes that may
  be extended. Be consistent with the project.
- Prefer union types of string literals over `enum`.
- Avoid non-null assertions (`!`); handle the `null`/`undefined` case.
- Use `satisfies` to check object literals against a type without widening.

## 6. Node and Express

- Keep route handlers thin: validate input, call a service function, send the
  response. Business logic lives in plain functions that are easy to test.
- Validate request input at the boundary (e.g., zod) before using it.
- Centralize error handling in an error middleware; handlers `throw` or call
  `next(err)` instead of sending ad-hoc error responses.
- Read configuration from environment variables in one config module, not
  scattered `process.env` lookups.
- Use `node:` prefixes for built-in imports (`import fs from 'node:fs/promises'`).

## 7. Testing

- Before writing tests, run `scripts/test-config.sh` and don't repeat in test
  files anything the config or setup files already do (see SKILL.md,
  "Writing tests"). Before adding a `beforeEach`/`afterEach`, check whether the
  config already does it.
- Test behavior, not implementation details.
- One behavior per test; test names read as sentences
  (`it('returns 0 when the user is missing')`).
- Arrange / Act / Assert structure with blank lines between sections.
- Pure functions extracted per the rules above should get unit tests.
