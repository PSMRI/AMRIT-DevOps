#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
DEVOPS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
WORKSPACE="$(dirname "$DEVOPS_DIR")"
COMPOSE_DIR="$DEVOPS_DIR/amrit-local-setup"

# shellcheck source=./lib.sh
source "$DEVOPS_DIR/Applications/Common-Platform/lib.sh"

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
