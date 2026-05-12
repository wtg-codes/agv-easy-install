import sys
import re

with open('antigravity-manager.sh', 'r') as f:
    content = f.read()

# 2.1 Add SCRIPT_VERSION and 2.5 KNOWN_SHA256
content = content.replace(
    '# Configuration\nDOWNLOAD_URL',
    '# Configuration\nSCRIPT_VERSION="1.1.0"\nKNOWN_SHA256="0000000000000000000000000000000000000000000000000000000000000000"\nDOWNLOAD_URL'
)

# 2.2 Quote all variable expansions
content = content.replace('echo $GLIBC_VERSION |', 'echo "$GLIBC_VERSION" |')
content = content.replace('DISTRO=$ID', 'DISTRO="$ID"')
content = content.replace('DISTRO_LIKE=$ID_LIKE', 'DISTRO_LIKE="$ID_LIKE"')
content = content.replace('case $choice in', 'case "$choice" in')

# 2.3 Switch all curl calls to -fSsL
content = content.replace('curl -sL ', 'curl -fSsL ')

# 2.6 Fix $0 pipe detection
content = content.replace(
    'if [ -f "$0" ] && [[ "$0" != *"bash"* ]]; then',
    'if [ -f "$0" ] && [ -r "$0" ]; then'
)

# 2.7 Add gpgcheck=0 explanation
content = content.replace(
    'gpgcheck=0',
    '# Set gpgcheck=0 because Artifact Registry doesn\'t support RPM upstream signing yet\ngpgcheck=0'
)

# 2.4 Add trap cleanup and 2.5 SHA-256 verification
old_do_install_tarball = """do_install_tarball() {
    echo -e "${C_MAG}🚀 Starting Google Antigravity Standalone (Tarball) Installation...${C_RESET}"

    echo -e "${C_CYAN}📁 Preparing directories...${C_RESET}"
    mkdir -p "$BIN_DIR" "$APP_DIR" "$WORKSPACE_DIR" "$DESKTOP_DIR" "$(dirname "$DESKTOP_FILE_SYS")"

    TMP_DIR=$(mktemp -d)

    echo -e "${C_BLUE}⬇️  Downloading Antigravity...${C_RESET}"
    curl -fSsL "$DOWNLOAD_URL" -o "$TMP_DIR/Antigravity.tar.gz"

    echo -e "${C_BLUE}📦 Extracting archive...${C_RESET}"
    tar -xzf "$TMP_DIR/Antigravity.tar.gz" -C "$APP_DIR" --strip-components=1"""

new_do_install_tarball = """do_install_tarball() {
    echo -e "${C_MAG}🚀 Starting Google Antigravity Standalone (Tarball) Installation...${C_RESET}"

    echo -e "${C_CYAN}📁 Preparing directories...${C_RESET}"
    mkdir -p "$BIN_DIR" "$APP_DIR" "$WORKSPACE_DIR" "$DESKTOP_DIR" "$(dirname "$DESKTOP_FILE_SYS")"

    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT

    echo -e "${C_BLUE}⬇️  Downloading Antigravity...${C_RESET}"
    curl -fSsL "$DOWNLOAD_URL" -o "$TMP_DIR/Antigravity.tar.gz"

    echo -e "${C_BLUE}🔐 Verifying checksum...${C_RESET}"
    if ! echo "$KNOWN_SHA256  $TMP_DIR/Antigravity.tar.gz" | sha256sum -c -; then
        echo -e "${C_RED}❌ Checksum verification failed!${C_RESET}"
        exit 1
    fi

    echo -e "${C_BLUE}📦 Extracting archive...${C_RESET}"
    tar -xzf "$TMP_DIR/Antigravity.tar.gz" -C "$APP_DIR" --strip-components=1"""
content = content.replace(old_do_install_tarball, new_do_install_tarball)

# 2.4 Remove explicit rm -rf "$TMP_DIR"
content = content.replace('    rm -rf "$TMP_DIR"\n', '')

# 2.17 macOS-aware paths in do_install_tarball
old_desktop = """    echo -e "${C_CYAN}🖥️  Adding shortcut to Desktop...${C_RESET}"
    cp "$DESKTOP_FILE_SYS" "$DESKTOP_FILE_USER"
    chmod +x "$DESKTOP_FILE_USER"
    
    if command -v gio &> /dev/null; then
        echo -e "${C_CYAN}🛡️  Marking desktop shortcut as trusted...${C_RESET}"
        gio set "$DESKTOP_FILE_USER" metadata::trusted true || true
    fi

    # Refresh app menu
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$HOME/.local/share/applications" || true
    fi"""
new_desktop = """    if [ "$PLATFORM" != "Darwin" ]; then
        echo -e "${C_CYAN}🖥️  Adding shortcut to Desktop...${C_RESET}"
        if command -v xdg-user-dir &> /dev/null; then
            DESKTOP_DIR=$(xdg-user-dir DESKTOP)
        else
            DESKTOP_DIR="$HOME/Desktop"
        fi
        DESKTOP_FILE_USER="$DESKTOP_DIR/google-antigravity.desktop"
        cp "$DESKTOP_FILE_SYS" "$DESKTOP_FILE_USER"
        chmod +x "$DESKTOP_FILE_USER"
        
        if command -v gio &> /dev/null; then
            echo -e "${C_CYAN}🛡️  Marking desktop shortcut as trusted...${C_RESET}"
            gio set "$DESKTOP_FILE_USER" metadata::trusted true || true
        fi

        # Refresh app menu
        if command -v update-desktop-database &> /dev/null; then
            update-desktop-database "$HOME/.local/share/applications" || true
        fi
    fi"""
content = content.replace(old_desktop, new_desktop)

# Insert detect_platform, check_brew, install_brew after check_deps()
brew_functions = """detect_platform() {
    PLATFORM=$(uname -s)
}

check_brew() {
    command -v brew >/dev/null 2>&1
}

install_brew() {
    echo -e "${C_MAG}🚀 Installing Antigravity via Homebrew...${C_RESET}"
    if ! check_brew; then
        echo -e "${C_RED}❌ Homebrew is not installed.${C_RESET}"
        echo -e "   ${C_YELLOW}Falling back to Tarball installation...${C_RESET}"
        do_install_tarball
        return
    fi
    
    if [ "$PLATFORM" = "Darwin" ]; then
        if ! brew install --cask antigravity; then
            echo -e "${C_RED}❌ Formula not found or installation failed.${C_RESET}"
            echo -e "   ${C_YELLOW}Falling back to Tarball installation...${C_RESET}"
            do_install_tarball
        fi
    else
        if ! brew install antigravity; then
            echo -e "${C_RED}❌ Formula not found or installation failed.${C_RESET}"
            echo -e "   ${C_YELLOW}Falling back to Tarball installation...${C_RESET}"
            do_install_tarball
        fi
    fi
}
"""
content = content.replace('install_repo() {\n', brew_functions + '\ninstall_repo() {\n')

# 2.11 Add brew removal path
old_remove = """    elif command -v dnf &> /dev/null && [ -f /etc/yum.repos.d/antigravity.repo ]; then
        sudo dnf remove -y antigravity || true
        sudo rm -f /etc/yum.repos.d/antigravity.repo
    fi"""
new_remove = """    elif command -v dnf &> /dev/null && [ -f /etc/yum.repos.d/antigravity.repo ]; then
        sudo dnf remove -y antigravity || true
        sudo rm -f /etc/yum.repos.d/antigravity.repo
    elif check_brew; then
        if [ "$PLATFORM" = "Darwin" ]; then
            brew uninstall --cask antigravity || true
        else
            brew uninstall antigravity || true
        fi
    fi"""
content = content.replace(old_remove, new_remove)

# Replace print_usage and the entry point logic
old_entry = """print_usage() {
    echo -e "${C_BOLD}Usage:${C_RESET} $0 [OPTION]"
    echo "Options:"
    echo "  --install   Run the interactive installation wizard."
    echo "  --remove    Uninstall Antigravity."
}

if [ "$1" == "--remove" ]; then
    do_remove
    exit 0
elif [ "$1" == "--install" ] || [ -z "$1" ]; then
    echo -e "${C_BLUE}${C_BOLD}==========================================${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}        🚀 Google Antigravity Setup${C_RESET}"
    echo -e "${C_BLUE}${C_BOLD}==========================================${C_RESET}"
    check_deps
    echo ""
    echo -e "${C_BOLD}What would you like to do?${C_RESET}"
    echo -e "  ${C_CYAN}1)${C_RESET} Install via Standard Repository ${C_GREEN}(Best for updates, requires sudo)${C_RESET}"
    echo -e "  ${C_CYAN}2)${C_RESET} Install via Standalone Tarball ${C_YELLOW}(Installs to ~/.local, no sudo needed)${C_RESET}"
    echo -e "  ${C_CYAN}3)${C_RESET} Install/Update this Manager script locally"
    echo -e "  ${C_CYAN}4)${C_RESET} Remove/Uninstall an existing Antigravity setup"
    echo -e "  ${C_CYAN}5)${C_RESET} Remove the Antigravity Manager script"
    echo -e "  ${C_CYAN}6)${C_RESET} Cancel"
    
    # Safely print the prompt and read the input from the tty
    echo -ne "${C_BOLD}Select an option [1-6]: ${C_RESET}"
    read choice < /dev/tty

    echo "" # Add a blank line for breathing room

    case "$choice" in
        1) install_repo; echo ""; save_manager_locally ;;
        2) do_install_tarball; echo ""; save_manager_locally ;;
        3) save_manager_locally ;;
        4) do_remove ;;
        5) remove_manager_script ;;
        "Google"|"google"|"GOOGLE")
            echo -e "${C_MAG}🎓 Easter Egg Found! Opening the Course Catalog Lab...${C_RESET}"
            if command -v xdg-open &> /dev/null; then
                xdg-open "https://wtg-codes.github.io/course-catalog/" &> /dev/null
            else
                echo -e "${C_YELLOW}Please open this link in your browser: https://wtg-codes.github.io/course-catalog/${C_RESET}"
            fi
            ;;
        *) echo -e "${C_YELLOW}Cancelled.${C_RESET}"; exit 0 ;;
    esac
else
    print_usage
    exit 1
fi
"""

new_entry = """print_usage() {
    echo -e "${C_BOLD}Usage:${C_RESET} $0 [OPTION]"
    echo "Options:"
    echo "  --install   Run the interactive installation wizard."
    echo "  --remove    Uninstall Antigravity."
    echo "  --version   Show version information."
    echo "  --help      Show this help message."
}

if [ "$1" = "--remove" ]; then
    detect_platform
    do_remove
    exit 0
elif [ "$1" = "--version" ]; then
    echo "Antigravity Manager v$SCRIPT_VERSION"
    exit 0
elif [ "$1" = "--help" ]; then
    print_usage
    exit 0
elif [ "$1" = "--install" ] || [ -z "$1" ]; then
    echo -e "${C_BLUE}${C_BOLD}==========================================${C_RESET}"
    echo -e "${C_CYAN}${C_BOLD}        🚀 Google Antigravity Setup${C_RESET}"
    echo -e "${C_BLUE}${C_BOLD}==========================================${C_RESET}"
    check_deps
    echo ""
    detect_platform
    echo -e "${C_BOLD}What would you like to do?${C_RESET}"
    if [ "$PLATFORM" = "Darwin" ]; then
        echo -e "  ${C_YELLOW}Detected: macOS — we recommend Option 2${C_RESET}"
    else
        echo -e "  ${C_YELLOW}Detected: Linux — we recommend Option 1 or 2${C_RESET}"
    fi
    echo -e "  ${C_CYAN}1)${C_RESET} Install via Standard Repository ${C_GREEN}(Best for Linux updates, requires sudo)${C_RESET}"
    echo -e "  ${C_CYAN}2)${C_RESET} Install via Homebrew ${C_GREEN}(macOS/Linux, no sudo needed)${C_RESET}"
    echo -e "  ${C_CYAN}3)${C_RESET} Install via Standalone Tarball ${C_YELLOW}(Installs to ~/.local, no sudo needed)${C_RESET}"
    echo -e "  ${C_CYAN}4)${C_RESET} Install/Update this Manager script locally"
    echo -e "  ${C_CYAN}5)${C_RESET} Remove/Uninstall an existing Antigravity setup"
    echo -e "  ${C_CYAN}6)${C_RESET} Remove the Antigravity Manager script"
    echo -e "  ${C_CYAN}7)${C_RESET} Cancel"
    
    # Safely print the prompt and read the input from the tty
    echo -ne "${C_BOLD}Select an option [1-7]: ${C_RESET}"
    read choice < /dev/tty

    echo "" # Add a blank line for breathing room

    case "$choice" in
        1) install_repo; echo ""; save_manager_locally ;;
        2) install_brew; echo ""; save_manager_locally ;;
        3) do_install_tarball; echo ""; save_manager_locally ;;
        4) save_manager_locally ;;
        5) do_remove ;;
        6) remove_manager_script ;;
        "Google"|"google"|"GOOGLE")
            echo -e "${C_MAG}🎓 Easter Egg Found! Opening the Course Catalog Lab...${C_RESET}"
            if [ "$PLATFORM" = "Darwin" ]; then
                open "https://wtg-codes.github.io/course-catalog/" >/dev/null 2>&1 || echo -e "${C_YELLOW}Please open this link in your browser: https://wtg-codes.github.io/course-catalog/${C_RESET}"
            elif command -v xdg-open >/dev/null 2>&1; then
                xdg-open "https://wtg-codes.github.io/course-catalog/" >/dev/null 2>&1 || echo -e "${C_YELLOW}Please open this link in your browser: https://wtg-codes.github.io/course-catalog/${C_RESET}"
            else
                echo -e "${C_YELLOW}Please open this link in your browser: https://wtg-codes.github.io/course-catalog/${C_RESET}"
            fi
            ;;
        *) echo -e "${C_YELLOW}Cancelled.${C_RESET}"; exit 0 ;;
    esac
else
    print_usage
    exit 1
fi"""

# need to make sure we replace the entry block correctly, it had `case $choice in` initially, which we already replaced.
# Let's replace the whole block again.
# To be safe, let's just do it from print_usage() to EOF
content = content.split('print_usage() {\n')[0] + new_entry + '\n'

with open('antigravity-manager.sh', 'w') as f:
    f.write(content)

