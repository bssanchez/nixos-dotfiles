import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string icon: ""
    property int value: 0
    property bool dimmed: false
    property color accent: theme.colors.mauve || "white"

    signal moved(int value)
    signal iconClicked()
    signal iconRightClicked()

    Layout.fillWidth: true
    spacing: 12

    Rectangle {
        Layout.preferredWidth: 34
        Layout.preferredHeight: 34
        radius: 12
        color: iconHover.hovered ? (theme.colors.surface1 || "gray") : (theme.colors.surface0 || "gray")

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.dimmed ? (theme.colors.overlay0 || "gray") : root.accent
            font.family: theme.fontFamily
            font.pixelSize: 16
        }

        HoverHandler { id: iconHover; cursorShape: Qt.PointingHandCursor }
        TapHandler { acceptedButtons: Qt.LeftButton; onTapped: root.iconClicked() }
        TapHandler { acceptedButtons: Qt.RightButton; onTapped: root.iconRightClicked() }
    }

    Item {
        id: track
        Layout.fillWidth: true
        Layout.preferredHeight: 22

        readonly property real shown: drag.active ? drag.preview : root.value
        readonly property real fraction: Math.max(0, Math.min(1, shown / 100))

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            height: 8
            radius: 4
            color: theme.colors.surface1 || "gray"

            Rectangle {
                width: Math.max(height, parent.width * track.fraction)
                height: parent.height
                radius: 4
                color: root.dimmed ? (theme.colors.overlay0 || "gray") : root.accent
            }
        }

        Rectangle {
            x: Math.max(0, Math.min(track.width - width, track.width * track.fraction - width / 2))
            anchors.verticalCenter: parent.verticalCenter
            width: 16
            height: 16
            radius: 8
            color: theme.colors.text || "white"
            scale: drag.active || knobHover.hovered ? 1.15 : 1
            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        HoverHandler { id: knobHover; cursorShape: Qt.PointingHandCursor }

        MouseArea {
            id: drag
            anchors.fill: parent
            property bool active: pressed
            property real preview: 0

            function valueAt(x) { return Math.round(Math.max(0, Math.min(1, x / width)) * 100); }

            onPressed: mouse => { preview = valueAt(mouse.x); root.moved(preview); }
            onPositionChanged: mouse => { if (pressed) { preview = valueAt(mouse.x); root.moved(preview); } }
            onWheel: wheel => root.moved(Math.max(0, Math.min(100, root.value + (wheel.angleDelta.y > 0 ? 5 : -5))))
        }
    }

    Text {
        text: Math.round(track.shown) + "%"
        color: theme.colors.subtext0 || "gray"
        font.family: theme.fontFamily
        font.pixelSize: 11
        horizontalAlignment: Text.AlignRight
        Layout.preferredWidth: 34
    }
}
