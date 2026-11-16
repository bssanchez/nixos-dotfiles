import QtQuick
import QtQuick.Layouts

import "../services"

RowLayout {
    id: root

    property var notification: null
    readonly property color accent: theme.colors[Notifications.urgencyColorName(notification?.urgency)] || "white"

    spacing: 12

    Rectangle {
        Layout.preferredWidth: 30
        Layout.preferredHeight: 30
        Layout.leftMargin: 2
        radius: 15
        color: theme.colors.surface0 || "gray"

        Image {
            id: appIcon
            anchors.centerIn: parent
            width: 18
            height: 18
            sourceSize.width: 36
            sourceSize.height: 36
            source: {
                const icon = root.notification?.app_icon || "";
                return icon.startsWith("/") ? "file://" + icon : "";
            }
            visible: status === Image.Ready
        }

        Text {
            anchors.centerIn: parent
            visible: !appIcon.visible
            text: "󰂚"
            color: root.accent
            font.family: theme.fontFamily
            font.pixelSize: 15
        }
    }

    ColumnLayout {
        spacing: 1
        Layout.maximumWidth: 340

        Text {
            Layout.fillWidth: true
            text: (root.notification?.app_name || "") + (root.notification?.summary ? " · " + root.notification.summary : "")
            color: theme.colors.text || "white"
            font.family: theme.fontFamily
            font.pixelSize: 12
            font.bold: true
            elide: Text.ElideRight
        }

        Text {
            Layout.fillWidth: true
            visible: text !== ""
            text: (root.notification?.body || "").replace(/\s+/g, " ")
            color: theme.colors.subtext0 || "gray"
            font.family: theme.fontFamily
            font.pixelSize: 11
            elide: Text.ElideRight
        }
    }

    Rectangle {
        Layout.preferredWidth: 4
        Layout.preferredHeight: 22
        Layout.rightMargin: 4
        radius: 2
        color: root.accent
    }
}
