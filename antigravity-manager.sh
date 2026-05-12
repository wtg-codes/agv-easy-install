#!/usr/bin/env bash
# =============================================================================
# Google Antigravity Setup Script
# WARNING: This file is auto-generated. Do not edit directly.
# Edit the files in the src/ directory and run ./build.sh instead.
# =============================================================================
set -e

# Colors for a cooler terminal output
C_RED='\033[0;31m'
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_BLUE='\033[0;34m'
C_CYAN='\033[0;36m'
C_MAG='\033[0;35m'
C_BOLD='\033[1m'
C_DIM='\033[2m'
C_RESET='\033[0m'

# Configuration
SCRIPT_VERSION="1.2.0"
KNOWN_SHA256="5232a4048ff4fa15685d9a981ba4fba573e297f3efc9b76f638e794baf775725"
DOWNLOAD_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/linux-x64/Antigravity.tar.gz"
MANAGER_URL="https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/antigravity-manager.sh"

# Directories
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/lib/antigravity"
WORKSPACE_DIR="$HOME/my-antigravity-work"
DESKTOP_DIR="$HOME/Desktop"

# Files
DESKTOP_FILE_SYS="$HOME/.local/share/applications/google-antigravity.desktop"
DESKTOP_FILE_USER="$DESKTOP_DIR/google-antigravity.desktop"
ICON_PATH="$APP_DIR/resources/app/out/vs/workbench/contrib/antigravityCustomAppIcon/browser/media/antigravity/antigravity.png"

# State & Logging
STATE_DIR="$HOME/.config/antigravity"
STATE_FILE="$STATE_DIR/install.json"
LOG_FILE="/tmp/antigravity-install.log"
VERBOSE=0
QUIET=0
AUTO=0
JSON_OUT=0
JSON_STATUS="success"
JSON_METHOD="none"

cleanup_ui() {
    tput cnorm 2>/dev/null || true
    printf "\r\033[K" 2>/dev/null || true
    if [ -n "$GUM_DIR" ] && [ -d "$GUM_DIR" ]; then
        rm -rf "$GUM_DIR"
    fi
}

exit_handler() {
    local exit_code=$?
    cleanup_ui
    if [ "$JSON_OUT" -eq 1 ]; then
        if [ $exit_code -ne 0 ]; then
            JSON_STATUS="error"
        fi
        cat <<EOF
{
  "status": "$JSON_STATUS",
  "method": "$JSON_METHOD",
  "path": "$BIN_DIR"
}
EOF
    fi
}
trap exit_handler EXIT INT TERM

log_info() {
    local msg="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') INFO: $(echo "$msg" | sed -E 's/\x1B\[[0-9;]*[mK]//g')" >> "$LOG_FILE"
    if [ "$JSON_OUT" -eq 0 ] && [ "$QUIET" -eq 0 ]; then
        echo -e "$msg"
    fi
}

log_error() {
    local msg="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') ERROR: $(echo "$msg" | sed -E 's/\x1B\[[0-9;]*[mK]//g')" >> "$LOG_FILE"
    if [ "$JSON_OUT" -eq 0 ]; then
        echo -e "${C_RED}❌ $msg${C_RESET}"
    fi
}

log_warn() {
    local msg="$1"
    echo "$(date '+%Y-%m-%d %H:%M:%S') WARN: $(echo "$msg" | sed -E 's/\x1B\[[0-9;]*[mK]//g')" >> "$LOG_FILE"
    if [ "$JSON_OUT" -eq 0 ] && [ "$QUIET" -eq 0 ]; then
        echo -e "${C_YELLOW}⚠ $msg${C_RESET}"
    fi
}

bootstrap_ui() {
    if command -v gum >/dev/null 2>&1; then
        return 0
    fi
    log_info "  ${C_DIM}Bootstrapping UI dependencies...${C_RESET}"
    GUM_DIR=$(mktemp -d)
    
    local GUM_VERSION="0.17.0"
    local OS="Linux"
    local ARCH="x86_64"
    
    [ "$PLATFORM" = "Darwin" ] && OS="Darwin"
    if [ "$(uname -m)" = "aarch64" ] || [ "$(uname -m)" = "arm64" ]; then
        ARCH="arm64"
    fi
    
    local TARBALL="gum_${GUM_VERSION}_${OS}_${ARCH}.tar.gz"
    
    if curl -fSsL "https://github.com/charmbracelet/gum/releases/download/v${GUM_VERSION}/${TARBALL}" | tar -xzf - -C "$GUM_DIR" 2>/dev/null; then
        local GUM_BIN
        GUM_BIN=$(find "$GUM_DIR" -name "gum" -type f -executable | head -n 1)
        if [ -n "$GUM_BIN" ]; then
            local gum_dir_path
            gum_dir_path=$(dirname "$GUM_BIN")
            export PATH="$gum_dir_path:$PATH"
        fi
    fi
}

run_cmd() {
    if [ "$VERBOSE" -eq 1 ]; then
        "$@" 2>&1 | tee -a "$LOG_FILE"
    else
        "$@" >> "$LOG_FILE" 2>&1
    fi
}

run_cmd_ui() {
    local msg="$1"
    shift
    if [ "$JSON_OUT" -eq 1 ] || [ "$VERBOSE" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        run_cmd "$@"
    elif command -v gum >/dev/null 2>&1; then
        gum spin --spinner dot --title "$msg" -- "$@"
    else
        log_info "  $msg"
        run_cmd "$@"
    fi
}

check_dependencies() {
    local deps=("curl" "tar" "awk" "grep")
    local missing=0
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            log_error "Missing required dependency: $dep"
            missing=1
        fi
    done
    if [ "$missing" -eq 1 ]; then
        log_error "Please install missing dependencies and try again."
        exit 1
    fi
    touch "$LOG_FILE" || true
}

inject_path() {
    if [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
        return
    fi

    local shell_rc=""
    if [ "$PLATFORM" = "Darwin" ]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"zsh"* ]]; then
        shell_rc="$HOME/.zshrc"
    elif [[ "$SHELL" == *"fish"* ]]; then
        shell_rc="$HOME/.config/fish/config.fish"
    else
        shell_rc="$HOME/.bashrc"
    fi

    local export_line="export PATH=\"\$HOME/.local/bin:\$PATH\""
    if [[ "$shell_rc" == *"fish"* ]]; then
        export_line="fish_add_path \$HOME/.local/bin"
    fi

    if grep -q "\$HOME/.local/bin" "$shell_rc" 2>/dev/null; then
        return
    fi

    if [ "$AUTO" -eq 1 ] || [ "$JSON_OUT" -eq 1 ]; then
        echo "$export_line" >> "$shell_rc"
        log_info "✅ Added ~/.local/bin to $shell_rc automatically."
    else
        log_warn "$BIN_DIR is not in your PATH."
        echo -ne "${C_YELLOW}Would you like to automatically add it to $shell_rc? [Y/n]: ${C_RESET}"
        read -r add_path < /dev/tty
        case "$add_path" in
            [nN]*) log_info "Skipping PATH injection. Please add it manually." ;;
            *)
                echo "$export_line" >> "$shell_rc"
                log_info "✅ Added ~/.local/bin to $shell_rc."
                log_info "   Please run 'source $shell_rc' or restart your terminal later."
                ;;
        esac
    fi
}

configure_chrome_path() {
    local SETTINGS_DIR="$HOME/.config/Antigravity/User"
    if [ "$PLATFORM" = "Darwin" ]; then
        SETTINGS_DIR="$HOME/Library/Application Support/Antigravity/User"
    fi
    local SETTINGS_FILE="$SETTINGS_DIR/settings.json"
    local chrome_path=""

    log_info "${C_CYAN}🔍 Locating Chrome binary for Antigravity...${C_RESET}"

    # 1. Prioritize raw Flatpak binaries (required to bypass sandbox)
    local flatpak_sys="/var/lib/flatpak/app/com.google.Chrome/current/active/files/extra/chrome"
    local flatpak_user="$HOME/.local/share/flatpak/app/com.google.Chrome/current/active/files/extra/chrome"

    if [[ -x "$flatpak_sys" ]]; then
        chrome_path="$flatpak_sys"
        log_info "  Found system-wide Flatpak Chrome: $chrome_path"
    elif [[ -x "$flatpak_user" ]]; then
        chrome_path="$flatpak_user"
        log_info "  Found user-level Flatpak Chrome: $chrome_path"
    else
        # 2. Fallback to standard system package binaries
        if [ "$PLATFORM" = "Darwin" ] && [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
            chrome_path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
            log_info "  Found macOS Chrome: $chrome_path"
        else
            for cmd in google-chrome-stable google-chrome chromium chromium-browser; do
                if command -v "$cmd" >/dev/null 2>&1; then
                    chrome_path=$(command -v "$cmd")
                    log_info "  Found standard system Chrome: $chrome_path"
                    break
                fi
            done
        fi
    fi

    if [[ -n "$chrome_path" ]]; then
        local do_inject=0
        if [ "$AUTO" -eq 1 ] || [ "$JSON_OUT" -eq 1 ]; then
            do_inject=1
        else
            log_warn "Antigravity occasionally fails to find Chrome when installed via Brew or Tarball."
            log_info "We found a valid Chrome binary at: ${C_BOLD}$chrome_path${C_RESET}"
            echo -ne "${C_YELLOW}Would you like to automatically configure Antigravity to use this browser? [Y/n]: ${C_RESET}"
            read -r set_chrome < /dev/tty
            case "$set_chrome" in
                [nN]*) log_info "Skipping Chrome configuration." ;;
                *) do_inject=1 ;;
            esac
        fi

        if [ "$do_inject" -eq 1 ]; then
            mkdir -p "$SETTINGS_DIR"
            [[ ! -f "$SETTINGS_FILE" ]] && echo '{}' > "$SETTINGS_FILE"

            if command -v jq >/dev/null 2>&1; then
                jq --arg path "$chrome_path" \
                   '.["antigravity.browser.chromeBinaryPath"] = $path' \
                   "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
                log_info "${C_GREEN}✅ Antigravity Chrome path mapped to $chrome_path${C_RESET}"
            else
                log_warn "jq is missing. Cannot automatically configure Chrome path. Install jq to enable auto-config."
            fi
        fi
    else
        log_warn "Could not locate a valid Chrome or Chromium executable. Antigravity may complain it is not installed."
    fi
}

save_manager_locally() {
    log_info "${C_CYAN}💾 Saving Antigravity Manager to your system...${C_RESET}"
    mkdir -p "$BIN_DIR"
    
    if [ -f "$0" ] && [ -r "$0" ]; then
        cp "$0" "$BIN_DIR/antigravity-manager"
    else
        run_cmd curl -fSsL "$MANAGER_URL" -o "$BIN_DIR/antigravity-manager"
    fi
    
    chmod +x "$BIN_DIR/antigravity-manager"
    log_info "${C_GREEN}✅ Manager saved.${C_RESET} Run ${C_BOLD}antigravity-manager${C_RESET} anytime."
    inject_path
}

remove_manager_script() {
    log_info "${C_RED}🗑️  Removing Antigravity Manager script...${C_RESET}"
    if [ -f "$BIN_DIR/antigravity-manager" ]; then
        rm -f "$BIN_DIR/antigravity-manager"
        log_info "${C_GREEN}✅ Manager script removed from your system.${C_RESET}"
    else
        log_warn "Manager script was not found on your system."
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

    if check_brew; then
        HAS_BREW="yes"
    fi

    if [ "$PLATFORM" = "Darwin" ]; then
        DISTRO_PRETTY="macOS $(sw_vers -productVersion 2>/dev/null || echo '')"
        if [ "$HAS_BREW" = "yes" ]; then RECOMMENDED="1"; else RECOMMENDED="3"; fi
    else
        detect_distro
        if [ -f /etc/os-release ]; then
            # shellcheck disable=SC1091
            DISTRO_PRETTY=$(. /etc/os-release && echo "${PRETTY_NAME:-$ID}")
        fi
        if command -v apt >/dev/null 2>&1; then HAS_APT="yes"; fi
        if command -v dnf >/dev/null 2>&1; then HAS_DNF="yes"; fi

        GLIBC_VERSION=$(ldd --version 2>/dev/null | awk 'NR==1 {print $NF}' || true)

        IS_ATOMIC="no"
        if [ -d /run/ostree-booted ] || [ "$DISTRO" = "bluefin" ] || [ "$DISTRO" = "bazzite" ]; then
            IS_ATOMIC="yes"
            DISTRO_PRETTY="${DISTRO_PRETTY} (Atomic)"
        fi

        if [ "$IS_ATOMIC" = "yes" ]; then
            if [ "$HAS_BREW" = "yes" ]; then RECOMMENDED="1"; else RECOMMENDED="3"; fi
        elif [ "$HAS_BREW" = "yes" ]; then RECOMMENDED="1"
        elif [ "$HAS_APT" = "yes" ] || [ "$HAS_DNF" = "yes" ]; then RECOMMENDED="2"
        else RECOMMENDED="3"; fi
    fi
}

print_system_info() {
    local PKGS=""
    [ "$HAS_BREW" = "yes" ] && PKGS="${PKGS}brew "
    [ "$HAS_APT" = "yes" ]  && PKGS="${PKGS}apt "
    [ "$HAS_DNF" = "yes" ]  && PKGS="${PKGS}dnf "
    local PKG_DISPLAY
    if [ -z "$PKGS" ]; then PKG_DISPLAY="${C_YELLOW}none${C_RESET}"; else PKG_DISPLAY="${C_GREEN}${PKGS}${C_RESET}"; fi

    log_info "  ${C_CYAN}OS:${C_RESET}   ${C_BOLD}${DISTRO_PRETTY}${C_RESET}"
    log_info "  ${C_CYAN}SYS:${C_RESET}  ${ARCH}$([ -n "$GLIBC_VERSION" ] && echo " · glibc ${GLIBC_VERSION}") · pkg: ${PKG_DISPLAY}"

    if [ -n "$GLIBC_VERSION" ]; then
        local MAJOR MINOR
        MAJOR=$(echo "$GLIBC_VERSION" | cut -d. -f1)
        MINOR=$(echo "$GLIBC_VERSION" | cut -d. -f2)
        if [ "$MAJOR" -lt 2 ] || { [ "$MAJOR" -eq 2 ] && [ "$MINOR" -lt 28 ]; }; then
            log_warn "glibc $GLIBC_VERSION < 2.28 — Antigravity may not work"
        fi
    fi
}

print_banner() {
    local mode="$1"
    echo -e "${C_CYAN}"
    cat << 'BANNER_EOF'
     ___        __  _                     _ __       
    /   |  ____/ /_(_)___ __________ __   (_) /___  __
   / /| | / __ \ __/ / _ \/ ___/ __ \ /| / / / __ \/ /
  / ___ |/ / / / /_/ / / / / / / / / / |/ / / /_/ / / 
 /_/  |_/_/ /_/\__/_/\__,_/_/ /_/ /_/|___/_/\____/_/  
BANNER_EOF
    echo -e "${C_RESET}"
    echo -e "  ${C_BLUE}${C_BOLD}Google Antigravity Setup v${SCRIPT_VERSION}${C_RESET} ${mode}"
    echo -e "  ${C_DIM}────────────────────────────────────────────────────────${C_RESET}"
}

install_brew() {
    JSON_METHOD="brew"
    log_info "${C_MAG}🚀 Installing Antigravity via Homebrew...${C_RESET}"
    if ! check_brew; then
        log_error "Homebrew is not installed."
        if [ "$PLATFORM" = "Darwin" ]; then
            log_error "Tarball fallback is not supported on macOS. Exiting."
            exit 1
        else
            log_warn "Falling back to Tarball installation..."
            do_install_tarball
        fi
        return
    fi
    
    if [ "$PLATFORM" = "Darwin" ]; then
        if ! run_cmd_ui "Brewing Antigravity..." brew install --cask antigravity; then
            log_error "Formula not found or installation failed."
            exit 1
        fi
    else
        if ! run_cmd_ui "Brewing Antigravity..." brew install antigravity; then
            log_error "Formula not found or installation failed."
            log_warn "Falling back to Tarball installation..."
            do_install_tarball
            return
        fi
    fi
    configure_chrome_path
    mkdir -p "$STATE_DIR"
    echo '{"method": "brew", "version": "'"$SCRIPT_VERSION"'"}' > "$STATE_FILE"
}

install_repo() {
    JSON_METHOD="repo"
    log_warn "This method requires sudo — you may be prompted for your password."
    sudo -v || { log_error "Sudo access required."; exit 1; }
    detect_distro
    case "$DISTRO" in
        ubuntu|debian|kali|linuxmint)
            log_info "${C_BLUE}🔑 Fetching repository keys...${C_RESET}"
            run_cmd sudo mkdir -p /etc/apt/keyrings
            curl -fSsL "https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg" | \
                sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg || { log_error "Failed to fetch keys"; exit 1; }
            
            log_info "${C_BLUE}📦 Configuring APT repository...${C_RESET}"
            echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ antigravity-debian main" | \
                sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
            
            if ! run_cmd_ui "Updating package lists..." sudo apt update || ! run_cmd_ui "Installing Antigravity..." sudo apt install -y antigravity; then
                log_error "Installation failed! Rolling back repository changes..."
                run_cmd sudo rm -f /etc/apt/sources.list.d/antigravity.list
                exit 1
            fi
            log_info "${C_GREEN}✅ Installation complete!${C_RESET} Launch with: ${C_BOLD}antigravity${C_RESET}"
            ;;
        fedora|rhel|centos|amzn)
            log_info "${C_BLUE}📦 Setting up RPM repository...${C_RESET}"
            sudo tee /etc/yum.repos.d/antigravity.repo > /dev/null << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL
            if ! run_cmd_ui "Updating package cache..." sudo dnf makecache || ! run_cmd_ui "Installing Antigravity..." sudo dnf install -y antigravity; then
                log_error "Installation failed! Rolling back repository changes..."
                run_cmd sudo rm -f /etc/yum.repos.d/antigravity.repo
                exit 1
            fi
            log_info "${C_GREEN}✅ Installation complete!${C_RESET} Launch with: ${C_BOLD}antigravity${C_RESET}"
            ;;
        *)
            log_error "Distribution $DISTRO not explicitly supported for repo install."
            if [ "$PLATFORM" = "Darwin" ]; then exit 1; fi
            log_warn "Falling back to Tarball installation..."
            do_install_tarball
            return
            ;;
    esac
    configure_chrome_path
    mkdir -p "$STATE_DIR"
    echo '{"method": "repo", "version": "'"$SCRIPT_VERSION"'"}' > "$STATE_FILE"
}

do_install_tarball() {
    JSON_METHOD="tarball"
    if ! command -v sha256sum >/dev/null 2>&1; then
        log_error "sha256sum is required for tarball install but was not found."
        exit 1
    fi

    log_info "${C_MAG}🚀 Starting Google Antigravity Standalone (Tarball) Installation...${C_RESET}"
    log_info "${C_CYAN}📁 Preparing directories...${C_RESET}"
    mkdir -p "$BIN_DIR" "$APP_DIR" "$WORKSPACE_DIR" "$DESKTOP_DIR" "$(dirname "$DESKTOP_FILE_SYS")"

    TMP_DIR=$(mktemp -d)
    # We still have our main EXIT trap, so we need to clean this specifically or append to trap
    trap 'rm -rf "$TMP_DIR"; exit_handler' EXIT INT TERM

    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        run_cmd curl -fSL "$DOWNLOAD_URL" -o "$TMP_DIR/Antigravity.tar.gz"
    else
        log_info "${C_BLUE}⬇️  Downloading Antigravity (~218 MB)...${C_RESET}"
        curl -fSL --progress-bar "$DOWNLOAD_URL" -o "$TMP_DIR/Antigravity.tar.gz"
    fi

    log_info "${C_BLUE}🔐 Verifying checksum...${C_RESET}"
    if ! echo "$KNOWN_SHA256  $TMP_DIR/Antigravity.tar.gz" | sha256sum -c - >/dev/null 2>&1; then
        log_error "Checksum verification failed!"
        exit 1
    fi

    gum spin --spinner dot --title "Extracting archive..." -- tar -xzf "$TMP_DIR/Antigravity.tar.gz" -C "$APP_DIR" --strip-components=1

    log_info "${C_BLUE}🔗 Creating symlink...${C_RESET}"
    ln -sf "$APP_DIR/antigravity" "$BIN_DIR/antigravity"

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
        log_info "${C_CYAN}🖥️  Adding shortcut to Desktop...${C_RESET}"
        if command -v xdg-user-dir &> /dev/null; then DESKTOP_DIR=$(xdg-user-dir DESKTOP); else DESKTOP_DIR="$HOME/Desktop"; fi
        DESKTOP_FILE_USER="$DESKTOP_DIR/google-antigravity.desktop"
        cp "$DESKTOP_FILE_SYS" "$DESKTOP_FILE_USER"
        chmod +x "$DESKTOP_FILE_USER"
        if command -v gio &> /dev/null; then run_cmd gio set "$DESKTOP_FILE_USER" metadata::trusted true || true; fi
        if command -v update-desktop-database &> /dev/null; then run_cmd update-desktop-database "$HOME/.local/share/applications" || true; fi
    fi

    echo ""
    if command -v gum >/dev/null 2>&1; then
        gum style --border double --border-foreground 46 --padding "1 2" "🎉 Installation Complete!
Launch: antigravity
Workspace: $WORKSPACE_DIR"
    else
        log_info "${C_GREEN}${C_BOLD}🎉 Installation Complete!${C_RESET}"
        log_info "  ${C_CYAN}▸${C_RESET} Launch:    ${C_BOLD}antigravity${C_RESET}"
        log_info "  ${C_CYAN}▸${C_RESET} Workspace: ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
    fi
    
    configure_chrome_path
    mkdir -p "$STATE_DIR"
    echo '{"method": "tarball", "version": "'"$SCRIPT_VERSION"'"}' > "$STATE_FILE"
}

do_remove() {
    JSON_METHOD="remove"
    if [ "$AUTO" -ne 1 ] && [ "$JSON_OUT" -ne 1 ]; then
        echo -ne "${C_RED}⚠ Are you sure you want to uninstall Antigravity? [y/N]: ${C_RESET}"
        read confirm < /dev/tty
        case "$confirm" in
            [yY]|[yY][eE][sS]) ;;
            *) log_warn "Cancelled."; return ;;
        esac
    fi
    log_info "${C_RED}🧹 Removing Google Antigravity...${C_RESET}"
    
    if [ -f "$STATE_FILE" ]; then
        local method
        method=$(grep -o '"method": "[^"]*' "$STATE_FILE" | grep -o '[^"]*$')
        log_info "Found installation state. Method used: $method"
        
        case "$method" in
            "brew")
                if [ "$PLATFORM" = "Darwin" ]; then run_cmd brew uninstall --cask antigravity || true
                else run_cmd brew uninstall antigravity || true; fi ;;
            "repo")
                detect_distro
                if command -v apt &> /dev/null && [ -f /etc/apt/sources.list.d/antigravity.list ]; then
                    run_cmd sudo apt remove -y antigravity || true
                    sudo rm -f /etc/apt/sources.list.d/antigravity.list
                elif command -v dnf &> /dev/null && [ -f /etc/yum.repos.d/antigravity.repo ]; then
                    run_cmd sudo dnf remove -y antigravity || true
                    sudo rm -f /etc/yum.repos.d/antigravity.repo
                fi ;;
            "tarball") ;;
        esac
        rm -f "$STATE_FILE"
    else
        log_warn "No state file found. Using heuristic removal..."
        detect_distro
        if command -v apt &> /dev/null && [ -f /etc/apt/sources.list.d/antigravity.list ]; then
            run_cmd sudo apt remove -y antigravity || true; sudo rm -f /etc/apt/sources.list.d/antigravity.list
        elif command -v dnf &> /dev/null && [ -f /etc/yum.repos.d/antigravity.repo ]; then
            run_cmd sudo dnf remove -y antigravity || true; sudo rm -f /etc/yum.repos.d/antigravity.repo
        elif check_brew; then
            if [ "$PLATFORM" = "Darwin" ]; then run_cmd brew uninstall --cask antigravity || true
            else run_cmd brew uninstall antigravity || true; fi
        fi
    fi

    rm -rf "$APP_DIR" "$BIN_DIR/antigravity" "$DESKTOP_FILE_SYS" "$DESKTOP_FILE_USER"
    if command -v update-desktop-database &> /dev/null; then run_cmd update-desktop-database "$HOME/.local/share/applications" || true; fi
    log_info "${C_GREEN}✅ Uninstalled successfully.${C_RESET} (Note: Your code in $WORKSPACE_DIR was kept safe)."
}

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
        print_banner "[DEMO MODE]"
        print_system_info
        echo ""
        interactive_menu
        echo ""
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
        choice=$?
    
        case "$choice" in
            1) install_brew; save_manager_locally ;;
            2) install_repo; save_manager_locally ;;
            3) do_install_tarball; save_manager_locally ;;
            4) save_manager_locally ;;
            5) do_remove ;;
            6) remove_manager_script ;;
            7) exec "$0" --demo-ui ;;
            8) log_warn "Cancelled."; trap - EXIT INT TERM; exit 0 ;;
        esac
        ;;
esac
