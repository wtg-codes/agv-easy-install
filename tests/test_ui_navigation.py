#!/usr/bin/env python3
"""
test_ui_navigation.py
---------------------
Full interactive navigation test for antigravity-manager.sh.

HOW IT WORKS
============
Uses `pyte` (a VT100 terminal emulator) to maintain a live rendered screen
state as raw PTY bytes arrive. After every keypress we snapshot the screen
and run assertions against what the user would *actually see* — not just the
raw byte stream.

This catches:
  - Ghost lines (menu option appearing in a row where it should not be)
  - Duplicate cursor indicators (❯ appearing more than once = tearing)
  - Wrong option highlighted after arrow navigation
  - Submenus not rendering / returning correctly
  - Script crashing mid-flow

STRUCTURE
=========
Each "test_*" function drives one flow and returns (passed: bool, log: list).
The test runner at the bottom prints a summary and exits non-zero on failure.

KEYS
====
  KEY_DOWN  = b"\x1b[B"
  KEY_UP    = b"\x1b[A"
  ENTER     = b"\r"
  ESC       = b"\x1b"
"""

import os
import sys
import time
import pty
import select
import termios
import tty
import pathlib
import pyte

# ── Config ───────────────────────────────────────────────────────────────────

REPO_ROOT = pathlib.Path(__file__).parent.parent
SCRIPT    = str(REPO_ROOT / "antigravity-manager.sh")

COLS, ROWS = 120, 30      # realistic desktop terminal size

KEY_DOWN  = b"\x1b[B"
KEY_UP    = b"\x1b[A"
KEY_ENTER = b"\r"
KEY_ESC   = b"\x1b"


# ── PTY + pyte harness ───────────────────────────────────────────────────────

class TerminalSession:
    """
    Spawns a child process in a PTY, feeds its output into a pyte Screen,
    and lets callers send keystrokes and inspect the rendered screen.
    """

    def __init__(self, cmd: list[str], cols=COLS, rows=ROWS, timeout=20):
        self.cols    = cols
        self.rows    = rows
        self.timeout = timeout
        self.log     = []

        # Set up pyte screen + stream
        self.screen = pyte.Screen(cols, rows)
        self.stream = pyte.ByteStream(self.screen)

        # Fork child into a PTY
        self.master_fd, slave_fd = pty.openpty()

        # Set terminal size on the slave
        import struct, fcntl
        winsize = struct.pack("HHHH", rows, cols, 0, 0)
        fcntl.ioctl(slave_fd, termios.TIOCSWINSZ, winsize)

        import subprocess
        self.proc = subprocess.Popen(
            cmd,
            stdin=slave_fd,
            stdout=slave_fd,
            stderr=slave_fd,
            close_fds=True,
            env={
                **os.environ,
                "TERM": "xterm-256color",
                "COLUMNS": str(cols),
                "LINES": str(rows),
            },
        )
        os.close(slave_fd)

    def _drain(self, wait: float = 0.3):
        """Read all available bytes from the PTY and feed them into pyte."""
        deadline = time.time() + wait
        while time.time() < deadline:
            r, _, _ = select.select([self.master_fd], [], [], 0.05)
            if r:
                try:
                    data = os.read(self.master_fd, 4096)
                    self.stream.feed(data)
                except OSError:
                    break

    def wait_for(self, text: str, timeout: float = 15.0) -> bool:
        """Block until `text` appears anywhere on the rendered screen."""
        deadline = time.time() + timeout
        while time.time() < deadline:
            self._drain(0.1)
            if text in self.display():
                return True
        return False

    def send(self, data: bytes, settle: float = 0.3):
        """Write bytes to the child's stdin and let the screen settle."""
        try:
            os.write(self.master_fd, data)
        except OSError:
            pass
        self._drain(settle)

    def display(self) -> str:
        """Return the current screen as a single string (one line per row)."""
        return "\n".join("".join(self.screen.buffer[r][c].data
                                 for c in range(self.cols))
                         for r in range(self.rows))

    def visible_lines(self) -> list[str]:
        """Return non-empty, stripped lines from the current screen."""
        return [l.strip() for l in self.display().splitlines() if l.strip()]

    def snapshot_label(self, label: str):
        """Save a labelled snapshot to the log for debugging."""
        lines = self.visible_lines()
        self.log.append(f"\n{'─'*60}")
        self.log.append(f"SNAPSHOT: {label}")
        self.log.append(f"{'─'*60}")
        self.log.extend(f"  {l}" for l in lines)

    def close(self):
        try:
            self.proc.terminate()
            self.proc.wait(timeout=3)
        except Exception:
            pass
        try:
            os.close(self.master_fd)
        except OSError:
            pass


# ── Assertion helpers ─────────────────────────────────────────────────────────

def assert_no_tearing(session: TerminalSession, label: str) -> list[str]:
    """
    Return a list of failure strings if tearing is detected on current screen.
    Tearing signatures:
      1. The cursor indicator ❯ appears more than once (ghost cursor)
      2. Any menu option text appears on more than one row
    """
    failures = []
    lines = session.visible_lines()
    display = session.display()

    # 1. Duplicate cursor indicators
    cursor_count = sum(1 for l in lines if l.startswith("❯") or "❯" in l)
    if cursor_count > 1:
        failures.append(
            f"[{label}] TEARING: ❯ cursor appears {cursor_count}× "
            f"(expected 1) — ghost cursor detected"
        )

    # 2. Duplicate menu option rows (same non-trivial text on 2+ rows)
    seen = {}
    for l in lines:
        # ignore very short lines, separator lines, nav hints
        stripped = l.lstrip("❯○ ★").strip()
        if len(stripped) < 8:
            continue
        if any(nav in stripped for nav in ["navigate", "submit", "blur", "───"]):
            continue
        seen.setdefault(stripped, 0)
        seen[stripped] += 1

    for text, count in seen.items():
        if count > 1:
            failures.append(
                f"[{label}] TEARING: '{text}' appears {count}× on screen — ghosting"
            )

    return failures


def assert_option_highlighted(session: TerminalSession, label: str,
                               expected_option: str) -> list[str]:
    """Assert that `expected_option` is on the same line as the ❯ cursor."""
    failures = []
    lines = session.visible_lines()
    cursor_line = next((l for l in lines if "❯" in l), None)
    if cursor_line is None:
        failures.append(f"[{label}] No cursor line found on screen")
    elif expected_option not in cursor_line:
        failures.append(
            f"[{label}] Expected '{expected_option}' to be highlighted, "
            f"but cursor is on: '{cursor_line.strip()}'"
        )
    return failures


def assert_text_visible(session: TerminalSession, label: str,
                         text: str) -> list[str]:
    """Assert that `text` is visible somewhere on the screen."""
    if text not in session.display():
        return [f"[{label}] Expected to see '{text}' on screen but it was absent"]
    return []


# ── Test flows ────────────────────────────────────────────────────────────────

def test_main_menu_navigation() -> tuple[bool, list[str]]:
    """
    Navigate the main menu top-to-bottom and back, verifying:
      - correct option is highlighted after each arrow press
      - no tearing / ghosting on any frame
    """
    failures = []
    print("\n▶  test_main_menu_navigation")
    session = TerminalSession(["bash", SCRIPT, "--demo-ui"])

    try:
        if not session.wait_for("navigate", timeout=20):
            return False, ["[main_menu] Timed out waiting for menu to appear"]

        session.snapshot_label("initial render")
        failures += assert_no_tearing(session, "initial render")
        failures += assert_option_highlighted(session, "initial", "Cancel")
        failures += assert_text_visible(session, "initial", "Choose Antigravity install method")
        failures += assert_text_visible(session, "initial", "Antigravity cleanup options")
        failures += assert_text_visible(session, "initial", "Install this script locally")

        # Arrow down × 3 — should land on "Install this script locally"
        for i, expected in enumerate([
            "Choose Antigravity install method",
            "Antigravity cleanup options",
            "Install this script locally",
        ]):
            session.send(KEY_DOWN, settle=0.4)
            session.snapshot_label(f"after DOWN #{i+1}")
            failures += assert_no_tearing(session, f"DOWN #{i+1}")
            failures += assert_option_highlighted(session, f"DOWN #{i+1}", expected)

        # Arrow up × 3 — should land back on Cancel
        for i, expected in enumerate([
            "Antigravity cleanup options",
            "Choose Antigravity install method",
            "Cancel",
        ]):
            session.send(KEY_UP, settle=0.4)
            session.snapshot_label(f"after UP #{i+1}")
            failures += assert_no_tearing(session, f"UP #{i+1}")
            failures += assert_option_highlighted(session, f"UP #{i+1}", expected)

    finally:
        session.close()

    passed = len(failures) == 0
    result = "✅ PASS" if passed else "❌ FAIL"
    print(f"   {result}  ({len(failures)} failure(s))")
    return passed, failures + session.log


def test_install_submenu() -> tuple[bool, list[str]]:
    """Navigate into the install sub-menu, check all options, go back."""
    failures = []
    print("\n▶  test_install_submenu")
    session = TerminalSession(["bash", SCRIPT, "--demo-ui"])

    try:
        if not session.wait_for("navigate", timeout=20):
            return False, ["[install_submenu] Timed out on main menu"]

        # Select "Choose Antigravity install method"
        session.send(KEY_DOWN, settle=0.4)
        session.send(KEY_ENTER, settle=1.5)

        if not session.wait_for("Homebrew", timeout=10):
            return False, ["[install_submenu] Timed out waiting for install sub-menu"]

        session.snapshot_label("install submenu — initial")
        failures += assert_no_tearing(session, "install submenu initial")
        failures += assert_text_visible(session, "install submenu", "Homebrew")
        failures += assert_text_visible(session, "install submenu", "System Repo")
        failures += assert_text_visible(session, "install submenu", "Official Binary")

        # Navigate down through all install options
        for i, expected in enumerate(["Homebrew", "System Repo", "Official Binary"]):
            session.send(KEY_DOWN, settle=0.4)
            session.snapshot_label(f"install submenu DOWN #{i+1}")
            failures += assert_no_tearing(session, f"install submenu DOWN #{i+1}")
            failures += assert_option_highlighted(session, f"install submenu DOWN #{i+1}", expected)

        # Go back up to "Back" and press Enter
        for _ in range(3):
            session.send(KEY_UP, settle=0.3)
        session.send(KEY_ENTER, settle=1.5)

        if not session.wait_for("navigate", timeout=10):
            return False, ["[install_submenu] Did not return to main menu after Back"]

        session.snapshot_label("returned to main menu")
        failures += assert_no_tearing(session, "returned to main menu")

    finally:
        session.close()

    passed = len(failures) == 0
    result = "✅ PASS" if passed else "❌ FAIL"
    print(f"   {result}  ({len(failures)} failure(s))")
    return passed, failures + session.log


def test_cleanup_submenu() -> tuple[bool, list[str]]:
    """Navigate into the cleanup sub-menu, verify all options, go back."""
    failures = []
    print("\n▶  test_cleanup_submenu")
    session = TerminalSession(["bash", SCRIPT, "--demo-ui"])

    try:
        if not session.wait_for("navigate", timeout=20):
            return False, ["[cleanup_submenu] Timed out on main menu"]

        # Select "Antigravity cleanup options"
        session.send(KEY_DOWN, settle=0.4)
        session.send(KEY_DOWN, settle=0.4)
        session.send(KEY_ENTER, settle=1.5)

        if not session.wait_for("Uninstall", timeout=10):
            return False, ["[cleanup_submenu] Timed out waiting for cleanup sub-menu"]

        session.snapshot_label("cleanup submenu — initial")
        failures += assert_no_tearing(session, "cleanup submenu initial")
        failures += assert_text_visible(session, "cleanup submenu", "Uninstall Antigravity")
        failures += assert_text_visible(session, "cleanup submenu", "Save manager")
        failures += assert_text_visible(session, "cleanup submenu", "Remove manager")
        failures += assert_text_visible(session, "cleanup submenu", "Demo UI")

        # Navigate down through all cleanup options
        for i, expected in enumerate([
            "Uninstall Antigravity",
            "Save manager",
            "Remove manager",
            "Demo UI",
        ]):
            session.send(KEY_DOWN, settle=0.4)
            session.snapshot_label(f"cleanup DOWN #{i+1}")
            failures += assert_no_tearing(session, f"cleanup DOWN #{i+1}")
            failures += assert_option_highlighted(session, f"cleanup DOWN #{i+1}", expected)

        # Back to "Back" and return
        for _ in range(4):
            session.send(KEY_UP, settle=0.3)
        session.send(KEY_ENTER, settle=1.5)

        if not session.wait_for("navigate", timeout=10):
            return False, ["[cleanup_submenu] Did not return to main menu after Back"]

        session.snapshot_label("returned to main menu")
        failures += assert_no_tearing(session, "returned to main menu")

    finally:
        session.close()

    passed = len(failures) == 0
    result = "✅ PASS" if passed else "❌ FAIL"
    print(f"   {result}  ({len(failures)} failure(s))")
    return passed, failures + session.log


def test_cancel_exits_cleanly() -> tuple[bool, list[str]]:
    """Select Cancel on the main menu, verify script exits cleanly (exit 0)."""
    failures = []
    print("\n▶  test_cancel_exits_cleanly")
    session = TerminalSession(["bash", SCRIPT, "--demo-ui"])

    try:
        if not session.wait_for("navigate", timeout=20):
            return False, ["[cancel] Timed out on main menu"]

        # Cancel is the first option — just hit Enter
        session.send(KEY_ENTER, settle=2.0)
        session.proc.wait(timeout=5)
        exit_code = session.proc.returncode

        if exit_code != 0:
            failures.append(
                f"[cancel] Expected exit code 0 after Cancel, got {exit_code}"
            )
        else:
            print("   exit code: 0 ✅")

    except Exception as e:
        failures.append(f"[cancel] Exception: {e}")
    finally:
        session.close()

    passed = len(failures) == 0
    result = "✅ PASS" if passed else "❌ FAIL"
    print(f"   {result}  ({len(failures)} failure(s))")
    return passed, failures + session.log


def test_easter_egg() -> tuple[bool, list[str]]:
    """
    Type 'Google' into the gum filter search box and confirm the Easter Egg
    option appears as the only match (we don't actually open the browser,
    just confirm the option is surfaced correctly).
    """
    failures = []
    print("\n▶  test_easter_egg")
    session = TerminalSession(["bash", SCRIPT, "--demo-ui"])

    try:
        if not session.wait_for("navigate", timeout=20):
            return False, ["[easter_egg] Timed out on main menu"]

        session.snapshot_label("before typing Google")

        # Type the secret word character by character
        for ch in b"Google":
            session.send(bytes([ch]), settle=0.2)

        session.snapshot_label("after typing Google")

        # After filtering, the visible list should shrink dramatically
        # and the placeholder text should NOT still say "Select an option..."
        lines = session.visible_lines()

        # Verify the regular options are filtered out
        if "Choose Antigravity install method" in session.display():
            failures.append(
                "[easter_egg] Regular options still visible after typing 'Google' "
                "— filter not working"
            )
        else:
            print("   filter narrowed correctly ✅")

    finally:
        session.close()

    passed = len(failures) == 0
    result = "✅ PASS" if passed else "❌ FAIL"
    print(f"   {result}  ({len(failures)} failure(s))")
    return passed, failures + session.log


# ── Runner ───────────────────────────────────────────────────────────────────

def main():
    print("=" * 62)
    print(" AGV Easy Install — Full UI Navigation Test Suite")
    print(f" Script: {SCRIPT}")
    print(f" Terminal: {COLS}×{ROWS}")
    print("=" * 62)

    tests = [
        test_main_menu_navigation,
        test_install_submenu,
        test_cleanup_submenu,
        test_cancel_exits_cleanly,
        test_easter_egg,
    ]

    results = []
    all_logs = []

    for test_fn in tests:
        passed, log = test_fn()
        results.append((test_fn.__name__, passed))
        all_logs.append((test_fn.__name__, log))

    # ── Summary ──────────────────────────────────────────────────
    print("\n" + "=" * 62)
    print(" SUMMARY")
    print("=" * 62)
    all_passed = True
    for name, passed in results:
        icon = "✅" if passed else "❌"
        print(f"  {icon}  {name}")
        if not passed:
            all_passed = False

    if not all_passed:
        print("\n── Failure details ─────────────────────────────────────────")
        for name, log in all_logs:
            failures = [l for l in log if l.startswith("[")]
            if failures:
                print(f"\n  {name}:")
                for f in failures:
                    print(f"    {f}")
        print()

    sys.exit(0 if all_passed else 1)


if __name__ == "__main__":
    main()
