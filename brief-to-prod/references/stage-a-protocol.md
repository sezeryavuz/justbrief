# Stage A protocol — Foundation

Stage A runs once per project, in one session. Its job is to convert the brief into the foundation the rest of the work runs on: VISION, PRODUCT-SPEC, TECHNICAL-DECISIONS, PLAN, CLAUDE.md, LOG.md, NOTES-TO-ADMIN.md, SKILLS-TO-INSTALL.md.

This file expands SKILL.md's 9-step Stage A list with the protocol detail.

---

## Pre-flight

Before starting Stage A, confirm:

1. The user has not already started a brief-to-prod project in this repo. (Check for an existing `CLAUDE.md` that names brief-to-prod — if present, you're in Stage B, not Stage A.)
2. You have either a brief file path or a usable session-prompt brief.
3. You can write to the repo root and (if needed) create a `BRIEF/` folder.

If any of these is unclear, ask one focused question to resolve it — but don't open the soft-confirm round yet; the foundation isn't built yet.

---

## Step 1 — Read the brief

The brief arrives in one of two forms:

- **File.** Look for `./brief.md`, `BRIEF/brief.md`, or any path the user named. Read in full.
- **Session prompt.** The user pasted the brief into the session. Save it as `./brief.md` before doing anything else. Sessions are ephemeral; the brief is the contract; it must be durable.

Treat the brief as authoritative. Note where it is silent — those are the gaps you'll resolve in steps 4–6 by deciding or surfacing.

## Step 2 — Validate the brief

Run `scripts/validate-brief.sh` if you have shell access, or apply the equivalent inline check from `brief-anatomy.md`. The check looks for:

- A description of what's being built
- The target audience or use case
- MVP scope or feature list
- Any locked technical / vendor / constraint choices
- Anything that locks you out of standard defaults (e.g. compliance requirements, latency budgets)

A failing validation is not a blocker — it just tells you what to surface in the soft confirm. Note gaps in `.workspace/`-style scratch (or a TODO list) for later.

## Step 3 — Discover skills

Extract the project's domains from the brief (frontend framework, backend language, database, deployment target, payment, auth, analytics, etc.). For each domain, look for installable skills.

See `skill-discovery-process.md` for the full discovery, trust-filter, and audit-filter logic. The output is `SKILLS-TO-INSTALL.md` at repo root, with skills grouped into Stage 1 / 2 / 3 per `stage-mapping-heuristics.md`, each with a copy-pasteable install command.

## Step 4 — Generate the foundation artifacts

In the same folder as the brief (root, or `BRIEF/`), generate from `templates/`:

- `VISION.md` — purpose, audience, success criteria, non-goals
- `PRODUCT-SPEC.md` — features, MVP scope, user flows, out-of-scope explicit list
- `TECHNICAL-DECISIONS.md` — stack, architecture, vendors, with every decision flagged `LOCKED` or `FLEXIBLE`

Use `rules/locked-vs-flexible-decisions.md` to read the brief's constraint vocabulary correctly. If the brief says "must use Postgres" → `LOCKED`. If it says "probably Postgres" → `FLEXIBLE` with Postgres as the proposal.

## Step 5 — Generate `PLAN.md`

At repo root. See `phase-design-guide.md` for sizing, definition-of-done patterns, per-phase test discipline. PLAN.md template includes:

- Goal sentence
- Architecture sentences
- Tech stack summary
- Phase list, each with: name, goal, tasks (bite-sized), definition of done, skill dependencies, complexity sizing
- Empty Phase Completion Log section (Stage B appends to it)

## Step 6 — Generate the meta files

At repo root:

- `CLAUDE.md` — orient any future session in seconds. Names the project, points at PLAN.md, points at LOG.md as the resume point, lists the locked stack at a glance.
- `LOG.md` — empty header only. Stage B will fill it.
- `NOTES-TO-ADMIN.md` — empty header with the severity legend and the entry format example.

## Step 7 — Self-review

Re-read what you generated, with fresh eyes. Check:

1. **Placeholder scan.** Any `{{PLACEHOLDER}}`, `TBD`, `TODO`, or vague requirement that slipped through? Fix it.
2. **Internal consistency.** Does VISION's success criteria match PRODUCT-SPEC's MVP? Does TECHNICAL-DECISIONS's stack match PLAN's tasks?
3. **Brief coverage.** For each MVP item in the brief, can you point to a phase in PLAN.md that delivers it? List gaps.
4. **Scope check.** If PLAN.md has more than ~10 phases, the project may be too large for one brief-to-prod pass. Note as an IMPORTANT to discuss in the soft confirm.
5. **Locked-decision audit.** Every `LOCKED` decision in TECHNICAL-DECISIONS.md should trace to a brief statement. If you locked something the brief didn't, downgrade to `FLEXIBLE`.

Fix issues inline. Don't loop — fix and move on. If you discover something the soft confirm should address, add it to your question list for Step 8.

## Step 8 — Soft confirm

The only structured interaction in the skill's lifecycle. Use `AskUserQuestion` (Claude Code) or the platform equivalent. One question per round, 2–4 options, options mutually exclusive.

**Discipline:** ask only the questions worth asking. If the brief unambiguously specified something, don't ask about it. If you can decide with confidence, decide.

### Question catalog (sample — adapt to the brief)

These are reference shapes. Drop, add, or rephrase per the brief's specifics.

**Project type / interpretation**
- "I interpreted this project as a [SaaS web app / mobile app / internal tool / CLI / API service]. Is this correct?"
  - Options: `yes` · `actually it's [other type]` · `explain more`

**Stack confirmation (only if some decisions were FLEXIBLE)**
- "For [domain], I proposed [choice] based on the brief. Keep this?"
  - Options: `keep` · `suggest alternative` · `let me decide`

**Phase shape**
- "I see [N] phases spanning an estimated [size]. Want me to merge or split any?"
  - Options: `proceed` · `merge phases X and Y` · `split phase Z` · `pause and discuss`

**External dependencies**
- "I detected dependencies on [list of services]. Do you have accounts / API keys ready for these?"
  - Options: `all ready` · `none ready` · `some — I'll mark in NOTES-TO-ADMIN` · `let me list`

**Out-of-scope gut check (if PRODUCT-SPEC.md explicitly excludes something noteworthy)**
- "Confirming the V1 explicitly excludes [thing]. Is that right?"
  - Options: `yes — exclude` · `include in V1` · `defer to V2 explicitly`

**Skill installation readiness**
- "SKILLS-TO-INSTALL.md lists [N] Stage 1 skills. You'll install these before Stage B. OK?"
  - Options: `OK, I'll install` · `show me the list first` · `skip — I'll work without`

### What NOT to ask

- File and folder names (decide them)
- Library micro-choices within a locked stack (decide them)
- Test framework choice within a locked language ecosystem (use the conventional default)
- Subtask ordering inside a phase (you decide)
- Code style (use the conventional default)
- Anything covered by a reasonable default

## Step 9 — Hand off

After the soft confirm, tell the user verbatim:

> *"Stage A is complete. Foundation artifacts and PLAN.md are in place. Before Stage B:*
>
> *1. Install the Stage 1 skills listed in `SKILLS-TO-INSTALL.md`.*
> *2. Resolve any preemptive blockers in `NOTES-TO-ADMIN.md` (severity BLOCKER).*
> *3. When ready, run `/clear` (or `/compact`) and type `continue`. I'll pick up Stage B from `LOG.md`'s last entry."*

Write the corresponding LOG.md first entry:

```markdown
## YYYY-MM-DD — Stage A complete

- Generated VISION.md, PRODUCT-SPEC.md, TECHNICAL-DECISIONS.md, PLAN.md, CLAUDE.md, NOTES-TO-ADMIN.md, SKILLS-TO-INSTALL.md.
- Soft confirm completed with N adjustments: [brief summary].
- Stage B starts at Phase 1, Task 1.
- Awaiting user to install Stage 1 skills and resolve any preemptive blockers.

**Next concrete task:** Phase 1, Task 1 — [task name from PLAN.md].
```

Stop. Stage A ends here.

---

## What happens if the user adjusts during the soft confirm

If their answers change the foundation (e.g. "actually use Next.js, not Remix"), update the affected artifacts immediately, re-run Step 7 self-review on the changes, then proceed to Step 9. Don't loop back to Step 4 unless the change is substantial (e.g. swapping the project type changes everything downstream).

If their answers require new Stage 1 skills, regenerate `SKILLS-TO-INSTALL.md` before Step 9.

## Anti-patterns

- **Asking the user to "review the docs" before continuing.** That's the kind of vague confirmation the brief explicitly bans. Ask focused selectable questions or don't ask.
- **Skipping the soft confirm because "the brief was clear."** Always do at least the project-type confirmation. It's one question and catches misreads.
- **Spawning extra meta files.** Stage A creates the eight artifacts named above. No SESSION-HANDOFF.md, no DECISIONS-LOG.md, no PROJECT-OVERVIEW.md. `CLAUDE.md` plus the seven others is the spec.
