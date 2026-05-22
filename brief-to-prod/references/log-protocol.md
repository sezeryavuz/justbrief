# LOG.md protocol

`LOG.md` is the resume point for every future session. It is **the only state file** that carries work-in-progress context between sessions. Get this right and resume is seamless. Get it wrong and the next session re-derives everything from scratch.

This file defines the format, when to write entries, and the rule that distinguishes a LOG entry from a NOTES-TO-ADMIN entry.

---

## Entry format

Every entry follows this shape:

```markdown
## YYYY-MM-DD HH:MM — [headline]

- Bullet of what just happened
- Bullet of significant decisions made
- Bullet of state currently in-flight (files mid-edit, tests partially passing, etc.)

**Next concrete task:** [exact task name from PLAN.md, e.g. "Phase 3, Task 2 — write retry logic for stripe webhook handler"]

[Optional: 1–2 lines of free-form context that won't fit the bullets]
```

**Concrete rules:**

- Timestamp resolution: minute precision when relevant, day-only when not. Always include the date.
- Headline: a verb phrase summarizing the work block. "Wired up auth middleware," "Refactored test fixtures," "Hit blocker on Stripe."
- Bullets: 3–7 per entry. Past tense for done items, present tense for in-flight.
- **The `Next concrete task` line is mandatory.** It's the first thing the next session reads.
- Entries are append-only. Never edit a prior entry; write a new one.

## When to write entries

Four trigger points:

1. **Start of work.** When picking up after `/clear`, write a brief "resuming from prior entry" line. Optional but useful for traceability.
2. **Significant decision.** Any decision the next session would benefit from knowing: chose library X over Y, restructured directory, deferred a sub-task to next phase, etc.
3. **End of work.** Always. Either you're stopping voluntarily (handing off cleanly) or hitting context exhaustion (see `context-exhaustion-protocol.md`).
4. **Phase completion.** A dedicated entry — "Phase N complete" — with the verification command output captured in the bullets and the next phase named in `Next concrete task`.

Do **not** write an entry per file edit. That's noise.

## Example — good entry

```markdown
## 2026-05-22 14:30 — Phase 2 complete; auth scaffolded

- Implemented JWT-based auth per TECHNICAL-DECISIONS.md (LOCKED: jose, locked at v5).
- All 12 auth tests pass: `npm test -- auth/` → 12/12 OK.
- Verified login flow end-to-end against staging supabase project.
- Committed at f3a4b21.
- Appended to PLAN.md Phase Completion Log.

**Next concrete task:** Phase 3, Task 1 — scaffold the dashboard route shell (`/dashboard/page.tsx`).
```

A future session reads this and knows: where we are, what tests prove it, what's next, what tools to use.

## Example — bad entry

```markdown
## 2026-05-22 — work today

Did a bunch of things on auth. Should be mostly working. Need to keep going on the dashboard eventually. There were some weird issues with the JWT library — might come back to that.
```

Why bad: no timestamp resolution, no specific accomplishments, vague status ("mostly working"), no verification claim, no next concrete task, free-floating worry ("might come back to that") that belongs in `NOTES-TO-ADMIN.md` if it matters.

## LOG.md vs NOTES-TO-ADMIN.md

This is the most-confused distinction in the skill. Use this test:

- **LOG.md** answers "what just happened and what's next." It's a status record for future sessions of *the skill*.
- **NOTES-TO-ADMIN.md** answers "what does the human need to know or decide." It's an inbox for the *user*.

A locked-decision deviation goes in NOTES-TO-ADMIN.md (the human needs to weigh in) and the affected work gets a one-line LOG entry pointing to it ("Phase 4 paused — see NOTES-TO-ADMIN 2026-05-22").

A library swap within a flexible decision is a LOG entry only.

A passing test suite is a LOG entry only.

A failed API integration that you worked around is a LOG entry IF you fully resolved it. If the workaround is a hack the user should know about, it's an FYI in NOTES-TO-ADMIN.md AND a LOG entry.

When in doubt, ask: "does the user need to act on this?" If yes → NOTES-TO-ADMIN. If no → LOG.

## File header

`LOG.md` opens with this header (created by Stage A):

```markdown
# LOG.md — [project name]

Resume mechanic: every new session reads CLAUDE.md, then the last entry of this file. Entries are append-only. Format: see brief-to-prod's references/log-protocol.md.

---
```

Then entries follow, newest at the bottom.

## On reading LOG.md at session start

The protocol is **"read the last entry."** Not the last 5 entries. Not the whole file. Just the most recent entry.

Why: each entry is self-sufficient (the `Next concrete task` line is mandatory). Reading further is a waste of context budget unless you specifically need to research how something earlier was done — in which case the file is searchable and `git log` is more authoritative anyway.

## When to refactor LOG.md

Never. Append-only.

If the file gets enormous (after months of work) and you want a summary, write a fresh `LOG-archive-YYYY.md` containing the old entries and start `LOG.md` over with a single "archived prior entries to LOG-archive-YYYY.md" entry. This is a v0.2+ concern.

## What the next session sees

`CLAUDE.md` instructs the next session to read `LOG.md`'s last entry on startup. That entry's `Next concrete task` line tells them what to do. From there they pick up.

If `LOG.md` is empty (immediately after Stage A), the next session reads `PLAN.md`'s Phase 1 and starts there.
