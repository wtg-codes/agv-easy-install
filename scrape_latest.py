"""
Scrapes the latest Antigravity tarball URL from antigravity.google.

Strategy:
  1. Fetch the download page HTML to find the hashed main JS bundle filename
     (e.g. main-5LR4F4TY.js).
  2. Fetch that JS bundle from the site root (NOT under /download/).
  3. The bundle is served gzip-compressed, so we must send Accept-Encoding
     and let requests handle decompression.
  4. Regex-extract the edgedl tarball URL from the decompressed JS.
  5. Validate the URL with a HEAD request before printing.

Prints the URL to stdout on success; prints errors to stderr and exits 1
on failure.
"""
import re
import sys

import requests

from typing import Optional


# The download page is an Angular SPA. The tarball URL lives inside the
# hashed main-*.js bundle, which changes filename on each deploy.
DOWNLOAD_PAGE = "https://antigravity.google/download/linux"
SITE_ROOT = "https://antigravity.google"

# Pattern to find the main JS bundle filename in the HTML.
MAIN_JS_PATTERN = re.compile(r'src="(main-[^"]+\.js)"')

# Pattern to find the tarball URL inside the JS bundle.
TARBALL_URL_PATTERN = re.compile(
    r'https://edgedl\.me\.gvt1\.com/[^"\'\\`\s]+Antigravity\.tar\.gz'
)

HEADERS = {
    "User-Agent": (
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
        "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    ),
    # Critical: the server returns gzip-compressed JS. Without this header
    # requests will receive raw gzip bytes and regex matching will fail.
    "Accept-Encoding": "gzip, deflate",
}


def scrape_url() -> Optional[str]:
    """Scrape the latest Linux tarball URL from antigravity.google."""

    try:
        # --- Step 1: Find the main JS bundle filename ---
        page_resp = requests.get(DOWNLOAD_PAGE, headers=HEADERS, timeout=15)
        page_resp.raise_for_status()

        js_match = MAIN_JS_PATTERN.search(page_resp.text)
        if not js_match:
            print("ERROR: Could not find main JS bundle in page HTML.",
                  file=sys.stderr)
            return None

        js_filename = js_match.group(1)
        # The JS file lives at the site root, not under /download/.
        js_url = f"{SITE_ROOT}/{js_filename}"

        # --- Step 2: Fetch and decompress the JS bundle ---
        js_resp = requests.get(js_url, headers=HEADERS, timeout=30)
        js_resp.raise_for_status()

        # --- Step 3: Extract the tarball URL ---
        tarball_match = TARBALL_URL_PATTERN.search(js_resp.text)
        if not tarball_match:
            print(f"ERROR: Tarball URL not found in {js_filename}.",
                  file=sys.stderr)
            return None

        url_candidate = tarball_match.group(0)

        # --- Step 4: Validate with a HEAD request ---
        try:
            head_resp = requests.head(
                url_candidate, timeout=15, allow_redirects=True
            )
            if head_resp.status_code != 200:
                print(
                    f"WARNING: HEAD request returned {head_resp.status_code} "
                    f"for {url_candidate}",
                    file=sys.stderr,
                )
        except requests.RequestException as exc:
            print(f"WARNING: HEAD validation failed: {exc}", file=sys.stderr)

        return url_candidate

    except requests.RequestException as exc:
        print(f"ERROR: Network request failed: {exc}", file=sys.stderr)
        return None


if __name__ == "__main__":
    latest_url = scrape_url()
    if latest_url:
        print(latest_url)
    else:
        sys.exit(1)
