import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk
from pathlib import Path

from waller.config import DEFAULT_VIDEOS
from waller.player import start_wallpaper, WallpaperError


class WallerWindow(Gtk.Window):
    def __init__(self):
        super().__init__(title="Waller")

        self.set_default_size(760, 540)
        self.set_border_width(12)
        self.set_position(Gtk.WindowPosition.CENTER)

        root = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=14)
        self.add(root)

        # =========================
        # Default videos section
        # =========================
        root.pack_start(Gtk.Label(label="Default wallpapers", xalign=0), False, False, 0)

        defaults_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        root.pack_start(defaults_box, False, False, 0)

        for name, path in DEFAULT_VIDEOS.items():
            row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)

            label = Gtk.Label(label=name, xalign=0)
            row.pack_start(label, True, True, 0)

            apply_btn = Gtk.Button(label="Apply")
            apply_btn.connect("clicked", self._on_apply, path)
            row.pack_end(apply_btn, False, False, 0)

            defaults_box.pack_start(row, False, False, 0)

        # =========================
        # Local videos section
        # =========================
        root.pack_start(Gtk.Separator(), False, False, 8)
        root.pack_start(Gtk.Label(label="Local videos (drag & drop)", xalign=0), False, False, 0)

        self.local_list = Gtk.ListBox()
        self.local_list.set_selection_mode(Gtk.SelectionMode.NONE)
        self.local_list.set_activate_on_single_click(False)
        root.pack_start(self.local_list, True, True, 0)

        self._setup_drag_and_drop()

    # =========================
    # Apply logic
    # =========================
    def _on_apply(self, _button, video_path):
        try:
            start_wallpaper(video_path)
        except WallpaperError as e:
            self._show_error(str(e))

    # =========================
    # Drag & drop handling
    # =========================
    def _setup_drag_and_drop(self):
        target = Gtk.TargetEntry.new("text/uri-list", 0, 0)
        self.local_list.drag_dest_set(
            Gtk.DestDefaults.ALL,
            [target],
            Gdk.DragAction.COPY,
        )
        self.local_list.connect("drag-data-received", self._on_drag_data)

    def _on_drag_data(self, _widget, _context, _x, _y, data, _info, _time):
        for uri in data.get_uris():
            if not uri.startswith("file://"):
                continue

            path = Path(uri[7:]).expanduser().resolve()
            if path.suffix.lower() not in (".mp4", ".mkv", ".webm"):
                continue

            self._add_local_video(path)

    def _add_local_video(self, path: Path):
        row = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=10)

        label = Gtk.Label(label=path.name, xalign=0)
        row.pack_start(label, True, True, 0)

        apply_btn = Gtk.Button(label="Apply")
        apply_btn.connect("clicked", self._on_apply, str(path))
        row.pack_end(apply_btn, False, False, 0)

        self.local_list.add(row)
        self.local_list.show_all()

    # =========================
    # Error dialog
    # =========================
    def _show_error(self, message: str):
        dialog = Gtk.MessageDialog(
            parent=self,
            flags=0,
            message_type=Gtk.MessageType.ERROR,
            buttons=Gtk.ButtonsType.OK,
            text="Wallpaper error",
        )
        dialog.format_secondary_text(message)
        dialog.run()
        dialog.destroy()

