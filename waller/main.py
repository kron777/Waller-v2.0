#!/usr/bin/env python3

from waller.waller import run_tray


def main():
    """
    Headless entry point.
    No Waller GUI is created.
    This hands control directly to waller.py.
    """
    run_tray()


if __name__ == "__main__":
    main()

