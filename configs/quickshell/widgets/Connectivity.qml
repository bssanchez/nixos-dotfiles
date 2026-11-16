import QtQuick

import "../components"
import "../pages"
import "../services"

Item {
    width: 74
    height: 34

    Rectangle {
        anchors.fill: parent
        color: popout.open ? (theme.colors.surface0 || "black") : (theme.colors.crust || "black")
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: Network.netIcon
                color: (!Network.wifiOn && Network.connType !== "ethernet") ? (theme.colors.overlay0 || "gray")
                    : (Network.connected ? (theme.colors.blue || "white") : (theme.colors.yellow || "white"))
                font.family: theme.fontFamily
                font.pixelSize: 16
            }

            Text {
                text: Network.btIcon
                color: !Network.btPowered ? (theme.colors.overlay0 || "gray")
                    : (Network.btDevices.length > 0 ? (theme.colors.sapphire || "white") : (theme.colors.blue || "white"))
                font.family: theme.fontFamily
                font.pixelSize: 16
            }
        }

        HoverHandler {
            id: triggerHover
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: popout.toggle()
        }
    }

    HoverPopout {
        id: popout
        triggerHovered: triggerHover.hovered
        alignRight: true
        edgeMargin: 275
        page: NetworkPage {
            onRequestClose: popout.open = false
        }
    }
}
