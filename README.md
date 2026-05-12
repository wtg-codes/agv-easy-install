# Google Antigravity Easy Install

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
