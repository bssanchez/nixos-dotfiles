import QtQuick
import QtQuick.Layouts

import "../components"
import "../services"

ColumnLayout {
    id: root

    property bool showTitle: true

    signal requestClose()

    spacing: 12
    readonly property int pageWidth: 348

    Component.onCompleted: { Network.watchers++; Network.refresh(); }
    Component.onDestruction: Network.watchers--

    Text {
        visible: root.showTitle
        text: "Conexiones"
        color: theme.colors.mauve || "white"
        font.family: theme.fontFamily
        font.bold: true
        font.pixelSize: 15
        Layout.alignment: Qt.AlignHCenter
    }

    component Card: Rectangle {
        default property alias content: col.data
        Layout.fillWidth: true
        Layout.preferredHeight: col.implicitHeight + 24
        radius: 14
        color: theme.colors.surface0 || "black"

        ColumnLayout {
            id: col
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            spacing: 10
        }
    }

    component Header: RowLayout {
        property string icon
        property color iconColor
        property string title
        property string subtitle
        property alias checked: sw.checked
        property alias accent: sw.accent
        signal toggled()

        Layout.fillWidth: true
        spacing: 12

        Text {
            text: parent.icon
            color: parent.iconColor
            font.family: theme.fontFamily
            font.pixelSize: 22
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: title
                color: theme.colors.text || "white"
                font.family: theme.fontFamily
                font.pixelSize: 13
                font.bold: true
            }

            Text {
                Layout.fillWidth: true
                text: subtitle
                color: theme.colors.subtext0 || "gray"
                font.family: theme.fontFamily
                font.pixelSize: 12
                elide: Text.ElideRight
            }
        }

        Switch {
            id: sw
            onToggled: parent.toggled()
        }
    }

    Card {
        Header {
            icon: Network.netIcon
            iconColor: (!Network.wifiOn && Network.connType !== "ethernet") ? (theme.colors.overlay0 || "gray")
                : (Network.connected ? (theme.colors.blue || "white") : (theme.colors.yellow || "white"))
            title: "Red"
            subtitle: Network.netLabel
            checked: Network.wifiOn
            accent: theme.colors.blue || "blue"
            onToggled: Network.toggleWifi()
        }

        ActionButton {
            icon: "󰤨"
            label: "Administrar red (gazelle)"
            onClicked: { Network.openWifiManager(); root.requestClose(); }
        }
    }

    Card {
        Header {
            icon: Network.btIcon
            iconColor: !Network.btPowered ? (theme.colors.overlay0 || "gray")
                : (Network.btDevices.length > 0 ? (theme.colors.sapphire || "white") : (theme.colors.blue || "white"))
            title: "Bluetooth"
            subtitle: Network.btLabel
            checked: Network.btPowered
            accent: theme.colors.sapphire || "blue"
            onToggled: Network.toggleBluetooth()
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: 34
            spacing: 4
            visible: Network.btDevices.length > 0

            Repeater {
                model: Network.btDevices

                delegate: Row {
                    required property var modelData
                    spacing: 8

                    Text {
                        text: "󰂱"
                        color: theme.colors.sapphire || "white"
                        font.family: theme.fontFamily
                        font.pixelSize: 12
                    }

                    Text {
                        text: modelData
                        color: theme.colors.subtext1 || "gray"
                        font.family: theme.fontFamily
                        font.pixelSize: 12
                    }
                }
            }
        }

        ActionButton {
            icon: "󰂯"
            iconColor: theme.colors.sapphire || "white"
            label: "Administrar Bluetooth (bluetui)"
            onClicked: { Network.openBluetoothManager(); root.requestClose(); }
        }
    }
}
