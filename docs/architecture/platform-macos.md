# macOS Support — Architecture Notes

> **Status:** ⚠️ Beta
> **Last updated:** 2026-05-13
> **Parent:** [implementation_plan.md](implementation_plan.md)

---

## Overview

macOS is currently in **Beta** support. The architecture relies heavily on POSIX-compliant tooling, but macOS introduces several proprietary security and process management layers (Gatekeeper, SIP, LaunchServices) that the installer must navigate.

### Supported Architectures
- **Intel (x86_64):** Supported via Rosetta 2 (if Homebrew is x86) or native.
- **Apple Silicon (arm64):** Fully supported natively.

---

## Security Architecture: SIP & Gatekeeper

macOS employs a defense-in-depth security model that heavily penalizes unsigned or unnotarized binaries (like our standalone Tarball fallback).

### System Integrity Protection (SIP)
SIP restricts the `root` user from modifying critical system directories (e.g., `/usr/bin`, `/System`). 
Because of SIP, our installer **cannot** place binaries in `/usr/bin/` on macOS, even with `sudo`. All Antigravity installations must go to user-space (`~/.local/bin/` or Homebrew's `/opt/homebrew/bin/`).

### Gatekeeper & `spctl`
Gatekeeper verifies the code signature and notarization ticket of applications before allowing them to run. By default, macOS blocks the execution of unsigned binaries downloaded from the internet.

If a user installs Antigravity via the Tarball method, macOS tags the downloaded tarball with a `com.apple.quarantine` extended attribute. This quarantine flag propagates to the extracted binary.

**The Fix:** If the user gets a "Cannot be opened because the developer cannot be verified" error, they must manually clear the quarantine flag or add a Gatekeeper exception using `spctl`:
```bash
# Clear quarantine flag
xattr -d com.apple.quarantine ~/.local/bin/antigravity

# Or bypass Gatekeeper policy (not recommended for production)
spctl --add ~/.local/bin/antigravity
```

---

## LaunchServices vs Direct Execution (`open`)

On Linux, the script uses `xdg-open` or launches Chrome directly. On macOS, the installer uses the native `open` command.

The `open` command acts as a CLI bridge to **macOS LaunchServices**.
```bash
open -a "Google Chrome" "https://example.com"
```

**Why we use `open` instead of direct execution:**
If you execute the Chrome binary directly (`/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`), you bypass LaunchServices. 
1. Bypassing LaunchServices means the app ignores `Info.plist` settings.
2. The app becomes a direct child process of the terminal shell, inheriting the shell's environment rather than the system's GUI environment.
3. Closing the terminal would kill the browser process.

By using `open`, Antigravity asks the OS to spawn Chrome properly as a sibling GUI application.

---

## Shell Configuration (`.zprofile` vs `.zshrc`)

Since macOS Catalina (10.15), the default shell is **Zsh**. 
Furthermore, macOS treats every new Terminal window as a **login shell**.

### Execution Order & `path_helper`
When a Terminal opens on macOS, Zsh sources files in this order:
1. `/etc/zprofile` -> *Runs Apple's `path_helper` to set system PATH.*
2. `~/.zprofile` -> *Best place for user PATH modifications.*
3. `~/.zshrc` -> *Best place for aliases and visual tweaks.*

**The Antigravity Installer Strategy:**
The script targets `~/.zprofile` when adding `~/.local/bin` to the user's `PATH`.
Why? Because if we put the PATH modification in `~/.zshenv` (which runs *before* `/etc/zprofile`), Apple's `path_helper` would overwrite our changes. By placing it in `~/.zprofile`, we ensure Antigravity's path is appended *after* the system defaults.

---

## Core Utilities Quirks (BSD vs GNU)

macOS ships with **BSD** versions of standard POSIX tools, which differ subtly from the **GNU** tools found on Linux.

| Tool | Linux (GNU) | macOS (BSD) | Antigravity Script Adaptation |
|---|---|---|---|
| **sed** | `sed -i 's/a/b/'` | `sed -i '' 's/a/b/'` | The script avoids in-place `sed -i` to prevent cross-platform breakages, favoring file redirection instead. |
| **sha256sum** | Built-in | Missing (use `shasum -a 256`) | The script must detect macOS and alias `sha256sum` to `shasum -a 256` under the hood. |
| **tar** | GNU Tar | BSD Tar | Both handle basic extraction identically (`tar -xzf`), so no adaptation is needed. |

---

## Essential macOS CLI Skills

1. **`xattr`**: View and remove extended attributes (like the quarantine bit).
   * `xattr ~/.local/bin/antigravity`
2. **`spctl --assess --verbose`**: Check if a binary passes Gatekeeper validation.
3. **`codesign -dv --verbose=4`**: Inspect the cryptographic signature and notarization ticket of a binary.
4. **`sw_vers`**: Print the macOS product name and version (used in our `detect_platform` script).
