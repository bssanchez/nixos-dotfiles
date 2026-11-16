import QtQuick

Row {
    id: root

    property var values: []
    property color barColor: "white"
    property int count: 12

    spacing: 2

    Repeater {
        model: root.count

        Rectangle {
            required property int index
            readonly property real level: root.values[index] || 0

            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(2, (root.width - root.spacing * (root.count - 1)) / root.count)
            height: Math.max(3, root.height * level)
            radius: width / 2
            color: root.barColor
            opacity: 0.55 + 0.45 * level

            Behavior on height { NumberAnimation { duration: 90 } }
        }
    }
}
