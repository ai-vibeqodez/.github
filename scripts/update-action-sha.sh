#!/usr/bin/env bash
set -euo pipefail

# update-action-sha.sh — resolve and update SHA pinning for all
# ai-warevo/.github/ci/actions/* references in workflow files.
#
# Usage:
#   scripts/update-action-sha.sh [--dry-run] [--push]
#
# --dry-run  show diff only (default)
# --push     commit and push the update

REPO_OWNER="ai-warevo"
REPO_NAME=".github"
CI_BASE="ci/actions"

dry_run=1
push=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --push)    dry_run=0; push=1; shift ;;
    *) echo "Usage: $0 [--dry-run] [--push]" >&2; exit 1 ;;
  esac
done

# ── helpers ──────────────────────────────────────────────────────
resolve_sha() {
  # Resolve the latest commit SHA for a given path in the repo
  git log --format="%H" -1 -- "$1"
}

# ── discover all referenced actions ──────────────────────────────
# Pattern: ai-warevo/.github/ci/actions/<name>@<sha>
mapfile -t refs < <(
  grep -roh 'ai-warevo/\.github/ci/actions/[a-zA-Z0-9_-]*@[a-f0-9]\{40\}' \
    ci/.github/workflows/*.yml 2>/dev/null | sort -u
)

if [[ ${#refs[@]} -eq 0 ]]; then
  echo "No ai-warevo action references found."
  exit 0
fi

# ── resolve current SHAs ─────────────────────────────────────────
declare -A current_sha
for ref in "${refs[@]}"; do
  name="${ref##*actions/}"
  name="${name%%@*}"
  current_sha["$name"]="$(resolve_sha "${CI_BASE}/${name}")"
done

# ── find stale references ────────────────────────────────────────
declare -A stale
files_to_update=()

for ref in "${refs[@]}"; do
  name="${ref##*actions/}"
  name="${name%%@*}"
  old_sha="${ref##*@}"
  new_sha="${current_sha[$name]}"

  if [[ "$old_sha" != "$new_sha" ]]; then
    stale["$ref"]="$new_sha"
  fi
done

if [[ ${#stale[@]} -eq 0 ]]; then
  echo "All action references are up to date."
  exit 0
fi

echo "=== Stale references (${#stale[@]} actions) ==="
for ref in "${!stale[@]}"; do
  name="${ref##*actions/}"
  name="${name%%@*}"
  old_sha="${ref##*@}"
  new_sha="${stale[$ref]}"
  echo "  $name:"
  echo "    old: $old_sha"
  echo "    new: $new_sha"
done

# ── collect files that need changes ──────────────────────────────
for ref in "${!stale[@]}"; do
  old_ref="$ref"
  new_sha="${stale[$ref]}"
  name="${ref##*actions/}"
  name="${name%%@*}"
  new_ref="ai-warevo/.github/ci/actions/${name}@${new_sha}"

  # Find files containing this old reference
  files=$(grep -rl "$old_ref" ci/.github/workflows/*.yml 2>/dev/null)
  for f in $files; do
    files_to_update+=("$f")
  done
done

# Deduplicate
mapfile -t files_to_update < <(printf '%s\n' "${files_to_update[@]}" | sort -u)

echo ""
echo "=== Files to update (${#files_to_update[@]}) ==="
for f in "${files_to_update[@]}"; do
  echo "  $f"
done

# ── apply or diff ────────────────────────────────────────────────
if [[ $dry_run -eq 1 ]]; then
  echo ""
  echo "=== Dry-run: applying changes and showing diff ==="
  for ref in "${!stale[@]}"; do
    old_ref="$ref"
    new_sha="${stale[$ref]}"
    name="${ref##*actions/}"
    name="${name%%@*}"
    new_ref="ai-warevo/.github/ci/actions/${name}@${new_sha}"

    for f in "${files_to_update[@]}"; do
      if grep -q "$old_ref" "$f" 2>/dev/null; then
        sed -i "s|${old_ref}|${new_ref}|g" "$f"
      fi
    done
  done

  git diff
  echo ""
  echo "No changes committed. Run with --push to apply."
else
  # Apply changes
  for ref in "${!stale[@]}"; do
    old_ref="$ref"
    new_sha="${stale[$ref]}"
    name="${ref##*actions/}"
    name="${name%%@*}"
    new_ref="ai-warevo/.github/ci/actions/${name}@${new_sha}"

    for f in "${files_to_update[@]}"; do
      if grep -q "$old_ref" "$f" 2>/dev/null; then
        sed -i "s|${old_ref}|${new_ref}|g" "$f"
      fi
    done
  done

  echo ""
  echo "=== Committed ==="
  git add "${files_to_update[@]}"
  git commit -m "ci: update action SHA pinning to latest commit"

  if [[ $push -eq 1 ]]; then
    echo "=== Pushing ==="
    git push origin main
    echo "Done."
  else
    echo "Changes committed. Push with: git push origin main"
  fi
fi
