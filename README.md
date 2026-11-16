# devflow skills

Free agent skills for everyday development, usable in Claude Code as a plugin.

| Skill | Claude Code | What it does |
|---|---|---|
| commit | `/devflow:commit` | Splits your working tree into atomic Conventional Commits and adds the ticket reference from the branch name. Shows the plan first, validates every message, never pushes. |
| clean-js | `/devflow:clean-js` | Opinionated JavaScript/TypeScript clean-code conventions (Node, React, Express, tests), with lint and test-config helpers. Your project's config always wins. |

Each skill works on its own. You rarely need to type the commands: the skills trigger from requests like "commit my changes" or whenever your agent edits JS/TS.

On Agensi the same skills are listed as `devflow-commit` and `devflow-clean-js`.

## Install (Claude Code)

```
/plugin marketplace add eldrego/devflow-skills
/plugin install devflow@devflow
```

Update later with `/plugin marketplace update devflow`.

## Notes

- The commit skill reads ticket keys such as `SB-142` or `#123` from the branch name. To limit matches to your Jira keys: `git config --global devflow.ticketKeys "ABC,XYZ"`.
- The clean-js skill runs Biome and/or ESLint with safe auto-fixes if your project has them configured.
- Scripts need `bash` and `git`, on macOS or Linux.

## More devflow skills

Planning (epic breakdown, ticket plans) and three-axis code review are available on [Agensi](https://www.agensi.io).

## License

MIT