import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell.Wayland
import "."
import "../theme"
import "../notifications"

PanelWindow {
    id: root
    property var modelData: null
    screen: modelData

    WlrLayershell.namespace: "quicksettings"
    WlrLayershell.layer: WlrLayer.Top
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

        // heightProxy quebra o binding loop:
        // PropertyChanges binding para mainLayout.implicitHeight (filho de container) faz o engine
        // de layout re-emitir implicitHeightChanged ao re-layoutar container, criando loop.
        // Usando um QtObject atualizado imperativamente via Connections, o detector de loop
        // não consegue traçar o ciclo (ele só segue bindings declarativos, não assignments).
        QtObject { id: heightProxy; property real value: 0 }
        Connections {
            target: mainLayout
            function onImplicitHeightChanged() { heightProxy.value = mainLayout.implicitHeight }
        }
        Component.onCompleted: heightProxy.value = mainLayout.implicitHeight

        state: QuickSettingsService.panelOpen ? "open" : "closed"

        states: [
            State {
                name: "open"
                PropertyChanges { target: container; height: heightProxy.value + 60 }
                PropertyChanges { target: filletLeft; scale: 1 }
                PropertyChanges { target: filletRight; scale: 1 }
                PropertyChanges { target: mainLayout; y: 0 }
                PropertyChanges { target: mainLayout; opacity: 1 }
            },
            State {
                name: "closed"
                PropertyChanges { target: container; height: 0 }
                PropertyChanges { target: filletLeft; scale: 0 }
                PropertyChanges { target: filletRight; scale: 0 }
                PropertyChanges { target: mainLayout; y: -20 }
                PropertyChanges { target: mainLayout; opacity: 0 }
            }
        ]

        transitions: [
            Transition {
                from: "closed"; to: "open"
                ParallelAnimation {
                    NumberAnimation { target: container; property: "height"; duration: 400; easing.type: Easing.OutExpo }
                    NumberAnimation { target: filletLeft; property: "scale"; duration: 150; easing.type: Easing.OutQuad }
                    NumberAnimation { target: filletRight; property: "scale"; duration: 150; easing.type: Easing.OutQuad }
                    
                    SequentialAnimation {
                        PauseAnimation { duration: 50 }
                        NumberAnimation { target: mainLayout; properties: "y,opacity"; duration: 500; easing.type: Easing.OutQuart }
                    }
                }
            },
            Transition {
                from: "open"; to: "closed"
                ParallelAnimation {
                    NumberAnimation { target: container; property: "height"; duration: 300; easing.type: Easing.InExpo }
                    NumberAnimation { target: mainLayout; properties: "y,opacity"; duration: 300; easing.type: Easing.InQuart }
                    
                    SequentialAnimation {
                        PauseAnimation { duration: 150 }
                        NumberAnimation { target: filletLeft; property: "scale"; duration: 150; easing.type: Easing.InQuad }
                    }
                    
                    SequentialAnimation {
                        PauseAnimation { duration: 150 }
                        NumberAnimation { target: filletRight; property: "scale"; duration: 150; easing.type: Easing.InQuad }
                    }
                }
            }
        ]

        // Bloqueia cliques para que clicar DENTRO do painel não o feche
        MouseArea {
            anchors.fill: container
            onClicked: (mouse) => { mouse.accepted = true }
        }

        // RectangularShadow {
        //     anchors.left: container.left
        //     anchors.right: container.right
        //     anchors.top: container.top
        //     height: container.height
        //     radius: 20
        //     blur: 32
        //     spread: 2
        //     color: "#BB000000"
        //     offset: Qt.vector2d(0, 6)
        //     cached: true
        // }

        // --- Cantos Invertidos (Fillets) ---
        Canvas {
            id: filletLeft
            width: 20; height: 20
            anchors.right: container.left
            anchors.top: container.top
            opacity: 1
            scale: 0
            transformOrigin: Item.TopRight
            onPaint: {
                var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = Theme.bgMainAlpha; ctx.beginPath();
                ctx.moveTo(0, 0); ctx.arcTo(20, 0, 20, 20, 20); ctx.lineTo(20, 0); ctx.closePath(); ctx.fill();
            }
        }

        Canvas {
            id: filletRight
            width: 20; height: 20
            anchors.left: container.right
            anchors.top: container.top
            opacity: 1
            scale: 0
            transformOrigin: Item.TopLeft
            onPaint: {
                var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = Theme.bgMainAlpha; ctx.beginPath();
                ctx.moveTo(20, 0); ctx.arcTo(0, 0, 0, 20, 20); ctx.lineTo(0, 0); ctx.closePath(); ctx.fill();
            }
        }

        Item {
            id: container
            width: 330
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.top: parent.top
            
            height: 0
            clip: true

            Rectangle {
                id: containerBg
                anchors.fill: parent
                anchors.topMargin: -20
                color: Theme.bgMainAlpha
                radius: 20
            }

            ColumnLayout {
                id: mainLayout
                width: parent.width
                anchors.top: parent.top
                anchors.topMargin: 30
                spacing: 20
                opacity: 0
                y: -20

                ColumnLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 25; Layout.rightMargin: 25; spacing: 8
                    RowLayout {
                        Text {
                            text: QuickSettingsService.muted ? "󰖁" : "󰕾"
                            color: QuickSettingsService.muted ? Theme.textSub : Theme.primary
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: QuickSettingsService.toggleMute()
                            }
                        }
                        Text { text: "Volume"; color: Theme.textMain; font.pixelSize: 12; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: Math.floor(QuickSettingsService.volume * 100) + "%"; color: Theme.textSub; font.pixelSize: 11; opacity: QuickSettingsService.muted ? 0.4 : 1.0 }
                    }
                    SliderCustom {
                        Layout.fillWidth: true
                        value: QuickSettingsService.volume
                        onMoved: QuickSettingsService.setVolume(value)
                        fillColor: Theme.primary
                        opacity: QuickSettingsService.muted ? 0.4 : 1.0
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 25; Layout.rightMargin: 25; spacing: 8
                    RowLayout {
                        Text {
                            text: QuickSettingsService.micMuted ? "󰍭" : "󰍬"
                            color: QuickSettingsService.micMuted ? Theme.textSub : Theme.red
                            font.pixelSize: 16
                            font.family: "JetBrainsMono Nerd Font"
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: QuickSettingsService.toggleMicMute()
                            }
                        }
                        Text { text: "Microfone"; color: Theme.textMain; font.pixelSize: 12; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: Math.floor(QuickSettingsService.micVolume * 100) + "%"; color: Theme.textSub; font.pixelSize: 11; opacity: QuickSettingsService.micMuted ? 0.4 : 1.0 }
                    }
                    SliderCustom {
                        Layout.fillWidth: true
                        value: QuickSettingsService.micVolume
                        onMoved: QuickSettingsService.setMicVolume(value)
                        fillColor: Theme.red
                        opacity: QuickSettingsService.micMuted ? 0.4 : 1.0
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 25; Layout.rightMargin: 25; spacing: 8
                    RowLayout {
                        Text { text: "󰃠"; color: Theme.orange; font.pixelSize: 16 }
                        Text { text: "Brilho"; color: Theme.textMain; font.pixelSize: 12; font.bold: true }
                        Item { Layout.fillWidth: true }
                        Text { text: Math.floor(QuickSettingsService.brightness * 100) + "%"; color: Theme.textSub; font.pixelSize: 11 }
                    }
                    SliderCustom { Layout.fillWidth: true; value: QuickSettingsService.brightness; onMoved: QuickSettingsService.setBrightness(value); fillColor: Theme.orange }
                }

                RowLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 25; Layout.rightMargin: 25; spacing: 0

                    Item { Layout.fillWidth: true }

                    // Wi-Fi
                    Rectangle {
                        width: 50; height: 50; radius: 25
                        color: QuickSettingsService.wifiEnabled ? Theme.primary : Theme.bgSurface
                        Text {
                            anchors.centerIn: parent
                            text: "󰖩"
                            font.pixelSize: 20
                            font.family: "JetBrainsMono Nerd Font"
                            color: QuickSettingsService.wifiEnabled ? Theme.bgMain : Theme.textMain
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: QuickSettingsService.toggleWifi() }
                    }

                    Item { Layout.fillWidth: true }

                    // Bluetooth
                    Rectangle {
                        width: 50; height: 50; radius: 25
                        color: QuickSettingsService.bluetoothEnabled ? Theme.blue : Theme.bgSurface
                        Text {
                            anchors.centerIn: parent
                            text: "󰂯"
                            font.pixelSize: 20
                            font.family: "JetBrainsMono Nerd Font"
                            color: QuickSettingsService.bluetoothEnabled ? Theme.bgMain : Theme.textMain
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: QuickSettingsService.toggleBluetooth() }
                    }

                    Item { Layout.fillWidth: true }

                    // VPN
                    Rectangle {
                        width: 50; height: 50; radius: 25
                        color: QuickSettingsService.vpnActive ? Theme.orange : Theme.bgSurface
                        Text {
                            anchors.centerIn: parent
                            text: "󰒍"
                            font.pixelSize: 20
                            font.family: "JetBrainsMono Nerd Font"
                            color: QuickSettingsService.vpnActive ? Theme.bgMain : Theme.textMain
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: QuickSettingsService.toggleVpn() }
                    }

                    Item { Layout.fillWidth: true }

                    // Hypridle
                    Rectangle {
                        width: 50; height: 50; radius: 25
                        color: QuickSettingsService.hypridleActive ? Theme.yellow : Theme.bgSurface
                        Text {
                            anchors.centerIn: parent
                            text: "󰤄"
                            font.pixelSize: 20
                            font.family: "JetBrainsMono Nerd Font"
                            color: QuickSettingsService.hypridleActive ? Theme.bgMain : Theme.textMain
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: QuickSettingsService.toggleHypridle() }
                    }

                    Item { Layout.fillWidth: true }

                    // DND (Não Perturbe)
                    Rectangle {
                        width: 50; height: 50; radius: 25
                        color: NotificationService.doNotDisturb ? Theme.red : Theme.bgSurface
                        Text {
                            anchors.centerIn: parent
                            text: NotificationService.doNotDisturb ? "󰂛" : "󰂚"
                            font.pixelSize: 20
                            font.family: "JetBrainsMono Nerd Font"
                            color: NotificationService.doNotDisturb ? Theme.bgMain : Theme.textMain
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: NotificationService.toggleDND() }
                    }

                    Item { Layout.fillWidth: true }
                }

                Rectangle {
                    Layout.fillWidth: true; Layout.leftMargin: 25; Layout.rightMargin: 25
                    height: 1; color: Theme.bgSurface
                }

                RowLayout {
                    Layout.fillWidth: true; Layout.leftMargin: 25; Layout.rightMargin: 25

                    Text {
                        text: "NOTIFICAÇÕES"; color: Theme.blue; font.pixelSize: 11; font.bold: true
                        font.letterSpacing: 2; opacity: 0.6
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        visible: NotificationService.history.length > 0
                        text: NotificationService.history.length
                        color: Theme.textMuted; font.pixelSize: 11
                    }
                    Item { width: 4 }
                    MouseArea {
                        width: 20; height: 20
                        visible: NotificationService.history.length > 0
                        cursorShape: Qt.PointingHandCursor
                        onClicked: NotificationService.clearHistory()
                        Text { anchors.centerIn: parent; text: "󰅖"; color: Theme.textMuted; font.pixelSize: 14 }
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.leftMargin: 15; Layout.rightMargin: 15
                    Layout.bottomMargin: 20
                    // Altura calculada pelo count × delegate fixo (54 = 48px + 6px spacing)
                    // evita dependência de contentHeight que causaria binding loop via container.height
                    implicitHeight: NotificationService.history.length === 0
                        ? 36
                        : Math.min(NotificationService.history.length * 54 - 6, 220)
                    clip: true

                    Text {
                        visible: NotificationService.history.length === 0
                        anchors.centerIn: parent
                        text: "Nenhuma notificação"; color: Theme.textMuted; font.pixelSize: 12; opacity: 0.5
                    }

                    ListView {
                        id: notifList
                        width: parent.width
                        height: parent.height
                        visible: NotificationService.history.length > 0
                        model: NotificationService.history
                        spacing: 6
                        clip: true
                        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                        delegate: Rectangle {
                            width: ListView.view.width
                            height: 48
                            radius: 8
                            color: Theme.bgSurface

                            RowLayout {
                                anchors.fill: parent; anchors.margins: 10; spacing: 8

                                Rectangle {
                                    width: 28; height: 28; radius: 6; color: Theme.bgHover
                                    visible: modelData.appIcon !== ""
                                    Image {
                                        anchors.fill: parent; anchors.margins: 4
                                        source: {
                                            if (!modelData.appIcon) return "";
                                            if (modelData.appIcon.startsWith("/") || modelData.appIcon.startsWith("file://")) return modelData.appIcon;
                                            return Quickshell.iconPath(modelData.appIcon, "image-missing");
                                        }
                                        fillMode: Image.PreserveAspectFit; asynchronous: true; sourceSize: Qt.size(20, 20)
                                    }
                                }
                                Text {
                                    visible: modelData.appIcon === ""
                                    text: "󰂚"; color: Theme.textMuted; font.pixelSize: 16
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true; spacing: 2
                                    Text {
                                        text: modelData.summary || modelData.appName || "Notificação"
                                        color: Theme.textMain; font.pixelSize: 12; font.bold: true
                                        Layout.fillWidth: true; elide: Text.ElideRight
                                    }
                                    Text {
                                        visible: modelData.body !== ""
                                        text: modelData.body || ""
                                        color: Theme.textSub; font.pixelSize: 10
                                        Layout.fillWidth: true; elide: Text.ElideRight
                                        maximumLineCount: 1
                                    }
                                }

                                Text {
                                    text: modelData.time
                                    color: Theme.textMuted; font.pixelSize: 10
                                    Layout.alignment: Qt.AlignTop
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

