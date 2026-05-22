# Sub-agent integration — design notes (deferred to v0.3)

v0.2 considered adding an `agents/` folder with specialized sub-agent definitions for Stage B. The brief explicitly asks for this design to be documented even when implementation is deferred, so a future v0.3 can pick it up cleanly. This file is that record.

**Status: DEFERRED to v0.3.** No `agents/` folder ships in v0.2.

---

## Why defer

Sub-agent integration would touch:

- The phase-execution loop in SKILL.md (Stage B step list)
- `references/phase-design-guide.md` (how each phase decomposes into sub-agent tasks)
- `references/autonomy-contract.md` (new rule on sub-agent dispatch policy)
- Up to four new agent prompt templates
- Model-selection guidance per role

That doubles v0.1.0's surface area. The brief calls this out explicitly: "if Theme 3 doubles surface area, defer to v0.3 and document the design." This file is the documented design.

The existing single-agent flow already works for Stage B — `subagent-driven-development`'s patterns are an *optimization*, not a correctness fix. They are exactly the right v0.3 evolution; they are too much for v0.2.

---

## Planned `agents/` folder layout

When v0.3 picks this up, the folder will be:

```
brief-to-prod/
└── agents/
    ├── implementer.md          # Implements one task per dispatch
    ├── spec-reviewer.md         # Verifies implementation matches PLAN.md task
    ├── quality-reviewer.md      # Checks code quality, tests, conventions
    ├── final-reviewer.md        # End-of-project full review
    └── README.md                # When to dispatch which sub-agent
```

Each `*.md` file is a Claude Code agent definition (YAML frontmatter + prompt body) following the conventions in the `subagent-driven-development` reference skill.

---

## Planned per-phase flow

For each phase in Stage B (this replaces the v0.1.0 "execute the phase" step):

```
1. Read the phase block from PLAN.md (Goal, Tasks, Definition of Done).
2. For each task in the phase:
   a. Dispatch `implementer` with the task text + the surrounding context the main agent curates.
   b. Implementer reports DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED.
   c. If DONE → dispatch `spec-reviewer` on the diff against the task spec.
   d. If spec-reviewer flags issues → re-dispatch implementer to fix → re-review.
   e. When spec-reviewer is clean → dispatch `quality-reviewer` on the diff for code quality.
   f. If quality-reviewer flags issues → re-dispatch implementer → re-review.
   g. When both reviewers are clean → mark task complete in PLAN.md.
3. Run the phase verification command (main agent, not sub-agent).
4. Commit.
5. LOG.md entry.
6. Continue to next phase.
```

At the end of all phases:

```
N. Dispatch `final-reviewer` on the full project diff vs PLAN.md's success criteria.
N+1. Address any blockers final-reviewer finds.
N+2. Stage B complete; project ships.
```

---

## Model selection (planned)

Per `subagent-driven-development`'s guidance:

| Role | Recommended model tier |
|---|---|
| `implementer` for 1–2 file mechanical tasks | Fast / cheap (Haiku-tier) |
| `implementer` for multi-file integration | Standard (Sonnet-tier) |
| `spec-reviewer` | Standard |
| `quality-reviewer` | Standard or above |
| `final-reviewer` (end-of-project) | Most capable (Opus-tier) |

The main agent coordinating the run stays on whatever model the user invoked Claude Code with. Sub-agents are dispatched with explicit model selection.

---

## Why this is a real improvement (not just complexity)

- **Context preservation.** The main agent stays focused on coordination; sub-agents handle bounded tasks. Long Stage B runs survive longer before context exhaustion.
- **Quality gates.** Two-stage review (spec then quality) catches over-building and under-building before they cascade.
- **Cost shaping.** Cheap models for mechanical work, expensive models for review/judgment. The current single-agent flow uses one tier throughout.
- **Parallelism.** When two phases are flagged `Independent of:` in PLAN.md, v0.3 could dispatch implementers concurrently. v0.2 cannot.

---

## What v0.2 already does that v0.3 builds on

The autonomy contract (rule 3) already says Stage B doesn't ask for permission. The LOG protocol (every entry has a `Next concrete task` line) already produces the granular task records sub-agents would consume. The phase structure (Goal / Tasks / Definition of Done) already breaks work into the right shape.

v0.3 will add the dispatch mechanics; v0.2's protocol is the substrate.

---

## Open questions for v0.3

- How does the main agent budget sub-agent invocations to stay under a session's token cap?
- Does each sub-agent get its own LOG.md "voice" or does the main agent consolidate?
- What happens when the spec-reviewer disagrees with PLAN.md (rather than with the implementer's diff)?
- Should `quality-reviewer` use a project-shipped config or rely on the language ecosystem's defaults?

These don't need to be answered now. Listed here so v0.3 can pick them up.

---

## Cross-references

- `references/native-claude-code-commands.md` — `/agents` is the command sub-agent integration uses
- `references/phase-design-guide.md` — current phase structure that sub-agents will consume
- `references/autonomy-contract.md` — current 12 rules; v0.3 may extend with a 13th covering dispatch policy

Reference skills that informed this design (in `.workspace/reference-skills/` during v0.2 authoring):

- `subagent-driven-development` — the per-task pattern
- `dispatching-parallel-agents` — when concurrent dispatch is appropriate
- `requesting-code-review` — reviewer prompt template
- `receiving-code-review` — how implementer handles reviewer feedback
