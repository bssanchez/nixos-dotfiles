import QtQuick
import QtQuick.Layouts

import "../components"
import "../services"

ColumnLayout {
    id: root

    spacing: 14
    readonly property int pageWidth: 360

    Component.onCompleted: Media.barWatchers++
    Component.onDestruction: Media.barWatchers--

    readonly property var player: Media.player

    // Mpris no notifica la posición; se refresca a mano mientras la página está viva.
    Timer {
        interval: 1000
        running: root.player?.isPlaying ?? false
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    function fmt(secs) {
        if (!isFinite(secs) || secs < 0) return "0:00";
        const s = Math.floor(secs);
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 14

        CoverArt {
            Layout.preferredWidth: 96
            Layout.preferredHeight: 96
            radius: 16
            source: Media.artUrl
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                Layout.fillWidth: true
                text: Media.title || "Nada sonando"
                color: theme.colors.text || "white"
                font.family: theme.fontFamily
                font.bold: true
                font.pixelSize: 15
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: Media.artist
                visible: text !== ""
                color: theme.colors.subtext0 || "gray"
                font.family: theme.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: root.player?.identity ?? ""
                color: theme.colors.overlay1 || "gray"
                font.family: theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }

            MiniBars {
                Layout.topMargin: 4
                Layout.preferredWidth: 96
                Layout.preferredHeight: 22
                values: Media.bars
                barColor: theme.colors.mauve || "white"
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4
        visible: (root.player?.lengthSupported ?? false) && root.player.length > 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            radius: 2
            color: theme.colors.surface1 || "gray"

            Rectangle {
                width: root.player && root.player.length > 0 ? parent.width * Math.min(1, root.player.position / root.player.length) : 0
                height: parent.height
                radius: 2
                color: theme.colors.mauve || "white"
            }

            TapHandler {
                enabled: root.player?.canSeek ?? false
                onTapped: point => root.player.position = root.player.length * point.position.x / parent.width
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: root.fmt(root.player?.position ?? 0)
                color: theme.colors.subtext0 || "gray"
                font.family: theme.fontFamily
                font.pixelSize: 10
                Layout.fillWidth: true
            }

            Text {
                text: root.fmt(root.player?.length ?? 0)
                color: theme.colors.subtext0 || "gray"
                font.family: theme.fontFamily
                font.pixelSize: 10
            }
        }
    }

    component Control: Rectangle {
        property string icon
        property bool primary: false
        signal clicked()

        Layout.preferredWidth: primary ? 52 : 40
        Layout.preferredHeight: primary ? 52 : 40
        radius: height / 2
        color: primary ? (theme.colors.mauve || "white") : (hover.hovered ? (theme.colors.surface1 || "gray") : (theme.colors.surface0 || "gray"))

        Text {
            anchors.centerIn: parent
            text: parent.icon
            color: parent.primary ? (theme.colors.crust || "black") : (theme.colors.text || "white")
            font.family: theme.fontFamily
            font.pixelSize: parent.primary ? 22 : 16
        }

        HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: parent.clicked() }
    }

    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 18

        Control { icon: "󰒮"; onClicked: Media.previous() }
        Control { icon: Media.playing ? "󰏤" : "󰐊"; primary: true; onClicked: Media.togglePlaying() }
        Control { icon: "󰒭"; onClicked: Media.next() }
    }
}
