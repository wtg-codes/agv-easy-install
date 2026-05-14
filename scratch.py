import requests, re, hashlib, sys, json
HEADERS = {"User-Agent": "Mozilla/5.0", "Accept-Encoding": "gzip, deflate"}
r1 = requests.get("https://antigravity.google/download/linux", headers=HEADERS)
js_match = re.search(r'src="(main-[^"]+\.js)"', r1.text)
if js_match:
    r2 = requests.get("https://antigravity.google/" + js_match.group(1), headers=HEADERS)
    urls = set(re.findall(r'https://edgedl\.me\.gvt1\.com/[^"\'\\`\s]+', r2.text))
    # filter to only stable releases and specific platforms
    targets = {
        "LINUX_X64": "linux-x64/Antigravity.tar.gz",
        "MAC_X64": "darwin-x64/Antigravity.dmg",
        "MAC_ARM64": "darwin-arm/Antigravity.dmg",
        "WIN_X64": "windows-x64/Antigravity.exe",
        "WIN_ARM64": "windows-arm64/Antigravity.exe"
    }
    results = {}
    for url in urls:
        if "stable/" not in url: continue
        for key, suffix in targets.items():
            if url.endswith(suffix):
                results[key] = {"url": url}
    print(json.dumps(results, indent=2))
