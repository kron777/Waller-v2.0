import json
import subprocess
import time
from pathlib import Path


"""
Hidamari API bridge for Waller

This module is responsible for:
- Validating Hidamari config existence
- Updating Hidamari config to VIDEO mode
- Pointing Hidamari to a specific video file
- Restarting Hidamari so it applies the change

This is the ONLY supported and stable way to control Hidamari
from outside its Flatpak sandbox.
"""

HIDAMARI_APP_ID = "io.github.jeffshee.Hidamari"

CONFIG_DIR = (
    Path.home()
    / ".var"
    / "app"
    / HIDAMARI_APP_ID
    / "config"
    / "hidamari"
)

CONFIG_FILE = CONFIG_DIR / "config.json"


class HidamariError(RuntimeError):
    pass


def _ensure_config_exists():
    if not CONFIG_FILE.exists():
        raise HidamariError(
            "Hidamari config not found.\n\n"
            "Run Hidamari once manually:\n"
            "flatpak run io.github.jeffshee.Hidamari"
        )


def _load_config() -> dict:
    _ensure_config_exists()
    with CONFIG_FILE.open("r", encoding="utf-8") as f:
        return json.load(f)


def _save_config(cfg: dict):
    CONFIG_DIR.mkdir(parents=True, exist_ok=True)
    with CONFIG_FILE.open("w", encoding="utf-8") as f:
        json.dump(cfg, f, indent=2)


def _is_running() -> bool:
    try:
        subprocess.run(
            ["pgrep", "-f", HIDAMARI_APP_ID],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True,
        )
        return True
    except subprocess.CalledProcessError:
        return False


def _stop():
    subprocess.run(
        ["pkill", "-f", HIDAMARI_APP_ID],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def _start():
    subprocess.Popen(
        ["flatpak", "run", HIDAMARI_APP_ID],
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )
    time.sleep(1.5)


def apply_video(video_path: str):
    video = Path(video_path).expanduser().resolve()

    if not video.exists():
        raise HidamariError(f"Video file does not exist:\n{video}")

    cfg = _load_config()

    # Force video wallpaper mode
    cfg["mode"] = "MODE_VIDEO"
    cfg["is_static_wallpaper"] = False

    # Update data source for default monitor
    data_source = cfg.get("data_source", {})
    data_source["Default"] = str(video)
    cfg["data_source"] = data_source

    _save_config(cfg)

    # Restart Hidamari to apply changes
    if _is_running():
        _stop()
        time.sleep(0.5)

    _start()

