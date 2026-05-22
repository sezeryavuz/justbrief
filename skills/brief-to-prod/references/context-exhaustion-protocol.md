# Context exhaustion protocol

Long autonomous runs eventually hit context limits. The handoff between sessions is the most fragile point in the skill's lifecycle — done well, the next session resumes in seconds; done poorly, the next session re-derives everything.

This is Stage C.

---

## Detection

Trigger Stage C when **any** of these are true:

- `/context` (Claude Code native command — see `native-claude-code-commands.md`) reports utilization at or above ~85–90%
- The harness is summarizing prior turns more aggressively than usual
- You feel yourself losing track of details from earlier in the session (your own internal signal — trust it)
- You are about to start a substantial new task that would push you over

Prefer triggering early at a safe stopping point over triggering late mid-edit. A clean handoff at 80% is better than a panicked handoff at 96%.

### How often to check `/context`

Not after every tool call — that's noise. The right cadence is:

- **At task boundaries** within a phase (between Task 2 and Task 3, for example).
- **Before starting a substantial new task** that would burn a meaningful chunk of context.
- **At phase boundaries** — natural break points. If `/context` shows >80% at a boundary, hand off proactively rather than starting a phase you can't finish.

If `/context` is unavailable, fall back to the internal signals listed above.

## Find a safe stopping point

A safe stopping point has these properties:

- The codebase is in a coherent state (no half-written files, no unrunnable build)
- Any in-flight test pass has finished
- A meaningful unit of work is done (a task complete, or at least a function complete)
- If you have uncommitted work in a clean state, commit it

If you are mid-edit:

- Finish the **smallest enclosing coherent unit** (the function, the test case, the import block) so the file compiles/parses.
- Save and commit if it represents a complete-enough increment.
- If the unit can't be finished safely, revert the in-flight changes (`git checkout -- file`) and note in the LOG entry what you were attempting so the next session can retry.

Never end mid-statement, mid-keyword, mid-config-block. Better to roll back than hand off a broken state.

## Write the handoff `LOG.md` entry

This is the highest-leverage write in Stage C. It must contain everything the next session needs.

Required content:

- Headline that summarizes what stage of what phase you stopped at
- Bullets: what's done, what's in-flight, what was learned this session
- **Next concrete task** line — exact, copy-paste-runnable level of specificity
- **In-flight state** — files mid-edit (and what state they're in), tests partially failing (and which), commands that were in progress
- **Open questions** — anything you would have asked yourself if you had context budget left

### Example

```markdown
## 2026-05-22 16:42 — Phase 3 mid-execution; context handoff

- Phase 3 task 1 (dashboard route shell) complete and committed (a8c2d10).
- Phase 3 task 2 (data fetching hook) ~60% — useDashboardData.ts has the fetch + type but is missing error handling. Test stubs in tests/useDashboardData.test.tsx written, not yet passing.
- Decided to use TanStack Query (was FLEXIBLE) over a hand-rolled fetcher — updated TECHNICAL-DECISIONS.md.

**Next concrete task:** Finish error handling in src/hooks/useDashboardData.ts:42-end, then run `npm test useDashboardData` and iterate to green. Then commit and move to Phase 3 task 3.

**In-flight state:** useDashboardData.ts is at 85% functional but lacks the error-state UI fallback. Test file imports the hook but tests fail at the "renders error state" assertion. Branch is `phase-3-dashboard`, no uncommitted changes (latest WIP was committed for safety).

**Open questions:** None — direction is clear.
```

### What separates great from adequate

The "Next concrete task" line should be at the granularity of "open this file, do this thing, run this command." The next session reads it as an instruction, not a description.

## Tell the user — verbatim

After writing the LOG entry, choose between `/compact` and `/clear` based on where in the work cycle you are:

```
Mid-phase (in-flight task, partial edits, half-passing tests) → recommend /compact
Phase boundary (last entry was "Phase N complete")              → recommend /clear
```

The reasoning: `/compact` preserves a summary of in-flight state that LOG.md can't fully capture in bullet form. At a phase boundary, LOG.md already carries everything; a fresh context window is cleaner.

Tell the user verbatim, picking ONE of the two:

> Mid-phase: *"Context is near full. Run `/compact` (preserves in-flight summary) and type `continue`. I will resume from the last `LOG.md` entry."*
>
> Phase boundary: *"Context is near full. Run `/clear` and type `continue`. I will resume from the last `LOG.md` entry."*

Use these words. Brief, predictable, repeatable. Don't soften, don't elaborate.

## Stop

Do not start new work after writing the handoff. The handoff is the last thing in the session.

If the user replies with anything except `/clear` + `continue`, treat the new instruction as a new session intent and respond accordingly. Don't keep working in this session out of habit.

---

## What the next session does

The next session, on startup:

1. Reads `CLAUDE.md` (orientation)
2. Reads `LOG.md`'s last entry (the handoff you just wrote)
3. Executes the `Next concrete task` line

If the handoff is good, step 3 takes seconds to start. If the handoff is bad, the next session re-derives state from `PLAN.md` and `git log`, which is slow and error-prone.

## Anti-patterns

- **Stopping mid-statement.** Always finish at least to a parseable boundary.
- **Writing a poetic handoff.** This is not the time for narrative. Bullets, specifics, the next task.
- **Spawning extra handoff files.** No SESSION-HANDOFF.md, no START-NEXT-SESSION.md. The LOG entry is the handoff.
- **Asking the user "should I continue or stop here?"** You decide. Either the next task fits in remaining context or it doesn't.
- **Continuing past 95% "to finish just one more thing."** Hard no — context overruns truncate your own handoff entry and the next session reads garbage.

## Edge case — context exhaustion before Stage A is done

If Stage A itself runs out of context (very large brief, complex foundation), don't try to compress Stage A into a handoff. Instead:

- Write everything generated so far to disk
- Add an IMPORTANT entry to `NOTES-TO-ADMIN.md` saying "Stage A partially complete; the next session must finish steps N–9 before starting Stage B"
- Run the verbatim user message
- Stop

Stage A is short enough that this is rare. If it happens twice on the same project, the brief is probably too large and should be split into multiple sub-projects.
