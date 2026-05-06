import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import "../quicksettings" as QS
import "../theme"

PanelWindow {
    id: barRoot
    required property var modelData

    signal togglePowerMenu
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: 10
        left: 10
        right: 10
    }
    WlrLayershell.namespace: "bar"
    exclusiveZone: 35
    implicitHeight: 35
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Theme.bgMainAlpha
        radius: 10
    }

    Workspaces {}

    Clock {
        anchors.centerIn: parent
    }

    RowLayout {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        spacing: 15

        SystemMonitor {
            Layout.alignment: Qt.AlignVCenter
        }

        Tray {
            // Verificamos a contagem real de itens usando .values.length
            visible: SystemTray.items.values.length > 0
            parentWindow: barRoot
            Layout.alignment: Qt.AlignVCenter
        }

        QS.QuickSettingsIcons {
            Layout.alignment: Qt.AlignVCenter
        }

        Battery {
            Layout.alignment: Qt.AlignVCenter
        }

        PowerButton {
            onOpenMenu: barRoot.togglePowerMenu()
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
