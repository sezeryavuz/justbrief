# Skill discovery process

`SKILLS-TO-INSTALL.md` is one of the foundational outputs of Stage A. It tells the user which installable skills the project benefits from, grouped by when they're needed (Stage 1 / 2 / 3) and filtered for trust and audit status.

This file defines how to discover skills, how to filter them, how to group them, and what to do when discovery sources aren't available.

---

## Step 1 — Extract domains from the brief

Read the brief and identify discrete technical and workflow domains. Examples of domain types:

- **Languages / runtimes** — Python, TypeScript, Go, Rust, etc.
- **Frontend frameworks** — Next.js, Remix, Svelte, etc.
- **Backend frameworks** — FastAPI, Express, Rails, Phoenix
- **Databases** — Postgres, MongoDB, ClickHouse, SQLite, DynamoDB
- **Auth providers** — Supabase, Clerk, Auth0, NextAuth, etc.
- **Payment providers** — Stripe, Lemon Squeezy, Paddle
- **Deploy targets** — Vercel, AWS, GCP, Fly, Railway
- **Workflow needs** — TDD, design review, accessibility, performance
- **Special-purpose** — search (Algolia, MeiliSearch), email (Resend, Postmark), analytics (PostHog, Plausible), AI (OpenAI, Anthropic), maps, video, etc.

Be liberal at this stage — a domain that doesn't turn up a skill costs nothing to have tried. A missed domain costs a useful skill.

## Step 2 — Look for skills per domain

**Preferred path: `find-skills` skill is installed.**

Use it. It is the cleanest path and benefits from skills.sh's ranking and audit data. The `find-skills` skill itself documents its calling pattern (see SKILL.md → "Cousin skills").

Typical invocation per domain: `npx skills find <domain keyword>`.

**Fallback path: `find-skills` is NOT installed.**

Make direct HTTP calls to the skills.sh API:

- Search endpoint: query by keyword, get a list of skill candidates with their source, install count, and metadata
- Audit endpoint: per-skill audit status (PASS / WARN / FAIL)

The exact endpoints can be discovered from https://skills.sh's documentation or via `curl https://skills.sh/api/` to enumerate. If neither documentation nor enumeration works, use the leaderboard at https://skills.sh as a manual fallback — top skills per domain are listed by install count.

If even the API is unreachable (offline development, etc.), produce a `SKILLS-TO-INSTALL.md` that names the *categories* of skills the user should consider, with `[OFFLINE — discover manually at https://skills.sh]` next to each. Surface as an FYI in NOTES-TO-ADMIN.md.

## Step 3 — Apply the trust filter

For each candidate skill, look up its source (the GitHub owner). Match against the trust list in `rules/trusted-skill-sources.txt`. The user can override the trust list project-locally by adding `BRIEF/trusted-sources.txt` — if that file exists, it **replaces** (not augments) the default trust list.

Filter rules:

| Source | Audit | Include? |
|---|---|---|
| Trusted | PASS | ✅ Include |
| Trusted | WARN | ✅ Include |
| Trusted | FAIL | ❌ Exclude |
| Untrusted | PASS | ⚠️ Include, flag for user review |
| Untrusted | WARN | ❌ Exclude |
| Untrusted | FAIL | ❌ Exclude |

The "flag for user review" case shows up in `SKILLS-TO-INSTALL.md` with `[REVIEW: untrusted source]` next to the skill entry. The user decides whether to install it.

## Step 4 — Quality check

Beyond trust/audit, sanity-check the candidates:

- **Install count.** Prefer skills with ≥1K installs. Skills under 100 installs warrant a `[NEW: low install count]` flag.
- **Source reputation.** Official organizations (`anthropics`, `vercel-labs`, `microsoft`, `obra`) are stronger signals than unknown personal accounts.
- **Recency.** If the underlying GitHub repo has been inactive for years, flag with `[STALE]`.

These checks mirror the `find-skills` skill's own guidance.

## Step 5 — Group by stage

See `stage-mapping-heuristics.md` for the full criteria. In short:

- **Stage 1** — needed before Stage B begins; foundation, scaffolding, conventions
- **Stage 2** — needed during specific phases of execution
- **Stage 3** — nice-to-have; the project ships without them but they improve specific outputs

Each Stage 2 skill in `SKILLS-TO-INSTALL.md` is annotated with the phase(s) it supports.

## Step 6 — Write `SKILLS-TO-INSTALL.md`

Use the template at `templates/SKILLS-TO-INSTALL.md.template`. The structure:

```markdown
# SKILLS-TO-INSTALL.md — [project name]

## Stage 1 — Install before Stage B

- **[skill-name]** ([source]) — [one-line purpose] ([install count])
  - `npx skills add <owner/repo@skill> -g -y`
  - Audit: [PASS/WARN]
  - [Optional flags: REVIEW: untrusted, NEW: low install count, STALE]

## Stage 2 — Install before relevant phase

- **[skill-name]** ([source]) — [purpose] ([install count])
  - Needed by: Phase N
  - `npx skills add <owner/repo@skill> -g -y`
  - Audit: [PASS/WARN]

## Stage 3 — Optional

- **[skill-name]** ([source]) — [purpose]
  - Reason: [why it would help]
  - `npx skills add <owner/repo@skill> -g -y`

## Skills not found for these domains

- [domain] — searched, no matching skill in the trust filter. Will proceed without.
```

If a domain genuinely lacks a skill and you proceed without one, say so — that's transparency.

## When the user has skills already installed

Stage A doesn't need to re-recommend skills the user already has. Before producing `SKILLS-TO-INSTALL.md`, check the platform's installed skill list (in Claude Code: the user's `~/.claude/skills/` or the slash-listed skills). For each candidate that's already installed, list it under a "Already installed" section so the user knows it was considered, not missed.

## Re-running discovery later

If the user adds a new feature mid-execution that needs a new domain (e.g. "let's add SMS notifications via Twilio"), Stage B can re-run discovery for that one domain and **append** to `SKILLS-TO-INSTALL.md` with a new Stage 2 entry. Do not rewrite the whole file — append.

## Dynamic mid-Stage-B installation (v0.2)

When Stage B reaches a phase whose required Stage 2 skills are not yet installed, the skill performs a *dynamic install* using Claude Code's `/reload-plugins` command — installing and activating the skill **without forcing a `/clear`**. This keeps Stage B's autonomous flow intact.

The flow is summarized as:

```
/skills → npx skills add ... → /reload-plugins → /skills (verify) → continue
```

Full mechanics (verify steps, log lines, fallback when `/reload-plugins` is unavailable) live in `references/dynamic-skill-installation.md`. That file also covers what gets logged and what triggers a BLOCKER vs an FYI.

This applies to Stage 2 skills only. Stage 1 skills are the user's pre-Stage-B contract; a missing Stage 1 skill is a BLOCKER per autonomy rule 8.
