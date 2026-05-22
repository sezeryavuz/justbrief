# Changelog

All notable changes to this repo will be documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- Initial repository scaffolding.
- `brief-to-prod` skill (v0.2.0): turn a single brief (one markdown file or one detailed prompt) into a complete software project — planned, built, tested, and deployed autonomously. Integrates Claude Code native commands (`/goal`, `/reload-plugins`, `/context`, `/compact`, `/clear`, `/skills`) for autonomy and dynamic mid-execution skill installation. Stage A wraps its soft confirm in an opt-in question (up to 5 adaptive questions). Ships an explicit `references/security-posture.md` as an audit contract. Sub-agent and lifecycle-hook designs documented for v0.3 (deferred).

### Changed
- `brief-to-prod` evolved from v0.1.0 to v0.2.0: SKILL.md workflow descriptions reference native commands; `scripts/validate-brief.sh` hardened with `set -euo pipefail`, per-block comments, and documented exit codes; reference index expanded and regrouped.
- Repo layout: moved skills under a `skills/` wrapper folder (`brief-to-prod/` → `skills/brief-to-prod/`) to match the skills.sh convention used by `obra/superpowers`, `anthropics/skills`, and `vercel-labs/agent-skills`. The skills.sh web index expects this layout; flat layouts at repo root install via the CLI but don't render on the site. CLI install command unchanged: `npx skills add sezeryavuz/justbrief --skill brief-to-prod`.
