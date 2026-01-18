#!/usr/bin/env bash
set -e

echo "=== 3.sh :: Waller v2.0 alignment script ==="

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

README="$REPO_ROOT/README.md"
DESKTOP="$REPO_ROOT/waller.desktop"
AUTOSTART="$REPO_ROOT/waller-autostart.desktop"

# --------------------------------------------------
# 1) Update README header + intro
# --------------------------------------------------
echo "[1/5] Updating README.md..."

if [ -f "$README" ]; then
  # Replace title line
  sed -i \
    '1s/^# .*/# Waller v2.0/' \
    "$README"

  # Remove explicit 0.1.0 references
  sed -i \
    's/Waller 0\.1\.0/Waller v2.0/g' \
    "$README"

  sed -i \
    's/0\.1\.0/v2.0/g' \
    "$README"

  # Ensure intro text is correct (idempotent)
  if ! grep -q "headless launcher" "$README"; then
    sed -i \
      '2i\
Waller is a lightweight, headless launcher that hands off directly to Hidamari to provide animated video wallpapers on GNOME (X11).\
' "$README"
  fi

  echo "✔ README updated"
else
  echo "⚠️ README.md not found"
fi

# --------------------------------------------------
# 2) Clean desktop file comments (no versions)
# --------------------------------------------------
echo "[2/5] Cleaning desktop files..."

for file in "$DESKTOP" "$AUTOSTART"; do
  if [ -f "$file" ]; then
    sed -i \
      's/Comment=.*/Comment=Animated desktop wallpapers via Hidamari/' \
      "$file"
    echo "✔ Cleaned $(basename "$file")"
  fi
done

# --------------------------------------------------
# 3) Scan for lingering 0.1.0 references
# --------------------------------------------------
echo "[3/5] Scanning repo for legacy version strings..."

MATCHES="$(grep -R "0\.1\.0" -n "$REPO_ROOT" || true)"

if [ -z "$MATCHES" ]; then
  echo "✔ No remaining 0.1.0 references found"
else
  echo "⚠️ Found remaining references:"
  echo "$MATCHES"
fi

# --------------------------------------------------
# 4) Summary
# --------------------------------------------------
echo "[4/5] Alignment complete."

# --------------------------------------------------
# 5) Git status
# --------------------------------------------------
echo "[5/5] Git status:"
git status --short

echo "-----------------------------------------"
echo "✔ README aligned to Waller v2.0"
echo "✔ Desktop metadata cleaned"
echo "✔ Legacy references audited"
echo
echo "Next:"
echo "  git add README.md waller.desktop waller-autostart.desktop 3.sh"
echo "  git commit -m \"Align metadata and docs to Waller v2.0\""
echo "-----------------------------------------"
