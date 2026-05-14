# Windows Support — Architecture Notes

> **Status:** 📋 Planned
> **Last updated:** 2026-05-13

---

## Two Possible Paths

Windows users can run bash scripts through two environments. They have very different characteristics:

| Environment | Kernel | Effort | Compatibility |
|---|---|---|---|
| **WSL2** | Real Linux kernel (VM) | Low | Near-native Linux |
| **Git Bash** | Windows kernel (MSYS2 emulation) | High | Partial compatibility |

**Recommendation:** Target WSL2 first. Git Bash is a stretch goal with significant limitations.

---

## WSL2 (Windows Subsystem for Linux)

### Detection

Multiple reliable methods:

```bash
# Method 1: Kernel version (most common)
if uname -r | grep -qi microsoft; then
    IS_WSL=true
fi

# Method 2: Environment variable (cleanest)
if [ -n "$WSL_DISTRO_NAME" ]; then
    IS_WSL=true
    WSL_DISTRO="$WSL_DISTRO_NAME"  # e.g., "Ubuntu"
fi

# Method 3: Interop file
if [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
    IS_WSL=true
fi
```

**Recommended:** Use method 2 first (`$WSL_DISTRO_NAME`), fall back to method 1.

### Integration with `detect_platform()`

```bash
# Inside detect_platform(), after Linux distro detection:
if [ -n "$WSL_DISTRO_NAME" ]; then
    DISTRO_VARIANT="WSL"
fi
```

System info should show:
```
OS:   Ubuntu 24.04 (WSL) (x86_64)
Best: ★ System Repo (APT)
```

### What Works in WSL2

| Feature | Status | Notes |
|---|---|---|
| **APT install** | ✅ Works | If running Ubuntu/Debian WSL distro |
| **DNF install** | ✅ Works | If running Fedora WSL distro |
| **Tarball install** | ✅ Works | Standard Linux filesystem |
| **`gum` bootstrap** | ✅ Works | Standard Linux binary |
| **`sha256sum`** | ✅ Works | GNU Coreutils |
| **`~/.bashrc` PATH** | ✅ Works | Default shell is Bash in most WSL distros |
| **`.desktop` files** | ⚠️ Limited | No desktop environment by default |
| **Browser opening** | ⚠️ Special | See below |

### WSL-Specific Quirks

#### 1. Browser Opening

WSL has no native GUI browser. To open URLs, you can invoke Windows executables from WSL:

```bash
# Open URL in Windows default browser from WSL
if [ "$IS_WSL" = true ]; then
    cmd.exe /c start "$url" 2>/dev/null
    # OR
    wslview "$url"  # if wslu is installed
fi
```

**`wslu`** is a collection of utilities for WSL that includes `wslview` (opens files/URLs in Windows). It's available via `apt install wslu` on Ubuntu WSL.

#### 2. File System Performance

WSL2 has poor performance when accessing Windows files (`/mnt/c/`). The installation should go to the Linux filesystem (`~/.local/lib/`), which is fast. Our default paths already do this.

#### 3. `.desktop` Files

WSL2 doesn't have a desktop environment by default, so `.desktop` files are useless. **Skip `.desktop` creation when WSL is detected:**

```bash
if [ "$DISTRO_VARIANT" != "WSL" ] && [ "$PLATFORM" != "Darwin" ]; then
    # Create .desktop file
fi
```

#### 4. `uname -s` is Still "Linux"

WSL2 reports `uname -s` as `Linux` (because it IS Linux). Detection must use the kernel version string or environment variables, not the OS name.

---

## Git Bash (MSYS2)

### Detection

```bash
if [ "$OSTYPE" = "msys" ] || [ "$OSTYPE" = "cygwin" ]; then
    IS_GITBASH=true
fi
```

Or:
```bash
if uname -s | grep -qi MINGW; then
    IS_GITBASH=true
fi
```

### Tool Availability

| Tool | Available? | Notes |
|---|---|---|
| `curl` | ✅ Yes | Bundled with Git for Windows + Windows native |
| `tar` | ✅ Yes | Bundled with Git for Windows + Windows native |
| `sha256sum` | ✅ Yes | Part of GNU Coreutils bundle |
| `bash` | ✅ Yes | MSYS2 bash |
| `gum` | ❓ Unknown | Charm releases include `Windows_x86_64.zip` — needs testing |
| `mktemp` | ✅ Yes | Works |
| `chmod +x` | ⚠️ No-op | Windows doesn't track Unix permissions |

### Major Limitations

1. **No package manager:** No `apt`, `dnf`, or `brew` (Homebrew doesn't support Git Bash). Only tarball install path is viable.

2. **No Linux binary compatibility:** Antigravity (the IDE) is a Linux application. It cannot run natively in Git Bash. The user would need to download the Windows version separately.

3. **Path differences:** Git Bash uses `/c/Users/...` paths. The install location would need to be Windows-friendly.

4. **Line ending issues:** CRLF vs LF can break scripts. `core.autocrlf` Git setting affects this.

5. **No `xdg-open`:** Use `start` command or `cmd.exe /c start`:
   ```bash
   start "https://example.com"
   ```

### Feasibility Assessment

> [!WARNING]
> **Git Bash support has very limited value.** If a user can install Git Bash, they can install WSL2, which provides a much better experience. Git Bash should only be a detection + redirect:

```bash
if [ "$IS_GITBASH" = true ]; then
    echo "⚠️  Git Bash detected. For the best experience, use WSL2."
    echo "   Install WSL: https://learn.microsoft.com/en-us/windows/wsl/install"
    echo ""
    echo "   If you already have WSL, open it and run this command there."
    exit 0
fi
```

---

## Testing Checklists

### WSL2

- [ ] Detection works (`$WSL_DISTRO_NAME` method)
- [ ] `--help` and `--version` work
- [ ] `--demo-ui` sandbox works
- [ ] APT install works (Ubuntu WSL)
- [ ] Tarball install works
- [ ] `gum` downloads and runs
- [ ] `.desktop` file is NOT created
- [ ] Browser opening works via `wslview` or `cmd.exe /c start`
- [ ] System info shows "Ubuntu 24.04 (WSL)"

### Git Bash

- [ ] Detection works (`$OSTYPE` method)
- [ ] Script shows WSL redirect message and exits gracefully
- [ ] No crashes or syntax errors
