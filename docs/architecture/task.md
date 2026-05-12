# Task Tracker — `agv-easy-install` Fix-Up

> Living document. Updated as each step completes.

## Phase 0 — Documentation Bootstrap ✅
- `[x]` 0.1 Create `AGENTS.md` at repo root
- `[x]` 0.2 Create `docs/architecture/` directory
- `[x]` 0.3 Copy `critique.md` into `docs/architecture/`
- `[x]` 0.4 Copy `retort.md` into `docs/architecture/`
- `[x]` 0.5 Create `implementation_plan.md` in `docs/architecture/`
- `[x]` 0.6 Create `tests/` directory
- `[x]` 0.7 Create `tests/run_gates.sh` (executable, all 5 phase gates)
- `[x]` 0.8 Run Phase 0 gate — **5/5 passed**

## Phase 1 — Scaffolding & Hygiene
- `[ ]` 1.1 Create `LICENSE` (MIT)
- `[ ]` 1.2 Create `.gitignore`
- `[ ]` 1.3 Create `requirements.txt`
- `[ ]` 1.4 Create `CONTRIBUTING.md`
- `[ ]` 1.5 Create `.github/PULL_REQUEST_TEMPLATE.md`
- `[ ]` 1.6 Move `index.html` → `docs/index.html`
- `[ ]` 1.7 Update `deploy-pages.yml` to scope to `docs/`
- `[ ]` 1.8 Pin action versions in `deploy-pages.yml`
- `[ ]` 1.9 Run Phase 1 gate

## Phase 2 — Shell Hardening + Homebrew
- `[ ]` 2.1 Add `SCRIPT_VERSION` constant
- `[ ]` 2.2 Quote all variable expansions
- `[ ]` 2.3 Switch curl to `-fSsL`
- `[ ]` 2.4 Add `trap` cleanup in `do_install_tarball()`
- `[ ]` 2.5 Add SHA-256 checksum verification
- `[ ]` 2.6 Fix `$0` pipe detection
- `[ ]` 2.7 Add `gpgcheck=0` explanation comment
- `[ ]` 2.8 Add `detect_platform()` function
- `[ ]` 2.9 Add `check_brew()` helper
- `[ ]` 2.10 Add `install_brew()` function
- `[ ]` 2.11 Add brew removal in `do_remove()`
- `[ ]` 2.12 Update menu to 7 options
- `[ ]` 2.13 Add platform auto-detect suggestion
- `[ ]` 2.14 Add `--version` flag
- `[ ]` 2.15 Expand `--help` flag
- `[ ]` 2.16 Add `sudo` privilege warning
- `[ ]` 2.17 macOS-aware paths (skip .desktop, use `open`, `xdg-user-dir`)
- `[ ]` 2.18 Easter egg macOS compat
- `[ ]` 2.19 Run Phase 2 gate

## Phase 3 — Pipeline Fixes
- `[ ]` 3.1 Pin `actions/checkout@v4`
- `[ ]` 3.2 Pin `actions/setup-python@v5`
- `[ ]` 3.3 Use `requirements.txt` in CI
- `[ ]` 3.4 Add URL validation step
- `[ ]` 3.5 Change `sed` delimiter to `#`
- `[ ]` 3.6 Add `shellcheck` lint step
- `[ ]` 3.7 Add SHA-256 sync step
- `[ ]` 3.8 Improve commit message
- `[ ]` 3.9 Add scraper docstring
- `[ ]` 3.10 Add scraper type hints
- `[ ]` 3.11 Add scraper URL validation
- `[ ]` 3.12 Scraper errors to stderr
- `[ ]` 3.13 Verify scraper syntax
- `[ ]` 3.14 Run Phase 3 gate

## Phase 4 — Docs & Polish
- `[ ]` 4.1 Pin Lucide version
- `[ ]` 4.2 Add `<meta name="description">`
- `[ ]` 4.3 Add Open Graph tags
- `[ ]` 4.4 Add favicon
- `[ ]` 4.5 Add `aria-label` to buttons
- `[ ]` 4.6 Add `aria-expanded` toggle
- `[ ]` 4.7 Add XSS safety comment
- `[ ]` 4.8 Add Homebrew to menu explanation
- `[ ]` 4.9 Update option numbers to match 7-option layout
- `[ ]` 4.10 Add CI status badge
- `[ ]` 4.11 Add architecture section to README
- `[ ]` 4.12 Expand supported platforms table
- `[ ]` 4.13 Add Homebrew quick-install
- `[ ]` 4.14 Add troubleshooting section
- `[ ]` 4.15 Add roadmap section
- `[ ]` 4.16 Fix "exclusively on Ubuntu" scope claim
- `[ ]` 4.17 Add changelog link
- `[ ]` 4.18 Run Phase 4 gate
