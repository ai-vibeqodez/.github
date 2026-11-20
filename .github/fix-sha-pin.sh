#!/usr/bin/env bash
set -euo pipefail

# fix-sha-pin.sh — replace all ai-warevo/.github action/workflow references
# with @main in workflow files.
#
# Only updates references to the ai-warevo/.github monorepo.
# Third-party actions (actions/checkout, docker/*, softprops/*, etc.) are untouched.
#
# Usage:
#   .github/fix-sha-pin.sh [target_ref] [--dry-run] [--push]
#
# target_ref    — branch/tag to pin to (default: main)
# --dry-run     show diff only (default)
# --push        commit and push the update
#
# Replaces patterns like:
#   ai-warevo/.github/.github/actions/cmake-build@eff474262b...
#   ai-warevo/.github/.github/workflows/reusable-pr-fast.yml@abc123...
#
# Does NOT touch:
#   actions/checkout@v4
#   docker/build-push-action@v5
#   softprops/action-gh-release@v2
#
# Examples:
#   .github/fix-sha-pin.sh              # replace with @main
#   .github/fix-sha-pin.sh v1.2.3       # replace with @v1.2.3
#   .github/fix-sha-pin.sh --dry-run    # preview changes
#   .github/fix-sha-pin.sh main --push  # apply and push

TARGET_REF="main"
dry_run=1
push=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    --push)    dry_run=0; push=1; shift ;;
    -h|--help)
      echo "Usage: $0 [target_ref] [--dry-run] [--push]"
      echo "  target_ref — branch/tag/SHA to pin to (default: main)"
      echo "  --dry-run  show diff only (default)"
      echo "  --push     commit and push the update"
      exit 0
      ;;
    -*)  echo "Unknown option: $1" >&2; exit 1 ;;
    *)   TARGET_REF="$1"; shift ;;
  esac
done

if [[ "$TARGET_REF" == -* ]]; then
  echo "Error: target_ref must not start with '-'" >&2
  exit 1
fi

# ── discover files with pinned references ────────────────────────
mapfile -t files < <(
  {
    grep -rl 'uses:.*@' .github/workflows/*.yml 2>/dev/null || true
    grep -rl 'uses:.*@' .github/actions/*/action.yml 2>/dev/null || true
  } \
    | sort -u
)

if [[ ${#files[@]} -eq 0 ]]; then
  echo "No workflow files with 'uses:' references found."
  exit 0
fi

# ── collect all unique ai-warevo/.github pinned references ───────
# Only match: ai-warevo/.github/.github/actions/... or
#             ai-warevo/.github/.github/workflows/...
declare -A old_refs=()

for f in "${files[@]}"; do
  while IFS= read -r match; do
    old_refs["$match"]=1
  done < <(grep -oP 'uses:\s*\Kai-warevo/\.github/\.github/(actions|workflows)/[^@]+@[a-f0-9v][^ ]*' "$f" 2>/dev/null || true)
done

if [[ ${#old_refs[@]} -eq 0 ]]; then
  echo "No pinned references found."
  exit 0
fi

echo "=== Found ${#old_refs[@]} unique pinned references ==="
for ref in "${!old_refs[@]}"; do
  echo "  ${ref%%@*}@${ref##*@}"
done

# ── perform replacements ─────────────────────────────────────────
declare -A replacements=()  # old_ref → new_ref

for ref in "${!old_refs[@]}"; do
  prefix="${ref%%@*}"
  replacements["$ref"]="${prefix}@${TARGET_REF}"
done

echo ""
echo "=== Replacing with @${TARGET_REF} ==="
for old in "${!replacements[@]}"; do
  echo "  ${old%%@*}@${old##*@} → ${old%%@*}@${TARGET_REF}"
done

# ── apply or diff ────────────────────────────────────────────────
if [[ $dry_run -eq 1 ]]; then
  echo ""
  echo "=== Dry-run: applying changes and showing diff ==="

  for old in "${!replacements[@]}"; do
    new="${replacements[$old]}"
    for f in "${files[@]}"; do
      if grep -qF "$old" "$f" 2>/dev/null; then
        sed -i "s|${old}|${new}|g" "$f"
      fi
    done
  done

  git diff
  echo ""
  echo "Restoring files (dry-run)."
  git checkout -- "${files[@]}"
  echo "No changes committed. Run with --push to apply."
else
  # Apply changes
  for old in "${!replacements[@]}"; do
    new="${replacements[$old]}"
    for f in "${files[@]}"; do
      if grep -qF "$old" "$f" 2>/dev/null; then
        sed -i "s|${old}|${new}|g" "$f"
      fi
    done
  done

  echo ""
  echo "=== Committed ==="
  git add "${files[@]}"
  git commit -m "ci: pin all action references to @${TARGET_REF}"

  if [[ $push -eq 1 ]]; then
    echo "=== Pushing ==="
    git push origin main
    echo "Done."
  else
    echo "Changes committed. Push with: git push origin main"
  fi
fi
