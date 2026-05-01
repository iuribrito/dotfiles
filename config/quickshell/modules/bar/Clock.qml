import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts  
import Quickshell

Item {
    id: clockWidget
    implicitWidth: clockText.implicitWidth
    implicitHeight: clockText.implicitHeight

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Text {
        id: clockText
        text: Qt.formatDateTime(clock.date, " MMM dd  hh:mm")
        color: "white"
        font.pixelSize: 14
        font.bold: true
        font.family: "JetBrainsMono Nerd Font"
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: calendarWindow.visible = !calendarWindow.visible
    }

    PanelWindow {
        id: calendarWindow
        visible: false 
        color: "transparent"
        exclusiveZone: -1 
        
        // --- VARIÁVEIS DE NAVEGAÇÃO ---
        property int mesVisualizado: clock.date.getMonth()
        property int anoVisualizado: clock.date.getFullYear()

        // Toda vez que você abre o calendário, ele volta pro dia de hoje
        onVisibleChanged: {
            if (visible) {
                mesVisualizado = clock.date.getMonth()
                anoVisualizado = clock.date.getFullYear()
            }
        }

        implicitWidth: 300
        implicitHeight: 320
        
        // --- A MÁGICA DE CENTRALIZAR ---
        anchors {
            top: true
            // Sem 'right: true' e sem 'left: true', o Hyprland centraliza na tela!
        }

        margins {
            top: 50    
            // Tirei a margem direita para ficar perfeitamente no centro
        }

        Rectangle {
            anchors.fill: parent
            color: "#1a1b26" 
            radius: 12
            border.color: "#414868"
            border.width: 2

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                // --- CABEÇALHO COM NAVEGAÇÃO ---
                RowLayout {
                    Layout.fillWidth: true

                    // Botão Voltar
                    Text {
                        text: "" // Ícone de seta do Nerd Fonts (ou use "<")
                        color: "#7aa2f7"
                        font.pixelSize: 18
                        font.bold: true
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (calendarWindow.mesVisualizado === 0) {
                                    calendarWindow.mesVisualizado = 11
                                    calendarWindow.anoVisualizado--
                                } else {
                                    calendarWindow.mesVisualizado--
                                }
                            }
                        }
                    }

                    // Título do Mês/Ano (Clique nele para voltar para hoje!)
                    Text {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        // Criamos uma data "falsa" só para o Qt formatar o nome do mês certinho
                        text: Qt.formatDateTime(new Date(calendarWindow.anoVisualizado, calendarWindow.mesVisualizado, 1), "MMMM yyyy")
                        color: "#7aa2f7"
                        font.pixelSize: 18
                        font.bold: true
                        font.capitalization: Font.Capitalize

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                calendarWindow.mesVisualizado = clock.date.getMonth()
                                calendarWindow.anoVisualizado = clock.date.getFullYear()
                            }
                        }
                    }

                    // Botão Avançar
                    Text {
                        text: "" // Ícone de seta do Nerd Fonts (ou use ">")
                        color: "#7aa2f7"
                        font.pixelSize: 18
                        font.bold: true
                        
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (calendarWindow.mesVisualizado === 11) {
                                    calendarWindow.mesVisualizado = 0
                                    calendarWindow.anoVisualizado++
                                } else {
                                    calendarWindow.mesVisualizado++
                                }
                            }
                        }
                    }
                }

                DayOfWeekRow {
                    Layout.fillWidth: true
                    locale: Qt.locale("pt_BR") 
                    delegate: Text {
                        text: model.shortName
                        font.pixelSize: 14
                        font.bold: true
                        color: "#565f89"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }

                MonthGrid {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    locale: Qt.locale("pt_BR")
                    
                    // Agora ele obedece as nossas variáveis, não o relógio!
                    month: calendarWindow.mesVisualizado
                    year: calendarWindow.anoVisualizado

                    delegate: Rectangle {
                        width: 35
                        height: 35
                        radius: 8
                        
                        // Fica azulzinho só no dia exato de hoje
                        color: model.today ? "#7aa2f7" : "transparent"
                        
                        Text {
                            anchors.centerIn: parent
                            text: model.day
                            // Deixa os dias de outros meses bem escuros para não confundir
                            color: model.today ? "#1a1b26" : (model.month === calendarWindow.mesVisualizado ? "#c0caf5" : "#414868")
                            font.pixelSize: 14
                            font.bold: model.today
                        }
                    }
                }
            }
        }
    }
}
