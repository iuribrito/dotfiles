pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isOpen: false
    property var usageCounts: ({})

    readonly property string usagePath: Quickshell.env("HOME") + "/.config/quickshell/launcher_usage.json"

    Component.onCompleted: loadProc.running = true

    function recordUsage(appId) {
        const counts = Object.assign({}, root.usageCounts)
        counts[appId] = (counts[appId] || 0) + 1
        root.usageCounts = counts
        saveProc.running = false
        saveProc.command = [
            "sh", "-c",
            "mkdir -p \"$(dirname \"$1\")\" && printf '%s' \"$2\" > \"$1\"",
            "sh", root.usagePath, JSON.stringify(counts)
        ]
        saveProc.running = true
    }

    Process {
        id: loadProc
        command: [
            "sh", "-c",
            "[ -f \"$1\" ] && cat \"$1\" || echo '{}'",
            "sh", root.usagePath
        ]
        stdout: SplitParser {
            onRead: data => {
                try { root.usageCounts = JSON.parse(data) } catch(e) {}
            }
        }
    }

    Process {
        id: saveProc
    }
}
