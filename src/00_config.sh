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
C_DIM='\033[2m'
C_RESET='\033[0m'

# Configuration
SCRIPT_VERSION="0.2.11"
DEFAULT_IDE_VERSION="2.0.0"
DEFAULT_CLI_VERSION="1.0.0"
DEFAULT_SDK_VERSION="0.1.0"
VERSIONS_JSON_URL="https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/versions.json"

LINUX_X64_SHA256="14bc9cb480a5be8fb3b7dc3e2b0cebfa66d370ad58cc1e0fa01140d1204d4297"
LINUX_X64_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/linux-x64/Antigravity.tar.gz"

MAC_X64_SHA256="7416561b81866656453d51810ff64c19bfdc41b5fabca2ca253e9f835e7b20a6"
MAC_X64_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/darwin-x64/Antigravity.dmg"

MAC_ARM64_SHA256="f96c360be0dc419186f987276b0aa1f8c22def1b76eec0892537c193e6bf4fdd"
MAC_ARM64_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/darwin-arm/Antigravity.dmg"

WIN_X64_SHA256="06e1b95dca9bf14fcbfc72ace0c11b42123c0cb65f35ee3c979b63bab3b56a6a"
WIN_X64_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/windows-x64/Antigravity.exe"

WIN_ARM64_SHA256="5b8f70548455c61fbc7ddf137b4d74c189444167085fdd6ef29b8cd2feb57b18"
WIN_ARM64_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/windows-arm/Antigravity.exe"
MANAGER_URL="https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/antigravity-manager.sh"
CLI_INSTALL_URL="https://antigravity.google/cli/install.sh"

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

