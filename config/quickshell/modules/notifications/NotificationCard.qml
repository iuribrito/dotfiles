import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "."
import "../theme"

Rectangle {
    id: root
    property var notification
    
    width: 300
    // Ajuste dinâmico de altura baseado no conteúdo
    height: Math.max(60, layout.implicitHeight + 20)
    
    color: Theme.bgMain // Catppuccin Mocha Base
    radius: 10
    border.color: Theme.bgSurface // Catppuccin Mocha Surface0
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
            color: Theme.bgSurface
            radius: 6
            visible: appIcon.source != ""

            Image {
                id: appIcon
                anchors.fill: parent
                anchors.margins: 4
                
                source: {
                    if (root.notification.image) {
                        return root.notification.image;
                    }
                    if (root.notification.appIcon) {
                        if (root.notification.appIcon.startsWith("/") || root.notification.appIcon.startsWith("file://")) {
                            return root.notification.appIcon;
                        }
                        // Quickshell.iconPath procura o ícone no tema do sistema e retorna o caminho real
                        return Quickshell.iconPath(root.notification.appIcon, "image-missing");
                    }
                    return "";
                }
                
                // Configurações padrão de imagem
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                sourceSize: Qt.size(24, 24)
            }
        }

        // Conteúdo de texto
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            spacing: 4

            Text {
                text: root.notification.summary
                color: Theme.primary // Catppuccin Mocha Mauve
                font.bold: true
                font.pixelSize: 14
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Text {
                text: root.notification.body
                color: Theme.textMain // Catppuccin Mocha Text
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
                color: Theme.red // Catppuccin Mocha Red
                font.pixelSize: 18
            }
        }
    }
}
