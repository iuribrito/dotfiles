import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Wayland
import "."
import "../theme"

PanelWindow {
    id: root
    property var modelData: null
    screen: modelData

    WlrLayershell.namespace: "quicksettings"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusiveZone: 0

    // Ocupa a tela inteira para capturar cliques fora do painel
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    
    visible: QuickSettingsService.panelOpen || container.height > 0
    color: "transparent"

    // Área que fecha o painel ao clicar fora
    MouseArea {
        anchors.fill: parent
        onClicked: QuickSettingsService.panelOpen = false
    }

    // A MÁGICA: Define qual parte da janela recebe cliques
    // Se estiver aberto, a tela toda recebe clique (para fechar ao clicar fora).
    // Se estiver fechando, apenas o painel recebe clique.
    mask: QuickSettingsService.panelOpen ? null : clickRegion

    Region {
        id: clickRegion
        item: container
    }

    Item {
        id: maskWrapper
        // Como a janela agora é tela cheia, posicionamos o conteúdo no canto
        anchors.top: parent.top
        anchors.right: parent.right
        width: 450
        height: 600

        // Bloqueia cliques para que clicar DENTRO do painel não o feche
        MouseArea {
            anchors.fill: container
            onClicked: (mouse) => { mouse.accepted = true }
        }

        // --- Cantos Invertidos (Fillets) ---
        Canvas {
            id: filletLeft
            width: 20; height: 20
            anchors.right: container.left
            anchors.top: container.top
            opacity: 1
            scale: QuickSettingsService.panelOpen ? 1 : 0
            transformOrigin: Item.TopRight
            // Behavior on opacity { NumberAnimation { duration: 400 } }
            Behavior on scale { NumberAnimation { duration: 1000; easing.type: Easing.OutBack } }
            onPaint: {
                var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = Theme.bgMain; ctx.beginPath();
                ctx.moveTo(0, 0); ctx.arcTo(20, 0, 20, 20, 20); ctx.lineTo(20, 0); ctx.closePath(); ctx.fill();
            }
        }

        Canvas {
            id: filletRight
            width: 20; height: 20
            anchors.left: container.right
            anchors.top: container.top
            opacity: 1
            scale: QuickSettingsService.panelOpen ? 1 : 0
            transformOrigin: Item.TopLeft
            // Behavior on opacity { NumberAnimation { duration: 400 } }
            Behavior on scale { NumberAnimation { duration: 1000; easing.type: Easing.OutBack } }
            onPaint: {
                var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = Theme.bgMain; ctx.beginPath();
                ctx.moveTo(20, 0); ctx.arcTo(0, 0, 0, 20, 20); ctx.lineTo(0, 0); ctx.closePath(); ctx.fill();
            }
        }

        Rectangle {
            id: container
            width: 330
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.top: parent.top
            
            height: QuickSettingsService.panelOpen ? (mainLayout.implicitHeight + 60) : 0
            clip: true
            color: Theme.bgMain
            radius: 20
            
            Rectangle {
                width: parent.width; height: 30; color: parent.color; anchors.top: parent.top
            }

            Behavior on height {
                NumberAnimation { duration: 700; easing.type: Easing.OutQuart }
            }

            ColumnLayout {
                id: mainLayout
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: 20
                spacing: 20
                opacity: QuickSettingsService.panelOpen ? 1 : 1
                y: QuickSettingsService.panelOpen ? 0 : -20
                // Behavior on opacity { NumberAnimation { duration: 300 } }
                Behavior on y { NumberAnimation { duration: 700; easing.type: Easing.OutQuart } }

                Text {
                    text: "CONFIGURAÇÕES"; color: Theme.primary; font.pixelSize: 11; font.bold: true
                    font.letterSpacing: 2; Layout.alignment: Qt.AlignHCenter; opacity: 0.6
                }

                ColumnLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 25; Layout.rightMargin: 25; spacing: 8
                    RowLayout {
                        Text { text: "󰕾"; color: Theme.primary; font.pixelSize: 16 }
                        Text { text: "Volume"; color: Theme.textMain; font.pixelSize: 12; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: Math.floor(QuickSettingsService.volume * 100) + "%"; color: Theme.textSub; font.pixelSize: 11 }
                    }
                    Slider { Layout.fillWidth: true; value: QuickSettingsService.volume; onMoved: QuickSettingsService.setVolume(value) }
                }

                ColumnLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 25; Layout.rightMargin: 25; spacing: 8
                    RowLayout {
                        Text { text: "󰃠"; color: Theme.orange; font.pixelSize: 16 }
                        Text { text: "Brilho"; color: Theme.textMain; font.pixelSize: 12; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: Math.floor(QuickSettingsService.brightness * 100) + "%"; color: Theme.textSub; font.pixelSize: 11 }
                    }
                    Slider { Layout.fillWidth: true; value: QuickSettingsService.brightness; onMoved: QuickSettingsService.setBrightness(value) }
                }

                RowLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 25; Layout.rightMargin: 25; Layout.bottomMargin: 20; spacing: 12
                    Rectangle {
                        Layout.fillWidth: true; height: 50; radius: 10; color: QuickSettingsService.wifiEnabled ? Theme.primary : Theme.bgSurface
                        RowLayout {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: "󰖩"; font.pixelSize: 16; color: QuickSettingsService.wifiEnabled ? Theme.bgMain : Theme.textMain }
                            Text { text: "Wi-Fi"; font.pixelSize: 10; font.bold: true; color: QuickSettingsService.wifiEnabled ? Theme.bgMain : Theme.textMain }
                        }
                        MouseArea { anchors.fill: parent; onClicked: QuickSettingsService.wifiEnabled = !QuickSettingsService.wifiEnabled }
                    }
                    Rectangle {
                        Layout.fillWidth: true; height: 50; radius: 10; color: QuickSettingsService.bluetoothEnabled ? Theme.blue : Theme.bgSurface
                        RowLayout {
                            anchors.centerIn: parent; spacing: 8
                            Text { text: "󰂯"; font.pixelSize: 16; color: QuickSettingsService.bluetoothEnabled ? Theme.bgMain : Theme.textMain }
                            Text { text: "Bluetooth"; font.pixelSize: 10; font.bold: true; color: QuickSettingsService.bluetoothEnabled ? Theme.bgMain : Theme.textMain }
                        }
                        MouseArea { anchors.fill: parent; onClicked: QuickSettingsService.bluetoothEnabled = !QuickSettingsService.bluetoothEnabled }
                    }
                }
            }
        }
    }
}
