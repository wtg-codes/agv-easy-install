# Package Specification: Antigravity IDE

> **Status:** ✅ Active
> **Last updated:** 2026-05-20
> **Parent:** [implementation_plan.md](implementation_plan.md)

---

## Overview

The **Google Antigravity IDE** is a desktop application designed for secure, agentic software engineering education. It packages the Gemini-powered code assistant canvas alongside terminal shells, debugging hooks, and course track viewers.

---

## Package Metadata

| Property | Value / Description |
|---|---|
| **Package Name** | `google-antigravity` (generic), `antigravity` (Homebrew/System Repos) |
| **Binary Name** | `antigravity` |
| **Target Audience** | Students, lab environments |
| **GUI Framework** | Electron / Native Web Shell |

---

## Target Installation Directories

The installation targets depend on the chosen installation method and operating system:

### 1. Homebrew (macOS / Linux)
- **macOS:** `/Applications/Google Antigravity.app` (cask)
- **Linux:** `/home/linuxbrew/.linuxbrew/bin/antigravity` (formula symlink pointing to the cellar extraction)

### 2. System Repo (Debian/Ubuntu/Fedora)
- **Executable:** `/usr/bin/antigravity`
- **Application Directory:** `/usr/share/antigravity`
- **Icon Assets:** `/usr/share/icons/hicolor/scalable/apps/antigravity.svg`
- **Desktop Entry:** `/usr/share/applications/google-antigravity.desktop`

### 3. Official Binary (Standalone Tarball)
- **User-Space Executable:** `~/.local/bin/antigravity`
- **Application Directory:** `~/.local/lib/antigravity/`
- **Desktop Entry:** `~/.local/share/applications/google-antigravity.desktop` and `~/Desktop/google-antigravity.desktop`

---

## Dependencies & Integrations

The Antigravity IDE has one primary critical runtime dependency:

### Google Chrome Browser
Antigravity operates via Chrome Developer Protocol (CDP) and requires a modern Google Chrome engine. 
- **Homebrew Cask:** Automatically forces a dependency on the `google-chrome` cask.
- **Tarball / System Repo:** The installer automatically scans for valid Chrome paths on the system (including flatpak/snap packages) and saves the mapping to the configuration directory (`~/.config/Antigravity`).

---

## Maintenance & Version Rules

1. **Auto-Updates:**
   - Packages installed via Homebrew and System Repos (`apt`/`dnf`) are updated through their respective package managers.
   - Standalone binary/tarball installations are updated by running the `antigravity-manager.sh` script or via an in-app prompt.
2. **Version Rules:**
   - Any modifications to the IDE payload delivery or script installers must be logged in `CHANGELOG.md`.
   - The default IDE version constant (`DEFAULT_IDE_VERSION`) in `src/00_config.sh` must match the latest validated release published to the Google Storage bucket.
