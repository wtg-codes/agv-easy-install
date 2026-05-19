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

TARGET_PATTERNS = {
    "LINUX_X64": re.compile(r'/linux-x64/Antigravity.*\.tar\.gz$'),
    "MAC_X64": re.compile(r'/darwin-x64/Antigravity.*\.dmg$'),
    "MAC_ARM64": re.compile(r'/darwin-arm/Antigravity.*\.dmg$'),
    "WIN_X64": re.compile(r'/windows-x64/Antigravity.*\.exe$'),
    "WIN_ARM64": re.compile(r'/windows-arm64/Antigravity.*\.exe$'),
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
        
        # Step 3: Map platforms to URLs by sorting semantic versions
        VERSION_PATTERN = re.compile(r'/stable/([0-9.]+)-[0-9]+/')
        versions_map = {}
        for url in all_urls:
            if "/stable/" not in url:
                continue
            match = VERSION_PATTERN.search(url)
            if not match:
                continue
            version_str = match.group(1)
            try:
                version_tuple = tuple(int(x) for x in version_str.split('.'))
            except ValueError:
                continue

            if version_tuple not in versions_map:
                versions_map[version_tuple] = []
            versions_map[version_tuple].append(url)

        # Sort versions to find the latest version that has all targets
        sorted_versions = sorted(versions_map.keys(), reverse=True)
        
        results = {}
        for ver in sorted_versions:
            ver_urls = versions_map[ver]
            candidate_results = {}
            for url in ver_urls:
                for platform, pattern in TARGET_PATTERNS.items():
                    if pattern.search(url):
                        candidate_results[platform] = {"url": url}
            
            if len(candidate_results) == len(TARGET_PATTERNS):
                results = candidate_results
                break

        # Validate we found all targets
        if len(results) != len(TARGET_PATTERNS):
            print(f"ERROR: Only found {len(results)} of {len(TARGET_PATTERNS)} targets.", file=sys.stderr)
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
