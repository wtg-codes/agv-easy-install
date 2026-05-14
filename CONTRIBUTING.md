# Contributing to `agv-easy-install`

Thanks for your interest in improving the installer! Here's how to get started.

---

## 🔀 Workflow

1. **Fork** the repository and **clone** your fork.
2. **Create a branch** from `main` (e.g. `fix/tarball-checksum`).
3. **Make your changes** — follow the rules in [`AGENTS.md`](AGENTS.md).
4. **Run the gate tests** before pushing:
   ```bash
   bash tests/run_gates.sh --phase all
   ```
5. **Open a Pull Request** using the provided template.

---

## ✅ Before You Submit

- [ ] `shellcheck -e SC1091,SC2162 antigravity-manager.sh` passes cleanly
- [ ] `bash -n antigravity-manager.sh` reports no syntax errors
- [ ] `python3 -m py_compile scrape_latest.py` succeeds
- [ ] All relevant phase gates pass
- [ ] If you changed menu options, you updated `docs/index.html` and ran `python3 docs/images/capture.py` to regenerate screenshots

---

## 📐 Style Guide

| File | Rules |
|---|---|
| `antigravity-manager.sh` | Double-quote all variables · `curl -fSsL` · `trap` cleanup for temp files |
| `docs/index.html` | Tailwind CDN (no build step) · Pin CDN versions · `textContent` only (no `innerHTML`) |
| `scrape_latest.py` | Type hints · Errors to `stderr` · Deps in `requirements.txt` |
| CI workflows | Pin action versions (`@v4`+) · `#` as `sed` delimiter |

---

## 📚 Key Files

| File | What it does |
|---|---|
| [`AGENTS.md`](AGENTS.md) | Full rules and architecture context |
| [`tests/run_gates.sh`](tests/run_gates.sh) | Automated gate tests for all phases |
| [`docs/architecture/`](docs/architecture/) | Critique, retort, and implementation plan |

## Development

The `antigravity-manager.sh` file is bundled from the `src/` directory. **Do not edit it directly.**

```bash
# 1. Edit files in src/
# 2. Compile
./build.sh
# 3. Verify
bash tests/run_gates.sh --phase all
```

If you changed the interactive menus, also update the screenshots:

```bash
# Edit docs/images/render.html to match the new menu text
# Then regenerate the PNGs:
python3 docs/images/capture.py
```
