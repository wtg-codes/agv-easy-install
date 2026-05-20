print_usage() {
    echo -e "${C_BOLD}Antigravity Manager v${SCRIPT_VERSION}${C_RESET}"
    echo -e "${C_DIM}Usage:${C_RESET} $0 [OPTION]"
    echo "  --install         Interactive installation wizard (default)"
    echo "  --auto            Headless auto-install"
    echo "  --install-brew    Headless Homebrew install"
    echo "  --install-repo    Headless System Repo install"
    echo "  --install-binary  Headless Official Binary install"
    echo "  --install-cli     Headless Antigravity CLI install"
    echo "  --install-jules   Headless Google Jules CLI install"
    echo "  --install-sdk     Headless Antigravity Python SDK install"
    echo "  --fast-track      Headless lab setup (IDE + CLI + Jules)"
    echo "  --remove          Uninstall Antigravity"
    echo "  --demo-ui         Test and view the UI layout without modifying the system"
    echo "  --json            Output machine-readable JSON at end (disables prompts)"
    echo "  --verbose         Enable verbose logging"
    echo "  --quiet           Suppress non-error output"
    echo "  --check           Verify existing installation health"
    echo "  --update          Force update of this manager script"
    echo "  --no-update       Skip checking for manager updates"
    echo "  --version         Show version"
    echo "  --help            Show this help"
}

# Parse CLI arguments
ACTION=""
for arg in "$@"; do
    case "$arg" in
        --install) ACTION="install" ;;
        --auto) ACTION="auto"; AUTO=1 ;;
        --install-brew) ACTION="brew"; AUTO=1 ;;
        --install-repo) ACTION="repo"; AUTO=1 ;;
        --install-binary) ACTION="binary"; AUTO=1 ;;
        --install-cli) ACTION="cli"; AUTO=1 ;;
        --install-jules) ACTION="jules"; AUTO=1 ;;
        --install-sdk) ACTION="sdk"; AUTO=1 ;;
        --fast-track) ACTION="fast_track"; AUTO=1 ;;
        --remove) ACTION="remove" ;;
        --demo-ui) ACTION="demo_ui" ;;
        --json) JSON_OUT=1; QUIET=1 ;;
        --verbose) VERBOSE=1 ;;
        --quiet) QUIET=1 ;;
        --check) ACTION="check" ;;
        --update) ACTION="update" ;;
        --no-update) NO_UPDATE=1 ;;
        --version) ACTION="version" ;;
        --help) ACTION="help" ;;
    esac
done

if [ "$ACTION" = "version" ]; then
    echo "Antigravity Manager v$SCRIPT_VERSION"
    trap - EXIT INT TERM # skip json output
    exit 0
elif [ "$ACTION" = "help" ]; then
    print_usage
    trap - EXIT INT TERM
    exit 0
fi

check_dependencies
detect_platform

# ── Auto-Update Mechanism ───────────────────────────────────────
check_for_updates() {
    if [ "${NO_UPDATE:-0}" -eq 1 ] || [ "${MOCK_MODE:-0}" -eq 1 ]; then return 0; fi
    # Skip if running locally without internet (we check quietly)
    if ! curl -fSsL --head "$MANAGER_URL" >/dev/null 2>&1; then return 0; fi

    local remote_version
    remote_version=$(curl -fSsL "https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/src/00_config.sh" | grep '^SCRIPT_VERSION=' | cut -d'"' -f2)
    
    if [ -n "$remote_version" ] && [ "$remote_version" != "$SCRIPT_VERSION" ]; then
        # Simple string comparison (assumes semver format like 0.2.2)
        # Bash string comparison is sufficient unless version jumps digit places e.g. 0.9.0 -> 0.10.0
        # For a robust approach we could use awk or just always update if !=
        log_info "${C_BLUE}🔄 A newer version of the installer is available ($remote_version). Updating...${C_RESET}"
        
        # We need to securely download the new script and replace ourselves
        local temp_script
        temp_script=$(mktemp)
        if curl -fSsL "$MANAGER_URL" -o "$temp_script" && bash -n "$temp_script"; then
            if [ -w "$0" ]; then
                cp "$temp_script" "$0"
                chmod +x "$0"
                rm -f "$temp_script"
                log_info "${C_GREEN}✅ Update successful! Restarting...${C_RESET}"
                echo ""
                exec "$0" "$@" # Restart with the same arguments!
            elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
                sudo cp "$temp_script" "$0"
                sudo chmod +x "$0"
                rm -f "$temp_script"
                log_info "${C_GREEN}✅ Update successful! Restarting...${C_RESET}"
                echo ""
                exec "$0" "$@"
            else
                log_warn "New version available, but current script is read-only. Run with --no-update to suppress this message."
            fi
        else
            log_error "Failed to download update. Continuing with current version."
        fi
        rm -f "$temp_script"
    fi
}

# If user forced an update
if [ "$ACTION" = "update" ]; then
    log_info "Forcing update check..."
    check_for_updates
    log_info "You are on the latest version ($SCRIPT_VERSION)."
    exit 0
fi

# Automatically check for updates before wizard or headless modes unless json is expected
if [ "$JSON_OUT" -eq 0 ]; then
    check_for_updates "$@"
fi

# ── Fast-Track Lab Setup (headless or wizard-confirmed) ───────
do_fast_track_install() {
    # Count total steps for progress display
    local total=0 step=0
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "vibe"; then total=$((total+1)); fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then total=$((total+1)); fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then total=$((total+1)); fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "jules"; then total=$((total+1)); fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then total=$((total+1)); fi

    log_info "${C_MAG}🎓 Starting setup — installing ${total} tool(s)...${C_RESET}"
    echo ""

    # Install Vibe (if selected)
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "vibe"; then
        step=$((step+1))
        log_info "${C_BOLD}Step ${step}/${total}: Installing Antigravity Vibe...${C_RESET}"
        do_install_binary "vibe"
        echo ""
    fi

    # Install IDE (if selected)
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then
        step=$((step+1))
        log_info "${C_BOLD}Step ${step}/${total}: Installing Antigravity IDE...${C_RESET}"
        case "$FAST_TRACK_METHOD" in
            brew) install_brew ;;
            repo) install_repo ;;
            binary|*) do_install_binary "ide" ;;
        esac
        echo ""
    fi

    # Install CLI (if selected)
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then
        step=$((step+1))
        log_info "${C_BOLD}Step ${step}/${total}: Installing Antigravity CLI...${C_RESET}"
        install_cli
        echo ""
    fi

    # Install Jules (if selected)
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "jules"; then
        step=$((step+1))
        log_info "${C_BOLD}Step ${step}/${total}: Installing Google Jules CLI...${C_RESET}"
        install_jules
        echo ""
    fi

    # Install SDK (if selected)
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then
        step=$((step+1))
        log_info "${C_BOLD}Step ${step}/${total}: Installing Antigravity SDK...${C_RESET}"
        install_sdk
        echo ""
    fi

    save_manager_locally

    echo ""
    local done_msg="🎉 Setup Complete!"
    local mock_bin_name="antigravity"
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "vibe"; then
        done_msg="${done_msg}\nVibe: v${DEFAULT_VIBE_VERSION} installed"
    fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then
        done_msg="${done_msg}\nIDE:  v${DEFAULT_IDE_VERSION} installed"
        if ! echo "$FAST_TRACK_PRODUCTS" | grep -q "vibe"; then
            mock_bin_name="antigravity-ide"
        fi
    fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then done_msg="${done_msg}\nCLI:  v${DEFAULT_CLI_VERSION} installed"; fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "jules"; then done_msg="${done_msg}\nJules CLI: latest installed"; fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then done_msg="${done_msg}\nSDK:  v${DEFAULT_SDK_VERSION} installed"; fi
    done_msg="${done_msg}\nLaunch: ${mock_bin_name}"

    if command -v gum >/dev/null 2>&1; then
        echo -e "$done_msg" | gum style --border double --border-foreground 46 --padding "1 2"
    else
        log_info "${C_GREEN}${C_BOLD}${done_msg}${C_RESET}"
    fi
}

# ── Sandbox mode (loops forever, all actions mocked) ────────────
start_sandbox_mode() {
    export MOCK_MODE=1
    export UI_MODE="[SANDBOX MODE]"
    DISTRO_PRETTY="Bluefin (Mock Sandbox)"
    ARCH="x86_64"
    GLIBC_VERSION="2.42"
    HAS_BREW="yes"
    RECOMMENDED=1

    while true; do
        main_menu

        case "$choice" in
            cancel) echo "Exiting Sandbox Mode."; trap - EXIT INT TERM; exit 0 ;;
            demo) log_warn "You are already in Sandbox Mode."; sleep 1 ;;
            save|remove_mgr)
                echo ""; run_mock_action "$choice"
                echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty
                ;;
            fast_track)
                fast_track_setup
                case "$choice" in
                    fast_track_go)
                        echo ""; run_mock_action "fast_track_go"
                        echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty
                        ;;
                    cancel|*) ;; # Loop back
                esac
                ;;
            install)
                local in_install=true
                while [ "$in_install" = true ]; do
                    install_submenu
                    if [ "$choice" = "back" ]; then
                        in_install=false
                        continue
                    fi
                    
                    if [ "$choice" = "ide_menu" ]; then
                        local in_ide=true
                        while [ "$in_ide" = true ]; do
                            ide_method_submenu
                            if [ "$choice" = "back" ]; then
                                in_ide=false
                                choice="back"
                                continue
                            fi
                            
                            if [ "$choice" = "binary_menu" ]; then
                                choose_ide_version
                                if [ "$choice" = "back" ]; then
                                    choice="back"
                                    continue
                                fi
                                in_ide=false
                                in_install=false
                            else
                                in_ide=false
                                in_install=false
                            fi
                        done
                    elif [ "$choice" = "cli_menu" ]; then
                        choose_cli_version
                        if [ "$choice" = "back" ]; then
                            choice="back"
                            continue
                        fi
                        in_install=false
                    elif [ "$choice" = "jules_menu" ]; then
                        choose_jules_version
                        if [ "$choice" = "back" ]; then
                            choice="back"
                            continue
                        fi
                        in_install=false
                    elif [ "$choice" = "sdk_menu" ]; then
                        choose_sdk_version
                        if [ "$choice" = "back" ]; then
                            choice="back"
                            continue
                        fi
                        in_install=false
                    fi
                done
                if [ "$choice" != "back" ]; then
                    echo ""; run_mock_action "$choice"
                    echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty
                fi
                ;;
            cleanup)
                cleanup_submenu
                case "$choice" in
                    remove|save|remove_mgr) echo ""; run_mock_action "$choice"; echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty ;;
                    back) ;; # loop back to main
                esac
                ;;
        esac
    done
}

# ── Interactive flow (normal mode) ──────────────────────────────
run_interactive() {
    while true; do
        main_menu

        case "$choice" in
            cancel) log_warn "Cancelled."; trap - EXIT INT TERM; exit 0 ;;
            demo) start_sandbox_mode; break ;;
            save) save_manager_locally; break ;;
            remove_mgr) remove_manager_script; break ;;
            fast_track)
                fast_track_setup
                case "$choice" in
                    fast_track_go)
                        do_fast_track_install
                        post_install_menu
                        break
                        ;;
                    cancel|*) continue ;; # Loop back to main menu
                esac
                ;;
            install)
                local in_install=true
                while [ "$in_install" = true ]; do
                    install_submenu
                    if [ "$choice" = "back" ]; then
                        in_install=false
                        continue
                    fi
                    
                    if [ "$choice" = "ide_menu" ]; then
                        local in_ide=true
                        while [ "$in_ide" = true ]; do
                            ide_method_submenu
                            if [ "$choice" = "back" ]; then
                                in_ide=false
                                choice="back"
                                continue
                            fi
                            
                            if [ "$choice" = "binary_menu" ]; then
                                choose_ide_version
                                if [ "$choice" = "back" ]; then
                                    choice="back"
                                    continue
                                fi
                                in_ide=false
                                in_install=false
                            else
                                in_ide=false
                                in_install=false
                            fi
                        done
                    elif [ "$choice" = "cli_menu" ]; then
                        choose_cli_version
                        if [ "$choice" = "back" ]; then
                            choice="back"
                            continue
                        fi
                        in_install=false
                    elif [ "$choice" = "jules_menu" ]; then
                        choose_jules_version
                        if [ "$choice" = "back" ]; then
                            choice="back"
                            continue
                        fi
                        in_install=false
                    elif [ "$choice" = "sdk_menu" ]; then
                        choose_sdk_version
                        if [ "$choice" = "back" ]; then
                            choice="back"
                            continue
                        fi
                        in_install=false
                    fi
                done
                case "$choice" in
                    brew) FAST_TRACK_PRODUCTS="ide"; install_brew; save_manager_locally; post_install_menu; break ;;
                    repo) FAST_TRACK_PRODUCTS="ide"; install_repo; save_manager_locally; post_install_menu; break ;;
                    binary:*)
                        local selected_version
                        selected_version=$(echo "$choice" | cut -d':' -f2)
                        FAST_TRACK_PRODUCTS="ide"
                        do_install_binary "$selected_version"
                        save_manager_locally
                        post_install_menu
                        break
                        ;;
                    cli:*)
                        local selected_version
                        selected_version=$(echo "$choice" | cut -d':' -f2)
                        FAST_TRACK_PRODUCTS="cli"
                        install_cli "$selected_version"
                        save_manager_locally
                        post_install_menu
                        break
                        ;;
                    jules:*)
                        local selected_version
                        selected_version=$(echo "$choice" | cut -d':' -f2)
                        FAST_TRACK_PRODUCTS="jules"
                        install_jules "$selected_version"
                        save_manager_locally
                        post_install_menu
                        break
                        ;;
                    sdk:*)
                        local selected_version
                        selected_version=$(echo "$choice" | cut -d':' -f2)
                        FAST_TRACK_PRODUCTS="sdk"
                        install_sdk "$selected_version"
                        save_manager_locally
                        post_install_menu
                        break
                        ;;
                    back) continue ;; # return to main menu
                esac
                ;;
            cleanup)
                cleanup_submenu
                case "$choice" in
                    remove) do_remove; break ;;
                    save) save_manager_locally; break ;;
                    remove_mgr) remove_manager_script; break ;;
                    back) continue ;; # return to main menu
                esac
                ;;
        esac
    done
}

# ── Dispatch ────────────────────────────────────────────────────
case "$ACTION" in
    remove) do_remove ;;
    auto)
        log_info "${C_MAG}🚀 Starting headless auto-install...${C_RESET}"
        if [ "$RECOMMENDED" = "1" ]; then install_brew; save_manager_locally
        elif [ "$RECOMMENDED" = "2" ]; then install_repo; save_manager_locally
        else do_install_binary "vibe"; save_manager_locally
        fi ;;
    fast_track)
        FAST_TRACK_PRODUCTS="vibe ide cli jules"
        case "$RECOMMENDED" in 1) FAST_TRACK_METHOD="brew" ;; 2) FAST_TRACK_METHOD="repo" ;; *) FAST_TRACK_METHOD="binary" ;; esac
        do_fast_track_install ;;
    brew) install_brew; save_manager_locally ;;
    repo) install_repo; save_manager_locally ;;
    binary) do_install_binary "vibe"; save_manager_locally ;;
    cli) install_cli; save_manager_locally ;;
    jules) install_jules; save_manager_locally ;;
    sdk) install_sdk; save_manager_locally ;;
    check) do_health_check ;;
    demo_ui) start_sandbox_mode ;;
    install|"")
        if [ "$JSON_OUT" -eq 1 ]; then
            log_error "Cannot use --json without specifying an explicit headless install method (e.g. --auto)"
            exit 1
        fi
        run_interactive
        ;;
esac
