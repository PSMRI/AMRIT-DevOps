#!/bin/bash
# Manifest-driven API/UI launchers plus port and memory guardrails.
# Source this file; do not run directly. Requires lib/common.sh,
# lib/services.conf, lib/products.conf to be already sourced.

# ── Manifest-driven setup ────────────────────────────────────────────────────

# Clones and initialises an API's local properties file using data from
# services.conf. Usage: setup_api_by_name <api_name>
setup_api_by_name() {
    local name="$1"
    local repo="${API_REPO[$name]}"
    local props="${API_PROPS[$name]}"

    if [ -z "$repo" ] || [ -z "$props" ]; then
        log_error "$name" "Missing entry in services.conf (API_REPO / API_PROPS)."
        return 1
    fi

    local example="${props%%:*}"
    local local_file="${props##*:}"
    setup_api "$name" "$repo" "$example" "$local_file"
}

# Clones and initialises a UI's local env file using data from services.conf.
# Usage: setup_ui_by_name <ui_name>
setup_ui_by_name() {
    local name="$1"
    local repo="${UI_REPO[$name]}"
    local env="${UI_ENV[$name]}"

    if [ -z "$repo" ] || [ -z "$env" ]; then
        log_error "$name" "Missing entry in services.conf (UI_REPO / UI_ENV)."
        return 1
    fi

    local example="${env%%:*}"
    local local_file="${env##*:}"
    setup_ui "$name" "$repo" "$example" "$local_file"
}

# ── Manifest-driven launch ───────────────────────────────────────────────────

# Launches an API in a tmux window. Window name is the API name lowercased.
# Usage: start_api_in_tmux <session_name> <api_name>
start_api_in_tmux() {
    local session="$1"
    local name="$2"
    local window
    window=$(echo "$name" | tr '[:upper:]' '[:lower:]')

    # -Dmaven.test.skip=true skips BOTH test execution and test *compilation*.
    # Several AMRIT APIs ship test sources that don't compile standalone; plain
    # -DskipTests still compiles them and fails the build, so use test.skip here.
    run_in_tmux "$session" "$window" \
        "cd \"$WORKSPACE/$name\" && mvn clean install -Dmaven.test.skip=true && mvn spring-boot:run -DENV_VAR=local"
}

# Launches a UI in a tmux window with its port from services.conf.
# Usage: start_ui_in_tmux <session_name> <ui_name>
start_ui_in_tmux() {
    local session="$1"
    local name="$2"
    local port="${UI_PORT[$name]}"
    local window
    window=$(echo "$name" | tr '[:upper:]' '[:lower:]')

    # Serve the LOCAL configuration so the app talks to localhost APIs. Bare
    # `ng serve` uses the repo's default (development) configuration, which
    # file-replaces environment.ts with environment.development.ts (remote dev
    # server). setup_ui injects a `local` configuration that uses
    # environment.local.ts; select it explicitly here.
    local serve_cmd="ng serve --configuration=local"
    [ -n "$port" ] && serve_cmd="ng serve --configuration=local --port=$port"

    run_in_tmux "$session" "$window" \
        "cd \"$WORKSPACE/$name\" && $serve_cmd"
}

# ── Product → service resolution ─────────────────────────────────────────────

# Unions the APIs required by one or more products, preserving dependency
# order (Common-API, Identity-API first; then product APIs in the order
# they appear in PRODUCT_APIS). Prints one API name per line, deduplicated.
# Usage: resolve_apis <product1> [product2 …]
resolve_apis() {
    local -a ordered=()
    local -A seen=()
    # Anchors first so they're always built and started before dependents.
    for anchor in Common-API Identity-API BeneficiaryID-Generation-API; do
        for p in "$@"; do
            local list="${PRODUCT_APIS[$p]}"
            for api in $list; do
                if [ "$api" = "$anchor" ] && [ -z "${seen[$api]}" ]; then
                    ordered+=("$api")
                    seen[$api]=1
                fi
            done
        done
    done
    for p in "$@"; do
        local list="${PRODUCT_APIS[$p]}"
        for api in $list; do
            if [ -z "${seen[$api]}" ]; then
                ordered+=("$api")
                seen[$api]=1
            fi
        done
    done
    printf '%s\n' "${ordered[@]}"
}

# Unions the UIs required by one or more products. Usage: resolve_uis <p1> [p2 …]
resolve_uis() {
    local -a ordered=()
    local -A seen=()
    for p in "$@"; do
        local list="${PRODUCT_UIS[$p]}"
        for ui in $list; do
            if [ -z "${seen[$ui]}" ]; then
                ordered+=("$ui")
                seen[$ui]=1
            fi
        done
    done
    printf '%s\n' "${ordered[@]}"
}

# ── Guardrails ───────────────────────────────────────────────────────────────

# Fails if any listed TCP port is already bound. Usage: port_conflict_check <p1> [p2 …]
port_conflict_check() {
    local conflicts=()
    for port in "$@"; do
        if lsof -iTCP:"$port" -sTCP:LISTEN -P 2>/dev/null | tail -n +2 | grep -q .; then
            conflicts+=("$port")
        fi
    done
    if [ ${#conflicts[@]} -gt 0 ]; then
        log_error "ports" "Ports already in use: ${conflicts[*]}"
        log_error "ports" "Free them or pass --force (where supported) before starting."
        for port in "${conflicts[@]}"; do
            log_error "ports" "Holder on :$port —"
            lsof -iTCP:"$port" -sTCP:LISTEN -P 2>/dev/null | tail -n +2 | awk '{printf "          %s %s (pid %s)\n", $1, $9, $2}'
        done
        return 1
    fi
}

# Fails if total RAM (GB) is below the threshold. Usage: memory_check <min_gb>
memory_check() {
    local min_gb="$1"
    local total_bytes=0
    case "$(uname -s)" in
        Darwin) total_bytes=$(sysctl -n hw.memsize 2>/dev/null || echo 0) ;;
        Linux)
            if [ -r /proc/meminfo ]; then
                local kb
                kb=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
                total_bytes=$((kb * 1024))
            fi
            ;;
    esac
    local total_gb=$((total_bytes / 1024 / 1024 / 1024))
    if [ "$total_gb" -lt "$min_gb" ]; then
        log_error "memory" "Full-platform mode needs at least ${min_gb} GB RAM; detected ${total_gb} GB."
        log_error "memory" "Re-run with --force to override (at your own risk) or pick a single-product mode."
        return 1
    fi
    log_info "memory" "Detected ${total_gb} GB RAM — proceeding."
}

# Prints the expected URLs for the APIs and UIs in the given lists.
# Usage: print_endpoints <"api1 api2…"> <"ui1 ui2…">
print_endpoints() {
    local apis="$1"
    local uis="$2"
    echo ""
    log_info "main" "Service endpoints once startup completes:"
    for api in $apis; do
        local port="${API_PORT[$api]}"
        [ -n "$port" ] && printf "  %-32s  http://localhost:%s/swagger-ui.html\n" "$api" "$port"
    done
    for ui in $uis; do
        local port="${UI_PORT[$ui]}"
        [ -n "$port" ] && printf "  %-32s  http://localhost:%s\n" "$ui" "$port"
    done
    echo ""
}
