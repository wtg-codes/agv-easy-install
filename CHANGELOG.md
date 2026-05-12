# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]
- **Bug Fix:** Bootstrapped `KNOWN_SHA256` to the currently valid tarball checksum to fix standalone tarball installations.
- **Bug Fix:** Removed macOS tarball fallbacks since the standalone tarball only contains a `linux-x64` binary.
- **Docs:** Clarified in `README.md` and `docs/index.html` that the tarball is Linux-only.

## [1.2.0] - 2026-05-12
### Added
- **Homebrew Support:** `antigravity-manager.sh` now supports `brew install --cask antigravity` on macOS and `brew install antigravity` on Linux.
- Added `--version` and `--help` CLI flags.
- Added macOS path awareness (skipping `.desktop` generation and using `open` instead of `xdg-open`).
- Added robust validation in the nightly `scrape_latest.py` pipeline, ensuring `KNOWN_SHA256` and `DOWNLOAD_URL` are kept in sync.

### Changed
- `curl` commands now use `-fSsL` to fail loudly on HTTP errors instead of silently creating truncated files.
- Refactored `antigravity-manager.sh` to include a `detect_platform` and `detect_distro` check instead of assuming an Ubuntu CloudTop.
- Moved `index.html` to `docs/index.html` to restrict GitHub Pages from exposing the whole repository.

### Fixed
- Fixed unquoted bash variable expansions throughout the manager script.
- Fixed an unstable pipe detection heuristic checking for `*"bash"*` in `$0`.
- Added a `trap` for the temporary directory cleanup to avoid leaving orphaned folders on errors.
