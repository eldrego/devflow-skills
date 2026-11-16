#!/usr/bin/env bash
# Usage: lint.sh <file> [file...]
# Runs whichever linters the current project is configured for, with safe
# auto-fixes, on the given files:
#   - Biome  (biome.json / biome.jsonc)          -> biome check --write
#   - ESLint (eslint.config.* / .eslintrc* / package.json "eslintConfig")
#                                                -> eslint --fix
# If both are configured, both run (some projects format with Biome and lint
# with ESLint). Never fails silently: always prints what happened.
set -uo pipefail

if [ "$#" -eq 0 ]; then
  echo "No files given. Usage: lint.sh <file> [file...]"
  exit 1
fi

has_biome_config() {
  [ -f biome.json ] || [ -f biome.jsonc ]
}

has_eslint_config() {
  compgen -G "eslint.config.*" >/dev/null || compgen -G ".eslintrc*" >/dev/null ||
    { [ -f package.json ] && grep -q '"eslintConfig"' package.json; }
}

ran_any=0
failed=0

if has_biome_config; then
  if npx --no-install biome --version >/dev/null 2>&1; then
    ran_any=1
    # Biome >= 1.8 uses --write; older versions use --apply.
    if npx --no-install biome check --help 2>/dev/null | grep -q -- '--write'; then
      fix_flag="--write"
    else
      fix_flag="--apply"
    fi
    echo "== Biome ($(npx --no-install biome --version)) =="
    if npx --no-install biome check "$fix_flag" "$@"; then
      echo "Biome: clean."
    else
      echo "Biome reported problems above."
      failed=1
    fi
  else
    echo "Found biome.json but Biome isn't installed (try: npm i -D @biomejs/biome)."
  fi
fi

if has_eslint_config; then
  if npx --no-install eslint --version >/dev/null 2>&1; then
    ran_any=1
    echo "== ESLint ($(npx --no-install eslint --version)) =="
    if npx --no-install eslint --fix "$@"; then
      echo "ESLint: clean."
    else
      echo "ESLint reported problems above."
      failed=1
    fi
  else
    echo "Found an ESLint config but ESLint isn't installed (try: npm install)."
  fi
fi

if [ "$ran_any" -eq 0 ]; then
  echo "No configured linter (Biome or ESLint) found in $(pwd) — skipping automated lint."
  echo "Review the files manually against the SKILL.md checklist instead."
  exit 0
fi

if [ "$failed" -ne 0 ]; then
  echo "Fix the problems above and re-run."
  exit 1
fi
