import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"

Scope {
    id: overviewScope
    required property var modelData

    GlobalShortcut {
        name: "overviewToggle"
        description: "Toggle window overview"
        onPressed: GlobalStates.overviewOpen = !GlobalStates.overviewOpen
    }

    PanelWindow {
        id: panelRoot

        visible: GlobalStates.overviewOpen
        screen: overviewScope.modelData

        WlrLayershell.namespace: "quickshell:overview"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: GlobalStates.overviewOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        color: "transparent"
        anchors { top: true; bottom: true; left: true; right: true }

        Item {
            anchors.fill: parent
            focus: panelRoot.visible

            Keys.onPressed: function(event) {
                if (event.key === Qt.Key_Escape) {
                    GlobalStates.overviewOpen = false
                    event.accepted = true
                } else if (event.key === Qt.Key_Tab) {
                    Hyprland.dispatch("workspace r+1")
                    event.accepted = true
                } else if (event.key === Qt.Key_Backtab) {
                    Hyprland.dispatch("workspace r-1")
                    event.accepted = true
                } else if (event.key === Qt.Key_Left) {
                    Hyprland.dispatch("workspace r-1")
                } else if (event.key === Qt.Key_Right) {
                    Hyprland.dispatch("workspace r+1")
                }
            }

            // Dimmed backdrop – click closes the overview
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0, 0, 0, 0.45)
                z: 0

                MouseArea {
                    anchors.fill: parent
                    onClicked: GlobalStates.overviewOpen = false
                }
            }

            // Overview card – click inside stays open
            OverviewWidget {
                screen: overviewScope.modelData
                anchors.centerIn: parent
                z: 1

                opacity: GlobalStates.overviewOpen ? 1 : 0
                scale: GlobalStates.overviewOpen ? 1 : 0.94
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuint } }
                Behavior on scale   { NumberAnimation { duration: 180; easing.type: Easing.OutQuint } }
            }
        }
    }
}
