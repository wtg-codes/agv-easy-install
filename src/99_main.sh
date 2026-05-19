print_usage() {
    echo -e "${C_BOLD}Antigravity Manager v${SCRIPT_VERSION}${C_RESET}"
    echo -e "${C_DIM}Usage:${C_RESET} $0 [OPTION]"
    echo "  --install         Interactive installation wizard (default)"
    echo "  --auto            Headless auto-install"
    echo "  --install-brew    Headless Homebrew install"
    echo "  --install-repo    Headless System Repo install"
    echo "  --install-binary  Headless Official Binary install"
    echo "  --install-cli     Headless Antigravity CLI install"
    echo "  --install-sdk     Headless Antigravity Python SDK install"
    echo "  --fast-track      Headless class setup (IDE + CLI)"
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

# ── Fast-Track Class Setup (headless or wizard-confirmed) ───────
do_fast_track_install() {
    log_info "${C_MAG}🎓 Starting class setup — installing IDE + CLI...${C_RESET}"
    echo ""

    # Step 1: Install IDE via the recommended method
    log_info "${C_BOLD}Step 1/2: Installing Antigravity IDE...${C_RESET}"
    case "$RECOMMENDED" in
        1) install_brew ;;
        2) install_repo ;;
        *) do_install_binary ;;
    esac

    echo ""

    # Step 2: Install CLI
    log_info "${C_BOLD}Step 2/2: Installing Antigravity CLI...${C_RESET}"
    install_cli

    save_manager_locally

    echo ""
    if command -v gum >/dev/null 2>&1; then
        gum style --border double --border-foreground 46 --padding "1 2" "🎉 Class Setup Complete!
IDE:  v${DEFAULT_IDE_VERSION} installed
CLI:  v${DEFAULT_CLI_VERSION} installed
Launch: antigravity"
    else
        log_info "${C_GREEN}${C_BOLD}🎉 Class Setup Complete!${C_RESET}"
        log_info "  ${C_CYAN}▸${C_RESET} IDE:  v${DEFAULT_IDE_VERSION} installed"
        log_info "  ${C_CYAN}▸${C_RESET} CLI:  v${DEFAULT_CLI_VERSION} installed"
        log_info "  ${C_CYAN}▸${C_RESET} Launch: ${C_BOLD}antigravity${C_RESET}"
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
                    install) ;; # Fall through to install submenu on next loop
                    cancel) ;; # Loop back
                esac
                # If user chose "Customize...", redirect to install submenu
                if [ "$choice" = "install" ]; then
                    install_submenu
                    case "$choice" in
                        binary_menu) choose_ide_version ;;
                        cli_menu) choose_cli_version ;;
                        sdk_menu) choose_sdk_version ;;
                    esac
                    if [ "$choice" != "back" ]; then
                        echo ""; run_mock_action "$choice"
                        echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty
                    fi
                fi
                ;;
            install)
                install_submenu
                case "$choice" in
                    binary_menu) choose_ide_version ;;
                    cli_menu) choose_cli_version ;;
                    sdk_menu) choose_sdk_version ;;
                esac
                if [ "$choice" != "back" ]; then
                    echo ""; run_mock_action "$choice"
                    echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty
                fi
                ;;
            cleanup)
                cleanup_submenu
                case "$choice" in
                    remove|save|remove_mgr) echo ""; run_mock_action "$choice"; echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty ;;
                    demo) log_warn "You are already in Sandbox Mode."; sleep 1 ;;
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
                    install) ;; # Fall through to install submenu below
                    cancel|*) continue ;; # Loop back to main menu
                esac
                # If user chose "Customize...", redirect to install submenu
                if [ "$choice" = "install" ]; then
                    install_submenu
                    case "$choice" in
                        binary_menu) choose_ide_version ;;
                        cli_menu) choose_cli_version ;;
                        sdk_menu) choose_sdk_version ;;
                    esac
                    case "$choice" in
                        brew) install_brew; save_manager_locally; post_install_menu; break ;;
                        repo) install_repo; save_manager_locally; post_install_menu; break ;;
                        binary:*)
                            local selected_version
                            selected_version=$(echo "$choice" | cut -d':' -f2)
                            do_install_binary "$selected_version"
                            save_manager_locally
                            post_install_menu
                            break
                            ;;
                        cli:*)
                            local selected_version
                            selected_version=$(echo "$choice" | cut -d':' -f2)
                            install_cli "$selected_version"
                            save_manager_locally
                            post_install_menu
                            break
                            ;;
                        sdk:*)
                            local selected_version
                            selected_version=$(echo "$choice" | cut -d':' -f2)
                            install_sdk "$selected_version"
                            save_manager_locally
                            post_install_menu
                            break
                            ;;
                        back) continue ;; # return to main menu
                    esac
                fi
                ;;
            install)
                install_submenu
                case "$choice" in
                    binary_menu) choose_ide_version ;;
                    cli_menu) choose_cli_version ;;
                    sdk_menu) choose_sdk_version ;;
                esac
                case "$choice" in
                    brew) install_brew; save_manager_locally; post_install_menu; break ;;
                    repo) install_repo; save_manager_locally; post_install_menu; break ;;
                    binary:*)
                        local selected_version
                        selected_version=$(echo "$choice" | cut -d':' -f2)
                        do_install_binary "$selected_version"
                        save_manager_locally
                        post_install_menu
                        break
                        ;;
                    cli:*)
                        local selected_version
                        selected_version=$(echo "$choice" | cut -d':' -f2)
                        install_cli "$selected_version"
                        save_manager_locally
                        post_install_menu
                        break
                        ;;
                    sdk:*)
                        local selected_version
                        selected_version=$(echo "$choice" | cut -d':' -f2)
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
                    demo) start_sandbox_mode; break ;;
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
        else do_install_binary; save_manager_locally
        fi ;;
    fast_track) do_fast_track_install ;;
    brew) install_brew; save_manager_locally ;;
    repo) install_repo; save_manager_locally ;;
    binary) do_install_binary; save_manager_locally ;;
    cli) install_cli; save_manager_locally ;;
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
