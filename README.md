<p align="center">
  <img src="https://img.shields.io/badge/platform-linux%20%7C%20macOS%20(beta)%20%7C%20WSL%20(beta)%20%7C%20ChromeOS%20(beta)-blue?style=flat-square" alt="Platform">
  <a href="https://github.com/wtg-codes/agv-easy-install/actions/workflows/nightly-update.yml"><img src="https://img.shields.io/github/actions/workflow/status/wtg-codes/agv-easy-install/nightly-update.yml?label=nightly%20sync&style=flat-square" alt="Nightly Sync"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green?style=flat-square" alt="MIT License"></a>
</p>

# 🚀 AGV Easy Install

> **Unofficial Google Antigravity setup by [wtg-codes](https://github.com/wtg-codes).**
> One command. Any shell. We get you coding.

<p align="center">
  <img src="docs/images/main_menu.png" alt="AGV Easy Install — Main Menu" width="680">
</p>

---

## ⚡ Quick Start

**Option A — Interactive Guide (recommended for students)**

👉 **[Open the Interactive Installation Guide](https://wtg-codes.github.io/agv-easy-install/)**

**Option B — Direct install**

```bash
curl -fSsL "https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/antigravity-manager.sh" | bash
```

**Option C — Advanced (Headless / Automation)**

The script supports non-interactive execution for CI/CD and provisioning tools:
```bash
# Auto-detect and install without prompts
curl -fSsL "https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/antigravity-manager.sh" | bash -s -- --auto

# Or force a specific method
bash antigravity-manager.sh --install-brew
bash antigravity-manager.sh --install-repo
bash antigravity-manager.sh --install-binary
bash antigravity-manager.sh --install-cli    # Headless Antigravity CLI install

# Additional options
bash antigravity-manager.sh --verbose  # Print detailed logs
bash antigravity-manager.sh --quiet    # Suppress non-error output
bash antigravity-manager.sh --check    # Verify existing installation health
bash antigravity-manager.sh --update   # Force update of this manager script
bash antigravity-manager.sh --remove   # Uninstall
bash antigravity-manager.sh --json     # Output single JSON object on completion
bash antigravity-manager.sh --demo-ui  # Sandbox mode — test the UI without installing
```

---

## 🖥️ What You'll See

The installer uses a hierarchical menu system — pick a category, then choose your method.

**1. Choose your install method →** The ★ marks the recommended option for your system.

<p align="center">
  <img src="docs/images/install_submenu.png" alt="Install method sub-menu" width="680">
</p>

**2. Cleanup options →** Uninstall, manage the script, or try Demo UI mode.

<p align="center">
  <img src="docs/images/cleanup_submenu.png" alt="Cleanup sub-menu" width="680">
</p>

**3. Demo UI (sandbox mode)** — Test the full installation experience without changing your system.

<p align="center">
  <img src="docs/images/mock_install.png" alt="Demo UI mock install flow" width="680">
</p>

---

## 🏗️ Architecture

```mermaid
graph LR
    A["🖥️ User Terminal"] -->|"curl \| bash"| B("antigravity-manager.sh")
    B -->|"Option 1"| C["🍺 Homebrew"]
    B -->|"Option 2"| D["📦 APT / DNF"]
    B -->|"Option 3"| E["📁 Official Binary (.tar.gz, .dmg, .exe)"]
```

The installer detects your OS and package manager, then recommends the best method automatically.

---

## 💻 Supported Platforms

We support **Linux (APT/DNF/Atomic)**, **macOS (Homebrew/DMG)**, and **Windows (WSL2/Native)**.
The script automatically detects your environment and recommends the best installation path.

For detailed platform-specific architecture, see our documentation:
- [Linux Support Notes](docs/architecture/platform-linux.md)
- [macOS Support Notes (Beta)](docs/architecture/platform-macos.md)
- [Windows & WSL2 Notes (Beta)](docs/architecture/platform-windows.md)
- [ChromeOS Crostini Notes (Beta)](docs/architecture/platform-crostini.md)

<details>
<summary>📥 Manual binary downloads</summary>

These links are updated nightly by our CI pipeline. If they fail, run the installer script instead—it always scrapes the latest URL.

- **Linux (x64)**: [Antigravity.tar.gz](https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/linux-x64/Antigravity.tar.gz)
- **macOS (Apple Silicon)**: [Antigravity.dmg (arm64)](https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/darwin-arm/Antigravity.dmg)
- **macOS (Intel)**: [Antigravity.dmg (x64)](https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/darwin-x64/Antigravity.dmg)
- **Windows (x64)**: [Antigravity.exe](https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/windows-x64/Antigravity.exe)
- **Windows (ARM64)**: [Antigravity.exe](https://storage.googleapis.com/antigravity-public/antigravity-hub/2.0.0-6324554176528384/windows-arm/Antigravity.exe)

</details>

---

## 📁 Install Locations (Official Binary)

| Item | Path |
|---|---|
| Application | `~/.local/lib/antigravity` (Linux) / `/Applications` (macOS) |
| Binary | `~/.local/bin/antigravity` |
| Manager | `~/.local/bin/antigravity-manager` |
| Workspace | `~/my-antigravity-work` |

---

## 🛠️ Troubleshooting & Architecture

Having issues? Curious how the installer works under the hood or what's on the roadmap?

- **[Implementation Plan & Architecture](docs/architecture/implementation_plan.md)**
- **[Homebrew Install Details](docs/architecture/install-homebrew.md)**
- **[System Repo Install Details](docs/architecture/install-repo.md)**
- **[Official Binary Install Details](docs/architecture/install-tarball.md)**

If `curl` fails, ensure you have an active internet connection. If the `gum` UI fails to download, the script gracefully falls back to a plain text menu.

---

## 📝 Changelog

See **[CHANGELOG.md](CHANGELOG.md)** for release history and recent updates.

---

## 🤝 Contributing

See **[CONTRIBUTING.md](CONTRIBUTING.md)** for guidelines.
All changes must pass `bash tests/run_gates.sh --phase all` before merging.

---

<p align="center">
  <sub>MIT License · Made for students · <a href="https://wtg-codes.github.io/agv-easy-install/">Interactive Guide</a></sub>
</p>
