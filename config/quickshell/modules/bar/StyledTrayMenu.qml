import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

PopupWindow {
    id: root
    required property QsMenuHandle menuHandle
    
    color: "transparent"
    visible: false
    
    function open() {
        visible = true;
    }

    function close() {
        visible = false;
    }

    Component.onCompleted: open()
    
    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#1e1e2e"
        radius: 8
        border.color: "#313244"
        border.width: 1
        
        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 4
            spacing: 0
            
            QsMenuOpener {
                id: menuOpener
                menu: root.menuHandle
            }
            
            Repeater {
                model: menuOpener.children
                
                delegate: Rectangle {
                    id: itemDelegate
                    required property QsMenuEntry modelData
                    Layout.fillWidth: true
                    implicitHeight: modelData.isSeparator ? 9 : 30
                    color: mouseArea.containsMouse ? "#313244" : "transparent"
                    radius: 4
                    
                    Rectangle {
                        visible: modelData.isSeparator
                        anchors.centerIn: parent
                        width: parent.width - 8
                        height: 1
                        color: "#45475a"
                    }
                    
                    RowLayout {
                        visible: !modelData.isSeparator
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8
                        
                        IconImage {
                            visible: modelData.icon !== ""
                            source: modelData.icon
                            width: 16
                            height: 16
                        }
                        
                        Text {
                            text: modelData.text
                            color: "#cdd6f4"
                            font.pixelSize: 12
                            Layout.fillWidth: true
                        }
                        
                        Text {
                            visible: modelData.hasChildren
                            text: "󰅂"
                            color: "#6c7086"
                            font.pixelSize: 12
                        }
                    }
                    
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (modelData.hasChildren) {
                                // Submenus não implementados nesta versão simplificada
                            } else {
                                modelData.triggered();
                                root.close();
                            }
                        }
                    }
                }
            }
        }
    }
    
    implicitWidth: 200
    implicitHeight: mainLayout.implicitHeight + 8
}
