# Install Method: Homebrew

> **Status:** ✅ Tested
> **Last updated:** 2026-05-13
> **Parent:** [implementation_plan.md](implementation_plan.md)
> **Packages:** [package-antigravity-ide.md](package-antigravity-ide.md) | [package-antigravity-cli.md](package-antigravity-cli.md)

---

## Overview

Homebrew is the officially recommended installation method for macOS and Atomic Linux distributions (like Bluefin). It provides a clean, user-space installation path that avoids modifying root filesystems or relying on `sudo`.

Antigravity is distributed via a **Custom Tap** (a third-party repository) rather than the `homebrew/core` repository.

### Formula vs Cask Architecture

Homebrew uses a Ruby Domain Specific Language (DSL).
- **Formula (`.rb`):** A procedural recipe used for compiling software from source or installing pre-compiled CLI binaries. Installed into the `Cellar`.
- **Cask (`.rb`):** A declarative definition used for installing pre-compiled GUI applications (`.app`, `.dmg`) directly into `/Applications`.

**Antigravity Architecture:** 
Because Antigravity relies heavily on a terminal CLI experience but requires Google Chrome (a GUI browser) to function, we distribute the CLI component as a **Formula** and use the `depends_on cask: "google-chrome"` stanza to ensure the browser is present.

---

## Installation Flow

```bash
# 1. Tap the custom repository
brew tap wtg-codes/homebrew-antigravity

# 2. Install the formula
brew install antigravity
```

**Source:** `src/30_installers.sh:23-38`

### Why a Custom Tap?
We use a custom tap (`wtg-codes/homebrew-antigravity`) instead of submitting to `homebrew-core` because:
1. `homebrew-core` has strict popularity metrics that new projects cannot meet.
2. We retain full control over the release cadence.
3. We can mandate Cask dependencies (like Chrome), which `homebrew-core` often rejects for standard CLI tools.

---

## Security: The Homebrew Sandbox

Homebrew employs a sandboxing mechanism during installation to prevent packages from maliciously or accidentally writing outside of the designated Homebrew prefix (`/opt/homebrew` on Apple Silicon, `/usr/local` on Intel).

> [!WARNING]
> **macOS vs Linux Architecture:**
> - **macOS:** Homebrew uses the native `sandbox-exec` utility. Formulae cannot write to arbitrary system paths during installation.
> - **Linux:** **Homebrew on Linux does not have a sandbox.** Installation scripts run with the permissions of the user invoking `brew install`. While our formula is safe, be aware that Linuxbrew lacks this strict macOS security layer.

---

## Continuous Integration & Release Automation

To ensure `brew install antigravity` always pulls the latest version, the custom tap repository (`wtg-codes/homebrew-antigravity`) must be kept in sync with the main project releases.

**Best Practice Automation:**
We utilize GitHub Actions (e.g., `mislav/bump-homebrew-formula-action`) in the main repository to automate this:
1. A new release is tagged in the main repo.
2. A GitHub Action builds the tarball and calculates the SHA-256 hash.
3. The Action uses a scoped Personal Access Token (PAT) to commit the new version string and SHA-256 hash directly into the `antigravity.rb` formula file living in the tap repository.

---

## Uninstall & Rollback

```bash
# Remove the package
brew uninstall antigravity

# Optional: Remove the tap to stop receiving updates
brew untap wtg-codes/homebrew-antigravity
```

**Source:** `src/30_installers.sh:177-179`

### Fallback Logic
If `brew install antigravity` fails inside the installation script, the script catches the non-zero exit code and cleanly falls through to the **Tarball** installation method. This ensures the user still gets a working installation without seeing a hard failure.

---

## Essential Homebrew Skills

1. **`brew info antigravity`**: Display detailed information about the formula, including dependencies and caveats.
2. **`brew audit --strict antigravity`**: Run this command locally when developing the formula to ensure it meets Homebrew's stylistic and structural guidelines.
3. **`brew install --build-from-source antigravity`**: Force compilation rather than using a pre-compiled bottle (useful for debugging architecture-specific issues).
4. **`brew doctor`**: The first step in troubleshooting any Homebrew environment issues.
