#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
DEVOPS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
WORKSPACE="$(dirname "$DEVOPS_DIR")"
COMPOSE_DIR="$DEVOPS_DIR/amrit-local-setup"

# shellcheck source=./lib.sh
source "$DEVOPS_DIR/Applications/Common-Platform/lib.sh"

# ── Reset flags ───────────────────────────────────────────────────────────────

for arg in "$@"; do
    case "$arg" in
        --reset-db)   rm -f "$AMRIT_SETUP_DIR/.db_migrated";  log_info "main" "DB migration sentinel cleared." ;;
        --reset-data) rm -f "$AMRIT_SETUP_DIR/.data_loaded";  log_info "main" "Master data sentinel cleared." ;;
        --reset-all)
            rm -f "$AMRIT_SETUP_DIR/.db_migrated" "$AMRIT_SETUP_DIR/.data_loaded"
            log_info "main" "All sentinels cleared."
            ;;
    esac
done

# ── Setup functions ───────────────────────────────────────────────────────────

setup_common_api() {
    setup_api "Common-API" \
        "https://github.com/PSMRI/Common-API.git" \
        "src/main/environment/common_example.properties" \
        "src/main/environment/common_local.properties"
}

setup_common_ui() {
    clone_repo "Common-UI" "https://github.com/PSMRI/Common-UI.git"
}

# ── Main ──────────────────────────────────────────────────────────────────────

setup_common_api
setup_common_ui
start_infrastructure
run_db_migrations || true
load_master_data
