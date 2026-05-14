# ChromeOS (Crostini) — Architecture Notes

> **Status:** 📋 Planned (Beta support exists via Tarball fallback)
> **Last updated:** 2026-05-13
> **Parent:** [implementation_plan.md](implementation_plan.md)

---

## Overview

Crostini is the official framework that allows ChromeOS to run Linux applications. 
It uses a highly secure, nested architecture: ChromeOS runs a custom KVM monitor (`crosvm`), which boots a minimal, read-only Linux VM (`Termina`), which in turn runs an LXC container (usually named `penguin`, running Debian).

Antigravity installs inside the `penguin` LXC container but integrates with the ChromeOS host via Crostini's bridge daemons.

---

## Detection Mechanism

```bash
# src/20_platform.sh (Planned detection)
if [ -f /dev/.cros_milestone ]; then
    PLATFORM="Crostini"
fi
```
The existence of `/dev/.cros_milestone` inside the Linux container is the canonical, officially documented way to detect if a script is running inside a ChromeOS Crostini environment.

---

## Architecture: The Crostini Bridge

Because the Antigravity CLI runs inside an isolated LXC container, it cannot directly draw windows on the ChromeOS screen or open URLs in the ChromeOS browser without help from bridge daemons.

### 1. Sommelier (The Wayland Proxy)
When Antigravity launches Google Chrome or an Electron app, the GUI must escape the container.
- **Sommelier** is a Wayland proxy compositor running *inside* the container.
- It intercepts the Wayland (or X11 via XWayland) draw commands from the app.
- It forwards these commands over a high-performance `virtio-gpu` channel to **Exo** (the Wayland compositor running on the ChromeOS host).
- *Result:* The Linux app appears as a native window on the ChromeOS desktop.

### 2. Garcon (The Integration Daemon)
Garcon is the daemon responsible for `.desktop` file synchronization and URL handling.

- **Desktop Shortcuts:** When Antigravity creates `google-antigravity.desktop` in `~/.local/share/applications/`, Garcon detects the file change. It parses the file and sends the icon and execution command to the ChromeOS host, making it appear in the ChromeOS App Launcher.
- **URL Handling:** If Antigravity runs `xdg-open "https://example.com"`, Garcon intercepts the request and forwards it to the host. ChromeOS then opens the URL in the native, host-side Chrome browser (not a browser inside the container).

---

## ARM vs x86_64 Considerations

Many popular Chromebooks use ARM processors (e.g., MediaTek, Qualcomm) rather than Intel/AMD (x86_64).

*   **Tarball Architecture:** The `detect_platform` script successfully detects `aarch64` and downloads the correct ARM-compiled `gum` UI binary.
*   **Homebrew Constraints:** While Homebrew works on ARM Linux, many third-party tools do not provide pre-compiled "bottles" for ARM Linux, leading to massive, slow compilations from source on low-power Chromebook CPUs.
*   **Recommendation:** On ARM Chromebooks, the **System Repo (APT)** or **Tarball** methods are strongly preferred over Homebrew to save battery and time.

---

## Chrome Detection Quirks

ChromeOS does not typically install a Linux version of Google Chrome inside the Crostini container, because the host OS *is* Chrome.

However, Antigravity requires a Chromium-based browser to run its agentic automation. 
*   **Current State:** A user on Crostini must manually install the Linux version of Chrome or Chromium inside the container (`sudo apt install chromium`) for Antigravity to work.
*   **Future Fix:** We may need to investigate if Crostini allows driving the host's Chrome browser via a forwarded debugging port, though this is likely blocked by ChromeOS security policies.

---

## Essential Crostini Skills & Tools

1. **`vmc` and `vsh` (Host Side):** Access the `crosh` terminal (Ctrl+Alt+T) to manage the VM. Use `vmc start termina` to manage the VM directly.
2. **`sommelier -X`**: Force an application to run via XWayland instead of native Wayland (useful for debugging blurry Electron apps).
3. **`journalctl -u garcon`**: Check the Garcon logs inside the container if a `.desktop` shortcut fails to appear in the ChromeOS launcher.
4. **`update-alternatives --config x-www-browser`**: Ensure Garcon is set as the default browser handler inside the container so URLs open on the host.
