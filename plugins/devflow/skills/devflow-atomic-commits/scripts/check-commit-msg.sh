#!/usr/bin/env bash
# Usage: check-commit-msg.sh <message-file>
# Checks a commit message against the Conventional Commits rules used by the
# devflow-atomic-commits skill. Prints every problem found. Exit 1 on errors.
set -uo pipefail

file="${1:-}"
if [ -z "$file" ] || [ ! -f "$file" ]; then
  echo "Usage: check-commit-msg.sh <message-file>"
  exit 2
fi

MAX_TITLE=72
MAX_LINE=72
TYPES="feat|fix|build|chore|ci|docs|perf|refactor|revert|style|test"

errors=0
warnings=0
error() { echo "ERROR: $1"; errors=$((errors + 1)); }
warn() { echo "WARN:  $1"; warnings=$((warnings + 1)); }

# Read lines, dropping git comment lines.
lines=()
while IFS= read -r line || [ -n "$line" ]; do
  [[ "$line" == \#* ]] && continue
  lines+=("$line")
done <"$file"

if [ "${#lines[@]}" -eq 0 ] || [ -z "${lines[0]}" ]; then
  echo "ERROR: empty commit message (or it starts with a blank line)"
  exit 1
fi

title="${lines[0]}"
title_re="^($TYPES)(\([a-z0-9._/-]+\))?(!)?: (.+)$"

if [[ "$title" =~ $title_re ]]; then
  description="${BASH_REMATCH[4]}"
  has_bang="${BASH_REMATCH[3]}"
  [[ "$description" == " "* ]] && error "title: only one space after ': '"
  [[ "$description" =~ \.$ ]] && error "title: no trailing period"
  [[ "$description" =~ ^[A-Z][a-z] ]] && error "title: description should start lowercase ('${description%% *}')"
  first_word="${description%% *}"
  [[ "$first_word" =~ ^[a-z]+(ed|ing)$ ]] &&
    warn "title: use the imperative mood ('add', not '$first_word')"
else
  has_bang=""
  error "title must match '<type>[(scope)][!]: <description>' with type one of: ${TYPES//|/, }
       got: '$title'"
fi

if [ "${#title}" -gt "$MAX_TITLE" ]; then
  error "title is ${#title} characters (max $MAX_TITLE)"
fi

if [ "${#lines[@]}" -gt 1 ] && [ -n "${lines[1]}" ]; then
  error "line 2 must be blank (separates title from body/footer)"
fi

has_breaking_footer=0
for ((i = 1; i < ${#lines[@]}; i++)); do
  line="${lines[$i]}"
  if [[ "$line" =~ ^(BREAKING[\ -]CHANGE):\  ]]; then
    has_breaking_footer=1
  fi
  if [[ "$line" =~ ^[Cc]o-[Aa]uthored-[Bb]y: ]] || [[ "$line" =~ [Gg]enerated\ with ]]; then
    error "line $((i + 1)): attribution lines are not allowed ('$line')"
  fi
  if [ "${#line}" -gt "$MAX_LINE" ] && [[ ! "$line" =~ https?:// ]]; then
    warn "line $((i + 1)) is ${#line} characters (wrap at $MAX_LINE)"
  fi
done

if [ -n "$has_bang" ] && [ "$has_breaking_footer" -eq 0 ]; then
  warn "title has '!' but no 'BREAKING CHANGE:' footer explaining what consumers must change"
fi

if [ "$errors" -gt 0 ]; then
  echo "$errors error(s), $warnings warning(s). Fix the errors before committing."
  exit 1
fi
if [ "$warnings" -gt 0 ]; then
  echo "OK ($warnings warning(s))"
else
  echo "OK"
fi
