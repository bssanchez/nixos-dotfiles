import QtQuick

import "../services"

Item {
    width: 34
    height: 34

    Rectangle {
        anchors.fill: parent
        color: hover.hovered ? (theme.colors.surface0 || "black") : (theme.colors.crust || "black")
        radius: height / 2

        Text {
            anchors.centerIn: parent
            text: Idle.enabled ? "󰒲" : "󰒳"
            color: Idle.enabled ? (theme.colors.text || "white") : (theme.colors.peach || "orange")
            font.family: theme.fontFamily
            font.pixelSize: 16
        }

        HoverHandler { id: hover }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Idle.toggle()
        }
    }
}
