import Quickshell
import QtQuick
import Quickshell.Services.SystemTray as SystemTrayService

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
    color: "#1a1b26"

    Workspaces {}

    Clock {
        anchors.centerIn: parent
    }

    Row {
        anchors.right: parent.right
        anchors.rightMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        spacing: 15

        SystemMonitor {}

        SystemTray {
            // Opcional: só mostra se tiver itens para não deixar buraco
            visible: SystemTrayService.items.count > 0
            parentWindow: barRoot
        }

        // Chamando o novo módulo de bateria
        Battery {}

        PowerButton {
            onOpenMenu: barRoot.togglePowerMenu()
        }
    }
}
