#!/bin/bash
# Interactive, gum-driven wizard for the AMRIT local setup.
# Source this file; do not run directly. Requires: ensure_gum passed,
# lib/services.conf, lib/products.conf, lib/common.sh, lib/launchers.sh,
# lib/engine.sh all sourced.

# ── Helper prompts ───────────────────────────────────────────────────────────

# Pretty-prints a product option label: "ecd — Early Childhood Development".
_product_label() {
    local key="$1"
    printf "%s — %s" "$key" "${PRODUCT_DESC[$key]}"
}

# Extracts the product key from a label produced by _product_label.
_product_key_from_label() { echo "$1" | awk '{print $1}'; }

# ── Wizard phases ────────────────────────────────────────────────────────────

# Prompts for a workspace directory, prefilling the current WORKSPACE default.
# Validates and creates the chosen path. Stays in a loop until a usable path
# is confirmed or the user aborts.
_wizard_choose_workspace() {
    local default="$WORKSPACE"
    local input
    while :; do
        input=$(gum input \
            --header="Where should AMRIT repos (APIs, UIs) be cloned?" \
            --placeholder="$default" \
            --value="$default" \
            --width=80) || return 1
        [ -z "$input" ] && input="$default"
        if resolve_workspace "$input" "interactive"; then
            return 0
        fi
        gum confirm "Try a different path?" || return 1
    done
}

_wizard_choose_action() {
    # Banner goes to the terminal (stderr) so it doesn't contaminate the
    # captured stdout from gum choose.
    gum style --foreground 212 --bold --padding "1 2" --border rounded --border-foreground 63 \
        "AMRIT Local Setup Wizard" >&2

    gum choose --height 8 --header "What do you want to do?" \
        "Run a single product (quick demo)" \
        "Run multiple products together" \
        "Run the full AMRIT platform (all APIs + all UIs)" \
        "Bring up infrastructure only (for IDE debugging)" \
        "Reset DB + master data" \
        "Quit"
}

_wizard_choose_product() {
    local -a labels=()
    for key in "${PRODUCT_ORDER[@]}"; do
        labels+=("$(_product_label "$key")")
    done
    local label
    label=$(gum choose --height 10 --header "Select product:" "${labels[@]}") || return 1
    _product_key_from_label "$label"
}

_wizard_choose_products_multi() {
    local -a labels=()
    for key in "${PRODUCT_ORDER[@]}"; do
        labels+=("$(_product_label "$key")")
    done
    local selections
    selections=$(gum choose --no-limit --height 10 \
        --header "Select products (Space toggles, Enter confirms):" \
        "${labels[@]}") || return 1
    local keys=""
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        keys+="$(_product_key_from_label "$line") "
    done <<< "$selections"
    echo "${keys% }"
}

_wizard_confirm_one_time_steps() {
    # Presents the three idempotent steps and lets the user skip any.
    # Sentinels pre-check so defaults are smart.
    local steps_header="One-time steps — untick to skip:"

    local default_selection="Start infrastructure"
    [ ! -f "$AMRIT_SETUP_DIR/.db_migrated" ] && default_selection+="\nRun DB migrations"
    [ ! -f "$AMRIT_SETUP_DIR/.data_loaded" ] && default_selection+="\nLoad master data"

    local selected
    selected=$(gum choose --no-limit --height 6 --header "$steps_header" \
        --selected "$(echo -e "$default_selection" | paste -sd, -)" \
        "Start infrastructure" \
        "Run DB migrations" \
        "Load master data") || return 1

    OPT_SKIP_INFRA=1; OPT_SKIP_DB=1; OPT_SKIP_DATA=1
    while IFS= read -r line; do
        case "$line" in
            "Start infrastructure") OPT_SKIP_INFRA="" ;;
            "Run DB migrations")    OPT_SKIP_DB="" ;;
            "Load master data")     OPT_SKIP_DATA="" ;;
        esac
    done <<< "$selected"
}

_wizard_summary_and_confirm() {
    local products="$1"
    local full_flag="$2"

    local api_list ui_list
    if [ -n "$full_flag" ]; then
        # Full platform mirrors engine.sh's direct-registry expansion —
        # resolve_apis("all") would fail since "all" is not a product key.
        api_list="Common-API Identity-API BeneficiaryID-Generation-API"
        local api ui
        for api in "${!API_REPO[@]}"; do
            case "$api" in
                Common-API|Identity-API|BeneficiaryID-Generation-API) ;;
                *) api_list+=" $api" ;;
            esac
        done
        ui_list=""
        for ui in "${!UI_REPO[@]}"; do ui_list+="$ui "; done
        ui_list="${ui_list% }"
    else
        api_list=$(resolve_apis $products | tr '\n' ' ')
        ui_list=$(resolve_uis $products | tr '\n' ' ')
    fi

    local skip_infra_str="run"; [ -n "$OPT_SKIP_INFRA" ] && skip_infra_str="skip"
    local skip_db_str="run";    [ -n "$OPT_SKIP_DB" ]    && skip_db_str="skip"
    local skip_data_str="run";  [ -n "$OPT_SKIP_DATA" ]  && skip_data_str="skip"

    gum style --padding "1 2" --border rounded --border-foreground 240 \
"Selection summary

Products:   $products
APIs:       $api_list
UIs:        $ui_list

Infra:      $skip_infra_str
Migrations: $skip_db_str
Master data: $skip_data_str"

    gum confirm "Proceed?" || return 1
}

# ── Top-level dispatcher ─────────────────────────────────────────────────────

# Drives the entire wizard flow. Sets SELECTED_PRODUCTS / OPT_* based on
# user input, then calls run_selection from engine.sh.
run_wizard() {
    _wizard_choose_workspace || return 1

    local action
    action=$(_wizard_choose_action) || return 1

    case "$action" in
        "Quit") log_info "wizard" "Goodbye."; return 0 ;;

        "Run a single product"*)
            local key
            key=$(_wizard_choose_product) || return 1
            SELECTED_PRODUCTS="$key"
            ;;

        "Run multiple products together")
            local keys
            keys=$(_wizard_choose_products_multi) || return 1
            if [ -z "$keys" ]; then
                log_error "wizard" "No product selected."; return 1
            fi
            SELECTED_PRODUCTS="$keys"
            ;;

        "Run the full AMRIT platform"*)
            SELECTED_PRODUCTS="all"
            ;;

        "Bring up infrastructure only"*)
            log_info "wizard" "Starting infrastructure only."
            apply_reset_flags "${RESET_ARGS[@]}"
            start_infrastructure
            log_info "wizard" "Infra up. Run your APIs/UIs from your IDE against localhost:3306/6379/27017/9200."
            return 0
            ;;

        "Reset DB + master data")
            rm -f "$AMRIT_SETUP_DIR/.db_migrated" "$AMRIT_SETUP_DIR/.data_loaded"
            log_info "wizard" "Sentinels cleared. Re-run the wizard to re-apply migrations and data."
            return 0
            ;;
    esac

    _wizard_confirm_one_time_steps || return 1
    _wizard_summary_and_confirm "$SELECTED_PRODUCTS" "$([ "$SELECTED_PRODUCTS" = "all" ] && echo 1)" || return 1
    run_selection
}
