# justbrief

> Claude Code skills that turn a small brief into a finished thing.

[![Installs](https://skills.sh/b/sezeryavuz/justbrief)](https://www.skills.sh/sezeryavuz/justbrief)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](./LICENSE)
[![Agents](https://img.shields.io/badge/agents-Claude%20Code%20%7C%20Cursor%20%7C%20Codex-8b5cf6)](https://www.skills.sh)

Most agent skills demand a lot of upfront input — long specs, dense configs, prescriptive instructions about how the work should be done. **justbrief** is a collection of AI agent skills built on a different idea. Each skill takes a small set of brief documents and produces a complete deliverable autonomously. You stay at the brief level; the AI agent handles the phased build underneath.

## The pattern

```
You write:  a brief
You get:    a complete deliverable
```

## Skills in this collection

| Skill | Version | What it produces |
| --- | --- | --- |
| [brief-to-prod](./skills/brief-to-prod) | v0.2.0 | A complete software project from one brief — planned, built, tested, and deployed autonomously, using Claude Code's native autonomy primitives. |

## Planned skills

- **brief-to-gtm** — turns a positioning brief into a go-to-market launch plan. _Planned._
- **brief-to-pitch** — turns a story brief into a pitch deck and narrative. _Planned._
- **brief-to-research** — turns a research brief into a structured report with cited evidence. _Planned._

## Quick start

```bash
npx skills add sezeryavuz/justbrief --skill <skill-name>
```

Works with [Claude Code](https://www.anthropic.com/claude-code), Cursor, Codex, Windsurf, and any agent that consumes skills.sh skills.

## Why justbrief

Most AI agent workflows make you redefine the workflow itself every time — what step is first, what to do next, where to stop. The cognitive load lives outside the agent, in your head.

justbrief skills carry the workflow inside them. You hand the agent a brief; the skill decides the phasing, the artifacts, and the gates. Every skill in the family obeys the same autonomy contract — same way to start, same way to hand off — so you only learn one mental model to use them all.

## Repository conventions

- All skills follow the `brief-to-X` naming pattern (e.g. `brief-to-prod`, `brief-to-gtm`).
- Each skill lives in its own top-level folder containing:
  - `SKILL.md` — the agent-facing skill definition.
  - `README.md` — human-facing overview.
  - `templates/` — supporting templates or example briefs (optional).
- Skills conform to [skills.sh](https://www.skills.sh) conventions for discovery and indexing.

## Contributing

Pull requests welcome. New skill proposals go through GitHub Discussions first — see [CONTRIBUTING.md](./CONTRIBUTING.md).

## License

MIT — see [LICENSE](./LICENSE).

## Acknowledgements

Built for [skills.sh](https://www.skills.sh), the agent skills directory. Distributed via the open-source [skills CLI](https://www.npmjs.com/package/skills) by Vercel.
