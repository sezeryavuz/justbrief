# Stage mapping heuristics — Stage 1 vs 2 vs 3

When `SKILLS-TO-INSTALL.md` groups discovered skills, it puts each in Stage 1, 2, or 3 by when in the project's lifecycle they're needed. This file is the decision rubric.

---

## Stage 1 — Foundation skills

**Definition:** Required *before* Stage B starts. These shape the scaffold, conventions, and patterns the rest of the project sits on top of. Switching them mid-build is expensive.

**Criteria:**

- The skill establishes conventions used everywhere (e.g. a framework-best-practices skill, a design-system pattern skill)
- The skill teaches scaffolding decisions made in Phase 1
- The skill's value is highest at project start and lowest later
- Without this skill, all phases would produce subtly worse output

**Examples:**

- `vercel-labs/react-best-practices` for a Next.js project
- `anthropics/frontend-design` for a project with a UI focus
- TDD or testing-discipline skills if the project values rigorous testing
- A skill that teaches the project's chosen monorepo tool

**User experience:** Stage A's handoff prompt tells the user explicitly to install all Stage 1 skills before running `/clear` + `continue`.

## Stage 2 — Phase-specific skills

**Definition:** Required for one or two specific phases, not before. These are domain skills that show up only when the relevant work begins.

**Criteria:**

- The skill addresses a specific domain that doesn't appear until Phase N
- Phase N+1 onward doesn't materially use the skill
- It's safe (and conserves user effort) to defer install until just before Phase N

**Examples:**

- A payments skill (Stripe, Lemon Squeezy) — needed only when payment integration starts
- A specific DB skill — needed only when DB schema design starts
- A deployment-target skill — needed at deploy phase
- An email-provider skill — needed when transactional emails start

**User experience:** `SKILLS-TO-INSTALL.md` annotates each Stage 2 skill with `Needed by: Phase N`. Stage B checks installation just before starting the phase. If missing, writes a BLOCKER (per autonomy rule 8) and continues with non-dependent work.

## Stage 3 — Optional / nice-to-have skills

**Definition:** The project ships fine without them. They improve specific outputs or speed up specific tasks but aren't essential.

**Criteria:**

- The skill improves quality of an output that would otherwise be merely "good"
- The skill addresses a domain the brief mentions in passing but doesn't make a core requirement
- The skill speeds up a task that's doable without it

**Examples:**

- An ad-creative skill for a SaaS that mentions "we'll need landing-page copy eventually"
- An advanced perf-optimization skill for a project where baseline perf is fine
- A polyglot doc-translation skill for an English-first product

**User experience:** Listed in `SKILLS-TO-INSTALL.md` with the reason ("would improve X output"). Stage B doesn't require them; it logs an FYI if a phase would have benefited from a Stage 3 skill that wasn't installed.

---

## How to decide when ambiguous

If a skill could plausibly be Stage 1 or Stage 2, ask:

> "Does Phase 1 produce different code if this skill is or isn't installed?"

- Yes → Stage 1
- No → Stage 2

If a skill could be Stage 2 or Stage 3, ask:

> "Will the phase that needs this skill be pauseable if it's missing?"

- "Yes, that phase pauses and waits for install" → Stage 2 (rule 8 applies)
- "No, the phase proceeds without it and the output is just slightly worse" → Stage 3

## Calibration — don't over-promote to Stage 1

Stage 1 is the user's friction. Every Stage 1 skill is an install they have to do before they can run `/clear + continue`. Promoting a Stage 2 skill to Stage 1 because "it might be useful early" adds friction without benefit.

Default to Stage 2 when in doubt. Promote to Stage 1 only when the skill is clearly foundational.

## Calibration — don't under-promote to Stage 3

Conversely, Stage 3 is essentially "I noticed this skill exists." If a phase would meaningfully benefit, that's Stage 2. Stage 3 is reserved for genuinely optional polish.

If every skill ends up in Stage 3, you probably did the discovery but failed the mapping. Re-examine.

## When the project shifts mid-execution

If the user adds a new feature in Stage B (via a `NOTES-TO-ADMIN.md` resolution that asks for it, for example), and the feature needs a new skill:

- If the feature's phase has already started → the new skill is Stage 1 *for the addition* — note the BLOCKER, get the user to install, then resume
- If the feature's phase is upcoming → the new skill is Stage 2; annotate the phase

## Examples table

| Project type | Likely Stage 1 | Likely Stage 2 | Likely Stage 3 |
|---|---|---|---|
| Next.js SaaS with Stripe and Postgres | react-best-practices, frontend-design | stripe-patterns, postgres-patterns, supabase-auth | landing-page-copywriting |
| CLI tool in Rust | rust-cli-patterns, TDD | (probably none) | release-engineering |
| Python data pipeline | python-best-practices, TDD | duckdb-patterns, airflow-patterns | data-viz-patterns |
| Static blog with MDX | frontend-design | seo-audit | ai-seo |

These are illustrative — actual mappings depend on what skills exist at discovery time and what the brief locks.
