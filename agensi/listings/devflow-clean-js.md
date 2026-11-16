# devflow-clean-js

| Field | Value |
|---|---|
| Name | devflow-clean-js |
| Price | Free |
| Upload | `dist/devflow-clean-js-<version>.zip` |
| Logo | `agensi/logos/devflow-clean-js.png` (512×512; SVG source alongside) |
| Categories | Developer tools (first), Code quality, JavaScript |
| Tags | javascript, typescript, clean-code, react, node, testing |
| Compatibility | Requires bash. Optional: Biome or ESLint configured in the project. |
| Permissions | Terminal (bash, npx); reads project files; **writes files** (the lint helper applies safe auto-fixes to the files it's given). No network beyond what the project's linters do. |
| Docs link | https://github.com/eldrego/devflow-skills |

## Summary

Opinionated clean-code conventions for JavaScript and TypeScript (Node, React, Express, tests), applied whenever your agent writes or changes JS/TS. Your project's own config always wins.

## Description

Opinionated clean-code conventions your agent applies every time it writes or changes JavaScript or TypeScript: Node, React, Express, browser code, state stores and tests (Vitest, Jest, Playwright).

- Checks your project's Biome, ESLint, Prettier and tsconfig first; your config always wins
- Core rules plus detailed conventions for arrays, objects, functions, React, TypeScript, Node/Express and testing, with before/after examples and a self-review checklist
- A code-smell guide for design-level problems
- Bundled helpers run your linters and show your test config, so tests don't repeat global setup

**Try it:** it runs on its own whenever your agent edits `.js`, `.jsx`, `.ts` or `.tsx` files. You can also ask "tidy this file" or "review this code's quality".

Works best in Claude Code; works in any agent that runs skills. Part of **devflow**: devflow-review uses the same rules for its standards review.

## See it in action

**Request:** "Implement the approved plan for this branch. Run the tests when done." (a discount-code lookup in a small Node project; the skill loaded on its own because the task writes JS)

**Result:**

I implemented the plan in `docs/plan/discount-codes/discount-config.md`. `npm test` passes, with 7 tests: the new discount tests plus the existing cart tests.

- **`config/discount-codes.json`:** three sample codes: `SAVE10` (percent), `FIVEOFF` (fixed, with `minSubtotal`) and `SUMMER25` (with `expiry`).
- **`src/discounts.js`:** `loadCodes()` reads the config through `import.meta.url` and validates it. `findCode(input, load = loadCodes)` trims the input and matches case-insensitively, returning `{ok:true, code}` or `{ok:false, reason}`.
- **`test/discounts.test.js`:** covers case-insensitive lookup, trimming, unknown, empty and non-string input, and the fail-closed cases.

The project has no Biome or ESLint config, so the lint step didn't run.

**What the conventions look like in the code:**

```js
export function findCode(input, load = loadCodes) {
  let codes;
  try {
    codes = validateCodes(load());
  } catch {
    return UNAVAILABLE;
  }
  if (typeof input !== 'string') return NOT_FOUND;
  const wanted = input.trim().toLowerCase();
  const code = codes.find((entry) => entry.code.trim().toLowerCase() === wanted);
  return code && wanted !== '' ? { ok: true, code } : NOT_FOUND;
}
```

Named exports, guard clauses instead of nesting, named result constants instead of magic values, no mutation, and an injectable loader so tests don't touch the file system.

## Limitations

- JavaScript and TypeScript only.
- The lint helper edits files (safe auto-fixes only) and needs Biome or ESLint already installed in the project.
- Refactors change structure, not behavior, unless you ask otherwise.

## FAQ

- **What if my team's style differs?** The project's config and existing patterns win over these rules.
