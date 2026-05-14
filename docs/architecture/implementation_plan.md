# AGV Easy Install — Implementation Plan

> **Last updated:** 2026-05-13 · Branch: `feat-platform-extensions`
> This is a living document. It reflects the current architecture and roadmap.
> For pending work items, see [`TODO.md`](../../TODO.md) in the project root.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│  src/                                               │
│  ├── 00_config.sh     Constants, version, colors    │
│  ├── 10_utils.sh      Logging, cleanup, gum boot    │
│  ├── 20_platform.sh   OS detect, banner, sys info   │
│  ├── 30_installers.sh Brew, repo, tarball install   │
│  ├── 40_ui.sh         Hierarchical menus            │
│  └── 99_main.sh       CLI dispatch, sandbox loop    │
└──────────┬──────────────────────────────────────────┘
           │ ./build.sh
           ▼
┌─────────────────────────────────────────────────────┐
│  antigravity-manager.sh  (compiled — never edit)    │
│  ├── DOWNLOAD_URL  ← updated nightly by CI          │
│  └── KNOWN_SHA256  ← MUST be updated alongside URL  │
└──────────┬──────────────────────────────────────────┘
           │ curl | bash
           ▼
┌─────────────────────────────────────────────────────┐
│  User's terminal                                    │
│  ├── Banner + system info dashboard                 │
│  ├── Main menu (Cancel / Install → / Cleanup →)     │
│  ├── Install sub-menu (★ Brew / Repo / Tarball)     │
│  └── Cleanup sub-menu (Uninstall / Save / Demo)     │
└─────────────────────────────────────────────────────┘
```

### Key Design Decisions

| Decision | Rationale |
|---|---|
| **Source-first bundler** (`src/` → `build.sh`) | Keeps modules small; the compiled script is the deliverable |
| **Ephemeral `gum`** | Zero permanent dependencies; downloaded to temp dir, cleaned up on exit |
| **Cancel-first menus** | Pressing Enter without thinking = safe exit (student audience) |
| **Hierarchical sub-menus** | Reduces top-level noise; signals "more choices ahead" with `→` arrows |
| **`curl \| bash` pattern** | Intentional — target audience is students on ephemeral VMs. SHA-256 check inside the script handles integrity |
| **`DOWNLOAD_URL` + `KNOWN_SHA256` coupling** | If one changes, the other MUST change. Nightly CI enforces this |

---

## Completed Phases (0–5)

All original phases are complete and validated by the 66-gate test suite.

| Phase | Name | Gates | Status |
|---|---|---|---|
| 0 | Documentation Bootstrap | 5 | ✅ Complete |
| 1 | Scaffolding & Hygiene | 9 | ✅ Complete |
| 2 | Shell Hardening + Homebrew | 14 | ✅ Complete |
| 3 | Pipeline Fixes | 11 | ✅ Complete |
| 4 | Docs & Polish | 13 | ✅ Complete |
| 5 | Bundler & Tooling | 14 | ✅ Complete |
| **Total** | | **66** | ✅ All passing |

### Gate Runner

```bash
# Run all gates
bash tests/run_gates.sh --phase all

# Run a specific phase
bash tests/run_gates.sh --phase 5
```

---

## Current Gate Summary

### Phase 0 — Documentation Bootstrap (5 gates)
- Architecture docs exist (`implementation_plan.md`)
- `AGENTS.md` exists
- Gate runner exists

### Phase 1 — Scaffolding & Hygiene (9 gates)
- LICENSE (MIT), `.gitignore`, `requirements.txt`
- `CONTRIBUTING.md`, PR template
- `docs/index.html` exists, root `index.html` removed
- Pages scoped to `docs/`

### Phase 2 — Shell Hardening + Homebrew (14 gates)
- `bash -n` + `shellcheck` clean
- `--version`, `--help` flags work
- Core functions exist: `detect_platform`, `install_brew`, `check_brew`
- `trap` cleanup, SHA-256 verification, `KNOWN_SHA256` constant
- Old `$0` bash detection removed
- Hierarchical menu system (`main_menu`, `install_submenu`, `cleanup_submenu`)
- Auto-detect recommendation

### Phase 3 — Pipeline Fixes (11 gates)
- Pinned action versions (`checkout@v4`, `setup-python@v5`)
- `requirements.txt` used, URL validation, `shellcheck` in CI
- Safe `sed` delimiter (`#`), SHA-256 sync step
- Scraper: compiles, has docstring, type hints, stderr errors

### Phase 4 — Docs & Polish (13 gates)
- Landing page: Lucide pinned, meta tags, OG tags, favicon, aria labels
- Homebrew in landing page, `aria-expanded` toggle
- README: architecture, Homebrew, troubleshooting, roadmap, changelog, scope claim

### Phase 5 — Bundler & Tooling (14 gates)
- `build.sh` exists and produces output
- `src/` structure: `00_config.sh`, `40_ui.sh`, `99_main.sh`
- `--demo-ui` flag and sandbox loop exist
- Screenshot tooling: `render.html`, `capture.py`
- Screenshot PNGs: `main_menu`, `install_submenu`, `cleanup_submenu`
- `AGENTS.md` documents `src/`

---

## Upcoming Work

See [`TODO.md`](../../TODO.md) for the detailed, structured task list. Key areas:

### macOS Validation (Beta → Stable)

> 📄 **[platform-macos.md](platform-macos.md)** — full architecture reference

**Completed:** `shasum -a 256` fallback, `~/.zprofile` PATH injection, tarball fallback unblocked, Gatekeeper `xattr` warning, platform-aware URL opener (easter egg).
**Remaining:** End-to-end testing on Apple Silicon + Intel hardware, `gum` arm64 bootstrap validation, Homebrew cask formula testing.

### Crostini (ChromeOS) — ⚠️ Beta

> 📄 **[platform-crostini.md](platform-crostini.md)** — full architecture reference

**Completed:** `/dev/.cros_milestone` detection, ChromeOS milestone in system info dashboard, `garcon-url-handler` Chrome-not-in-container warning.
**Remaining:** End-to-end testing on ChromeOS hardware (x86_64 and ARM), `gum` arm64 bootstrap on Chromebooks.

### Windows (WSL2 + Git Bash) — ⚠️ Beta

> 📄 **[platform-windows.md](platform-windows.md)** — full architecture reference

**Completed:** WSL2 detection (`/proc/version`), `(WSL)` label in dashboard, `.desktop` skip in WSL, `wslview` browser opener, MSYS2/Git Bash hard-exit redirect to WSL2.
**Remaining:** End-to-end testing in WSL2 Ubuntu.

### Official Precompiled Binaries (macOS / Windows)
- The current architecture pulls a standalone Linux tarball. We will expand `scrape_latest.py` and the nightly CI to scrape URLs and SHA-256 hashes for official macOS and Windows binaries.
- The compiled script will feature new constants (`MAC_X64_URL`, `MAC_ARM64_URL`, `WIN_X64_URL`).
- These official binaries will become the **recommended** installation path on their respective platforms, offering a more native experience while keeping current methods (Homebrew / WSL) available as fallbacks.

### CI & Quality
- ✅ GitHub Actions CI workflow (`ci.yml`) — runs phase gates on `ubuntu-latest` and `macos-latest`
- `--check` flag for installation health verification (planned)

---

## Screenshot Regeneration

When the terminal UI changes, update the screenshots:

```bash
# 1. Edit docs/images/render.html to match new menu text
# 2. Regenerate PNGs
python3 docs/images/capture.py
# 3. Verify in README and landing page
```

---

## Architecture Reference Index

### Platform Docs

| Platform | Doc | Status |
|---|---|---|
| Linux (umbrella) | [platform-linux.md](platform-linux.md) | ✅ Tested |
| ↳ Debian/Ubuntu (APT) | [platform-linux-apt.md](platform-linux-apt.md) | ✅ Tested |
| ↳ Fedora/RHEL (DNF) | [platform-linux-dnf.md](platform-linux-dnf.md) | ✅ Tested |
| ↳ Atomic/Immutable | [platform-linux-atomic.md](platform-linux-atomic.md) | ✅ Tested |
| macOS | [platform-macos.md](platform-macos.md) | ⚠️ Beta |
| Crostini (ChromeOS) | [platform-crostini.md](platform-crostini.md) | ⚠️ Beta |
| Windows (WSL2 + Git Bash) | [platform-windows.md](platform-windows.md) | ⚠️ Beta |

### Install Method Docs

| Method | Doc | Needs sudo? |
|---|---|---|
| Homebrew | [install-homebrew.md](install-homebrew.md) | No |
| System Repo (APT/DNF) | [install-repo.md](install-repo.md) | Yes |
| Tarball (standalone) | [install-tarball.md](install-tarball.md) | No |

---

## File Map

See `AGENTS.md` for the complete, authoritative file map.
