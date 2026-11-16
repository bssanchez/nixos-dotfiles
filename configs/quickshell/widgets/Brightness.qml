import QtQuick

import "../services"

Item {
    width: 74
    height: 34

    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: Brightness.icon
                color: theme.colors.yellow || "white"
                font.family: theme.fontFamily
                font.pixelSize: 14
            }

            Text {
                text: Brightness.level + "%"
                color: theme.colors.text || "black"
                font.pixelSize: 14
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => Brightness.set(mouse.button === Qt.MiddleButton ? "10%" : "60%")
            onWheel: wheel => Brightness.set(wheel.angleDelta.y > 0 ? "5%+" : "5%-")
        }
    }
}
