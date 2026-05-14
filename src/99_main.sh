print_usage() {
    echo -e "${C_BOLD}Antigravity Manager v${SCRIPT_VERSION}${C_RESET}"
    echo -e "${C_DIM}Usage:${C_RESET} $0 [OPTION]"
    echo "  --install         Interactive installation wizard (default)"
    echo "  --auto            Headless auto-install"
    echo "  --install-brew    Headless Homebrew install"
    echo "  --install-repo    Headless System Repo install"
    echo "  --install-tarball Headless Tarball install"
    echo "  --remove          Uninstall Antigravity"
    echo "  --demo-ui         Test and view the UI layout without modifying the system"
    echo "  --json            Output machine-readable JSON at end (disables prompts)"
    echo "  --verbose         Enable verbose logging"
    echo "  --quiet           Suppress non-error output"
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
        --install-tarball) ACTION="tarball"; AUTO=1 ;;
        --remove) ACTION="remove" ;;
        --demo-ui) ACTION="demo_ui" ;;
        --json) JSON_OUT=1; QUIET=1 ;;
        --verbose) VERBOSE=1 ;;
        --quiet) QUIET=1 ;;
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

# ── Sandbox mode (loops forever, all actions mocked) ────────────
start_sandbox_mode() {
    export MOCK_MODE=1
    DISTRO_PRETTY="Bluefin (Mock Sandbox)"
    ARCH="x86_64"
    GLIBC_VERSION="2.42"
    HAS_BREW="yes"
    RECOMMENDED=1

    while true; do
        clear || true
        print_banner "[SANDBOX MODE]"
        print_system_info
        main_menu

        case "$choice" in
            cancel) echo "Exiting Sandbox Mode."; trap - EXIT INT TERM; exit 0 ;;
            install)
                install_submenu
                if [ "$choice" != "back" ]; then
                    echo ""; run_mock_action "$choice"
                    echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty
                fi
                ;;
            remove)
                echo ""; run_mock_action "remove"
                echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty
                ;;
            manage)
                manage_submenu
                case "$choice" in
                    save|remove_mgr) echo ""; run_mock_action "$choice"; echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty ;;
                    demo) log_warn "You are already in Sandbox Mode."; sleep 1 ;;
                    back) ;; # loop back to main
                esac
                ;;
        esac
    done
}

# ── Interactive flow (normal mode) ──────────────────────────────
run_interactive() {
    print_banner ""
    print_system_info
    main_menu

    case "$choice" in
        cancel) log_warn "Cancelled."; trap - EXIT INT TERM; exit 0 ;;
        install)
            install_submenu
            case "$choice" in
                brew) install_brew; save_manager_locally ;;
                repo) install_repo; save_manager_locally ;;
                tarball) do_install_tarball; save_manager_locally ;;
                back) log_warn "Cancelled."; trap - EXIT INT TERM; exit 0 ;;
            esac
            ;;
        remove) do_remove ;;
        manage)
            manage_submenu
            case "$choice" in
                save) save_manager_locally ;;
                remove_mgr) remove_manager_script ;;
                demo) start_sandbox_mode ;;
                back) log_warn "Cancelled."; trap - EXIT INT TERM; exit 0 ;;
            esac
            ;;
    esac
}

# ── Dispatch ────────────────────────────────────────────────────
case "$ACTION" in
    remove) do_remove ;;
    auto)
        log_info "${C_MAG}🚀 Starting headless auto-install...${C_RESET}"
        if [ "$RECOMMENDED" = "1" ]; then install_brew; save_manager_locally
        elif [ "$RECOMMENDED" = "2" ]; then install_repo; save_manager_locally
        else do_install_tarball; save_manager_locally
        fi ;;
    brew) install_brew; save_manager_locally ;;
    repo) install_repo; save_manager_locally ;;
    tarball) do_install_tarball; save_manager_locally ;;
    demo_ui) start_sandbox_mode ;;
    install|"")
        if [ "$JSON_OUT" -eq 1 ]; then
            log_error "Cannot use --json without specifying an explicit headless install method (e.g. --auto)"
            exit 1
        fi
        run_interactive
        ;;
esac
