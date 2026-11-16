import QtQuick
import QtQuick.Effects

Item {
    id: root

    property alias source: art.source
    property real radius: 8

    Image {
        id: art
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
        sourceSize.width: root.width * 2
        sourceSize.height: root.height * 2
    }

    Rectangle {
        id: maskRect
        anchors.fill: parent
        radius: root.radius
        visible: false
        layer.enabled: true
    }

    MultiEffect {
        anchors.fill: parent
        source: art
        maskEnabled: true
        maskSource: maskRect
        visible: art.status === Image.Ready
    }

    Rectangle {
        anchors.fill: parent
        radius: root.radius
        color: theme.colors.surface0 || "gray"
        visible: art.status !== Image.Ready

        Text {
            anchors.centerIn: parent
            text: "󰝚"
            color: theme.colors.mauve || "white"
            font.family: theme.fontFamily
            font.pixelSize: Math.max(10, root.height * 0.45)
        }
    }
}
