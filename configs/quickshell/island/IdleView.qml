import QtQuick
import QtQuick.Layouts

import "../components"
import "../providers"
import "../services"
import "../widgets"

// Reposo (y música): workspaces al centro, laterales según el estado.
RowLayout {
    id: root

    property string monitorName: ""
    property bool music: false

    signal expandRequested()
    signal mediaRequested()

    // cava solo corre mientras la vista de música está activa.
    readonly property bool wantsBars: music && enabled
    property bool _counted: false

    function syncBars() {
        if (wantsBars !== _counted) {
            Media.barWatchers += wantsBars ? 1 : -1;
            _counted = wantsBars;
        }
    }

    onWantsBarsChanged: syncBars()
    Component.onCompleted: syncBars()
    Component.onDestruction: if (_counted) Media.barWatchers--

    spacing: 10

    // ---- Lateral izquierdo ----
    Text {
        visible: !root.music
        text: Time.format("hh:mm")
        color: theme.colors.text || "white"
        font.family: theme.fontFamily
        font.pixelSize: 14
        font.bold: true
        Layout.leftMargin: 6
    }

    RowLayout {
        visible: root.music
        spacing: 8
        Layout.maximumWidth: 170

        CoverArt {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            radius: 12
            source: Media.artUrl

            RotationAnimation on rotation {
                from: 0
                to: 360
                duration: 9000
                loops: Animation.Infinite
                running: root.music && Media.playing
            }
        }

        Text {
            Layout.fillWidth: true
            Layout.maximumWidth: 138
            text: Media.title
            color: theme.colors.text || "white"
            font.family: theme.fontFamily
            font.pixelSize: 12
            elide: Text.ElideRight
        }

        HoverHandler { cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: root.mediaRequested() }
    }

    Workspaces {
        monitorName: root.monitorName
        slotWidth: 26
        slotHeight: 22
    }

    // ---- Lateral derecho ----
    MiniBars {
        visible: root.music
        Layout.preferredWidth: 46
        Layout.preferredHeight: 18
        count: Media.barCount
        values: Media.bars
        barColor: theme.colors.mauve || "white"
    }

    Rectangle {
        id: drop
        visible: !root.music
        Layout.preferredHeight: 26
        Layout.preferredWidth: dropRow.implicitWidth + 18
        radius: height / 2
        color: theme.colors.crust || "black"

        Row {
            id: dropRow
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: Network.netIcon
                color: Network.connected ? (theme.colors.blue || "white") : (theme.colors.overlay0 || "gray")
                font.family: theme.fontFamily
                font.pixelSize: 13
            }

            Text {
                text: Battery.icon + " " + Battery.level + "%"
                color: theme.colors[Battery.colorName] || "white"
                font.family: theme.fontFamily
                font.pixelSize: 12
            }

            Rectangle {
                visible: Notifications.count > 0
                anchors.verticalCenter: parent.verticalCenter
                width: 6
                height: 6
                radius: 3
                color: theme.colors.red || "red"
            }
        }
    }

    Text {
        text: "󰅀"
        color: expandHover.hovered ? (theme.colors.mauve || "white") : (theme.colors.subtext0 || "gray")
        font.family: theme.fontFamily
        font.pixelSize: 16
        Layout.rightMargin: 4

        HoverHandler { id: expandHover; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: root.expandRequested() }
    }
}
