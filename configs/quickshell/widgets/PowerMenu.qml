import QtQuick

import Quickshell

Item {
    id: root
    width: 34
    height: 34

    Rectangle {
        anchors.fill: parent
        color: hover.hovered ? (theme.colors.surface0 || "black") : (theme.colors.crust || "black")
        radius: height / 2

        Text {
            anchors.centerIn: parent
            text: "󰐥"
            color: hover.hovered ? (theme.colors.red || "red") : (theme.colors.maroon || "red")
            font.family: theme.fontFamily
            font.pixelSize: 17
        }

        HoverHandler { id: hover }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/powermenu.sh"])
        }
    }
}
