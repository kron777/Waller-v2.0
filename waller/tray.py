import gi
gi.require_version("Gtk", "3.0")
gi.require_version("AppIndicator3", "0.1")
from gi.repository import Gtk, AppIndicator3

import subprocess
import sys
from pathlib import Path


APP_ID = "waller"
ICON_PATH = str(
    Path(__file__).parent.parent / "assets" / "waller.png"
)


class WallerTray:
    def __init__(self):
        self.indicator = AppIndicator3.Indicator.new(
            APP_ID,
            ICON_PATH,
            AppIndicator3.IndicatorCategory.APPLICATION_STATUS,
        )

        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
        self.indicator.set_menu(self._build_menu())

    def _build_menu(self):
        menu = Gtk.Menu()

        open_item = Gtk.MenuItem(label="Open")
        open_item.connect("activate", self._open_gui)
        menu.append(open_item)

        menu.append(Gtk.SeparatorMenuItem())

        exit_item = Gtk.MenuItem(label="Exit")
        exit_item.connect("activate", self._quit)
        menu.append(exit_item)

        menu.show_all()
        return menu

    def _open_gui(self, _):
        subprocess.Popen(
            [sys.executable, "-m", "waller.main"],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )

    def _quit(self, _):
        Gtk.main_quit()


def run_tray():
    WallerTray()
    Gtk.main()


if __name__ == "__main__":
    run_tray()

