#!/usr/bin/env python3
"""Capture terminal UI screenshots from the HTML render page.

Usage:
    cd docs/images/
    python3 capture.py

Requires: pip install playwright && playwright install chromium
"""
import os
from pathlib import Path
from playwright.sync_api import sync_playwright

HERE = Path(__file__).parent.resolve()
RENDER_PAGE = HERE / "render.html"

SHOTS = {
    "shot1": "main_menu.png",
    "shot2": "install_submenu.png",
    "shot3": "cleanup_submenu.png",
    "shot4": "mock_install.png",
}

def main() -> None:
    if not RENDER_PAGE.exists():
        print(f"Error: {RENDER_PAGE} not found. Run from docs/images/.")
        raise SystemExit(1)

    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport={"width": 900, "height": 2000})
        page.goto(RENDER_PAGE.as_uri())
        page.wait_for_timeout(1000)

        for element_id, filename in SHOTS.items():
            el = page.locator(f"#{element_id}")
            out = HERE / filename
            el.screenshot(path=str(out))
            print(f"  ✓ {filename}")

        browser.close()

    print(f"\nDone! {len(SHOTS)} screenshots saved to {HERE}/")

if __name__ == "__main__":
    main()
