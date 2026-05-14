# Linux (DNF) — Fedora/RHEL Family

> **Status:** ✅ Tested
> **Last updated:** 2026-05-13
> **Parent:** [platform-linux.md](platform-linux.md)

---

## Supported Distributions

| `$DISTRO` (from `/etc/os-release`) | Name | Tested? |
|---|---|---|
| `fedora` | Fedora Workstation | ✅ 40+ |
| `rhel` | Red Hat Enterprise Linux | ⚠️ Expected (untested) |
| `centos` | CentOS Stream | ⚠️ Expected (untested) |
| `amzn` | Amazon Linux 2023 | ⚠️ Expected (untested) |
| `rocky` | Rocky Linux | ⚠️ Not in case statement |
| `alma` | AlmaLinux | ⚠️ Not in case statement |
| `ol` | Oracle Linux | ⚠️ Not in case statement |

> [!NOTE]
> Rocky Linux (`rocky`), AlmaLinux (`alma`), and Oracle Linux (`ol`) are RHEL clones and would work with DNF, but their `$ID` values are not in the current `case` match. They will fall through to tarball. To add support: `fedora|rhel|centos|amzn|rocky|alma|ol)`.

---

## Install Flow

```bash
# 1. Write .repo file
sudo tee /etc/yum.repos.d/antigravity.repo > /dev/null << EOL
[antigravity-rpm]
name=Antigravity RPM Repository
baseurl=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm
enabled=1
gpgcheck=0
EOL

# 2. Install
sudo dnf makecache
sudo dnf install -y antigravity
```

**Source:** `src/30_installers.sh:57-71`

---

## Security & Package Integrity

> [!WARNING]
> **`gpgcheck=0` is set.** RPM packages are NOT cryptographically verified. This is because the upstream Google Artifact Registry does not currently provide GPG-signed RPMs.

**What this means:** A compromised mirror or man-in-the-middle could serve a tampered package without DNF detecting it.

**Future Architecture Improvement:**
When the upstream Artifact Registry starts signing RPMs and repository metadata, the script must be updated to establish a secure chain of trust:

```ini
gpgcheck=1       # Verify individual package signatures
repo_gpgcheck=1  # Verify repomd.xml metadata signature
gpgkey=https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/RPM-GPG-KEY
```

---

## DNF5 vs DNF4 Architecture

Fedora 41+ ships **DNF5** as the default package manager. DNF5 is a complete C++ rewrite of the older Python-based DNF4, utilizing the unified `libdnf5` library for faster metadata processing and reduced memory footprint.

**Compatibility:**
Our installer is immune to the CLI syntax changes between DNF4 and DNF5 because we write the `.repo` configuration file directly to `/etc/yum.repos.d/antigravity.repo`. 
- **DNF4 method:** `dnf config-manager --add-repo`
- **DNF5 method:** `dnf config-manager addrepo`
- **Our method:** Direct file write (Works seamlessly across both).

*📚 Reference:* [DNF5 Project Documentation](https://dnf5.readthedocs.io/en/latest/)

---

## SELinux Considerations

Fedora and RHEL have SELinux enabled by default in enforcing mode.

- **System Repo (DNF):** Packages installed via DNF automatically receive the correct SELinux file contexts defined in the RPM spec. This is the safest approach.
- **Tarball (`~/.local/bin/`):** Binaries installed manually may lack proper contexts, causing SELinux to block execution (e.g., if Chrome tries to execute a shell script). 

**Fixing Tarball SELinux Issues:**
If a user installs via Tarball and faces "Permission Denied" errors despite having `+x` permissions, they should restore the context:

```bash
# Set the binary context
sudo semanage fcontext -a -t bin_t "$HOME/.local/bin/antigravity(/.*)?"
sudo restorecon -v "$HOME/.local/bin/antigravity"
```

> [!CAUTION]
> Do not use `chcon` to fix SELinux issues. `chcon` changes are temporary and will be wiped out during a system relabel or if `restorecon` is run on the home directory. Always use `semanage fcontext` for permanent rules.

---

## Removal & Cleanup

```bash
sudo dnf remove -y antigravity
sudo rm -f /etc/yum.repos.d/antigravity.repo
```

**Source:** `src/30_installers.sh:183-185`

### Rollback on Failure

If `dnf install` fails, the `.repo` file is immediately removed to prevent dependency resolution errors on future `dnf upgrade` commands:

```bash
sudo rm -f /etc/yum.repos.d/antigravity.repo
```

---

## Essential DNF Skills & Tools

1. **`dnf history`**: View past transactions. Use `dnf history undo <id>` to rollback a bad installation.
2. **`dnf repoquery -l antigravity`**: List all files provided by the installed RPM package.
3. **`ausearch -m AVC,USER_AVC -ts recent`**: Search recent SELinux denial logs if Antigravity fails to launch or execute a command.
4. **`audit2allow`**: Generates SELinux policy allow rules from logs (advanced troubleshooting tool).
