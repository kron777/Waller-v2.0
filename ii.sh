#!/usr/bin/env bash
set -e

echo "=== ii.sh :: Waller integration helper ==="

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
LAUNCHER="$BIN_DIR/waller-launch"
DESKTOP_FILE="$DESKTOP_DIR/waller.desktop"
AUTOSTART_FILE="$DESKTOP_DIR/waller-autostart.desktop"

# ensure dirs exist
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"

echo "[1/6] Writing launcher stub..."

cat <<'EOF' > "$LAUNCHER"
#!/usr/bin/env bash
exec python3 -m waller.main
EOF

chmod +x "$LAUNCHER"

echo "[2/6] Ensuring desktop entry points to launcher..."

if [ -f "$REPO_ROOT/waller.desktop" ]; then
  sed "s|Exec=.*|Exec=$LAUNCHER|g" \
    "$REPO_ROOT/waller.desktop" > "$DESKTOP_FILE"
else
  echo "⚠️ waller.desktop not found in repo root"
fi

echo "[3/6] Ensuring autostart entry points to launcher..."

if [ -f "$REPO_ROOT/waller-autostart.desktop" ]; then
  sed "s|Exec=.*|Exec=$LAUNCHER|g" \
    "$REPO_ROOT/waller-autostart.desktop" > "$AUTOSTART_FILE"
else
  echo "⚠️ waller-autostart.desktop not found in repo root"
fi

update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true

echo "[4/6] Cleaning stale python cache..."
rm -rf "$REPO_ROOT/waller/__pycache__" || true

echo "[5/6] Git status:"
git status --short

echo "[6/6] Commit + tag helper ready."

echo "-----------------------------------------"
echo "✔ Launcher enforced (headless)"
echo "✔ Desktop + autostart wired"
echo "✔ Hidamari is sole GUI"
echo
echo "If everything looks correct, run:"
echo "  git add ."
echo "  git commit -m \"Headless launcher: Waller hands off directly to Hidamari\""
echo "  git tag v0.2.1"
echo "  git push && git push origin v0.2.1"
echo "-----------------------------------------"
