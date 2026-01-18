#!/usr/bin/env bash
set -e

echo "=== Installing Waller 2.0 ==="

# --- sanity check ---
if [[ "$XDG_SESSION_TYPE" != "x11" ]]; then
  echo "ERROR: Waller requires X11 (Wayland not supported)."
  exit 1
fi

# --- paths ---
APP_DIR="$HOME/.local/share/waller"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"

# ensure local bin is usable
export PATH="$HOME/.local/bin:$PATH"

# --- deps ---
echo "[1/8] Installing system dependencies..."
sudo apt update
sudo apt install -y flatpak ffmpeg jq libnotify-bin

# --- flatpak ---
echo "[2/8] Installing Hidamari + codecs..."
flatpak remote-add --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y flathub \
  io.github.jeffshee.Hidamari \
  org.freedesktop.Platform.ffmpeg-full//23.08

# --- directories ---
echo "[3/8] Creating directories..."
mkdir -p "$APP_DIR"/{videos,icons,screenshots}
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"

# --- assets ---
echo "[4/8] Installing assets..."

# videos (clean defaults only)
cp assets/defaults/*.mp4 "$APP_DIR/videos/"

# icons
cp assets/icon.png "$APP_DIR/icons/"
cp assets/waller.png "$APP_DIR/icons/"
cp assets/w-logo-33563.png "$APP_DIR/icons/"

# screenshots + docs
cp -r screenshots "$APP_DIR/"
cp README.md "$APP_DIR/"
cp LICENSE "$APP_DIR/"

# --- launcher ---
echo "[5/8] Installing launcher..."
cat <<'EOF' > "$BIN_DIR/waller-launch"
#!/usr/bin/env bash
flatpak run io.github.jeffshee.Hidamari &
EOF

chmod +x "$BIN_DIR/waller-launch"

# --- desktop entries ---
echo "[6/8] Installing desktop entries..."

sed "s|Exec=.*|Exec=$BIN_DIR/waller-launch|g" waller.desktop \
  | sed "s|Icon=.*|Icon=$APP_DIR/icons/icon.png|g" \
  > "$DESKTOP_DIR/waller.desktop"

cp waller-autostart.desktop "$DESKTOP_DIR/"

update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true

# --- hidamari preseed ---
echo "[7/8] Pre-seeding Hidamari config (non-destructive)..."

HIDA_DIR="$HOME/.var/app/io.github.jeffshee.Hidamari/config"
HIDA_FILE="$HIDA_DIR/config.json"

mkdir -p "$HIDA_DIR"

if [ ! -f "$HIDA_FILE" ]; then
  cat <<EOF > "$HIDA_FILE"
{
  "local_video_dirs": [
    "$HOME/.local/share/waller/videos"
  ]
}
EOF
  echo "• Hidamari config created"
else
  echo "• Hidamari config already exists, leaving untouched"
fi

# --- done ---
echo "[8/8] Finalizing..."
notify-send "Waller installed" "Open Hidamari → Local Files to select wallpapers" || true

echo "✅ Waller installed successfully."
echo "• Launch from app menu or tray"
echo "• Videos are preloaded in Hidamari → Local Files"

