# Contributing to justbrief

Welcome. justbrief is a family of Claude Code / AI agent skills built around one idea: each skill takes a small brief and produces a complete deliverable autonomously. Contributions that fit that philosophy are very welcome.

## Naming

All skills in this collection follow the `brief-to-X` pattern, where `X` is the deliverable (e.g. `brief-to-prod`, `brief-to-gtm`, `brief-to-pitch`). If your idea doesn't fit that shape, it probably belongs in a different repo.

## Proposing a new skill

Before opening a pull request, open a [GitHub Discussion](https://github.com/sezeryavuz/justbrief/discussions) describing:

- **Brief shape** — what documents does the user provide?
- **Deliverable shape** — what does the skill produce?
- **Autonomy boundary** — what decisions does the skill make on its own, and what does it surface to the human admin?

This lets us check fit before anyone writes the skill.

## Skill folder structure

Each skill lives in its own top-level folder:

```
brief-to-X/
  SKILL.md      # agent-facing skill definition (required)
  README.md     # human-facing overview (required)
  templates/    # supporting templates or example briefs (optional)
```

## SKILL.md authoring guidelines

- The `description` field must be a clear paragraph of natural prose. skills.sh uses semantic search; well-written prose with relevant keywords beats lists of tags.
- State **activation conditions** plainly — when should the agent reach for this skill?
- State **when not to activate** — false-positive prevention matters as much as recall.
- Keep instructions to the agent direct and imperative. Avoid hedging.

## Testing locally

To test a skill in development, point the `skills` CLI at the local repo:

```bash
npx skills add ./path/to/justbrief --skill brief-to-X
```

Then run the skill from a fresh agent session against a real brief.

## Style

Sentence case for headings. Concise prose over bulleted exhaustiveness. American English.

## Code of Conduct

Everyone interacting in this project is expected to follow our [Code of Conduct](./.github/CODE_OF_CONDUCT.md).
