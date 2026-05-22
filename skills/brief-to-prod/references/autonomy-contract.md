# The autonomy contract — 12 rules in full

These 12 rules govern every decision the skill makes while running. They are the difference between *autonomous and trustworthy* and *autonomous and reckless*. SKILL.md lists their titles; this file is the depth.

When you find yourself debating a judgment call, read the relevant rule. When two rules seem to conflict, the lower-numbered rule wins.

---

## 1. Brief is the contract

**Rule.** What the brief specifies is what gets built. If the brief is silent on something, the skill decides. If the brief locked something, the skill respects it.

**Why this matters.** The brief is the only durable record of what the user wants. Without this rule the skill drifts toward whatever-feels-right and the user ends up with software they didn't ask for.

**How to apply.**
- Before any phase, re-skim the relevant sections of the brief and `PRODUCT-SPEC.md`.
- If the brief is silent on a detail (file structure, library choice within the locked stack, function naming), decide and document briefly in `LOG.md` and never ask.
- If the brief locked a choice and you believe it must change, raise an IMPORTANT note in `NOTES-TO-ADMIN.md` and pause the dependent work. Do not silently deviate.

## 2. Stage A soft confirm asks selectable questions only

**Rule.** During the one structured interaction in the skill's lifecycle, every question is a focused, selectable-option question. No essay-length confirmation prompts. No "is everything OK?" walls of text.

**Why this matters.** Users tolerate one well-bounded confirmation. They do not tolerate a 2000-word brief asking them to re-read everything and bless the whole foundation. Selectable questions are faster, more accurate, and respect the user's time.

**How to apply.**
- Use `AskUserQuestion` (Claude Code) or the platform equivalent. One question per round, 2–4 options, options are mutually exclusive.
- Phrase questions concretely: "I interpreted the project as a [type]. Is this correct?" with options `[yes / actually it's X / explain more]`.
- Ask only the questions worth asking. If the brief was unambiguous on a point, decide without confirming.
- See `stage-a-protocol.md` for the full question catalog.

## 3. Stage B is fully autonomous

**Rule.** After Stage A's confirmation, there are no "should I move to Phase N?" or "ready to deploy?" prompts. The plan is the authority. Continue until done, blocked, or out of context.

**Why this matters.** The skill's value proposition is autonomy. A skill that pauses every phase is just `brainstorming` + `executing-plans` with extra ceremony. If you want checkpoints, use those cousin skills.

**How to apply.**
- Never end a session with "should I continue?" Either the work is genuinely blocked (write a BLOCKER and continue with non-dependent work) or it is not (continue silently).
- Phase completion → write `LOG.md` entry → append to `PLAN.md`'s completion log → start next phase. No user prompt in between.
- If you find yourself drafting a "ready to proceed?" message, that's a red flag. Either write the BLOCKER or just proceed.

**Native reinforcement.** Claude Code's `/goal` command is the platform-level form of this rule. At the end of Stage A, the skill sets a goal naming the PLAN.md completion as the condition. If `/goal` is available, use it; if not, the contract in this file binds equally well. See `native-claude-code-commands.md` for the command details.

## 4. `LOG.md`'s last entry is the resume point

**Rule.** Every new session reads `CLAUDE.md` first, then `LOG.md`'s last entry to find where to pick up. Nothing else carries session state.

**Why this matters.** Multiple state files (SESSION-HANDOFF.md, START-NEXT-SESSION.md, etc.) drift out of sync and confuse new sessions. One source of truth is reliable.

**How to apply.**
- Update `LOG.md` at start of work, at significant decisions, at end of work, and before any context-exhaustion handoff.
- Keep each entry self-sufficient: "what just happened, what's next, what's in flight."
- Never invent a second handoff file. If you need more space, write a longer LOG entry.
- See `log-protocol.md` for entry format.

## 5. `NOTES-TO-ADMIN.md` is for the genuinely critical

**Rule.** Three severities — BLOCKER, IMPORTANT, FYI. Most decisions never reach this file. If everything is in there, the user reads none of it.

**Why this matters.** The user's attention is the scarcest resource in the system. Spamming the admin file dilutes the signal of genuine blockers and the user starts ignoring it.

**How to apply.**
- BLOCKER: cannot proceed on the dependent work without admin input. Always pair with a paused phase or task flag in `PLAN.md`.
- IMPORTANT: can proceed, but the admin should weigh in soon. A locked-decision deviation is IMPORTANT.
- FYI: informational only. Use sparingly.
- See `notes-to-admin-guide.md` for examples and the entry format.

## 6. Locked constraints in `TECHNICAL-DECISIONS.md` are not up for revision

**Rule.** During execution, you do not silently replace locked technology, architecture, or vendor choices. If you believe a locked constraint must change, raise IMPORTANT and pause the dependent work.

**Why this matters.** Locked constraints encode user intent that the brief already affirmed. Changing them silently is a betrayal of the contract. Even when the change "would be better," it isn't your call.

**How to apply.**
- Mark every decision in `TECHNICAL-DECISIONS.md` as `LOCKED` or `FLEXIBLE` (see `rules/locked-vs-flexible-decisions.md`).
- Flexible decisions can be revised mid-execution with a `LOG.md` note.
- Locked decisions trigger Rule 5 (IMPORTANT in `NOTES-TO-ADMIN.md`) and Rule 10 (no silent skipping) when they need to change.

## 7. Test as you go

**Rule.** Every phase ends with verification of what was built. No "tests deferred to a later phase."

**Why this matters.** Untested phases compound. By Phase 5 the system has five untested layers and the first regression takes a day to find. Per-phase verification is cheap; bulk verification at the end is brutal.

**How to apply.**
- Each phase's definition of done includes the verification command and the expected passing state.
- Run the verification command before declaring the phase done. Do not claim "should pass" — run it and read the output. (This is `verification-before-completion`'s "Iron Law" applied per phase.)
- If verification fails, that's the work — fix it before moving on.

## 8. Skill stage transition gate

**Rule.** Before any phase that depends on Stage 2 or Stage 3 skills (per `SKILLS-TO-INSTALL.md`), if those skills are not yet confirmed installed, write a BLOCKER and pause that phase. Non-dependent prep continues.

**Why this matters.** Phases that quietly proceed without their required skills produce subpar output that's hard to retroactively fix. Better to pause and surface.

**How to apply.**
- For each phase, list its skill dependencies in `PLAN.md`.
- At phase start, check whether the required skills are installed. Use the platform's skill list, not memory.
- If missing → BLOCKER + paused phase + a clear note in `PLAN.md` near the phase.

## 9. Cost-aware development

**Rule.** Use cached fixtures and stubs during testing. Real API integration is verified once per phase, not on every commit.

**Why this matters.** Calling a paid API on every test iteration burns money and slows the loop. Stubs make tests fast, deterministic, and free.

**How to apply.**
- Build the stub/fixture path as part of the first phase that integrates an external service.
- Run the real-API verification once at phase end, capturing the response shape in a fixture for future tests.
- If a stub diverges from real behavior, that's a bug — fix the stub and re-run the real check.

## 10. No silent skipping

**Rule.** A blocked task gets a `NOTES-TO-ADMIN.md` entry AND a flag in `PLAN.md`. Never silently skip.

**Why this matters.** Silent skips become hidden gaps in the deliverable. The user discovers them in production, not during development.

**How to apply.**
- Skip = a clearly marked deferral with the reason and the unblock condition.
- The `PLAN.md` task gets `[SKIPPED — see NOTES-TO-ADMIN.md entry YYYY-MM-DD]` instead of `[x]`.
- When unblocked, the task is un-skipped and worked normally.

## 11. Commit hygiene

**Rule.** Commit at meaningful milestones with messages tied to phase + task. Never commit secrets.

**Why this matters.** A clean commit history is the second-most-useful resume aid after `LOG.md`. Secrets in history are a permanent leak even after rotation.

**How to apply.**
- Commit message format: `{phase-tag}: {task summary}` — e.g. `phase-2: scaffold auth middleware with stub`.
- Before any `git add`, scan for files that may hold secrets (`.env`, `*credentials*`, etc.). If unsure, ask via NOTES-TO-ADMIN.
- Never use `--no-verify` to bypass hooks unless the user explicitly told you to.

## 12. Logs are diffs, not novels

**Rule.** `LOG.md` entries are concise — a paragraph or short bullet list per work block. Narrative belongs in `NOTES-TO-ADMIN.md`.

**Why this matters.** A 50-page LOG is unreadable. The point of the log is fast resume orientation, not project history. Long entries hide the resume signal.

**How to apply.**
- Each entry: 5–15 lines. Headline + 3–5 bullet points + "next concrete task" line.
- If you find yourself writing a story, pause and ask: is this a status note (LOG) or a decision the admin needs to weigh in on (NOTES-TO-ADMIN)?
- See `log-protocol.md` for the canonical format.

---

## Rationalization prevention

These thoughts mean you are about to break the contract:

| Thought | Reality |
|---|---|
| "Just this one phase needs a check-in" | Rule 3. The plan is the authority. |
| "The locked stack would be simpler with X instead" | Rule 6. Raise IMPORTANT, don't silently swap. |
| "I'll write the test later, the phase is done enough" | Rule 7. Phase is not done. |
| "This blocker isn't really blocking, I can work around" | Rule 10. Write the note AND work around. Both. |
| "The log will be more useful with more context" | Rule 12. Brevity is the point. Move depth to NOTES-TO-ADMIN. |
| "The user said use FastAPI but Express is faster here" | Rule 1, Rule 6. Use FastAPI. |
| "I'll just ask the user one quick question before continuing" | Rule 3. Stage B has no quick questions. NOTES-TO-ADMIN or proceed. |

---

## Worked examples

**Example A — locked stack, better alternative discovered.**

The brief locked Postgres. Phase 4 begins; you realize the analytics queries would be 10× faster on ClickHouse for this workload.

Wrong response: silently swap.
Right response: append an IMPORTANT entry to `NOTES-TO-ADMIN.md`:

> ## 2026-05-22 — IMPORTANT
>
> **Issue:** Phase 4 analytics queries fit ClickHouse's columnar model much better than Postgres. Estimated 10× perf on the dashboard. `TECHNICAL-DECISIONS.md` locks Postgres.
>
> **What I need from you:** Should I (a) keep Postgres and accept the perf cost, (b) switch to ClickHouse, or (c) propose a hybrid where Postgres stays for transactional state and ClickHouse handles analytics? I've paused Phase 4 pending direction. Phase 5 prep is non-dependent and continues.

Pause Phase 4. Flag in `PLAN.md`. Continue with Phase 5 prep.

**Example B — phase complete, plan says deploy next.**

Phase 6 (last) is done. Phase 7 in the plan is "deploy to production." Wrong response: ask "ready to deploy?" Right response: just deploy. The plan says so. If deployment requires an API key you don't have, that's a BLOCKER — write it and pause Phase 7, not a question.

**Example C — context exhaustion mid-edit.**

You're 92% through context and in the middle of writing a 400-line file. Wrong response: keep going. Right response: finish only the function you're currently inside, save the file (so it compiles), commit if a meaningful unit is done, then run the Stage C handoff. Better a slightly-incomplete-but-coherent state than a syntactically broken file.

---

See also: `notes-to-admin-guide.md`, `log-protocol.md`, `context-exhaustion-protocol.md`.
