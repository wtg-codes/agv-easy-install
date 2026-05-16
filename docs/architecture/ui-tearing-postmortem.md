# Postmortem: macOS TUI Tearing and Auto-Downgrade Bug

## What Happened
1. **The Core Issue:** On macOS Terminal.app, `gum filter` height calculation caused tearing and double-rendering of the top banner. When given too little height (e.g. `--height=6` or dynamically sized to just the options count), `gum filter` interacts poorly with macOS's alternate screen buffer, leading to scrolling artifacts and "ghosting" where the screen was cut off.
2. **The "Main Branch Return" Bug:** The user reported the fix worked locally on the branch but immediately broke again when merged to `main`. This occurred because `raw.githubusercontent.com` caches files for up to 5 minutes, so curl-piping the script immediately after merging downloaded the *old* `v0.2.5` payload with the bug still intact.

## Why Tests Didn't Catch It
1. **Virtual TTY Rendering Differences:** Our `pyte`-based testing framework (`test_ui_navigation.py`) uses a strict, logical `120x30` character grid that perfectly clears and updates lines. Real-world hardware-accelerated terminals like macOS Terminal.app have rendering quirks and scroll buffers that aren't perfectly simulated by `pty` + `pyte`. Tearing simply doesn't happen in a pure Python screen buffer.
2. **The Auto-Downgrade Test Bug:** The testing environment itself had a severe race condition/flaw. The mock session was running `bash antigravity-manager.sh --demo-ui`. Because it didn't pass the `--no-update` flag, the script's built-in auto-updater reached out to GitHub `main` branch, saw `v0.2.5` was the "authoritative" version, downloaded it, overwrote the local file, and restarted. The tests were continuously re-testing the broken production branch instead of the local branch!

## How We Fixed It
1. **Increased Fixed Height:** Changed `gum filter` to use a hardcoded `--height=8`. This gives exactly enough breathing room for all 4 options without needing internal scrolling, bypassing the macOS tearing bug entirely.
2. **Version Bump (0.2.7):** Bumped to `v0.2.7` specifically so users and developers can definitively prove which version is running to defeat GitHub's CDN caching. 
3. **Test Framework Fix:** Added `--no-update` to the `TerminalSession` spawn arguments in `test_ui_navigation.py` to prevent the test suite from auto-downgrading the script during local development.
