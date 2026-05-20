# ── Top-level menu header (full banner + system info) ────────────
get_menu_header() {
    print_banner "${UI_MODE:-}"
    print_system_info
}

# ── Compact one-line header for submenus ─────────────────────────
get_compact_header() {
    local label="${1:-}"
    local mode="${UI_MODE:-}"
    local os_label="${DISTRO_PRETTY:-Unknown OS}"
    echo -e "${C_BOLD}AGV Easy Install v${SCRIPT_VERSION}${C_RESET} ${C_DIM}|${C_RESET} ${os_label} ${C_DIM}|${C_RESET} ${mode:+${C_YELLOW}${mode}${C_RESET} ${C_DIM}|${C_RESET} }${label}"
}

# ── Wizard Step 1: Intent Question ──────────────────────────────
main_menu() {
    bootstrap_ui
    clear || true
    echo ""
    
    local options=(
        "Cancel"
        "🎓 Set up for lab (IDE + CLI, one click)"
        "⚡ Install or update a specific tool  →"
        "🧹 Manage existing installation  →"
        "🖥️  Demo UI (sandbox mode)"
    )

    if command -v gum >/dev/null 2>&1; then
        local header
        header=$(get_menu_header)
        CHOICE=$(gum filter --header="$header" --no-limit --no-strict --indicator="❯ " --placeholder="Select an option or type a secret..." "${options[@]}") || CHOICE="Cancel"
    else
        clear || true
        get_menu_header
        log_warn "UI dependencies failed to load. Falling back to simple menu."
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-5]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Cancel" ;;
            2) CHOICE="lab" ;;
            3) CHOICE="specific" ;;
            4) CHOICE="manage" ;;
            5) CHOICE="Demo" ;;
            [Gg]oogle) CHOICE="Google" ;;
            *) CHOICE="Cancel" ;;
        esac
    fi

    case "$CHOICE" in
        "Cancel"*) choice="cancel" ;;
        *"Set up for lab"*|*"lab"*) choice="fast_track" ;;
        *"Install or update"*|*"specific"*) choice="install" ;;
        *"Manage"*|*"manage"*) choice="cleanup" ;;
        *"Demo"*) choice="demo" ;;
        [Gg]oogle)
            log_info "Opening Course Catalog..."
            local opener="xdg-open"
            if [ "$PLATFORM" = "Darwin" ]; then opener="open"
            elif grep -qi "microsoft" /proc/version 2>/dev/null; then opener="wslview"
            fi
            run_cmd "$opener" "https://catalog.google.com" || true
            choice="cancel"
            ;;
        *) choice="cancel" ;;
    esac
}

# ── Wizard Step 2a: Fast-Track Setup ────────────────────────────
# Globals set by this function:
#   FAST_TRACK_PRODUCTS  – space-separated list of selected products (ide cli sdk)
#   FAST_TRACK_METHOD    – install method for IDE (brew repo binary)
FAST_TRACK_PRODUCTS=""
FAST_TRACK_METHOD=""

fast_track_setup() {
    FAST_TRACK_PRODUCTS=""
    FAST_TRACK_METHOD=""

    # ── Step A: Which products? (multi-select) ──
    clear || true
    echo ""
    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select tools to install (space to toggle)")
        local selected
        selected=$(gum choose --no-limit --header="$cheader" \
            --selected="Antigravity IDE,Antigravity CLI (agy)" \
            "Antigravity IDE" \
            "Antigravity CLI (agy)" \
            "Antigravity SDK (Python)") || selected=""
    else
        echo "Select tools to install (comma-separated, e.g. 1,2):"
        echo "1) Antigravity IDE"
        echo "2) Antigravity CLI (agy)"
        echo "3) Antigravity SDK (Python)"
        read -r -p "Choice [1,2]: " nums < /dev/tty
        local selected=""
        case "$nums" in
            *1*) selected="Antigravity IDE" ;;
        esac
        case "$nums" in
            *2*) selected="${selected:+$selected\n}Antigravity CLI" ;;
        esac
        case "$nums" in
            *3*) selected="${selected:+$selected\n}Antigravity SDK" ;;
        esac
    fi

    if [ -z "$selected" ]; then
        choice="cancel"
        return
    fi

    # Parse selections into a simple flag string
    if echo "$selected" | grep -q "IDE"; then FAST_TRACK_PRODUCTS="ide"; fi
    if echo "$selected" | grep -q "CLI"; then FAST_TRACK_PRODUCTS="${FAST_TRACK_PRODUCTS:+$FAST_TRACK_PRODUCTS }cli"; fi
    if echo "$selected" | grep -q "SDK"; then FAST_TRACK_PRODUCTS="${FAST_TRACK_PRODUCTS:+$FAST_TRACK_PRODUCTS }sdk"; fi

    # ── Step B: IDE install method (if IDE selected) ──
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then
        clear || true
        echo ""
        local rec_brew="" rec_repo="" rec_bin=""
        case "$RECOMMENDED" in
            1) rec_brew=" ★" ;;
            2) rec_repo=" ★" ;;
            3) rec_bin=" ★" ;;
        esac

        if command -v gum >/dev/null 2>&1; then
            local mheader
            mheader=$(get_compact_header "How should the IDE be installed?")
            CHOICE=$(gum choose --header="$mheader" \
                "Homebrew (cross-platform, no sudo)${rec_brew}" \
                "System Repo (APT/DNF, needs sudo)${rec_repo}" \
                "Official Binary / Tarball${rec_bin}" \
                "Cancel") || CHOICE="Cancel"
        else
            echo ""
            echo "How should the IDE be installed?"
            echo "1) Homebrew (cross-platform, no sudo)${rec_brew}"
            echo "2) System Repo (APT/DNF, needs sudo)${rec_repo}"
            echo "3) Official Binary / Tarball${rec_bin}"
            echo "4) Cancel"
            read -r -p "Select method [1-4]: " num < /dev/tty
            case "$num" in
                1) CHOICE="Homebrew" ;;
                2) CHOICE="System" ;;
                3) CHOICE="Binary" ;;
                *) CHOICE="Cancel" ;;
            esac
        fi

        case "$CHOICE" in
            *"Homebrew"*) FAST_TRACK_METHOD="brew" ;;
            *"System"*) FAST_TRACK_METHOD="repo" ;;
            *"Binary"*|*"Tarball"*) FAST_TRACK_METHOD="binary" ;;
            *) choice="cancel"; return ;;
        esac
    fi

    # ── Step C: Summary & confirm ──
    clear || true
    echo ""
    local summary="📦 Ready to install:"
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then
        local method_label="Homebrew"
        case "$FAST_TRACK_METHOD" in
            repo) method_label="System Repo" ;;
            binary) method_label="Official Binary" ;;
        esac
        summary="${summary}\n  ✦ Antigravity IDE  (v${DEFAULT_IDE_VERSION}) via ${method_label}"
    fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then
        summary="${summary}\n  ✦ Antigravity CLI  (v${DEFAULT_CLI_VERSION})"
    fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then
        summary="${summary}\n  ✦ Antigravity SDK  (v${DEFAULT_SDK_VERSION}) via pip"
    fi

    if command -v gum >/dev/null 2>&1; then
        echo -e "$summary" | gum style --border rounded --border-foreground 33 --padding "1 2" --margin "0 2"
        echo ""
        local cheader2
        cheader2=$(get_compact_header "Confirm")
        CHOICE=$(gum choose --header="$cheader2" "Install now" "Cancel") || CHOICE="Cancel"
    else
        echo -e "$summary"
        echo ""
        echo "1) Install now"
        echo "2) Cancel"
        read -r -p "Proceed? [1-2]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Install now" ;;
            *) CHOICE="Cancel" ;;
        esac
    fi

    case "$CHOICE" in
        "Install now"*) choice="fast_track_go" ;;
        *) choice="cancel" ;;
    esac
}

# ── Wizard Step 2b: Tool Picker (specific tool) ────────────────
install_submenu() {
    clear || true
    echo ""
    local rec_brew="" rec_repo="" rec_bin="  "
    case "$RECOMMENDED" in
        1) rec_brew="★ " ;;
        2) rec_repo="★ " ;;
        3) rec_bin="★ " ;;
    esac

    local options=(
        "Back"
        "${rec_brew}Homebrew (cross-platform, no sudo)"
        "${rec_repo}System Repo (APT/DNF, needs sudo)"
        "${rec_bin}Official Binary IDE  →"
        "Antigravity CLI (agy)  →"
        "Antigravity SDK (Python)  →"
    )

    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Choose install method")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Choose install method:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select method [1-6]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Back" ;;
            2) CHOICE="Homebrew" ;;
            3) CHOICE="System" ;;
            4) CHOICE="Official Binary IDE" ;;
            5) CHOICE="CLI" ;;
            6) CHOICE="SDK" ;;
            *) CHOICE="Back" ;;
        esac
    fi

    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *"Homebrew"*) choice="brew" ;;
        *"System"*) choice="repo" ;;
        *"Binary IDE"*) choice="binary_menu" ;;
        *"CLI"*) choice="cli_menu" ;;
        *"SDK"*) choice="sdk_menu" ;;
        *) choice="back" ;;
    esac
}

# ── Cleanup sub-menu ────────────────────────────────────────────
cleanup_submenu() {
    clear || true
    echo ""
    local options=(
        "Back"
        "Uninstall Antigravity"
        "Save manager (add 'antigravity-manager' command)"
        "Remove manager (delete this script)"
    )

    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Manage installation")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Manage installation:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-4]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Back" ;;
            2) CHOICE="Uninstall" ;;
            3) CHOICE="Save" ;;
            4) CHOICE="Remove manager" ;;
            *) CHOICE="Back" ;;
        esac
    fi

    case "$CHOICE" in
        "Back"*) choice="back" ;;
        "Uninstall"*) choice="remove" ;;
        "Save"*) choice="save" ;;
        "Remove"*) choice="remove_mgr" ;;
        *) choice="back" ;;
    esac
}

# ── Post-Install Follow-up ──────────────────────────────────────
post_install_menu() {
    clear || true
    echo ""
    local done_msg="🎉 Setup Complete!"
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then done_msg="${done_msg}\nIDE:  v${DEFAULT_IDE_VERSION} installed"; fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then done_msg="${done_msg}\nCLI:  v${DEFAULT_CLI_VERSION} installed"; fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then done_msg="${done_msg}\nSDK:  v${DEFAULT_SDK_VERSION} installed"; fi
    done_msg="${done_msg}\nLaunch: antigravity"

    if command -v gum >/dev/null 2>&1; then
        echo -e "$done_msg" | gum style --border double --border-foreground 46 --padding "1 2"
        echo ""
        local cheader
        cheader=$(get_compact_header "What next?")
        CHOICE=$(gum choose --header="$cheader" \
            "🚀 Launch Antigravity now" \
            "📁 Create workspace folder (~/my-antigravity-work)" \
            "💾 Save this installer for later" \
            "✅ Done — exit") || CHOICE="Done"
    else
        log_info "${C_GREEN}${C_BOLD}${done_msg}${C_RESET}"
        echo ""
        echo "What next?"
        echo "1) Launch Antigravity now"
        echo "2) Create workspace folder"
        echo "3) Save this installer for later"
        echo "4) Done — exit"
        read -r -p "Select option [1-4]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Launch" ;;
            2) CHOICE="Create" ;;
            3) CHOICE="Save" ;;
            *) CHOICE="Done" ;;
        esac
    fi

    case "$CHOICE" in
        *"Launch"*)
            log_info "Launching Antigravity..."
            local opener="antigravity"
            if command -v "$opener" >/dev/null 2>&1; then
                "$opener" &
            else
                log_warn "Antigravity command not found yet. Try closing and reopening your terminal, then type: antigravity"
            fi
            ;;
        *"workspace"*|*"Create"*)
            if [ ! -d "$WORKSPACE_DIR" ]; then
                mkdir -p "$WORKSPACE_DIR"
                log_info "✅ Created workspace at ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
            else
                log_info "Workspace already exists at ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
            fi
            ;;
        *"Save"*|*"installer"*)
            save_manager_locally
            ;;
        *) ;; # Done — exit
    esac
}

# ── Version Selection Helpers ────────────────────────────────────
list_ide_versions() {
    local json_file="/tmp/versions.json"
    if [ -f "$json_file" ]; then
        awk '
          BEGIN { in_ide=0 }
          $0 ~ "\"ide\"" { in_ide=1; next }
          in_ide && $0 ~ "}" && $0 !~ "," { in_ide=0 }
          in_ide && $0 ~ "^    \"[0-9.]+\":" {
            split($0, a, "\"");
            print a[2]
          }
        ' "$json_file" 2>/dev/null
    else
        echo "$DEFAULT_IDE_VERSION"
    fi
}

list_cli_versions() {
    local json_file="/tmp/versions.json"
    if [ -f "$json_file" ]; then
        awk '
          BEGIN { in_cli=0 }
          $0 ~ "\"cli\"" { in_cli=1; next }
          in_cli && $0 ~ "}" && $0 !~ "," { in_cli=0 }
          in_cli && $0 ~ "^    \"[0-9.]+\":" {
            split($0, a, "\"");
            print a[2]
          }
        ' "$json_file" 2>/dev/null
    else
        echo "$DEFAULT_CLI_VERSION"
    fi
}

list_sdk_versions() {
    local json_file="/tmp/versions.json"
    if [ -f "$json_file" ]; then
        awk '
          BEGIN { in_sdk=0; in_vers=0 }
          $0 ~ "\"sdk\"" { in_sdk=1; next }
          in_sdk && $0 ~ "}" && $0 !~ "," { in_sdk=0 }
          in_sdk && $0 ~ "\"versions\"" { in_vers=1; next }
          in_vers && $0 ~ "]" { in_vers=0 }
          in_vers && $0 ~ "\"[0-9.]+\"" {
            split($0, a, "\"");
            print a[2]
          }
        ' "$json_file" 2>/dev/null
    else
        echo "$DEFAULT_SDK_VERSION"
    fi
}

choose_ide_version() {
    fetch_versions_json || true
    clear || true
    
    local versions=()
    while IFS= read -r line; do
        versions+=("$line")
    done < <(list_ide_versions)
    
    if [ ${#versions[@]} -eq 0 ]; then
        versions+=("$DEFAULT_IDE_VERSION")
    fi
    
    local options=("Back")
    for v in "${versions[@]}"; do
        if [ "$v" = "$DEFAULT_IDE_VERSION" ]; then
            options+=("$v (Latest / Default)")
        else
            options+=("$v")
        fi
    done
    
    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select IDE version")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Select IDE version:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-${#options[@]}]: " num < /dev/tty
        local idx=$((num-1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#options[@]} ]; then
            CHOICE="${options[$idx]}"
        else
            CHOICE="Back"
        fi
    fi
    
    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *)
            local selected_ver
            selected_ver=$(echo "$CHOICE" | awk '{print $1}')
            choice="binary:$selected_ver"
            ;;
    esac
}

choose_cli_version() {
    fetch_versions_json || true
    clear || true
    
    local versions=()
    while IFS= read -r line; do
        versions+=("$line")
    done < <(list_cli_versions)
    
    if [ ${#versions[@]} -eq 0 ]; then
        versions+=("$DEFAULT_CLI_VERSION")
    fi
    
    local options=("Back")
    for v in "${versions[@]}"; do
        if [ "$v" = "$DEFAULT_CLI_VERSION" ]; then
            options+=("$v (Latest / Default)")
        else
            options+=("$v")
        fi
    done
    
    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select CLI version")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Select CLI version:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-${#options[@]}]: " num < /dev/tty
        local idx=$((num-1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#options[@]} ]; then
            CHOICE="${options[$idx]}"
        else
            CHOICE="Back"
        fi
    fi
    
    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *)
            local selected_ver
            selected_ver=$(echo "$CHOICE" | awk '{print $1}')
            choice="cli:$selected_ver"
            ;;
    esac
}

choose_sdk_version() {
    fetch_versions_json || true
    clear || true
    
    local versions=()
    while IFS= read -r line; do
        versions+=("$line")
    done < <(list_sdk_versions)
    
    if [ ${#versions[@]} -eq 0 ]; then
        versions+=("$DEFAULT_SDK_VERSION")
    fi
    
    local options=("Back" "latest (Latest / Default)")
    for v in "${versions[@]}"; do
        options+=("$v")
    done
    
    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select SDK version")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Select SDK version:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-${#options[@]}]: " num < /dev/tty
        local idx=$((num-1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#options[@]} ]; then
            CHOICE="${options[$idx]}"
        else
            CHOICE="Back"
        fi
    fi
    
    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *)
            local selected_ver
            selected_ver=$(echo "$CHOICE" | awk '{print $1}')
            choice="sdk:$selected_ver"
            ;;
    esac
}

# ── Mock actions for sandbox mode ───────────────────────────────
run_mock_action() {
    local action="$1"

    case "$action" in
        fast_track_go)
            local method_label="Homebrew"
            case "$FAST_TRACK_METHOD" in repo) method_label="System Repo" ;; binary) method_label="Official Binary" ;; esac

            log_info "${C_MAG}🚀 Starting setup (Mock)...${C_RESET}"
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then
                run_cmd_ui "Installing Antigravity IDE (v${DEFAULT_IDE_VERSION}) via ${method_label}..." sleep 1.5
            fi
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then
                run_cmd_ui "Installing Antigravity CLI (v${DEFAULT_CLI_VERSION})..." sleep 1
            fi
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then
                run_cmd_ui "Installing Antigravity SDK (v${DEFAULT_SDK_VERSION}) via pip..." sleep 1
            fi
            echo ""
            local done_msg="🎉 Mock Setup Complete!"
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then done_msg="${done_msg}\nIDE:  v${DEFAULT_IDE_VERSION} installed via ${method_label}"; fi
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then done_msg="${done_msg}\nCLI:  v${DEFAULT_CLI_VERSION} installed"; fi
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then done_msg="${done_msg}\nSDK:  v${DEFAULT_SDK_VERSION} installed"; fi
            done_msg="${done_msg}\nLaunch: antigravity"
            if command -v gum >/dev/null 2>&1; then
                echo -e "$done_msg" | gum style --border double --border-foreground 46 --padding "1 2"
            else
                log_info "${C_GREEN}${C_BOLD}${done_msg}${C_RESET}"
            fi
            ;;
        brew|repo|binary*|cli*|sdk*)
            local method="Homebrew"
            local product="Google Antigravity IDE"
            local version=""
            
            if [[ "$action" == *":"* ]]; then
                version=" (version $(echo "$action" | cut -d':' -f2))"
            fi
            
            if [[ "$action" == "binary"* ]]; then
                method="Official Binary"
                product="Google Antigravity IDE"
            elif [[ "$action" == "cli"* ]]; then
                method="Antigravity CLI"
                product="Antigravity CLI (agy)"
            elif [[ "$action" == "sdk"* ]]; then
                method="Antigravity SDK"
                product="Antigravity SDK (Python)"
            elif [ "$action" = "repo" ]; then
                method="System Repo"
            fi

            log_info "${C_MAG}🚀 Starting mock installation of ${product}${version} via ${method}...${C_RESET}"
            if [[ "$action" == "cli"* ]]; then
                run_cmd_ui "Downloading Antigravity CLI installer..." sleep 1
                run_cmd_ui "Executing installation script..." sleep 1.5
                echo ""
                log_info "${C_GREEN}${C_BOLD}🎉 Mock Installation Complete!${C_RESET}"
                log_info "  ${C_CYAN}▸${C_RESET} Launch:    ${C_BOLD}agy --help${C_RESET}"
                return
            fi
            
            if [[ "$action" == "sdk"* ]]; then
                run_cmd_ui "Connecting to PyPI..." sleep 1
                run_cmd_ui "Installing package 'google-antigravity'..." sleep 1.5
                echo ""
                log_info "${C_GREEN}${C_BOLD}🎉 Mock Installation Complete!${C_RESET}"
                log_info "  ${C_CYAN}▸${C_RESET} Verify:    ${C_BOLD}python3 -c \"import google_antigravity\"${C_RESET}"
                return
            fi

            run_cmd_ui "Downloading Antigravity payload..." sleep 1.5
            run_cmd_ui "Extracting binaries..." sleep 1
            echo ""
            log_warn "Antigravity occasionally fails to find Chrome when installed via Brew or Binary."
            log_info "We found a valid Chrome binary at: ${C_BOLD}/usr/bin/google-chrome${C_RESET}"

            # shellcheck disable=SC2088
            local mock_rc="~/.bashrc"
            # shellcheck disable=SC2088
            if [ "$PLATFORM" = "Darwin" ]; then mock_rc="~/.zprofile"; fi

            if command -v gum >/dev/null 2>&1; then
                gum confirm "Would you like to automatically configure Antigravity to use this browser?" || true
                echo ""
                log_warn "$HOME/.local/bin is not in your PATH."
                gum confirm "Would you like to automatically add it to $mock_rc?" || true
                echo ""
                run_cmd_ui "Applying configuration..." sleep 1
                echo ""
                gum style --border double --border-foreground 46 --padding "1 2" "🎉 Mock Installation Complete!
Launch: antigravity
Workspace: $WORKSPACE_DIR"
            else
                echo -ne "${C_YELLOW}Would you like to automatically configure Antigravity to use this browser? [Y/n]: ${C_RESET}"
                read -r _ < /dev/tty || true
                echo ""
                log_warn "$HOME/.local/bin is not in your PATH."
                echo -ne "${C_YELLOW}Would you like to automatically add it to $mock_rc? [Y/n]: ${C_RESET}"
                read -r _ < /dev/tty || true
                echo ""
                log_info "${C_GREEN}${C_BOLD}🎉 Mock Installation Complete!${C_RESET}"
                log_info "  ${C_CYAN}▸${C_RESET} Launch:    ${C_BOLD}antigravity${C_RESET}"
                log_info "  ${C_CYAN}▸${C_RESET} Workspace: ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
            fi
            ;;
        save)
            log_info "${C_MAG}🚀 Saving manager locally (Mock)...${C_RESET}"
            run_cmd_ui "Copying script to ~/.local/bin/antigravity-manager..." sleep 1
            log_info "✅ Manager saved successfully!"
            ;;
        remove)
            log_info "${C_MAG}🚀 Uninstalling Antigravity (Mock)...${C_RESET}"
            if command -v gum >/dev/null 2>&1; then
                gum confirm "Are you sure you want to completely remove Antigravity?" || true
            fi
            run_cmd_ui "Removing app files..." sleep 1
            run_cmd_ui "Removing state directories..." sleep 0.5
            log_info "✅ Uninstallation complete!"
            ;;
        remove_mgr)
            log_info "${C_MAG}🚀 Removing manager script (Mock)...${C_RESET}"
            run_cmd_ui "Deleting ~/.local/bin/antigravity-manager..." sleep 1
            log_info "✅ Manager script deleted."
            ;;
    esac
}
