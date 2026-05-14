# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/).

---

## [Unreleased]

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
