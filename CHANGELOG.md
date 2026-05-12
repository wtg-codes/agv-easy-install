# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/).

---

## [Unreleased]

### Fixed
- Bootstrapped `KNOWN_SHA256` to the real tarball checksum — standalone installs no longer fail out of the box.
- Removed macOS tarball fallbacks (the standalone tarball is `linux-x64` only).

### Docs
- Clarified in README and landing page that the tarball path is Linux-only.
- Added `CHANGELOG.md`.

---

## [1.2.0] — 2026-05-12

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
