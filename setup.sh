#!/usr/bin/env bash
set -e

echo "📥 Downloading Antigravity Manager..."
curl -sL https://raw.githubusercontent.com/wtg-codes/agv-easy-install/main/antigravity-manager.sh -o antigravity-manager.sh
chmod +x antigravity-manager.sh

echo "🛠️ Running installation..."
./antigravity-manager.sh --install
