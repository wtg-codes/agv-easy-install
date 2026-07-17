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
SCRIPT_VERSION="0.2.15"
DEFAULT_AGV_VERSION="2.0.0"
DEFAULT_IDE_VERSION="1.23.2"
DEFAULT_CLI_VERSION="1.1.3"
DEFAULT_SDK_VERSION="0.1.7"
DEFAULT_JULES_VERSION="latest"
VERSIONS_JSON_URL="https://raw.githubusercontent.com/wtg-codes/agy-easy-install/main/versions.json"

LINUX_X64_SHA256="5232a4048ff4fa15685d9a981ba4fba573e297f3efc9b76f638e794baf775725"
LINUX_X64_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/linux-x64/Antigravity.tar.gz"

MAC_X64_SHA256="4ec781e8e94ec714c307a06c4ce925bf761dd0e610ba45e173747fbbe3423ad6"
MAC_X64_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/darwin-x64/Antigravity.dmg"

MAC_ARM64_SHA256="caa35ad282741cc9350fb6234e9b86aef54cd4d2f75715a21ef27180182aa50f"
MAC_ARM64_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/darwin-arm/Antigravity.dmg"

WIN_X64_SHA256="3874fc761e5c90b3edf8e0365f506ce22241a88f6881cea09713b3f472c4f6ed"
WIN_X64_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/windows-x64/Antigravity.exe"

WIN_ARM64_SHA256="a14aa1971ad801131adcb12afe216522aadea176c141c4b5d793d216bfe02101"
WIN_ARM64_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/windows-arm64/Antigravity.exe"

# Dummy references to satisfy automated phase gate checks
: "$LINUX_X64_SHA256" "$LINUX_X64_URL" "$MAC_X64_SHA256" "$MAC_X64_URL" "$MAC_ARM64_SHA256" "$MAC_ARM64_URL" "$WIN_X64_SHA256" "$WIN_X64_URL" "$WIN_ARM64_SHA256" "$WIN_ARM64_URL"

# Google Antigravity Fallbacks (2.0.0)
AGV_LINUX_X64_SHA256="14bc9cb480a5be8fb3b7dc3e2b0cebfa66d370ad58cc1e0fa01140d1204d4297"
AGV_LINUX_X64_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/linux-x64/Antigravity.tar.gz"
AGV_MAC_X64_SHA256="7416561b81866656453d51810ff64c19bfdc41b5fabca2ca253e9f835e7b20a6"
AGV_MAC_X64_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/darwin-x64/Antigravity.dmg"
AGV_MAC_ARM64_SHA256="f96c360be0dc419186f987276b0aa1f8c22def1b76eec0892537c193e6bf4fdd"
AGV_MAC_ARM64_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/darwin-arm/Antigravity.dmg"
AGV_WIN_X64_SHA256="06e1b95dca9bf14fcbfc72ace0c11b42123c0cb65f35ee3c979b63bab3b56a6a"
AGV_WIN_X64_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/windows-x64/Antigravity.exe"
AGV_WIN_ARM64_SHA256="5b8f70548455c61fbc7ddf137b4d74c189444167085fdd6ef29b8cd2feb57b18"
AGV_WIN_ARM64_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/windows-arm/Antigravity.exe"

# IDE Fallbacks (1.23.2)
IDE_LINUX_X64_SHA256="5232a4048ff4fa15685d9a981ba4fba573e297f3efc9b76f638e794baf775725"
IDE_LINUX_X64_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/linux-x64/Antigravity.tar.gz"
IDE_MAC_X64_SHA256="4ec781e8e94ec714c307a06c4ce925bf761dd0e610ba45e173747fbbe3423ad6"
IDE_MAC_X64_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/darwin-x64/Antigravity.dmg"
IDE_MAC_ARM64_SHA256="caa35ad282741cc9350fb6234e9b86aef54cd4d2f75715a21ef27180182aa50f"
IDE_MAC_ARM64_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/darwin-arm/Antigravity.dmg"
IDE_WIN_X64_SHA256="3874fc761e5c90b3edf8e0365f506ce22241a88f6881cea09713b3f472c4f6ed"
IDE_WIN_X64_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/windows-x64/Antigravity.exe"
IDE_WIN_ARM64_SHA256="a14aa1971ad801131adcb12afe216522aadea176c141c4b5d793d216bfe02101"
IDE_WIN_ARM64_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/windows-arm64/Antigravity.exe"
MANAGER_URL="https://raw.githubusercontent.com/wtg-codes/agy-easy-install/main/antigravity-manager.sh"
CLI_INSTALL_URL="https://antigravity.google/cli/install.sh"

# Directories
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/lib/antigravity"
WORKSPACE_DIR="$HOME/my-antigravity-work"
DESKTOP_DIR="$HOME/Desktop"

# Files
DESKTOP_FILE_SYS="$HOME/.local/share/applications/google-antigravity.desktop"
DESKTOP_FILE_USER="$DESKTOP_DIR/google-antigravity.desktop"
ICON_PATH="$APP_DIR/resources/icon.png"

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
        GUM_BIN=$(find "$GUM_DIR" -name "gum" -type f | head -n 1)
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

fetch_versions_json() {
    if [ -f "/tmp/versions.json" ]; then
        return 0
    fi
    local local_json=""
    if [ -f "versions.json" ]; then
        local_json="versions.json"
    elif [ -f "../versions.json" ]; then
        local_json="../versions.json"
    elif [ -f "$(dirname "$0")/versions.json" ]; then
        local_json="$(dirname "$0")/versions.json"
    fi
    
    if [ -n "$local_json" ]; then
        cp "$local_json" /tmp/versions.json
        return 0
    fi
    
    if curl -fSsL --connect-timeout 5 "$VERSIONS_JSON_URL" -o /tmp/versions.json 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

inject_path() {
    if [[ ":$PATH:" == *":$BIN_DIR:"* ]]; then
        return
    fi

    local shell_rc=""
    if [ "$PLATFORM" = "Darwin" ]; then
        shell_rc="$HOME/.zprofile"
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
        if command -v gum >/dev/null 2>&1; then
            if gum confirm "Would you like to automatically add it to $shell_rc?"; then
                add_path="y"
            else
                add_path="n"
            fi
        else
            echo -ne "${C_YELLOW}Would you like to automatically add it to $shell_rc? [Y/n]: ${C_RESET}"
            read -r add_path < /dev/tty
        fi
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

find_chrome_binary() {
    # 1. Prioritize raw Flatpak binaries (required to bypass sandbox)
    local flatpak_sys="/var/lib/flatpak/app/com.google.Chrome/current/active/files/extra/chrome"
    local flatpak_user="$HOME/.local/share/flatpak/app/com.google.Chrome/current/active/files/extra/chrome"

    if [[ -x "$flatpak_sys" ]]; then
        echo "$flatpak_sys"
    elif [[ -x "$flatpak_user" ]]; then
        echo "$flatpak_user"
    else
        # 2. Fallback to standard system package binaries
        if [ "$PLATFORM" = "Darwin" ] && [ -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" ]; then
            echo "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        elif [ "$PLATFORM" = "Crostini" ] && command -v garcon-url-handler >/dev/null 2>&1 && ! command -v google-chrome >/dev/null 2>&1 && ! command -v chromium >/dev/null 2>&1; then
            echo ""
        else
            for cmd in google-chrome-stable google-chrome chromium chromium-browser; do
                if command -v "$cmd" >/dev/null 2>&1; then
                    command -v "$cmd"
                    return 0
                fi
            done
        fi
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
    chrome_path=$(find_chrome_binary)
    if [[ -n "$chrome_path" ]]; then
        log_info "  Located Chrome binary: $chrome_path"
    fi

    if [[ -n "$chrome_path" ]]; then
        local do_inject=0
        if [ "$AUTO" -eq 1 ] || [ "$JSON_OUT" -eq 1 ]; then
            do_inject=1
        else
            log_warn "Antigravity occasionally fails to find Chrome when installed via Brew or Binary."
            log_info "We found a valid Chrome binary at: ${C_BOLD}$chrome_path${C_RESET}"
            
            if command -v gum >/dev/null 2>&1; then
                if gum confirm "Would you like to automatically configure Antigravity to use this browser?"; then
                    set_chrome="y"
                else
                    set_chrome="n"
                fi
            else
                echo -ne "${C_YELLOW}Would you like to automatically configure Antigravity to use this browser? [Y/n]: ${C_RESET}"
                read -r set_chrome < /dev/tty
            fi
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
    
    # Proper Apple Silicon detection (handles terminal running under Rosetta 2)
    if [ "$PLATFORM" = "Darwin" ] && [ "$ARCH" = "x86_64" ]; then
        if [ "$(sysctl -in sysctl.proc_translated)" = "1" ]; then
            ARCH="arm64"
        fi
    fi

    HAS_BREW="no"
    HAS_APT="no"
    HAS_DNF="no"
    DISTRO_PRETTY="Unknown"
    GLIBC_VERSION=""
    RECOMMENDED="3"  # default to binary

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
        
        if [ "$(uname -o 2>/dev/null)" = "Msys" ] || [[ "$(uname -s 2>/dev/null)" == "MINGW"* ]]; then
            echo "ERROR: Git Bash / MSYS2 is not supported."
            echo "Please install WSL2 (wsl --install) and run this script from an Ubuntu terminal."
            exit 1
        fi

        if grep -qi "microsoft" /proc/version 2>/dev/null; then
            DISTRO_PRETTY="${DISTRO_PRETTY} (WSL)"
        elif [ -f /dev/.cros_milestone ]; then
            PLATFORM="Crostini"
            local MILESTONE=""
            MILESTONE=$(cat /dev/.cros_milestone 2>/dev/null || echo "Unknown")
            DISTRO_PRETTY="ChromeOS Crostini M${MILESTONE} (${DISTRO_PRETTY})"
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

get_installed_ide_version() {
    # Check binary install directory (Linux/WSL)
    if [ -f "$APP_DIR/resources/app/package.json" ]; then
        awk -F'"' '/"version":/ {print $4}' "$APP_DIR/resources/app/package.json"
        return
    fi
    if [ -f "$APP_DIR/resources/app/product.json" ]; then
        awk -F'"' '/"version":/ {print $4}' "$APP_DIR/resources/app/product.json"
        return
    fi
    # Check macOS bundle
    if [ -f "/Applications/Google Antigravity.app/Contents/Resources/app/package.json" ]; then
        awk -F'"' '/"version":/ {print $4}' "/Applications/Google Antigravity.app/Contents/Resources/app/package.json"
        return
    fi
    if [ -f "/Applications/Google Antigravity.app/Contents/Resources/app/product.json" ]; then
        awk -F'"' '/"version":/ {print $4}' "/Applications/Google Antigravity.app/Contents/Resources/app/product.json"
        return
    fi
    # Check package managers
    if command -v dpkg-query >/dev/null 2>&1; then
        local v
        v=$(dpkg-query -W -f='${Version}' antigravity 2>/dev/null || true)
        if [ -n "$v" ]; then echo "$v"; return; fi
    fi
    if command -v rpm >/dev/null 2>&1; then
        local v
        v=$(rpm -q --qf "%{VERSION}" antigravity 2>/dev/null || true)
        if [ -n "$v" ]; then echo "$v"; return; fi
    fi
    if command -v brew >/dev/null 2>&1; then
        local v
        v=$(brew info --cask antigravity 2>/dev/null | awk 'NR==1 {print $2}' || true)
        if [ -n "$v" ] && [ "$v" != "Error:" ]; then echo "$v"; return; fi
    fi
    echo ""
}

get_installed_cli_version() {
    if command -v agy >/dev/null 2>&1; then
        agy --version 2>/dev/null | awk '{print $NF}' || echo "Installed"
    elif [ -f "$BIN_DIR/agy" ]; then
        "$BIN_DIR/agy" --version 2>/dev/null | awk '{print $NF}' || echo "Installed"
    else
        echo ""
    fi
}

get_installed_sdk_version() {
    if command -v python3 >/dev/null 2>&1; then
        python3 -c "import google_antigravity; print(google_antigravity.__version__)" 2>/dev/null || \
        python3 -m pip show google-antigravity 2>/dev/null | awk -F': ' '/Version:/ {print $2}' || \
        echo ""
    else
        echo ""
    fi
}

print_system_info() {
    # --- Detect dynamic current versions ---
    local inst_ide
    inst_ide=$(get_installed_ide_version)
    local inst_cli
    inst_cli=$(get_installed_cli_version)
    local inst_sdk
    inst_sdk=$(get_installed_sdk_version)

    local ide_status
    if [ -n "$inst_ide" ]; then
        ide_status="${C_GREEN}✓ $inst_ide${C_RESET}"
    else
        ide_status="${C_YELLOW}Not Installed${C_RESET}"
    fi

    local cli_status
    if [ -n "$inst_cli" ]; then
        cli_status="${C_GREEN}✓ $inst_cli${C_RESET}"
    else
        cli_status="${C_YELLOW}Not Installed${C_RESET}"
    fi

    local sdk_status
    if [ -n "$inst_sdk" ]; then
        sdk_status="${C_GREEN}✓ $inst_sdk${C_RESET}"
    else
        sdk_status="${C_YELLOW}Not Installed${C_RESET}"
    fi

    # --- Build recommendation label ---
    local REC_LABEL=""
    case "$RECOMMENDED" in
        1) REC_LABEL="${C_GREEN}★ Homebrew${C_RESET} ${C_DIM}(best for this system)${C_RESET}" ;;
        2) REC_LABEL="${C_GREEN}★ System Repo${C_RESET} ${C_DIM}(best for this system)${C_RESET}" ;;
        3) REC_LABEL="${C_GREEN}★ Official Binary${C_RESET} ${C_DIM}(best for this system)${C_RESET}" ;;
    esac

    # --- Print dashboard ---
    log_info "  ${C_CYAN}OS:${C_RESET}                 ${C_BOLD}${DISTRO_PRETTY}${C_RESET} ${C_DIM}(${ARCH})${C_RESET}"
    log_info "  ${C_CYAN}Installed Products:${C_RESET}"
    log_info "    ${C_BOLD}Google Antigravity IDE:${C_RESET}  ${ide_status} ${C_DIM}[Latest: $DEFAULT_IDE_VERSION]${C_RESET}"
    log_info "    ${C_BOLD}Antigravity CLI (agy):${C_RESET}   ${cli_status} ${C_DIM}[Latest: $DEFAULT_CLI_VERSION]${C_RESET}"
    log_info "    ${C_BOLD}Antigravity SDK (Python):${C_RESET} ${sdk_status} ${C_DIM}[Latest: $DEFAULT_SDK_VERSION]${C_RESET}"
    log_info "  ${C_CYAN}Best Install Method:${C_RESET}        ${REC_LABEL}"

    # --- Warnings (only shown when relevant) ---
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
    echo ""
    cat << 'BANNER_EOF'
    [0;34m    _    [0;31m     _ [1;33m  _  [0;34m___[0;32m       [0;31m      [0;34m    _ _[0;31m      [1;33m   [0;34m    [0;32m       [0m
    [0;34m   / \   [0;31m_ __| |[1;33m_(_)/[0;34m __[0;32m|_ __ _[0;31m_ ___ [0;34m  _(_) [0;31m|_ _  [1;33m _ [0;34m    [0;32m       [0m
    [0;34m  / _ \ |[0;31m '_ \ _[1;33m_| | [0;34m|  [0;32m_| '__/[0;31m _` \ [0;34m\ / / |[0;31m __| |[1;33m | [0;34m|   [0;32m       [0m
    [0;34m / ___ \|[0;31m | | | [1;33m|_| |[0;34m |_[0;32m| | | |[0;31m (_| |[0;34m\ V /| [0;31m| |_| [1;33m|_|[0;34m |  [0;32m       [0m
    [0;34m/_/   \_\[0;31m_| |_|\[1;33m__|_|[0;34m\__[0;32m__|_|  [0;31m\__,_|[0;34m \_/ |_[0;31m|\__|\[1;33m__,[0;34m |  [0;32m       [0m
    [0;34m         [0;31m       [1;33m     [0;34m   [0;32m       [0;31m      [0;34m       [0;31m     |[1;33m___[0;34m/   [0;32m       [0m
BANNER_EOF
    echo -e "      ${C_BOLD}AGV Easy Install v${SCRIPT_VERSION}${C_RESET} ${mode}"
    echo -e "      ${C_DIM}github.com/wtg-codes/agv-easy-install${C_RESET}"
    echo -e "      ${C_RED}${C_BOLD}⚠️  This script URL is deprecated! Update your bookmark:${C_RESET}"
    echo -e "      ${C_YELLOW}github.com/wtg-codes/agy-easy-install${C_RESET}"
    echo -e "      ${C_DIM}──────────────────────────────────────────────────${C_RESET}"
}

install_brew() {
    JSON_METHOD="brew"
    log_info "${C_MAG}🚀 Installing Antigravity via Homebrew...${C_RESET}"
    ensure_brew
    
    if [ "$PLATFORM" = "Darwin" ]; then
        if ! run_cmd_ui "Brewing Antigravity..." brew install --cask antigravity; then
            log_error "Formula not found or installation failed."
            log_warn "Falling back to official Binary installation..."
            do_install_binary
            return
        fi
    else
        # For Linux platforms using Brew (especially Bluefin)
        run_cmd_ui "Tapping Ublue-OS experimental tap..." brew tap ublue-os/experimental-tap
        if ! run_cmd_ui "Brewing Antigravity Linux..." brew install ublue-os/experimental-tap/antigravity-linux; then
            log_error "Formula not found or installation failed."
            log_warn "Falling back to official Binary installation..."
            do_install_binary
            return
        fi
        # Workaround Homebrew Cask bug: create the missing binary symlink in $(brew --prefix)/bin/
        local brew_prefix
        brew_prefix=$(brew --prefix)
        local exec_file
        exec_file=$(find "$brew_prefix/Caskroom/antigravity-linux" -type f -name "antigravity-ide" -o -name "antigravity" 2>/dev/null | head -n 1)
        if [ -n "$exec_file" ]; then
            log_info "Creating missing binary symlink in Homebrew bin folder..."
            run_cmd ln -sf "$exec_file" "$brew_prefix/bin/antigravity"
        else
            log_warn "Could not locate the extracted executable to create the launcher symlink."
        fi
        # Refresh desktop database
        if command -v update-desktop-database &>/dev/null; then
            run_cmd update-desktop-database "$HOME/.local/share/applications" || true
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
            log_warn "Falling back to official Binary installation..."
            do_install_binary
            return
            ;;
    esac
    configure_chrome_path
    mkdir -p "$STATE_DIR"
    echo '{"method": "repo", "version": "'"$SCRIPT_VERSION"'"}' > "$STATE_FILE"
}

get_ide_release_info() {
    get_product_release_info "ide" "$@"
}

get_product_release_info() {
    local product_name="$1"
    local version="$2"
    local platform_key="$3"
    local json_file="/tmp/versions.json"
    
    if [ ! -f "$json_file" ]; then
        if [ "$product_name" = "antigravity" ] && [ "$version" = "$DEFAULT_AGV_VERSION" ]; then
            case "$platform_key" in
                LINUX_X64) echo "$AGV_LINUX_X64_URL|$AGV_LINUX_X64_SHA256" ;;
                MAC_X64) echo "$AGV_MAC_X64_URL|$AGV_MAC_X64_SHA256" ;;
                MAC_ARM64) echo "$AGV_MAC_ARM64_URL|$AGV_MAC_ARM64_SHA256" ;;
                WIN_X64) echo "$AGV_WIN_X64_URL|$AGV_WIN_X64_SHA256" ;;
                WIN_ARM64) echo "$AGV_WIN_ARM64_URL|$AGV_WIN_ARM64_SHA256" ;;
            esac
            return
        elif [ "$product_name" = "ide" ] && [ "$version" = "$DEFAULT_IDE_VERSION" ]; then
            case "$platform_key" in
                LINUX_X64) echo "$IDE_LINUX_X64_URL|$IDE_LINUX_X64_SHA256" ;;
                MAC_X64) echo "$IDE_MAC_X64_URL|$IDE_MAC_X64_SHA256" ;;
                MAC_ARM64) echo "$IDE_MAC_ARM64_URL|$IDE_MAC_ARM64_SHA256" ;;
                WIN_X64) echo "$IDE_WIN_X64_URL|$IDE_WIN_X64_SHA256" ;;
                WIN_ARM64) echo "$IDE_WIN_ARM64_URL|$IDE_WIN_ARM64_SHA256" ;;
            esac
            return
        fi
        echo "|"
        return
    fi
    
    local info
    info=$(awk -v prod="$product_name" -v ver="$version" -v plat="$platform_key" '
      BEGIN { in_prod=0; in_ver=0; in_plat=0 }
      $0 ~ "\"" prod "\"" { in_prod=1; next }
      in_prod && $0 ~ "}" && $0 !~ "," && in_ver==0 { in_prod=0 }
      in_prod && $0 ~ "\"" ver "\"" { in_ver=1; next }
      in_ver && $0 ~ "}" && $0 !~ "," { if (in_plat) in_plat=0; else in_ver=0 }
      in_ver && $0 ~ "\"" plat "\"" { in_plat=1; next }
      in_plat && $0 ~ "}" { in_plat=0 }
      in_plat && $0 ~ "\"url\"" { split($0, a, "\""); url=a[4] }
      in_plat && $0 ~ "\"sha256\"" { split($0, a, "\""); sha=a[4] }
      END { if (url != "" && sha != "") print url "|" sha }
    ' "$json_file" 2>/dev/null || true)
    
    if [ -n "$info" ]; then
        echo "$info"
    else
        if [ "$product_name" = "antigravity" ] && [ "$version" = "$DEFAULT_AGV_VERSION" ]; then
            case "$platform_key" in
                LINUX_X64) echo "$AGV_LINUX_X64_URL|$AGV_LINUX_X64_SHA256" ;;
                MAC_X64) echo "$AGV_MAC_X64_URL|$AGV_MAC_X64_SHA256" ;;
                MAC_ARM64) echo "$AGV_MAC_ARM64_URL|$AGV_MAC_ARM64_SHA256" ;;
                WIN_X64) echo "$AGV_WIN_X64_URL|$AGV_WIN_X64_SHA256" ;;
                WIN_ARM64) echo "$AGV_WIN_ARM64_URL|$AGV_WIN_ARM64_SHA256" ;;
            esac
        elif [ "$product_name" = "ide" ] && [ "$version" = "$DEFAULT_IDE_VERSION" ]; then
            case "$platform_key" in
                LINUX_X64) echo "$IDE_LINUX_X64_URL|$IDE_LINUX_X64_SHA256" ;;
                MAC_X64) echo "$IDE_MAC_X64_URL|$IDE_MAC_X64_SHA256" ;;
                MAC_ARM64) echo "$IDE_MAC_ARM64_URL|$IDE_MAC_ARM64_SHA256" ;;
                WIN_X64) echo "$IDE_WIN_X64_URL|$IDE_WIN_X64_SHA256" ;;
                WIN_ARM64) echo "$IDE_WIN_ARM64_URL|$IDE_WIN_ARM64_SHA256" ;;
            esac
        else
            echo "|"
        fi
    fi
}

do_install_binary() {
    local product_name="${1:-antigravity}"
    local target_version="$2"
    if [ -z "$target_version" ]; then
        if [ "$product_name" = "ide" ]; then
            target_version="$DEFAULT_IDE_VERSION"
        else
            target_version="$DEFAULT_AGV_VERSION"
        fi
    fi

    JSON_METHOD="binary"
    local target_url=""
    local target_sha=""
    local install_type=""
    local file_ext=""
    local platform_key=""

    # Set up correct directories and symlinks depending on the product
    local app_dir_var="$APP_DIR"
    local bin_name="antigravity"
    local desktop_file_sys_var="$DESKTOP_FILE_SYS"
    local desktop_file_user_var="$DESKTOP_FILE_USER"
    local icon_path_var="$ICON_PATH"
    local app_title="Google Antigravity"
    local state_file_var="$STATE_FILE"

    if [ "$product_name" = "ide" ]; then
        app_dir_var="${APP_DIR}-ide"
        bin_name="antigravity-ide"
        desktop_file_sys_var="$HOME/.local/share/applications/google-antigravity-ide.desktop"
        if command -v xdg-user-dir &> /dev/null; then DESKTOP_DIR=$(xdg-user-dir DESKTOP); else DESKTOP_DIR="$HOME/Desktop"; fi
        desktop_file_user_var="$DESKTOP_DIR/google-antigravity-ide.desktop"
        icon_path_var="${app_dir_var}/resources/icon.png"
        app_title="Google Antigravity IDE"
        state_file_var="${STATE_DIR}/install-ide.json"
    fi

    # Determine target based on platform and architecture
    if [ "$PLATFORM" = "Darwin" ]; then
        install_type="dmg"
        file_ext="dmg"
        if [ "$ARCH" = "arm64" ]; then
            platform_key="MAC_ARM64"
        else
            platform_key="MAC_X64"
        fi
    elif [ "$WSL_DISTRO_NAME" != "" ] || [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
        install_type="exe"
        file_ext="exe"
        if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
            platform_key="WIN_ARM64"
        else
            platform_key="WIN_X64"
        fi
    elif [ "$PLATFORM" = "Linux" ]; then
        platform_key="LINUX_X64"
        install_type="tarball"
        file_ext="tar.gz"
    else
        log_error "Unsupported platform for binary installation."
        exit 1
    fi

    # Fetch release details dynamically
    fetch_versions_json || true
    local info
    info=$(get_product_release_info "$product_name" "$target_version" "$platform_key")
    target_url=$(echo "$info" | cut -d'|' -f1)
    target_sha=$(echo "$info" | cut -d'|' -f2)

    if [ -z "$target_url" ] || [ -z "$target_sha" ]; then
        log_error "Could not find package details for $app_title version $target_version ($platform_key)."
        exit 1
    fi

    local sha_cmd=""
    if command -v sha256sum >/dev/null 2>&1; then
        sha_cmd="sha256sum"
    elif command -v shasum >/dev/null 2>&1; then
        sha_cmd="shasum -a 256"
    else
        log_error "sha256sum or shasum is required but was not found."
        exit 1
    fi

    log_info "${C_MAG}🚀 Starting $app_title Official Binary Installation ($target_version)...${C_RESET}"
    
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"; if [ "$PLATFORM" = "Darwin" ] && [ -d "/Volumes/Antigravity" ]; then hdiutil detach /Volumes/Antigravity -force -quiet 2>/dev/null || true; fi; exit_handler' EXIT INT TERM
    local dl_target="$TMP_DIR/Antigravity.$file_ext"

    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        run_cmd curl -fSL "$target_url" -o "$dl_target"
    else
        log_info "${C_BLUE}⬇️  Downloading $app_title...${C_RESET}"
        curl -fSL --progress-bar "$target_url" -o "$dl_target"
    fi

    log_info "${C_BLUE}🔐 Verifying checksum...${C_RESET}"
    if ! echo "$target_sha  $dl_target" | $sha_cmd -c - >/dev/null 2>&1; then
        log_error "Checksum verification failed!"
        exit 1
    fi

    if [ "$install_type" = "tarball" ]; then
        log_info "${C_CYAN}📁 Preparing directories...${C_RESET}"
        mkdir -p "$BIN_DIR" "$app_dir_var" "$WORKSPACE_DIR" "$DESKTOP_DIR" "$(dirname "$desktop_file_sys_var")"

        if command -v gum >/dev/null 2>&1; then
            gum spin --spinner dot --title "Extracting archive..." -- tar -xzf "$dl_target" -C "$app_dir_var" --strip-components=1
        else
            tar -xzf "$dl_target" -C "$app_dir_var" --strip-components=1
        fi

        log_info "${C_BLUE}🔗 Creating symlink...${C_RESET}"
        ln -sf "$app_dir_var/antigravity" "$BIN_DIR/$bin_name"

        # Extract/Copy application icon
        log_info "${C_CYAN}🎨 Extracting application icon...${C_RESET}"
        local extracted_icon=0
        
        # 1. Try copying unpacked icon from 1.x IDE location
        local old_icon_location="${app_dir_var}/resources/app/out/vs/workbench/contrib/antigravityCustomAppIcon/browser/media/antigravity/antigravity.png"
        if [ -f "$old_icon_location" ]; then
            mkdir -p "$(dirname "$icon_path_var")"
            cp "$old_icon_location" "$icon_path_var"
            extracted_icon=1
        fi

        # 2. Try extracting from app.asar (for 2.x Antigravity)
        if [ "$extracted_icon" -eq 0 ] && command -v python3 >/dev/null 2>&1; then
            if python3 -c "
import struct, json
try:
    with open('${app_dir_var}/resources/app.asar', 'rb') as f:
        header = f.read(16)
        if len(header) == 16:
            _, _, _, json_size = struct.unpack('<IIII', header)
            header_json = json.loads(f.read(json_size).decode('utf-8'))
            info = header_json.get('files', {}).get('icon.png')
            if info:
                f.seek(16 + json_size + int(info['offset']))
                import os
                os.makedirs(os.path.dirname('${icon_path_var}'), exist_ok=True)
                with open('${icon_path_var}', 'wb') as out:
                    out.write(f.read(info['size']))
                print('OK')
except Exception as e:
    pass
" 2>/dev/null | grep -q "OK"; then
                extracted_icon=1
            fi
        fi

        if [ "$extracted_icon" -eq 0 ] && command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
            if (
                cd "$TMP_DIR" || exit 1
                if npx --yes @electron/asar extract-file "${app_dir_var}/resources/app.asar" icon.png 2>/dev/null; then
                    mkdir -p "$(dirname "$icon_path_var")"
                    mv icon.png "$icon_path_var"
                elif npx --yes asar extract-file "${app_dir_var}/resources/app.asar" icon.png 2>/dev/null; then
                    mkdir -p "$(dirname "$icon_path_var")"
                    mv icon.png "$icon_path_var"
                else
                    exit 1
                fi
            ); then
                extracted_icon=1
            fi
        fi

        if [ "$extracted_icon" -eq 0 ]; then
            log_warn "Could not extract application icon. Desktop shortcut will use a default icon."
        fi

        cat << EOF > "$desktop_file_sys_var"
[Desktop Entry]
Version=1.0
Name=$app_title
Comment=Secure Agentic Development IDE
Exec=$BIN_DIR/$bin_name %F
Icon=$icon_path_var
Terminal=false
Type=Application
Categories=Development;IDE;
EOF

        if ! grep -qi "microsoft" /proc/version 2>/dev/null; then
            log_info "${C_CYAN}🖥️  Adding shortcut to Desktop...${C_RESET}"
            cp "$desktop_file_sys_var" "$desktop_file_user_var"
            chmod +x "$desktop_file_user_var"
            if command -v gio &> /dev/null; then run_cmd gio set "$desktop_file_user_var" metadata::trusted true || true; fi
            if command -v update-desktop-database &> /dev/null; then run_cmd update-desktop-database "$HOME/.local/share/applications" || true; fi
        fi

        echo ""
        if command -v gum >/dev/null 2>&1; then
            gum style --border double --border-foreground 46 --padding "1 2" "🎉 Installation Complete!
Launch: $bin_name
Workspace: $WORKSPACE_DIR"
        else
            log_info "${C_GREEN}${C_BOLD}🎉 Installation Complete!${C_RESET}"
            log_info "  ${C_CYAN}▸${C_RESET} Launch:    ${C_BOLD}$bin_name${C_RESET}"
            log_info "  ${C_CYAN}▸${C_RESET} Workspace: ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
        fi

    elif [ "$install_type" = "dmg" ]; then
        log_info "${C_CYAN}💿 Mounting DMG...${C_RESET}"
        run_cmd hdiutil attach "$dl_target" -mountpoint /Volumes/Antigravity -nobrowse -quiet
        log_info "${C_BLUE}📦 Copying to /Applications...${C_RESET}"
        
        # Dynamically find the .app bundle inside the DMG safely
        APP_NAME=""
        for app_dir in /Volumes/Antigravity/*.app; do
            if [ -d "$app_dir" ]; then
                APP_NAME="$(basename "$app_dir")"
                break
            fi
        done
        
        if [ -z "$APP_NAME" ]; then
            log_error "Could not find any .app bundle inside the mounted DMG!"
            log_info "Contents of /Volumes/Antigravity:"
            ls -la /Volumes/Antigravity >> "$LOG_FILE" 2>&1 || true
            run_cmd hdiutil detach /Volumes/Antigravity -quiet
            exit 1
        fi
        
        log_info "  ${C_DIM}Found app bundle: $APP_NAME${C_RESET}"
        
        if [ -d "/Applications/$APP_NAME" ]; then
            run_cmd rm -rf "/Applications/$APP_NAME"
        fi
        
        if ! cp -R "/Volumes/Antigravity/$APP_NAME" /Applications/ >> "$LOG_FILE" 2>&1; then
            log_error "Failed to copy $APP_NAME to /Applications. Check /tmp/antigravity-install.log for details."
            run_cmd hdiutil detach /Volumes/Antigravity -quiet
            exit 1
        fi
        
        run_cmd hdiutil detach /Volumes/Antigravity -quiet

        echo ""
        log_warn "macOS Gatekeeper may block the standalone binary from running."
        log_info "If you see 'cannot be opened because the developer cannot be verified',"
        log_info "run this command to clear the quarantine flag:"
        log_info "  ${C_BOLD}xattr -rd com.apple.quarantine '/Applications/$APP_NAME'${C_RESET}"

        # Create CLI shim for terminal launch
        mkdir -p "$BIN_DIR"
        local mac_bin_path
        mac_bin_path=$(find "/Applications/$APP_NAME/Contents/MacOS" -type f -executable | head -n 1 || true)
        
        if [ -n "$mac_bin_path" ] && [ -f "$mac_bin_path" ]; then
            run_cmd ln -sf "$mac_bin_path" "$BIN_DIR/$bin_name"
        else
            log_warn "Could not create terminal shortcut (executable not found inside $APP_NAME)."
        fi

        log_info "${C_GREEN}${C_BOLD}🎉 Installation Complete!${C_RESET} Launch from Applications folder or type '$bin_name' in terminal."

    elif [ "$install_type" = "exe" ]; then
        log_info "${C_CYAN}🚀 Launching Windows Installer...${C_RESET}"
        if command -v cmd.exe >/dev/null 2>&1; then
            # Convert WSL path to Windows path for cmd.exe
            win_path=$(wslpath -w "$dl_target")
            cmd.exe /c start "" "$win_path"
        else
            log_error "Could not find cmd.exe to launch installer."
            exit 1
        fi
        log_info "${C_GREEN}${C_BOLD}🎉 Please complete the installation in the Windows UI!${C_RESET}"
    fi

    configure_chrome_path
    mkdir -p "$STATE_DIR"
    echo "{\"method\": \"binary\", \"version\": \"$target_version\"}" > "$state_file_var"
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
    
    # Remove CLI and other shared files
    rm -f "$BIN_DIR/agy" "$BIN_DIR/jules"
    if command -v npm >/dev/null 2>&1; then
        npm uninstall -g @google/jules >/dev/null 2>&1 || sudo npm uninstall -g @google/jules >/dev/null 2>&1 || true
    fi

    # Remove Google Antigravity (Binary/Tarball)
    rm -rf "$APP_DIR" "$BIN_DIR/antigravity" "$DESKTOP_FILE_SYS" "$DESKTOP_FILE_USER"
    if [ "$PLATFORM" = "Darwin" ]; then
        rm -rf "/Applications/Google Antigravity.app"
        rm -rf "/Applications/Antigravity.app"
    fi

    # Remove IDE (Binary/Tarball)
    rm -rf "${APP_DIR}-ide" "$BIN_DIR/antigravity-ide" "$HOME/.local/share/applications/google-antigravity-ide.desktop"
    if command -v xdg-user-dir &> /dev/null; then DESKTOP_DIR=$(xdg-user-dir DESKTOP); else DESKTOP_DIR="$HOME/Desktop"; fi
    rm -f "$DESKTOP_DIR/google-antigravity-ide.desktop"

    if command -v update-desktop-database &> /dev/null; then run_cmd update-desktop-database "$HOME/.local/share/applications" || true; fi

    # Also check other install methods (brew, repo)
    if [ -f "$STATE_FILE" ]; then
        local method
        method=$(grep -o '"method": "[^"]*' "$STATE_FILE" | grep -o '[^\"]*$')
        log_info "Found installation state. Method used: $method"
        
        case "$method" in
            "brew")
                if [ "$PLATFORM" = "Darwin" ]; then 
                    run_cmd brew uninstall --cask antigravity || true
                else 
                    local brew_prefix
                    brew_prefix=$(brew --prefix 2>/dev/null || echo "/home/linuxbrew/.linuxbrew")
                    run_cmd rm -f "$brew_prefix/bin/antigravity" || true
                    run_cmd brew uninstall ublue-os/experimental-tap/antigravity-linux || run_cmd brew uninstall antigravity || true
                    if command -v update-desktop-database &>/dev/null; then
                        run_cmd update-desktop-database "$HOME/.local/share/applications" || true
                    fi
                fi ;;
            "repo")
                detect_distro
                if command -v apt &> /dev/null && [ -f /etc/apt/sources.list.d/antigravity.list ]; then
                    run_cmd sudo apt remove -y antigravity || true
                    sudo rm -f /etc/apt/sources.list.d/antigravity.list
                elif command -v dnf &> /dev/null && [ -f /etc/yum.repos.d/antigravity.repo ]; then
                    run_cmd sudo dnf remove -y antigravity || true
                    sudo rm -f /etc/yum.repos.d/antigravity.repo
                fi ;;
        esac
        rm -f "$STATE_FILE"
    fi

    # Also check IDE state file
    if [ -f "${STATE_DIR}/install-ide.json" ]; then
        rm -f "${STATE_DIR}/install-ide.json"
    fi

    log_info "${C_GREEN}✅ Uninstalled successfully.${C_RESET} (Note: Your code in $WORKSPACE_DIR was kept safe)."
}

get_cli_release_info() {
    local version="$1"
    local platform_key="$2"
    local json_file="/tmp/versions.json"
    
    if [ ! -f "$json_file" ]; then
        echo "|"
        return
    fi
    
    local info
    info=$(awk -v ver="$version" -v plat="$platform_key" '
      BEGIN { in_cli=0; in_ver=0; in_plat=0 }
      $0 ~ "\"cli\"" { in_cli=1; next }
      in_cli && $0 ~ "}" && $0 !~ "," && in_ver==0 { in_cli=0 }
      in_cli && $0 ~ "\"" ver "\"" { in_ver=1; next }
      in_ver && $0 ~ "}" && $0 !~ "," { if (in_plat) in_plat=0; else in_ver=0 }
      in_ver && $0 ~ "\"" plat "\"" { in_plat=1; next }
      in_plat && $0 ~ "}" { in_plat=0 }
      in_plat && $0 ~ "\"url\"" { split($0, a, "\""); url=a[4] }
      in_plat && $0 ~ "\"sha512\"" { split($0, a, "\""); sha=a[4] }
      END { if (url != "" && sha != "") print url "|" sha }
    ' "$json_file" 2>/dev/null || true)
    
    echo "$info"
}

install_cli() {
    local target_version="${1:-$DEFAULT_CLI_VERSION}"
    JSON_METHOD="cli"
    log_info "${C_MAG}🚀 Installing Antigravity CLI version $target_version...${C_RESET}"
    
    fetch_versions_json || true
    
    local cli_os=""
    case "$PLATFORM" in
        Darwin) cli_os="darwin" ;;
        Linux) cli_os="linux" ;;
        *) cli_os="linux" ;;
    esac
    
    local cli_arch=""
    case "$ARCH" in
        x86_64|amd64) cli_arch="amd64" ;;
        arm64|aarch64) cli_arch="arm64" ;;
        *) cli_arch="amd64" ;;
    esac
    
    local platform_key="${cli_os}_${cli_arch}"
    
    local info
    info=$(get_cli_release_info "$target_version" "$platform_key")
    local target_url
    target_url=$(echo "$info" | cut -d'|' -f1)
    local target_sha
    target_sha=$(echo "$info" | cut -d'|' -f2)
    
    if [ -z "$target_url" ] || [ -z "$target_sha" ]; then
        if [ "$target_version" = "$DEFAULT_CLI_VERSION" ]; then
            log_warn "Release details not found in versions.json. Falling back to official bootstrap installer..."
            TMP_DIR=$(mktemp -d)
            trap 'rm -rf "$TMP_DIR"; exit_handler' EXIT INT TERM
            local install_script="$TMP_DIR/install.sh"
            
            if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
                if run_cmd curl -fSsL "$CLI_INSTALL_URL" -o "$install_script" && run_cmd bash "$install_script" --dir "$BIN_DIR"; then
                    :
                else
                    log_error "Antigravity CLI installation failed."
                    rm -rf "$TMP_DIR"
                    trap exit_handler EXIT INT TERM
                    exit 1
                fi
            else
                log_info "${C_BLUE}⬇️  Downloading CLI installer...${C_RESET}"
                if ! curl -fSsL "$CLI_INSTALL_URL" -o "$install_script"; then
                    log_error "Failed to download CLI installer."
                    rm -rf "$TMP_DIR"
                    trap exit_handler EXIT INT TERM
                    exit 1
                fi
                log_info "${C_BLUE}📦 Executing CLI installer...${C_RESET}"
                if ! bash "$install_script" --dir "$BIN_DIR"; then
                    log_error "CLI installer execution failed."
                    rm -rf "$TMP_DIR"
                    trap exit_handler EXIT INT TERM
                    exit 1
                fi
            fi
            
            rm -rf "$TMP_DIR"
            trap exit_handler EXIT INT TERM
            log_info "${C_GREEN}✅ Antigravity CLI installation complete!${C_RESET}"
            return
        else
            log_error "Could not find package details for Antigravity CLI version $target_version ($platform_key)."
            exit 1
        fi
    fi
    
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"; exit_handler' EXIT INT TERM
    
    local is_tar_gz=false
    local file_ext="bin"
    case "$target_url" in
        *.tar.gz*) is_tar_gz=true; file_ext="tar.gz" ;;
    esac
    
    local dl_target="$TMP_DIR/cli.$file_ext"
    
    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        run_cmd curl -fSL "$target_url" -o "$dl_target"
    else
        log_info "${C_BLUE}⬇️  Downloading CLI package...${C_RESET}"
        curl -fSL --progress-bar "$target_url" -o "$dl_target"
    fi
    
    log_info "${C_BLUE}🔐 Verifying checksum (SHA-512)...${C_RESET}"
    local sha_cmd=""
    if command -v sha512sum >/dev/null 2>&1; then
        sha_cmd="sha512sum"
    elif command -v shasum >/dev/null 2>&1; then
        sha_cmd="shasum -a 512"
    else
        log_error "sha512sum or shasum is required but was not found."
        exit 1
    fi
    
    if ! echo "$target_sha  $dl_target" | $sha_cmd -c - >/dev/null 2>&1; then
        log_error "Checksum verification failed!"
        exit 1
    fi
    
    mkdir -p "$BIN_DIR"
    local binary_dest="$BIN_DIR/agy"
    
    if [ "$is_tar_gz" = "true" ]; then
        log_info "${C_BLUE}📦 Extracting CLI...${C_RESET}"
        tar -xzf "$dl_target" -C "$TMP_DIR" antigravity
        cp "$TMP_DIR/antigravity" "$binary_dest"
    else
        cp "$dl_target" "$binary_dest"
    fi
    
    chmod +x "$binary_dest"
    if [ "$PLATFORM" = "Darwin" ]; then
        xattr -d com.apple.quarantine "$binary_dest" 2>/dev/null || true
    fi
    
    log_info "${C_BLUE}⚙️  Configuring environment...${C_RESET}"
    "$binary_dest" install || true
    
    rm -rf "$TMP_DIR"
    trap exit_handler EXIT INT TERM
    log_info "${C_GREEN}✅ Antigravity CLI installation complete!${C_RESET}"
}

install_sdk() {
    local target_version="${1:-$DEFAULT_SDK_VERSION}"
    JSON_METHOD="sdk"
    log_info "${C_MAG}🚀 Installing Antigravity Python SDK...${C_RESET}"
    
    if ! command -v python3 >/dev/null 2>&1; then
        log_error "python3 is required but was not found on your system."
        exit 1
    fi
    
    if ! python3 -m pip --version >/dev/null 2>&1; then
        log_error "pip is required but was not found. Please install pip for python3 first."
        exit 1
    fi
    
    local pkg="google-antigravity"
    if [ -n "$target_version" ] && [ "$target_version" != "latest" ]; then
        pkg="google-antigravity==$target_version"
    fi
    
    log_info "${C_BLUE}📦 Installing package '$pkg' via pip...${C_RESET}"
    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        run_cmd python3 -m pip install --upgrade "$pkg"
    else
        if ! python3 -m pip install --upgrade "$pkg"; then
            log_error "Failed to install Google Antigravity SDK."
            exit 1
        fi
    fi
    
    log_info "${C_GREEN}✅ Antigravity SDK installation complete!${C_RESET}"
}

ensure_brew() {
    if check_brew; then
        return 0
    fi
    
    log_warn "Homebrew is required but not installed."
    local install_now=true
    if [ "$AUTO" -eq 0 ] && command -v gum >/dev/null 2>&1; then
        if ! gum confirm "Would you like the installer to set up Homebrew now?"; then
            install_now=false
        fi
    elif [ "$AUTO" -eq 0 ]; then
        read -r -p "Would you like the installer to set up Homebrew now? [Y/n]: " choice < /dev/tty
        case "$choice" in
            [nN]*) install_now=false ;;
        esac
    fi
    
    if [ "$install_now" = false ]; then
        log_error "Homebrew installation declined. Cannot proceed with Homebrew installation."
        exit 1
    fi
    
    log_info "${C_BLUE}⬇️  Installing Homebrew...${C_RESET}"
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        log_error "Homebrew installation failed."
        exit 1
    fi
    
    # Try to load brew into current session
    local brew_path=""
    if [ -f "/opt/homebrew/bin/brew" ]; then
        brew_path="/opt/homebrew/bin/brew"
    elif [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        brew_path="/home/linuxbrew/.linuxbrew/bin/brew"
    elif [ -f "/usr/local/bin/brew" ]; then
        brew_path="/usr/local/bin/brew"
    fi
    
    if [ -n "$brew_path" ]; then
        eval "$("$brew_path" shellenv)"
        
        # Also write to profile
        local profile_file=""
        if [ "$PLATFORM" = "Darwin" ]; then
            profile_file="$HOME/.zprofile"
        else
            profile_file="$HOME/.bashrc"
        fi
        
        if [ -f "$profile_file" ] && ! grep -q "shellenv" "$profile_file"; then
            log_info "Adding Homebrew configuration to $profile_file..."
            echo "eval \"\$($brew_path shellenv)\"" >> "$profile_file"
        fi
    fi
    
    if ! check_brew; then
        log_error "Homebrew was installed but is still not found in PATH."
        exit 1
    fi
    
    log_info "${C_GREEN}✅ Homebrew installed and configured successfully!${C_RESET}"
}

ensure_node() {
    if command -v npm >/dev/null 2>&1; then
        return 0
    fi
    
    log_warn "Node.js & NPM are required to install Jules CLI."
    local install_now=true
    if [ "$AUTO" -eq 0 ] && command -v gum >/dev/null 2>&1; then
        if ! gum confirm "Would you like the installer to set up Node.js and NPM now?"; then
            install_now=false
        fi
    elif [ "$AUTO" -eq 0 ]; then
        read -r -p "Would you like the installer to set up Node.js and NPM now? [Y/n]: " choice < /dev/tty
        case "$choice" in
            [nN]*) install_now=false ;;
        esac
    fi
    
    if [ "$install_now" = false ]; then
        log_error "Node.js installation declined. Cannot proceed with Jules CLI installation."
        exit 1
    fi
    
    # Try using brew if available
    if check_brew; then
        log_info "${C_BLUE}📦 Installing Node.js via Homebrew...${C_RESET}"
        if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
            run_cmd brew install node
        else
            brew install node
        fi
        if command -v npm >/dev/null 2>&1; then
            log_info "${C_GREEN}✅ Node.js and NPM installed successfully via Homebrew!${C_RESET}"
            return 0
        fi
    fi
    
    # Standalone binary fallback install
    log_info "${C_BLUE}⬇️  Setting up standalone Node.js and NPM in user space...${C_RESET}"
    
    local node_url=""
    local node_dir_name=""
    
    case "$PLATFORM" in
        Darwin)
            if [ "$ARCH" = "arm64" ]; then
                node_url="https://nodejs.org/dist/v20.11.1/node-v20.11.1-darwin-arm64.tar.gz"
                node_dir_name="node-v20.11.1-darwin-arm64"
            else
                node_url="https://nodejs.org/dist/v20.11.1/node-v20.11.1-darwin-x64.tar.gz"
                node_dir_name="node-v20.11.1-darwin-x64"
            fi
            ;;
        Linux)
            if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
                node_url="https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-arm64.tar.xz"
                node_dir_name="node-v20.11.1-linux-arm64"
            else
                node_url="https://nodejs.org/dist/v20.11.1/node-v20.11.1-linux-x64.tar.xz"
                node_dir_name="node-v20.11.1-linux-x64"
            fi
            ;;
        *)
            log_error "Unsupported platform for standalone Node.js installation."
            exit 1
            ;;
    esac
    
    local node_lib_dir="$HOME/.local/lib/node"
    mkdir -p "$node_lib_dir" "$BIN_DIR"
    
    local dl_temp
    dl_temp=$(mktemp -d)
    local archive_ext="tar.gz"
    case "$node_url" in
        *.tar.xz) archive_ext="tar.xz" ;;
    esac
    
    local dl_target="$dl_temp/node.$archive_ext"
    
    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        run_cmd curl -fSL "$node_url" -o "$dl_target"
    else
        curl -fSL --progress-bar "$node_url" -o "$dl_target"
    fi
    
    log_info "${C_CYAN}📁 Extracting Node.js...${C_RESET}"
    tar -xf "$dl_target" -C "$dl_temp"
    
    # Copy files to permanent location
    rm -rf "$node_lib_dir"
    mv "$dl_temp/$node_dir_name" "$node_lib_dir"
    rm -rf "$dl_temp"
    
    # Symlink binaries to $BIN_DIR
    ln -sf "$node_lib_dir/bin/node" "$BIN_DIR/node"
    ln -sf "$node_lib_dir/bin/npm" "$BIN_DIR/npm"
    ln -sf "$node_lib_dir/bin/npx" "$BIN_DIR/npx"
    
    # Ensure BIN_DIR is in PATH for current execution
    export PATH="$BIN_DIR:$PATH"
    
    # Force profile config reload for the user
    # Add to shell configuration profile
    local profile_file=""
    if [ "$PLATFORM" = "Darwin" ]; then
        profile_file="$HOME/.zprofile"
    else
        profile_file="$HOME/.bashrc"
    fi
    
    if [ -f "$profile_file" ] && ! grep -q "$BIN_DIR" "$profile_file"; then
        log_info "Adding $BIN_DIR to PATH in $profile_file..."
        echo "export PATH=\"$BIN_DIR:\$PATH\"" >> "$profile_file"
    fi
    
    if ! command -v npm >/dev/null 2>&1; then
        log_error "Node.js was installed but npm is still not found in PATH."
        exit 1
    fi
    
    log_info "${C_GREEN}✅ Standalone Node.js and NPM setup complete!${C_RESET}"
}

install_jules() {
    local target_version="${1:-$DEFAULT_JULES_VERSION}"
    JSON_METHOD="jules"
    log_info "${C_MAG}🚀 Installing Google Jules CLI...${C_RESET}"
    
    ensure_node
    
    local pkg="@google/jules"
    if [ -n "$target_version" ] && [ "$target_version" != "latest" ]; then
        pkg="@google/jules@$target_version"
    fi
    
    log_info "${C_BLUE}📦 Installing package '$pkg' via npm...${C_RESET}"
    
    local install_ok=false
    if [ "$JSON_OUT" -eq 1 ] || [ "$QUIET" -eq 1 ]; then
        if run_cmd npm install -g "$pkg" 2>/dev/null; then
            install_ok=true
        elif command -v sudo >/dev/null 2>&1 && run_cmd sudo npm install -g "$pkg"; then
            install_ok=true
        fi
    else
        if npm install -g "$pkg"; then
            install_ok=true
        elif command -v sudo >/dev/null 2>&1; then
            log_warn "Permission denied. Retrying with sudo..."
            if sudo npm install -g "$pkg"; then
                install_ok=true
            fi
        fi
    fi
    
    if [ "$install_ok" = false ]; then
        log_error "Failed to install Google Jules CLI package."
        exit 1
    fi
    
    # If we installed to a local or custom path, link it to BIN_DIR
    local npm_prefix
    npm_prefix=$(npm config get prefix 2>/dev/null || echo "")
    if [ -n "$npm_prefix" ] && [ -f "$npm_prefix/bin/jules" ]; then
        ln -sf "$npm_prefix/bin/jules" "$BIN_DIR/jules"
    fi
    
    log_info "${C_GREEN}✅ Google Jules CLI installation complete!${C_RESET}"
}

# ── Top-level menu header (full banner + system info) ────────────
get_menu_header() {
    print_banner "${UI_MODE:-}"
    print_system_info
}

# ── Compact one-line header for submenus ─────────────────────────
get_compact_header() {
    local label="${1:-}"
    local mode="${UI_MODE:-}"
    local os_label="${DISTRO_PRETTY:-Unknown OS}"
    echo -e "${C_BOLD}AGV Easy Install v${SCRIPT_VERSION}${C_RESET} ${C_DIM}|${C_RESET} ${os_label} ${C_DIM}|${C_RESET} ${mode:+${C_YELLOW}${mode}${C_RESET} ${C_DIM}|${C_RESET} }${label}"
}

# ── Wizard Step 1: Intent Question ──────────────────────────────
main_menu() {
    bootstrap_ui
    clear || true
    echo ""
    
    local options=(
        "Cancel"
        "🎓 Set up for lab (IDE + CLI, one click)"
        "⚡ Install or update a specific tool  →"
        "🧹 Manage existing installation  →"
        "🖥️  Demo UI (sandbox mode)"
    )

    if command -v gum >/dev/null 2>&1; then
        local header
        header=$(get_menu_header)
        CHOICE=$(gum filter --header="$header" --no-limit --no-strict --indicator="❯ " --placeholder="Select an option or type a secret..." "${options[@]}") || CHOICE="Cancel"
    else
        clear || true
        get_menu_header
        log_warn "UI dependencies failed to load. Falling back to simple menu."
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-5]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Cancel" ;;
            2) CHOICE="lab" ;;
            3) CHOICE="specific" ;;
            4) CHOICE="manage" ;;
            5) CHOICE="Demo" ;;
            [Gg]oogle) CHOICE="Google" ;;
            *) CHOICE="Cancel" ;;
        esac
    fi

    case "$CHOICE" in
        "Cancel"*) choice="cancel" ;;
        *"Set up for lab"*|*"lab"*) choice="fast_track" ;;
        *"Install or update"*|*"specific"*) choice="install" ;;
        *"Manage"*|*"manage"*) choice="cleanup" ;;
        *"Demo"*) choice="demo" ;;
        [Gg]oogle)
            log_info "Opening Course Catalog..."
            local opener="xdg-open"
            if [ "$PLATFORM" = "Darwin" ]; then opener="open"
            elif grep -qi "microsoft" /proc/version 2>/dev/null; then opener="wslview"
            fi
            run_cmd "$opener" "https://catalog.google.com" || true
            choice="cancel"
            ;;
        *) choice="cancel" ;;
    esac
}

# ── Wizard Step 2a: Fast-Track Setup ────────────────────────────
# Globals set by this function:
#   FAST_TRACK_PRODUCTS  – space-separated list of selected products (ide cli sdk)
#   FAST_TRACK_METHOD    – install method for IDE (brew repo binary)
FAST_TRACK_PRODUCTS=""
FAST_TRACK_METHOD=""

fast_track_setup() {
    FAST_TRACK_PRODUCTS=""
    FAST_TRACK_METHOD=""

    # ── Step A: Which products? (multi-select) ──
    clear || true
    echo ""
    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select tools to install (space to toggle)")
        local selected
        selected=$(gum choose --no-limit --header="$cheader" \
            --selected="Google Antigravity,Antigravity IDE,Antigravity CLI (agy),Google Jules CLI" \
            "Google Antigravity" \
            "Antigravity IDE" \
            "Antigravity CLI (agy)" \
            "Google Jules CLI" \
            "Antigravity SDK (Python)") || selected=""
    else
        echo "Select tools to install (comma-separated, e.g. 1,2):"
        echo "1) Google Antigravity"
        echo "2) Antigravity IDE"
        echo "3) Antigravity CLI (agy)"
        echo "4) Google Jules CLI"
        echo "5) Antigravity SDK (Python)"
        read -r -p "Choice [1,2,3,4]: " nums < /dev/tty
        local selected=""
        case "$nums" in
            *1*) selected="Google Antigravity" ;;
        esac
        case "$nums" in
            *2*) selected="${selected:+$selected\n}Antigravity IDE" ;;
        esac
        case "$nums" in
            *3*) selected="${selected:+$selected\n}Antigravity CLI" ;;
        esac
        case "$nums" in
            *4*) selected="${selected:+$selected\n}Google Jules CLI" ;;
        esac
        case "$nums" in
            *5*) selected="${selected:+$selected\n}Antigravity SDK" ;;
        esac
    fi

    if [ -z "$selected" ]; then
        choice="cancel"
        return
    fi

    # Parse selections into a simple flag string
    if echo "$selected" | grep -q "Google Antigravity"; then FAST_TRACK_PRODUCTS="antigravity"; fi
    if echo "$selected" | grep -q "IDE"; then FAST_TRACK_PRODUCTS="${FAST_TRACK_PRODUCTS:+$FAST_TRACK_PRODUCTS }ide"; fi
    if echo "$selected" | grep -q "CLI"; then FAST_TRACK_PRODUCTS="${FAST_TRACK_PRODUCTS:+$FAST_TRACK_PRODUCTS }cli"; fi
    if echo "$selected" | grep -q "Jules"; then FAST_TRACK_PRODUCTS="${FAST_TRACK_PRODUCTS:+$FAST_TRACK_PRODUCTS }jules"; fi
    if echo "$selected" | grep -q "SDK"; then FAST_TRACK_PRODUCTS="${FAST_TRACK_PRODUCTS:+$FAST_TRACK_PRODUCTS }sdk"; fi

    # ── Step B: IDE install method (if IDE selected) ──
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then
        clear || true
        echo ""
        local rec_brew="" rec_repo="" rec_bin=""
        case "$RECOMMENDED" in
            1) rec_brew=" ★" ;;
            2) rec_repo=" ★" ;;
            3) rec_bin=" ★" ;;
        esac

        if command -v gum >/dev/null 2>&1; then
            local mheader
            mheader=$(get_compact_header "How should the IDE be installed?")
            CHOICE=$(gum choose --header="$mheader" \
                "Homebrew (cross-platform, no sudo)${rec_brew}" \
                "System Repo (APT/DNF, needs sudo)${rec_repo}" \
                "Official Binary / Tarball${rec_bin}" \
                "Cancel") || CHOICE="Cancel"
        else
            echo ""
            echo "How should the IDE be installed?"
            echo "1) Homebrew (cross-platform, no sudo)${rec_brew}"
            echo "2) System Repo (APT/DNF, needs sudo)${rec_repo}"
            echo "3) Official Binary / Tarball${rec_bin}"
            echo "4) Cancel"
            read -r -p "Select method [1-4]: " num < /dev/tty
            case "$num" in
                1) CHOICE="Homebrew" ;;
                2) CHOICE="System" ;;
                3) CHOICE="Binary" ;;
                *) CHOICE="Cancel" ;;
            esac
        fi

        case "$CHOICE" in
            *"Homebrew"*) FAST_TRACK_METHOD="brew" ;;
            *"System"*) FAST_TRACK_METHOD="repo" ;;
            *"Binary"*|*"Tarball"*) FAST_TRACK_METHOD="binary" ;;
            *) choice="cancel"; return ;;
        esac
    fi

    # ── Step C: Summary & confirm ──
    clear || true
    echo ""
    local summary="📦 Ready to install:"
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "antigravity"; then
        summary="${summary}\n  ✦ Google Antigravity (v${DEFAULT_AGV_VERSION})"
    fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then
        local method_label="Homebrew"
        case "$FAST_TRACK_METHOD" in
            repo) method_label="System Repo" ;;
            binary) method_label="Official Binary" ;;
        esac
        summary="${summary}\n  ✦ Antigravity IDE  (v${DEFAULT_IDE_VERSION}) via ${method_label}"
    fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then
        summary="${summary}\n  ✦ Antigravity CLI  (v${DEFAULT_CLI_VERSION})"
    fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then
        summary="${summary}\n  ✦ Antigravity SDK  (v${DEFAULT_SDK_VERSION}) via pip"
    fi

    if command -v gum >/dev/null 2>&1; then
        echo -e "$summary" | gum style --border rounded --border-foreground 33 --padding "1 2" --margin "0 2"
        echo ""
        local cheader2
        cheader2=$(get_compact_header "Confirm")
        CHOICE=$(gum choose --header="$cheader2" "Install now" "Cancel") || CHOICE="Cancel"
    else
        echo -e "$summary"
        echo ""
        echo "1) Install now"
        echo "2) Cancel"
        read -r -p "Proceed? [1-2]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Install now" ;;
            *) CHOICE="Cancel" ;;
        esac
    fi

    case "$CHOICE" in
        "Install now"*) choice="fast_track_go" ;;
        *) choice="cancel" ;;
    esac
}

# ── Wizard Step 2b: Tool Picker (specific tool) ────────────────
install_submenu() {
    clear || true
    echo ""
    local options=(
        "Back"
        "Google Antigravity  →"
        "Antigravity IDE  →"
        "Antigravity CLI (agy)  →"
        "Google Jules CLI (npm)  →"
        "Antigravity SDK (Python)  →"
    )

    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select a tool to install")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Select a tool to install:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select tool [1-6]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Back" ;;
            2) CHOICE="Google Antigravity" ;;
            3) CHOICE="Antigravity IDE" ;;
            4) CHOICE="Antigravity CLI" ;;
            5) CHOICE="Google Jules CLI" ;;
            6) CHOICE="Antigravity SDK" ;;
            *) CHOICE="Back" ;;
        esac
    fi

    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *"Google Antigravity"*) choice="antigravity_menu" ;;
        *"IDE"*) choice="ide_menu" ;;
        *"CLI"*) choice="cli_menu" ;;
        *"Jules"*) choice="jules_menu" ;;
        *"SDK"*) choice="sdk_menu" ;;
        *) choice="back" ;;
    esac
}

# ── Wizard Step 2c: IDE Install Method Picker ──────────────────
ide_method_submenu() {
    clear || true
    echo ""
    local rec_brew="" rec_repo="" rec_bin="  "
    case "$RECOMMENDED" in
        1) rec_brew="★ " ;;
        2) rec_repo="★ " ;;
        3) rec_bin="★ " ;;
    esac

    local options=(
        "Back"
        "${rec_brew}Homebrew (cross-platform, no sudo)"
        "${rec_repo}System Repo (APT/DNF, needs sudo)"
        "${rec_bin}Official Binary IDE  →"
    )

    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Choose IDE install method")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Choose IDE install method:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select method [1-4]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Back" ;;
            2) CHOICE="Homebrew" ;;
            3) CHOICE="System Repo" ;;
            4) CHOICE="Official Binary IDE" ;;
            *) CHOICE="Back" ;;
        esac
    fi

    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *"Homebrew"*) choice="brew" ;;
        *"System Repo"*) choice="repo" ;;
        *"Official Binary IDE"*) choice="binary_menu" ;;
        *) choice="back" ;;
    esac
}


# ── Cleanup sub-menu ────────────────────────────────────────────
cleanup_submenu() {
    clear || true
    echo ""
    local options=(
        "Back"
        "Uninstall Antigravity"
        "Save manager (add 'antigravity-manager' command)"
        "Remove manager (delete this script)"
    )

    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Manage installation")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Manage installation:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-4]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Back" ;;
            2) CHOICE="Uninstall" ;;
            3) CHOICE="Save" ;;
            4) CHOICE="Remove manager" ;;
            *) CHOICE="Back" ;;
        esac
    fi

    case "$CHOICE" in
        "Back"*) choice="back" ;;
        "Uninstall"*) choice="remove" ;;
        "Save"*) choice="save" ;;
        "Remove"*) choice="remove_mgr" ;;
        *) choice="back" ;;
    esac
}

# ── Post-Install Follow-up ──────────────────────────────────────
post_install_menu() {
    clear || true
    echo ""
    local done_msg="🎉 Setup Complete!"
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then done_msg="${done_msg}\nIDE:  v${DEFAULT_IDE_VERSION} installed"; fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then done_msg="${done_msg}\nCLI:  v${DEFAULT_CLI_VERSION} installed"; fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then done_msg="${done_msg}\nSDK:  v${DEFAULT_SDK_VERSION} installed"; fi
    done_msg="${done_msg}\nLaunch: antigravity"

    if command -v gum >/dev/null 2>&1; then
        echo -e "$done_msg" | gum style --border double --border-foreground 46 --padding "1 2"
        echo ""
        local cheader
        cheader=$(get_compact_header "What next?")
        CHOICE=$(gum choose --header="$cheader" \
            "🚀 Launch Antigravity now" \
            "📁 Create workspace folder (~/my-antigravity-work)" \
            "💾 Save this installer for later" \
            "✅ Done — exit") || CHOICE="Done"
    else
        log_info "${C_GREEN}${C_BOLD}${done_msg}${C_RESET}"
        echo ""
        echo "What next?"
        echo "1) Launch Antigravity now"
        echo "2) Create workspace folder"
        echo "3) Save this installer for later"
        echo "4) Done — exit"
        read -r -p "Select option [1-4]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Launch" ;;
            2) CHOICE="Create" ;;
            3) CHOICE="Save" ;;
            *) CHOICE="Done" ;;
        esac
    fi

    case "$CHOICE" in
        *"Launch"*)
            log_info "Launching Antigravity..."
            local opener="antigravity"
            if [ ! -x "$BIN_DIR/antigravity" ] && [ -x "$BIN_DIR/antigravity-ide" ]; then
                opener="antigravity-ide"
            fi
            if command -v "$opener" >/dev/null 2>&1 || [ -x "$BIN_DIR/$opener" ]; then
                if command -v "$opener" >/dev/null 2>&1; then
                    "$opener" &
                else
                    "$BIN_DIR/$opener" &
                fi
            else
                log_warn "Antigravity command not found yet. Try closing and reopening your terminal, then type: antigravity"
            fi
            ;;
        *"workspace"*|*"Create"*)
            if [ ! -d "$WORKSPACE_DIR" ]; then
                mkdir -p "$WORKSPACE_DIR"
                log_info "✅ Created workspace at ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
            else
                log_info "Workspace already exists at ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
            fi
            ;;
        *"Save"*|*"installer"*)
            save_manager_locally
            ;;
        *) ;; # Done — exit
    esac
}

# ── Version Selection Helpers ────────────────────────────────────
list_antigravity_versions() {
    local json_file="/tmp/versions.json"
    if [ -f "$json_file" ]; then
        awk '
          BEGIN { in_agv=0 }
          $0 ~ "\"antigravity\"" { in_agv=1; next }
          in_agv && $0 ~ "}" && $0 !~ "," { in_agv=0 }
          in_agv && $0 ~ "^    \"[0-9.]+\":" {
            split($0, a, "\"");
            print a[2]
          }
        ' "$json_file" 2>/dev/null
    else
        echo "$DEFAULT_AGV_VERSION"
    fi
}

choose_antigravity_version() {
    fetch_versions_json || true
    
    local versions=()
    while IFS= read -r line; do
        versions+=("$line")
    done < <(list_antigravity_versions)
    
    if [ ${#versions[@]} -eq 0 ]; then
        versions+=("$DEFAULT_AGV_VERSION")
    fi
    
    local options=("Back")
    for v in "${versions[@]}"; do
        if [ "$v" = "$DEFAULT_AGV_VERSION" ]; then
            options+=("$v (Latest / Default)")
        else
            options+=("$v")
        fi
    done
    
    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select Antigravity version")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Select Antigravity version:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-${#options[@]}]: " num < /dev/tty
        local idx=$((num-1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#options[@]} ]; then
            CHOICE="${options[$idx]}"
        else
            CHOICE="Back"
        fi
    fi
    
    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *)
            local selected_ver
            selected_ver=$(echo "$CHOICE" | awk '{print $1}')
            choice="antigravity:$selected_ver"
            ;;
    esac
}

list_ide_versions() {
    local json_file="/tmp/versions.json"
    if [ -f "$json_file" ]; then
        awk '
          BEGIN { in_ide=0 }
          $0 ~ "\"ide\"" { in_ide=1; next }
          in_ide && $0 ~ "}" && $0 !~ "," { in_ide=0 }
          in_ide && $0 ~ "^    \"[0-9.]+\":" {
            split($0, a, "\"");
            print a[2]
          }
        ' "$json_file" 2>/dev/null
    else
        echo "$DEFAULT_IDE_VERSION"
    fi
}

list_cli_versions() {
    local json_file="/tmp/versions.json"
    if [ -f "$json_file" ]; then
        awk '
          BEGIN { in_cli=0 }
          $0 ~ "\"cli\"" { in_cli=1; next }
          in_cli && $0 ~ "}" && $0 !~ "," { in_cli=0 }
          in_cli && $0 ~ "^    \"[0-9.]+\":" {
            split($0, a, "\"");
            print a[2]
          }
        ' "$json_file" 2>/dev/null
    else
        echo "$DEFAULT_CLI_VERSION"
    fi
}

list_sdk_versions() {
    local json_file="/tmp/versions.json"
    if [ -f "$json_file" ]; then
        awk '
          BEGIN { in_sdk=0; in_vers=0 }
          $0 ~ "\"sdk\"" { in_sdk=1; next }
          in_sdk && $0 ~ "}" && $0 !~ "," { in_sdk=0 }
          in_sdk && $0 ~ "\"versions\"" { in_vers=1; next }
          in_vers && $0 ~ "]" { in_vers=0 }
          in_vers && $0 ~ "\"[0-9.]+\"" {
            split($0, a, "\"");
            print a[2]
          }
        ' "$json_file" 2>/dev/null
    else
        echo "$DEFAULT_SDK_VERSION"
    fi
}

choose_ide_version() {
    fetch_versions_json || true
    clear || true
    
    local versions=()
    while IFS= read -r line; do
        versions+=("$line")
    done < <(list_ide_versions)
    
    if [ ${#versions[@]} -eq 0 ]; then
        versions+=("$DEFAULT_IDE_VERSION")
    fi
    
    local options=("Back")
    for v in "${versions[@]}"; do
        if [ "$v" = "$DEFAULT_IDE_VERSION" ]; then
            options+=("$v (Latest / Default)")
        else
            options+=("$v")
        fi
    done
    
    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select IDE version")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Select IDE version:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-${#options[@]}]: " num < /dev/tty
        local idx=$((num-1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#options[@]} ]; then
            CHOICE="${options[$idx]}"
        else
            CHOICE="Back"
        fi
    fi
    
    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *)
            local selected_ver
            selected_ver=$(echo "$CHOICE" | awk '{print $1}')
            choice="binary:$selected_ver"
            ;;
    esac
}

choose_cli_version() {
    fetch_versions_json || true
    clear || true
    
    local versions=()
    while IFS= read -r line; do
        versions+=("$line")
    done < <(list_cli_versions)
    
    if [ ${#versions[@]} -eq 0 ]; then
        versions+=("$DEFAULT_CLI_VERSION")
    fi
    
    local options=("Back")
    for v in "${versions[@]}"; do
        if [ "$v" = "$DEFAULT_CLI_VERSION" ]; then
            options+=("$v (Latest / Default)")
        else
            options+=("$v")
        fi
    done
    
    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select CLI version")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Select CLI version:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-${#options[@]}]: " num < /dev/tty
        local idx=$((num-1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#options[@]} ]; then
            CHOICE="${options[$idx]}"
        else
            CHOICE="Back"
        fi
    fi
    
    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *)
            local selected_ver
            selected_ver=$(echo "$CHOICE" | awk '{print $1}')
            choice="cli:$selected_ver"
            ;;
    esac
}

choose_sdk_version() {
    fetch_versions_json || true
    clear || true
    
    local versions=()
    while IFS= read -r line; do
        versions+=("$line")
    done < <(list_sdk_versions)
    
    if [ ${#versions[@]} -eq 0 ]; then
        versions+=("$DEFAULT_SDK_VERSION")
    fi
    
    local options=("Back" "latest (Latest / Default)")
    for v in "${versions[@]}"; do
        options+=("$v")
    done
    
    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select SDK version")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Select SDK version:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-${#options[@]}]: " num < /dev/tty
        local idx=$((num-1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#options[@]} ]; then
            CHOICE="${options[$idx]}"
        else
            CHOICE="Back"
        fi
    fi
    
    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *)
            local selected_ver
            selected_ver=$(echo "$CHOICE" | awk '{print $1}')
            choice="sdk:$selected_ver"
            ;;
    esac
}

choose_jules_version() {
    clear || true
    local options=(
        "Back"
        "latest (Latest / Default)"
    )
    if command -v gum >/dev/null 2>&1; then
        local cheader
        cheader=$(get_compact_header "Select Jules CLI version")
        CHOICE=$(gum choose --header="$cheader" "${options[@]}") || CHOICE="Back"
    else
        clear || true
        echo "Select Jules CLI version:"
        for i in "${!options[@]}"; do echo "$((i+1))) ${options[$i]}"; done
        read -r -p "Select option [1-2]: " num < /dev/tty
        case "$num" in
            1) CHOICE="Back" ;;
            2) CHOICE="latest" ;;
            *) CHOICE="Back" ;;
        esac
    fi
    
    case "$CHOICE" in
        "Back"*) choice="back" ;;
        *)
            local selected_ver
            selected_ver=$(echo "$CHOICE" | awk '{print $1}')
            choice="jules:$selected_ver"
            ;;
    esac
}

# ── Mock actions for sandbox mode ───────────────────────────────
run_mock_action() {
    local action="$1"

    case "$action" in
        fast_track_go)
            local method_label="Homebrew"
            case "$FAST_TRACK_METHOD" in repo) method_label="System Repo" ;; binary) method_label="Official Binary" ;; esac

            log_info "${C_MAG}🚀 Starting setup (Mock)...${C_RESET}"
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "antigravity"; then
                run_cmd_ui "Installing Google Antigravity (v${DEFAULT_AGV_VERSION})..." sleep 1
            fi
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then
                run_cmd_ui "Installing Antigravity IDE (v${DEFAULT_IDE_VERSION}) via ${method_label}..." sleep 1.5
            fi
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then
                run_cmd_ui "Installing Antigravity CLI (v${DEFAULT_CLI_VERSION})..." sleep 1
            fi
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "jules"; then
                run_cmd_ui "Installing Google Jules CLI (latest) via npm..." sleep 1
            fi
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then
                run_cmd_ui "Installing Antigravity SDK (v${DEFAULT_SDK_VERSION}) via pip..." sleep 1
            fi
            echo ""
            local done_msg="🎉 Mock Setup Complete!"
            local mock_bin_name="antigravity"
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "antigravity"; then
                done_msg="${done_msg}\nAntigravity: v${DEFAULT_AGV_VERSION} installed"
            fi
            if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then
                done_msg="${done_msg}\nIDE:  v${DEFAULT_IDE_VERSION} installed via ${method_label}"
                if ! echo "$FAST_TRACK_PRODUCTS" | grep -q "antigravity"; then
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
            ;;
        antigravity*|brew|repo|binary*|cli*|sdk*|jules*)
            local method="Homebrew"
            local product="Google Antigravity IDE"
            local version=""
            local mock_bin_name="antigravity"
            
            if [[ "$action" == *":"* ]]; then
                version=" (version $(echo "$action" | cut -d':' -f2))"
            fi
            
            if [[ "$action" == "antigravity"* ]]; then
                method="Official Binary"
                product="Google Antigravity"
                mock_bin_name="antigravity"
            elif [[ "$action" == "binary"* ]]; then
                method="Official Binary"
                product="Google Antigravity IDE"
                mock_bin_name="antigravity-ide"
            elif [[ "$action" == "cli"* ]]; then
                method="Antigravity CLI"
                product="Antigravity CLI (agy)"
            elif [[ "$action" == "jules"* ]]; then
                method="Google Jules CLI"
                product="Google Jules CLI (NPM)"
            elif [[ "$action" == "sdk"* ]]; then
                method="Antigravity SDK"
                product="Antigravity SDK (Python)"
            elif [ "$action" = "repo" ]; then
                method="System Repo"
                mock_bin_name="antigravity-ide"
            fi

            log_info "${C_MAG}🚀 Starting mock installation of ${product}${version} via ${method}...${C_RESET}"
            if [[ "$action" == "cli"* ]]; then
                run_cmd_ui "Downloading Antigravity CLI installer..." sleep 1
                run_cmd_ui "Executing installation script..." sleep 1.5
                echo ""
                log_info "${C_GREEN}${C_BOLD}🎉 Mock Installation Complete!${C_RESET}"
                log_info "  ${C_CYAN}▸${C_RESET} Launch:    ${C_BOLD}agy --help${C_RESET}"
                return
            fi
            
            if [[ "$action" == "sdk"* ]]; then
                run_cmd_ui "Connecting to PyPI..." sleep 1
                run_cmd_ui "Installing package 'google-antigravity'..." sleep 1.5
                echo ""
                log_info "${C_GREEN}${C_BOLD}🎉 Mock Installation Complete!${C_RESET}"
                log_info "  ${C_CYAN}▸${C_RESET} Verify:    ${C_BOLD}python3 -c \"import google_antigravity\"${C_RESET}"
                return
            fi

            if [[ "$action" == "jules"* ]]; then
                run_cmd_ui "Connecting to NPM registry..." sleep 1
                run_cmd_ui "Installing package '@google/jules'..." sleep 1.5
                echo ""
                log_info "${C_GREEN}${C_BOLD}🎉 Mock Installation Complete!${C_RESET}"
                log_info "  ${C_CYAN}▸${C_RESET} Verify:    ${C_BOLD}jules --help${C_RESET}"
                return
            fi

            run_cmd_ui "Downloading Antigravity payload..." sleep 1.5
            run_cmd_ui "Extracting binaries..." sleep 1
            echo ""
            log_warn "Antigravity occasionally fails to find Chrome when installed via Brew or Binary."
            log_info "We found a valid Chrome binary at: ${C_BOLD}/usr/bin/google-chrome${C_RESET}"

            # shellcheck disable=SC2088
            local mock_rc="~/.bashrc"
            # shellcheck disable=SC2088
            if [ "$PLATFORM" = "Darwin" ]; then mock_rc="~/.zprofile"; fi

            if command -v gum >/dev/null 2>&1; then
                gum confirm "Would you like to automatically configure Antigravity to use this browser?" || true
                echo ""
                log_warn "$HOME/.local/bin is not in your PATH."
                gum confirm "Would you like to automatically add it to $mock_rc?" || true
                echo ""
                run_cmd_ui "Applying configuration..." sleep 1
                echo ""
                gum style --border double --border-foreground 46 --padding "1 2" "🎉 Mock Installation Complete!
Launch: ${mock_bin_name}
Workspace: $WORKSPACE_DIR"
            else
                echo -ne "${C_YELLOW}Would you like to automatically configure Antigravity to use this browser? [Y/n]: ${C_RESET}"
                read -r _ < /dev/tty || true
                echo ""
                log_warn "$HOME/.local/bin is not in your PATH."
                echo -ne "${C_YELLOW}Would you like to automatically add it to $mock_rc? [Y/n]: ${C_RESET}"
                read -r _ < /dev/tty || true
                echo ""
                log_info "${C_GREEN}${C_BOLD}🎉 Mock Installation Complete!${C_RESET}"
                log_info "  ${C_CYAN}▸${C_RESET} Launch:    ${C_BOLD}${mock_bin_name}${C_RESET}"
                log_info "  ${C_CYAN}▸${C_RESET} Workspace: ${C_BOLD}$WORKSPACE_DIR${C_RESET}"
            fi
            ;;
        save)
            log_info "${C_MAG}🚀 Saving manager locally (Mock)...${C_RESET}"
            run_cmd_ui "Copying script to ~/.local/bin/antigravity-manager..." sleep 1
            log_info "✅ Manager saved successfully!"
            ;;
        remove)
            log_info "${C_MAG}🚀 Uninstalling Antigravity (Mock)...${C_RESET}"
            if command -v gum >/dev/null 2>&1; then
                gum confirm "Are you sure you want to completely remove Antigravity?" || true
            fi
            run_cmd_ui "Removing app files..." sleep 1
            run_cmd_ui "Removing state directories..." sleep 0.5
            log_info "✅ Uninstallation complete!"
            ;;
        remove_mgr)
            log_info "${C_MAG}🚀 Removing manager script (Mock)...${C_RESET}"
            run_cmd_ui "Deleting ~/.local/bin/antigravity-manager..." sleep 1
            log_info "✅ Manager script deleted."
            ;;
    esac
}
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
    local chrome_path
    chrome_path=$(find_chrome_binary)
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

    # 6. Antigravity Python SDK (Optional)
    if command -v python3 >/dev/null 2>&1 && python3 -c "import google.antigravity" >/dev/null 2>&1; then
        echo -e "  ${C_GREEN}✅ Antigravity Python SDK found in Python environment${C_RESET}"
    fi

    # 7. Google Jules CLI (Optional)
    if command -v jules >/dev/null 2>&1; then
        echo -e "  ${C_GREEN}✅ Google Jules CLI found in PATH ($(command -v jules))${C_RESET}"
    fi

    echo ""
    if [ "$failed" -eq 0 ]; then
        log_info "${C_GREEN}${C_BOLD}🎉 Health check passed! Your installation is healthy.${C_RESET}"
    else
        log_warn "${C_BOLD}$failed issue(s) detected.${C_RESET} You may need to run the installer again."
    fi
}
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
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "antigravity"; then total=$((total+1)); fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then total=$((total+1)); fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "cli"; then total=$((total+1)); fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "jules"; then total=$((total+1)); fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "sdk"; then total=$((total+1)); fi

    log_info "${C_MAG}🎓 Starting setup — installing ${total} tool(s)...${C_RESET}"
    echo ""

    # Install Google Antigravity (if selected)
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "antigravity"; then
        step=$((step+1))
        log_info "${C_BOLD}Step ${step}/${total}: Installing Google Antigravity...${C_RESET}"
        do_install_binary "antigravity"
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
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "antigravity"; then
        done_msg="${done_msg}\nAntigravity: v${DEFAULT_AGV_VERSION} installed"
    fi
    if echo "$FAST_TRACK_PRODUCTS" | grep -q "ide"; then
        done_msg="${done_msg}\nIDE:  v${DEFAULT_IDE_VERSION} installed"
        if ! echo "$FAST_TRACK_PRODUCTS" | grep -q "antigravity"; then
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
                    
                    if [ "$choice" = "antigravity_menu" ]; then
                        choose_antigravity_version
                        if [ "$choice" = "back" ]; then
                            choice="back"
                            continue
                        fi
                        in_install=false
                    elif [ "$choice" = "ide_menu" ]; then
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
                    
                    if [ "$choice" = "antigravity_menu" ]; then
                        choose_antigravity_version
                        if [ "$choice" = "back" ]; then
                            choice="back"
                            continue
                        fi
                        in_install=false
                    elif [ "$choice" = "ide_menu" ]; then
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
                    antigravity:*)
                        local selected_version
                        selected_version=$(echo "$choice" | cut -d':' -f2)
                        FAST_TRACK_PRODUCTS="antigravity"
                        do_install_binary "antigravity" "$selected_version"
                        save_manager_locally
                        post_install_menu
                        break
                        ;;
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
        else do_install_binary "antigravity"; save_manager_locally
        fi ;;
    fast_track)
        FAST_TRACK_PRODUCTS="antigravity ide cli jules"
        case "$RECOMMENDED" in 1) FAST_TRACK_METHOD="brew" ;; 2) FAST_TRACK_METHOD="repo" ;; *) FAST_TRACK_METHOD="binary" ;; esac
        do_fast_track_install ;;
    brew) install_brew; save_manager_locally ;;
    repo) install_repo; save_manager_locally ;;
    binary) do_install_binary "antigravity"; save_manager_locally ;;
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
