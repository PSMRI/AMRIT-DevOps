#!/bin/bash
# Shared setup functions for AMRIT scripts.
# Source this file; do not run directly.

# ── Logging ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log_info()  { echo -e "${GREEN}[INFO]${NC}  [${1}] ${2}"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  [${1}] ${2}"; }
log_error() { echo -e "${RED}[ERROR]${NC} [${1}] ${2}"; }

# ── Infrastructure ────────────────────────────────────────────────────────────

# Usage: start_infrastructure
# Requires: $COMPOSE_DIR
start_infrastructure() {
    log_info "infra" "Starting infrastructure containers..."
    docker-compose -f "$COMPOSE_DIR/docker-compose.yml" up -d
    log_info "infra" "Containers started. Waiting for readiness..."
    wait_for_infrastructure
}

# Usage: wait_for_container <label> <check_command>
wait_for_container() {
    local label="$1"
    local check_cmd="$2"
    local timeout=120
    local interval=5
    local elapsed=0

    while ! eval "$check_cmd" &>/dev/null; do
        if [ "$elapsed" -ge "$timeout" ]; then
            log_error "infra" "$label did not become ready within ${timeout}s."
            log_error "infra" "Check logs: docker-compose -f \"$COMPOSE_DIR/docker-compose.yml\" logs $label"
            return 1
        fi
        sleep "$interval"
        elapsed=$((elapsed + interval))
    done
    log_info "infra" "$label is ready."
}

# Usage: wait_for_infrastructure
# Requires: $COMPOSE_DIR
wait_for_infrastructure() {
    wait_for_container "mysql" \
        "docker exec mysql-container mysqladmin ping -h 127.0.0.1 --silent"

    wait_for_container "redis" \
        "docker exec redis-container redis-cli ping | grep -q PONG"

    wait_for_container "mongodb" \
        "docker exec mongodb-container mongosh --quiet --eval \"db.adminCommand('ping').ok\" -u root -p 1234 --authenticationDatabase admin | grep -q 1"

    wait_for_container "elasticsearch" \
        "curl -s -u elastic:piramalES http://localhost:9200/_cluster/health | grep -q status"

    log_info "infra" "All infrastructure containers are ready."
}

# ── Repository Setup ──────────────────────────────────────────────────────────

# Clones a repository with no additional setup steps.
# Usage: clone_repo <name> <repo_url>
# Requires: $WORKSPACE
clone_repo() {
    local name="$1"
    local repo_url="$2"
    local dir="$WORKSPACE/$name"

    if [ ! -d "$dir" ]; then
        log_info "$name" "Cloning repository..."
        git clone "$repo_url" "$dir"
        log_info "$name" "Done."
    else
        log_info "$name" "Already exists, skipping clone."
    fi
}

# Clones a Spring Boot API repo and copies the example properties file.
# Usage: setup_api <name> <repo_url> <example_props> <local_props>
# Requires: $WORKSPACE
setup_api() {
    local name="$1"
    local repo_url="$2"
    local example_props="$3"
    local local_props="$4"
    local dir="$WORKSPACE/$name"

    clone_repo "$name" "$repo_url"

    if [ ! -f "$dir/$local_props" ]; then
        cp "$dir/$example_props" "$dir/$local_props"
        log_info "$name" "Edit $local_props with your local connection details before starting the service."
    fi
}

# Clones an Angular UI repo, initialises submodules, installs npm deps,
# and copies the example environment file.
# Usage: setup_ui <name> <repo_url> <example_env> <local_env>
# Requires: $WORKSPACE
setup_ui() {
    local name="$1"
    local repo_url="$2"
    local example_env="$3"
    local local_env="$4"
    local dir="$WORKSPACE/$name"

    clone_repo "$name" "$repo_url"

    if [ ! -d "$dir/node_modules" ]; then
        log_info "$name" "Initialising submodules (includes Common-UI)..."
        git -C "$dir" submodule update --init --recursive
        log_info "$name" "Installing npm dependencies (this may take a few minutes)..."
        (cd "$dir" && npm install --legacy-peer-deps)
    fi

    if [ ! -f "$dir/$local_env" ]; then
        cp "$dir/$example_env" "$dir/$local_env"
        log_info "$name" "Edit $local_env with your local API endpoints before starting the service."
    fi
}

# ── Service Startup (tmux) ───────────────────────────────────────────────────

# Creates a new tmux session. Kills any existing session with the same name.
# Usage: create_tmux_session <session_name> <first_window_name>
create_tmux_session() {
    local session="$1"
    local first_window="$2"

    if ! command -v tmux &>/dev/null; then
        log_error "tmux" "tmux is not installed. Install it with: sudo apt install tmux"
        exit 1
    fi

    if tmux has-session -t "$session" 2>/dev/null; then
        log_warn "tmux" "Session '$session' already exists. Killing and recreating..."
        tmux kill-session -t "$session"
    fi

    tmux new-session -d -s "$session" -n "$first_window"
    log_info "tmux" "Created session '$session'."
}

# Sends a command to an existing window, or creates the window if it doesn't exist.
# Usage: run_in_tmux <session_name> <window_name> <command>
run_in_tmux() {
    local session="$1"
    local window="$2"
    local cmd="$3"

    if ! tmux list-windows -t "$session" -F "#{window_name}" 2>/dev/null | grep -qx "$window"; then
        tmux new-window -t "$session" -n "$window"
    fi

    tmux send-keys -t "$session:$window" "$cmd" Enter
    log_info "tmux" "Started '$window'."
}

