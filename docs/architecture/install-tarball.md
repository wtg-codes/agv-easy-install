# Install Method: Tarball — Architecture Notes

> **Last updated:** 2026-05-13
> **Source:** `src/30_installers.sh:86-155` (`do_install_tarball`)

---

## Overview

Tarball is the **universal fallback** method. It downloads a pre-built archive, verifies its SHA-256 checksum, extracts it, and symlinks the binary. No package manager or `sudo` required (installs to `~/.local/`).

**This is also the method used for CI/headless installs via `--auto`.**

---

## How It Works

### Flow

```
do_install_tarball()
├── Check sha256sum is available
├── Create directories
│   ├── ~/.local/bin/            (BIN_DIR)
│   ├── ~/.local/lib/antigravity (APP_DIR)
│   ├── ~/my-antigravity-work    (WORKSPACE_DIR)
│   └── ~/Desktop               (DESKTOP_DIR)
├── Download tarball → temp dir
│   └── curl -fSL $DOWNLOAD_URL
├── Verify SHA-256 checksum
│   └── echo "$KNOWN_SHA256  file" | sha256sum -c -
├── Extract archive
│   └── tar -xzf ... -C $APP_DIR --strip-components=1
├── Create symlink
│   └── ln -sf $APP_DIR/antigravity $BIN_DIR/antigravity
├── Create .desktop file (Linux only)
│   ├── ~/.local/share/applications/
│   └── ~/Desktop/ (with gio trust + chmod +x)
├── inject_path()              # Add ~/.local/bin to shell rc
├── configure_chrome_path()    # Find and set Chrome binary
└── Write state file           # {"method": "tarball", ...}
```

---

## Security: SHA-256 Verification

The tarball is verified against a known checksum embedded in the script:

```bash
# Constants in src/00_config.sh:
DOWNLOAD_URL="https://..."
KNOWN_SHA256="abc123..."

# Verification:
echo "$KNOWN_SHA256  $TMP_DIR/Antigravity.tar.gz" | sha256sum -c - > /dev/null 2>&1
```

### Critical Coupling

> [!CAUTION]
> **`DOWNLOAD_URL` and `KNOWN_SHA256` MUST be updated together.** If the URL changes but the hash doesn't, every download will be rejected. The nightly CI (`nightly-update.yml`) handles this automatically.

### macOS Compatibility Issue

macOS does NOT have `sha256sum`. It uses `shasum -a 256` instead. The script currently requires `sha256sum` and will fail on macOS:

```bash
# Current code (Linux only):
if ! command -v sha256sum > /dev/null 2>&1; then
    log_error "sha256sum is required..."
    exit 1
fi

# Fix needed for cross-platform:
if command -v sha256sum > /dev/null 2>&1; then
    SHA_CMD="sha256sum"
elif command -v shasum > /dev/null 2>&1; then
    SHA_CMD="shasum -a 256"
else
    log_error "No SHA-256 utility found."
    exit 1
fi
```

**Note:** Tarball install is currently blocked on macOS (`src/30_installers.sh:75`), so this is future-proofing.

---

## File Layout After Install

```
~/.local/
├── bin/
│   └── antigravity → ../lib/antigravity/antigravity  (symlink)
├── lib/
│   └── antigravity/                                   (extracted tarball)
│       ├── antigravity                                (main binary)
│       ├── resources/
│       └── ...
└── share/
    └── applications/
        └── google-antigravity.desktop

~/my-antigravity-work/     (workspace directory)

~/Desktop/
└── google-antigravity.desktop  (desktop shortcut, Linux only)
```

---

## Temp File Cleanup

The download uses a temp directory with a trap to ensure cleanup:

```bash
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"; exit_handler' EXIT INT TERM
```

This ensures the temp tarball is deleted even if the script crashes or is interrupted.

---

## Download Progress

- **Interactive mode:** Shows `curl --progress-bar` (visible download bar)
- **JSON/Quiet mode:** Uses `curl -fSL` silently
- **Extraction:** Uses `gum spin --spinner dot` if available

---

## Removal

Tarball removal is straightforward — just delete the files:

```bash
rm -rf ~/.local/lib/antigravity
rm -f ~/.local/bin/antigravity
rm -f ~/.local/share/applications/google-antigravity.desktop
rm -f ~/Desktop/google-antigravity.desktop
```

The workspace (`~/my-antigravity-work`) is **intentionally preserved** during uninstall.

---

## Platform Compatibility

| Platform | Status | Notes |
|---|---|---|
| Linux (any distro) | ✅ Tested | Primary fallback path |
| Linux (Atomic) | ✅ Tested | Works on Bluefin/Silverblue |
| macOS | ❌ Blocked | `src/30_installers.sh:75` exits before tarball |
| WSL2 | 📋 Expected | Standard Linux filesystem |
| Crostini | 📋 Expected | Standard Debian filesystem |
| Git Bash | ❌ N/A | Linux binary won't run on Windows |

---

## CI/Headless Usage

The tarball method is used by `--auto` for unattended installs:

```bash
curl -fSsL https://wtg-codes.github.io/agv-easy-install/install.sh | bash -s -- --auto
```

In auto mode:
- No interactive prompts
- PATH injection is automatic
- Chrome path is auto-configured
- State file is written for future removal

---

## Open Issues

1. **`sha256sum` macOS fallback** — needs `shasum -a 256` support
2. **No progress percentage** — `curl --progress-bar` shows a bar but no ETA or percentage
3. **`--strip-components=1`** — assumes the tarball has exactly one top-level directory. If the upstream changes structure, this breaks.
4. **Large download (~218 MB)** — no resume support (`-C -`). If download fails midway, must restart from scratch.
5. **`gum spin` used for extraction** — if `gum` failed to bootstrap, extraction still works but shows no progress.
