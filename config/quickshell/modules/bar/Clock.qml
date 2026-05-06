import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts  
import Quickshell
import Quickshell.Wayland
import "../theme"

Item {
    id: clockWidget
    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight
    
    // Variável para controlar a animação e o estado do calendário
    property bool isCalendarOpen: false

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        id: clockText
        text: Qt.formatDateTime(clock.date, " MMM dd  hh:mm")
        color: Theme.white
        font.pixelSize: 14
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: clockWidget.isCalendarOpen = !clockWidget.isCalendarOpen
    }

    PanelWindow {
        id: calendarWindow
        
        WlrLayershell.namespace: "calendar"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        // Ocupa a tela inteira para capturar cliques fora do calendário
        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        visible: clockWidget.isCalendarOpen || container.height > 0
        color: "transparent"

        // Área que fecha o calendário ao clicar fora
        MouseArea {
            anchors.fill: parent
            onClicked: clockWidget.isCalendarOpen = false
        }

        // Define qual parte da janela recebe cliques da mesma forma que o QS
        mask: clockWidget.isCalendarOpen ? null : clickRegion

        Region {
            id: clickRegion
            item: container
        }

        Item {
            id: maskWrapper
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: 360
            height: 600

            state: clockWidget.isCalendarOpen ? "open" : "closed"

            states: [
                State {
                    name: "open"
                    PropertyChanges { target: container; height: 350 }
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
                    PropertyChanges { target: mainLayout; opacity: 1 }
                }
            ]

            transitions: [
                Transition {
                    from: "closed"; to: "open"
                    ParallelAnimation {
                        NumberAnimation { target: container; property: "height"; duration: 400; easing.type: Easing.OutExpo }
                        NumberAnimation { target: filletLeft; property: "scale"; duration: 150; easing.type: Easing.OutQuad }
                        NumberAnimation { target: filletRight; property: "scale"; duration: 150; easing.type: Easing.OutQuad }
                        NumberAnimation { target: mainLayout; properties: "y,opacity"; duration: 500; easing.type: Easing.OutQuart }
                    }
                },
                Transition {
                    from: "open"; to: "closed"
                    ParallelAnimation {
                        NumberAnimation { target: container; property: "height"; duration: 300; easing.type: Easing.InExpo }
                        NumberAnimation { target: mainLayout; properties: "y,opacity"; duration: 300; easing.type: Easing.InQuart }
                        
                        SequentialAnimation {
                            PauseAnimation { duration: 155 }
                            NumberAnimation { target: filletLeft; property: "scale"; duration: 150; easing.type: Easing.InQuad }
                        }
                        
                        SequentialAnimation {
                            PauseAnimation { duration: 155 }
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

            // --- Cantos Invertidos (Fillets) da esquerda ---
            Canvas {
                id: filletLeft
                width: 20; height: 20
                anchors.right: container.left
                anchors.top: container.top
                opacity: 1
                scale: 0
                transformOrigin: Item.TopRight
                onPaint: {
                    var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = Theme.bgMain; ctx.beginPath();
                    ctx.moveTo(0, 0); ctx.arcTo(20, 0, 20, 20, 20); ctx.lineTo(20, 0); ctx.closePath(); ctx.fill();
                }
            }

            // --- Cantos Invertidos (Fillets) da direita ---
            Canvas {
                id: filletRight
                width: 20; height: 20
                anchors.left: container.right
                anchors.top: container.top
                opacity: 1
                scale: 0
                transformOrigin: Item.TopLeft
                onPaint: {
                    var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = Theme.bgMain; ctx.beginPath();
                    ctx.moveTo(20, 0); ctx.arcTo(0, 0, 0, 20, 20); ctx.lineTo(0, 0); ctx.closePath(); ctx.fill();
                }
            }

            Item {
                id: container
                width: 320
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                
                height: 0
                clip: true

                // Fundo com arredondamento apenas embaixo (usando margem negativa em cima)
                Rectangle {
                    id: containerBg
                    anchors.fill: parent
                    anchors.topMargin: -20
                    color: Theme.bgMain
                    radius: 20
                }

                // --- VARIÁVEIS DE NAVEGAÇÃO ---
                property int mesVisualizado: clock.date.getMonth()
                property int anoVisualizado: clock.date.getFullYear()

                // Toda vez que você abre o calendário, ele volta pro dia de hoje
                onHeightChanged: {
                    if (height === 350) {
                        mesVisualizado = clock.date.getMonth()
                        anoVisualizado = clock.date.getFullYear()
                    }
                }

                ColumnLayout {
                    id: mainLayout
                    width: parent.width
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    spacing: 10
                    
                    opacity: 0
                    y: -20

                    // --- CABEÇALHO COM NAVEGAÇÃO ---
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16

                        // Botão Voltar
                        Text {
                            text: ""
                            color: Theme.blueTokyo
                            font.pixelSize: 18
                            font.bold: true
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (container.mesVisualizado === 0) {
                                        container.mesVisualizado = 11
                                        container.anoVisualizado--
                                    } else {
                                        container.mesVisualizado--
                                    }
                                }
                            }
                        }

                        // Título do Mês/Ano (Clique nele para voltar para hoje!)
                        Text {
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            text: Qt.formatDateTime(new Date(container.anoVisualizado, container.mesVisualizado, 1), "MMMM yyyy")
                            color: Theme.blueTokyo
                            font.pixelSize: 18
                            font.bold: true
                            font.capitalization: Font.Capitalize

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    container.mesVisualizado = clock.date.getMonth()
                                    container.anoVisualizado = clock.date.getFullYear()
                                }
                            }
                        }

                        // Botão Avançar
                        Text {
                            text: ""
                            color: Theme.blueTokyo
                            font.pixelSize: 18
                            font.bold: true
                            
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (container.mesVisualizado === 11) {
                                        container.mesVisualizado = 0
                                        container.anoVisualizado++
                                    } else {
                                        container.mesVisualizado++
                                    }
                                }
                            }
                        }
                    }

                    DayOfWeekRow {
                        Layout.fillWidth: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        locale: Qt.locale("pt_BR") 
                        delegate: Text {
                            text: model.shortName
                            font.pixelSize: 14
                            font.bold: true
                            color: Theme.blueMuted
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    MonthGrid {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.leftMargin: 16
                        Layout.rightMargin: 16
                        locale: Qt.locale("pt_BR")
                        
                        month: container.mesVisualizado
                        year: container.anoVisualizado

                        delegate: Rectangle {
                            width: 35
                            height: 35
                            radius: 8
                            
                            color: model.today ? Theme.blueTokyo : "transparent"
                            
                            Text {
                                anchors.centerIn: parent
                                text: model.day
                                color: model.today ? Theme.bgMain : (model.month === container.mesVisualizado ? Theme.textMain : Theme.textMuted)
                                font.pixelSize: 14
                                font.bold: model.today
                            }
                        }
                    }
                }
            }
        }
    }
}
