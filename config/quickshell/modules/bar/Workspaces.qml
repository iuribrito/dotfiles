import QtQuick
import Quickshell
import Quickshell.Hyprland
import "../overview"

Row {
    id: wsList
    anchors.left: parent.left
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: 10
    spacing: 8

    Repeater {
        model: 10

        delegate: Rectangle {
            id: wsRect

            property int wsNumber: index + 1

            // Verifica se o workspace atual é o focado
            property bool isFocused: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id === wsNumber

            // Melhora a detecção de janelas: procuramos o workspace na lista do Hyprland
            // e verificamos se ele existe (o que no Hyprland significa que tem janelas ou foco)
            // Dentro do Workspaces.qml
            property bool hasWindows: {
                if (!Hyprland.workspaces.values)
                    return false;
                return Hyprland.workspaces.values.some(ws => ws.id === wsNumber);
            }

            width: isFocused ? 30 : 12
            height: 12
            radius: 6

            // Cores baseadas no estado
            color: {
                if (isFocused)
                    return "#7aa2f7";  // Azul para o atual
                if (hasWindows)
                    return "#bb9af7"; // Roxo para os que têm janelas
                return "#3b4261";                 // Cinza para vazios
            }

            Behavior on width {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutQuint
                }
            }
            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: function(mouse) {
                    if (mouse.button === Qt.RightButton)
                        GlobalStates.overviewOpen = !GlobalStates.overviewOpen
                    else
                        Hyprland.dispatch(`workspace ${wsNumber}`)
                }
            }
        }
    }
}
