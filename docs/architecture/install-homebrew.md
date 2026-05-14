# Install Method: Homebrew — Architecture Notes

> **Last updated:** 2026-05-13
> **Source:** `src/30_installers.sh:1-32` (`install_brew`)

---

## Overview

Homebrew is the **recommended** install method. It provides cross-platform support (Linux + macOS), automatic updates, and no-sudo installation. Our script recommends it via the `★` star rating in the install sub-menu.

---

## How It Works

### Flow

```
install_brew()
├── check_brew()               # Is `brew` in PATH?
│   ├── YES → continue
│   └── NO  → macOS: exit with error
│             Linux: fall back to tarball
├── Platform check
│   ├── macOS: brew install --cask antigravity
│   └── Linux: brew install antigravity
├── configure_chrome_path()    # Find and set Chrome binary
└── Write state file           # {"method": "brew", ...}
```

### Key Code

```bash
# macOS: GUI app → uses --cask
brew install --cask antigravity

# Linux: CLI/desktop app → uses formula
brew install antigravity
```

### Fallback Behavior

If Homebrew is not installed:
- **macOS:** Fatal error — tarball is not supported on macOS.
- **Linux:** Automatically falls back to `do_install_tarball()`.

If the formula is not found:
- **macOS:** Fatal error (no fallback).
- **Linux:** Falls back to `do_install_tarball()`.

---

## Homebrew Concepts

### Formula vs Cask

| Type | `brew install <name>` | `brew install --cask <name>` |
|---|---|---|
| **For** | CLI tools, libraries | GUI apps (.app bundles) |
| **Install location** | `$(brew --prefix)/bin/` | `/Applications/` (macOS) |
| **Typical format** | Source or pre-built binary | `.dmg`, `.pkg`, `.zip` |

We use:
- **Formula** on Linux (installs to `~/.linuxbrew/bin/`)
- **Cask** on macOS (installs to `/Applications/`)

### Taps (Custom Repositories)

Since Antigravity is proprietary, it won't be in `homebrew/core`. It needs a custom Tap:

```bash
# Users would run:
brew tap wtg-codes/antigravity
brew install antigravity
```

**To create the tap:**
1. Create GitHub repo: `wtg-codes/homebrew-antigravity`
2. Add formula file: `Formula/antigravity.rb`
3. Formula downloads the tarball, verifies SHA-256, and installs

**Status:** 📋 The tap does not exist yet. This is required before Homebrew install actually works.

---

## Removal

```bash
# State file says method=brew
# macOS:
brew uninstall --cask antigravity

# Linux:
brew uninstall antigravity
```

Also removes: `$APP_DIR`, `$BIN_DIR/antigravity`, `.desktop` files.

---

## Platform Compatibility

| Platform | Command | Status |
|---|---|---|
| Linux (Ubuntu, Fedora, etc.) | `brew install antigravity` | ✅ Code ready (needs tap) |
| Linux (Atomic/Immutable) | `brew install antigravity` | ✅ Best option for these distros |
| macOS (Apple Silicon) | `brew install --cask antigravity` | ⚠️ Code ready, needs validation |
| macOS (Intel) | `brew install --cask antigravity` | ⚠️ Code ready, needs validation |
| WSL2 | `brew install antigravity` | 📋 Should work (untested) |
| Crostini | `brew install antigravity` | 📋 Should work (untested) |

---

## Open Issues

1. **No Homebrew tap exists yet** — `brew install antigravity` will fail with "formula not found"
2. **Cask formula not created** — needed for macOS `.app` bundle install
3. **Auto-update:** Homebrew handles updates, but the user must run `brew upgrade`
4. **Homebrew install itself** — if user doesn't have Homebrew, our script doesn't install it (intentional — we don't modify the host package manager)
