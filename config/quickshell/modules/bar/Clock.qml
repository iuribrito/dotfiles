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
                scale: clockWidget.isCalendarOpen ? 1 : 0
                transformOrigin: Item.TopRight
                Behavior on scale { NumberAnimation { duration: 1000; easing.type: Easing.OutBack } }
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
                scale: clockWidget.isCalendarOpen ? 1 : 0
                transformOrigin: Item.TopLeft
                Behavior on scale { NumberAnimation { duration: 1000; easing.type: Easing.OutBack } }
                onPaint: {
                    var ctx = getContext("2d"); ctx.reset(); ctx.fillStyle = Theme.bgMain; ctx.beginPath();
                    ctx.moveTo(20, 0); ctx.arcTo(0, 0, 0, 20, 20); ctx.lineTo(0, 0); ctx.closePath(); ctx.fill();
                }
            }

            Rectangle {
                id: container
                width: 320
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                
                // Anima a altura
                height: clockWidget.isCalendarOpen ? 350 : 0
                clip: true
                color: Theme.bgMain
                radius: 20
                
                // Esconde o arredondamento na parte de cima para grudar na barra
                Rectangle {
                    width: parent.width; height: 30; color: parent.color; anchors.top: parent.top
                }

                Behavior on height {
                    NumberAnimation { duration: 700; easing.type: Easing.OutQuart }
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
                    
                    // Animação de descer o conteúdo
                    opacity: clockWidget.isCalendarOpen ? 1 : 1
                    y: clockWidget.isCalendarOpen ? 0 : -20
                    Behavior on y { NumberAnimation { duration: 700; easing.type: Easing.OutQuart } }

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
