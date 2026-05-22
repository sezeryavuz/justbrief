#!/usr/bin/env bash
# validate-brief.sh — sanity-check a brief input for brief-to-prod
#
# Usage:
#   scripts/validate-brief.sh [path/to/brief.md]
#
# Default path: ./brief.md (then BRIEF/brief.md as fallback).
#
# Exit codes:
#   0 — brief found and passed all required checks (warnings allowed)
#   1 — brief found but failed a required check (e.g. too short to be useful)
#   2 — brief file not found at default or supplied path
#   3 — reserved for future use (argument or environment error)
#
# Output:
#   Human-readable findings on stdout. Each finding is prefixed:
#     [OK]      — passed
#     [WARN]    — non-blocking; the skill should surface in the Stage A soft confirm
#     [FAIL]    — blocking; must be resolved before Stage B begins
#
# Audit posture (see references/security-posture.md):
#   - The script reads the brief file only. It does not read other files.
#   - It does not make network calls.
#   - It does not modify any files.
#   - Every external command (wc, tr, grep, echo) is a standard POSIX utility.
#   - The script is short and meant to be readable top-to-bottom by an auditor.
#
# This script is intentionally simple. Its purpose is to give the skill a quick
# objective signal about brief quality. The skill resolves WARN/FAIL items via
# the Stage A soft confirm and NOTES-TO-ADMIN.md.

# Strict mode: exit on error, exit on unset var, fail pipeline on any stage failure.
set -euo pipefail

# ---------------------------------------------------------------------------
# Resolve the brief path.
# Argument 1 (if present) wins. Otherwise auto-detect ./brief.md, then BRIEF/brief.md.
# ---------------------------------------------------------------------------
brief_path="${1:-}"

if [[ -z "$brief_path" ]]; then
  if [[ -f "./brief.md" ]]; then
    brief_path="./brief.md"
  elif [[ -f "./BRIEF/brief.md" ]]; then
    brief_path="./BRIEF/brief.md"
  fi
fi

if [[ -z "$brief_path" ]]; then
  # Exit 2: no brief at all (default paths empty, no argument supplied).
  echo "[FAIL] No brief path provided and ./brief.md / ./BRIEF/brief.md not found." >&2
  exit 2
fi

if [[ ! -f "$brief_path" ]]; then
  # Exit 2: a path was given/found but the file doesn't exist.
  echo "[FAIL] Brief file not found: $brief_path" >&2
  exit 2
fi

echo "[OK] Found brief at: $brief_path"

# ---------------------------------------------------------------------------
# Word count check. Too short → FAIL (sets `fail` flag). Out-of-range → WARN.
# ---------------------------------------------------------------------------
# Track whether any [FAIL] occurred. 0 = clean, 1 = at least one fail.
fail=0

word_count=$(wc -w < "$brief_path" | tr -d ' ')

if [[ "$word_count" -lt 100 ]]; then
  echo "[FAIL] Brief is very short ($word_count words). Need at least ~100 words to derive a useful foundation."
  fail=1
elif [[ "$word_count" -lt 200 ]]; then
  echo "[WARN] Brief is short ($word_count words). Soft confirm will need to fill substantial gaps."
elif [[ "$word_count" -gt 3000 ]]; then
  echo "[WARN] Brief is long ($word_count words). Consider splitting into brief.md + an appendix for spec depth."
else
  echo "[OK] Word count ($word_count) is in the comfortable range."
fi

# ---------------------------------------------------------------------------
# Topic-coverage heuristic.
# Lowercase the brief once so each check_keyword call is a single grep pass.
# `check_keyword <label> <keyword1> [<keyword2> ...]` prints OK if any keyword
# is present, WARN otherwise.
# ---------------------------------------------------------------------------
content=$(tr '[:upper:]' '[:lower:]' < "$brief_path")

check_keyword() {
  local label="$1"
  shift
  local found=0
  local keyword
  for keyword in "$@"; do
    # `grep -F` so keywords are treated as fixed strings (not regex).
    # `|| true` prevents `set -e` from killing the loop on a non-match.
    if printf '%s' "$content" | grep -qF "$keyword"; then
      found=1
      break
    fi
  done
  if [[ "$found" -eq 1 ]]; then
    echo "[OK] Brief mentions $label."
  else
    echo "[WARN] Brief may not cover $label clearly. Soft confirm should probe."
  fi
}

check_keyword "what is being built" "build" "ship" "create" "make" "app" "service" "tool" "platform" "system"
check_keyword "audience or user" "user" "customer" "audience" "team" "client" "consumer" "developer"
check_keyword "scope or features" "feature" "scope" "mvp" "v1" "requirement" "must" "should"
check_keyword "stack or tech preferences" "stack" "framework" "language" "library" "react" "next" "python" "node" "go " "rust" "postgres" "database"
check_keyword "deploy target or hosting" "deploy" "hosting" "vercel" "aws" "gcp" "fly" "railway" "cloudflare" "self-host" "on-prem"

# ---------------------------------------------------------------------------
# Contradiction heuristic.
# Detect the obvious tension: brief says "must be free" yet names paid services.
# Cheap, not exhaustive; the soft confirm is the real resolver.
# ---------------------------------------------------------------------------
if printf '%s' "$content" | grep -qE "(must be free|no cost|zero cost)" \
  && printf '%s' "$content" | grep -qE "(aws|gcp|datadog|snowflake)"; then
  echo "[WARN] Brief mentions free/no-cost AND services that typically incur cost. Verify in soft confirm."
fi

# ---------------------------------------------------------------------------
# Final exit. fail=1 → exit 1 (a required check failed). Else exit 0.
# ---------------------------------------------------------------------------
if [[ "$fail" -eq 1 ]]; then
  exit 1
fi

exit 0
