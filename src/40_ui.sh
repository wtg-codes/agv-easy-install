# ── Top-level menu header ────────────────────────────────────────
get_menu_header() {
    print_banner "${UI_MODE:-}"
    print_system_info
}

# ── Wizard Step 1: Intent Question ──────────────────────────────
main_menu() {
    bootstrap_ui
    echo ""
    
    local mgr_opt="Install this script locally"
    if [ -f "$BIN_DIR/antigravity-manager" ]; then
        mgr_opt="Remove this script locally"
    fi

    local options=(
        "Cancel"
        "🎓 Set up for class (IDE + CLI, one click)"
        "⚡ Install or update a specific tool  →"
        "🧹 Manage existing installation  →"
        "$mgr_opt"
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
            2) CHOICE="class" ;;
            3) CHOICE="specific" ;;
            4) CHOICE="manage" ;;
            5) CHOICE="$mgr_opt" ;;
            [Gg]oogle) CHOICE="Google" ;;
            *) CHOICE="Cancel" ;;
        esac
    fi

    case "$CHOICE" in
        "Cancel"*) choice="cancel" ;;
        *"Set up for class"*|*"class"*) choice="fast_track" ;;
        *"Install or update"*|*"specific"*) choice="install" ;;
        *"Manage"*|*"manage"*) choice="cleanup" ;;
        "Install this script"*) choice="save" ;;
        "Remove this script"*) choice="remove_mgr" ;;
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

# ── Wizard Step 2a: Fast-Track Confirmation ─────────────────────
fast_track_setup() {
    echo ""
    local rec_method="Homebrew"
    case "$RECOMMENDED" in
        1) rec_method="Homebrew" ;;
        2) rec_method="System Repo (APT/DNF)" ;;
        3) rec_method="Official Binary" ;;
    esac

    if command -v gum >/dev/null 2>&1; then
        gum style --border rounded --border-foreground 33 --padding "1 2" --margin "0 2" \
            "$(echo -e "${C_BOLD}📦 Ready to install:${C_RESET}")
$(echo -e "  ${C_CYAN}✦${C_RESET} Antigravity IDE  ${C_DIM}(latest — v${DEFAULT_IDE_VERSION})${C_RESET}")
$(echo -e "  ${C_CYAN}✦${C_RESET} Antigravity CLI  ${C_DIM}(latest — v${DEFAULT_CLI_VERSION})${C_RESET}")

$(echo -e "  ${C_DIM}Method: ★ ${rec_method}${C_RESET}")"
        echo ""
        local options=(
            "Install now"
            "Customize..."
            "Cancel"
        )
        CHOICE=$(gum choose --header="Proceed?" "${options[@]}") || CHOICE="Cancel"
    else
        clear || true
        get_menu_header
        echo ""
        echo "📦 Ready to install:"
        echo "  ✦ Antigravity IDE  (latest — v${DEFAULT_IDE_VERSION})"
        echo "  ✦ Antigravity CLI  (latest — v${DEFAULT_CLI_VERSION})"
        echo ""
        echo "  Method: ★ ${rec_method}"
        echo ""
        echo "1) Install now"
        echo "2) Customize..."
        echo "3) Cancel"
        read -r -p "Select option [1-3]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Install now" ;;
            2) CHOICE="Customize" ;;
            *) CHOICE="Cancel" ;;
        esac
    fi

    case "$CHOICE" in
        "Install now"*) choice="fast_track_go" ;;
        "Customize"*) choice="install" ;;
        *) choice="cancel" ;;
    esac
}

# ── Wizard Step 2b: Tool Picker (specific tool) ────────────────
install_submenu() {
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
        local header
        header=$(get_menu_header)
        CHOICE=$(gum filter --header="$header" --no-limit --indicator="❯ " --placeholder="Select a product or installation method..." "${options[@]}") || CHOICE="Back"
    else
        clear || true
        get_menu_header
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
    echo ""
    local options=(
        "Back"
        "Uninstall Antigravity"
        "Save manager (add 'antigravity-manager' command)"
        "Remove manager (delete this script)"
        "Demo UI (sandbox mode)"
    )

    if command -v gum >/dev/null 2>&1; then
        local header
        header=$(get_menu_header)
        CHOICE=$(gum filter --header="$header" --no-limit --indicator="❯ " --placeholder="Select a cleanup option..." "${options[@]}") || CHOICE="Back"
    else
        clear || true
        get_menu_header
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-5]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Back" ;;
            2) CHOICE="Uninstall" ;;
            3) CHOICE="Save" ;;
            4) CHOICE="Remove manager" ;;
            5) CHOICE="Demo" ;;
            *) CHOICE="Back" ;;
        esac
    fi

    case "$CHOICE" in
        "Back"*) choice="back" ;;
        "Uninstall"*) choice="remove" ;;
        "Save"*) choice="save" ;;
        "Remove"*) choice="remove_mgr" ;;
        "Demo"*) choice="demo" ;;
        *) choice="back" ;;
    esac
}

# ── Post-Install Follow-up ──────────────────────────────────────
post_install_menu() {
    echo ""
    if command -v gum >/dev/null 2>&1; then
        local options=(
            "🚀 Launch Antigravity now"
            "📁 Create workspace folder (~/my-antigravity-work)"
            "💾 Save this installer for later"
            "✅ Done — exit"
        )
        CHOICE=$(gum choose --header="What next?" "${options[@]}") || CHOICE="Done"
    else
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
        local header
        header=$(get_menu_header)
        CHOICE=$(gum filter --header="$header" --no-limit --indicator="❯ " --placeholder="Select IDE version to install..." "${options[@]}") || CHOICE="Back"
    else
        clear || true
        get_menu_header
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
        local header
        header=$(get_menu_header)
        CHOICE=$(gum filter --header="$header" --no-limit --indicator="❯ " --placeholder="Select CLI version to install..." "${options[@]}") || CHOICE="Back"
    else
        clear || true
        get_menu_header
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
        local header
        header=$(get_menu_header)
        CHOICE=$(gum filter --header="$header" --no-limit --indicator="❯ " --placeholder="Select SDK version to install..." "${options[@]}") || CHOICE="Back"
    else
        clear || true
        get_menu_header
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
            log_info "${C_MAG}🚀 Starting fast-track class setup (Mock)...${C_RESET}"
            run_cmd_ui "Installing Antigravity IDE (v${DEFAULT_IDE_VERSION}) via ★ Homebrew..." sleep 1.5
            run_cmd_ui "Downloading Antigravity CLI installer..." sleep 1
            run_cmd_ui "Installing Antigravity CLI (v${DEFAULT_CLI_VERSION})..." sleep 1
            echo ""
            if command -v gum >/dev/null 2>&1; then
                gum style --border double --border-foreground 46 --padding "1 2" "🎉 Mock Class Setup Complete!
IDE:  v${DEFAULT_IDE_VERSION} installed via Homebrew
CLI:  v${DEFAULT_CLI_VERSION} installed
Launch: antigravity"
            else
                log_info "${C_GREEN}${C_BOLD}🎉 Mock Class Setup Complete!${C_RESET}"
                log_info "  ${C_CYAN}▸${C_RESET} IDE:  v${DEFAULT_IDE_VERSION} installed via Homebrew"
                log_info "  ${C_CYAN}▸${C_RESET} CLI:  v${DEFAULT_CLI_VERSION} installed"
                log_info "  ${C_CYAN}▸${C_RESET} Launch: ${C_BOLD}antigravity${C_RESET}"
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
