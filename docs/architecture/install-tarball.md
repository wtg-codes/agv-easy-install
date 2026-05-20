# Install Method: Tarball (Standalone)

> **Status:** ✅ Tested
> **Last updated:** 2026-05-13
> **Parent:** [implementation_plan.md](implementation_plan.md)
> **Packages:** [package-antigravity-ide.md](package-antigravity-ide.md)

---

## Overview

The Tarball method is the universal, zero-dependency fallback for Antigravity. If the user's system lacks Homebrew, APT, or DNF, the installer dynamically downloads a pre-compiled `.tar.gz` archive and unpacks it into the user's home directory.

This method requires **no root privileges (`sudo`)** and does not alter the host system's root filesystem.

---

## Architecture: User-Space FHS

We adhere to the XDG Base Directory Specification and the unofficial but widely accepted user-space Filesystem Hierarchy Standard (FHS).

| Target | Path | Purpose |
|---|---|---|
| **Payload Extraction** | `~/.local/lib/antigravity/` | Holds the raw, extracted application files (binaries, node_modules, assets). |
| **Executable Symlink** | `~/.local/bin/antigravity` | A symlink pointing to the core binary in the `lib` directory. Added to `$PATH`. |

*📚 Reference:* [XDG Base Directory Spec](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)

---

## Download & Integrity Flow

The installer performs a secure, verified download using POSIX standard tools (`curl` and `tar`).

### 1. Robust Download (`curl`)
The script uses `curl -fSsL` to download the tarball:
- `-f`: Fail silently on server errors (prevents downloading an HTML 404 page).
- `-S`: Show errors if they occur (overriding the silent flag for errors only).
- `-s`: Silent mode (no progress bar, keeping automated CI logs clean).
- `-L`: Follow HTTP redirects (essential if the URL points to a dynamic release asset).

### 2. Cryptographic Verification (`sha256sum`)
Security is paramount because this method pulls directly from the open internet without the GPG verification layer provided by APT/DNF.

1. The installer hardcodes a `KNOWN_SHA256` constant (updated nightly by CI).
2. It downloads the tarball to a temporary file (`/tmp/antigravity-install.tar.gz`).
3. It computes the SHA-256 hash of the downloaded file.
4. **Execution is immediately halted** if the computed hash does not perfectly match `KNOWN_SHA256`.

*SHA-256 is immune to collision attacks, ensuring the downloaded file has not been tampered with or corrupted.*

### 3. Extraction (`tar`)
Once verified, the tarball is extracted securely:
```bash
tar -xzf /tmp/antigravity-install.tar.gz -C ~/.local/lib/antigravity/ --strip-components=1
```
Using `-C` ensures the extraction is sandboxed to the target directory, preventing path traversal attacks from a maliciously crafted tarball.

---

## Platform Handling

The tarball method requires the installer to map the local OS architecture to the correct binary payload:

```bash
# src/20_platform.sh mapping logic
PLATFORM=$(uname -s)
ARCH=$(uname -m)

# Translates to URLs like:
# .../antigravity-linux-x64.tar.gz
# .../antigravity-linux-arm64.tar.gz
# .../antigravity-darwin-arm64.tar.gz
```

---

## Removal & Cleanup

```bash
# Safely remove the application payload
rm -rf ~/.local/lib/antigravity/

# Remove the executable symlink
rm -f ~/.local/bin/antigravity
```

**Source:** `src/30_installers.sh:187-190`

### Defensive Temp Cleanup
Any function that touches `/tmp/` uses a bash `trap` to ensure no orphaned files are left behind, even if the user sends a `SIGINT` (Ctrl+C) mid-download:
```bash
trap 'rm -f /tmp/antigravity-install.tar.gz' EXIT
```

---

## Essential Tarball Skills

1. **`sha256sum` (Linux) / `shasum -a 256` (macOS)**: Manually verify the checksum of a downloaded file.
2. **`ldd ~/.local/lib/antigravity/antigravity`**: Check if the standalone binary is missing any shared library dependencies on a minimal Linux installation.
3. **`tar -tvf archive.tar.gz`**: List the contents of a tarball *without* extracting it, useful for auditing directory structures.
