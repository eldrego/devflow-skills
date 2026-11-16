# devflow-clean-js

| Field | Value |
|---|---|
| Name | devflow-clean-js |
| Price | Free |
| Upload | `dist/devflow-clean-js-<version>.zip` |
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

TODO: paste a real run (700+ characters): a request such as "refactor this handler", and the before/after code with the lint result.

## Limitations

- JavaScript and TypeScript only.
- The lint helper edits files (safe auto-fixes only) and needs Biome or ESLint already installed in the project.
- Refactors change structure, not behavior, unless you ask otherwise.

## FAQ

- **What if my team's style differs?** The project's config and existing patterns win over these rules.
