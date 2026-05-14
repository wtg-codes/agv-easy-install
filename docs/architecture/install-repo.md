# Install Method: System Repo (APT/DNF) — Architecture Notes

> **Last updated:** 2026-05-13
> **Source:** `src/30_installers.sh:34-84` (`install_repo`)

---

## Overview

System Repo installs Antigravity through the OS package manager. This is the most "native" option — packages are managed by APT or DNF, receive system updates, and integrate cleanly with the package database. **Requires `sudo`.**

---

## How It Works

### Flow

```
install_repo()
├── sudo -v                     # Verify sudo access
├── detect_distro()             # Read /etc/os-release
├── Case: ubuntu|debian|kali|linuxmint
│   ├── Fetch GPG key → /etc/apt/keyrings/
│   ├── Add .list file → /etc/apt/sources.list.d/
│   ├── apt update && apt install -y antigravity
│   └── On failure: rollback (remove .list file)
├── Case: fedora|rhel|centos|amzn
│   ├── Write .repo file → /etc/yum.repos.d/
│   ├── dnf makecache && dnf install -y antigravity
│   └── On failure: rollback (remove .repo file)
├── Case: unsupported
│   └── Fall back to tarball (Linux) or exit (macOS)
├── configure_chrome_path()
└── Write state file            # {"method": "repo", ...}
```

---

## APT Path (Debian/Ubuntu Family)

### Repository Setup

```bash
# 1. Create keyring directory
sudo mkdir -p /etc/apt/keyrings

# 2. Fetch and dearmor the GPG key
curl -fSsL "https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg" | \
    sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg

# 3. Add the repository (uses signed-by — modern best practice)
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] \
    https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ \
    antigravity-debian main" | \
    sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null

# 4. Install
sudo apt update
sudo apt install -y antigravity
```

### Security Notes

- **`signed-by` is used** — the GPG key is scoped to this repo only (not global trust)
- **Key stored in `/etc/apt/keyrings/`** — modern best practice (not deprecated `apt-key`)
- **`gpg --dearmor`** — converts ASCII-armored key to binary format as required by APT

### Rollback on Failure

If `apt install` fails, the script removes the `.list` file to prevent broken `apt update` on future runs:
```bash
sudo rm -f /etc/apt/sources.list.d/antigravity.list
```

---

## DNF Path (Fedora/RHEL Family)

### Repository Setup

```bash
# Write the repo file directly
sudo tee /etc/yum.repos.d/antigravity.repo > /dev/null << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL

# Install
sudo dnf makecache
sudo dnf install -y antigravity
```

### Security Notes

> [!WARNING]
> **`gpgcheck=0` is currently set.** This means packages are NOT cryptographically verified. The upstream Artifact Registry does not provide GPG-signed RPMs. This is documented in the code with a comment explaining the limitation.

**Future improvement:** When the upstream adds GPG signing:
```ini
gpgcheck=1
gpgkey=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/RPM-GPG-KEY
```

### Rollback on Failure

```bash
sudo rm -f /etc/yum.repos.d/antigravity.repo
```

---

## Removal

```bash
# State file says method=repo

# APT:
sudo apt remove -y antigravity
sudo rm -f /etc/apt/sources.list.d/antigravity.list

# DNF:
sudo dnf remove -y antigravity
sudo rm -f /etc/yum.repos.d/antigravity.repo
```

Also removes: `$APP_DIR`, `$BIN_DIR/antigravity`, `.desktop` files.

---

## Platform Compatibility

| Platform | Package Manager | Status |
|---|---|---|
| Ubuntu 22.04+ | APT | ✅ Tested |
| Debian 12+ | APT | ✅ Expected to work |
| Linux Mint | APT | ✅ Expected to work |
| Kali Linux | APT | ✅ Expected to work |
| Fedora 40+ | DNF | ✅ Tested |
| RHEL 9+ | DNF | ⚠️ Expected to work (untested) |
| CentOS Stream | DNF | ⚠️ Expected to work (untested) |
| Amazon Linux 2023 | DNF | ⚠️ Expected to work (untested) |
| macOS | N/A | ❌ Not applicable |
| Atomic Linux | N/A | ❌ Not applicable (`rpm-ostree` ≠ DNF) |

---

## Open Issues

1. **`gpgcheck=0` on RPM path** — packages are not GPG-verified
2. **No DEB822 format** — we use the older one-line `.list` format. Ubuntu 24.04+ prefers `.sources` files, but our format still works.
3. **No automatic repo key rotation** — if the GPG key changes, the user must re-run the installer
4. **Sudo timing** — `sudo -v` may time out on slow networks before download completes
