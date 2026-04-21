#!/bin/bash
# Shared primitives for the AMRIT automation wizard.
# Source this file; do not run directly.
#
# Exposes: logging, clone/setup helpers, infra lifecycle, tmux helpers,
# DB migration + master-data loaders (sentinel-guarded), preflight check,
# and ensure_gum for the wizard UI.

# ── Logging ───────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
log_info()  { echo -e "${GREEN}[INFO]${NC}  [${1}] ${2}"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  [${1}] ${2}"; }
log_error() { echo -e "${RED}[ERROR]${NC} [${1}] ${2}"; }

AMRIT_SETUP_DIR="${AMRIT_SETUP_DIR:-$HOME/.amrit}"

# ── Workspace resolution ─────────────────────────────────────────────────────

# Normalises and validates a candidate workspace path. Creates the directory
# if it doesn't exist (with user confirmation when in TTY mode and $2 is
# "interactive"). Sets WORKSPACE to the absolute, resolved path on success.
# Usage: resolve_workspace <path> [interactive|auto]
resolve_workspace() {
    local raw="$1"
    local mode="${2:-auto}"

    if [ -z "$raw" ]; then
        log_error "workspace" "No workspace path provided."
        return 1
    fi

    # Expand ~ and resolve to absolute form without requiring the dir to exist.
    raw="${raw/#\~/$HOME}"
    local abs
    if [ -d "$raw" ]; then
        abs=$(cd "$raw" && pwd -P)
    else
        local parent="$(dirname "$raw")"
        local base="$(basename "$raw")"
        if [ ! -d "$parent" ]; then
            log_error "workspace" "Parent directory does not exist: $parent"
            return 1
        fi
        abs="$(cd "$parent" && pwd -P)/$base"
    fi

    if [ ! -d "$abs" ]; then
        if [ "$mode" = "interactive" ] && command -v gum &>/dev/null; then
            if ! gum confirm "Create new workspace at $abs?"; then
                log_error "workspace" "User declined to create $abs."
                return 1
            fi
        fi
        mkdir -p "$abs" || { log_error "workspace" "Failed to create $abs."; return 1; }
        log_info "workspace" "Created $abs."
    fi

    if [ ! -w "$abs" ]; then
        log_error "workspace" "Workspace is not writable: $abs"
        return 1
    fi

    # Sanity: disallow choosing AMRIT-DevOps itself or anything inside it as
    # the workspace — sibling clones would land in confusing places.
    case "$abs" in
        "$DEVOPS_DIR"|"$DEVOPS_DIR"/*)
            log_error "workspace" "Workspace ($abs) must be outside AMRIT-DevOps ($DEVOPS_DIR)."
            return 1
            ;;
    esac

    WORKSPACE="$abs"
    export WORKSPACE
    log_info "workspace" "Using workspace: $WORKSPACE"
}

# ── Preflight ────────────────────────────────────────────────────────────────

# Verifies required CLI tools are on PATH and Docker is running.
# Called at wizard entry. Exits non-zero if any check fails.
preflight() {
    local missing=()
    local required=(docker java mvn node tmux git lsof)
    for tool in "${required[@]}"; do
        command -v "$tool" &>/dev/null || missing+=("$tool")
    done

    # ng is optional — some UIs use `npm start` wrappers instead.
    if ! command -v ng &>/dev/null; then
        log_warn "preflight" "Angular CLI (ng) not on PATH — UI windows may fail. Install with: npm install -g @angular/cli"
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        log_error "preflight" "Missing required tools: ${missing[*]}"
        log_error "preflight" "See AMRIT-DevOps/README.md#prerequisites for install pointers."
        return 1
    fi

    if ! docker ps &>/dev/null; then
        log_error "preflight" "Docker daemon is not running. Start Docker Desktop and retry."
        return 1
    fi

    log_info "preflight" "All required tools available; Docker is running."
}

# Detects gum; offers to install via brew (macOS) or apt/dnf (Linux).
# Exits if the user declines or install fails.
ensure_gum() {
    if command -v gum &>/dev/null; then
        return 0
    fi

    log_warn "gum" "The 'gum' CLI is required for the interactive wizard."
    log_info "gum" "Install pointers: https://github.com/charmbracelet/gum#installation"

    local installer=""
    case "$(uname -s)" in
        Darwin) command -v brew &>/dev/null && installer="brew install gum" ;;
        Linux)
            if command -v apt-get &>/dev/null; then
                installer="sudo mkdir -p /etc/apt/keyrings && curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg && echo 'deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *' | sudo tee /etc/apt/sources.list.d/charm.list && sudo apt-get update && sudo apt-get install -y gum"
            elif command -v dnf &>/dev/null; then
                installer="echo '[charm]\nname=Charm\nbaseurl=https://repo.charm.sh/yum/\nenabled=1\ngpgcheck=1\ngpgkey=https://repo.charm.sh/yum/gpg.key' | sudo tee /etc/yum.repos.d/charm.repo && sudo dnf install -y gum"
            fi
            ;;
    esac

    if [ -z "$installer" ]; then
        log_error "gum" "No automatic installer available for this platform. Install gum manually and retry."
        return 1
    fi

    read -rp "Install gum now? [y/N] " reply
    case "$reply" in
        [yY]|[yY][eE][sS])
            bash -c "$installer" || { log_error "gum" "Install failed."; return 1; }
            command -v gum &>/dev/null || { log_error "gum" "Install completed but 'gum' still not on PATH."; return 1; }
            log_info "gum" "gum installed."
            ;;
        *)
            log_error "gum" "Cannot continue without gum. Either install it or re-run with flags (see --help)."
            return 1
            ;;
    esac
}

# ── Sentinel flag handling ───────────────────────────────────────────────────

apply_reset_flags() {
    mkdir -p "$AMRIT_SETUP_DIR"
    for arg in "$@"; do
        case "$arg" in
            --reset-db)   rm -f "$AMRIT_SETUP_DIR/.db_migrated";  log_info "reset" "DB migration sentinel cleared." ;;
            --reset-data) rm -f "$AMRIT_SETUP_DIR/.data_loaded";  log_info "reset" "Master data sentinel cleared." ;;
            --reset-all)
                rm -f "$AMRIT_SETUP_DIR/.db_migrated" "$AMRIT_SETUP_DIR/.data_loaded"
                log_info "reset" "All sentinels cleared."
                ;;
        esac
    done
}

# ── One-time setup: DB migrations & master data ──────────────────────────────

# Clones AMRIT-DB and runs Flyway migrations via Maven.
# Skipped if sentinel file exists. Non-fatal on failure.
# Requires: $WORKSPACE
run_db_migrations() {
    local sentinel="$AMRIT_SETUP_DIR/.db_migrated"

    if [ -f "$sentinel" ]; then
        log_info "db-migration" "Already applied, skipping. (Remove $sentinel to re-run)"
        return 0
    fi

    mkdir -p "$AMRIT_SETUP_DIR"

    setup_api "AMRIT-DB" "https://github.com/PSMRI/AMRIT-DB.git" \
        "src/main/environment/common_example.properties" \
        "src/main/environment/common_local.properties"

    local db_dir="$WORKSPACE/AMRIT-DB"

    log_info "db-migration" "Running Flyway migrations (this may take a few minutes)..."

    local log_file
    log_file=$(mktemp)

    mvn -f "$db_dir/pom.xml" spring-boot:run -DENV_VAR=local 2>&1 | tee "$log_file" &
    local mvn_pid=$!

    local timeout=300
    local elapsed=0
    local interval=5
    while kill -0 "$mvn_pid" 2>/dev/null; do
        if grep -q "SUCCESS\|Flyway migration completed successfully" "$log_file" 2>/dev/null; then
            kill "$mvn_pid" 2>/dev/null
            wait "$mvn_pid" 2>/dev/null
            break
        fi
        if grep -q "Error during migration:\|Failed to repair and migrate\|BUILD FAILURE\|APPLICATION FAILED TO START" "$log_file" 2>/dev/null; then
            kill "$mvn_pid" 2>/dev/null
            wait "$mvn_pid" 2>/dev/null
            rm -f "$log_file"
            log_warn "db-migration" "Migration failed — continuing setup."
            return 1
        fi
        if [ "$elapsed" -ge "$timeout" ]; then
            kill "$mvn_pid" 2>/dev/null
            wait "$mvn_pid" 2>/dev/null
            rm -f "$log_file"
            log_warn "db-migration" "Migration timed out after ${timeout}s — continuing setup."
            return 1
        fi
        sleep "$interval"
        elapsed=$((elapsed + interval))
    done

    rm -f "$log_file"
    touch "$sentinel"
    log_info "db-migration" "Migrations applied successfully."
}

# Loads master/dummy data by delegating to loaddummydata.sh.
# Skipped if sentinel file exists. Non-fatal on failure.
# Requires: $COMPOSE_DIR
load_master_data() {
    local sentinel="$AMRIT_SETUP_DIR/.data_loaded"

    if [ -f "$sentinel" ]; then
        log_info "master-data" "Already loaded, skipping. (Remove $sentinel to re-run)"
        return 0
    fi

    local script="$COMPOSE_DIR/loaddummydata.sh"

    if [ ! -f "$script" ]; then
        log_warn "master-data" "loaddummydata.sh not found at $script — skipping."
        return 0
    fi

    log_info "master-data" "Loading master data..."

    if bash "$script"; then
        touch "$sentinel"
        log_info "master-data" "Master data loaded successfully."
    else
        log_warn "master-data" "Master data loading encountered errors — continuing setup."
    fi
}

# ── Infrastructure ────────────────────────────────────────────────────────────

# Usage: start_infrastructure
# Requires: $COMPOSE_DIR
start_infrastructure() {
    log_info "infra" "Starting infrastructure containers..."
    docker compose -f "$COMPOSE_DIR/docker-compose.yml" up -d
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
            log_error "infra" "Check logs: docker compose -f \"$COMPOSE_DIR/docker-compose.yml\" logs $label"
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
        if [ ! -f "$dir/$example_props" ]; then
            log_warn "$name" "Example properties file '$example_props' not found in repo — skipping copy."
            return 0
        fi
        cp "$dir/$example_props" "$dir/$local_props"
        log_info "$name" "Created $local_props from example. Edit it with your local connection details before starting."
    fi
}

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
        if [ ! -f "$dir/$example_env" ]; then
            log_warn "$name" "Example env file '$example_env' not found — skipping copy."
            return 0
        fi
        cp "$dir/$example_env" "$dir/$local_env"
        log_info "$name" "Created $local_env from example. Edit it with your local API endpoints before starting."
    fi
}

# ── Service Startup (tmux) ───────────────────────────────────────────────────

# Usage: create_tmux_session <session_name> <first_window_name>
create_tmux_session() {
    local session="$1"
    local first_window="$2"

    if ! command -v tmux &>/dev/null; then
        log_error "tmux" "tmux is not installed."
        exit 1
    fi

    if tmux has-session -t "$session" 2>/dev/null; then
        log_warn "tmux" "Session '$session' already exists. Killing and recreating..."
        tmux kill-session -t "$session"
    fi

    tmux new-session -d -s "$session" -n "$first_window"
    log_info "tmux" "Created session '$session'."
}

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
