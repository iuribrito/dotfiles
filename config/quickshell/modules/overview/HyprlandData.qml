pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Singleton {
    id: root
    property var windowList: []
    property var addresses: []
    property var windowByAddress: ({})
    property var monitors: []

    function updateWindowList() { getClients.running = true }
    function updateMonitors() { getMonitors.running = true }
    function updateAll() {
        updateWindowList()
        updateMonitors()
    }

    Component.onCompleted: updateAll()

    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (["openlayer", "closelayer", "screencast"].includes(event.name)) return
            updateAll()
        }
    }

    Process {
        id: getClients
        command: ["hyprctl", "clients", "-j"]
        stdout: StdioCollector {
            id: clientsCollector
            onStreamFinished: {
                try {
                    root.windowList = JSON.parse(clientsCollector.text)
                    let byAddr = {}
                    for (let win of root.windowList) {
                        byAddr[win.address] = win
                    }
                    root.windowByAddress = byAddr
                    root.addresses = root.windowList.map(w => w.address)
                } catch (e) {
                    console.warn("[HyprlandData] Failed to parse clients:", e)
                }
            }
        }
    }

    Process {
        id: getMonitors
        command: ["hyprctl", "monitors", "-j"]
        stdout: StdioCollector {
            id: monitorsCollector
            onStreamFinished: {
                try {
                    root.monitors = JSON.parse(monitorsCollector.text)
                } catch (e) {
                    console.warn("[HyprlandData] Failed to parse monitors:", e)
                }
            }
        }
    }
}
