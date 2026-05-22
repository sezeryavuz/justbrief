# NOTES-TO-ADMIN.md — when, why, how

`NOTES-TO-ADMIN.md` is the user's inbox. It surfaces only what the user needs to act on or know about. Most of the skill's work never reaches this file.

This file defines severity, entry format, the resolution mechanic, and the worked judgment patterns.

---

## Severity

Three levels. Pick one per entry.

### BLOCKER

The skill cannot proceed on the dependent work without admin input. Always pair with a paused task / phase flag in `PLAN.md`.

Examples:
- Stripe API key required but the user has not created an account
- A locked technical decision turns out to be infeasible mid-execution
- The brief is genuinely ambiguous on an irreversible decision (e.g. user-facing pricing model)
- A required service or library is not available in the user's region

### IMPORTANT

The skill can proceed (perhaps with non-dependent work) but the admin should weigh in soon. Often used for decisions that affect direction but aren't yet blocking.

Examples:
- Discovered that a flexible decision would be much better with a different choice (admin may want to update TECHNICAL-DECISIONS.md)
- A new dependency on an external service became necessary that wasn't in the brief
- Cost estimates for a planned approach are materially higher than implied
- A security concern that needs user awareness but isn't immediately exploitable

### FYI

Informational only. The admin can read this at leisure with no required action.

Examples:
- "Generated the foundation; Stage A complete."
- "Phase 3 took longer than estimated; PLAN.md updated."
- "Used a fallback library for X because the brief's preferred choice was unmaintained."

Use FYI sparingly. If it's truly nothing the user cares about, it might just be a LOG entry instead.

---

## Entry format

```markdown
## YYYY-MM-DD — [SEVERITY]

**Issue:** What is happening. One or two sentences max.

**What I need from you:** Concrete ask. If multiple paths forward, name them.

**Affected work:** Which phase / task is paused or constrained. Reference PLAN.md.

**Non-dependent work in progress:** What I'm continuing while this is open.

**Resolution:** _(appended by admin — see below)_
```

For FYI entries, drop "What I need from you" and "Affected work."

For BLOCKER entries, the "Affected work" line is mandatory and must reference a PLAN.md task that has been marked paused.

## Resolution mechanic

When the user resolves an entry, they append a `**Resolution:** YYYY-MM-DD — ...` line to the entry. After resolution:

- For BLOCKERs: the next session resumes the paused work. Update PLAN.md to un-pause the task.
- For IMPORTANTs: update the relevant artifact (TECHNICAL-DECISIONS.md, PRODUCT-SPEC.md, etc.) per the resolution and continue.
- For FYIs: no action needed.

Entries are never deleted, only resolved. The history is the audit trail.

## Examples

### BLOCKER — missing API key

```markdown
## 2026-05-22 — BLOCKER

**Issue:** Phase 4 (payment integration) requires a Stripe test API key. None present in the environment or `.env.example`. The brief named Stripe as the locked payment provider but no account creation step.

**What I need from you:** Create a Stripe account (test mode is fine for development), generate a test secret key, and add it as `STRIPE_SECRET_KEY` in your local `.env`. Confirm here when done.

**Affected work:** Phase 4, all tasks. PLAN.md marks Phase 4 paused.

**Non-dependent work in progress:** Phase 5 prep (analytics scaffolding) does not depend on Stripe and is continuing.

**Resolution:** _(awaiting admin)_
```

### IMPORTANT — locked decision needs revision

```markdown
## 2026-05-22 — IMPORTANT

**Issue:** TECHNICAL-DECISIONS.md locks Postgres. During Phase 4, the analytics queries needed by the dashboard would run roughly 10× faster on ClickHouse for this access pattern. Postgres still works but the dashboard will feel slow under load.

**What I need from you:** Pick one — (a) keep Postgres and accept the perf cost, (b) switch to ClickHouse outright, (c) hybrid: Postgres for transactional, ClickHouse for analytics only.

**Affected work:** Phase 4 dashboard endpoints. Currently paused pending direction; Phase 5 (notifications) is non-dependent and continues.

**Resolution:** _(awaiting admin)_
```

### FYI — fallback used

```markdown
## 2026-05-22 — FYI

**Issue:** The brief preferred `node-cron` for scheduled tasks but it has not been actively maintained for 2 years (last release 2023-08). Switched to `croner` which is API-compatible enough for our usage and actively maintained. Updated TECHNICAL-DECISIONS.md (was FLEXIBLE, not LOCKED).

**Resolution:** _(no action needed; FYI)_
```

---

## When to surface vs not

The bar is high. Default is *don't surface*. Surface only when:

- The decision is irreversible or expensive to reverse
- An external action is required that you cannot take (account creation, API key, domain registration, infrastructure provisioning)
- A locked constraint is in question
- A material risk to security, privacy, or the user's wallet
- A genuine ambiguity in the brief affects something the user would want to weigh in on

Do **not** surface for:

- File and folder naming (decide)
- Library micro-choices within a constraint (decide)
- Subtask ordering (decide)
- Refactoring opportunities you noticed (just do it or skip; not the user's problem)
- Test strategy details (decide)
- Stylistic choices already covered by reasonable defaults (decide)
- "Should I move to the next phase?" (the answer is always yes per Rule 3 of the autonomy contract)

## Batching

Multiple notes can stack. The skill **continues with non-dependent work** while admin notes await resolution. Stage B does not pause the whole project just because one BLOCKER is open — it pauses only the dependent work and proceeds elsewhere.

When two related notes arise close together, write them as separate entries (one per issue) — easier for the admin to resolve them in order.

## Where this file lives

`NOTES-TO-ADMIN.md` at repo root. Created empty by Stage A with this header:

```markdown
# NOTES-TO-ADMIN.md — [project name]

Surfaced by brief-to-prod for items requiring admin input or awareness.

## Severity meanings

- **BLOCKER** — Cannot proceed without admin input
- **IMPORTANT** — Can proceed, but admin should weigh in soon
- **FYI** — Informational

## Entry format

[reference to references/notes-to-admin-guide.md or short reminder]

---
```

Then entries follow.
