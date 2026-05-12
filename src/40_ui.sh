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
    log_info "${C_MAG}🚀 Starting mock installation...${C_RESET}"
    run_cmd_ui "Downloading Antigravity payload..." sleep 1.5
    run_cmd_ui "Extracting binaries..." sleep 1
    echo ""
    log_warn "Antigravity occasionally fails to find Chrome when installed via Brew or Tarball."
    log_info "We found a valid Chrome binary at: ${C_BOLD}/usr/bin/google-chrome${C_RESET}"
    
    if command -v gum >/dev/null 2>&1; then
        gum confirm "Would you like to automatically configure Antigravity to use this browser?" || true
        echo ""
        log_warn "~/.local/bin is not in your PATH."
        gum confirm "Would you like to automatically add it to ~/.bashrc?" || true
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
        log_warn "~/.local/bin is not in your PATH."
        echo -ne "${C_YELLOW}Would you like to automatically add it to ~/.bashrc? [Y/n]: ${C_RESET}"
        read -r _ < /dev/tty || true
        echo ""
        log_info "${C_GREEN}${C_BOLD}🎉 Mock Installation Complete!${C_RESET}"
        log_info "  ${C_CYAN}▸${C_RESET} Launch:    ${C_BOLD}antigravity${C_RESET}"
        log_info "  ${C_CYAN}▸${C_RESET} Workspace: ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
    fi
    trap - EXIT INT TERM
    exit 0
}
