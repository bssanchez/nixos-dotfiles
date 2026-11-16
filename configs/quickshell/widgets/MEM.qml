import QtQuick

import "../components"
import "../pages"
import "../services"

Item {
    width: 100
    height: 34

    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                color: theme.colors.sapphire || "black"
                text: ""
                font.pixelSize: 14
            }

            Text {
                text: Memory.usedText
                font.pixelSize: 14
                color: theme.colors.text || "black"
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: { Memory.refresh(); popout.toggle(); }
        }
    }

    HoverPopout {
        id: popout
        triggerHovered: hoverArea.containsMouse
        edgeMargin: 20
        page: MemoryPage {}
    }
}
