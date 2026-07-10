pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root

    property bool isOpen: false
    property var entries: []
    property var _buf: []

    GlobalShortcut {
        name: "clipboardToggle"
        description: "Toggle clipboard history"
        onPressed: root.isOpen = !root.isOpen
    }

    onIsOpenChanged: if (isOpen) load()

    function load() {
        root._buf = []
        listProc.running = false
        listProc.running = true
    }

    function paste(line) {
        pasteProc.running = false
        pasteProc.command = ["sh", "-c", "printf '%s\\n' \"$1\" | cliphist decode | wl-copy", "sh", line]
        pasteProc.running = true
    }

    function remove(line) {
        const idx = root.entries.indexOf(line)
        if (idx !== -1) {
            const copy = root.entries.slice()
            copy.splice(idx, 1)
            root.entries = copy
        }
        removeProc.running = false
        removeProc.command = ["sh", "-c", "printf '%s\\n' \"$1\" | cliphist delete", "sh", line]
        removeProc.running = true
    }

    Process {
        id: listProc
        command: ["cliphist", "list"]
        stdout: SplitParser {
            onRead: data => {
                const line = data.trim()
                if (line !== "") {
                    const buf = root._buf.slice()
                    buf.push(line)
                    root._buf = buf
                }
            }
        }
        onRunningChanged: {
            if (!running) root.entries = root._buf.slice()
        }
    }

    Process { id: pasteProc }
    Process { id: removeProc }
}
