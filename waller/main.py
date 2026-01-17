import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

from waller.ui.main_window import WallerWindow


def main():
    window = WallerWindow()
    window.connect("destroy", Gtk.main_quit)
    window.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()

