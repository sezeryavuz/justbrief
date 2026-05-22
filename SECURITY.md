# Security Policy

## Reporting

If you believe you've found a security concern in a justbrief skill — or any helper script published in this repo — please email **sezer@modulex.dev** rather than opening a public issue.

We'll respond as quickly as we can.

## Trust model

Skills in this repo are markdown plus, occasionally, small helper scripts. They run inside whatever AI coding agent installs them (Claude Code, Cursor, Codex, Windsurf, etc.). The same trust model that applies to any open-source repo applies here: read the skill before letting an agent run it.

## Automated checks

[skills.sh](https://www.skills.sh) runs automated checks on skills installed through the `skills` CLI. Those checks complement, but don't replace, reviewing what a skill does before running it.
