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

start_sandbox_mode() {
    export MOCK_MODE=1
    DISTRO_PRETTY="Bluefin (Mock Sandbox)"
    ARCH="x86_64"
    GLIBC_VERSION="2.42"
    PKGS="brew dnf "
    RECOMMENDED=1
    
    while true; do
        clear || true
        print_banner "[SANDBOX MODE]"
        print_system_info
        echo ""
        interactive_menu
        
        case "$choice" in
            8) echo "Exiting Sandbox Mode."; trap - EXIT INT TERM; exit 0 ;;
            7) log_warn "You are already in Sandbox Mode."; sleep 1 ;;
            *) echo ""; run_mock_action "$choice"; echo ""; echo -ne "${C_DIM}Press Enter to continue...${C_RESET}"; read -r _ < /dev/tty ;;
        esac
    done
}

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
    demo_ui)
        start_sandbox_mode
        ;;
    install|"")
        if [ "$JSON_OUT" -eq 1 ]; then
            log_error "Cannot use --json without specifying an explicit headless install method (e.g. --auto)"
            exit 1
        fi
        
        print_banner ""
        print_system_info
        echo ""
        
        interactive_menu
    
        case "$choice" in
            1) install_brew; save_manager_locally ;;
            2) install_repo; save_manager_locally ;;
            3) do_install_tarball; save_manager_locally ;;
            4) save_manager_locally ;;
            5) do_remove ;;
            6) remove_manager_script ;;
            7) echo ""; start_sandbox_mode ;;
            8) log_warn "Cancelled."; trap - EXIT INT TERM; exit 0 ;;
        esac
        ;;
esac
