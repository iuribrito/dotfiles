import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import "."

Rectangle {
    id: root
    property var notification
    
    width: 300
    // Ajuste dinâmico de altura baseado no conteúdo
    height: Math.max(60, layout.implicitHeight + 20)
    
    color: "#1e1e2e" // Catppuccin Mocha Base
    radius: 10
    border.color: "#313244" // Catppuccin Mocha Surface0
    border.width: 1

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Ícone da aplicação ou da imagem da notificação
        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop
            color: "#313244"
            radius: 6
            visible: appIcon.source != ""

            Image {
                id: appIcon
                anchors.fill: parent
                anchors.margins: 4
                source: root.notification.appIcon || root.notification.image || ""
                fillMode: Image.PreserveAspectFit
            }
        }

        // Conteúdo de texto
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 4

            Text {
                text: root.notification.summary
                color: "#cba6f7" // Catppuccin Mocha Mauve
                font.bold: true
                font.pixelSize: 14
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: root.notification.body
                color: "#cdd6f4" // Catppuccin Mocha Text
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.pixelSize: 12
                lineHeight: 1.1
                // Remove o limite de linhas para não cortar
            }
        }

        // Botão Fechar
        MouseArea {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            Layout.alignment: Qt.AlignTop
            cursorShape: Qt.PointingHandCursor
            onClicked: NotificationService.removeNotification(root.notification)
            
            Text {
                anchors.centerIn: parent
                text: "󰅖" // Ícone de fechar (ou use "×" se não tiver Nerd Font)
                color: "#f38ba8" // Catppuccin Mocha Red
                font.pixelSize: 18
            }
        }
    }
}
