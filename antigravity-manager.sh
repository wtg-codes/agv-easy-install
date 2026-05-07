#!/usr/bin/env bash
set -e

# Configuration
DOWNLOAD_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/1.23.2-4781536860569600/linux-x64/Antigravity.tar.gz"

# Directories (for Tarball install)
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/lib/antigravity"
WORKSPACE_DIR="$HOME/my-antigravity-work"
DESKTOP_DIR="$HOME/Desktop"

# Files
DESKTOP_FILE_SYS="$HOME/.local/share/applications/google-antigravity.desktop"
DESKTOP_FILE_USER="$DESKTOP_DIR/google-antigravity.desktop"
ICON_PATH="$APP_DIR/resources/app/out/vs/workbench/contrib/antigravityCustomAppIcon/browser/media/antigravity/antigravity.png"

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_LIKE=$ID_LIKE
    else
        DISTRO="unknown"
    fi
}

check_deps() {
    echo "🔍 Checking dependencies..."
    # Get glibc version (e.g., 2.35)
    GLIBC_VERSION=$(ldd --version | head -n 1 | grep -oP '\d+\.\d+' | head -n 1)
    echo "   Detected glibc: $GLIBC_VERSION"

    # Simple version check (split by dot)
    MAJOR=$(echo $GLIBC_VERSION | cut -d. -f1)
    MINOR=$(echo $GLIBC_VERSION | cut -d. -f2)

    if [ "$MAJOR" -lt 2 ] || { [ "$MAJOR" -eq 2 ] && [ "$MINOR" -lt 28 ]; }; then
        echo "⚠️  Warning: Your glibc version ($GLIBC_VERSION) is lower than the recommended 2.28."
        echo "   Antigravity might not run correctly."
    fi
}

install_repo() {
    detect_distro
    case "$DISTRO" in
        ubuntu|debian|kali|linuxmint)
            echo "📦 Setting up DEB repository..."
            sudo mkdir -p /etc/apt/keyrings
            curl -fSsL https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg | \
                sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg
            echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-apt antigravity main" | \
                sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null
            sudo apt update
            sudo apt install -y antigravity
            ;;
        fedora|rhel|centos|amzn)
            echo "📦 Setting up RPM repository..."
            sudo tee /etc/yum.repos.d/antigravity.repo << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL
            sudo dnf makecache
            sudo dnf install -y antigravity
            ;;
        *)
            echo "❌ Distribution $DISTRO not explicitly supported for repo install."
            echo "   Falling back to Tarball installation..."
            do_install_tarball
            ;;
    esac
}

do_install_tarball() {
    echo "🚀 Starting Google Antigravity Standalone (Tarball) Installation..."

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
    fi

    echo "🎉 Installation Complete!"
    echo "Your workspace is ready at: $WORKSPACE_DIR"
}

do_remove() {
    echo "🧹 Removing Google Antigravity..."
    # Try removing repo package if exists
    detect_distro
    if command -v apt &> /dev/null && [ -f /etc/apt/sources.list.d/antigravity.list ]; then
        sudo apt remove -y antigravity || true
        sudo rm -f /etc/apt/sources.list.d/antigravity.list
    elif command -v dnf &> /dev/null && [ -f /etc/yum.repos.d/antigravity.repo ]; then
        sudo dnf remove -y antigravity || true
        sudo rm -f /etc/yum.repos.d/antigravity.repo
    fi

    # Cleanup standalone files
    rm -rf "$APP_DIR"
    rm -f "$BIN_DIR/antigravity"
    rm -f "$DESKTOP_FILE_SYS"
    rm -f "$DESKTOP_FILE_USER"
    echo "✅ Uninstalled successfully. (Note: Your code in $WORKSPACE_DIR was kept safe)."
}

print_usage() {
    echo "Usage: $0 [OPTION]"
    echo "Options:"
    echo "  --install   Run the interactive installation wizard."
    echo "  --remove    Uninstall Antigravity."
}

if [ "$1" == "--remove" ]; then
    do_remove
    exit 0
elif [ "$1" == "--install" ] || [ -z "$1" ]; then
    echo "------------------------------------------"
    echo "   Google Antigravity Manager"
    echo "------------------------------------------"
    check_deps
    echo ""
    echo "How would you like to install Antigravity?"
    echo "1) Standard Repository (Best for updates, requires sudo)"
    echo "2) Standalone Tarball (Installs to ~/.local, no sudo needed for app)"
    echo "3) Cancel"
    read -p "Select an option [1-3]: " choice

    case $choice in
        1) install_repo ;;
        2) do_install_tarball ;;
        *) echo "Cancelled."; exit 0 ;;
    esac
else
    print_usage
    exit 1
fi
