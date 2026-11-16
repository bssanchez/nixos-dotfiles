import QtQuick

import "../components"
import "../pages"
import "../providers"

Item {
    width: 180
    height: 34

    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 6

            Text {
                color: theme.colors.peach
                text: "󰃰"
                font.pixelSize: 14
            }

            Text {
                text: Time.format("d MMM • hh:mm AP")
                font.pixelSize: 14
                color: theme.colors.text
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
        alignRight: true
        edgeMargin: 20
        extraHeight: 10
        page: CalendarPage {}
    }
}
