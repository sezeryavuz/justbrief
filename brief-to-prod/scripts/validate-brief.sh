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
#   1 — brief found but failed a required check
#   2 — brief file not found
#   3 — argument or environment error
#
# Output:
#   Human-readable findings on stdout. Each finding is prefixed:
#     [OK]      — passed
#     [WARN]    — non-blocking; surface in soft confirm
#     [FAIL]    — blocking; must be resolved before Stage B
#
# This script is intentionally simple. Its purpose is to give the skill a quick
# objective signal about brief quality. The skill resolves WARN/FAIL items via
# the Stage A soft confirm and NOTES-TO-ADMIN.md.

set -u

brief_path="${1:-}"

# Auto-detect if no argument given
if [[ -z "$brief_path" ]]; then
  if [[ -f "./brief.md" ]]; then
    brief_path="./brief.md"
  elif [[ -f "./BRIEF/brief.md" ]]; then
    brief_path="./BRIEF/brief.md"
  fi
fi

if [[ -z "$brief_path" ]]; then
  echo "[FAIL] No brief path provided and ./brief.md / ./BRIEF/brief.md not found." >&2
  exit 2
fi

if [[ ! -f "$brief_path" ]]; then
  echo "[FAIL] Brief file not found: $brief_path" >&2
  exit 2
fi

echo "[OK] Found brief at: $brief_path"

# --- Word count ---
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

# --- Indicators that the brief covers required topics ---
content=$(tr '[:upper:]' '[:lower:]' < "$brief_path")

check_keyword() {
  local label="$1"
  shift
  local found=0
  for keyword in "$@"; do
    if echo "$content" | grep -q "$keyword"; then
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
check_keyword "stack or tech preferences" "stack" "framework" "language" "language" "library" "react" "next" "python" "node" "go " "rust" "postgres" "database"
check_keyword "deploy target or hosting" "deploy" "hosting" "vercel" "aws" "gcp" "fly" "railway" "cloudflare" "self-host" "on-prem"

# --- Contradiction heuristic (cheap) ---
# Look for obvious tension like "free" + paid-tier-only services
if echo "$content" | grep -qE "(must be free|no cost|zero cost)" && echo "$content" | grep -qE "(aws|gcp|datadog|snowflake)"; then
  echo "[WARN] Brief mentions free/no-cost AND services that typically incur cost. Verify in soft confirm."
fi

if [[ "${fail:-0}" -eq 1 ]]; then
  exit 1
fi

exit 0
