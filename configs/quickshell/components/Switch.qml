import QtQuick

Rectangle {
    id: root

    property bool checked: false
    property color accent: theme.colors.blue || "blue"

    signal toggled()

    width: 46
    height: 26
    radius: height / 2
    color: checked ? accent : (theme.colors.surface2 || "gray")

    Behavior on color { ColorAnimation { duration: 150 } }

    Rectangle {
        width: 20
        height: 20
        radius: height / 2
        color: theme.colors.text || "white"
        anchors.verticalCenter: parent.verticalCenter
        x: root.checked ? parent.width - width - 3 : 3
        Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    HoverHandler { cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.toggled() }
}
