import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"

Scope {
    id: launcherScope
    required property var modelData

    GlobalShortcut {
        name: "launcherToggle"
        description: "Toggle app launcher"
        onPressed: LauncherState.isOpen = !LauncherState.isOpen
    }

    PanelWindow {
        id: panelRoot
        visible: LauncherState.isOpen
        screen: launcherScope.modelData

        WlrLayershell.namespace: "quickshell:launcher"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: LauncherState.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        color: "transparent"
        anchors { top: true; bottom: true; left: true; right: true }

        onVisibleChanged: {
            if (visible) Qt.callLater(() => searchField.forceActiveFocus())
            else {
                searchField.text = ""
                appList.currentIndex = 0
            }
        }

        Item {
            id: content
            anchors.fill: parent

            property string query: ""
            property int hoveredIndex: -1
            readonly property var filteredApps: {
                const q = content.query.toLowerCase().trim()
                const counts = LauncherState.usageCounts
                const all = [...DesktopEntries.applications.values]
                    .filter(a => !a.noDisplay)
                    .sort((a, b) => {
                        const diff = (counts[b.id] || 0) - (counts[a.id] || 0)
                        return diff !== 0 ? diff : a.name.localeCompare(b.name)
                    })
                if (q === "") return all
                return all.filter(a =>
                    a.name.toLowerCase().includes(q) ||
                    (a.genericName ?? "").toLowerCase().includes(q)
                )
            }

            onFilteredAppsChanged: appList.currentIndex = 0

            MouseArea {
                anchors.fill: parent
                onClicked: LauncherState.isOpen = false
            }

            Rectangle {
                id: card
                anchors.centerIn: parent
                width: 460
                height: Math.min(content.height * 0.75, 560)
                color: Qt.rgba(0.118, 0.118, 0.180, 0.92)
                radius: 14

                opacity: LauncherState.isOpen ? 1 : 0
                scale: LauncherState.isOpen ? 1 : 0.95
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuint } }
                Behavior on scale   { NumberAnimation { duration: 180; easing.type: Easing.OutQuint } }

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    anchors { fill: parent; margins: 16 }
                    spacing: 12

                    // Barra de busca
                    Rectangle {
                        Layout.fillWidth: true
                        height: 44
                        radius: 10
                        color: Theme.bgSurface

                        RowLayout {
                            anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                            spacing: 8

                            Text {
                                text: "󰍉"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 18
                                color: Theme.textMuted
                            }

                            Item {
                                Layout.fillWidth: true
                                Layout.fillHeight: true

                                TextInput {
                                    id: searchField
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: parent.width
                                    color: Theme.textMain
                                    font.pixelSize: 14
                                    selectByMouse: true
                                    clip: true

                                    onTextChanged: content.query = text

                                    Keys.onPressed: function(event) {
                                        if (event.key === Qt.Key_Escape) {
                                            LauncherState.isOpen = false
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                            const idx = appList.currentIndex
                                            if (idx >= 0 && idx < content.filteredApps.length) {
                                                LauncherState.recordUsage(content.filteredApps[idx].id)
                                                content.filteredApps[idx].execute()
                                                LauncherState.isOpen = false
                                            }
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                                            appList.currentIndex = Math.min(appList.currentIndex + 1, content.filteredApps.length - 1)
                                            appList.positionViewAtIndex(appList.currentIndex, ListView.Contain)
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
                                            appList.currentIndex = Math.max(appList.currentIndex - 1, 0)
                                            appList.positionViewAtIndex(appList.currentIndex, ListView.Contain)
                                            event.accepted = true
                                        }
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Buscar aplicativos..."
                                    color: Theme.textMuted
                                    font.pixelSize: 14
                                    visible: !searchField.text
                                }
                            }
                        }
                    }

                    // Lista de apps
                    ListView {
                        id: appList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 2

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        model: ScriptModel {
                            values: content.filteredApps
                        }

                        delegate: Item {
                            required property var modelData
                            required property int index
                            width: appList.width
                            height: 60

                            Rectangle {
                                anchors { fill: parent; leftMargin: 2; rightMargin: 2 }
                                radius: 8
                                color: (index === appList.currentIndex || row.containsMouse)
                                    ? Theme.bgSurface : "transparent"
                                Behavior on color { ColorAnimation { duration: 80 } }

                                RowLayout {
                                    anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                                    spacing: 14

                                    Item {
                                        id: iconItem
                                        Layout.preferredWidth: 38
                                        Layout.preferredHeight: 38

                                        property bool failed: false

                                        Image {
                                            id: appIcon
                                            anchors.fill: parent
                                            source: iconItem.failed ? "" : Quickshell.iconPath(modelData.icon, "")
                                            fillMode: Image.PreserveAspectFit
                                            smooth: true
                                            mipmap: true
                                            visible: !iconItem.failed && status === Image.Ready
                                            onStatusChanged: if (status === Image.Error) iconItem.failed = true
                                        }

                                        Rectangle {
                                            anchors.fill: parent
                                            radius: 8
                                            color: Theme.bgHover
                                            visible: iconItem.failed || appIcon.status !== Image.Ready

                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.name.charAt(0).toUpperCase()
                                                color: Theme.textSub
                                                font.pixelSize: 15
                                                font.bold: true
                                            }
                                        }
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 2

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.name
                                            color: Theme.textMain
                                            font.pixelSize: 14
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.comment || modelData.genericName || ""
                                            color: Theme.textMuted
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                            visible: text !== ""
                                        }
                                    }
                                }

                                MouseArea {
                                    id: row
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: appList.currentIndex = index
                                    onClicked: {
                                        LauncherState.recordUsage(modelData.id)
                                        modelData.execute()
                                        LauncherState.isOpen = false
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
