#!/usr/bin/env bash
# hub.sh — single entry point: load every skill module in this directory.
#
# Usage (recommended for full toolbox):
#   source /path/to/skills/hub.sh
#
# Loads, in order:
#   1. env-sync.sh — .env.local, syncenv / syncccip / syncday
#   2. git-branch-workflow.sh — cleanbranches, cleanorphans
#   3. networking-workflow.sh — myip
#   4. Any other *.sh here except hub.sh (sorted by path), so new skills are picked up automatically.
#
# For env-sync only (no git/network helpers), source env-sync.sh directly.

# --- Resolve skills repo root (same logic as env-sync.sh) --------------------
if [[ -z "${SKILLS_ROOT:-}" ]]; then
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    eval 'SKILLS_ROOT="$(cd "$(dirname "${(%):-%x}")" && pwd)"'
  elif [[ -n "${BASH_SOURCE[0]:-}" ]]; then
    SKILLS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  else
    SKILLS_ROOT="$(cd "$(dirname "$0")" && pwd)"
  fi
fi

# Core modules in a stable order (env-sync must run first so .env.local applies).
_skills_hub_ordered=(
  env-sync.sh
  git-branch-workflow.sh
  networking-workflow.sh
)
for _skills_hub_m in "${_skills_hub_ordered[@]}"; do
  _skills_hub_p="$SKILLS_ROOT/$_skills_hub_m"
  if [[ -f "$_skills_hub_p" ]]; then
    # shellcheck source=/dev/null
    source "$_skills_hub_p"
  fi
done

# Additional *.sh files (e.g. future modules) without editing this list.
if [[ -d "$SKILLS_ROOT" ]]; then
  while IFS= read -r _skills_hub_p; do
    [[ -z "$_skills_hub_p" ]] && continue
    _skills_hub_b=$(basename "$_skills_hub_p")
    [[ "$_skills_hub_b" == "hub.sh" ]] && continue
    case "$_skills_hub_b" in
      env-sync.sh|git-branch-workflow.sh|networking-workflow.sh) continue ;;
    esac
    # shellcheck source=/dev/null
    source "$_skills_hub_p"
  done < <(
    find "$SKILLS_ROOT" -maxdepth 1 -type f -name '*.sh' 2>/dev/null |
      LC_ALL=C sort
  )
fi

unset _skills_hub_m _skills_hub_p _skills_hub_b _skills_hub_ordered
