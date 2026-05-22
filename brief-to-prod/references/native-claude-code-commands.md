# Native Claude Code commands — when and how

brief-to-prod runs inside Claude Code. Claude Code ships a small set of slash commands that map cleanly onto behaviors this skill has historically described in prose. This file documents which commands the skill uses, when, and why — so the behavior is auditable and the skill stays aligned with native Claude Code primitives instead of reinventing them.

These are commands the **skill itself** invokes (or instructs the user to invoke). They are not commands the brief specifies. Skill behavior should always degrade gracefully if a command is unavailable in the user's Claude Code version — fall back to the prose protocol the command replaces.

---

## `/reload-plugins`

**What it does.** Activates plugin changes (new skills, hook changes, etc.) in the current session without `/clear`. Lets the skill install a new skill mid-execution and use it immediately.

**When the skill uses it.** In Stage B, when a phase about to start needs a Stage 2 skill that isn't installed. Sequence:

1. `/skills` to confirm whether the candidate skill is already present.
2. If not: `npx skills add <source> --skill <name>` via bash.
3. `/reload-plugins` to activate.
4. Continue Stage B without `/clear`.

See `dynamic-skill-installation.md` for the full flow.

**Fallback if unavailable.** Log an FYI to `LOG.md` ("attempted /reload-plugins, not available in this Claude Code version") and tell the user verbatim: *"I installed `<skill>`. Run `/clear` and type `continue` so the new skill is loaded."* This is slower but always works.

## `/goal`

**What it does.** Sets a goal for the session and instructs the agent to keep working until the goal is met. This is the native form of the autonomy contract's rule 3 ("Stage B is fully autonomous").

**When the skill uses it.** At the end of Stage A, immediately before handoff. The skill sets a goal like:

> *"Complete all phases in PLAN.md to their definition-of-done. Surface BLOCKERs to NOTES-TO-ADMIN.md and continue with non-dependent work. Run Stage C handoff if context approaches 90%."*

This reinforces — at the platform level — the contract the skill describes in prose. If `/goal` is available, use it. If not, the prose contract still binds.

**Fallback if unavailable.** None needed — the autonomy contract in `references/autonomy-contract.md` carries the same meaning. `/goal` is reinforcement, not requirement.

## `/context`

**What it does.** Reports the current session's context utilization (typically a percentage or token count).

**When the skill uses it.** Two trigger points:

1. **Periodic check during Stage B.** Before starting a substantial task, check context. If >85%, prepare for handoff.
2. **Before the next phase.** Phase boundaries are natural break points. If `/context` shows >80% at a boundary, hand off proactively rather than starting a phase you can't finish.

The skill does not poll `/context` after every tool call — that's noise. Check at task boundaries.

**Fallback if unavailable.** Use the agent's own internal signal — the harness summarizing aggressively, losing detail from earlier turns, etc. The trigger heuristic in `context-exhaustion-protocol.md` covers this.

## `/skills`

**What it does.** Lists currently installed skills.

**When the skill uses it.** Two trigger points:

1. **Stage A skill discovery** — before adding a candidate to `SKILLS-TO-INSTALL.md`, check whether the user already has it (so the file goes under "Already installed" instead of "Stage 1 — install").
2. **Stage B dynamic install** — before `npx skills add` for a newly-needed skill, check whether it's already there (e.g. the user installed it manually).

**Fallback if unavailable.** Read `~/.claude/skills/` directly with `ls` via bash, or skip the check and accept that occasional re-install attempts are harmless.

## `/compact`

**What it does.** Summarizes the current conversation in place, freeing context while preserving state about what was discussed.

**When the skill uses it.** When context exhaustion hits **mid-phase**. Mid-phase means there's in-flight state (an edit in progress, a half-running test, a partly-formed decision) that the next session benefits from inheriting. Compact preserves that summary.

The skill does not invoke `/compact` itself — it tells the user verbatim: *"Run `/compact` (preserves summaries) and type `continue`."* The user invokes it.

**Compare to `/clear`** (next entry) for the choice.

## `/clear`

**What it does.** Wipes the conversation and starts fresh in the same session.

**When the skill uses it (instructs the user to use it).** At **phase boundaries** — when one phase is fully complete (verified, committed, LOG entry written) and the next phase is about to start. At a boundary, LOG.md already carries everything the next session needs; in-flight state from the prior turn would just clutter context.

**Choosing between `/compact` and `/clear`:**

```
At context exhaustion mid-phase    → /compact (preserve in-flight summary)
At a clean phase boundary          → /clear (fresh slate; LOG.md carries state)
Stage A handoff                    → /clear (always — clean slate for Stage B)
Stage C handoff                    → user's choice; the skill suggests /compact for mid-phase, /clear for phase boundary
```

The skill explicitly tells the user which one to run.

## `/diff`

**What it does.** Shows uncommitted git changes.

**When the skill uses it.** Inside phase-completion checkpoints — after running the verification command and before committing, the skill can call `/diff` (or `git diff` via bash) to sanity-check that the diff matches what the phase intended to change. If the diff contains surprising files (e.g. unintended edits to `.env` or other configs), the skill writes an IMPORTANT note instead of committing.

Also useful during Stage C: a quick `/diff` confirms there's nothing uncommitted that would be lost across session boundary.

**Fallback if unavailable.** `git diff` and `git status --porcelain` via bash give the same information.

## `/agents`

**What it does.** Manages agent configurations — primarily relevant when a skill ships specialized sub-agents.

**When the skill uses it.** Not in v0.2.0. Sub-agent integration is deferred to v0.3.0; see `sub-agent-design-deferred.md` for the planned use.

## `/hooks`

**What it does.** Views configured hooks (PreToolUse, PostToolUse, SessionStart, etc.).

**When the skill uses it.** Not in v0.2.0. Lifecycle hook integration is deferred to v0.3.0; see `lifecycle-hooks-deferred.md`.

## `/init`

**What it does.** Claude Code's CLAUDE.md initializer — produces a generic CLAUDE.md for the repo.

**When the skill uses it.** Never. The skill produces its **own opinionated** CLAUDE.md from `templates/CLAUDE.md.template`, tailored to a brief-to-prod project (resume mechanic, autonomy contract reminder, file map). `/init`'s output is generic; brief-to-prod's is specific.

If a user runs `/init` on a brief-to-prod project, the skill's CLAUDE.md is what governs. If the user wants the generic version too, they can run `/init` and name the output something else.

**Note for documentation:** the README and SKILL.md mention this so users aren't confused.

---

## Compatibility / version-skew policy

Claude Code evolves. A command available in version N may be renamed or behave differently in N+1. The skill should:

1. Try the command.
2. If it errors or isn't recognized, log an FYI in LOG.md and use the prose fallback documented above.
3. Never block on a command being available — every command listed has a documented fallback.

If a user reports that a command behaves differently from this file's description, that's a v0.2.x doc update, not a skill bug.

---

## Cross-references

- `references/dynamic-skill-installation.md` — full flow that uses `/skills` + `/reload-plugins`
- `references/context-exhaustion-protocol.md` — `/context`, `/compact`, `/clear` in the handoff protocol
- `references/stage-a-protocol.md` — `/goal` at Stage A handoff
- `references/autonomy-contract.md` — Rule 3 (autonomous Stage B) is what `/goal` formalizes
- `references/security-posture.md` — only the commands listed here are invoked by the skill; that's the contract
