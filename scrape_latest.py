"""
Scrapes the latest Antigravity binary URLs from antigravity.google.
Also fetches available CLI and SDK versions.
"""
import sys
import json
import hashlib
import requests
from typing import Dict, Any, Optional

DOWNLOAD_PAGE = "https://antigravity.google/download/linux"
SITE_ROOT = "https://antigravity.google"
HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36",
    "Accept-Encoding": "gzip, deflate",
}

IDE_TARGETS = ["LINUX_X64", "MAC_X64", "MAC_ARM64", "WIN_X64", "WIN_ARM64"]

CLI_PLATFORMS = {
    "linux_amd64": ("linux-x64", "cli_linux_x64.tar.gz"),
    "darwin_arm64": ("darwin-arm", "cli_mac_arm64.tar.gz"),
    "darwin_amd64": ("darwin-x64", "cli_mac_x64.tar.gz"),
    "windows_amd64": ("windows-x64", "cli_windows_x64.exe"),
    "windows_arm64": ("windows-arm", "cli_windows_arm64.exe"),
}

def compute_sha(url: str, hash_type: str = "sha256") -> str:
    """Stream downloads the URL and computes its hash (sha256 or sha512)."""
    h = hashlib.sha256() if hash_type == "sha256" else hashlib.sha512()
    with requests.get(url, stream=True, timeout=30) as r:
        r.raise_for_status()
        for chunk in r.iter_content(chunk_size=8192):
            h.update(chunk)
    return h.hexdigest()

def scrape_urls() -> Optional[Dict[str, Any]]:
    """Scrapes all available IDE, CLI, and SDK versions."""
    # Step 1: Load existing versions.json to cache already computed hashes
    cache = {}
    try:
        with open("versions.json", "r") as f:
            old_data = json.load(f)
            # Handle new structure
            if isinstance(old_data, dict):
                if "vibe" in old_data:
                    for ver, platforms in old_data["vibe"].items():
                        for plat, info in platforms.items():
                            if isinstance(info, dict) and "url" in info and "sha256" in info:
                                cache[info["url"]] = info["sha256"]
                if "ide" in old_data:
                    for ver, platforms in old_data["ide"].items():
                        for plat, info in platforms.items():
                            if isinstance(info, dict) and "url" in info and "sha256" in info:
                                cache[info["url"]] = info["sha256"]
                if "cli" in old_data:
                    for ver, platforms in old_data["cli"].items():
                        for plat, info in platforms.items():
                            if isinstance(info, dict) and "url" in info and "sha512" in info:
                                cache[info["url"]] = info["sha512"]
                # Handle old flat structure
                if "vibe" not in old_data and "ide" not in old_data and "cli" not in old_data:
                    for plat, info in old_data.items():
                        if isinstance(info, dict) and "url" in info and "sha256" in info:
                            cache[info["url"]] = info["sha256"]
    except Exception as e:
        print(f"INFO: Could not load existing versions.json for caching: {e}", file=sys.stderr)

    results = {
        "vibe": {},
        "ide": {},
        "cli": {},
        "sdk": {"latest": "0.1.0", "versions": ["0.1.0"]}
    }

    # Step 2: Fetch IDE releases
    print("Fetching active IDE releases from API...", file=sys.stderr)
    try:
        api_resp = requests.get("https://antigravity-auto-updater-974169037036.us-central1.run.app/releases", headers=HEADERS, timeout=15)
        api_resp.raise_for_status()
        ide_releases = api_resp.json()
    except Exception as e:
        print(f"ERROR: Failed to fetch IDE releases from API: {e}", file=sys.stderr)
        return None

    # Step 3: Verify and hash IDE releases
    for release in ide_releases[:5]:
        version = release["version"]
        exec_id = release["execution_id"]
        
        # Test candidate base URLs
        base_urls = [
            f"https://storage.googleapis.com/antigravity-public/antigravity-hub/{version}-{exec_id}/",
            f"https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/{version}-{exec_id}/"
        ]
        
        working_base = None
        for base in base_urls:
            test_url = f"{base}linux-x64/Antigravity.tar.gz"
            try:
                r = requests.head(test_url, timeout=5)
                if r.status_code == 200:
                    working_base = base
                    break
            except requests.RequestException:
                continue

        if not working_base:
            print(f"Skipping IDE version {version}: No working base URL found.", file=sys.stderr)
            continue

        print(f"Scraping IDE version {version}...", file=sys.stderr)
        version_data = {}
        valid = True
        
        for plat in IDE_TARGETS:
            plat_path = ""
            if plat == "LINUX_X64":
                plat_path = "linux-x64/Antigravity.tar.gz"
            elif plat == "MAC_X64":
                plat_path = "darwin-x64/Antigravity.dmg"
            elif plat == "MAC_ARM64":
                plat_path = "darwin-arm/Antigravity.dmg"
            elif plat == "WIN_X64":
                plat_path = "windows-x64/Antigravity.exe"
            elif plat == "WIN_ARM64":
                # Some releases use windows-arm, others windows-arm64
                plat_path = "windows-arm/Antigravity.exe"
                try:
                    r = requests.head(f"{working_base}{plat_path}", timeout=5)
                    if r.status_code != 200:
                        plat_path = "windows-arm64/Antigravity.exe"
                except requests.RequestException:
                    plat_path = "windows-arm64/Antigravity.exe"

            target_url = f"{working_base}{plat_path}"
            
            # Use cached hash or download
            if target_url in cache:
                sha = cache[target_url]
            else:
                print(f"  Computing SHA-256 for IDE {version} {plat}...", file=sys.stderr)
                try:
                    sha = compute_sha(target_url, "sha256")
                except Exception as e:
                    print(f"  WARNING: Failed to download/hash {target_url}: {e}", file=sys.stderr)
                    valid = False
                    break
            
            version_data[plat] = {"url": target_url, "sha256": sha}

        if valid:
            if version.startswith("2."):
                results["vibe"][version] = version_data
            else:
                results["ide"][version] = version_data

    # Step 4: Fetch CLI releases
    print("Fetching active CLI releases from API...", file=sys.stderr)
    try:
        cli_resp = requests.get("https://antigravity-cli-auto-updater-974169037036.us-central1.run.app/releases", headers=HEADERS, timeout=15)
        cli_resp.raise_for_status()
        cli_releases = cli_resp.json()
    except Exception as e:
        print(f"ERROR: Failed to fetch CLI releases: {e}", file=sys.stderr)
        return None

    for release in cli_releases[:5]:
        version = release["version"]
        exec_id = release["execution_id"]
        
        print(f"Scraping CLI version {version}...", file=sys.stderr)
        version_data = {}
        valid = True
        
        for plat, (plat_dir, filename) in CLI_PLATFORMS.items():
            target_url = f"https://storage.googleapis.com/antigravity-public/antigravity-cli/{version}-{exec_id}/{plat_dir}/{filename}"
            
            # Use cached hash or download
            if target_url in cache:
                sha = cache[target_url]
            else:
                print(f"  Computing SHA-512 for CLI {version} {plat}...", file=sys.stderr)
                try:
                    sha = compute_sha(target_url, "sha512")
                except Exception as e:
                    print(f"  WARNING: Failed to download/hash CLI {target_url}: {e}", file=sys.stderr)
                    valid = False
                    break
            
            version_data[plat] = {"url": target_url, "sha512": sha}

        if valid:
            results["cli"][version] = version_data

    # Step 5: Fetch SDK release from PyPI
    print("Fetching SDK release from PyPI...", file=sys.stderr)
    try:
        pypi_resp = requests.get("https://pypi.org/pypi/google-antigravity/json", headers=HEADERS, timeout=15)
        pypi_resp.raise_for_status()
        pypi_data = pypi_resp.json()
        latest_sdk = pypi_data["info"]["version"]
        all_sdk_versions = sorted(list(pypi_data["releases"].keys()), reverse=True)
        results["sdk"] = {
            "latest": latest_sdk,
            "versions": all_sdk_versions
        }
    except Exception as e:
        print(f"WARNING: Failed to fetch SDK release from PyPI: {e}", file=sys.stderr)

    return results

if __name__ == "__main__":
    data = scrape_urls()
    if data:
        print(json.dumps(data, indent=2))
    else:
        sys.exit(1)
