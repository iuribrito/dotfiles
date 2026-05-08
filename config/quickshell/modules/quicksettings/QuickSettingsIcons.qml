import QtQuick
import QtQuick.Layouts
import Quickshell
import "."
import "../theme"

Item {
    id: root
    implicitWidth: layout.width + 20
    implicitHeight: layout.height

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: QuickSettingsService.panelOpen = !QuickSettingsService.panelOpen
    }

    Rectangle {
        width: 100 // Largura total da barra de progresso aumentada
        height: 24 // Fica mais fina e elegante
        radius: 5
        color: Theme.bgMain // Cor de fundo (vazio)
        anchors.verticalCenter: parent.verticalCenter

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
                color: Theme.primary
                font.pixelSize: 14
            }

            // Volume
            Text {
                text: QuickSettingsService.muted ? "󰝟" : (QuickSettingsService.volume > 0.5 ? "󰕾" : "󰖀")
                color: Theme.primary
                font.pixelSize: 14
            }

            // Microfone
            Text {
                text: QuickSettingsService.micMuted ? "󰍭" : "󰍬"
                color: QuickSettingsService.micMuted ? Theme.textSub : Theme.primary
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
            }
        }
    }
}
