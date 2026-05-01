import QtQuick
import Quickshell
import Quickshell.Io

PanelWindow {
    id: pmRoot
    required property var modelData
    required property bool isVisible
    signal close()

    screen: modelData
    visible: isVisible

    anchors {
        top: true; bottom: true; left: true; right: true
    }

    color: "transparent"
    exclusiveZone: -1

    // Fundo escurecido que pode ser clicado para fechar
    MouseArea {
        anchors.fill: parent
        onClicked: pmRoot.close()
        
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: pmRoot.isVisible ? 0.3 : 0.0
            Behavior on opacity { NumberAnimation { duration: 300 } }
        }
    }

    // --- O CONTAINER DO MENU (A "Pílula" Flutuante) ---
    Rectangle {
        id: sidebar
        width: 70
        // A altura se adapta automaticamente à quantidade de botões + margens
        height: menuCol.implicitHeight + 30 
        radius: 20
        
        // Cor de fundo levemente rosada/clara igual ao do seu print
        color: "#f5eceb" 

        anchors.verticalCenter: parent.verticalCenter
        
        // A MÁGICA DA ANIMAÇÃO CERTA:
        // Prende na direita e anima a margem. 
        // Se visível = 20px de distância da borda. Se não = -100px (escondido fora da tela)
        anchors.right: parent.right
        anchors.rightMargin: pmRoot.isVisible ? 20 : -100
        
        Behavior on anchors.rightMargin { 
            NumberAnimation { duration: 400; easing.type: Easing.OutExpo } 
        }

        // --- OS BOTÕES NA VERTICAL ---
        Column {
            id: menuCol
            anchors.centerIn: parent
            spacing: 12

            // Componente de Botão Redondo/Quadrado
            component MenuBtn: Rectangle {
                id: btn
                property string iconTxt
                property string cmd
                property string hoverColor

                width: 46; height: 46
                radius: 12 // Bordas arredondadas do botão
                
                // Fundo do botão muda suavemente ao passar o mouse
                color: btnArea.containsMouse ? "#e6dada" : "transparent"
                Behavior on color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: btn.iconTxt
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 22
                    // Fica escuro normal, e pega a cor do hover (vermelho/azul) quando passa o mouse
                    color: btnArea.containsMouse ? btn.hoverColor : "#4a4a4a"
                }

                MouseArea {
                    id: btnArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Process.start("sh", ["-c", btn.cmd]);
                        pmRoot.close();
                    }
                }
            }

            // --- SEUS BOTÕES NA ORDEM DO PRINT ---
            
            // Logout (Seta saindo)
            MenuBtn { iconTxt: "󰍃"; cmd: "hyprctl dispatch exit"; hoverColor: "#f7768e" }
            
            // Power (Desligar)
            MenuBtn { iconTxt: ""; cmd: "systemctl poweroff"; hoverColor: "#f7768e" }
            
            // A PERSONAGEM CHIBI DO MEIO
            // Se você tiver a imagem, coloque o caminho na propriedade 'source'
            // Se não tiver, basta apagar este bloco Image
            Image {
                // Exemplo: source: "file:///home/seu_usuario/Imagens/chibi.png"
                source: "" 
                width: 46
                height: 46
                fillMode: Image.PreserveAspectFit
                // Só mostra se você colocar um caminho válido
                visible: source != "" 
            }

            // Suspender (Seta para baixo no print, ou pode usar a lua "󰤄")
            MenuBtn { iconTxt: "󰇄"; cmd: "systemctl suspend"; hoverColor: "#e0af68" }
            
            // Reiniciar (Círculo girando)
            MenuBtn { iconTxt: "󰜉"; cmd: "systemctl reboot"; hoverColor: "#7aa2f7" }
        }
    }
}
