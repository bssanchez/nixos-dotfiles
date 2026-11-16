import QtQuick

import Quickshell
import Quickshell.Wayland

import "../services"

Item {
    id: root
    width: 74
    height: 34

    property string alertLevel: "low"
    property bool alertVisible: false

    Connections {
        target: Battery
        function onAlert(kind) {
            root.alertLevel = kind;
            root.alertVisible = true;
            alertHideTimer.restart();
        }
    }

    Timer {
        id: alertHideTimer
        interval: 8000
        onTriggered: root.alertVisible = false
    }

    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: Battery.icon
                color: theme.colors[Battery.colorName] || "white"
                font.family: theme.fontFamily
                font.pixelSize: 14
            }

            Text {
                text: Battery.level + "%"
                color: theme.colors.text || "black"
                font.pixelSize: 14
            }
        }
    }

    PanelWindow {
        anchors { top: true }
        margins { top: 50 }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-battery-alert"
        exclusionMode: ExclusionMode.Ignore

        visible: root.alertVisible
        implicitWidth: 320
        implicitHeight: 64
        color: "transparent"

        Rectangle {
            readonly property color accent: root.alertLevel === "critical" ? (theme.colors.red || "red") : (theme.colors.peach || "orange")

            anchors.centerIn: parent
            width: 300
            height: 52
            radius: 16
            color: theme.colors.crust || "black"
            border.width: 2
            border.color: accent

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰂃"
                    color: parent.parent.accent
                    font.family: theme.fontFamily
                    font.pixelSize: 24
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: root.alertLevel === "critical" ? "¡Battery is dying!" : "Battery Low"
                        color: theme.colors.text || "white"
                        font.family: theme.fontFamily
                        font.bold: true
                        font.pixelSize: 14
                    }

                    Text {
                        text: "Conecta el cargador — " + Battery.level + "%"
                        color: theme.colors.subtext0 || "gray"
                        font.family: theme.fontFamily
                        font.pixelSize: 12
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.alertVisible = false
            }
        }
    }
}
