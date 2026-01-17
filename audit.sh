#!/usr/bin/env bash

OUT="$HOME/Desktop/results.txt"

echo "WALLER + HIDAMARI DEEP AUDIT" > "$OUT"
echo "Timestamp: $(date)" >> "$OUT"
echo "==================================================" >> "$OUT"
echo >> "$OUT"

echo "### SYSTEM" >> "$OUT"
uname -a >> "$OUT"
echo "DESKTOP: $XDG_CURRENT_DESKTOP" >> "$OUT"
echo "SESSION: $XDG_SESSION_TYPE" >> "$OUT"
echo >> "$OUT"

echo "### PYTHON" >> "$OUT"
which python3 >> "$OUT"
python3 --version >> "$OUT"
echo >> "$OUT"

echo "### WALLER FILE CHECKS" >> "$OUT"
pwd >> "$OUT"
ls -l waller >> "$OUT"
ls -l waller/ui >> "$OUT"
ls -l assets >> "$OUT"
ls -l assets/defaults >> "$OUT"
echo >> "$OUT"

echo "### DEFAULT VIDEO PATHS" >> "$OUT"
python3 - <<'PY' >> "$OUT" 2>&1
from waller.config import DEFAULT_VIDEOS
import os
for k,v in DEFAULT_VIDEOS.items():
    print(k, "=>", v, "exists:", os.path.exists(v))
PY
echo >> "$OUT"

echo "### HIDAMARI FLATPAK INFO" >> "$OUT"
flatpak info io.github.jeffshee.Hidamari >> "$OUT"
echo >> "$OUT"

echo "### HIDAMARI PERMISSIONS" >> "$OUT"
flatpak info --show-permissions io.github.jeffshee.Hidamari >> "$OUT"
echo >> "$OUT"

echo "### HIDAMARI CONFIG CONTENTS" >> "$OUT"
cat "$HOME/.var/app/io.github.jeffshee.Hidamari/config/hidamari/config.json" >> "$OUT" 2>&1
echo >> "$OUT"

echo "### HIDAMARI PROCESSES (before)" >> "$OUT"
pgrep -af Hidamari >> "$OUT" || echo "Not running" >> "$OUT"
echo >> "$OUT"

echo "### MANUAL APPLY TEST (API)" >> "$OUT"
python3 - <<'PY' >> "$OUT" 2>&1
from waller.hidamari_api import apply_video
from waller.config import DEFAULT_VIDEOS
print("Applying:", list(DEFAULT_VIDEOS.values())[0])
apply_video(list(DEFAULT_VIDEOS.values())[0])
print("Apply call finished")
PY
echo >> "$OUT"

sleep 2

echo "### HIDAMARI PROCESSES (after)" >> "$OUT"
pgrep -af Hidamari >> "$OUT" || echo "Not running" >> "$OUT"
echo >> "$OUT"

echo "### MPV INSIDE FLATPAK CHECK" >> "$OUT"
flatpak run --command=sh io.github.jeffshee.Hidamari -c "which mpv && mpv --version" >> "$OUT" 2>&1
echo >> "$OUT"

echo "### FLATPAK FILE ACCESS TEST" >> "$OUT"
flatpak run --command=sh io.github.jeffshee.Hidamari -c "ls $HOME/Desktop/waller/assets/defaults" >> "$OUT" 2>&1
echo >> "$OUT"

echo "### DONE" >> "$OUT"
