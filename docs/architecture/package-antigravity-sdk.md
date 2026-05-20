# Package Specification: Antigravity Python SDK

> **Status:** ✅ Active
> **Last updated:** 2026-05-20
> **Parent:** [implementation_plan.md](implementation_plan.md)

---

## Overview

The **Antigravity Python SDK** (`google-antigravity`) provides programmatic Python interfaces to interact with Antigravity agents, control code analysis modules, and write custom extension scripts.

---

## Package Metadata

| Property | Value / Description |
|---|---|
| **PyPI Package Name** | `google-antigravity` |
| **Import Namespace** | `google_antigravity` |
| **Distribution** | Python Package Index (PyPI) |
| **Dependencies** | `python3` (>= 3.9), `pip` |

---

## Target Installation Directories

The SDK is installed via `pip3` and resides in the system or virtual environment's site-packages:
- **Global User-space:** `~/.local/lib/python3.*/site-packages/google_antigravity/`
- **Virtual Environment:** `<venv>/lib/python3.*/site-packages/google_antigravity/`

---

## Dependencies & Integrations

The SDK works in Python runtimes and interfaces with:
1. **Local IDE Engine:** Sends commands to the IDE server backend (typically on port `8080` or dynamically mapped).
2. **Google Cloud Services:** Can optionally authenticate to vertex/gemini backends using standard Google Cloud SDK components.

---

## Maintenance & Version Rules

1. **Installer Method:**
   - The installer uses `python3 -m pip install --upgrade google-antigravity` to install or update the package.
2. **Version Syncing:**
   - The default SDK version constant (`DEFAULT_SDK_VERSION`) in `src/00_config.sh` is defined as `latest` or a pinned semver.
3. **Agent Rule:**
   - Any architectural changes to the SDK client interface must be documented in this package specification.
