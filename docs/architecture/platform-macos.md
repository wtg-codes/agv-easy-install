# macOS Support — Architecture Notes

> **Status:** ⚠️ Beta — code paths exist but need end-to-end validation.
> **Last updated:** 2026-05-13

---

## Current State

The script already has macOS-aware code in several modules. This document catalogs what exists, what's missing, and specific implementation guidance.

### What Already Works (Code Exists)

| Feature | File | Status |
|---|---|---|
| `PLATFORM=Darwin` detection | `src/20_platform.sh:7` | ✅ Implemented |
| `gum` bootstrap: `Darwin_arm64` + `Darwin_x86_64` | `src/10_utils.sh:62-65` | ✅ Implemented |
| Skip `.desktop` file on macOS | `src/30_installers.sh:131` | ✅ Implemented |
| `brew install --cask antigravity` for macOS | `src/30_installers.sh:6-8` | ✅ Implemented |
| `brew uninstall --cask` removal | `src/30_installers.sh:176,198` | ✅ Implemented |
| Tarball blocked on macOS (Linux-only) | `src/30_installers.sh:75` | ✅ Implemented |
| Chrome detection on macOS | `src/20_platform.sh:74` | ✅ Path: `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` |
| macOS system info in banner | `src/20_platform.sh:54+` | ✅ Uses `sw_vers` |

### What's Broken or Missing

#### 1. `sha256sum` doesn't exist on macOS

**Impact:** Tarball install will fail (but tarball is already blocked on macOS, so low impact for now).

**The Fix:**
```bash
# In src/30_installers.sh, replace direct sha256sum call with:
if command -v sha256sum > /dev/null 2>&1; then
    SHA_CMD="sha256sum"
elif command -v shasum > /dev/null 2>&1; then
    SHA_CMD="shasum -a 256"
else
    log_error "No SHA-256 utility found."
    return 1
fi

# Then use: echo "$KNOWN_SHA256  $file" | $SHA_CMD -c -
```

> [!NOTE]
> Since tarball is blocked on macOS anyway, this is mainly for future-proofing and for correctness on other platforms that might use `shasum`.

#### 2. PATH setup assumes `~/.bashrc`

**Impact:** macOS default shell is Zsh since Catalina (2019). Writing to `~/.bashrc` does nothing for most users.

**The Fix:** Detect the user's shell and write to the correct profile:
```bash
case "$SHELL" in
    */zsh)  PROFILE="$HOME/.zprofile" ;;
    */bash) PROFILE="$HOME/.bashrc" ;;
    *)      PROFILE="$HOME/.profile" ;;
esac
```

**Files to change:** `src/30_installers.sh` (PATH setup), `src/40_ui.sh` (mock references `~/.bashrc`).

#### 3. Easter egg (`xdg-open`) not yet implemented

**Impact:** The AGENTS.md mentions an undocumented `"Google"` input that should open the Course Catalog. The code for this doesn't exist yet in the current source modules.

**The Fix:** When implementing, use platform-aware opener:
```bash
open_url() {
    local url="$1"
    if [ "$PLATFORM" = "Darwin" ]; then
        open "$url"
    else
        xdg-open "$url" 2>/dev/null || echo "Visit: $url"
    fi
}
```

#### 4. `save_manager_locally()` path may not be ideal

**Impact:** `~/.local/bin` is not a standard macOS path. It works if the user adds it to PATH, but Homebrew users expect tools in `/opt/homebrew/bin` or `/usr/local/bin`.

**Recommendation:** Keep `~/.local/bin` for consistency but ensure the PATH setup (item 2 above) covers it.

---

## macOS-Specific Quirks for Bash Scripts

| Quirk | Detail |
|---|---|
| **Default shell is Zsh** | Since Catalina (2019). Scripts run with `bash` still work, but profile files differ. |
| **`sha256sum` missing** | Use `shasum -a 256` instead. |
| **No `xdg-open`** | Use `open` (native macOS command). |
| **No `.desktop` files** | macOS uses `.app` bundles. Our script already skips `.desktop` creation on Darwin. |
| **`uname -m` returns `arm64`** | Not `aarch64` like Linux. Our gum bootstrap already handles this. |
| **Homebrew paths differ** | Apple Silicon: `/opt/homebrew/bin`. Intel: `/usr/local/bin`. |
| **`sed` is BSD** | `-i` requires `''` argument (e.g., `sed -i '' 's/foo/bar/'`). GNU sed doesn't. |
| **`readlink` is BSD** | No `-f` flag. Use `realpath` or custom function if needed. |
| **System Integrity Protection (SIP)** | Can't write to `/usr/bin/` or `/usr/local/` without disabling SIP. Use `~/.local/bin/` or Homebrew paths. |

---

## Testing Checklist

> Run these on a real Mac (or GitHub Actions macOS runner).

### Minimum Viability (must pass for Beta → Stable)

- [ ] `bash antigravity-manager.sh --help` — no errors
- [ ] `bash antigravity-manager.sh --version` — prints version
- [ ] `bash antigravity-manager.sh --demo-ui` — full sandbox loop works
- [ ] `gum` downloads and runs (arm64 on Apple Silicon, x86_64 on Intel)
- [ ] Homebrew install path: `brew install antigravity` (if formula exists)
- [ ] Homebrew removal: `brew uninstall --cask antigravity`
- [ ] No `.desktop` file created
- [ ] Chrome detected at `/Applications/Google Chrome.app/...`
- [ ] PATH added to `~/.zprofile` (not `~/.bashrc`)

### Stretch Goals

- [ ] `open` used instead of `xdg-open` for URLs
- [ ] Easter egg works (when implemented)
- [ ] `save_manager_locally()` creates working `antigravity-manager` command
- [ ] GitHub Actions macOS runner smoke test in CI
