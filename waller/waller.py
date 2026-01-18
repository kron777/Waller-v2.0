#!/usr/bin/env python3

import subprocess
import sys
import time


def launch_hidamari_gui():
    """
    Launch Hidamari GUI non-blocking.
    """
    try:
        subprocess.Popen(
            ["flatpak", "run", "io.github.jeffshee.Hidamari"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except Exception as e:
        print(f"[Waller] Failed to launch Hidamari: {e}", file=sys.stderr)


def run_tray():
    """
    Headless controller runtime.
    Launches Hidamari and keeps process alive.
    """

    # Launch Hidamari immediately
    launch_hidamari_gui()

    # Keep Waller alive (tray / controller / future hooks)
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        pass

