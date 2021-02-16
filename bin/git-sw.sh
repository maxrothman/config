#!/usr/bin/env bash
set -euo pipefail

# Switch your current work to a new branch
usage="Usage: git-sw [-n|--no-stash] <branch> [since]
  branch: the name of the branch to switch to
  since: move all commits after this one"

stash=true
# Parse args
if [[ "${1:-}" == -* ]]; then
  if [ "$1" = "-n" ] || [ "$1" = "--no-stash" ]; then
    stash=false
  else
    echo "Invalid argument $1"
    exit 1
  fi
  shift
fi

branch="${1:-}"
if [ -z "$branch" ]; then
  echo "$usage"
  exit 2
fi
since="${2:-@{u\}}"

# If there's no commits to move, do nothing
if [ -z "$(git rev-list "$since"..)" ]; then
  echo "No commits to move!"
  exit 0
fi

# If the branch doesn't exist, create it
set +e
"$(git rev-parse --verify "$branch")" >/dev/null 2>/dev/null
result="$?"
set -e

if [ "$result" -gt 0 ]; then
  git branch "$branch"
else
  echo "Branch $branch already exists"
  exit 1
fi

if [ -n "$(git status --porcelain)" ] && [ "$stash" = true ]; then
  echo "Stashing untracked changes..."
  git stash --include-untracked
  stashed=true
fi

git reset --hard "$since"
git checkout "$branch"

if [ stashed = true ]; then
  git stash pop
fi

