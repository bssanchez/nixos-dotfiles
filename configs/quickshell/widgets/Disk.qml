import QtQuick

import "../components"
import "../pages"
import "../services"

Item {
    width: 140
    height: 34

    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                color: theme.colors.yellow || "black"
                text: ""
                font.pixelSize: 14
            }

            Text {
                text: Disks.rootText
                font.pixelSize: 14
                color: theme.colors.text || "black"
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: popout.toggle()
        }
    }

    HoverPopout {
        id: popout
        triggerHovered: hoverArea.containsMouse
        edgeMargin: 125
        extraHeight: 10
        page: DiskPage {}
    }
}
