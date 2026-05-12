interactive_menu() {
    bootstrap_ui
    echo ""
    local options=(
        "Homebrew (cross-platform, no sudo)"
        "System Repo (APT/DNF, auto-updates, needs sudo)"
        "Tarball (manual, installs to ~/.local)"
        "Save manager (add 'antigravity-manager' command)"
        "Uninstall (remove Antigravity)"
        "Remove mgr (remove this script)"
        "Demo UI (Test animations without installing)"
        "Cancel"
    )
    # Menu has options [1-8]
    if command -v gum >/dev/null 2>&1; then
        CHOICE=$(gum choose --cursor="❯ " --selected="${options[$((RECOMMENDED-1))]}" "${options[@]}")
    else
        log_warn "UI dependencies failed to load. Falling back to simple menu."
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-8]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Homebrew" ;;
            2) CHOICE="System Repo" ;;
            3) CHOICE="Tarball" ;;
            4) CHOICE="Save manager" ;;
            5) CHOICE="Uninstall" ;;
            6) CHOICE="Remove mgr" ;;
            7) CHOICE="Demo UI" ;;
            8) CHOICE="Cancel" ;;
            *) CHOICE="Cancel" ;;
        esac
    fi
    
    case "$CHOICE" in
        "Homebrew"*) choice=1 ;;
        "System Repo"*) choice=2 ;;
        "Tarball"*) choice=3 ;;
        "Save manager"*) choice=4 ;;
        "Uninstall"*) choice=5 ;;
        "Remove mgr"*) choice=6 ;;
        "Demo UI"*) choice=7 ;;
        "Cancel"*) choice=8 ;;
        *) choice=8 ;;
    esac
}



run_demo_spinners() {
    run_cmd_ui "Faking installation via choice $choice..." sleep 2
    run_cmd_ui "Configuring Chrome path..." sleep 1
    echo ""
    if command -v gum >/dev/null 2>&1; then
        gum style --border double --border-foreground 46 --padding "1 2" "🎉 Demo Complete!
Launch: antigravity
Workspace: $WORKSPACE_DIR"
    else
        log_info "${C_GREEN}${C_BOLD}🎉 Demo Complete!${C_RESET}"
        log_info "  ${C_CYAN}▸${C_RESET} Launch:    ${C_BOLD}antigravity${C_RESET}"
        log_info "  ${C_CYAN}▸${C_RESET} Workspace: ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
    fi
    trap - EXIT INT TERM
    exit 0
}
