import QtQuick
import Quickshell

Item {
    id: powerBtn
    implicitWidth: 30
    implicitHeight: 24
    
    // Criamos um "grito" (sinal) para avisar a barra
    signal openMenu() 

    Text {
        anchors.centerIn: parent
        text: "" 
        color: "#f7768e" 
        font.pixelSize: 18
        font.family: "JetBrains Nerd Font"
        
        opacity: mouseArea.containsMouse ? 0.7 : 1.0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        // Quando clicar, emite o sinal
        onClicked: powerBtn.openMenu()
    }
}
