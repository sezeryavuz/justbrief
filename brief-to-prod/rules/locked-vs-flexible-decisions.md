# Reading locked vs flexible decisions in the brief

`TECHNICAL-DECISIONS.md` flags every decision as `LOCKED` or `FLEXIBLE`. This file is the vocabulary lookup the skill uses when reading the brief.

Rule 6 of the autonomy contract: locked constraints are not up for revision during execution. Getting these labels right at Stage A is what makes Stage B autonomous and trustworthy.

---

## Locked signals

Phrases that mean **LOCKED**:

- "must use"
- "must be"
- "required"
- "non-negotiable"
- "we already have"
- "already chosen"
- "we've decided"
- "the only option"
- "has to be"
- "needs to be"
- "we're using" (present tense — implies committed)
- "the stack is"
- "built on"
- "running on"
- explicit constraints with rationale ("must use Postgres because we have existing infra")

Implicit locking signals:

- A specific version pin ("React 19.0.0", "Postgres 16")
- Reference to existing infrastructure ("our existing Auth0 tenant")
- Compliance or regulatory references ("HIPAA-compliant DB")
- Cost / budget locks ("must run on free-tier services")

## Flexible signals

Phrases that mean **FLEXIBLE**:

- "probably"
- "we'd like to use"
- "preferred"
- "ideally"
- "lean toward"
- "thinking about"
- "considering"
- "open to"
- "default to"
- "something like"
- "X or similar"
- comparison choices ("Postgres or MySQL")
- "you decide" / "your call" / "up to you"

## Silent

If the brief says nothing about a decision:

- Treat as `FLEXIBLE` with the skill's recommended default (see `references/brief-anatomy.md` "Gap-filling patterns")
- Note the default in TECHNICAL-DECISIONS.md and the source: "FLEXIBLE — default chosen because brief was silent"
- Surface in the soft confirm only if the choice is significant (database, deploy target, payment provider, auth provider)

## When in doubt, lean flexible

Over-locking blocks reasonable improvements mid-execution and forces unnecessary IMPORTANT notes. Under-locking risks silently changing things the user cared about (but rule 1 says: the brief is the contract — silent changes don't happen, you surface).

So the asymmetry favors flexibility: a flexible decision the user later wants to lock can be locked with a one-line update; a locked decision that's wrong forces a paused phase and an IMPORTANT note.

## Format in TECHNICAL-DECISIONS.md

Every entry follows this shape:

```markdown
### [Decision name]

**Choice:** [the specific choice]
**Status:** LOCKED | FLEXIBLE
**Source:** [brief quote or "default because brief silent"]
**Why this matters:** [one sentence — what depends on this]
```

Example:

```markdown
### Database

**Choice:** Postgres 16
**Status:** LOCKED
**Source:** Brief: "We already have a Postgres cluster — use it"
**Why this matters:** All schema, query, and migration work assumes Postgres semantics.

### CI provider

**Choice:** GitHub Actions
**Status:** FLEXIBLE
**Source:** default because brief silent (repo is on GitHub)
**Why this matters:** Affects workflow YAML format and runner availability.
```

## Edge case — conflicting signals in the brief

If one sentence says "we'd like to use X" and another says "X is required," the latter wins (locked). If neither has the other's specificity and they truly conflict, surface as an IMPORTANT note in NOTES-TO-ADMIN.md during Stage A and ask in the soft confirm.

## Edge case — a locked decision that's incoherent

E.g. brief locks "Postgres" but also locks "we run only on Cloudflare Workers" (Postgres is not natively available there). Surface as a BLOCKER in Stage A — the soft confirm needs to resolve this before Stage B can plan around it.
