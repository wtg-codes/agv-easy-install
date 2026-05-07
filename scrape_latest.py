import re
import requests
import sys

def scrape_url():
    # Attempting to find the latest URL by checking common sources or patterns
    # Since the main page is dynamic, we'll try to find it via a known update channel if possible.
    # For now, we use a heuristic or check for the latest version in the JS assets if we can find them.

    url = "https://antigravity.google/download/linux"
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    }

    try:
        response = requests.get(url, headers=headers, timeout=10)
        content = response.text

        # Look for the JS file that might contain the URL
        js_files = re.findall(r'src="(main-[^"]+\.js)"', content)
        for js_file in js_files:
            js_url = f"https://antigravity.google/download/{js_file}"
            js_resp = requests.get(js_url, timeout=10)
            found = re.search(r'https://edgedl\.me\.gvt1\.com/[^"]+Antigravity\.tar\.gz', js_resp.text)
            if found:
                return found.group(0)

        # If not found in JS, try searching for the pattern in the whole page just in case
        found = re.search(r'https://edgedl\.me\.gvt1\.com/[^"]+Antigravity\.tar\.gz', content)
        if found:
            return found.group(0)

    except Exception as e:
        print(f"Error scraping: {e}")

    return None

if __name__ == "__main__":
    latest_url = scrape_url()
    if latest_url:
        print(latest_url)
    else:
        # Fallback: if we can't scrape it, we keep the current one or return an error
        # In a real scenario, we might have a more robust way to find it.
        sys.exit(1)
