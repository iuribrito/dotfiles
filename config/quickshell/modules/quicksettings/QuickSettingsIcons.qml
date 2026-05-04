import QtQuick
import QtQuick.Layouts
import Quickshell
import "."

MouseArea {
    id: root
    implicitWidth: layout.width + 10
    implicitHeight: layout.height
    onClicked: QuickSettingsService.panelOpen = !QuickSettingsService.panelOpen

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 12

        // WiFi
        Text {
            text: QuickSettingsService.wifiEnabled ? "󰖩" : "󰖪"
            color: "#cba6f7"
            font.pixelSize: 14
        }

        // Bluetooth
        Text {
            text: QuickSettingsService.bluetoothEnabled ? "󰂯" : "󰂲"
            color: "#89b4fa"
            font.pixelSize: 14
        }

        // Volume
        Text {
            text: QuickSettingsService.muted ? "󰝟" : (QuickSettingsService.volume > 0.5 ? "󰕾" : "󰖀")
            color: "#f9e2af"
            font.pixelSize: 14
        }

        // Brilho
        Text {
            text: "󰃠"
            color: "#fab387"
            font.pixelSize: 14
        }
    }
}
