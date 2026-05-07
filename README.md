# Antigravity Installer

A simple, robust way to install Google Antigravity on Linux.

## Quick Install (One-Liner)

Open your terminal and paste the following command:

```bash
curl -sSL https://raw.githubusercontent.com/google/antigravity-install/main/setup.sh | bash
```

This will download the manager script and start the interactive installation.

## Manual Usage

If you prefer to download and run the manager manually:

1. **Download the manager:**
   ```bash
   curl -sSL https://raw.githubusercontent.com/google/antigravity-install/main/antigravity-manager.sh -o antigravity-manager.sh
   chmod +x antigravity-manager.sh
   ```

2. **Install:**
   ```bash
   ./antigravity-manager.sh --install
   ```

3. **Remove:**
   ```bash
   ./antigravity-manager.sh --remove
   ```

## Features

- **Interactive Setup:** Choose between a system-wide repository installation (APT/RPM) or a standalone tarball installation.
- **Auto-Detection:** Automatically detects your Linux distribution (Ubuntu, Debian, Fedora, RHEL, etc.) and sets up the correct repositories.
- **Dependency Checks:** Verifies system requirements like `glibc` before installation.
- **Desktop Integration:** Creates a Desktop shortcut and registers the application in your system menu with the correct icon.
- **Managed Workspace:** Sets up a default workspace at `~/my-antigravity-work`.

## Requirements

- Linux (x86_64)
- `glibc` >= 2.28 (e.g., Ubuntu 20.04+, Debian 10+, Fedora 36+, RHEL 8+)
- `curl`, `tar`, `gpg` (standard on most distros)
