#!/usr/bin/env bash
set -e

echo "=== ii.sh :: Waller integration + default wallpaper curator ==="

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
ASSETS_DIR="$REPO_ROOT/assets/defaults"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
APP_DIR="$HOME/.local/share/waller"
VIDEO_DIR="$APP_DIR/videos"

LAUNCHER="$BIN_DIR/waller-launch"

mkdir -p "$ASSETS_DIR" "$VIDEO_DIR" "$BIN_DIR" "$DESKTOP_DIR"

# --------------------------------------------------
# 1) enforce headless launcher
# --------------------------------------------------
echo "[1/8] Writing launcher stub..."

cat <<'EOF' > "$LAUNCHER"
#!/usr/bin/env bash
exec python3 -m waller.main
EOF

chmod +x "$LAUNCHER"

# --------------------------------------------------
# 2) wire desktop + autostart
# --------------------------------------------------
echo "[2/8] Wiring desktop + autostart..."

[ -f "$REPO_ROOT/waller.desktop" ] &&
  sed "s|Exec=.*|Exec=$LAUNCHER|g" "$REPO_ROOT/waller.desktop" \
    > "$DESKTOP_DIR/waller.desktop"

[ -f "$REPO_ROOT/waller-autostart.desktop" ] &&
  sed "s|Exec=.*|Exec=$LAUNCHER|g" "$REPO_ROOT/waller-autostart.desktop" \
    > "$DESKTOP_DIR/waller-autostart.desktop"

update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true

# --------------------------------------------------
# 3) ensure yt-dlp exists
# --------------------------------------------------
echo "[3/8] Checking yt-dlp..."
command -v yt-dlp >/dev/null 2>&1 || {
  echo "ERROR: yt-dlp is required. Install it first."
  exit 1
}

# --------------------------------------------------
# 4) define default video set (source of truth)
# --------------------------------------------------
echo "[4/8] Ensuring raw default videos exist..."

declare -A SOURCES=(
  ["RoS4U2pC_4w"]="fire-nebula.mp4"
  ["rRNWW38WgGs"]="green-arena.mp4"
  ["zK6sTY6Y4dU"]="neon-waves.mp4"
  ["ZwLBQIPfXXw"]="peaceful-sunset.mp4"
  ["vKRkecNzEY8"]="space-encounters.mp4"
  ["yC79xscT888"]="ambient-grid.mp4"
  ["4flcF-ZZxeY"]="deep-field.mp4"
  ["lQghbcZgQMA"]="cosmic-flow.mp4"
  ["h990ITSyxzw"]="dark-motion.mp4"
)

for id in "${!SOURCES[@]}"; do
  if ! ls "$ASSETS_DIR"/*"$id"*.mp4 >/dev/null 2>&1; then
    echo "  → downloading $id"
    yt-dlp \
      -f "bv*[ext=mp4]/b[ext=mp4]" \
      --merge-output-format mp4 \
      -o "$ASSETS_DIR/%(title)s [$id].mp4" \
      "https://www.youtube.com/watch?v=$id"
  else
    echo "  ✔ $id already present"
  fi
done

# --------------------------------------------------
# 5) normalize + install runtime defaults
# --------------------------------------------------
echo "[5/8] Normalizing + installing runtime wallpapers..."

rm -f "$VIDEO_DIR"/*.mp4 || true

for id in "${!SOURCES[@]}"; do
  src="$(ls "$ASSETS_DIR"/*"$id"*.mp4 | head -n 1)"
  cp "$src" "$VIDEO_DIR/${SOURCES[$id]}"
done

echo "✔ Installed wallpapers:"
ls "$VIDEO_DIR" | sed 's/^/  - /'

# --------------------------------------------------
# 6) clean python cache
# --------------------------------------------------
echo "[6/8] Cleaning Python cache..."
rm -rf "$REPO_ROOT/waller/__pycache__" || true

# --------------------------------------------------
# 7) git status
# --------------------------------------------------
echo "[7/8] Git status:"
git status --short

# --------------------------------------------------
# 8) done
# --------------------------------------------------
echo "[8/8] ii.sh complete."
echo "-----------------------------------------"
echo "✔ Missing defaults downloaded"
echo "✔ Raw assets stored in assets/defaults"
echo "✔ Runtime wallpapers normalized"
echo "✔ Launcher + autostart enforced"
echo
echo "Next:"
echo "  git add assets/defaults ii.sh"
echo "  git commit -m \"Add and normalize full default wallpaper set\""
echo "-----------------------------------------"
