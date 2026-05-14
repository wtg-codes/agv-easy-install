# Linux (APT) — Debian/Ubuntu Family

> **Status:** ✅ Tested
> **Last updated:** 2026-05-13
> **Parent:** [platform-linux.md](platform-linux.md)

---

## Supported Distributions

| `$DISTRO` (from `/etc/os-release`) | Name | Tested? |
|---|---|---|
| `ubuntu` | Ubuntu | ✅ 22.04, 24.04 |
| `debian` | Debian | ✅ Expected (same APT path) |
| `kali` | Kali Linux | ⚠️ Expected (Debian-based) |
| `linuxmint` | Linux Mint | ⚠️ Expected (Ubuntu-based) |
| `pop` | Pop!_OS | ⚠️ Not in case statement — falls through to tarball |
| `elementary` | elementary OS | ⚠️ Not in case statement — falls through to tarball |

> [!NOTE]
> Pop!_OS (`pop`) and elementary OS (`elementary`) are Ubuntu-based and would work with APT, but their `$ID` values are not in the current `case` match. They will fall through to tarball. To add support, include them in the APT case: `ubuntu|debian|kali|linuxmint|pop|elementary)`.

---

## Install Flow & Best Practices

```bash
# 1. Create keyring directory
sudo mkdir -p /etc/apt/keyrings

# 2. Fetch and dearmor GPG key (scoped via signed-by)
curl -fSsL "https://us-central1-apt.pkg.dev/doc/repo-signing-key.gpg" | \
    sudo gpg --dearmor --yes -o /etc/apt/keyrings/antigravity-repo-key.gpg

# 3. Add repository source
echo "deb [signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg] \
    https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/ \
    antigravity-debian main" | \
    sudo tee /etc/apt/sources.list.d/antigravity.list > /dev/null

# 4. Install
sudo apt update
sudo apt install -y antigravity
```

**Source:** `src/30_installers.sh:40-55`

### Security: GPG Keyrings

- **`apt-key` is Deprecated:** Modern Debian/Ubuntu removes `apt-key` due to its global trust model (a key added there could authorize packages from *any* repo).
- **`signed-by` Scoping:** We explicitly bind our repository to its GPG key using `signed-by=/etc/apt/keyrings/antigravity-repo-key.gpg`. This prevents "key confusion" attacks.
- **`gpg --dearmor`:** APT requires keys in a binary format. If the upstream key is ASCII-armored (starts with `-----BEGIN PGP PUBLIC KEY BLOCK-----`), it must be piped through `gpg --dearmor`.

*📚 Reference:* [Debian Repository Format](https://wiki.debian.org/DebianRepository/Format)

---

## APT Pinning & Priority (`apt-cache policy`)

If a user has multiple repositories providing the `antigravity` package, APT uses a priority system (pinning) to decide which one to install. By default, installed packages have a priority of 100, and available uninstalled packages have 500.

You can inspect exactly how APT evaluates the Antigravity package:
```bash
apt-cache policy antigravity
```
*Output will show the candidate version and which repository it belongs to.*

Advanced users can create custom pinning rules in `/etc/apt/preferences.d/` if they need to force installations from specific channels.

*📚 Reference:* [AptPreferences(5) Manual](https://manpages.ubuntu.com/manpages/focal/man5/apt_preferences.5.html)

---

## Ubuntu 24.04+ DEB822 Format (`.sources`)

Ubuntu 24.04 (Noble Numbat) and later prefer the new **DEB822** format over the traditional one-line `.list` format. DEB822 uses a stanza-based structure. 

While our current `.list` script **still works** on 24.04, it is considered legacy.

**Future Architecture Improvement:**
Instead of a `.list` file, the installer should create `/etc/apt/sources.list.d/antigravity.sources`:
```text
Types: deb
URIs: https://us-central1-apt.pkg.dev/projects/antigravity-auto-updater-dev/
Suites: antigravity-debian
Components: main
Signed-By: /etc/apt/keyrings/antigravity-repo-key.gpg
```
*Note: Tools like `apt modernize-sources` can automatically migrate older files.*

---

## Removal & Cleanup

```bash
sudo apt remove -y antigravity
sudo rm -f /etc/apt/sources.list.d/antigravity.list
# Also: rm -f /etc/apt/keyrings/antigravity-repo-key.gpg (not currently done)
```

**Source:** `src/30_installers.sh:180-182`

> [!WARNING]
> **Stale Key Issue:** The GPG key (`antigravity-repo-key.gpg`) is NOT currently removed during uninstall. This is harmless but leaves an orphaned key. A future update should add key cleanup to the removal script.

### Rollback on Failure

If `apt install` fails mid-flight, the `.list` file is intentionally deleted to prevent broken `apt update` commands on future runs:
```bash
sudo rm -f /etc/apt/sources.list.d/antigravity.list
```

---

## Essential APT Skills & Tools

1. **`apt-cache policy`**: Check package priorities and repository sources.
2. **`apt-mark hold antigravity`**: Prevent a package from being automatically upgraded (useful if a bad update breaks functionality).
3. **`dpkg -L antigravity`**: List all files installed by the `antigravity` deb package to verify installation locations.
4. **`gpg --show-keys`**: Inspect the contents and expiration date of the downloaded `.gpg` keyring file.
