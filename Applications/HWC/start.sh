#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
DEVOPS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
WORKSPACE="$(dirname "$DEVOPS_DIR")"

# shellcheck source=../Common-Platform/lib.sh
source "$DEVOPS_DIR/Applications/Common-Platform/lib.sh"

# ── Setup functions ───────────────────────────────────────────────────────────

setup_hwc_api() {
    setup_api "HWC-API" \
        "https://github.com/PSMRI/HWC-API.git" \
        "src/main/environment/hwc_example.properties" \
        "src/main/environment/hwc_local.properties"
}

setup_hwc_ui() {
    setup_ui "HWC-UI" \
        "https://github.com/PSMRI/HWC-UI.git" \
        "src/environments/environment.local.ts" \
        "src/environments/environment.ts"
}

# ── Service Startup ───────────────────────────────────────────────────────────

start_services() {
    local session="amrit-hwc"

    create_tmux_session "$session" "common-api"

    run_in_tmux "$session" "common-api" \
        "cd \"$WORKSPACE/Common-API\" && mvn clean install -DskipTests=true && mvn spring-boot:run -DENV_VAR=local"

    run_in_tmux "$session" "hwc-api" \
        "cd \"$WORKSPACE/HWC-API\" && mvn clean install -DskipTests=true && mvn spring-boot:run -DENV_VAR=local"

    run_in_tmux "$session" "hwc-ui" \
        "cd \"$WORKSPACE/HWC-UI\" && ng serve"

    echo ""
    log_info "main" "All services launched in tmux session '$session'."
    log_info "main" "Attach to view logs:  tmux attach -t $session"
    log_info "main" "Switch windows:       Ctrl+b, then n / p  or  Ctrl+b, then 0-2"
    echo ""
}

# ── Main ──────────────────────────────────────────────────────────────────────

setup_hwc_api
setup_hwc_ui

start_services
