import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property color iconColor: theme.colors.blue || "white"

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 34
    radius: 10
    color: hover.hovered ? (theme.colors.surface2 || "gray") : (theme.colors.surface1 || "gray")

    Row {
        anchors.centerIn: parent
        spacing: 8

        Text {
            text: root.icon
            color: root.iconColor
            font.family: theme.fontFamily
            font.pixelSize: 14
        }

        Text {
            text: root.label
            color: theme.colors.text || "white"
            font.family: theme.fontFamily
            font.pixelSize: 13
        }
    }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.clicked() }
}
