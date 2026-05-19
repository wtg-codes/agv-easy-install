do_health_check() {
    log_info "${C_MAG}🔍 Running Google Antigravity Health Check...${C_RESET}"
    echo ""

    local passed=0
    local failed=0

    check_status() {
        if eval "$2" > /dev/null 2>&1; then
            echo -e "  ${C_GREEN}✅ $1${C_RESET}"
            passed=$((passed + 1))
        else
            echo -e "  ${C_RED}❌ $1${C_RESET}"
            failed=$((failed + 1))
        fi
    }

    # 1. Antigravity Binary
    local bin_path=""
    if command -v antigravity >/dev/null 2>&1; then
        bin_path=$(command -v antigravity)
        check_status "Antigravity binary found in PATH ($bin_path)" "true"
    else
        # check macos standard path
        if [ -d "/Applications/Google Antigravity.app" ]; then
            bin_path="/Applications/Google Antigravity.app/Contents/MacOS/Google Antigravity"
            check_status "Antigravity binary found in Applications" "test -x '$bin_path'"
        else
            check_status "Antigravity binary found in PATH" "false"
        fi
    fi

    # 2. Chrome/Chromium installation
    if [ -n "$chrome_path" ] && [ -x "$chrome_path" ]; then
        check_status "Chrome/Chromium found ($chrome_path)" "true"
    else
        check_status "Chrome/Chromium found" "false"
    fi

    # 3. State file
    check_status "Installation state file exists ($STATE_FILE)" "test -f '$STATE_FILE'"

    # 4. Workspace
    check_status "Default workspace exists ($WORKSPACE_DIR)" "test -d '$WORKSPACE_DIR'"

    # 5. Antigravity CLI (Optional)
    if command -v agy >/dev/null 2>&1; then
        echo -e "  ${C_GREEN}✅ Antigravity CLI found in PATH ($(command -v agy))${C_RESET}"
    fi

    echo ""
    if [ "$failed" -eq 0 ]; then
        log_info "${C_GREEN}${C_BOLD}🎉 Health check passed! Your installation is healthy.${C_RESET}"
    else
        log_warn "${C_BOLD}$failed issue(s) detected.${C_RESET} You may need to run the installer again."
    fi
}
