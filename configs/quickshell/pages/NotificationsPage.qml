import QtQuick
import QtQuick.Layouts

import "../services"

ColumnLayout {
    id: root

    property bool showClose: false
    property bool showTitle: true
    // Alto máximo de la lista; en el panel lateral se estira con fillHeight.
    property int listHeight: 360

    signal requestClose()

    spacing: 14
    readonly property int pageWidth: 364

    Component.onCompleted: { Notifications.watchers++; Notifications.refresh(); }
    Component.onDestruction: Notifications.watchers--

    component HeaderButton: Rectangle {
        property string icon
        property color iconColor
        signal clicked()

        width: 30
        height: 30
        radius: 8
        color: hover.hovered ? (theme.colors.surface1 || "gray") : (theme.colors.surface0 || "gray")

        Text {
            anchors.centerIn: parent
            text: parent.icon
            color: parent.iconColor
            font.family: theme.fontFamily
            font.pixelSize: 14
        }

        HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: parent.clicked() }
    }

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: root.showTitle ? "Notificaciones" : Notifications.count + " recientes"
            color: root.showTitle ? (theme.colors.lavender || "white") : (theme.colors.subtext0 || "gray")
            font.family: theme.fontFamily
            font.bold: root.showTitle
            font.pixelSize: root.showTitle ? 16 : 12
            Layout.fillWidth: true
        }

        Text {
            visible: root.showTitle
            text: Notifications.count + ""
            color: theme.colors.subtext0 || "gray"
            font.family: theme.fontFamily
            font.pixelSize: 13
        }

        HeaderButton {
            icon: "󰎟"
            iconColor: theme.colors.red || "red"
            onClicked: Notifications.clear()
        }

        HeaderButton {
            visible: root.showClose
            icon: "󰅖"
            iconColor: theme.colors.text || "white"
            onClicked: root.requestClose()
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        color: theme.colors.surface0 || "gray"
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 140
        visible: Notifications.count === 0

        Column {
            anchors.centerIn: parent
            spacing: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "󰂛"
                color: theme.colors.surface2 || "gray"
                font.family: theme.fontFamily
                font.pixelSize: 48
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Sin notificaciones"
                color: theme.colors.subtext0 || "gray"
                font.family: theme.fontFamily
                font.pixelSize: 13
            }
        }
    }

    ListView {
        id: list
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.preferredHeight: Math.min(contentHeight, root.listHeight)
        visible: Notifications.count > 0
        clip: true
        spacing: 10
        model: Notifications.items
        boundsBehavior: Flickable.StopAtBounds

        delegate: Rectangle {
            required property var modelData
            readonly property color accent: theme.colors[Notifications.urgencyColorName(modelData.urgency)] || "white"

            width: ListView.view ? ListView.view.width : 0
            height: cardCol.implicitHeight + 24
            radius: 14
            color: theme.colors.surface0 || "black"

            Rectangle {
                width: 4
                height: parent.height - 16
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                radius: 2
                color: parent.accent
            }

            Column {
                id: cardCol
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 24
                anchors.rightMargin: 14
                spacing: 4

                Text {
                    width: parent.width
                    text: (modelData.app_name || "app").toString()
                    color: accent
                    font.family: theme.fontFamily
                    font.pixelSize: 11
                    font.bold: true
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: (modelData.summary || "").toString()
                    color: theme.colors.text || "white"
                    font.family: theme.fontFamily
                    font.pixelSize: 13
                    font.bold: true
                    wrapMode: Text.Wrap
                    visible: text !== ""
                }

                Text {
                    width: parent.width
                    text: (modelData.body || "").toString()
                    color: theme.colors.subtext1 || "gray"
                    font.family: theme.fontFamily
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                    maximumLineCount: 4
                    elide: Text.ElideRight
                    visible: text !== ""
                }
            }
        }
    }
}
