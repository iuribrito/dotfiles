import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray as SystemTrayService
import "../quicksettings" as QS

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
    implicitHeight: 35
    color: "#1e1e2e"

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

        SystemTray {
            visible: SystemTrayService.items.count > 0
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
