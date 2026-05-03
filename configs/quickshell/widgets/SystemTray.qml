import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io
import Quickshell.Services.SystemTray

import "../components"

RowLayout {
    id: root

    property var colors: theme.colors

    visible: SystemTray.items.values.length > 0
    spacing: 4

    Rectangle {
        clip: true
        height: 34
        radius: height / 2

        color: colors.crust || "black"

        Layout.preferredWidth: trayInner.implicitWidth + 16

        RowLayout {
            id: trayInner
            anchors.centerIn: parent
            spacing: 8

            Tray {
                iconSize: 16
                colors: root.colors
            }
        }
    }
}
