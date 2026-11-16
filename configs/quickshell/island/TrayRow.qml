import QtQuick
import Qt5Compat.GraphicalEffects

import Quickshell.Services.SystemTray

Row {
    id: root

    property int boxSize: 28
    property int iconSize: 16

    signal menuRequested(var item)

    spacing: 4

    Repeater {
        model: SystemTray.items.values

        delegate: Rectangle {
            required property var modelData

            width: root.boxSize
            height: root.boxSize
            radius: root.boxSize / 2
            color: hover.hovered ? (theme.colors.surface0 || "gray") : "transparent"

            Behavior on color { ColorAnimation { duration: 120 } }

            Image {
                id: trayIcon
                anchors.centerIn: parent
                width: root.iconSize
                height: root.iconSize
                sourceSize.width: root.iconSize * 2
                sourceSize.height: root.iconSize * 2
                source: modelData.icon || ""
                fillMode: Image.PreserveAspectFit
                visible: false
            }

            ColorOverlay {
                anchors.fill: trayIcon
                source: trayIcon
                color: theme.colors.text || "white"
                visible: trayIcon.status === Image.Ready
            }

            Text {
                anchors.centerIn: parent
                visible: trayIcon.status === Image.Error
                text: "?"
                color: theme.colors.text || "white"
            }

            HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                onClicked: mouse => {
                    if (mouse.button === Qt.LeftButton)
                        modelData.activate();
                    else if (mouse.button === Qt.MiddleButton)
                        modelData.secondaryActivate();
                    else if (modelData.hasMenu)
                        root.menuRequested(modelData);
                }
            }
        }
    }
}
