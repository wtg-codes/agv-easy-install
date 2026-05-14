# Crostini (ChromeOS) Support — Architecture Notes

> **Status:** 📋 Planned
> **Last updated:** 2026-05-13

---

## What is Crostini?

Crostini is ChromeOS's built-in Linux container support. It runs a Debian-based Linux container (default name: `penguin`) inside a VM managed by ChromeOS. Users get a full Linux terminal with `apt`, `bash`, and standard GNU tools.

**Key insight:** From our script's perspective, Crostini looks like a standard Debian Linux system. The tarball and APT install paths should work with minimal changes.

---

## Detection

### Recommended Method

```bash
if [ -f /dev/.cros_milestone ]; then
    IS_CROSTINI=true
    CROS_MILESTONE=$(cat /dev/.cros_milestone)
fi
```

The file `/dev/.cros_milestone` is placed by ChromeOS integration tools and contains the ChromeOS version number.

### Alternative Checks

| Method | Command | Reliability |
|---|---|---|
| **`/dev/.cros_milestone`** | `test -f /dev/.cros_milestone` | ✅ Best — ChromeOS-specific |
| **Hostname** | `hostname` returns `penguin` | ⚠️ Can be changed by user |
| **`$BROWSER` variable** | `echo $BROWSER` → `/usr/bin/garcon-url-handler` | ⚠️ Only if set by ChromeOS |

### Integration with `detect_platform()`

Add to `src/20_platform.sh`:
```bash
# Inside detect_platform(), after Linux distro detection:
if [ -f /dev/.cros_milestone ]; then
    DISTRO_VARIANT="Crostini"
    CROS_MILESTONE=$(cat /dev/.cros_milestone)
fi
```

This should appear in the system info dashboard as:
```
OS:   Debian 12 (Crostini, ChromeOS M130) (x86_64)
```

---

## What Works

| Feature | Expected Behavior | Notes |
|---|---|---|
| **APT install** | ✅ Works | Standard Debian — `apt` is available |
| **Tarball install** | ✅ Works | Standard Linux filesystem |
| **`gum` bootstrap** | ✅ Works | `Linux_x86_64` binary; ARM Chromebooks need `Linux_arm64` |
| **`sha256sum`** | ✅ Works | GNU Coreutils installed by default |
| **`~/.bashrc` PATH setup** | ✅ Works | Default shell is Bash on Debian |
| **`.desktop` file** | ⚠️ Partial | File can be created, but ChromeOS app launcher integration varies |

---

## Known Quirks

### 1. Browser Opening

Crostini uses `garcon-url-handler` to bridge URLs from the Linux container to the ChromeOS browser. This means:

- `xdg-open` works if the ChromeOS integration sets `BROWSER=/usr/bin/garcon-url-handler`
- **The easter egg (if implemented) should work** — `xdg-open` will route through garcon
- **Antigravity itself** may need a browser path configured. Chrome is NOT installed inside the container — it runs on the ChromeOS host.

**Recommendation:** When Chrome is not found inside the container, check for `garcon-url-handler`:
```bash
if [ -f /dev/.cros_milestone ] && [ -x /usr/bin/garcon-url-handler ]; then
    log_info "Crostini detected — ChromeOS browser will be used via garcon."
    # Skip Chrome detection; the IDE should use garcon-url-handler or the user's host Chrome
fi
```

### 2. ARM Chromebooks

Many Chromebooks use ARM processors (MediaTek, Qualcomm). The `gum` bootstrap already handles `arm64` via `uname -m`, but this should be tested on an actual ARM Chromebook.

### 3. Storage

Crostini has limited storage by default. The tarball install (~500MB) may be significant on a 32GB Chromebook. Consider warning the user about disk usage.

### 4. `.desktop` Files

ChromeOS can integrate Linux `.desktop` files into its app launcher, but the behavior is inconsistent:
- Files in `~/.local/share/applications/` are sometimes picked up
- Icon rendering depends on ChromeOS version
- **Recommendation:** Still create the `.desktop` file (same as standard Debian), but don't guarantee it appears in the ChromeOS launcher

---

## Testing Checklist

- [ ] `bash antigravity-manager.sh --help` — no errors
- [ ] `bash antigravity-manager.sh --version` — prints version
- [ ] `bash antigravity-manager.sh --demo-ui` — sandbox works
- [ ] `detect_platform()` identifies Crostini + shows ChromeOS milestone
- [ ] APT install works (if apt repo is available)
- [ ] Tarball install works
- [ ] `gum` downloads correct binary (x86_64 or arm64 depending on Chromebook)
- [ ] `xdg-open` routes through `garcon-url-handler`
- [ ] Antigravity launches and can connect to a browser

---

## Implementation Priority

**Low effort, medium value.** Since Crostini is Debian, most code already works. The main work is:
1. Add detection in `detect_platform()`
2. Handle Chrome-not-found gracefully (suggest garcon)
3. Test on a real Chromebook
