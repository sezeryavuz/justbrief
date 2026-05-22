# Phase design guide

`PLAN.md` is the spine of Stage B. Every phase you put in it is a contract: "this phase will deliver X, verified by Y, before phase N+1 starts." Get phase design right and Stage B runs cleanly; get it wrong and resumes are confused and definitions of done are debatable.

This file covers sizing, structure, definition of done, dependencies, and the per-phase test discipline.

---

## What is a phase

A phase is a grouping of related tasks that together produce a self-contained, verifiable increment of the project. Think of it as the smallest unit of work that, if you stopped right after, would leave the project in a coherent state.

Examples of well-shaped phases:

- "Phase 1 — Repo scaffolding: framework installed, CI green, hello-world deployed"
- "Phase 2 — Auth: users can sign up, log in, and log out; session persists; tests pass"
- "Phase 3 — Dashboard skeleton: routes exist, layout renders, no real data yet"
- "Phase 4 — Dashboard data: dashboard pulls and displays the four core metrics"

Anti-shape:

- "Phase 1 — Set up the project" (vague — what does "set up" mean done?)
- "Phase 2 — Build the app" (too large)
- "Phase 3 — Fix bugs as they come up" (not a phase, it's a state of mind)

## Sizing heuristics

- **Most projects have 5–10 phases.** Fewer than 4 usually means you're under-decomposing. More than 12 usually means the project is too large for one brief-to-prod pass — surface in the soft confirm.
- **Each phase has 3–8 tasks.** Tasks are bite-sized (~2–5 minutes of focused work each, per writing-plans convention).
- **A phase should fit in roughly one session of focused execution.** If a phase is so large it would always blow past context, decompose.
- **A phase should not span domains that have independent verification.** Frontend + backend + payments in one phase is too coupled — split by domain.

## Phase structure in PLAN.md

Each phase block in PLAN.md follows this shape:

````markdown
## Phase N — [Name]

**Goal:** [one sentence — what's true after this phase that wasn't before]

**Skill dependencies:** [list from SKILLS-TO-INSTALL.md, e.g. "Stage 1: react-best-practices; Stage 2: testing-library-react"]

**Tasks:**

- [ ] **Task 1: [Component / responsibility]**
  - Files: Create `src/...`, Modify `src/...:L-L`
  - Steps:
    1. Write failing test for X
    2. Run test — expect fail
    3. Implement minimal code
    4. Run test — expect pass
    5. Commit
- [ ] **Task 2: ...**

**Definition of done:**
- [ ] All tasks above checked
- [ ] Verification command runs clean: `[exact command]` → expected output `[X]`
- [ ] No regressions: `[existing test suite command]` → all green
- [ ] Commit message: `phase-N: [summary]`

**Phase Completion Log:** _(Stage B appends here after running the verification command)_
````

The "Phase Completion Log" is critical — it's the breadcrumb trail confirming a phase was actually verified, not just declared done.

## Definition of done — non-negotiable

Every phase has a definition of done that includes:

1. **All task checkboxes ticked.** Not "most." All. If a task is genuinely unworkable, mark it `[SKIPPED — see NOTES-TO-ADMIN]` and the phase definition of done now requires the skip is resolved or accepted.
2. **A specific verification command.** Not "tests pass" but `npm test --filter auth` (or equivalent). The command and the expected outcome are both in the plan.
3. **No regressions in earlier phases' verifications.** Re-run prior phase verifications if there's any chance the current phase affected them. If "all tests" is fast, run all tests.
4. **A commit at the boundary.** One clean commit, message of the form `phase-N: [phase name and one-line summary]`.

## Per-phase test discipline

This is rule 7 of the autonomy contract. The point: never carry untested work forward.

- **TDD where it works.** Write the failing test, then the code, then verify pass. This is the writing-plans default.
- **Smoke tests where TDD doesn't fit.** For UI shells, integration setups, or things that are easier to verify by running once than by writing a test for, define the smoke test explicitly in the phase: "Run `npm run dev`, open localhost:3000, confirm the dashboard route renders without errors."
- **Integration tests at phase boundaries.** When a phase touches multiple layers, the verification command is an end-to-end test of the whole path.
- **External API tests once per phase.** Per rule 9 — stub during development, hit the real API once at phase end to verify the shape hasn't drifted.

## Cross-phase dependencies

Some phases logically require others to be complete first. Document them in PLAN.md with explicit `Depends on:` lines:

```markdown
## Phase 4 — Dashboard data

**Depends on:** Phase 2 (auth — for user-scoped queries), Phase 3 (dashboard shell)
```

Sequential by default. If two phases are independent, mark them `**Independent of:** ...` so Stage B knows it can pick them up out of order if blocked on dependencies.

## Skill stage dependencies

Each phase lists which skills it depends on (from `SKILLS-TO-INSTALL.md`):

- **Stage 1 skills** must be installed before Stage B begins (Stage A's hand-off lists them).
- **Stage 2 skills** can be installed during execution — the phase that needs them won't start until they're confirmed installed.
- **Stage 3 skills** are nice-to-have — phases proceed without them but log an FYI.

Per rule 8, Stage B pauses any phase whose Stage 2/3 dependencies aren't available, writes a BLOCKER, and continues with non-dependent phases where possible.

## Anti-patterns

- **Phases without verification commands.** Reads as "phase done = phase claimed done," which is the lie the verification-before-completion skill exists to prevent.
- **One mega-phase covering the whole MVP.** This is the most common failure. The plan should let you stop at any phase boundary and have a coherent partial project.
- **Phases that don't end in something the user could see / run.** Each phase should produce a demonstrable change — a new endpoint working, a new UI screen rendering, a deployment going through.
- **"Refactor and polish" as a final phase.** Refactoring belongs inside phases as they're built. A "polish" phase smells like accumulated tech debt — fix at the source.
- **Hidden dependencies between phases.** If Phase 4 secretly requires a thing from Phase 2 that wasn't surfaced in `Depends on:`, the next session will hit a confusing error. Surface dependencies explicitly.

## Worked example — three-phase MVP

```markdown
## Phase 1 — Repo scaffolding

**Goal:** A Next.js 15 app scaffolded, CI green, deployed to Vercel preview.
**Skill dependencies:** Stage 1: react-best-practices
**Tasks:** (5 tasks omitted for brevity)
**Definition of done:**
- [ ] All tasks checked
- [ ] `npm run build` → exit 0
- [ ] `npm test` → 0 tests, 0 failures (placeholder suite present)
- [ ] Preview deploy URL responds 200 on `/`
- [ ] Commit: `phase-1: scaffold next.js app with CI and preview deploy`

## Phase 2 — Auth

**Goal:** Email+password signup/login/logout via Supabase, session persists across reloads.
**Depends on:** Phase 1
**Skill dependencies:** Stage 2: supabase-auth-patterns
**Tasks:** (6 tasks omitted)
**Definition of done:**
- [ ] All tasks checked
- [ ] `npm test -- auth/` → all pass
- [ ] Manual: signup, logout, login, reload all work in preview
- [ ] Commit: `phase-2: auth via supabase, session persistence verified`

## Phase 3 — Dashboard shell

**Goal:** Authenticated `/dashboard` route renders a layout with placeholder cards; redirects to `/login` when unauthenticated.
**Depends on:** Phase 2
**Skill dependencies:** none beyond Phase 1's
**Tasks:** (4 tasks omitted)
**Definition of done:**
- [ ] All tasks checked
- [ ] `npm test -- dashboard/` → all pass
- [ ] Manual: `/dashboard` while logged out → redirected to `/login`; while logged in → layout renders
- [ ] Commit: `phase-3: dashboard route shell with auth guard`
```

Three phases. Each phase ends in a verifiable state. Each phase is roughly one session of focused work.
