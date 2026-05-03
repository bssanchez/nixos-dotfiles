import QtQuick
import QtQuick.Layouts

import Quickshell

import "../widgets"

PanelWindow {
    id: topBar
    implicitHeight: 40
    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 5
        left: 5
        right: 5
        bottom: 0
    }

    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: theme.colors.background || "black"
        radius: 8

        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 10
            spacing: 10

            Item {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32

                Image {
                    anchors.fill: parent
                    source: Quickshell.shellDir + "/assets/tasks-icon.png"
                    fillMode: Image.PreserveAspectFit
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Quickshell.execDetached(["rofi", "-show", "drun"])
                }
            }

            CPU {}
            MEM {}
            Disk {}
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter

            Workspaces {}
        }

        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10
            spacing: 10

            SystemTray { }
        }
    }
}
