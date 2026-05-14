# AGV Easy Install — Implementation Plan

> **Last updated:** 2026-05-13 · Branch: `feat-bash-bundler`
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
The code paths exist but need end-to-end testing on real hardware:
- `gum` bootstrap for arm64 + x86_64
- `.desktop` skip, `open` vs `xdg-open`, `~/.zprofile` PATH
- Homebrew formula validation
- Chrome detection on macOS

### New Platform Support
- **Crostini (ChromeOS):** Debian container; tarball path likely works
- **Windows WSL2:** Ubuntu layer; tarball path likely works
- **Windows Git Bash:** May need significant work; lowest priority

### CI Improvements
- GitHub Actions macOS runner for smoke tests
- `--check` flag for installation health verification

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

## File Map

See `AGENTS.md` for the complete, authoritative file map.
