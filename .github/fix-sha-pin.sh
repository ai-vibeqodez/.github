#!/usr/bin/env bash
set -euo pipefail

# fix-sha-pin.sh — resolve and update SHA pinning for all
# ai-warevo/.github/.github/actions/* references in workflow files.
#
# Usage:
#   .github/fix-sha-pin.sh [ref] [--dry-run] [--push]
#
# ref    — branch name, tag, or commit SHA (default: main)
# --dry-run  show diff only (default)
# --push     commit and push the update
#
# Examples:
#   .github/fix-sha-pin.sh              # update from main
#   .github/fix-sha-pin.sh v1.2.3       # update from tag v1.2.3
#   .github/fix-sha-pin.sh abc1234      # update from specific commit
#   .github/fix-sha-pin.sh feat/branch  # update from feature branch
#   .github/fix-sha-pin.sh --dry-run    # preview changes
#   .github/fix-sha-pin.sh main --push  # apply and push

REPO_OWNER="ai-warevo"
REPO_NAME=".github"
ACTIONS_DIR=".github/actions"

# ── parse arguments ──────────────────────────────────────────────
ref="main"
dry_run=1
push=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --push)    dry_run=0; push=1; shift ;;
    -h|--help)
      echo "Usage: $0 [ref] [--dry-run] [--push]"
      echo "  ref    — branch, tag, or commit SHA (default: main)"
      echo "  --dry-run  show diff only (default)"
      echo "  --push     commit and push the update"
      exit 0
      ;;
    -*)  echo "Unknown option: $1" >&2; exit 1 ;;
    *)   ref="$1"; shift ;;
  esac
done

# Validate ref is not a flag-like value
if [[ "$ref" == -* ]]; then
  echo "Error: ref must not start with '-'" >&2
  exit 1
fi

# ── helpers ──────────────────────────────────────────────────────
# Resolve the latest commit SHA for a directory at a given ref.
# Uses the GitHub API (works from any machine, no need for the ref locally).
resolve_sha() {
  local action_name="$1"
  local target_ref="$2"
  local path="${ACTIONS_DIR}/${action_name}"

  # Try GitHub API first (works from CI, any branch, no checkout needed)
  local sha
  sha=$(curl -s "https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/commits" \
    -H "Accept: application/vnd.github.v3+json" \
    -d "path=${path}&sha=${target_ref}&per_page=1" \
    | jq -r '.[0].sha // empty' 2>/dev/null)

  if [[ -n "$sha" ]]; then
    echo "$sha"
    return 0
  fi

  # Fallback: git ls-tree (only works if ref exists locally)
  sha=$(git ls-tree -r "${target_ref}" -- "${path}" 2>/dev/null | awk '{print $3}' | head -1)
  if [[ -n "$sha" ]]; then
    echo "$sha"
    return 0
  fi

  return 1
}

# ── discover all referenced composite actions ────────────────────
# Pattern: ai-warevo/.github/.github/actions/<name>@<sha>
mapfile -t refs < <(
  grep -roh 'ai-warevo/\.github/\.github/actions/[^@]*@[a-f0-9]\{40\}' \
    .github/workflows/*.yml 2>/dev/null \
    | sort -u
)

if [[ ${#refs[@]} -eq 0 ]]; then
  echo "No ai-warevo action references found in .github/workflows/*.yml."
  exit 0
fi

echo "=== Found ${#refs[@]} unique action references ==="
echo "Resolving SHAs from ref: ${ref}"
for ref_item in "${refs[@]}"; do
  echo "  ${ref_item%%@*}@${ref_item##*@}"
done

# ── resolve latest SHAs ──────────────────────────────────────────
declare -A action_sha=()  # action name → latest SHA

for ref_item in "${refs[@]}"; do
  # Extract action name — strip everything before the last /
  name="${ref_item##*/}"
  name="${name%%@*}"

  sha=$(resolve_sha "$name" "$ref")
  if [[ -z "$sha" ]]; then
    echo "WARNING: Could not resolve SHA for action '$name' at ref '${ref}'" >&2
    continue
  fi
  action_sha["$name"]="$sha"
done

if [[ ${#action_sha[@]} -eq 0 ]]; then
  echo "No SHAs could be resolved. Is the ref '${ref}' valid?" >&2
  exit 1
fi

# ── find stale / incorrect references ────────────────────────────
declare -A stale=()  # old_ref → new_ref

for ref_item in "${refs[@]}"; do
  name="${ref_item##*/}"
  name="${name%%@*}"
  current_sha="${ref_item##*@}"

  # Skip if we couldn't resolve the new SHA
  if [[ -z "${action_sha[$name]:-}" ]]; then
    continue
  fi

  new_sha="${action_sha[$name]}"
  new_ref="ai-warevo/.github/.github/actions/${name}@${new_sha}"

  if [[ "$ref_item" != "$new_ref" ]]; then
    stale["$ref_item"]="$new_ref"
  fi
done

if [[ ${#stale[@]} -eq 0 ]]; then
  echo "All action references are up to date for ref '${ref}'."
  exit 0
fi

echo ""
echo "=== Stale/incorrect references (${#stale[@]}) ==="
for old_ref in "${!stale[@]}"; do
  name="${old_ref##*/}"
  name="${name%%@*}"
  old_sha="${old_ref##*@}"
  new_sha="${action_sha[$name]}"
  echo "  ${name}:"
  echo "    old: @${old_sha:0:12}"
  echo "    new: @${new_sha:0:12}"
done

# ── collect files that need changes ──────────────────────────────
files_to_update=()

for old_ref in "${!stale[@]}"; do
  new_ref="${stale[$old_ref]}"

  for yml in .github/workflows/*.yml; do
    if grep -qF "$old_ref" "$yml" 2>/dev/null; then
      files_to_update+=("$yml")
    fi
  done
done

# Deduplicate and sort
if [[ ${#files_to_update[@]} -gt 0 ]]; then
  mapfile -t files_to_update < <(printf '%s\n' "${files_to_update[@]}" | sort -u)
fi

echo ""
echo "=== Files to update (${#files_to_update[@]}) ==="
for f in "${files_to_update[@]}"; do
  echo "  ${f}"
done

# ── apply or diff ────────────────────────────────────────────────
if [[ $dry_run -eq 1 ]]; then
  echo ""
  echo "=== Dry-run: applying changes and showing diff ==="

  for old_ref in "${!stale[@]}"; do
    new_ref="${stale[$old_ref]}"

    for f in "${files_to_update[@]}"; do
      if grep -qF "$old_ref" "$f" 2>/dev/null; then
        sed -i "s|${old_ref}|${new_ref}|g" "$f"
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
  for old_ref in "${!stale[@]}"; do
    new_ref="${stale[$old_ref]}"

    for f in "${files_to_update[@]}"; do
      if grep -qF "$old_ref" "$f" 2>/dev/null; then
        sed -i "s|${old_ref}|${new_ref}|g" "$f"
      fi
    done
  done

  echo ""
  echo "=== Committed ==="
  git add "${files_to_update[@]}"
  git commit -m "ci: update action SHA pinning to latest commit (${ref})"

  if [[ $push -eq 1 ]]; then
    echo "=== Pushing ==="
    git push origin main
    echo "Done."
  else
    echo "Changes committed. Push with: git push origin main"
  fi
fi
