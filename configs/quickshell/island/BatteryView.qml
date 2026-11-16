import QtQuick
import QtQuick.Layouts

import "../services"

RowLayout {
    id: root

    property string level: "low"
    readonly property color accent: level === "critical" ? (theme.colors.red || "red") : (theme.colors.peach || "orange")

    signal dismissed()

    spacing: 12

    Text {
        text: "󰂃"
        color: root.accent
        font.family: theme.fontFamily
        font.pixelSize: 22
        Layout.leftMargin: 6

        SequentialAnimation on opacity {
            running: root.visible
            loops: Animation.Infinite
            NumberAnimation { to: 0.35; duration: 700; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 1; duration: 700; easing.type: Easing.InOutQuad }
        }
    }

    ColumnLayout {
        spacing: 1

        Text {
            text: root.level === "critical" ? "¡Batería agotándose!" : "Batería baja"
            color: theme.colors.text || "white"
            font.family: theme.fontFamily
            font.bold: true
            font.pixelSize: 13
        }

        Text {
            text: "Conecta el cargador — " + Battery.level + "%"
            color: theme.colors.subtext0 || "gray"
            font.family: theme.fontFamily
            font.pixelSize: 11
        }
    }

    Text {
        text: "󰅖"
        color: theme.colors.subtext0 || "gray"
        font.family: theme.fontFamily
        font.pixelSize: 14
        Layout.leftMargin: 6
        Layout.rightMargin: 6

        HoverHandler { cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: root.dismissed() }
    }
}
