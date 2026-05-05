import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

Row {
    id: trayRoot
    spacing: 8 
    
    property var parentWindow: null
    property var activeMenu: null

    HyprlandFocusGrab {
        id: focusGrab
        active: trayRoot.activeMenu !== null
        windows: [trayRoot.activeMenu]
        onCleared: {
            if (trayRoot.activeMenu) {
                trayRoot.activeMenu.close();
                trayRoot.activeMenu = null;
            }
        }
    }

    Repeater {
        // Usamos .values para obter a lista real de itens do Map do Quickshell
        model: SystemTray.items.values

        delegate: IconImage {
            id: trayIcon
            width: 20
            height: 20
            // No Quickshell, os itens no Repeater são acessados via modelData
            source: modelData.icon

            Loader {
                id: menuLoader
                active: false
                sourceComponent: StyledTrayMenu {
                    menuHandle: modelData.menu
                    
                    anchor {
                        window: trayRoot.parentWindow
                        item: trayIcon
                        edges: Quickshell.Top
                        gravity: Quickshell.Top
                    }
                    
                    Component.onCompleted: {
                        trayRoot.activeMenu = this;
                    }
                    
                    onVisibleChanged: {
                        if (!visible) {
                            menuLoader.active = false;
                            if (trayRoot.activeMenu === this) {
                                trayRoot.activeMenu = null;
                            }
                        }
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
                            if (trayRoot.activeMenu) {
                                trayRoot.activeMenu.close();
                            }
                            menuLoader.active = true;
                        } else {
                            modelData.secondaryActivate();
                        }
                    }
                }
            }
        }
    }
}
