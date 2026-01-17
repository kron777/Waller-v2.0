from pathlib import Path

"""
Waller configuration

IMPORTANT:
Hidamari (Flatpak) can only access directories explicitly allowed
by its sandbox permissions.

By default, Hidamari has access to:
  ~/Videos/Hidamari/

All default wallpapers MUST live there, otherwise they will not play.
"""

BASE_DIR = Path.home() / "Videos" / "Hidamari"

DEFAULT_VIDEOS = {
    "Green Arena": str(BASE_DIR / "green-arena.mp4"),
    "Fire Nebula": str(BASE_DIR / "fire-nebula.mp4"),
    "Neon Fantasy Waves": str(BASE_DIR / "neon-waves.mp4"),
    "Peaceful Sunset": str(BASE_DIR / "peaceful-sunset.mp4"),
    "Space Encounters": str(BASE_DIR / "space-encounters.mp4"),
}

