# devflow skills

Free agent skills for everyday development, usable in Claude Code as a plugin.

| Skill | What it does |
|---|---|
| `devflow-atomic-commits` | Splits your working tree into atomic Conventional Commits and adds the ticket reference from the branch name. Shows the plan first, validates every message, never pushes. |
| `devflow-clean-js` | Opinionated JavaScript/TypeScript clean-code conventions (Node, React, Express, tests), with lint and test-config helpers. Your project's config always wins. |

Each skill works on its own.

## Install (Claude Code)

```
/plugin marketplace add eldrego/devflow-skills
/plugin install devflow@devflow
```

Update later with `/plugin marketplace update devflow`.

## Notes

- `devflow-atomic-commits` reads ticket keys such as `SB-142` or `#123` from the branch name. To limit matches to your Jira keys: `git config --global devflow.ticketKeys "ABC,XYZ"`.
- `devflow-clean-js` runs Biome and/or ESLint with safe auto-fixes if your project has them configured.
- Scripts need `bash` and `git`, on macOS or Linux.

## More devflow skills

Planning (epic breakdown, ticket plans) and three-axis code review are available on [Agensi](https://www.agensi.io).

## License

MIT