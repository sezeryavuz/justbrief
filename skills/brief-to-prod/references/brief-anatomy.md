# Brief anatomy — what makes a good brief

This file describes what a complete brief contains, what's commonly missing, and how to fill gaps without bouncing the user.

---

## The minimum useful brief

A brief that gives the skill enough to work with contains, in any form:

1. **What is being built.** A description specific enough to picture the result. "A web app" is not enough; "a Postgres-backed dashboard that shows revenue from Stripe broken down by product line" is enough.
2. **Why.** The purpose, the audience, the problem being solved. Helps the skill make good trade-offs when the spec is silent.
3. **MVP scope.** What must be true for V1 to be considered shipped. Either a feature list or a user-story narrative.
4. **Locked decisions.** Any technology, vendor, constraint, or design choice the user has already made and doesn't want revisited. Use clear language: "must use," "we already have," "non-negotiable," etc.

A great brief also includes:

- **Out-of-scope items** explicitly listed (saves rework when the skill almost builds it and the user says "no, that's V2")
- **The intended deploy target** if known
- **Performance, scale, or compliance constraints** that affect architecture (HIPAA, sub-100ms p99, etc.)
- **Existing infrastructure** to integrate with (existing auth provider, existing database, existing CI)
- **Reference implementations** the user likes ("similar to X but without Y")

## Length

A few hundred to a couple thousand words is usually right. Briefs much shorter than that leave too much to interpret; briefs much longer drift into spec territory and lose the "brief" property.

If the user has more than ~3000 words of brief, suggest splitting into a brief + an appendix (the appendix being detailed specs they want the skill to honor). The skill reads both but treats the brief as the primary contract.

## Common omissions and how to handle them

### "Who is this for?"

If the brief doesn't say, the skill makes an inference from context (B2B SaaS? consumer? internal tool? developer tool?) and surfaces the inference in the soft confirm: *"I interpreted this as a [type]. Is this correct?"*

### "What's the deploy target?"

If unclear, default to the most natural target for the chosen stack (e.g. Vercel for Next.js, Fly for Node services, etc.) and flag in TECHNICAL-DECISIONS.md as `FLEXIBLE`. Confirm in the soft confirm if it's a notable choice.

### "What's the budget / team size implied?"

Usually unsaid. The skill assumes solo / small-team unless the brief says otherwise; this affects choices like "use a managed DB" vs "self-host." If a choice has significant cost implications either way, flag in TECHNICAL-DECISIONS.md as `FLEXIBLE` and surface in soft confirm.

### "What does the MVP exclude?"

A brief that lists features but doesn't list non-features almost always leads to scope creep mid-build. If the brief lists 5 features and the soft-confirm options for "what is the MVP" gravitate toward 3 of them, that's a useful conversation to have in the soft confirm.

### "What does success look like?"

If the brief doesn't define success, the skill writes one in VISION.md based on inference and asks the user to confirm in the soft confirm.

### "What is the existing stack / codebase?"

This skill is greenfield-first. If the brief implies it's a major rewrite (the user mentions an existing system), the skill treats this as greenfield from a code perspective but reads any provided links / files for migration constraints. If the brief is "add this to my existing app," this is the wrong skill — the user wants a feature-development workflow, not brief-to-prod.

## Validating a brief — checklist

These are the checks `scripts/validate-brief.sh` runs (or that you run inline if no shell):

- [ ] Brief contains a "what" — at least one paragraph describing the product
- [ ] Brief contains a "why" — purpose, audience, or problem statement
- [ ] Brief contains an MVP indication — feature list, user stories, or scope description
- [ ] Brief is between ~200 and ~3000 words (warn outside this range, don't fail)
- [ ] Brief identifies at least the primary language / framework, OR explicitly says "you decide"
- [ ] Brief does not contradict itself (e.g. "must be free to host" and "use AWS Aurora" — flag)

Validation failures are inputs to the soft confirm, not project blockers. The skill resolves them by asking focused questions.

## When the brief is essentially a one-liner

E.g. "build me a personal finance dashboard." This skill can still proceed if the user is willing to answer Stage A questions liberally. The soft confirm will be longer than usual.

If the brief is so thin that 20+ confirmation questions would be needed, that's a sign the user should write a longer brief first. Surface as a BLOCKER:

> ## YYYY-MM-DD — BLOCKER
>
> **Issue:** The brief is too sparse to derive a meaningful foundation. I'd need to ask 20+ structural questions to proceed, which violates the "one soft confirm" contract.
>
> **What I need from you:** Expand the brief to cover at minimum: target user, 3–5 core features, preferred stack (or explicit "you decide"), success criteria.
>
> **Resolution:** _(awaiting admin)_

## Gap-filling patterns

Rather than asking the user, the skill **fills minor gaps with conventional defaults** and surfaces what was filled in the soft confirm only if the choice is significant.

| Gap | Conventional default | Surface in soft confirm? |
|---|---|---|
| Test framework | The language's most popular (Jest for JS, Pytest for Python, etc.) | No |
| Linter | Default for the framework (ESLint+Prettier, Ruff, etc.) | No |
| CI provider | GitHub Actions if the repo is on GitHub | No |
| Repo structure | Single repo, conventional layout for the framework | No |
| Deploy target | Most natural for the chosen stack | If significant cost / vendor lock-in |
| Auth provider | If unspecified, hosted (Supabase/Clerk) over self-hosted | Yes, briefly |
| Database | If unspecified, Postgres | Yes, briefly |
| Payment provider | If unspecified, Stripe | Yes, briefly |
| Monitoring / logging | If unspecified, defer to V2 (don't add unprompted) | No |

## Distinguishing locked from flexible

See `rules/locked-vs-flexible-decisions.md` for the vocabulary. In short:

- **Locked** signals: "must use," "we already have," "non-negotiable," "required," "already chosen"
- **Flexible** signals: "probably," "we'd like to use," "preferred," "ideally," "lean toward"
- **Silent**: the brief doesn't mention it → flexible, with the skill's recommended default

When in doubt, lean toward flexible — over-locking is worse than under-locking because over-locking blocks reasonable improvements.

## The user's brief is the contract

Per rule 1 of the autonomy contract: what the brief says is what gets built. The skill **does not improve on the brief** without surfacing it. If the brief asks for X and X seems suboptimal, build X and add an FYI to NOTES-TO-ADMIN.md explaining the trade-off. Don't silently substitute.
