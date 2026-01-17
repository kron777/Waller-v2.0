"""
player.py

Thin abstraction layer between Waller UI and the Hidamari backend.

Responsibilities:
- Expose a stable start_wallpaper() API to the UI
- Delegate all real work to hidamari_api
- Contain ZERO UI logic
- Contain ZERO Flatpak / GTK logic
- Contain ZERO legacy wallpaper backends

This file intentionally stays small and boring.
"""

from waller.hidamari_api import apply_video, HidamariError


class WallpaperError(RuntimeError):
    """
    High-level wallpaper error surfaced to the UI.
    """
    pass


def start_wallpaper(video_path: str):
    """
    Apply a video as the desktop wallpaper via Hidamari.

    This function is called by the GUI 'Apply' buttons.
    """
    try:
        apply_video(video_path)
    except HidamariError as e:
        raise WallpaperError(str(e)) from e
    except Exception as e:
        raise WallpaperError(
            "Unexpected error while applying wallpaper:\n"
            f"{e}"
        ) from e

