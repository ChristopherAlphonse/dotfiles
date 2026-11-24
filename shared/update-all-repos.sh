# --------------------------------------------------
# update-all-repos: parallel fetch + fast-forward across all repos under cwd
# --------------------------------------------------
#
# Safety model (mirrors gitlab-mirror-groups.sh):
#   - Never checkout, stash, merge, or rebase the branch you have checked
#     out. Dirty trees are fetched only and reported, never touched further.
#   - All updates are fast-forward only (git merge --ff-only); a diverged
#     branch is reported and left as-is, never merged/rebased/force-updated.
#   - On a feature branch or detached HEAD, the default branch is still
#     fast-forwarded underneath it (advancing a ref that isn't checked out
#     never touches the working tree), so it's ready to merge whenever.
#   - Empty repos (no commits yet) are skipped.

# Colors for per-repo status lines and end-of-run summaries. Only emitted
# when stdout is a terminal, so redirected/piped output stays clean.
if [[ -t 1 ]]; then
  UAR_GREEN=$'\033[0;32m'
  UAR_YELLOW=$'\033[0;33m'
  UAR_RED=$'\033[0;31m'
  UAR_CYAN=$'\033[0;36m'
  UAR_GRAY=$'\033[0;90m'
  UAR_RESET=$'\033[0m'
else
  UAR_GREEN=""
  UAR_YELLOW=""
  UAR_RED=""
  UAR_CYAN=""
  UAR_GRAY=""
  UAR_RESET=""
fi
export UAR_GREEN UAR_YELLOW UAR_RED UAR_CYAN UAR_GRAY UAR_RESET

# Resolve a repo's default branch from the remote's advertised HEAD, with a
# refresh if the recorded ref is unset or dangling (e.g. the remote renamed
# its default branch and the old one was pruned).
_uar_default_branch() {
  local repo="$1" def
  def="$(git -C "$repo" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"
  def="${def#origin/}"
  if [[ -z "$def" ]] || ! git -C "$repo" show-ref --verify --quiet "refs/remotes/origin/$def"; then
    git -C "$repo" remote set-head origin --auto >/dev/null 2>&1
    def="$(git -C "$repo" symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)"
    def="${def#origin/}"
  fi
  printf '%s' "$def"
}

# True if the working tree has staged/unstaged changes. Untracked files
# don't block a fast-forward, so they're intentionally not checked here.
_uar_is_dirty() {
  local repo="$1"
  ! { git -C "$repo" diff --quiet && git -C "$repo" diff --cached --quiet; }
}

# Fast-forward the checked-out branch to its upstream, only if clean and
# only if the update actually is a fast-forward. No-op with no upstream.
# The branch name itself is colored: green when it ends up up to date,
# red when it's diverged and was left untouched.
_uar_ff_current_branch() {
  local repo="$1" branch="$2"
  if _uar_is_dirty "$repo"; then
    echo "${UAR_RED}[dirty]${UAR_RESET} local changes present, fetched only: $repo"
    echo "$repo" >> "$UAR_DIRTY_FILE"
    return
  fi
  if git -C "$repo" rev-parse --abbrev-ref '@{u}' >/dev/null 2>&1; then
    if git -C "$repo" merge --ff-only --quiet '@{u}' 2>/dev/null; then
      echo "${UAR_GREEN}[${branch}]${UAR_RESET} $repo"
    else
      echo "${UAR_RED}[${branch}]${UAR_RESET} diverged, left as-is: $repo"
    fi
  fi
}

# Update a single repo: fetch, then fast-forward the default branch and the
# checked-out branch, without ever switching branches, stashing, or merging.
_uar_update_one() {
  local repo="$1"
  local def current_branch

  if ! git -C "$repo" fetch --all --prune --quiet; then
    echo "${UAR_RED}[warn]${UAR_RESET} fetch failed: $repo"
    return
  fi

  if ! git -C "$repo" rev-parse --verify --quiet HEAD >/dev/null 2>&1; then
    echo "${UAR_GRAY}[empty]${UAR_RESET} no commits yet, skipped: $repo"
    return
  fi

  def="$(_uar_default_branch "$repo")"
  current_branch="$(git -C "$repo" branch --show-current 2>/dev/null)"

  if [[ -n "$def" && "$current_branch" == "$def" ]]; then
    _uar_ff_current_branch "$repo" "$def"
    return
  fi

  # Feature branch or detached HEAD: bring the default branch current
  # underneath it, then fast-forward the working branch too if it's clean.
  # The default branch name is colored the same way: green when advanced
  # cleanly, red when diverged and left as-is.
  if [[ -n "$def" ]] && git -C "$repo" show-ref --verify --quiet "refs/remotes/origin/$def"; then
    if git -C "$repo" fetch --quiet . "refs/remotes/origin/${def}:refs/heads/${def}" 2>/dev/null; then
      echo "${UAR_GREEN}[${def}]${UAR_RESET} updated underneath '${current_branch:-detached HEAD}': $repo"
    else
      echo "${UAR_RED}[${def}]${UAR_RESET} diverged, left as-is (underneath '${current_branch:-detached HEAD}'): $repo"
    fi
  fi

  if [[ -n "$current_branch" ]]; then
    _uar_ff_current_branch "$repo" "$current_branch"
  fi

  printf '%s\t%s\t%s\n' "$repo" "${current_branch:-detached HEAD}" "${def:-unknown}" >> "$UAR_WARN_FILE"
}

# Main entry point: find all repos under cwd and update them in parallel.
# Usage: update-all-repos [max_parallel_jobs]   (default 8)
update-all-repos() {
  local jobs="${1:-8}"
  local funcs warn_file dirty_file
  warn_file="$(mktemp "${TMPDIR:-/tmp}/update-all-repos-warn.XXXXXX")"
  dirty_file="$(mktemp "${TMPDIR:-/tmp}/update-all-repos-dirty.XXXXXX")"

  {
    export UAR_WARN_FILE="$warn_file" UAR_DIRTY_FILE="$dirty_file"
    funcs="$(typeset -f _uar_default_branch _uar_is_dirty _uar_ff_current_branch _uar_update_one)"

    find . -type d -name ".terraform" -prune -o -type d -name ".git" -print0 |
      xargs -0 -n1 -P"$jobs" -I{} zsh -c "$funcs"'
        repo=$(dirname "$1")
        _uar_update_one "$repo"
      ' _ {}

    if [[ -s "$warn_file" ]]; then
      echo
      echo "${UAR_RED}>> $(wc -l < "$warn_file" | tr -d '[:space:]') repo(s) on a non-default branch (default kept current underneath):${UAR_RESET}"
      sort "$warn_file" | while IFS=$'\t' read -r p cur def; do
        echo "${UAR_RED}   $p (on '$cur', default '$def')${UAR_RESET}"
      done
    fi

    if [[ -s "$dirty_file" ]]; then
      echo
      echo "${UAR_RED}>> $(wc -l < "$dirty_file" | tr -d '[:space:]') repo(s) with local changes (fetched only, not updated):${UAR_RESET}"
      sort -u "$dirty_file" | while IFS= read -r p; do
        echo "${UAR_RED}   $p${UAR_RESET}"
      done
    fi
  } always {
    command rm -f "$warn_file" "$dirty_file"
    unset UAR_WARN_FILE UAR_DIRTY_FILE
  }
}
