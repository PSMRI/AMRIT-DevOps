#!/usr/bin/env bash
# AMRIT Local Setup — single entry point.
# Interactive wizard by default; flag-driven for CI / repeat runs.
#
# See `bash start.sh --help` for all options.

# Associative arrays require bash 4+. macOS ships bash 3.2 at /bin/bash.
# Re-exec under a newer bash if we detect we're running under the old one.
if [ "${BASH_VERSINFO:-0}" -lt 4 ]; then
    for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash /usr/bin/bash; do
        if [ -x "$candidate" ] && "$candidate" -c '[ "${BASH_VERSINFO:-0}" -ge 4 ]'; then
            exec "$candidate" "$0" "$@"
        fi
    done
    echo "[ERROR] This script requires bash 4+. macOS ships bash 3.2 at /bin/bash."
    echo "        Install a modern bash:  brew install bash"
    echo "        Or re-run under a specific newer bash path."
    exit 1
fi

set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
AUTOMATION_DIR="$SCRIPT_DIR"
LOCAL_SETUP_DIR="$(dirname "$AUTOMATION_DIR")"
DEVOPS_DIR="$(dirname "$LOCAL_SETUP_DIR")"
WORKSPACE="$(dirname "$DEVOPS_DIR")"
COMPOSE_DIR="$LOCAL_SETUP_DIR/infra"

LIB_DIR="$AUTOMATION_DIR/lib"

# shellcheck source=lib/services.conf
source "$LIB_DIR/services.conf"
# shellcheck source=lib/products.conf
source "$LIB_DIR/products.conf"
# shellcheck source=lib/common.sh
source "$LIB_DIR/common.sh"
# shellcheck source=lib/launchers.sh
source "$LIB_DIR/launchers.sh"
# shellcheck source=lib/engine.sh
source "$LIB_DIR/engine.sh"
# shellcheck source=lib/wizard.sh
source "$LIB_DIR/wizard.sh"

# ── Dispatch ─────────────────────────────────────────────────────────────────
# Parse flags / handle help / print usage BEFORE the toolchain preflight so
# partially-configured machines can still discover the CLI surface.

if [ $# -gt 0 ]; then
    # Flag mode — orchestrate non-interactively.
    parse_flags "$@" || exit 1
    # Allow bare reset (no products) to clear sentinels and exit early —
    # no need to preflight the full toolchain for a sentinel wipe.
    if [ -z "$SELECTED_PRODUCTS" ]; then
        apply_reset_flags "${RESET_ARGS[@]}"
        exit 0
    fi
    preflight || exit 1
    resolve_workspace "${OPT_WORKSPACE:-$WORKSPACE}" "auto" || exit 1
    run_selection
    exit $?
fi

# No flags: either run the wizard (TTY) or print usage (non-TTY).
if [ ! -t 0 ] || [ ! -t 1 ]; then
    log_error "cli" "No flags provided and stdin is not a TTY. Pass --product=<key> or similar."
    print_usage
    exit 1
fi

preflight || exit 1
ensure_gum || exit 1
run_wizard
