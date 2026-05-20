# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/).

---

## [0.2.13] — 2026-05-20

### Changed
- **Cleaner Screen Flow:** Added `clear || true` at the beginning of all interactive steps/menus (main menu, wizard steps, tool submenus, version selectors, post-install menus) to prevent old terminal output and previous step menus from cluttering the screen.
- **Main Menu simplification:** Removed the "Install/Remove this script locally" option from the main menu to reduce clutter (it remains accessible in the "Manage existing installation" submenu).
- **Terminology:** Renamed "Set up for class" to "Set up for lab" across all user-facing UI screens, logs, and docs.

## [0.2.12] — 2026-05-19

### Added
- **Wizard Flow:** Replaced flat menu with an intent-based wizard. First question asks "What would you like to do?" with options for lab setup, specific tool install, or manage existing installation.
- **Fast-Track Lab Setup:** New "🎓 Set up for lab" option installs selected products (IDE, CLI, SDK) via a multi-select picker, asks for the installation method, and confirms. Also available headlessly via `--fast-track`.
- **Post-Install Follow-up:** After any installation completes, a follow-up menu offers to launch Antigravity, create a workspace folder, or save the installer for later.

### Changed
- **Main Menu:** Menu options are now intent-based ("Set up for lab", "Install or update a specific tool", "Manage existing installation") instead of action-based ("Choose install method", "Cleanup options").
- **Submenus:** Switched from `gum filter` to `gum choose` and implemented compact one-line headers so all options are always visible on smaller terminal buffers.
- **Demo Mode:** Moved the "Demo UI (sandbox mode)" to the main menu.
- **Landing Page:** Updated wizard flow documentation and screenshots to match the new menu structure.

## [0.2.10] — 2026-05-19

### Added
- **Multi-Product Support:** Re-imagined installer interface to support Google Antigravity IDE, Antigravity CLI (`agy`), and Antigravity Python SDK (`google-antigravity`).
- **Dynamic Version Listing & Selection:** Fetches available releases dynamically from `versions.json` (and PyPI API for the SDK), letting users choose historical versions of each product to install.
- **Installed Version Detection:** Checks and displays currently installed versions of the IDE, CLI, and SDK on the startup dashboard alongside the latest available versions.
- **SDK Installation Support:** Added support for installing specific versions of the Antigravity Python SDK directly from PyPI.
- **Improved Scraper & Cache:** Upgraded `scrape_latest.py` with hash caching to prevent redundant file downloads of old versions, PyPI querying, and multi-product JSON manifest generation.
- **Health Check and Sandbox Updates:** Added SDK verification to the health check flow and integrated multi-product selection and mock actions in the sandbox demo mode.

## [0.2.9] — 2026-05-19

### Added
- **Antigravity CLI Support:** Added the command-line helper tool (`agy`) installer support, including the interactive UI option, `--install-cli` headless argument, and automatic removal of `$BIN_DIR/agy` on uninstall.
- **Health Check Integration:** Added optional CLI binary presence and PATH verification to the `--check` health check command.

### Changed
- **Official Release Alignment:** Targeted stable release version `2.0.0` from GCS URLs. Expanded the python scraper regex pattern to support both `/stable/` (edgedl) and `/antigravity-hub/` (GCS) path structures.
- **Documentation and Mock Screenshots:** Added CLI setup card to the landing page and README, updated manual download links, updated `docs/images/render.html` mock menu, and regenerated terminal mock screenshots.

## [0.2.8] — 2026-05-19

### Fixed
- **Nightly Scraper Version 2+ Support:** Updated `scrape_latest.py` to parse semantic versioning from the release page URLs, select the latest version, and matching download paths using a flexible filename pattern (to support files like `Antigravity IDE` in version 2+).

## [0.2.7] — 2026-05-15

### Added
- **Modern Terminal UI:** The interactive installer now features a beautiful arrow-key menu, animated spinners, and status blocks powered by an ephemeral download of `gum`.
- **Chrome Sandbox Bypass:** Added automatic path configuration for Flatpak/Atomic Linux environments to securely connect Antigravity to the browser.
- **Auto PATH Injection:** The installer can now automatically inject `~/.local/bin` into `~/.bashrc`, `~/.zshrc`, `~/.zprofile` (macOS), or `config.fish`.
- **JSON Output Mode:** Added `--json` flag to emit a single machine-readable status object instead of colored logs.
- **Headless Mode:** Added `--auto`, `--install-brew`, `--install-repo`, and `--install-tarball` flags for non-interactive automation.
- **Logging System:** Added robust logging to `/tmp/antigravity-install.log` with `--verbose` and `--quiet` flags.
- **State Management:** Added an `install.json` state file to track the install method for perfectly clean uninstalls.
- **Dependency Checks:** Script now fails fast if `curl`, `tar`, `awk`, or `grep` are missing.
- **WSL2 Detection:** Detects Windows Subsystem for Linux, labels dashboard as `(WSL)`, skips `.desktop` creation, routes browser opening to `wslview`.
- **MSYS2/Git Bash Block:** Hard-exits on MSYS2/Git Bash with a message directing users to WSL2.
- **Crostini (ChromeOS) Detection:** Detects `/dev/.cros_milestone`, displays milestone in dashboard, warns when no Linux browser is installed in the container.
- **macOS `shasum` Fallback:** Tarball verification now uses `shasum -a 256` on macOS when GNU `sha256sum` is unavailable.
- **macOS Tarball Unblocked:** The tarball install path now works on macOS, with a Gatekeeper `xattr` quarantine removal instruction shown post-install.
- **macOS PATH Fix:** PATH injection on macOS now targets `~/.zprofile` instead of `~/.zshrc`, preventing `path_helper` overwrites.
- **Easter Egg Upgrade:** Main menu now uses `gum filter --no-strict`, allowing free-text input to trigger the hidden `Google` Course Catalog opener. Works on all platforms via `xdg-open`/`open`/`wslview`.
- **CI Gate Tests:** Added `ci.yml` workflow to run the full 66-gate test suite on both `ubuntu-latest` and `macos-latest`.

### Changed
- **Rollbacks:** The system repository installer now gracefully cleans up broken repository keys and list files if `apt/dnf install` fails.

### Fixed
- Bootstrapped `KNOWN_SHA256` to the real tarball checksum — standalone installs no longer fail out of the box.
- **`gum filter` UI tearing:** Adjusted `--height=8` to provide exact space for all 4 options, bypassing the macOS alternate screen buffer tearing bug. Also fixed local development test auto-downgrade issue.

### Docs
- Updated README platform table: Crostini and WSL now show ⚠️ Beta, Git Bash shows ❌ Blocked.
- Updated README Roadmap to reflect completed macOS, Crostini, and Windows work.
- Updated platform badge to include WSL and ChromeOS.
- Documented new headless CLI flags in `README.md`.
- Added `CHANGELOG.md`.

---

## [0.2.2] — 2026-05-12

### Added
- **Homebrew install path** — `brew install --cask antigravity` (macOS) / `brew install antigravity` (Linux).
- `--version` and `--help` CLI flags.
- Platform auto-detection with install method recommendation in the interactive menu.
- macOS awareness — skips `.desktop` file creation, uses `open` instead of `xdg-open`.
- SHA-256 checksum verification for tarball downloads.
- `trap` cleanup for temp directories on error.
- Nightly CI now syncs both `DOWNLOAD_URL` **and** `KNOWN_SHA256` in lockstep.
- `shellcheck` lint step in the nightly pipeline before committing.
- URL validation (`HEAD` request) before the nightly commit.
- `AGENTS.md`, `CONTRIBUTING.md`, `LICENSE` (MIT), `.gitignore`, `requirements.txt`.
- Phase gate test runner (`tests/run_gates.sh`).
- Architecture docs (`docs/architecture/`).

### Changed
- All `curl` calls switched to `-fSsL` (fail on HTTP errors).
- `sed` delimiter in nightly CI changed from `|` to `#` to avoid URL injection.
- GitHub Pages deployment scoped to `docs/` instead of the entire repo root.
- Action versions pinned consistently (`checkout@v4`, `setup-python@v5`).
- Lucide icon library pinned to `0.292.0` (was `@latest`).

### Fixed
- Double-quoted all variable expansions to pass `shellcheck`.
- Replaced brittle `*"bash"*` pipe detection with `[ -f "$0" ] && [ -r "$0" ]`.
- Added `gpgcheck=0` explanation comment in the RPM repo block.
- Added `aria-label` attributes and `aria-expanded` toggle to the landing page.
- Added SEO meta tags and Open Graph tags to the landing page.
