import json
from pathlib import Path

STORE_DIR = Path.home() / ".waller_runtime"
STORE_FILE = STORE_DIR / "local_videos.json"


def load_local_videos():
    if STORE_FILE.exists():
        try:
            return json.loads(STORE_FILE.read_text())
        except Exception:
            return []
    return []


def add_local_video(path: str):
    videos = load_local_videos()
    if path not in videos:
        videos.append(path)
        STORE_DIR.mkdir(parents=True, exist_ok=True)
        STORE_FILE.write_text(json.dumps(videos, indent=2))


def remove_local_video(path: str):
    videos = load_local_videos()
    if path in videos:
        videos.remove(path)
        STORE_FILE.write_text(json.dumps(videos, indent=2))

