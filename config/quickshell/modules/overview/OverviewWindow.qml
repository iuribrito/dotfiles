import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"

Rectangle {
    id: root

    property var toplevel
    property var windowData
    property var monitorData
    property var widgetMonitor
    property real scale: 0.13
    property real xOffset: 0
    property real yOffset: 0
    property bool hovered: false
    property bool pressed: false

    readonly property real targetWindowWidth: Math.max((windowData?.size[0] ?? 80) * scale, 20)
    readonly property real targetWindowHeight: Math.max((windowData?.size[1] ?? 60) * scale, 15)
    readonly property real initX: {
        if (!windowData || !monitorData) return xOffset
        return Math.max((windowData.at[0] - monitorData.x) * scale, 0) + xOffset
    }
    readonly property real initY: {
        if (!windowData || !monitorData) return yOffset
        return Math.max((windowData.at[1] - monitorData.y) * scale, 0) + yOffset
    }

    x: initX
    y: initY
    width: targetWindowWidth
    height: targetWindowHeight
    radius: 5
    clip: true
    color: Theme.bgSurface

    ScreencopyView {
        anchors.fill: parent
        captureSource: GlobalStates.overviewOpen ? root.toplevel : null
        live: true
    }

    // Hover/press overlay
    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.pressed ? Qt.rgba(1, 1, 1, 0.18)
             : root.hovered ? Qt.rgba(1, 1, 1, 0.09)
             : "transparent"
        border.color: Qt.rgba(1, 1, 1, 0.12)
        border.width: 1
    }

    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutQuint } }
    Behavior on y { NumberAnimation { duration: 150; easing.type: Easing.OutQuint } }
    Behavior on width  { NumberAnimation { duration: 150; easing.type: Easing.OutQuint } }
    Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutQuint } }
}
