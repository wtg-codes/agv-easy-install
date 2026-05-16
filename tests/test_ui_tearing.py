#!/usr/bin/env python3
"""
test_ui_tearing.py
------------------
Two-part test for the AGV Easy Install UI:

1. PTY TEARING CHECK  — Spawns antigravity-manager.sh --demo-ui in a real
   pseudo-terminal (via pexpect) at a realistic terminal size, captures the
   raw byte stream, and asserts that the "ghosting" signature is absent.
   The classic tearing artifact is the placeholder line appearing MORE THAN
   ONCE in the captured output (gum failing to clear its previous frame).

2. PLAYWRIGHT SCREENSHOT — Opens docs/images/render.html in a headless
   Chromium browser, screenshots all four terminal mockups, and saves them
   to tests/screenshots/ for human inspection.
"""

import re
import sys
import os
import pathlib
import pexpect
from playwright.sync_api import sync_playwright

REPO_ROOT = pathlib.Path(__file__).parent.parent
SCRIPT    = str(REPO_ROOT / "antigravity-manager.sh")
RENDER_HTML = (REPO_ROOT / "docs" / "images" / "render.html").as_uri()
SCREENSHOT_DIR = REPO_ROOT / "tests" / "screenshots"
SCREENSHOT_DIR.mkdir(parents=True, exist_ok=True)

# ── ANSI stripper ────────────────────────────────────────────────────────────
ANSI_RE = re.compile(r'\x1B\[[0-9;]*[A-Za-z]|\x1B\][^\x07]*\x07|\r')

def strip_ansi(raw: bytes) -> str:
    return ANSI_RE.sub('', raw.decode('utf-8', errors='replace'))

# ── 1. PTY Tearing Check ─────────────────────────────────────────────────────
def test_pty_no_tearing():
    print("\n── PTY Tearing Check ────────────────────────────────────────")
    print(f"  Script : {SCRIPT}")

    # Spawn in a 120-col × 30-row pseudo-terminal (realistic desktop size)
    child = pexpect.spawn(
        "bash", [SCRIPT, "--demo-ui"],
        encoding=None,           # bytes mode so we see raw escapes
        dimensions=(30, 120),    # (rows, cols)
        timeout=20,
        env={**os.environ, "TERM": "xterm-256color", "NO_COLOR": ""}
    )

    # Collect output until the menu appears (look for the nav hint line)
    buf = b""
    try:
        child.expect(b"navigate", timeout=20)
        buf = child.before + child.after
        # Give it half a second more to flush any redraws
        child.expect(pexpect.TIMEOUT, timeout=0.5)
        buf += child.before
    except pexpect.EOF:
        buf += child.before or b""
    except pexpect.TIMEOUT:
        buf += child.before or b""
    finally:
        child.close(force=True)

    clean = strip_ansi(buf)
    print(f"  Captured {len(buf)} raw bytes / {len(clean)} chars after ANSI strip")

    # --- Assertion: placeholder text must not appear more than once ----------
    placeholder = "Select an option or type a secret"
    occurrences = clean.count(placeholder)
    print(f"  Placeholder occurrences: {occurrences}  (want ≤ 1)")

    if occurrences > 1:
        # Print the lines around duplicates for diagnosis
        for i, line in enumerate(clean.splitlines()):
            if placeholder in line:
                print(f"    LINE {i:3d}: {repr(line)}")
        print("  ❌ FAIL — placeholder duplicated (tearing / ghosting detected)")
        return False
    else:
        print("  ✅ PASS — no duplicate placeholder (no tearing detected)")
        return True


# ── 2. Playwright Screenshot ─────────────────────────────────────────────────
def test_playwright_screenshots():
    print("\n── Playwright Screenshot Check ──────────────────────────────")
    print(f"  Source : {RENDER_HTML}")

    shots = []
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        page = browser.new_page(viewport={"width": 900, "height": 800})
        page.goto(RENDER_HTML)
        page.wait_for_load_state("networkidle")

        shot_ids = ["shot1", "shot2", "shot3", "shot4"]
        labels   = ["main_menu", "install_submenu", "cleanup_submenu", "mock_install"]

        for sid, label in zip(shot_ids, labels):
            el = page.locator(f"#{sid}")
            out = SCREENSHOT_DIR / f"{label}.png"
            el.screenshot(path=str(out))
            shots.append(out)
            print(f"  📸 Saved: tests/screenshots/{label}.png")

        browser.close()

    print(f"  ✅ PASS — {len(shots)} screenshots saved to tests/screenshots/")
    return True


# ── Main ─────────────────────────────────────────────────────────────────────
if __name__ == "__main__":
    pty_ok  = test_pty_no_tearing()
    shot_ok = test_playwright_screenshots()

    print("\n── Summary ──────────────────────────────────────────────────")
    print(f"  PTY tearing check : {'✅ PASS' if pty_ok  else '❌ FAIL'}")
    print(f"  Playwright shots  : {'✅ PASS' if shot_ok else '❌ FAIL'}")

    sys.exit(0 if (pty_ok and shot_ok) else 1)
