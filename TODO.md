# TODO — AGV Easy Install

> **Last updated:** 2026-05-13 · Branch: `feat-bash-bundler`
> This file is the single source of truth for all pending work.
> It MUST be updated at the end of every coding session.

---

## ✅ Completed

### Core Installer
- [x] Modular `src/` → `build.sh` bundler architecture
- [x] `detect_platform()` — OS, arch, package manager, glibc
- [x] `install_brew()` — Homebrew install path (Linux + macOS code)
- [x] `install_repo()` — APT/DNF system repo install
- [x] `do_install_tarball()` — standalone tarball with SHA-256 verification
- [x] `do_remove()` — uninstall Antigravity (all methods)
- [x] `save_manager_locally()` — persist the manager script
- [x] AGV detection at startup — check if Antigravity is already installed
- [x] Chrome browser detection + auto-configuration prompt

### Terminal UI
- [x] Ephemeral `gum` bootstrap (download → temp dir → cleanup)
- [x] Colorful ASCII art banner with version + repo link
- [x] System info dashboard (OS, AGV status, recommendation)
- [x] Hierarchical Cancel-first menu (main → install / cleanup sub-menus)
- [x] `--demo-ui` sandbox mode with mock actions for every path
- [x] Fallback plain-text menu when `gum` unavailable

### CLI Interface
- [x] `--version`, `--help`, `--remove`, `--verbose`, `--quiet`, `--json`
- [x] `--auto` headless auto-install (CI/provisioning)
- [x] `--install-brew`, `--install-repo`, `--install-tarball` direct flags
- [x] `--demo-ui` sandbox mode

### Security & Integrity
- [x] `KNOWN_SHA256` constant + `sha256sum` verification on tarball downloads
- [x] Nightly CI syncs both `DOWNLOAD_URL` and `KNOWN_SHA256` together
- [x] `curl -fSsL` everywhere (never swallows HTTP errors)
- [x] `textContent` only in landing page (no `innerHTML` XSS risk)
- [x] `trap ... EXIT` cleanup for all temp files

### CI/CD
- [x] `nightly-update.yml` — scrape URL, validate, update script, lint, commit
- [x] `deploy-pages.yml` — GitHub Pages from `docs/`
- [x] Pinned action versions (`checkout@v4`, `setup-python@v5`)
- [x] `sed` uses `#` delimiter (safe for URLs)
- [x] `shellcheck` lint step before commit

### Documentation
- [x] README with hero screenshot, platform table, roadmap, troubleshooting
- [x] Interactive landing page (`docs/index.html`) with embedded screenshots
- [x] Corp/CloudTop warning as collapsible `<details>`
- [x] Screenshot tooling (`docs/images/render.html` + `capture.py`)
- [x] AGENTS.md with complete file map and rules
- [x] CONTRIBUTING.md with `src/` → `build.sh` workflow
- [x] CHANGELOG.md

### Testing
- [x] 66-gate test suite across 6 phases
- [x] Phase 0: Documentation bootstrap
- [x] Phase 1: Scaffolding & hygiene
- [x] Phase 2: Shell hardening + Homebrew
- [x] Phase 3: Pipeline fixes
- [x] Phase 4: Docs & polish
- [x] Phase 5: Bundler & tooling

---

## ⚠️ In Progress — macOS (Beta)

> macOS code paths exist but have NOT been end-to-end validated.
> See **[docs/architecture/platform-macos.md](docs/architecture/platform-macos.md)** for implementation details.

### Code Fixes Needed
- [ ] `sha256sum` → `shasum -a 256` fallback (macOS has no `sha256sum`)
- [ ] PATH setup: detect shell, write to `~/.zprofile` (Zsh) not `~/.bashrc`
- [ ] Mock UI references `~/.bashrc` — should be shell-aware
- [ ] Easter egg: implement `open` vs `xdg-open` platform-aware opener

### Validation Needed (Code Exists)
- [ ] `gum` bootstrap on macOS (arm64 binary download)
- [ ] `gum` bootstrap on macOS (x86_64 binary download)
- [ ] Skip `.desktop` file creation on Darwin — code at `src/30_installers.sh:131`
- [ ] Chrome detection at `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`
- [ ] `brew install --cask antigravity` actually works
- [ ] `brew uninstall --cask antigravity` cleanup
- [ ] `save_manager_locally()` in `~/.local/bin/` with correct PATH

### End-to-End Testing
- [ ] Full flow on macOS Sonoma (Apple Silicon)
- [ ] Full flow on macOS Sonoma (Intel)
- [ ] `--demo-ui` sandbox mode works
- [ ] GitHub Actions macOS runner smoke test

---

## 📋 Planned — New Platforms

### Crostini (ChromeOS)

> See **[docs/architecture/platform-crostini.md](docs/architecture/platform-crostini.md)** for implementation details.

- [ ] Add Crostini detection: `test -f /dev/.cros_milestone` in `detect_platform()`
- [ ] Show ChromeOS milestone in system info dashboard
- [ ] Handle Chrome-not-in-container: detect `garcon-url-handler`
- [ ] Test APT install in Crostini Debian container
- [ ] Test tarball install in Crostini
- [ ] Test `gum` binary on ARM Chromebooks (`Linux_arm64`)
- [ ] Document in README platform table
- [ ] End-to-end test on ChromeOS (x86_64)
- [ ] End-to-end test on ChromeOS (ARM)

### Windows — WSL2

> See **[docs/architecture/platform-windows.md](docs/architecture/platform-windows.md)** for implementation details.

- [ ] Add WSL detection: `$WSL_DISTRO_NAME` or `uname -r | grep microsoft`
- [ ] Show "(WSL)" in system info dashboard
- [ ] Skip `.desktop` file creation in WSL
- [ ] Browser opening: use `wslview` or `cmd.exe /c start` instead of `xdg-open`
- [ ] Test APT install in WSL2 Ubuntu
- [ ] Test tarball install in WSL2
- [ ] Document in README platform table

### Windows — Git Bash

> See **[docs/architecture/platform-windows.md](docs/architecture/platform-windows.md)** for implementation details.

- [ ] Add Git Bash detection: `$OSTYPE = msys` or `uname -s | grep MINGW`
- [ ] Implement graceful redirect: show message suggesting WSL2 instead
- [ ] Verify no crashes or syntax errors when script runs
- [ ] Document as "not supported — use WSL2" in README

---

## 📋 Planned — Features

- [ ] macOS `.dmg` download fallback (for users without Homebrew)
- [ ] Automated CI testing on macOS (GitHub Actions macOS runner)
- [ ] Auto-update mechanism for the manager script itself
- [ ] `--check` flag to verify existing installation health
- [ ] Localization / i18n (stretch goal)

---

## ✅ Maintenance — Complete

- [x] Review and update screenshots when menu text changes — verified all menu text matches between `src/40_ui.sh` and `docs/images/render.html`
- [x] Keep landing page screenshots in sync with `render.html` — landing page (`docs/index.html`) references `main_menu.png`, `install_submenu.png`, `cleanup_submenu.png`; README references all 4 PNGs
- [x] Regenerate screenshots: ran `python3 docs/images/capture.py` — 4 PNGs updated
- [x] Gate count in implementation plan — verified: 66 gates across 6 phases
