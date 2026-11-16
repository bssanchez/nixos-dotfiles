import QtQuick
import QtQuick.Layouts

// Tile del dashboard: el cuerpo navega a su página y el icono puede actuar como toggle.
Rectangle {
    id: root

    property string icon: ""
    property string title: ""
    property string subtitle: ""
    property color accent: theme.colors.mauve || "white"
    property bool active: true
    property bool iconToggles: false

    signal clicked()
    signal iconClicked()

    Layout.fillWidth: true
    implicitHeight: 58
    radius: 16
    color: hover.hovered ? (theme.colors.surface1 || "gray") : (theme.colors.surface0 || "gray")

    Behavior on color { ColorAnimation { duration: 120 } }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.clicked() }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 12
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 12
            color: root.active ? root.accent : (theme.colors.surface2 || "gray")

            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
                anchors.centerIn: parent
                text: root.icon
                color: root.active ? (theme.colors.crust || "black") : (theme.colors.text || "white")
                font.family: theme.fontFamily
                font.pixelSize: 18
            }

            TapHandler {
                enabled: root.iconToggles
                onTapped: root.iconClicked()
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: root.title
                color: theme.colors.text || "white"
                font.family: theme.fontFamily
                font.pixelSize: 13
                font.bold: true
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.subtitle
                color: theme.colors.subtext0 || "gray"
                font.family: theme.fontFamily
                font.pixelSize: 11
                elide: Text.ElideRight
            }
        }
    }
}
