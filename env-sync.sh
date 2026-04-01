#!/usr/bin/env bash
# env-sync.sh — portable helpers to run repo env sync scripts from any cwd.
#
# Usage (recommended): add to your shell rc:
#   source /path/to/skills/env-sync.sh
#
# Optional local config: copy `.env.example` → `.env.local` in this directory.
# Variables there are exported when you source this file (see README.md).
#
# Configure the target repo either:
#   1) ENV_SYNC_PROJECT_ROOT — absolute path (overrides 2)
#   2) ENV_SYNC_WORKSPACE + ENV_SYNC_PROJECT — workspace dir + project folder name
#
# Example ~/.zshrc (without .env.local):
#   export ENV_SYNC_WORKSPACE="$HOME/Developer"
#   export ENV_SYNC_PROJECT="algobot-webapp-ui"
#   source "$HOME/Developer/skills/env-sync.sh"
#
# Migrating from ALGO_BOT_ROOT: set ENV_SYNC_PROJECT_ROOT in .env.local or shell rc.

# --- Resolve skills repo root (directory containing this file) --------------
# Zsh branch uses eval so Bash never parses ${(%):-%x}. Check Zsh first when sourced from Zsh.
if [[ -z "${SKILLS_ROOT:-}" ]]; then
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    eval 'SKILLS_ROOT="$(cd "$(dirname "${(%):-%x}")" && pwd)"'
  elif [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    SKILLS_ROOT="$(cd "$(dirname "$0")" && pwd)"
  fi
fi

# --- Load optional local overrides (.env.local) ------------------------------
_skills_env_file="${SKILLS_ENV_FILE:-$SKILLS_ROOT/.env.local}"
if [[ -f "$_skills_env_file" ]]; then
  # shellcheck source=/dev/null
  set -a
  # shellcheck source=/dev/null
  source "$_skills_env_file"
  set +a
fi
unset _skills_env_file

# --- User / machine configuration (defaults; .env.local may set above) -----
ENV_SYNC_WORKSPACE="${ENV_SYNC_WORKSPACE:-$HOME/workspace}"
ENV_SYNC_PROJECT="${ENV_SYNC_PROJECT:-algobot-webapp-ui}"
ENV_SYNC_PROJECT_ROOT="${ENV_SYNC_PROJECT_ROOT:-}"

_env_sync_resolve_root() {
  local root="${ENV_SYNC_PROJECT_ROOT:-$ENV_SYNC_WORKSPACE/$ENV_SYNC_PROJECT}"
  if [[ ! -d "$root" ]]; then
    echo "[env-sync] Error: project root is not a directory: $root" >&2
    echo "[env-sync] Set ENV_SYNC_PROJECT_ROOT or ENV_SYNC_WORKSPACE + ENV_SYNC_PROJECT" >&2
    echo "[env-sync] (e.g. in $SKILLS_ROOT/.env.local — copy from .env.example)." >&2
    return 1
  fi
  printf '%s\n' "$root"
}

syncenv() {
  local root
  root="$(_env_sync_resolve_root)" || return 1
  (
    cd "$root" || exit 1
    if [[ ! -f scripts/sync-to-env-local.sh ]]; then
      echo "[env-sync] Error: missing scripts/sync-to-env-local.sh under $root" >&2
      exit 1
    fi
    bash scripts/sync-to-env-local.sh
  )
}

syncccip() {
  local root
  root="$(_env_sync_resolve_root)" || return 1
  (
    cd "$root" || exit 1
    if [[ ! -f scripts/sync-command-center-lan.sh ]]; then
      echo "[env-sync] Error: missing scripts/sync-command-center-lan.sh under $root" >&2
      exit 1
    fi
    bash scripts/sync-command-center-lan.sh
  )
}

# Daily: env file sync + command center LAN hints
alias syncday='syncenv && syncccip'
