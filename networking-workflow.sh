#!/usr/bin/env bash
# networking-workflow.sh — small network-related shell helpers.
#
# Loaded automatically when you source env-sync.sh (same SKILLS_ROOT / .env.local).
#
# Environment (optional, set in skills/.env.local):
#   SKILLS_MYIP_URL — URL that returns plain-text public IP (default below)

SKILLS_MYIP_URL="${SKILLS_MYIP_URL:-http://ipecho.net/plain}"

myip() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "[skills] myip: curl is required" >&2
    return 1
  fi
  curl -fsS "$SKILLS_MYIP_URL" && echo
}
