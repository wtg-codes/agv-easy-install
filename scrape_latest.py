"""
Scrapes the latest Antigravity binary URLs from antigravity.google.

Strategy:
  1. Fetch the download page HTML to find the hashed main JS bundle.
  2. Fetch the JS bundle and regex-extract all edgedl URLs.
  3. Filter the URLs by platform (Linux x64, macOS x64/arm64, Windows x64/arm64).
  4. Stream-download each binary to compute its SHA-256 hash.
  5. Output a JSON object containing URLs and hashes.
"""
import re
import sys
import json
import hashlib
import requests

from typing import Dict, Optional


DOWNLOAD_PAGE = "https://antigravity.google/download/linux"
SITE_ROOT = "https://antigravity.google"

MAIN_JS_PATTERN = re.compile(r'src="(main-[^"]+\.js)"')
EDGEDL_URL_PATTERN = re.compile(r'https://edgedl\.me\.gvt1\.com/[^"\'\\`\s]+')

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
    "Accept-Encoding": "gzip, deflate",
}

TARGETS = {
    "LINUX_X64": "linux-x64/Antigravity.tar.gz",
    "MAC_X64": "darwin-x64/Antigravity.dmg",
    "MAC_ARM64": "darwin-arm/Antigravity.dmg",
    "WIN_X64": "windows-x64/Antigravity.exe",
    "WIN_ARM64": "windows-arm64/Antigravity.exe",
}

def compute_sha256(url: str) -> str:
    """Stream downloads the URL and computes its SHA-256 hash."""
    h = hashlib.sha256()
    with requests.get(url, stream=True, timeout=30) as r:
        r.raise_for_status()
        for chunk in r.iter_content(chunk_size=8192):
            h.update(chunk)
    return h.hexdigest()

def scrape_urls() -> Optional[Dict[str, Dict[str, str]]]:
    try:
        # Step 1: Find the main JS bundle
        page_resp = requests.get(DOWNLOAD_PAGE, headers=HEADERS, timeout=15)
        page_resp.raise_for_status()

        js_match = MAIN_JS_PATTERN.search(page_resp.text)
        if not js_match:
            print("ERROR: Could not find main JS bundle in page HTML.", file=sys.stderr)
            return None

        js_url = f"{SITE_ROOT}/{js_match.group(1)}"

        # Step 2: Fetch JS and extract all URLs
        js_resp = requests.get(js_url, headers=HEADERS, timeout=30)
        js_resp.raise_for_status()

        all_urls = set(EDGEDL_URL_PATTERN.findall(js_resp.text))
        
        # Step 3: Map platforms to URLs
        results = {}
        for url in all_urls:
            if "/stable/" not in url:
                continue
            for platform, suffix in TARGETS.items():
                if url.endswith(suffix):
                    results[platform] = {"url": url}

        # Validate we found all targets
        if len(results) != len(TARGETS):
            print(f"ERROR: Only found {len(results)} of {len(TARGETS)} targets.", file=sys.stderr)
            return None

        # Step 4: Compute hashes
        for platform, data in results.items():
            print(f"Computing SHA-256 for {platform}...", file=sys.stderr)
            try:
                data["sha256"] = compute_sha256(data["url"])
            except requests.RequestException as e:
                print(f"ERROR: Failed to download {platform}: {e}", file=sys.stderr)
                return None

        return results

    except requests.RequestException as exc:
        print(f"ERROR: Network request failed: {exc}", file=sys.stderr)
        return None

if __name__ == "__main__":
    data = scrape_urls()
    if data:
        print(json.dumps(data, indent=2))
    else:
        sys.exit(1)
