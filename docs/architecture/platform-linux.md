# Linux Support — Architecture Notes

> **Status:** ✅ Tested — primary platform.
> **Last updated:** 2026-05-13

---

## Overview

Linux is the primary and fully-tested platform. All three install methods work, and the UI has been validated on multiple distributions.

---

## Detection

```bash
PLATFORM=$(uname -s)  # Returns "Linux"
```

### Distribution Detection (`detect_distro`)

The script reads `/etc/os-release` to identify the distribution:

```bash
DISTRO=$(grep -w ID /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
```

Currently supported values and their install paths:

| `$DISTRO` | Install Method | Package Manager |
|---|---|---|
| `ubuntu` | APT repo | `apt` |
| `debian` | APT repo | `apt` |
| `kali` | APT repo | `apt` |
| `linuxmint` | APT repo | `apt` |
| `fedora` | DNF repo | `dnf` |
| `rhel` | DNF repo | `dnf` |
| `centos` | DNF repo | `dnf` |
| `amzn` | DNF repo | `dnf` |
| Any (with Homebrew) | Homebrew | `brew` |
| Any | Tarball | Manual |

### Atomic/Immutable Linux (Bluefin, Silverblue, etc.)

These distributions use `rpm-ostree` or `ujust` and have read-only `/usr`. Key considerations:

- **APT/DNF is NOT available** (or is layered and discouraged)
- **Homebrew works** — it installs to `$HOME/.linuxbrew/`
- **Tarball works** — it installs to `~/.local/lib/`
- Detection: `rpm-ostree status` succeeds, or `/etc/os-release` contains `VARIANT_ID=*atomic*`

**Current status:** Works via Homebrew and Tarball. No special detection code yet — shows as the base distro (e.g., "Fedora").

---

## Architecture Details

### Chrome Detection

Priority order (see `src/20_platform.sh:52-95`):
1. **Flatpak Chrome** (system-wide) → `/var/lib/flatpak/app/com.google.Chrome/.../chrome`
2. **Flatpak Chrome** (user) → `~/.local/share/flatpak/app/com.google.Chrome/.../chrome`
3. **System package Chrome** → `google-chrome-stable`, `google-chrome`, `chromium`, `chromium-browser`

### PATH Setup

Shell detection logic (`src/20_platform.sh:1-49`):
- Zsh → writes to `~/.zshrc`
- Fish → writes to `~/.config/fish/config.fish`
- Bash (default) → writes to `~/.bashrc`
- Idempotent — checks if `$HOME/.local/bin` is already in the file before writing

### `.desktop` File

Created at two locations:
- **System apps:** `~/.local/share/applications/google-antigravity.desktop`
- **Desktop shortcut:** `$(xdg-user-dir DESKTOP)/google-antigravity.desktop` (with fallback to `$HOME/Desktop`)

Post-install:
- `chmod +x` on the desktop shortcut
- `gio set metadata::trusted true` if `gio` is available (GNOME trust)
- `update-desktop-database` if available

### `gum` Bootstrap

Downloads from GitHub releases:
- `Linux_x86_64` for Intel/AMD
- `Linux_arm64` for ARM (e.g., ARM Chromebooks, Raspberry Pi)

### SHA-256 Verification

Uses `sha256sum` from GNU Coreutils (always available on Linux).

---

## Tested Distributions

| Distribution | Version | Status |
|---|---|---|
| Bluefin (Fedora Atomic) | 43 | ✅ Tested (Homebrew + Tarball) |
| Ubuntu | 22.04, 24.04 | ✅ Tested (APT + Tarball) |
| Fedora | 40+ | ✅ Tested (DNF) |
| Debian | 12 | ✅ Expected to work (same as Ubuntu APT path) |

---

## Known Quirks

| Quirk | Detail |
|---|---|
| **Flatpak Chrome sandboxing** | Antigravity can't launch Flatpak Chrome directly via `flatpak run`. Must use the raw binary path inside the Flatpak installation. |
| **Wayland** | Some Electron apps need `--ozone-platform-hint=auto`. Not currently set by our installer. |
| **SELinux (Fedora/RHEL)** | Tarball binaries in `~/.local` may need context labels. Not yet handled. |
| **Immutable distros** | `rpm-ostree` layering is slow and discouraged. Homebrew or Tarball is preferred. |
