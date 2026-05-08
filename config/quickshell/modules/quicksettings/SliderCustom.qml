import QtQuick
import QtQuick.Controls
import "../theme"

Slider {
    id: control
    property color fillColor: Theme.primary

    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: 8
        radius: 4
        color: Theme.bgDark

        Rectangle {
            width: control.visualPosition * (control.availableWidth - control.handle.implicitWidth) + control.handle.implicitWidth / 2
            height: parent.height
            radius: 4
            color: control.fillColor

            Behavior on width {
                NumberAnimation { duration: 80; easing.type: Easing.OutQuad }
            }
        }
    }

    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        implicitWidth: 20
        implicitHeight: 20
        radius: 10
        color: control.fillColor

        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: Theme.bgMain
            opacity: 0.8
        }

        HoverHandler { cursorShape: Qt.PointingHandCursor }

        scale: control.pressed ? 0.88 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100; easing.type: Easing.OutQuad }
        }
    }
}
