#!/usr/bin/env bash
set -e

COMMAND=$1
DOWNLOAD_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/linux-x64/Antigravity.tar.gz"

# Directories
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/lib/antigravity"
WORKSPACE_DIR="$HOME/my-antigravity-work"
DESKTOP_DIR="$HOME/Desktop"

# Files
DESKTOP_FILE_SYS="$HOME/.local/share/applications/google-antigravity.desktop"
DESKTOP_FILE_USER="$DESKTOP_DIR/google-antigravity.desktop"
ICON_PATH="$APP_DIR/resources/app/out/vs/workbench/contrib/antigravityCustomAppIcon/browser/media/antigravity/antigravity.png"

print_usage() {
    echo "Usage: ./antigravity-manager.sh [OPTION]"
    echo "Options:"
    echo "  --install   Installs Antigravity, sets up workspace, and creates desktop shortcuts."
    echo "  --remove    Uninstalls Antigravity and removes shortcuts."
}

do_remove() {
    echo "🧹 Removing Google Antigravity..."
    rm -rf "$APP_DIR"
    rm -f "$BIN_DIR/antigravity"
    rm -f "$DESKTOP_FILE_SYS"
    rm -f "$DESKTOP_FILE_USER"
    echo "✅ Uninstalled successfully. (Note: Your code in $WORKSPACE_DIR was kept safe)."
}

do_install() {
    echo "🚀 Starting Google Antigravity Installation..."

    echo "📁 Preparing directories..."
    mkdir -p "$BIN_DIR"
    mkdir -p "$APP_DIR"
    mkdir -p "$WORKSPACE_DIR"
    mkdir -p "$DESKTOP_DIR"
    mkdir -p "$(dirname "$DESKTOP_FILE_SYS")"

    TMP_DIR=$(mktemp -d)

    echo "⬇️ Downloading Antigravity..."
    curl -sL "$DOWNLOAD_URL" -o "$TMP_DIR/Antigravity.tar.gz"

    echo "📦 Extracting archive..."
    tar -xzf "$TMP_DIR/Antigravity.tar.gz" -C "$APP_DIR" --strip-components=1

    echo "🔗 Creating symlink..."
    ln -sf "$APP_DIR/antigravity" "$BIN_DIR/antigravity"

    echo "🖼️ Registering application icon..."
    cat << EOF > "$DESKTOP_FILE_SYS"
[Desktop Entry]
Version=1.0
Name=Google Antigravity
Comment=Secure Agentic Development IDE
Exec=$BIN_DIR/antigravity
Icon=$ICON_PATH
Terminal=false
Type=Application
Categories=Development;IDE;
EOF

    echo "🖥️ Adding shortcut to Desktop..."
    cp "$DESKTOP_FILE_SYS" "$DESKTOP_FILE_USER"
    chmod +x "$DESKTOP_FILE_USER"

    # On Ubuntu, desktop icons sometimes need to be marked as trusted
    if command -v gio &> /dev/null; then
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
    echo "Run 'antigravity --version' to verify."
}

case "$COMMAND" in
    --install)
        do_install
        ;;
    --remove)
        do_remove
        ;;
    *)
        print_usage
        exit 1
        ;;
esac
