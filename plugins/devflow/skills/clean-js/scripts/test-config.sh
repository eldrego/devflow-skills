#!/usr/bin/env bash
# Usage: test-config.sh
# Prints the current project's test-tool configuration (Vitest, Jest,
# Playwright) and its global setup files, so tests can avoid repeating what
# is already configured globally. Run from the project root.
set -uo pipefail

MAX_LINES=120
found_any=0

show() {
  local file="$1"
  found_any=1
  echo
  echo "===== $file ====="
  head -n "$MAX_LINES" "$file"
  local total
  total=$(wc -l <"$file" | tr -d ' ')
  if [ "$total" -gt "$MAX_LINES" ]; then
    echo "... ($total lines total, truncated; read the file for the rest)"
  fi
}

# Runner configs and common global setup files: the project root plus nested
# app/package folders (monorepos such as Nx, Turborepo, pnpm workspaces).
files=$(find . -maxdepth 4 \
  \( -name node_modules -o -name .git -o -name dist -o -name build -o -name coverage \) -prune -o \
  -type f \( -name "vitest.config.*" -o -name "vitest.workspace.*" -o -name "vite.config.*" \
  -o -name "jest.config.*" -o -name "jest.preset.*" -o -name "playwright.config.*" \
  -o -name "setupTests.*" -o -name "vitest.setup.*" -o -name "jest.setup.*" \
  -o -name "test-setup.*" -o -name "setup-tests.*" -o -name "global-setup.*" \
  -o -name "globalSetup.*" \) -print 2>/dev/null | sort)

for file in $files; do
  show "$file"
done

# Jest config embedded in package.json (a top-level "jest": { ... } block, not
# the jest dependency entry).
if [ -f package.json ] && grep -qE '^  "jest"[[:space:]]*:[[:space:]]*\{' package.json; then
  found_any=1
  echo
  echo "===== package.json \"jest\" block ====="
  grep -nE -A 25 '^  "jest"[[:space:]]*:[[:space:]]*\{' package.json | head -n 40
fi

if [ "$found_any" -eq 0 ]; then
  echo "No Vitest, Jest, or Playwright config or setup files found in $(pwd)."
  echo "Check package.json scripts to see how tests are run."
  exit 0
fi

echo
echo "Also read any setup files referenced by setupFiles / setupFilesAfterEnv /"
echo "globalSetup above that were not printed here."
