#!/bin/bash
# Non-interactive orchestrator. Handles flag parsing and exposes
# run_selection(), the single code path used by both flag mode and the wizard.
# Source this file; do not run directly.

# ── Flag parser ──────────────────────────────────────────────────────────────

# Parses CLI flags. Exports:
#   SELECTED_PRODUCTS   — space-separated lowercase product keys, or "all"
#   OPT_SKIP_INFRA, OPT_SKIP_DB, OPT_SKIP_DATA   — 1 if set, empty otherwise
#   OPT_FORCE           — 1 if --force passed
#   RESET_ARGS          — args to forward to apply_reset_flags
# Returns 1 if --help was requested or args are invalid.
parse_flags() {
    SELECTED_PRODUCTS=""
    OPT_SKIP_INFRA=""
    OPT_SKIP_DB=""
    OPT_SKIP_DATA=""
    OPT_FORCE=""
    OPT_WORKSPACE=""
    OPT_ATTACH=""
    RESET_ARGS=()

    for arg in "$@"; do
        case "$arg" in
            --all)                SELECTED_PRODUCTS="all" ;;
            --product=*)          SELECTED_PRODUCTS="${arg#*=}" ;;
            --products=*)         SELECTED_PRODUCTS="$(echo "${arg#*=}" | tr ',' ' ')" ;;
            --workspace=*)        OPT_WORKSPACE="${arg#*=}" ;;
            --skip-infra)         OPT_SKIP_INFRA=1 ;;
            --skip-db)            OPT_SKIP_DB=1 ;;
            --skip-data)          OPT_SKIP_DATA=1 ;;
            --force)              OPT_FORCE=1 ;;
            --attach)             OPT_ATTACH=1 ;;
            --no-attach)          OPT_ATTACH=0 ;;
            --reset-db|--reset-data|--reset-all) RESET_ARGS+=("$arg") ;;
            -h|--help)            print_usage; return 1 ;;
            *)                    log_error "cli" "Unknown flag: $arg"; print_usage; return 1 ;;
        esac
    done

    # Normalise selected products to lowercase, validate each exists.
    if [ -n "$SELECTED_PRODUCTS" ] && [ "$SELECTED_PRODUCTS" != "all" ]; then
        local normalised=""
        for p in $SELECTED_PRODUCTS; do
            local key
            key=$(echo "$p" | tr '[:upper:]' '[:lower:]')
            if [ -z "${PRODUCT_APIS[$key]}" ]; then
                log_error "cli" "Unknown product: $p. Known: ${PRODUCT_ORDER[*]}"
                return 1
            fi
            normalised+="$key "
        done
        SELECTED_PRODUCTS="${normalised% }"
    fi
}

print_usage() {
    cat <<EOF
AMRIT local setup — unified launcher

Usage:
  bash start.sh                              # interactive wizard (requires gum)
  bash start.sh --product=<key>              # run one product
  bash start.sh --products=<k1>,<k2>,…       # run multiple products together
  bash start.sh --all                        # run full AMRIT platform (14 APIs + 10 UIs)

Product keys: ${PRODUCT_ORDER[*]}

Options:
  --workspace=<path>       directory to clone AMRIT repos into
                           (default: parent of AMRIT-DevOps; created if missing)
  --skip-infra             skip 'docker compose up' of MySQL/Redis/Mongo/ES
  --skip-db                skip Flyway migrations
  --skip-data              skip master-data load
  --reset-db               clear DB-migration sentinel, re-run migrations
  --reset-data             clear master-data sentinel, re-run data load
  --reset-all              clear both sentinels
  --force                  bypass memory / port guardrails for --all
  --attach                 attach to the tmux session on completion (no prompt)
  --no-attach              never attach, never prompt (for CI / nohup)

Examples:
  bash start.sh --product=ecd
  bash start.sh --products=ecd,hwc --skip-db --skip-data
  bash start.sh --all --force
EOF
}

# ── Core run ─────────────────────────────────────────────────────────────────

# Given a list of product keys (or the string "all"), provisions infra,
# sets up and launches every required API and UI in a single tmux session.
# Assumes SELECTED_PRODUCTS / OPT_* / RESET_ARGS are already populated.
run_selection() {
    local products="$SELECTED_PRODUCTS"
    local full=""
    if [ "$products" = "all" ]; then
        full=1
    fi

    apply_reset_flags "${RESET_ARGS[@]}"

    # ── Resolve services and determine tmux session name ─────────────────
    local api_list ui_list
    if [ -n "$full" ]; then
        # Full platform: every API and every UI in the registry, with the
        # shared anchors (Common, Identity, BeneficiaryID-Generation) first
        # so dependents find them built when their builds start.
        api_list="Common-API Identity-API BeneficiaryID-Generation-API"
        for api in "${!API_REPO[@]}"; do
            case "$api" in
                Common-API|Identity-API|BeneficiaryID-Generation-API) ;;
                *) api_list+=" $api" ;;
            esac
        done
        ui_list=""
        for ui in "${!UI_REPO[@]}"; do ui_list+="$ui "; done
        ui_list="${ui_list% }"
        products="all"
    else
        api_list=$(resolve_apis $products | tr '\n' ' ')
        ui_list=$(resolve_uis $products | tr '\n' ' ')
    fi

    local session
    if [ -n "$full" ]; then
        session="amrit-all"
    else
        local first
        first=$(echo "$products" | awk '{print $1}')
        if [ "$(echo "$products" | wc -w)" -eq 1 ]; then
            session="amrit-$first"
        else
            session="amrit-multi"
        fi
    fi

    log_info "main" "Selected products:      $products"
    log_info "main" "APIs to launch:         $api_list"
    log_info "main" "UIs to launch:          $ui_list"
    log_info "main" "tmux session:           $session"

    # ── Guardrails (skipped when --force on --all) ───────────────────────
    if [ -n "$full" ] && [ -z "$OPT_FORCE" ]; then
        memory_check 24 || return 1
    fi

    # Collect all ports we're about to bind, do a pre-flight check.
    if [ -z "$OPT_FORCE" ]; then
        local ports=()
        for api in $api_list; do ports+=("${API_PORT[$api]}"); done
        for ui in $ui_list; do ports+=("${UI_PORT[$ui]}"); done
        port_conflict_check "${ports[@]}" || return 1
    fi

    # ── One-time setup ────────────────────────────────────────────────────
    if [ -z "$OPT_SKIP_INFRA" ]; then
        start_infrastructure
    else
        log_info "main" "Skipping infra (--skip-infra)."
    fi

    if [ -z "$OPT_SKIP_DB" ]; then
        run_db_migrations || true
    else
        log_info "main" "Skipping DB migrations (--skip-db)."
    fi

    if [ -z "$OPT_SKIP_DATA" ]; then
        load_master_data
    else
        log_info "main" "Skipping master-data load (--skip-data)."
    fi

    # ── Clone + configure every service before launching anything ────────
    log_info "main" "Cloning and configuring repositories..."
    for api in $api_list; do setup_api_by_name "$api" || return 1; done
    for ui in $ui_list; do setup_ui_by_name "$ui" || return 1; done

    # ── Launch in tmux ───────────────────────────────────────────────────
    # First API gets the initial window; the rest use new-window.
    local first_api
    first_api=$(echo "$api_list" | awk '{print $1}')
    local first_window
    first_window=$(echo "$first_api" | tr '[:upper:]' '[:lower:]')
    create_tmux_session "$session" "$first_window"

    for api in $api_list; do start_api_in_tmux "$session" "$api"; done
    for ui in $ui_list; do start_ui_in_tmux "$session" "$ui"; done

    # ── Report ───────────────────────────────────────────────────────────
    echo ""
    log_info "main" "All services launched in tmux session '$session'."
    log_info "main" "Attach to view logs:  tmux attach -t $session"
    log_info "main" "Switch windows:       Ctrl+b n / p   or   Ctrl+b <number>"
    log_info "main" "Detach (keep running): Ctrl+b d"
    log_info "main" "Stop everything:      tmux kill-session -t $session"
    print_endpoints "$api_list" "$ui_list"
    log_info "main" "First Maven build per API takes several minutes. Be patient."

    # ── Auto-attach offer ────────────────────────────────────────────────
    # Only prompt when a gum-capable TTY is available (wizard path). Flag
    # mode with --attach forces attach; --no-attach suppresses the prompt.
    if [ "$OPT_ATTACH" = "1" ]; then
        exec tmux attach -t "$session"
    elif [ "$OPT_ATTACH" = "0" ]; then
        return 0
    elif [ -t 0 ] && [ -t 1 ] && command -v gum &>/dev/null; then
        if gum confirm "Attach to tmux session '$session' now?"; then
            exec tmux attach -t "$session"
        fi
    fi
}
