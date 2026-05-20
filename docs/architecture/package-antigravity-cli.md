# Package Specification: Antigravity CLI

> **Status:** ✅ Active
> **Last updated:** 2026-05-20
> **Parent:** [implementation_plan.md](implementation_plan.md)

---

## Overview

The **Antigravity CLI** (`agy`) is a command-line utility used to interface with the Antigravity developer environment, run course labs, submit tasks, and verify agent statuses.

---

## Package Metadata

| Property | Value / Description |
|---|---|
| **Package Name** | `antigravity-cli` |
| **Binary Name** | `agy` |
| **Execution** | Native pre-compiled Go/Rust executable |
| **Distribution** | Standalone direct binary download |

---

## Target Installation Directories

The CLI executable is installed to user-space:
- **Executable Path:** `~/.local/bin/agy`
- **Configuration Directory:** `~/.config/antigravity-cli/`
- **Settings File:** `~/.gemini/antigravity-cli/settings.json` (holds active MCP servers, tokens, and user state)

---

## Dependencies & Integrations

The CLI has no heavy runtime dependencies, operating as a compiled standalone binary.

### Key Integration Points
1. **GitHub API Integration:** Leverages the GitHub Personal Access Token configured in `~/.config/environment.d/antigravity-mcp.conf` (or via git config) to interact with class repositories and submit lab outputs.
2. **Local Agent Bridge:** Can coordinate actions with a running local Antigravity IDE instance using a local web socket loop.

---

## Maintenance & Version Rules

1. **Standalone Script Loader:**
   - The CLI installer downloads the package directly from release assets using platform-aware OS-architecture URLs.
2. **Version Constancy:**
   - The default CLI version constant (`DEFAULT_CLI_VERSION`) in `src/00_config.sh` must be kept in sync with the latest released CLI package version.
3. **Automated Verification:**
   - The `agy --version` output is validated during execution phase gates to ensure it matches expectations.
