# agv-easy-install

A simple way for students to install Google Antigravity on Linux.

## Quick Install

To install Google Antigravity, run the following command in your terminal:

```bash
curl -sL https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/setup.sh | bash
```

## Management Script

The installation also provides an `antigravity-manager.sh` script in your current directory (or you can download it again) that allows you to install or remove the application.

### Uninstalling

To remove Google Antigravity and its shortcuts (keeping your workspace safe):

```bash
./antigravity-manager.sh --remove
```

### Reinstalling / Updating

To reinstall or update to the latest version handled by this script:

```bash
./antigravity-manager.sh --install
```
