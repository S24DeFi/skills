#!/usr/bin/env bash
# git-branch-workflow.sh — portable git branch cleanup helpers.
#
# Loaded automatically when you source env-sync.sh (same SKILLS_ROOT / .env.local).
# Or source this file after setting SKILLS_ROOT and optionally loading .env.local.
#
# Environment (optional, set in skills/.env.local):
#   SKILLS_GIT_REMOTE           — default: origin
#   SKILLS_PROTECTED_BRANCHES   — space-separated branch names never deleted as orphans
#                                 default: master main

SKILLS_GIT_REMOTE="${SKILLS_GIT_REMOTE:-origin}"

_skills_list_local_branches() {
  git for-each-ref refs/heads/ --format='%(refname:short)' 2>/dev/null
}

_skills_is_protected() {
  local branch="$1"
  local tok
  # shellcheck disable=SC2086
  for tok in ${SKILLS_PROTECTED_BRANCHES:-master main}; do
    [[ -z "$tok" ]] && continue
    [[ "$branch" == "$tok" ]] && return 0
  done
  return 1
}

cleanbranches() {
  local remote current_branch total_orphaned gone_branches
  remote="$SKILLS_GIT_REMOTE"

  git fetch --prune
  printf 'Checking for branches to clean up...\n'

  gone_branches=$(git branch -vv | grep '\[gone\]' | awk '{print $1}' || true)
  if [[ -n "$gone_branches" ]]; then
    # shellcheck disable=SC2086
    echo "$gone_branches" | xargs git branch -D
    printf 'Cleaned up tracked branches that were deleted from remote\n'
  fi

  current_branch=$(git branch --show-current)

  while IFS= read -r branch; do
    [[ -z "$branch" ]] && continue
    if [[ "$branch" == "$current_branch" ]]; then
      continue
    fi
    if _skills_is_protected "$branch"; then
      continue
    fi
    if ! git ls-remote --heads "$remote" "refs/heads/$branch" 2>/dev/null | grep -q "$branch"; then
      printf '  Orphaned: %s\n' "$branch"
    fi
  done < <(_skills_list_local_branches)

  total_orphaned=0
  while IFS= read -r branch; do
    [[ -z "$branch" ]] && continue
    if [[ "$branch" == "$current_branch" ]]; then
      continue
    fi
    if _skills_is_protected "$branch"; then
      continue
    fi
    if ! git ls-remote --heads "$remote" "refs/heads/$branch" 2>/dev/null | grep -q "$branch"; then
      total_orphaned=$((total_orphaned + 1))
    fi
  done < <(_skills_list_local_branches)

  if [[ "$total_orphaned" -gt 0 ]]; then
    printf '\nFound %d local branch(es) not on remote %s.\n' "$total_orphaned" "$remote"
    printf 'Run "cleanorphans" to delete them.\n'
  else
    printf 'No orphaned branches found.\n'
  fi
}

cleanorphans() {
  local remote current_branch
  remote="$SKILLS_GIT_REMOTE"
  current_branch=$(git branch --show-current)

  while IFS= read -r branch; do
    [[ -z "$branch" ]] && continue
    if [[ "$branch" == "$current_branch" ]]; then
      continue
    fi
    if _skills_is_protected "$branch"; then
      continue
    fi
    if ! git ls-remote --heads "$remote" "refs/heads/$branch" 2>/dev/null | grep -q "$branch"; then
      git branch -D "$branch" && printf 'Deleted: %s\n' "$branch"
    fi
  done < <(_skills_list_local_branches)

  printf 'Orphaned branches cleanup complete\n'
}
