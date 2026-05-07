#!/usr/bin/env bash
set -e

echo "📥 Fetching Antigravity Manager..."
curl -sSL https://raw.githubusercontent.com/google/antigravity-install/main/antigravity-manager.sh -o antigravity-manager.sh
chmod +x antigravity-manager.sh

echo "🚀 Launching installer..."
./antigravity-manager.sh --install
