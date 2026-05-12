#!/usr/bin/env bash
set -e

# Colors for a cooler terminal output
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'
C_MAG='\033[0;35m'
C_BOLD='\033[1m'
C_RESET='\033[0m'

# Configuration
SCRIPT_VERSION="1.1.0"
KNOWN_SHA256="0000000000000000000000000000000000000000000000000000000000000000"
DOWNLOAD_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/linux-x64/Antigravity.tar.gz"
MANAGER_URL="https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/antigravity-manager.sh"

# Directories (for Tarball install)
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/lib/antigravity"
WORKSPACE_DIR="$HOME/my-antigravity-work"
DESKTOP_DIR="$HOME/Desktop"

# Files
DESKTOP_FILE_SYS="$HOME/.local/share/applications/google-antigravity.desktop"
DESKTOP_FILE_USER="$DESKTOP_DIR/google-antigravity.desktop"
ICON_PATH="$APP_DIR/resources/app/out/vs/workbench/contrib/antigravityCustomAppIcon/browser/media/antigravity/antigravity.png"

verify_path() {
    echo -e "${C_CYAN}🔍 Verifying PATH...${C_RESET}"
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo -e "${C_YELLOW}⚠️  WARNING: $BIN_DIR is not in your PATH.${C_RESET}"
        echo -e "Please add the following line to your ~/.bashrc:"
        echo -e "${C_BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${C_RESET}"
    else
        echo -e "${C_GREEN}✅ PATH looks good.${C_RESET}"
    fi
}

save_manager_locally() {
    echo -e "${C_CYAN}💾 Saving Antigravity Manager to your system...${C_RESET}"
    mkdir -p "$BIN_DIR"
    
    # Smart copy: Prevent overwriting local tests with older GitHub versions
    if [ -f "$0" ] && [ -r "$0" ]; then
        cp "$0" "$BIN_DIR/antigravity-manager"
    else
        curl -fSsL "$MANAGER_URL" -o "$BIN_DIR/antigravity-manager"
    fi
    
    chmod +x "$BIN_DIR/antigravity-manager"
    echo -e "${C_GREEN}✅ Manager saved!${C_RESET} You can now type '${C_BOLD}antigravity-manager${C_RESET}' in your terminal anytime to manage the app."
    
    echo ""
    verify_path
}

remove_manager_script() {
    echo -e "${C_RED}🗑️  Removing Antigravity Manager script...${C_RESET}"
    if [ -f "$BIN_DIR/antigravity-manager" ]; then
        rm -f "$BIN_DIR/antigravity-manager"
        echo -e "${C_GREEN}✅ Manager script removed from your system.${C_RESET}"
    else
        echo -e "${C_YELLOW}ℹ️  Manager script was not found on your system.${C_RESET}"
    fi
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO="$ID"
        # shellcheck disable=SC2034
        DISTRO_LIKE="$ID_LIKE"
    else
        DISTRO="unknown"
    fi
}

check_brew() {
    command -v brew >/dev/null 2>&1
}

detect_platform() {
    PLATFORM=$(uname -s)
    ARCH=$(uname -m)
    HAS_BREW="no"
    HAS_APT="no"
    HAS_DNF="no"
    DISTRO_PRETTY="Unknown"
    GLIBC_VERSION=""
    RECOMMENDED="3"  # default to tarball

    # Detect Homebrew
    if check_brew; then
        HAS_BREW="yes"
    fi

    if [ "$PLATFORM" = "Darwin" ]; then
        DISTRO_PRETTY="macOS $(sw_vers -productVersion 2>/dev/null || echo '')"
        if [ "$HAS_BREW" = "yes" ]; then
            RECOMMENDED="1"
        else
            RECOMMENDED="3"
        fi
    else
        # Linux detection
        detect_distro
        if [ -f /etc/os-release ]; then
            # shellcheck disable=SC1091
            DISTRO_PRETTY=$(. /etc/os-release && echo "${PRETTY_NAME:-$ID}")
        fi

        if command -v apt >/dev/null 2>&1; then
            HAS_APT="yes"
        fi
        if command -v dnf >/dev/null 2>&1; then
            HAS_DNF="yes"
        fi

        # Get glibc version safely
        GLIBC_VERSION=$(ldd --version 2>/dev/null | awk 'NR==1 {print $NF}')

        # Recommend based on what's available: brew > apt/dnf > tarball
        if [ "$HAS_BREW" = "yes" ]; then
            RECOMMENDED="1"
        elif [ "$HAS_APT" = "yes" ] || [ "$HAS_DNF" = "yes" ]; then
            RECOMMENDED="2"
        else
            RECOMMENDED="3"
        fi
    fi
}

print_system_info() {
    # Compact one-line system summary
    local PKGS=""
    [ "$HAS_BREW" = "yes" ] && PKGS="${PKGS}brew "
    [ "$HAS_APT" = "yes" ]  && PKGS="${PKGS}apt "
    [ "$HAS_DNF" = "yes" ]  && PKGS="${PKGS}dnf "
    [ -z "$PKGS" ] && PKGS="none "

    echo -e "  ${C_CYAN}▸${C_RESET} ${C_BOLD}${DISTRO_PRETTY}${C_RESET} (${ARCH})$([ -n "$GLIBC_VERSION" ] && echo " · glibc ${GLIBC_VERSION}") · pkg: ${C_GREEN}${PKGS}${C_RESET}"

    # glibc warning (only if problematic)
    if [ -n "$GLIBC_VERSION" ]; then
        local MAJOR MINOR
        MAJOR=$(echo "$GLIBC_VERSION" | cut -d. -f1)
        MINOR=$(echo "$GLIBC_VERSION" | cut -d. -f2)
        if [ "$MAJOR" -lt 2 ] || { [ "$MAJOR" -eq 2 ] && [ "$MINOR" -lt 28 ]; }; then
            echo -e "  ${C_YELLOW}⚠ glibc $GLIBC_VERSION < 2.28 — Antigravity may not work${C_RESET}"
        fi
    fi
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

install_repo() {
    detect_distro
    case "$DISTRO" in
        ubuntu|debian|kali|linuxmint)
            echo -e "${C_BLUE}🔑 Fetching repository keys...${C_RESET}"
            sudo mkdir -p /etc/apt/keyrings
            curl -fSsL "https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg" | \
                sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
            
            echo -e "${C_BLUE}📦 Configuring APT repository...${C_RESET}"
            echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
                sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
            
            echo -e "${C_BLUE}🔄 Updating package lists...${C_RESET}"
            sudo apt update
            
            echo -e "${C_MAG}🚀 Installing Antigravity...${C_RESET}"
            sudo apt install -y antigravity
            
            echo -e "${C_GREEN}✅ Installation complete!${C_RESET} You can now launch '${C_BOLD}antigravity${C_RESET}' from your terminal or app menu."
            ;;
        fedora|rhel|centos|amzn)
            echo -e "${C_BLUE}📦 Setting up RPM repository...${C_RESET}"
            sudo tee /etc/yum.repos.d/antigravity.repo << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
# Set gpgcheck=0 because Artifact Registry doesn't support RPM upstream signing yet
gpgcheck=0
EOL
            sudo dnf makecache
            sudo dnf install -y antigravity
            ;;
        *)
            echo -e "${C_RED}❌ Distribution $DISTRO not explicitly supported for repo install.${C_RESET}"
            echo -e "   ${C_YELLOW}Falling back to Tarball installation...${C_RESET}"
            do_install_tarball
            ;;
    esac
}

do_install_tarball() {
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
    tar -xzf "$TMP_DIR/Antigravity.tar.gz" -C "$APP_DIR" --strip-components=1

    echo -e "${C_BLUE}🔗 Creating symlink...${C_RESET}"
    ln -sf "$APP_DIR/antigravity" "$BIN_DIR/antigravity"

    echo -e "${C_BLUE}🖼️  Registering application icon...${C_RESET}"
    cat << EOF > "$DESKTOP_FILE_SYS"
[Desktop Entry]
Version=1.0
Name=Google Antigravity
Comment=Secure Agentic Development IDE
Exec=$BIN_DIR/antigravity %F
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Development;IDE;
EOF

    if [ "$PLATFORM" != "Darwin" ]; then
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
    fi

    echo -e "${C_CYAN}🧹 Cleaning up...${C_RESET}"

    echo -e "${C_GREEN}🎉 Installation Complete!${C_RESET}"
    echo -e "Your workspace is ready at: ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
}

do_remove() {
    echo -e "${C_RED}🧹 Removing Google Antigravity...${C_RESET}"
    # Try removing repo package if exists
    detect_distro
    if command -v apt &> /dev/null && [ -f /etc/apt/sources.list.d/antigravity.list ]; then
        sudo apt remove -y antigravity || true
        sudo rm -f /etc/apt/sources.list.d/antigravity.list
    elif command -v dnf &> /dev/null && [ -f /etc/yum.repos.d/antigravity.repo ]; then
        sudo dnf remove -y antigravity || true
        sudo rm -f /etc/yum.repos.d/antigravity.repo
    elif check_brew; then
        if [ "$PLATFORM" = "Darwin" ]; then
            brew uninstall --cask antigravity || true
        else
            brew uninstall antigravity || true
        fi
    fi

    # Cleanup standalone files
    rm -rf "$APP_DIR"
    rm -f "$BIN_DIR/antigravity"
    rm -f "$DESKTOP_FILE_SYS"
    rm -f "$DESKTOP_FILE_USER"
    
    if command -v update-desktop-database &> /dev/null; then
        update-desktop-database "$HOME/.local/share/applications" || true
    fi
    
    echo -e "${C_GREEN}✅ Uninstalled successfully.${C_RESET} (Note: Your code in $WORKSPACE_DIR was kept safe)."
}

print_usage() {
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
    echo -e "${C_BLUE}${C_BOLD}========== 🚀 Google Antigravity Setup ==========${C_RESET}"
    detect_platform
    print_system_info
    echo ""
    echo -e "${C_BOLD}Select an install method${C_RESET} ${C_GREEN}(★ = recommended)${C_RESET}"
    echo -e "  ${C_CYAN}1)${C_RESET} Homebrew      $([ "$RECOMMENDED" = "1" ] && echo -e "${C_GREEN}★${C_RESET}  ") ${C_GREEN}cross-platform, no sudo${C_RESET}"
    echo -e "  ${C_CYAN}2)${C_RESET} System Repo   $([ "$RECOMMENDED" = "2" ] && echo -e "${C_GREEN}★${C_RESET}  ") ${C_GREEN}APT/DNF, auto-updates, needs sudo${C_RESET}"
    echo -e "  ${C_CYAN}3)${C_RESET} Tarball       $([ "$RECOMMENDED" = "3" ] && echo -e "${C_GREEN}★${C_RESET}  ") ${C_YELLOW}manual, installs to ~/.local${C_RESET}"
    echo -e "  ${C_CYAN}4)${C_RESET} Save manager  ${C_CYAN}add 'antigravity-manager' command${C_RESET}"
    echo -e "  ${C_CYAN}5)${C_RESET} Uninstall     ${C_RED}remove Antigravity${C_RESET}"
    echo -e "  ${C_CYAN}6)${C_RESET} Remove manager"
    echo -e "  ${C_CYAN}7)${C_RESET} Cancel"
    echo -ne "${C_BOLD}Pick [1-7]: ${C_RESET}"
    read choice < /dev/tty

    echo "" # Add a blank line for breathing room

    case "$choice" in
        1) install_brew; echo ""; save_manager_locally ;;
        2) install_repo; echo ""; save_manager_locally ;;
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
fi
