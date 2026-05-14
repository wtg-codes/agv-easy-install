# Windows (WSL2 & Git Bash) — Architecture Notes

> **Status:** 📋 Planned
> **Last updated:** 2026-05-13
> **Parent:** [implementation_plan.md](implementation_plan.md)

---

## Overview

Windows support for Antigravity relies on its Unix-compatibility layers. There are two primary environments where a user might attempt to run the Antigravity installer on Windows: **WSL2** (Windows Subsystem for Linux) and **Git Bash** (MSYS2).

Our architectural strategy handles these two environments very differently:
1. **WSL2:** Treat as native Linux.
2. **Git Bash:** Redirect the user to WSL2.

---

## 1. WSL2 Architecture (Supported)

WSL2 runs a true Linux kernel inside a lightweight Hyper-V virtual machine. From Antigravity's perspective, this is a standard Linux installation.

### Detection Mechanism

The `detect_platform` script identifies WSL by checking the kernel release string:
```bash
if grep -q "microsoft" /proc/version 2>/dev/null; then
    IS_WSL="yes"
fi
```

### Installation Flow
If a user runs the installer inside an Ubuntu WSL2 instance, the script detects `ubuntu` and automatically defaults to the **System Repo (APT)** method, just like native Linux.

### The 9P Protocol Bottleneck
WSL2 uses the **9P Protocol** to share files across the OS boundary (between NTFS and EXT4). This protocol introduces massive latency for heavy I/O operations (like `npm install` or executing agentic searches over large repos).

> [!IMPORTANT]
> **Best Practice:** Antigravity users on Windows *must* clone their repositories and run the agent inside the WSL filesystem (`/home/user/project`), **not** on the Windows mount (`/mnt/c/Users/...`). Running Antigravity against a project in `/mnt/c/` will result in severe performance degradation.

### Interoperability & `.exe` Execution
Antigravity can leverage WSL2's built-in interoperability. If the agent needs to open a file or URL on the host Windows machine, it can directly invoke Windows executables from the Linux shell:
```bash
# Antigravity can open a URL in the native Windows browser
explorer.exe "https://example.com"
```
Tools like `wslview` (from `wslutilities`) can also be used as a wrapper to trigger default Windows applications.

---

## 2. Git Bash / MSYS2 (Not Supported)

Git Bash is a collection of GNU utilities ported to Windows via the **MSYS2** compatibility layer (based on Cygwin).

### Why Git Bash is Blocked
While Git Bash looks like Linux, it is fundamentally different:
- **No Native Linux Kernel:** It uses POSIX emulation. Unmodified Linux binaries (ELF format) will not run.
- **Faux Filesystem:** Its filesystem root (`/`) maps to a hidden directory inside `C:\Program Files\Git`, which lacks standard Linux structures (`/etc/os-release`, systemd, package managers).
- **Process Spawning:** Node.js or Python agents attempting to spawn child processes often fail or hang due to how MSYS2 handles POSIX `fork()` emulation.

### The Redirect Strategy
Rather than attempting to hack Antigravity to run natively on Windows via MSYS2, our architecture intercepts Git Bash executions and **hard-stops** the user, directing them to install WSL2.

**Planned Detection Logic:**
```bash
if [ "$(uname -o 2>/dev/null)" = "Msys" ] || [ "$(uname -s 2>/dev/null | cut -c 1-5)" = "MINGW" ]; then
    echo "ERROR: Git Bash / MSYS2 is not supported."
    echo "Please install WSL2 (wsl --install) and run this script from an Ubuntu terminal."
    exit 1
fi
```

This drastically reduces the project's maintenance surface area while pushing Windows users toward the Microsoft-recommended, performant development environment (WSL2).

---

## Essential Windows/WSL Skills

1. **`wsl --install`**: The single command required to provision a full Ubuntu environment on Windows.
2. **`wslpath`**: Convert paths between Windows format (`C:\`) and WSL format (`/mnt/c/`).
   * *Example:* `wslpath -w /home/user/file.txt`
3. **`explorer.exe .`**: Opens the current WSL Linux directory in the native Windows File Explorer via the `\\wsl.localhost\` network share.
