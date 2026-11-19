#!/usr/bin/env bash
set -euo pipefail

# fix-sha-pin.sh — resolve and update SHA pinning for all
# ai-warevo/.github/ci/actions/* references in workflow files.
#
# Usage:
#   .github/fix-sha-pin.sh [--dry-run] [--push]
#
# --dry-run  show diff only (default)
# --push     commit and push the update

REPO_OWNER="ai-warevo"
REPO_NAME=".github"
CI_ACTIONS="ci/actions"

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
  # Resolve the latest commit SHA for a given path on origin/main
  git ls-tree origin/main -- "$1" | awk '{print $3}'
}

# ── discover all referenced actions ──────────────────────────────
# Pattern: ai-warevo/.github/ci/actions/<name>@<sha>
# Also catches stale: ai-warevo/.github/.github/actions/<name>@<sha>
mapfile -t refs < <(
  grep -roh 'ai-warevo/\.github/[^@]*@[a-f0-9]\{40\}' \
    .github/workflows/*.yml ci/.github/workflows/*.yml 2>/dev/null \
    | sort -u
)

if [[ ${#refs[@]} -eq 0 ]]; then
  echo "No ai-warevo action references found."
  exit 0
fi

echo "=== Found ${#refs[@]} unique action references ==="
for ref in "${refs[@]}"; do
  echo "  $ref"
done

# ── normalize and resolve SHAs ───────────────────────────────────
declare -A action_sha   # action name → latest SHA from origin/main
declare -A action_paths # action name → correct path (ci/actions/<name>)

for ref in "${refs[@]}"; do
  # Extract action name — strip everything before the last /
  name="${ref##*/}"
  name="${name%%@*}"

  # Correct path: always ci/actions/<name>
  action_paths["$name"]="${CI_ACTIONS}/${name}"

  # Resolve latest SHA from origin/main
  sha=$(resolve_sha "${CI_ACTIONS}/${name}")
  if [[ -z "$sha" ]]; then
    echo "WARNING: Could not resolve SHA for action '$name'" >&2
    continue
  fi
  action_sha["$name"]="$sha"
done

# ── find stale / incorrect references ────────────────────────────
declare -A stale=()  # old_ref → new_ref

for ref in "${refs[@]}"; do
  # Extract name and current SHA
  name="${ref##*/}"
  name="${name%%@*}"
  current_sha="${ref##*@}"

  # Expected correct reference
  expected_ref="ai-warevo/.github/${CI_ACTIONS}/${name}@${action_sha[$name]}"

  if [[ "$ref" != "$expected_ref" ]]; then
    stale["$ref"]="$expected_ref"
  fi
done

if [[ ${#stale[@]} -eq 0 ]]; then
  echo "All action references are up to date."
  exit 0
fi

# Guard: if dry-run and no stale refs after initial check, skip
# (dry-run already applied changes, so stale is empty on re-run)
if [[ $dry_run -eq 1 && ${#files_to_update[@]} -eq 0 ]]; then
  echo "No files to update."
  exit 0
fi

echo ""
echo "=== Stale/incorrect references (${#stale[@]}) ==="
for ref in "${!stale[@]}"; do
  name="${ref##*/}"
  name="${name%%@*}"
  old_sha="${ref##*@}"
  new_sha="${action_sha[$name]}"
  echo "  $name:"
  echo "    old: $ref"
  echo "    new: ${stale[$ref]}"
done

# ── collect files that need changes ──────────────────────────────
files_to_update=()  # files that need updating

for ref in "${!stale[@]}"; do
  old_ref="$ref"
  new_ref="${stale[$ref]}"

  # Find files containing this old reference
  for pattern_file in .github/workflows/*.yml ci/.github/workflows/*.yml; do
    if grep -q "$old_ref" "$pattern_file" 2>/dev/null; then
      files_to_update+=("$pattern_file")
    fi
  done
done

# Deduplicate and sort
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
    new_ref="${stale[$ref]}"

    for f in "${files_to_update[@]}"; do
      if grep -q "$old_ref" "$f" 2>/dev/null; then
        # Escape special characters for sed
        escaped_old=$(printf '%s\n' "$old_ref" | sed 's/[&/\]/\\&/g')
        escaped_new=$(printf '%s\n' "$new_ref" | sed 's/[&/\]/\\&/g')
        sed -i "s|${escaped_old}|${escaped_new}|g" "$f"
      fi
    done
  done

  git diff
  echo ""
  echo "Restoring files (dry-run)."
  git checkout -- "${files_to_update[@]}"
  echo "No changes committed. Run with --push to apply."
else
  # Apply changes
  for ref in "${!stale[@]}"; do
    old_ref="$ref"
    new_ref="${stale[$ref]}"

    for f in "${files_to_update[@]}"; do
      if grep -q "$old_ref" "$f" 2>/dev/null; then
        escaped_old=$(printf '%s\n' "$old_ref" | sed 's/[&/\]/\\&/g')
        escaped_new=$(printf '%s\n' "$new_ref" | sed 's/[&/\]/\\&/g')
        sed -i "s|${escaped_old}|${escaped_new}|g" "$f"
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
