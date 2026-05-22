# Lifecycle hooks integration — design notes (deferred to v0.3)

v0.2 considered adding a `hooks/` folder with Claude Code lifecycle hooks that automate parts of the resume and checkpoint flow. The brief asks for the design to be recorded even when implementation is deferred. This file is that record.

**Status: DEFERRED to v0.3.** No `hooks/` folder ships in v0.2.

---

## Why defer

Hooks are a UX improvement, not a correctness improvement. The current Stage A/B/C flow works because:

- `CLAUDE.md` instructs every new session to read `LOG.md`'s last entry.
- The autonomy contract binds the agent to write LOG entries at significant moments.
- Stage C handoff is explicitly instructed.

Hooks would automate some of that work — but if they fail or aren't supported on the user's Claude Code version, the prose protocol still works. So hooks are an optimization layer.

Adding them now would mean:

- Defining hook scripts (JSON or shell)
- Documenting fallback for users on Claude Code versions without hook support
- Updating the security posture file (hooks run automatically; that's a new behavior surface)
- Testing with real Claude Code session lifecycle events

That's enough surface area to defer to v0.3 per the brief's guidance.

---

## Planned `hooks/` folder layout

When v0.3 picks this up:

```
brief-to-prod/
└── hooks/
    ├── session-start.sh         # Inject last LOG entry on session start
    ├── user-prompt-submit.sh    # If prompt is "continue", inject resume context
    ├── post-tool-use.sh         # Optional: checkpoint after significant tool use
    ├── hooks.json               # Claude Code hooks manifest
    └── README.md                # When each hook fires and why
```

Each hook is small (10–40 lines of shell or JSON), well-commented, and surfaced explicitly in the security posture.

---

## Hook designs

### SessionStart — auto-inject last LOG entry

**Trigger:** Claude Code starts a new session in a directory containing brief-to-prod's CLAUDE.md.

**Behavior:** Read the last `## ` entry from LOG.md. If found, emit it as additional system context so the agent's first response already knows the resume point.

**Why this helps:** Saves the agent from explicitly running `tail -50 LOG.md` or similar on every new session. The handoff becomes nearly instantaneous.

**Pseudo-code:**
```bash
#!/usr/bin/env bash
set -euo pipefail
if [[ ! -f ./LOG.md ]]; then exit 0; fi
last_entry=$(awk '/^## /{section=""}{section = section "\n" $0}END{print section}' ./LOG.md)
echo "RESUME CONTEXT (from LOG.md last entry):"
echo "$last_entry"
```

### UserPromptSubmit — handle "continue" specifically

**Trigger:** User submits a prompt.

**Behavior:** If the prompt is literally `continue` (case-insensitive, trimmed), prepend the resume context (same content as SessionStart's output) before passing the prompt to the agent.

**Why this helps:** "Continue" is the canonical resume word per the autonomy contract. Treating it specially makes the resume mechanic reflex-fast.

### PostToolUse — checkpoint after significant tool use

**Trigger:** After certain tool calls (e.g. test runs, build invocations).

**Behavior:** If a phase-end verification command just completed successfully, append a `Phase N verified` line to LOG.md automatically.

**Why this helps:** Reduces the chance of forgetting to log a verification result. Not strictly necessary — the autonomy contract already requires manual logging — but defense-in-depth.

This one is the most invasive; v0.3 should evaluate whether it's worth shipping or whether the LOG protocol alone suffices.

---

## Security implications

Hooks execute automatically. That makes them a new surface that needs to be in `security-posture.md`:

- All hooks must follow the same "scripts are auditable" rule (shebang, `set -euo pipefail`, comments per block).
- All hooks must follow "commands are visible" — every command the hook runs is logged somewhere the user can see.
- Hooks may not introduce new network calls beyond what `security-posture.md` already permits.
- Hooks may not read files outside the project root.

v0.3's PR adding hooks will update `security-posture.md` accordingly.

---

## Fallback if Claude Code version doesn't support hooks

The user runs an older Claude Code without hook support. The `hooks.json` is simply ignored. The skill works exactly as it does in v0.2 — by virtue of the prose protocol in `references/`. No regression.

---

## What v0.2 already does that v0.3 builds on

Same as the sub-agent design: the autonomy contract (rule 4: LOG.md's last entry is the resume point) is the protocol the hooks would automate. v0.2 establishes the contract; v0.3 mechanizes it.

---

## Open questions for v0.3

- Are hooks per-project (committed to the user's repo as `.claude/hooks/`) or per-skill (installed alongside the skill)? Likely the latter — the skill ships the hook scripts, Claude Code picks them up when the skill is installed.
- How are hooks uninstalled when the skill is uninstalled? Claude Code's plugin lifecycle should handle this; verify before shipping.
- Should hooks be opt-in (off by default, user enables) or opt-out (on by default, user disables)? Lean opt-out — the skill is opinionated, hooks reinforce its opinions.

---

## Cross-references

- `references/native-claude-code-commands.md` — `/hooks` is the command for viewing configured hooks
- `references/log-protocol.md` — LOG entry mechanic that SessionStart and UserPromptSubmit would auto-trigger
- `references/security-posture.md` — will be updated when v0.3 ships hooks
- `references/autonomy-contract.md` Rule 4 — what these hooks formalize

The two reference-skill files most relevant to this design are not in `.workspace/reference-skills/` for v0.2, but v0.3 should look at Claude Code's own hooks documentation and the `hookify` plugin patterns before implementing.
