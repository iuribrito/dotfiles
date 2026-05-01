import Quickshell
import QtQuick
import Quickshell.Wayland
import "."

PanelWindow {
    id: root
    property var modelData: null
    screen: modelData

    WlrLayershell.namespace: "notifications"
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        right: true
    }

    width: 320
    height: content.height + 20
    color: "transparent"

    Column {
        id: content
        width: 300
        spacing: 10
        anchors.right: parent.right
        anchors.margins: 10

        Repeater {
            model: NotificationService.notifications
            delegate: NotificationCard {
                notification: modelData
            }
        }
    }
}
