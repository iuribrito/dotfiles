import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../theme"

Scope {
    id: clipboardScope
    required property var modelData

    PanelWindow {
        id: panelRoot
        readonly property bool isFocusedScreen: Hyprland.focusedMonitor?.name === clipboardScope.modelData.name
        visible: ClipboardService.isOpen && isFocusedScreen
        screen: clipboardScope.modelData

        WlrLayershell.namespace: "quickshell:clipboard"
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: ClipboardService.isOpen
            ? WlrKeyboardFocus.OnDemand
            : WlrKeyboardFocus.None

        color: "transparent"
        anchors { top: true; bottom: true; left: true; right: true }

        onVisibleChanged: {
            if (visible) Qt.callLater(() => searchField.forceActiveFocus())
            else {
                searchField.text = ""
                itemList.currentIndex = 0
            }
        }

        Item {
            id: content
            anchors.fill: parent

            property string query: ""

            readonly property var filteredEntries: {
                const q = content.query.toLowerCase().trim()
                if (q === "") return ClipboardService.entries
                return ClipboardService.entries.filter(e =>
                    e.toLowerCase().includes(q)
                )
            }

            onFilteredEntriesChanged: itemList.currentIndex = 0

            MouseArea {
                anchors.fill: parent
                onClicked: ClipboardService.isOpen = false
            }

            Rectangle {
                id: card
                anchors.centerIn: parent
                width: 500
                height: Math.min(content.height * 0.75, 580)
                color: Qt.rgba(0.118, 0.118, 0.180, 0.92)
                radius: 14

                opacity: ClipboardService.isOpen ? 1 : 0
                scale: ClipboardService.isOpen ? 1 : 0.95
                Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutQuint } }
                Behavior on scale   { NumberAnimation { duration: 180; easing.type: Easing.OutQuint } }

                MouseArea { anchors.fill: parent }

                ColumnLayout {
                    anchors { fill: parent; margins: 16 }
                    spacing: 10

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6

                        Text {
                            text: "󰅒"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 14
                            color: Theme.primary
                        }

                        Text {
                            text: "Histórico do Clipboard"
                            color: Theme.textSub
                            font.pixelSize: 13
                            font.bold: true
                        }

                        Item { Layout.fillWidth: true }

                        Text {
                            text: content.filteredEntries.length + " itens  ·  Del remove  ·  Enter cola"
                            color: Theme.textMuted
                            font.pixelSize: 10
                        }
                    }

                    // Search bar
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
                                            ClipboardService.isOpen = false
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                            const entry = content.filteredEntries[itemList.currentIndex]
                                            if (entry !== undefined) {
                                                ClipboardService.paste(entry)
                                                ClipboardService.isOpen = false
                                            }
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) {
                                            itemList.currentIndex = Math.min(
                                                itemList.currentIndex + 1,
                                                content.filteredEntries.length - 1
                                            )
                                            itemList.positionViewAtIndex(itemList.currentIndex, ListView.Contain)
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) {
                                            itemList.currentIndex = Math.max(itemList.currentIndex - 1, 0)
                                            itemList.positionViewAtIndex(itemList.currentIndex, ListView.Contain)
                                            event.accepted = true
                                        } else if (event.key === Qt.Key_Delete) {
                                            const entry = content.filteredEntries[itemList.currentIndex]
                                            if (entry !== undefined) ClipboardService.remove(entry)
                                            event.accepted = true
                                        }
                                    }
                                }

                                Text {
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Buscar no histórico..."
                                    color: Theme.textMuted
                                    font.pixelSize: 14
                                    visible: !searchField.text
                                }
                            }
                        }
                    }

                    // List
                    ListView {
                        id: itemList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: content.filteredEntries.length > 0
                        clip: true
                        spacing: 2

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        model: ScriptModel {
                            values: content.filteredEntries
                        }

                        delegate: Item {
                            id: delegateRoot
                            required property var modelData
                            required property int index
                            width: itemList.width
                            height: 58

                            readonly property string entryContent: {
                                const tab = modelData.indexOf("\t")
                                return tab !== -1 ? modelData.substring(tab + 1) : modelData
                            }
                            readonly property bool isImage: entryContent.startsWith("[[ binary")

                            Rectangle {
                                anchors { fill: parent; leftMargin: 2; rightMargin: 2 }
                                radius: 8
                                color: (delegateRoot.index === itemList.currentIndex || row.containsMouse)
                                    ? Theme.orangeAlt : "transparent"
                                Behavior on color { ColorAnimation { duration: 80 } }

                                readonly property bool highlighted:
                                    delegateRoot.index === itemList.currentIndex || row.containsMouse

                                RowLayout {
                                    anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                                    spacing: 12

                                    Text {
                                        text: delegateRoot.isImage ? "󰋩" : "󰅎"
                                        font.family: "Symbols Nerd Font"
                                        font.pixelSize: 18
                                        color: parent.parent.highlighted ? Theme.bgMain : Theme.textMuted
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 3

                                        Text {
                                            Layout.fillWidth: true
                                            text: delegateRoot.isImage
                                                ? delegateRoot.entryContent
                                                : delegateRoot.entryContent.replace(/\s+/g, " ").trim()
                                            color: parent.parent.parent.highlighted ? Theme.bgMain : Theme.textMain
                                            font.pixelSize: 13
                                            elide: Text.ElideRight
                                            maximumLineCount: 1
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: delegateRoot.isImage
                                                ? "Imagem"
                                                : delegateRoot.entryContent.length + " caracteres"
                                            color: parent.parent.parent.highlighted
                                                ? Qt.rgba(0.118, 0.118, 0.180, 0.7)
                                                : Theme.textMuted
                                            font.pixelSize: 10
                                            elide: Text.ElideRight
                                        }
                                    }
                                }

                                MouseArea {
                                    id: row
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: itemList.currentIndex = delegateRoot.index
                                    onClicked: {
                                        ClipboardService.paste(delegateRoot.modelData)
                                        ClipboardService.isOpen = false
                                    }
                                }
                            }
                        }
                    }

                    // Empty state
                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: content.filteredEntries.length === 0

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: "󰅒"
                                font.family: "Symbols Nerd Font"
                                font.pixelSize: 32
                                color: Theme.textMuted
                                opacity: 0.4
                            }

                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: content.query ? "Nenhum resultado" : "Clipboard vazio"
                                color: Theme.textMuted
                                font.pixelSize: 13
                                opacity: 0.6
                            }
                        }
                    }
                }
            }
        }
    }
}
