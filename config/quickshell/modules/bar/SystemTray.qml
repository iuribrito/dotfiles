import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

Row {
    id: trayRoot
    spacing: 8 
    
    property var parentWindow: null

    Repeater {
        model: SystemTray.items

        delegate: IconImage {
            id: trayIcon
            width: 20
            height: 20
            source: modelData.icon

            QsMenuAnchor {
                id: menuAnchor
                menu: modelData.menu
                
                anchor {
                    window: trayRoot.parentWindow
                    edges: Quickshell.Bottom
                    gravity: Quickshell.Bottom
                    
                    rect: {
                        if (!trayRoot.parentWindow) return Qt.rect(0, 0, 0, 0);
                        var pos = trayIcon.mapToItem(null, 0, 0);
                        return Qt.rect(pos.x, pos.y, trayIcon.width, trayIcon.height);
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton
                cursorShape: Qt.PointingHandCursor

                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (modelData.menu) {
                            menuAnchor.open();
                        } else {
                            modelData.secondaryActivate();
                        }
                    }
                }
            }
        }
    }
}
