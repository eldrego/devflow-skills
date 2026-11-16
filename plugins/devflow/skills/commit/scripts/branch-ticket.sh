#!/usr/bin/env bash
# Usage: branch-ticket.sh [branch-name]
# Prints the ticket reference found in the branch name (e.g. "SB-142" or "#123"),
# or nothing if there is none. Defaults to the current branch.
#
# Optional: restrict Jira-style matches to known project keys with
#   git config devflow.ticketKeys "SB,STREAM"
set -uo pipefail

branch="${1:-$(git branch --show-current 2>/dev/null)}"
[ -z "$branch" ] && exit 0 # detached HEAD or not a repo

# Bot branches never carry tickets.
case "$branch" in
  dependabot/* | renovate/*) exit 0 ;;
esac

# Words that look like Jira keys in lowercase branches but aren't.
NOT_KEYS="feat feature features fix fixes bugfix bug hotfix chore release releases
docs doc refactor test tests perf style build ci revert wip spike task tasks
issue issues gh pr node v vite react next nx es ts js python java api ui ux
mf mfe"
NOT_KEYS=" $(printf '%s' "$NOT_KEYS" | tr '\n' ' ') "

allowed_keys="$(git config --get devflow.ticketKeys 2>/dev/null | tr '[:lower:]' '[:upper:]' | tr -d ' ')"

is_allowed_key() {
  local key="$1"
  if [ -n "$allowed_keys" ]; then
    [[ ",$allowed_keys," == *",$key,"* ]]
  else
    local lower
    lower="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')"
    [[ "$NOT_KEYS" != *" $lower "* ]]
  fi
}

# 1. Uppercase Jira-style key anywhere: SB-142, PROJ2-88.
rest="$branch"
while [[ "$rest" =~ (^|[^A-Za-z0-9])([A-Z][A-Z0-9]+)-([0-9]+) ]]; do
  key="${BASH_REMATCH[2]}"
  if is_allowed_key "$key"; then
    echo "$key-${BASH_REMATCH[3]}"
    exit 0
  fi
  rest="${rest#*"${BASH_REMATCH[0]}"}"
done

# 2. Lowercase Jira-style key at the start of a path segment: feat/sb-142-x.
IFS='/' read -r -a segments <<<"$branch"
for segment in "${segments[@]}"; do
  if [[ "$segment" =~ ^([a-z][a-z0-9]+)-([0-9]+)([-_]|$) ]]; then
    key="$(printf '%s' "${BASH_REMATCH[1]}" | tr '[:lower:]' '[:upper:]')"
    if is_allowed_key "$key"; then
      echo "$key-${BASH_REMATCH[2]}"
      exit 0
    fi
  fi
done

# 3. GitHub issue number.
#    issue-45, issues/45, gh-45, #45, or a segment starting with digits (123-fix).
if [[ "$branch" =~ (^|/)(issues?|gh)[-/]([0-9]+)([-_/]|$) ]]; then
  echo "#${BASH_REMATCH[3]}"
  exit 0
fi
if [[ "$branch" =~ (^|/)#?([0-9]+)([-_]|$) ]]; then
  echo "#${BASH_REMATCH[2]}"
  exit 0
fi

exit 0
