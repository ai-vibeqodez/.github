#!/usr/bin/env bash
# Sync scripts from ai-warevo/.github to the local project (Linux/macOS).
#
#   scripts/updater.sh [--version] [--check-only] [--ignore-verify] [-h|--help]
#
#   --version          Show this script's version and exit
#   --check-only       Check for updates without making changes
#                      (exit 0=up-to-date, 1=update available)
#   --ignore-verify    Skip SHA256 verification (DANGEROUS: only for emergencies)
#   -h|--help          Show this help
#
# Downloads all files from the scripts/ directory of the GitHub repo and
# overwrites local copies when they differ. Asks for consent before each
# overwrite.  Also checks itself (this script) against the remote.
#
# All downloads are verified against SHA256 checksums from SHA256SUMS.
# If verification fails, the file is NOT written and an error is reported.
#
# SCRIPT_VERSION is auto-updated during the sync — never edit it manually.

SCRIPT_VERSION=1.1.0

set -euo pipefail

# ── Globals ──────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

REMOTE_BASE="https://raw.githubusercontent.com/ai-warevo/.github/refs/heads/main/scripts"
REMOTE_SCRIPTS_DIR="$REMOTE_BASE"

# ── Argument parsing ─────────────────────────────────────────────────
show_version=0
check_only=0
ignore_verify=0
for arg in "$@"; do
    case "$arg" in
        --version)         show_version=1 ;;
        --check-only)      check_only=1 ;;
        --ignore-verify)   ignore_verify=1 ;;
        -h|--help)         sed -n '2,14p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *) echo "[ERROR] unknown argument '$arg' (try --help)" >&2; exit 1 ;;
    esac
done

if [ "$show_version" -eq 1 ]; then
    echo "updater.sh v${SCRIPT_VERSION}"
    exit 0
fi

# ── Logging helpers ──────────────────────────────────────────────────
log_info()  { echo "[INFO]  $*"; }
log_warn()  { echo "[WARN]  $*"; }
log_error() { echo "[ERROR] $*" >&2; }
log_ok()    { echo "[OK]    $*"; }
log_verify() { echo "[VERIFY] $*"; }

# ── HTTP helpers ─────────────────────────────────────────────────────
# Download a remote file to stdout.  Returns 1 on failure.
fetch_remote() {
    local url="$1"
    curl -fsSL --connect-timeout 5 --max-time 15 "$url" 2>/dev/null || return 1
}

# ── Embedded known checksums (fallback if SHA256SUMS is unreachable) ──
# Format: "filename sha256hash"
declare -A known_checksums=(
    ["changelog-update.sh"]="3b41dcd104db8b18316c123c4d4a52d8a077e29ade2ed5a322f7c33817d68098"
    ["release.sh"]="f0caefa59e32fcb0fa012de2eec7e35719dfc3b894b19da7e490d9be67a0cd62"
    ["updater.sh"]="f50ff64e2ce8a0a9062b57c3c5ce3cf516779345f75b45a09f8b377a8ce160b1"
    ["changelog-update.ps1"]="bccd7139cf5504970f22ea2c45a38b591df5f69221872942acbe557a44a6f956"
    ["release.ps1"]="c15f42b298079e7b79c15873a754eb94ea1e4ac5cfb3685c3400706d0ab1a2f1"
    ["updater.ps1"]="54c89e83de73fbe44d8725b2e4262ad6e36e7bf6ea9bfd1626ea00882e017d98"
)

# ── SHA256 verification ──────────────────────────────────────────────
# Verify downloaded content against known checksums.
# Returns 0 if verified, 1 if mismatch or not found.
# Uses remote SHA256SUMS first, then falls back to embedded checksums.
verify_checksum() {
    local filename="$1"
    local content="$2"

    if [ "$ignore_verify" -eq 1 ]; then
        log_warn "SHA256 verification SKIPPED for ${filename} (--ignore-verify)"
        log_warn "  WARNING: This is dangerous — only use in emergencies!"
        return 0
    fi

    # Try remote SHA256SUMS first
    local remote_sums
    remote_sums="$(fetch_remote "${REMOTE_SCRIPTS_DIR}/SHA256SUMS")" || true

    local expected_hash=""

    if [ -n "$remote_sums" ]; then
        expected_hash="$(echo "$remote_sums" | grep "  ${filename}$" | awk '{print $1}')" || true
    fi

    # Fall back to embedded checksums
    if [ -z "$expected_hash" ]; then
        expected_hash="${known_checksums[$filename]:-}" || true
    fi

    if [ -z "$expected_hash" ]; then
        log_warn "No known checksum for ${filename} — skipping verification"
        return 1
    fi

    local actual_hash
    actual_hash="$(echo "$content" | sha256sum | awk '{print $1}')"

    if [ "$actual_hash" = "$expected_hash" ]; then
        log_verify "SHA256 OK for ${filename}"
        return 0
    else
        log_error "SHA256 MISMATCH for ${filename}!"
        log_error "  Expected: ${expected_hash}"
        log_error "  Actual:   ${actual_hash}"
        log_error "  File may be tampered or corrupted — refusing to overwrite"
        return 1
    fi
}

# ── SemVer comparison ────────────────────────────────────────────────
# Returns 0 if $1 > $2, 1 otherwise.
version_gt() {
    IFS='.' read -r -a a <<< "$1"
    IFS='.' read -r -a b <<< "$2"

    local max=${#a[@]}
    [ ${#b[@]} -gt "$max" ] && max=${#b[@]}

    for ((i = 0; i < max; i++)); do
        local va="${a[$i]:-0}"
        local vb="${b[$i]:-0}"
        if ((va > vb)); then return 0; fi
        if ((va < vb)); then return 1; fi
    done
    return 1
}

# ── Parse SCRIPT_VERSION from a script's content ─────────────────────
parse_version() {
    local content="$1"
    echo "$content" | grep -oP 'SCRIPT_VERSION=\K[0-9]+\.[0-9]+\.[0-9]+' || true
}

# ── Consent ──────────────────────────────────────────────────────────
ask_consent() {
    local file="$1"
    local action="${2:-overwrite}"
    printf "[CONSENT] %s %s? [Y/n] " "$action" "$file"
    local reply
    IFS= read -r reply || reply="y"
    reply="${reply,,}"
    [ -z "$reply" ] || [ "$reply" = "y" ] || [ "$reply" = "yes" ]
}

# ── Conflict detection ───────────────────────────────────────────────
# Returns 0 if files differ, 1 if identical.
files_differ() {
    local local_file="$1" remote_content="$2"
    diff --quiet "$local_file" <(echo "$remote_content") >/dev/null 2>&1
    return $?
}

# ── Main logic ───────────────────────────────────────────────────────

log_info "updater.sh v${SCRIPT_VERSION} — starting"
log_info "Repository root: ${REPO_ROOT}"

# 1. Check internet connectivity by probing remote scripts.
log_info "Checking remote repository…"
known_scripts=(
    "changelog-update.sh"
    "changelog-update.ps1"
    "release.sh"
    "release.ps1"
    "updater.sh"
)

declare -a available_scripts=()
for script in "${known_scripts[@]}"; do
    if fetch_remote "${REMOTE_SCRIPTS_DIR}/${script}" >/dev/null 2>&1; then
        available_scripts+=("$script")
    fi
done

if [ ${#available_scripts[@]} -eq 0 ]; then
    log_warn "Cannot reach remote scripts repository (no internet or scripts/ is empty)"
    log_warn "Skipping update — local scripts are unchanged"
    exit 0
fi

log_info "Found ${#available_scripts[@]} script(s) on remote: ${available_scripts[*]}"

# 2. Self-check: is updater.sh itself outdated?
self_remote="$(fetch_remote "${REMOTE_SCRIPTS_DIR}/updater.sh")" || true
if [ -n "$self_remote" ]; then
    self_remote_version="$(parse_version "$self_remote")"
    if [ -n "$self_remote_version" ]; then
        log_info "Local version : ${SCRIPT_VERSION}"
        log_info "Remote version: ${self_remote_version}"

        if version_gt "$self_remote_version" "$SCRIPT_VERSION"; then
            log_info "New version available: ${self_remote_version}"
        else
            log_info "Already up to date (v${SCRIPT_VERSION})"
        fi
    else
        log_warn "SCRIPT_VERSION not found in remote updater.sh — skipping self-check"
    fi
else
    log_info "Remote updater.sh not yet available (first deploy?) — skipping self-check"
fi

# 3. Sync each script.
updated=0
skipped=0
errors=0

for script in "${available_scripts[@]}"; do
    log_info "Processing ${script}…"

    local_file="${SCRIPT_DIR}/${script}"
    remote_content="$(fetch_remote "${REMOTE_SCRIPTS_DIR}/${script}")" || {
        log_error "Failed to download ${script} from remote"
        ((errors++)) || true
        continue
    }

    remote_version="$(parse_version "$remote_content")"

    # Verify SHA256 BEFORE proceeding.
    if ! verify_checksum "$script" "$remote_content"; then
        log_error "  Aborting ${script} — checksum verification failed"
        ((errors++)) || true
        continue
    fi

    # If local file doesn't exist, always sync (after verification).
    if [ ! -f "$local_file" ]; then
        if [ "$check_only" -eq 1 ]; then
            log_info "  [check-only] ${script} is missing locally — would create"
            updated=$((updated + 1))
        else
            if ask_consent "$script" "create"; then
                echo "$remote_content" > "$local_file"
                log_ok "Created ${script} (v${remote_version})"
                updated=$((updated + 1))
            else
                log_info "  Skipped (user declined)"
                skipped=$((skipped + 1))
            fi
        fi
        continue
    fi

    # Local file exists — check if it differs.
    if files_differ "$local_file" "$remote_content"; then
        local_version="$(parse_version "$(cat "$local_file")")"
        if [ "$check_only" -eq 1 ]; then
            log_info "  [check-only] ${script} differs — local: ${local_version:-?}, remote: ${remote_version:-?}"
            updated=$((updated + 1))
        else
            if ask_consent "$script" "overwrite"; then
                echo "$remote_content" > "$local_file"
                log_ok "Updated ${script} (${local_version:-?} → ${remote_version:-?})"
                updated=$((updated + 1))
            else
                log_info "  Skipped (user declined)"
                skipped=$((skipped + 1))
            fi
        fi
    else
        log_info "  ${script} is up to date"
    fi
done

# 4. Summary.
echo ""
log_info "Summary: ${updated} updated, ${skipped} skipped, ${errors} errors"

if [ "$check_only" -eq 1 ]; then
    if [ "$updated" -gt 0 ]; then
        log_info "Updates available — run without --check-only to apply"
        exit 1
    else
        log_info "All scripts are up to date"
        exit 0
    fi
fi

if [ "$errors" -gt 0 ]; then
    log_error "Completed with ${errors} error(s)"
    exit 1
fi

log_ok "All scripts synced successfully"
exit 0
