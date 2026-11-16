#!/usr/bin/env bash
# Usage: scripts/build-agensi.sh
# Checks every skill against the Agensi packaging rules and writes one ZIP per
# skill (one Agensi listing each) to dist/. Exit 1 if any check fails.
#
# Skills keep short names in the repo (the Claude Code plugin namespaces them,
# e.g. /devflow:commit). Agensi names must be unique across the platform, so
# each ZIP's folder and frontmatter name get AGENSI_PREFIX (devflow-commit).
set -uo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
dist="$root/dist"
AGENSI_PREFIX="devflow-"
MAX_SCRIPT_BYTES=20480
MAX_FILES=200
MAX_SUMMARY=300
MAX_NAME=60

if [ -x "$root/scripts/sync-shared.sh" ]; then
  "$root/scripts/sync-shared.sh" --check || exit 1
fi

rm -rf "$dist"
mkdir -p "$dist"
failed=0

fail() {
  echo "  FAIL: $1"
  failed=1
}

frontmatter() {
  awk 'NR == 1 { if ($0 != "---") exit; next } $0 == "---" { exit } { print }' "$1"
}

field() {
  printf '%s\n' "$1" | grep "^$2:" | head -n 1 | sed "s/^$2:[[:space:]]*//"
}

check_skill() {
  local dir="$1" name="$2" md="$1/SKILL.md"
  [ -f "$md" ] || { fail "no SKILL.md"; return; }

  local fm
  fm="$(frontmatter "$md")"
  for key in name description summary version tags keywords use_cases; do
    printf '%s\n' "$fm" | grep -q "^$key:" || fail "frontmatter has no '$key'"
  done
  [ "$(field "$fm" name)" = "$name" ] || fail "frontmatter name doesn't match folder '$name'"
  local summary
  summary="$(field "$fm" summary)"
  [ "${#summary}" -le "$MAX_SUMMARY" ] || fail "summary is ${#summary} characters (max $MAX_SUMMARY)"
  grep -q '^Requires:' "$md" || fail "no 'Requires:' line in SKILL.md"

  # Install paths and other skills' files don't exist on Agensi. allowed-tools
  # is Claude Code-only frontmatter, so it may use CLAUDE_SKILL_DIR.
  grep -rnE '\$\{CLAUDE_SKILL_DIR\}|\.\./|/Users/|/home/|~/\.claude' "$dir" |
    grep -v ':allowed-tools:' && fail "install-specific or cross-skill paths (above)"

  # Every file a skill mentions must be inside the skill.
  local ref
  for ref in $(grep -rhoE '(references|scripts|templates)/[A-Za-z0-9._/-]+\.(md|sh|py|js|json|txt)' "$dir" | sort -u); do
    [ -f "$dir/$ref" ] || fail "mentions $ref, which isn't in the skill"
  done

  grep -rnEi 'ignore (all )?previous instructions|curl[^|]*\|[[:space:]]*(ba|z)?sh|chmod 777|shell=True|os\.system' "$dir" &&
    fail "security-scan pattern (above)"

  local script size
  for script in "$dir"/scripts/*; do
    [ -f "$script" ] || continue
    size=$(wc -c <"$script" | tr -d ' ')
    [ "$size" -le "$MAX_SCRIPT_BYTES" ] || fail "$(basename "$script") is $size bytes (max $MAX_SCRIPT_BYTES)"
  done

  local count
  count=$(find "$dir" -type f ! -name SKILL.md ! -name .DS_Store | wc -l | tr -d ' ')
  [ "$count" -le "$MAX_FILES" ] || fail "$count supporting files (max $MAX_FILES)"
}

for dir in "$root"/plugins/*/skills/*/; do
  dir="${dir%/}"
  name="$(basename "$dir")"
  echo "== $name"
  before=$failed
  failed=0
  check_skill "$dir" "$name"
  listing="$AGENSI_PREFIX$name"
  [ "${#listing}" -le "$MAX_NAME" ] || fail "Agensi name '$listing' is over $MAX_NAME characters"
  if [ "$failed" -eq 0 ]; then
    version="$(field "$(frontmatter "$dir/SKILL.md")" version)"
    stage="$(mktemp -d)"
    cp -R "$dir" "$stage/$listing"
    awk -v name="$listing" '
      NR == 1 { in_fm = ($0 == "---"); print; next }
      in_fm && $0 == "---" { in_fm = 0 }
      in_fm && /^name:/ { print "name: " name; next }
      { print }' "$dir/SKILL.md" >"$stage/$listing/SKILL.md"
    (cd "$stage" && zip -qrX "$dist/$listing-$version.zip" "$listing" -x '*.DS_Store')
    rm -rf "$stage"
    echo "  OK -> dist/$listing-$version.zip"
  fi
  [ "$before" -eq 1 ] && failed=1
done

if [ "$failed" -ne 0 ]; then
  echo "Some skills failed. Fix them before uploading."
  exit 1
fi
echo "All skills passed."
