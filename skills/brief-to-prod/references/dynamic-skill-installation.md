# Dynamic skill installation — installing skills mid-execution

Stage A's `SKILLS-TO-INSTALL.md` lists Stage 2 and Stage 3 skills the project may need. Stage 2 skills are installed *just in time* — right before the phase that needs them. v0.2 introduces a native flow that performs the install **without forcing a `/clear`**, so the skill keeps momentum across phases.

This file describes the flow, the fallback when `/reload-plugins` isn't available, and the audit-friendly logging the skill emits.

---

## When the flow runs

At the start of each phase in Stage B, the skill checks `PLAN.md`'s `Skill dependencies:` line for that phase. For each Stage 2 or Stage 3 skill listed:

1. Was it confirmed installed in a previous step? If yes, proceed.
2. Otherwise, run the install flow below.

Stage 1 skills are not handled here — by contract, the user installed them before running `/clear continue` after Stage A. If a Stage 1 skill is missing at Stage B start, that's a BLOCKER (per autonomy rule 8), not a dynamic install opportunity.

---

## The install flow

```
1. /skills
   → list installed skills
   → if the target skill is already there, log FYI and proceed without install

2. Bash: npx skills add <source>[--skill <name>] -g -y
   → install at user (-g) level
   → -y skips interactive prompts
   → capture stdout/stderr to LOG.md for traceability

3. /reload-plugins
   → activates the new skill in the current session
   → no /clear needed

4. /skills (verify)
   → confirm the skill now appears
   → if not, treat as BLOCKER (see fallback below)

5. LOG.md entry:
   "Installed <skill> via <command>. /reload-plugins active. Verified via /skills."

6. Continue Stage B execution.
```

---

## Why this matters

Before v0.2, the only ways to add a skill mid-build were:

- Stop, tell the user to install, hand off via `/clear continue`. Cost: one full handoff per skill.
- Skip the skill and produce subtly worse output (silent quality loss).

`/reload-plugins` eliminates both costs. The skill keeps autonomous momentum and the user doesn't have to context-switch.

---

## Fallback — `/reload-plugins` unavailable or fails

Some Claude Code versions don't expose `/reload-plugins`. If the command errors, isn't recognized, or appears not to take effect (verified via `/skills` after):

1. Write an FYI to `LOG.md`: *"Attempted /reload-plugins, did not appear to activate <skill>. Falling back to user handoff."*
2. Write a BLOCKER to `NOTES-TO-ADMIN.md`:

   > ## YYYY-MM-DD — BLOCKER
   >
   > **Issue:** Phase N requires `<skill>`. Installed via `npx skills add ...` but cannot activate in this session.
   >
   > **What I need from you:** Run `/clear` and type `continue` so the new skill is loaded. I'll resume from LOG.md's last entry.
   >
   > **Affected work:** Phase N is paused.
   >
   > **Non-dependent work in progress:** [next non-dependent phase, if any]
   >
   > **Resolution:** _(awaiting user)_

3. Continue with any non-dependent phase per rule 8 of the autonomy contract.

The fallback always works — it just costs a handoff.

---

## Trust and audit checks at install time

The trust filter applied during Stage A discovery (`skill-discovery-process.md`) already vetted the skill. At install time, the skill does **not** re-verify trust or audit — that decision was already made and is recorded in `SKILLS-TO-INSTALL.md`.

What the skill *does* do at install time:

- Captures the exact command run, the source, and the resolved skill name into LOG.md
- Captures the install's exit code (0 expected; non-zero → BLOCKER + a clear note)
- Does **not** read the new skill's content beyond what `/skills` shows; the new skill activates and Claude Code itself handles the load

This keeps the install path auditable: every install corresponds to a LOG.md entry naming the skill, the command, and the activation method.

---

## What gets logged

Each dynamic install produces three LOG.md artifacts:

1. **Pre-install line**: *"Phase N needs <skill>. Checked /skills — not installed. Proceeding with install."*
2. **Install line**: the exact command and its stdout/stderr summary. Trim to ~10 lines.
3. **Verify line**: *"`/skills` confirms <skill> active. Continuing Phase N."*

If verify fails, replace 3 with the BLOCKER + fallback flow above.

Three lines per install is the right density. More clutters; less and the audit trail is too thin.

---

## What does NOT happen in this flow

- The skill never installs Stage 1 skills mid-execution. Stage 1 is the user's contract at Stage A handoff. A missing Stage 1 skill is a BLOCKER.
- The skill never installs a skill the user did not pre-approve through `SKILLS-TO-INSTALL.md` (Stage A) or a NOTES-TO-ADMIN.md resolution. No surprise installs.
- The skill never silently swaps a skill for a different one mid-execution. If a candidate isn't installable, that's a BLOCKER.
- The skill does not modify `~/.claude/settings.json`, hooks, or any global Claude Code config to enable a skill. Install via `npx skills add` only.

These constraints are mirrored in `security-posture.md` — the install path is one of the few places the skill interacts with the user's system outside the project directory, and it must be transparent.

---

## Edge cases

### Skill already installed but version is wrong

`/skills` shows the skill but the project benefits from a newer version. v0.2 does not upgrade in-place — write an FYI in LOG.md and proceed with the installed version. If the version mismatch is causing a real problem, that's an IMPORTANT note for the admin.

### Two phases need the same skill

Install once; the second phase's check finds it via `/skills` and proceeds.

### Network unavailable

`npx skills add` will fail. Treat as a BLOCKER with the actual error in the note. The phase pauses; non-dependent work continues.

### `npx skills` itself not available (no Node, etc.)

This should have surfaced at Stage A. If it manifests in Stage B, write a BLOCKER:

> **Issue:** Cannot install <skill> — `npx skills` is not available on this system.
> **What I need from you:** Install Node + `skills` CLI per https://skills.sh, or install the skill manually and confirm here.

---

## Cross-references

- `references/skill-discovery-process.md` — where Stage A produces `SKILLS-TO-INSTALL.md`
- `references/stage-mapping-heuristics.md` — Stage 1/2/3 mapping
- `references/native-claude-code-commands.md` — `/skills` and `/reload-plugins` details
- `references/autonomy-contract.md` Rule 8 — the skill stage transition gate
- `references/security-posture.md` — the install path's audit contract
