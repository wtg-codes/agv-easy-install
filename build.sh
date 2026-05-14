#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

OUT_FILE="antigravity-manager.sh"

echo "#!/usr/bin/env bash" > "$OUT_FILE"
echo "# =============================================================================" >> "$OUT_FILE"
echo "# Google Antigravity Setup Script" >> "$OUT_FILE"
echo "# WARNING: This file is auto-generated. Do not edit directly." >> "$OUT_FILE"
echo "# Edit the files in the src/ directory and run ./build.sh instead." >> "$OUT_FILE"
echo "# =============================================================================" >> "$OUT_FILE"

# Strip the leading #!/usr/bin/env bash from 00_config.sh
tail -n +2 src/00_config.sh >> "$OUT_FILE"

cat src/10_utils.sh \
    src/20_platform.sh \
    src/30_installers.sh \
    src/40_ui.sh \
    src/50_health.sh \
    src/99_main.sh >> "$OUT_FILE"

chmod +x "$OUT_FILE"

echo "Bundled $OUT_FILE successfully."
