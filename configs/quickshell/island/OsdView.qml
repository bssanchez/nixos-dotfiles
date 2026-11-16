import QtQuick
import QtQuick.Layouts

import "../services"

RowLayout {
    id: root

    property string kind: "volume"

    readonly property bool isVolume: kind === "volume"
    readonly property int value: isVolume ? (Audio.muted ? 0 : Audio.volume) : Brightness.level
    readonly property color accent: isVolume ? (theme.colors.sky || "white") : (theme.colors.yellow || "white")

    spacing: 12

    Text {
        text: root.isVolume ? Audio.icon : Brightness.icon
        color: root.accent
        font.family: theme.fontFamily
        font.pixelSize: 18
        Layout.leftMargin: 6
        Layout.preferredWidth: 20
    }

    Rectangle {
        Layout.preferredWidth: 180
        Layout.preferredHeight: 6
        radius: 3
        color: theme.colors.surface1 || "gray"

        Rectangle {
            width: parent.width * Math.min(1, root.value / 100)
            height: parent.height
            radius: 3
            color: root.accent

            Behavior on width { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
        }
    }

    Text {
        text: root.isVolume && Audio.muted ? "Mute" : root.value + "%"
        color: theme.colors.text || "white"
        font.family: theme.fontFamily
        font.pixelSize: 12
        horizontalAlignment: Text.AlignRight
        Layout.preferredWidth: 38
        Layout.rightMargin: 6
    }
}
