# brief-to-prod

> **Give a brief. Get a finished thing.**

`brief-to-prod` is a Claude Code skill that turns a single brief — one markdown file or one detailed prompt — into a complete software project. Planned, built, tested, and deployed. Autonomous by default. One soft confirm in the middle.

It is the foundational member of the `justbrief` family of skills, all of which follow the same promise: the user supplies *what they want*; the skill handles *how to make it*.

**Version:** `v0.1.0` &nbsp;·&nbsp; **License:** MIT

---

## What it does

You write a brief — a few hundred to a couple thousand words describing what you want built. You drop the file in your repo (or paste it into the session). You invoke this skill.

The skill then:

1. **Reads the brief** and validates it has enough to work with.
2. **Generates the foundation:** `VISION.md`, `PRODUCT-SPEC.md`, `TECHNICAL-DECISIONS.md`, `PLAN.md`, `CLAUDE.md`, `LOG.md`, `NOTES-TO-ADMIN.md`, `SKILLS-TO-INSTALL.md`.
3. **Asks you a focused round of selectable-option questions** to confirm the foundation. This is the only structured interaction.
4. **Stops.** You install any Stage 1 skills, resolve any preemptive blockers, then `/clear` and type `continue`.
5. **Executes the phased build autonomously** across as many sessions as it takes. Tests as it goes. Logs progress. Surfaces blockers via `NOTES-TO-ADMIN.md`. Never asks for permission to move between phases.

It is technology-agnostic. The brief tells it what stack to use; the skill respects locked choices and decides flexible ones.

## When to use it

Use it for:

- A new software project, greenfield
- A major rewrite where you want to start from the brief, not the old code
- Any project where you've thought enough about what you want that a brief captures it, and you'd rather not be in the loop for every micro-decision

Do *not* use it for:

- Bug fixes or small changes to a finished project
- Work you want to pair-program through, decision by decision
- Pitch decks, GTM plans, research reports — use the `brief-to-X` sibling that fits
- Plan-only work where you don't want execution

## Quick start

1. Drop a `brief.md` in your repo root (or paste your brief into the Claude Code session).
2. Tell Claude Code: *"Use brief-to-prod on this."*
3. Answer the Stage A soft-confirm questions.
4. When prompted, install any Stage 1 skills shown in `SKILLS-TO-INSTALL.md`, resolve preemptive blockers in `NOTES-TO-ADMIN.md`, then run `/clear` and type `continue`.
5. Sit back. The skill executes phase by phase. Check `LOG.md` for progress; check `NOTES-TO-ADMIN.md` if it needs you.

## What a good brief looks like

A great brief is concise — a few hundred to a couple thousand words. It says, in any form: what is being built, why, who it's for, what the MVP must do, and any locked technology / constraint decisions you've already made.

Short, informal briefs are fine. The skill asks follow-up questions during Stage A to fill genuine gaps. See `references/brief-anatomy.md` (inside the skill) for what helps and what doesn't.

## What gets generated

Co-located with your brief (same folder — so root if the brief is at root, `BRIEF/` if it's in `BRIEF/`):

| File | What it holds |
|---|---|
| `VISION.md` | The why — purpose, audience, success criteria |
| `PRODUCT-SPEC.md` | The what — features, scope, MVP boundaries |
| `TECHNICAL-DECISIONS.md` | The how — stack, architecture, locked vs flexible decisions |

At repo root (for resume discoverability):

| File | What it holds |
|---|---|
| `CLAUDE.md` | Entry point for every future session — orients new sessions on the project |
| `PLAN.md` | Phases, checklists, definition of done per phase, completion log |
| `LOG.md` | Append-only narrative; last entry is the resume point |
| `NOTES-TO-ADMIN.md` | BLOCKER / IMPORTANT / FYI entries for you |
| `SKILLS-TO-INSTALL.md` | Stage 1 / 2 / 3 skill recommendations + install commands |

## Structure

```
brief-to-prod/
├── SKILL.md          # The dispatcher — read first
├── README.md         # This file
├── references/       # On-demand depth (read as needed)
├── rules/            # Lookup tables (trust list, decision vocabulary)
├── templates/        # Artifact skeletons with {{PLACEHOLDER}} syntax
└── scripts/          # Deterministic helpers (validate-brief.sh)
```

Curious about the design? Start with `SKILL.md`. The reference files explain the workflow in depth.

## Compatibility

- Built for Claude Code, but skill content is agent-neutral
- Works with or without [`find-skills`](https://skills.sh/) — falls back to direct API calls
- Technology-agnostic — no assumed stack, framework, or language

## License

MIT.
