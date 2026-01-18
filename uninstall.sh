#!/usr/bin/env bash
set -e

echo "=== Uninstalling Waller ==="

APP_DIR="$HOME/.local/share/waller"
BIN_FILE="$HOME/.local/bin/waller-launch"
DESKTOP_DIR="$HOME/.local/share/applications"

echo "[1/4] Removing application data..."
rm -rf "$APP_DIR"

echo "[2/4] Removing launcher..."
rm -f "$BIN_FILE"

echo "[3/4] Removing desktop entries..."
rm -f "$DESKTOP_DIR/waller.desktop"
rm -f "$DESKTOP_DIR/waller-autostart.desktop"

echo "[4/4] Updating desktop database..."
update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true

echo "✅ Waller uninstalled successfully."
echo "Flatpak Hidamari and codecs were left intact."

