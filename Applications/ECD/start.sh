#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
DEVOPS_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
WORKSPACE="$(dirname "$DEVOPS_DIR")"

# shellcheck source=../Common-Platform/lib.sh
source "$DEVOPS_DIR/Applications/Common-Platform/lib.sh"

# ── Setup functions ───────────────────────────────────────────────────────────

setup_ecd_api() {
    setup_api "ECD-API" \
        "https://github.com/PSMRI/ECD-API.git" \
        "src/main/environment/ecd_example.properties" \
        "src/main/environment/ecd_local.properties"
}

setup_ecd_ui() {
    setup_ui "ECD-UI" \
        "https://github.com/PSMRI/ECD-UI.git" \
        "src/environments/environment.local.ts" \
        "src/environments/environment.ts"
}

# ── Service Startup ───────────────────────────────────────────────────────────

start_services() {
    local session="amrit-ecd"

    create_tmux_session "$session" "docker"

    run_in_tmux "$session" "docker" \
        "$DEVOPS_DIR/Applications/Common-Platform/start.sh"

    run_in_tmux "$session" "common-api" \
        "cd \"$WORKSPACE/Common-API\" && mvn clean install -DskipTests=true && mvn spring-boot:run -DENV_VAR=local"

    run_in_tmux "$session" "ecd-api" \
        "cd \"$WORKSPACE/ECD-API\" && mvn clean install -DskipTests=true && mvn spring-boot:run -DENV_VAR=local"

    run_in_tmux "$session" "ecd-ui" \
        "cd \"$WORKSPACE/ECD-UI\" && ng serve"

    echo ""
    log_info "main" "All services launched in tmux session '$session'."
    log_info "main" "Attach to view logs:  tmux attach -t $session"
    log_info "main" "Switch windows:       Ctrl+b, then n / p  or  Ctrl+b, then 0-2"
    echo ""
}

# ── Main ──────────────────────────────────────────────────────────────────────

setup_ecd_api
setup_ecd_ui

start_services
