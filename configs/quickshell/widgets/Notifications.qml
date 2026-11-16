import QtQuick

import Quickshell
import Quickshell.Wayland

import "../pages"
import "../services"

Item {
    id: root
    width: 44
    height: 34

    property bool panelOpen: false

    Rectangle {
        anchors.fill: parent
        color: root.panelOpen ? (theme.colors.surface0 || "black") : (theme.colors.crust || "black")
        radius: height / 2

        Text {
            anchors.centerIn: parent
            text: Notifications.count > 0 ? "󰂚" : "󰂜"
            color: root.panelOpen ? (theme.colors.lavender || "white") : (theme.colors.text || "white")
            font.family: theme.fontFamily
            font.pixelSize: 16
        }

        Rectangle {
            visible: Notifications.count > 0
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 2
            anchors.rightMargin: 2
            width: 15
            height: 15
            radius: width / 2
            color: theme.colors.red || "red"

            Text {
                anchors.centerIn: parent
                text: Notifications.count > 9 ? "9+" : Notifications.count
                color: theme.colors.crust || "black"
                font.family: theme.fontFamily
                font.pixelSize: 9
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.panelOpen = !root.panelOpen
        }
    }

    PanelWindow {
        anchors {
            top: true
            right: true
            bottom: true
        }

        margins {
            top: 5
            right: 5
            bottom: 5
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notifications"

        visible: root.panelOpen
        implicitWidth: 400
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            radius: 20
            color: theme.colors.background || "black"
            clip: true

            Loader {
                anchors.fill: parent
                anchors.margins: 18
                active: root.panelOpen

                sourceComponent: NotificationsPage {
                    showClose: true
                    listHeight: 10000
                    onRequestClose: root.panelOpen = false
                }
            }
        }
    }
}
