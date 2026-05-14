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

- [ ] `gum` bootstrap on macOS (arm64 binary URL)
- [ ] `gum` bootstrap on macOS (x86_64 binary URL)
- [ ] Skip `.desktop` file creation on Darwin — code exists, needs validation
- [ ] `open` vs `xdg-open` for easter egg — code exists, needs validation
- [ ] PATH setup writes to `~/.zprofile` (not `~/.bashrc`) on macOS
- [ ] Homebrew formula actually installs Antigravity on macOS
- [ ] Chrome detection works on macOS (`/Applications/Google Chrome.app/...`)
- [ ] `save_manager_locally()` puts script in a macOS-appropriate location
- [ ] End-to-end test on macOS Sonoma (Apple Silicon)
- [ ] End-to-end test on macOS Sonoma (Intel)

---

## 📋 Planned — New Platforms

### Crostini (ChromeOS)
- [ ] Test tarball install in Crostini Debian container
- [ ] Detect Crostini environment (`/dev/.cros_milestone` or similar)
- [ ] Add to `detect_platform()` output
- [ ] Document in README platform table
- [ ] End-to-end test on ChromeOS

### Windows — WSL2
- [ ] Detect WSL environment (`uname -r` contains `microsoft`)
- [ ] Guide user to install via Ubuntu layer
- [ ] Test tarball install in WSL2 Ubuntu
- [ ] Add to `detect_platform()` output
- [ ] Document in README platform table

### Windows — Git Bash
- [ ] Investigate `curl`/`tar` availability in Git Bash
- [ ] Determine if `gum` can run in Git Bash
- [ ] Prototype minimal install path
- [ ] Document known limitations

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
