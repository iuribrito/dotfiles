import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"

Item {
    id: root
    required property var screen

    readonly property HyprlandMonitor monitor: Hyprland.monitorFor(screen)

    // Layout config
    readonly property int rows: 2
    readonly property int cols: 5
    readonly property real wsScale: 0.13
    readonly property real wsSpacing: 5
    readonly property real padding: 10

    readonly property real wsWidth:  monitor.width  * wsScale
    readonly property real wsHeight: monitor.height * wsScale

    implicitWidth:  cols * wsWidth  + (cols - 1) * wsSpacing + padding * 2
    implicitHeight: rows * wsHeight + (rows - 1) * wsSpacing + padding * 2

    // Active workspace tracking
    readonly property int totalShown: rows * cols
    readonly property int effectiveActiveWsId: Math.max(1, Math.min(100, monitor?.activeWorkspace?.id ?? 1))
    readonly property int workspaceGroup: Math.floor((effectiveActiveWsId - 1) / totalShown)

    // Drag state
    property int draggingFromWorkspace: -1
    property int draggingTargetWorkspace: -1

    function wsForCell(r, c) {
        return workspaceGroup * totalShown + r * cols + c + 1
    }
    function wsRow(wsId) {
        return Math.floor(((wsId - 1) % totalShown) / cols)
    }
    function wsCol(wsId) {
        return (wsId - 1) % cols
    }

    // Card background
    Rectangle {
        anchors.fill: parent
        color: Theme.bgDark
        radius: 14
    }

    // Catch-all: prevent backdrop from closing overview when clicking on empty widget space
    MouseArea {
        anchors.fill: parent
        z: 0
    }

    Item {
        id: gridArea
        x: root.padding
        y: root.padding
        width:  root.cols * root.wsWidth  + (root.cols - 1) * root.wsSpacing
        height: root.rows * root.wsHeight + (root.rows - 1) * root.wsSpacing

        // ── Workspace tiles ──────────────────────────────────────────────
        Repeater {
            model: root.rows * root.cols

            Item {
                id: wsTile
                required property int index
                readonly property int rowIdx: Math.floor(wsTile.index / root.cols)
                readonly property int colIdx: wsTile.index % root.cols
                readonly property int wsId:
                    root.workspaceGroup * root.totalShown + rowIdx * root.cols + colIdx + 1
                property bool isDragTarget: wsTile.wsId === root.draggingTargetWorkspace

                x: colIdx * (root.wsWidth + root.wsSpacing)
                y: rowIdx * (root.wsHeight + root.wsSpacing)
                width: root.wsWidth
                height: root.wsHeight
                z: 0

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: wsTile.isDragTarget ? Theme.bgHover : Theme.bgSurface
                    border.color: wsTile.isDragTarget ? Theme.blueMuted : "transparent"
                    border.width: 2
                    Behavior on color { ColorAnimation { duration: 150 } }

                    Text {
                        anchors.centerIn: parent
                        text: wsTile.wsId
                        font.pixelSize: parent.width * 0.22
                        font.bold: true
                        color: Qt.rgba(1, 1, 1, 0.1)
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    z: 1
                    onClicked: {
                        if (root.draggingTargetWorkspace === -1) {
                            GlobalStates.overviewOpen = false
                            Hyprland.dispatch("workspace " + wsTile.wsId)
                        }
                    }
                }

                DropArea {
                    anchors.fill: parent
                    z: 2
                    onEntered: {
                        root.draggingTargetWorkspace = wsTile.wsId
                    }
                    onExited: {
                        if (root.draggingTargetWorkspace === wsTile.wsId)
                            root.draggingTargetWorkspace = -1
                    }
                }
            }
        }

        // ── Focused workspace border ──────────────────────────────────────
        Rectangle {
            x: root.wsCol(root.effectiveActiveWsId) * (root.wsWidth + root.wsSpacing)
            y: root.wsRow(root.effectiveActiveWsId) * (root.wsHeight + root.wsSpacing)
            width: root.wsWidth
            height: root.wsHeight
            color: "transparent"
            radius: 6
            border.color: Theme.blue
            border.width: 2
            z: 3
            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutQuint } }
            Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutQuint } }
        }

        // ── Window previews ───────────────────────────────────────────────
        Repeater {
            model: ScriptModel {
                values: {
                    if (!HyprlandData.windowList.length) return []
                    return ToplevelManager.toplevels.values.filter(function(toplevel) {
                        var addr = "0x" + toplevel.HyprlandToplevel?.address
                        var win = HyprlandData.windowByAddress[addr]
                        if (!win) return false
                        var wsId = win.workspace?.id ?? 0
                        var minWs = root.workspaceGroup * root.totalShown + 1
                        var maxWs = (root.workspaceGroup + 1) * root.totalShown
                        return wsId >= minWs && wsId <= maxWs
                    })
                }
            }

            delegate: OverviewWindow {
                id: winWidget
                required property var modelData

                readonly property string winAddress: "0x" + modelData.HyprlandToplevel.address
                toplevel: modelData
                windowData: HyprlandData.windowByAddress[winAddress] ?? null
                monitorData: {
                    var mId = windowData?.monitor ?? 0
                    return HyprlandData.monitors.find(function(m) { return m.id === mId }) ?? null
                }
                widgetMonitor: HyprlandData.monitors.find(function(m) { return m.id === root.monitor?.id }) ?? null
                scale: root.wsScale

                xOffset: root.wsCol(windowData?.workspace?.id ?? 1) * (root.wsWidth + root.wsSpacing)
                yOffset: root.wsRow(windowData?.workspace?.id ?? 1) * (root.wsHeight + root.wsSpacing)

                z: Drag.active ? 9999 : 4
                Drag.hotSpot.x: width / 2
                Drag.hotSpot.y: height / 2

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    drag.target: parent

                    onEntered: winWidget.hovered = true
                    onExited:  winWidget.hovered = false

                    onPressed: function(mouse) {
                        root.draggingFromWorkspace = winWidget.windowData?.workspace?.id ?? -1
                        winWidget.pressed = true
                        winWidget.Drag.active = true
                        winWidget.Drag.source = winWidget
                        winWidget.Drag.hotSpot.x = mouse.x
                        winWidget.Drag.hotSpot.y = mouse.y
                    }

                    onReleased: {
                        var target  = root.draggingTargetWorkspace
                        var fromWs  = winWidget.windowData?.workspace?.id ?? -1
                        winWidget.pressed = false
                        winWidget.Drag.active = false
                        root.draggingFromWorkspace = -1
                        root.draggingTargetWorkspace = -1

                        if (target !== -1 && target !== fromWs) {
                            Hyprland.dispatch("movetoworkspacesilent " + target + ", address:" + (winWidget.windowData?.address ?? ""))
                        }
                        resetPosTimer.restart()
                    }

                    onClicked: function(event) {
                        if (!winWidget.windowData) return
                        if (event.button === Qt.LeftButton) {
                            GlobalStates.overviewOpen = false
                            Hyprland.dispatch("focuswindow address:" + winWidget.windowData.address)
                            event.accepted = true
                        } else if (event.button === Qt.MiddleButton) {
                            Hyprland.dispatch("closewindow address:" + winWidget.windowData.address)
                            event.accepted = true
                        }
                    }
                }

                // Restore position binding after drag (give Hyprland time to process)
                Timer {
                    id: resetPosTimer
                    interval: 300
                    onTriggered: {
                        winWidget.x = Qt.binding(function() { return winWidget.initX })
                        winWidget.y = Qt.binding(function() { return winWidget.initY })
                    }
                }
            }
        }
    }
}
