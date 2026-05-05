import QtQuick
import QtQuick.Layouts
import Quickshell
import "."
import "../theme"

Item {
    id: root
    implicitWidth: layout.width + 10
    implicitHeight: layout.height

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: QuickSettingsService.panelOpen = !QuickSettingsService.panelOpen
    }

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 12

        // WiFi
        Text {
            text: QuickSettingsService.wifiEnabled ? "󰖩" : "󰖪"
            color: Theme.primary
            font.pixelSize: 14
        }

        // Bluetooth
        Text {
            text: QuickSettingsService.bluetoothEnabled ? "󰂯" : "󰂲"
            color: Theme.blue
            font.pixelSize: 14
        }

        // Volume
        Text {
            text: QuickSettingsService.muted ? "󰝟" : (QuickSettingsService.volume > 0.5 ? "󰕾" : "󰖀")
            color: Theme.yellow
            font.pixelSize: 14
        }

        // Brilho
        Text {
            text: "󰃠"
            color: Theme.orange
            font.pixelSize: 14
        }
    }
}
