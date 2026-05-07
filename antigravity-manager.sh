#!/usr/bin/env bash
set -e

# Default to --install if run without arguments
COMMAND=${1:---install}

DOWNLOAD_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/linux-x64/Antigravity.tar.gz"
SCRIPT_URL="https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/antigravity-manager.sh"

# Directories
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/lib/antigravity"
WORKSPACE_DIR="$HOME/my-antigravity-work"

# Safely locate the Desktop directory
DESKTOP_DIR=$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")
APPLICATIONS_DIR="$HOME/.local/share/applications"

# Files
DESKTOP_FILE_SYS="$APPLICATIONS_DIR/google-antigravity.desktop"
DESKTOP_FILE_USER="$DESKTOP_DIR/google-antigravity.desktop"

print_usage() {
    echo "Usage: antigravity-manager [OPTION]"
    echo "Options:"
    echo "  --install   Installs Antigravity, sets up workspace, and creates desktop shortcuts. (Default)"
    echo "  --remove    Uninstalls Antigravity and removes shortcuts."
}

do_remove() {
    echo "🧹 Removing Google Antigravity..."
    rm -rf "$APP_DIR"
    rm -f "$BIN_DIR/antigravity"
    rm -f "$BIN_DIR/antigravity-manager"
    rm -f "$DESKTOP_FILE_SYS"
    rm -f "$DESKTOP_FILE_USER"
    echo "✅ Uninstalled successfully. (Note: Your code in $WORKSPACE_DIR was kept safe)."
}

do_install() {
    echo "🚀 Starting Google Antigravity Installation..."

    echo "📁 Preparing directories..."
    mkdir -p "$BIN_DIR" "$APP_DIR" "$WORKSPACE_DIR" "$DESKTOP_DIR" "$APPLICATIONS_DIR"

    TMP_DIR=$(mktemp -d)

    echo "⬇️ Downloading Antigravity..."
    curl -sL "$DOWNLOAD_URL" -o "$TMP_DIR/Antigravity.tar.gz"

    echo "📦 Extracting archive..."
    tar -xzf "$TMP_DIR/Antigravity.tar.gz" -C "$APP_DIR" --strip-components=1

    echo "🔗 Creating symlink..."
    ln -sf "$APP_DIR/antigravity" "$BIN_DIR/antigravity"

    echo "🛠️ Installing management script..."
    if [[ "$0" == *"antigravity-manager.sh" ]]; then
        cp "$0" "$BIN_DIR/antigravity-manager"
    else
        curl -sL "$SCRIPT_URL" -o "$BIN_DIR/antigravity-manager"
    fi
    chmod +x "$BIN_DIR/antigravity-manager"

    echo "🖼️ Registering application icon..."
    # Fallback logic for icons
    ICON_PATH="code"
    if [ -f "$APP_DIR/resources/app/out/vs/workbench/contrib/antigravityCustomAppIcon/browser/media/antigravity/antigravity.png" ]; then
        ICON_PATH="$APP_DIR/resources/app/out/vs/workbench/contrib/antigravityCustomAppIcon/browser/media/antigravity/antigravity.png"
    elif [ -f "$APP_DIR/resources/app/resources/linux/code.png" ]; then
        ICON_PATH="$APP_DIR/resources/app/resources/linux/code.png"
    elif [ -f "$APP_DIR/antigravity.png" ]; then
        ICON_PATH="$APP_DIR/antigravity.png"
    fi

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
StartupNotify=true
EOF

    chmod +x "$DESKTOP_FILE_SYS"

    # Refresh app menu
    if command -v update-desktop-database &>/dev/null; then
        update-desktop-database "$APPLICATIONS_DIR" || true
    fi

    echo "🖥️ Adding shortcut to Desktop..."
    cp "$DESKTOP_FILE_SYS" "$DESKTOP_FILE_USER"
    chmod +x "$DESKTOP_FILE_USER"

    # Trust desktop icon if possible
    if command -v gio &>/dev/null; then
        echo "🛡️ Marking desktop shortcut as trusted..."
        gio set "$DESKTOP_FILE_USER" metadata::trusted true || true
    fi

    echo "🧹 Cleaning up..."
    rm -rf "$TMP_DIR"

    echo "🔍 Verifying PATH..."
    if [[ ":$PATH:" != *":$BIN_DIR:"* ]]; then
        echo "⚠️  WARNING: $BIN_DIR is not in your PATH."
        echo "Please add the following line to your ~/.bashrc:"
        echo "export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo "Then run: source ~/.bashrc"
    else
        echo "✅ PATH looks good."
    fi

    echo "🎉 Installation Complete!"
    echo "Your workspace is ready at: $WORKSPACE_DIR"
    echo "Run 'antigravity' to launch."
}

case "$COMMAND" in
    --install)
        do_install
        ;;
    --remove)
        do_remove
        ;;
    --help|-h)
        print_usage
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
