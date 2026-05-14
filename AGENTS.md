# Agent Instructions — `agv-easy-install`

> This file provides context and rules for AI coding agents working in this repository.

---

## Project Identity

**What this is:** A cross-platform installer toolkit for Google Antigravity, consisting of:
- `src/` and `build.sh` — The source files for the manager script. **Never edit `antigravity-manager.sh` directly.** Edit the files in `src/` and run `./build.sh` to compile them.
- `antigravity-manager.sh` — The compiled core product. A Bash script that installs, manages, and removes Antigravity.
- `scrape_latest.py` — A Python utility that scrapes the latest Antigravity tarball URL (run nightly by CI).
- `.github/workflows/` — CI pipelines for Pages deployment and nightly URL updates.

**Who it's for:** Students setting up an IDE for a class. Most have never used a terminal. The primary goal is *zero-friction setup on any platform where you can paste a command into a shell.*

**Philosophy:** If you can get to a shell and paste a command, we help you install. The bash script IS the cross-platform tool — no rewrite needed. Each new OS adds a detection path within the same script.

---

## Architecture — Critical Couplings

```
┌────────────────────────────────────────────────────────────┐
│  antigravity-manager.sh                                    │
│  ├── DOWNLOAD_URL    ← updated nightly by CI               │
│  └── KNOWN_SHA256    ← MUST be updated alongside URL       │
└──────────────────────┬────────────────────────────────────-─┘
                       │ sed replacement
┌──────────────────────┴─────────────────────────────────────┐
│  .github/workflows/nightly-update.yml                      │
│  └── scrape_latest.py → new URL → update script → commit  │
└────────────────────────────────────────────────────────────┘
```

> [!CAUTION]
> **`DOWNLOAD_URL` and `KNOWN_SHA256` are architecturally coupled.** If you change one, you MUST change the other. The nightly CI does this automatically. If you manually edit either constant, update both.

---

## Rules

### Shell Script (`antigravity-manager.sh`)

1. **All changes must pass `shellcheck`.** Run: `shellcheck -e SC1091,SC2162 antigravity-manager.sh`
2. **All changes must pass `bash -n`.** Run: `bash -n antigravity-manager.sh`
3. **Always double-quote variable expansions.** `"$VAR"`, never bare `$VAR`.
4. **Use `curl -fSsL`**, never `curl -sL`. The `-f` flag ensures HTTP errors are not silently swallowed.
5. **The `curl | bash` install pattern is intentional.** Do not replace it with a multi-step download-verify-execute flow. The target audience is students on ephemeral VMs. Integrity is handled by the SHA-256 check inside the script itself.
6. **Preserve the easter egg.** The interactive menu has an undocumented `"Google"` input that opens the Course Catalog. Keep it working across platforms (`xdg-open` on Linux, `open` on macOS).
7. **macOS awareness:** macOS support is **beta** (see Roadmap in README). The code paths exist — skip `.desktop` file creation on macOS, use `open` instead of `xdg-open` when `uname -s` is `Darwin` — but end-to-end testing is incomplete.
8. **Cleanup:** Any function that creates temp files must use `trap ... EXIT` to clean up on failure.
9. **Interactive menu:** The script uses a hierarchical `gum choose` menu (main → install sub-menu / cleanup sub-menu). When modifying menu options, update all three: the `gum choose` options array, the fallback `case` statement, AND the landing page's menu explanation + screenshots in `docs/index.html`. Regenerate screenshots with `python3 docs/images/capture.py`.
10. **Ephemeral UI Pattern:** The script uses `gum` for its modern UI elements. To preserve the zero-dependency philosophy, `gum` must ONLY be downloaded ephemerally via `bootstrap_ui()` into a temp directory and cleaned up via `trap`. Do not permanently install it via APT/DNF or alter host package managers.

### Landing Page (`docs/index.html`)

1. **Uses Tailwind CDN.** This is intentional for a single static page. Do NOT rewrite to vanilla CSS.
2. **Pin external dependencies.** Lucide must be pinned to a specific version, never `@latest`.
3. **Use `textContent`, never `innerHTML`** when injecting fetched content. This is a security boundary — add a comment if you touch this code.
4. **Keep the page self-contained.** No build step, no bundler, no npm. It must work as a single HTML file served by GitHub Pages.
5. **Menu screenshots must match the script.** If the script's menu changes, update the screenshots by editing `docs/images/render.html` and running `python3 docs/images/capture.py`.

### Python Scraper (`scrape_latest.py`)

1. **Keep it minimal.** This is a single-purpose utility, not a framework.
2. **Print the URL to stdout, errors to stderr.** CI captures stdout for the URL value.
3. **Dependencies are in `requirements.txt`.** Install via `pip install -r requirements.txt`, not inline `pip install`.

### CI Workflows

1. **Pin all action versions** to a specific major (e.g., `@v4`). Never use `@latest` or `@main`.
2. **The nightly workflow must update both `DOWNLOAD_URL` and `KNOWN_SHA256`** when the URL changes. This is non-negotiable.
3. **Use `#` as the `sed` delimiter**, not `|` or `/`, to avoid injection from URLs containing those characters.
4. **Run `shellcheck` before committing** any changes to `antigravity-manager.sh`.

### Documentation

1. **README must reflect actual capabilities.** If the script supports a new distro or platform, update the README's supported platforms table.
2. **`TODO.md` is the single source of truth for pending work.** It lives in the project root. Update it at the end of every coding session to reflect what was completed and what remains.
3. **Architecture docs live in `docs/architecture/`.** The `implementation_plan.md` is a living document — update it when making architectural changes.
4. **After every session, update these files if they are affected by your changes:**
   - `TODO.md` — check off completed items, add new items discovered
   - `README.md` — platform table, roadmap, troubleshooting
   - `docs/index.html` — if menus or UI changed
   - `docs/images/render.html` + `capture.py` — if menu text changed
   - `CHANGELOG.md` — for user-facing changes

---

## Testing

All changes are verified via gate tests in `tests/run_gates.sh`.

```bash
# Run a specific phase gate
bash tests/run_gates.sh --phase 2

# Run all gates
bash tests/run_gates.sh --phase all
```

Before submitting any PR, the relevant phase gate(s) must pass.

---

## File Map

```
.
├── AGENTS.md                          ← You are here
├── CONTRIBUTING.md                    ← How to contribute
├── CHANGELOG.md                       ← Release history
├── TODO.md                            ← Pending work (update every session)
├── LICENSE                            ← MIT
├── README.md                          ← User-facing docs
├── build.sh                           ← Compiles src/ → antigravity-manager.sh
├── antigravity-manager.sh             ← THE CORE PRODUCT (compiled — do not edit directly)
├── src/                               ← Source modules (edit these)
│   ├── 00_config.sh                   ← Constants, version, colors
│   ├── 10_utils.sh                    ← Logging, cleanup, bootstrap_ui
│   ├── 20_platform.sh                 ← detect_platform, print_system_info, print_banner
│   ├── 30_installers.sh               ← install_brew, install_repo, do_install_tarball
│   ├── 40_ui.sh                       ← main_menu, install_submenu, cleanup_submenu
│   └── 99_main.sh                     ← CLI dispatch, sandbox loop, run_interactive
├── scrape_latest.py                   ← Nightly URL scraper
├── requirements.txt                   ← Python deps for scraper
├── .gitignore
├── .github/
│   ├── PULL_REQUEST_TEMPLATE.md
│   └── workflows/
│       ├── deploy-pages.yml           ← Pages deployment (docs/ only)
│       └── nightly-update.yml         ← URL + SHA-256 auto-update
├── docs/
│   ├── index.html                     ← Landing page (GitHub Pages)
│   ├── images/                        ← Terminal UI screenshots
│   │   ├── render.html                ← Screenshot source (HTML mockups)
│   │   ├── capture.py                 ← Playwright script to regenerate PNGs
│   │   ├── main_menu.png
│   │   ├── install_submenu.png
│   │   ├── cleanup_submenu.png
│   │   └── mock_install.png
│   └── architecture/
│       └── implementation_plan.md     ← Living architecture doc
└── tests/
    └── run_gates.sh                   ← Phase gate test runner (66 gates)
```

---

## Common Pitfalls

| Pitfall | Why It Breaks |
|---------|--------------|
| Updating `DOWNLOAD_URL` without `KNOWN_SHA256` | Tarball install rejects every download (checksum mismatch) |
| Using `innerHTML` in the landing page | XSS vulnerability from fetched source code |
| Adding `@latest` to a CDN dependency | Unpinned dep = ticking time bomb |
| Forgetting to quote a variable in bash | Shellcheck fails, word splitting bugs on edge cases |
| Changing menu options without updating the landing page | Students see wrong instructions |
| Using `/` or `|` as sed delimiter in CI | URLs containing those chars break or inject into the script |
| Adding macOS code that calls `xdg-open` | `xdg-open` doesn't exist on macOS — use `open` |
