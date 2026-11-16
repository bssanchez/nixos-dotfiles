import QtQuick

import "../components"
import "../pages"
import "../services"

Item {
    width: 80
    height: 34

    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: ""
                color: theme.colors.red || "black"
                font.pixelSize: 14
            }

            Text {
                text: Cpu.total + "%"
                color: theme.colors.text || "black"
                font.pixelSize: 14
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
        edgeMargin: 20
        extraHeight: 10
        page: CpuPage {}
    }
}
