import os

with open('docs/index.html', 'r') as f:
    html = f.read()

# 4.1
html = html.replace('lucide@latest', 'lucide@0.292.0')

# 4.2, 4.3, 4.4
meta_tags = """    <title>Install Google Antigravity</title>
    <meta name="description" content="A cross-platform installation script for Google Antigravity.">
    <meta property="og:title" content="Install Google Antigravity">
    <meta property="og:description" content="A cross-platform installation script for Google Antigravity.">
    <link rel="icon" href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2290%22>🚀</text></svg>">"""
html = html.replace('    <title>Install Google Antigravity</title>', meta_tags)

# 4.5
html = html.replace('title="Save as PDF"', 'title="Save as PDF" aria-label="Export to PDF"')
html = html.replace('title="Copy to clipboard"', 'title="Copy to clipboard" aria-label="Copy install command to clipboard"')

# 4.6
html = html.replace('<details id="sourceDetails"', '<details id="sourceDetails" aria-expanded="false"')
html = html.replace('function fetchSource() {', 'function fetchSource() {\n            const details = document.getElementById("sourceDetails");\n            details.setAttribute("aria-expanded", details.hasAttribute("open") ? "false" : "true");')

# 4.7
html = html.replace('sourceEl.textContent = text;', '// SECURITY: We use textContent instead of innerHTML to prevent XSS attacks when injecting fetched source code.\n                sourceEl.textContent = text;')

# 4.8 & 4.9
old_options = """                        <ul class="space-y-3">
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-emerald-500/20 text-emerald-400 font-mono rounded text-xs border border-emerald-500/30">1</span>
                                <div>
                                    <strong class="text-slate-200">Standard Repository (Recommended)</strong>
                                    <p class="text-slate-400 text-xs mt-0.5">Installs the app securely via your system's package manager so it stays updated automatically.</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-amber-500/20 text-amber-400 font-mono rounded text-xs border border-amber-500/30">2</span>
                                <div>
                                    <strong class="text-slate-200">Standalone Tarball (Fallback)</strong>
                                    <p class="text-slate-400 text-xs mt-0.5">If Option 1 fails, use this. It downloads the IDE to a local folder (no sudo required).</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-slate-800 text-slate-400 font-mono rounded text-xs border border-slate-700">3</span>
                                <div>
                                    <strong class="text-slate-200">Install/Update this Manager script</strong>
                                    <p class="text-slate-400 text-xs mt-0.5">Saves this menu to your computer so you can access it anytime by typing <code>antigravity-manager</code>.</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-slate-800 text-slate-400 font-mono rounded text-xs border border-slate-700">4</span>
                                <div>
                                    <strong class="text-slate-200">Remove/Uninstall setup</strong>
                                    <p class="text-slate-400 text-xs mt-0.5">Safely deletes the IDE and shortcuts (keeps your actual code safe).</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-slate-800 text-slate-400 font-mono rounded text-xs border border-slate-700">5</span>
                                <div>
                                    <strong class="text-slate-200">Remove Manager script</strong>
                                    <p class="text-slate-400 text-xs mt-0.5">Deletes the <code>antigravity-manager</code> tool from your system.</p>
                                </div>
                            </li>
                        </ul>"""

new_options = """                        <p class="text-slate-400 text-xs mt-2 mb-2">Options [1-7] mapped as follows:</p>
                        <ul class="space-y-3">
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-emerald-500/20 text-emerald-400 font-mono rounded text-xs border border-emerald-500/30">1</span>
                                <div>
                                    <strong class="text-slate-200">Standard Repository (Linux Only)</strong>
                                    <p class="text-slate-400 text-xs mt-0.5">Installs via APT/DNF so it stays updated automatically (requires sudo).</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-blue-500/20 text-blue-400 font-mono rounded text-xs border border-blue-500/30">2</span>
                                <div>
                                    <strong class="text-slate-200">Homebrew (macOS/Linux)</strong>
                                    <p class="text-slate-400 text-xs mt-0.5">Uses Homebrew to install the app cleanly. Great for macOS users.</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-amber-500/20 text-amber-400 font-mono rounded text-xs border border-amber-500/30">3</span>
                                <div>
                                    <strong class="text-slate-200">Standalone Tarball (Fallback)</strong>
                                    <p class="text-slate-400 text-xs mt-0.5">Downloads the IDE to a local folder (no sudo required).</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-slate-800 text-slate-400 font-mono rounded text-xs border border-slate-700">4</span>
                                <div>
                                    <strong class="text-slate-200">Install/Update this Manager script</strong>
                                    <p class="text-slate-400 text-xs mt-0.5">Saves this menu so you can access it via <code>antigravity-manager</code>.</p>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-slate-800 text-slate-400 font-mono rounded text-xs border border-slate-700">5</span>
                                <div>
                                    <strong class="text-slate-200">Remove/Uninstall setup</strong>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-slate-800 text-slate-400 font-mono rounded text-xs border border-slate-700">6</span>
                                <div>
                                    <strong class="text-slate-200">Remove Manager script</strong>
                                </div>
                            </li>
                            <li class="flex items-start gap-3">
                                <span class="flex-shrink-0 flex items-center justify-center w-6 h-6 bg-slate-800 text-slate-400 font-mono rounded text-xs border border-slate-700">7</span>
                                <div>
                                    <strong class="text-slate-200">Cancel</strong>
                                </div>
                            </li>
                        </ul>"""
html = html.replace(old_options, new_options)

with open('docs/index.html', 'w') as f:
    f.write(html)

# README.md
readme = """# Google Antigravity Easy Install

[![CI](https://github.com/wtg-codes/agv-easy-install/actions/workflows/nightly-update.yml/badge.svg)](https://github.com/wtg-codes/agv-easy-install/actions/workflows/nightly-update.yml)

A cross-platform installation script for Google Antigravity.

## 🚀 Quick Install (Recommended)

The easiest way to get started is to follow our **[Interactive Installation Guide](https://wtg-codes.github.io/agv-easy-install/)**.

Alternatively, run this command in your terminal:

```bash
curl -fSsL "https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/antigravity-manager.sh" | bash
```

### Homebrew Users (macOS/Linux)
If you prefer Homebrew, you can just run the script and select Option 2, or install directly if the formula is available:
```bash
brew install --cask antigravity
```

## 🏗️ Architecture

```mermaid
graph LR
    A[User Terminal] -->|curl| B(antigravity-manager.sh)
    B -->|Option 1| C{Linux System Repo}
    B -->|Option 2| D{Homebrew}
    B -->|Option 3| E{Standalone Tarball}
```

## 💻 Supported Platforms

| Platform | Recommended Method | Fallback |
|----------|-------------------|----------|
| macOS | Homebrew | Tarball |
| Ubuntu/Debian | APT | Tarball |
| Fedora/RHEL | DNF | Tarball |
| Other Linux | Tarball | Tarball |

## 🛠️ Troubleshooting
If you encounter `curl: (23) Failed writing body`, it usually means you need to update `curl` or try downloading the file manually.
If `antigravity` is not found after install, try reopening your terminal or running `source ~/.bashrc`.

## 🗺️ Roadmap
- [x] Phase 1: Basic setup and repo structure
- [x] Phase 2: Shell script hardening and Homebrew support
- [x] Phase 3: CI/CD fixes for nightly updates
- [x] Phase 4: Documentation polish
- [ ] Future: Windows support (Winget/Chocolatey)

## 📝 Changelog
See [CHANGELOG.md](CHANGELOG.md) for detailed history or check git commit logs.

## 📁 Locations
- **Application:** `~/.local/lib/antigravity`
- **Binary:** `~/.local/bin/antigravity`
- **Manager:** `~/.local/bin/antigravity-manager`
- **Workspace:** `~/my-antigravity-work`
"""

with open('README.md', 'w') as f:
    f.write(readme)
