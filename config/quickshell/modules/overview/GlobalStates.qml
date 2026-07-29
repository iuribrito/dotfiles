pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
    id: root
    property bool overviewOpen: false

    GlobalShortcut {
        name: "overviewToggle"
        description: "Toggle window overview"
        onPressed: root.overviewOpen = !root.overviewOpen
    }
}
