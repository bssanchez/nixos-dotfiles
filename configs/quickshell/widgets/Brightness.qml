import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

Item {
    id: brightnessWidget
    width: 74
    height: 34

    property int level: 0

    function brightnessIcon() {
        if (level < 34) return "󰃞";
        if (level < 67) return "󰃟";
        return "󰃠";
    }

    Process {
        id: brightnessProc
        command: ["brightnessctl", "-m"]

        stdout: StdioCollector {
            onStreamFinished: {
                // "amdgpu_bl1,backlight,60000,92%,64764"
                const m = this.text.trim().match(/,(\d+)%,/);
                if (m)
                    brightnessWidget.level = parseInt(m[1]);
            }
        }
    }

    Process { id: setProc }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: brightnessProc.running = true
        Component.onCompleted: brightnessProc.running = true
    }

    Timer {
        id: quickRefresh
        interval: 60
        repeat: false
        onTriggered: brightnessProc.running = true
    }

    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: brightnessWidget.brightnessIcon()
                color: theme.colors.yellow || "white"
                font.family: theme.fontFamily
                font.pixelSize: 15
            }

            Text {
                text: brightnessWidget.level + "%"
                color: theme.colors.text || "black"
                font.pixelSize: 15
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            cursorShape: Qt.PointingHandCursor

            onClicked: (mouse) => {
                const target = mouse.button === Qt.MiddleButton ? "10%" : "60%";
                setProc.command = ["brightnessctl", "-e4", "-n2", "set", target];
                setProc.running = true;
                quickRefresh.restart();
            }

            onWheel: (wheel) => {
                const dir = wheel.angleDelta.y > 0 ? "5%+" : "5%-";
                setProc.command = ["brightnessctl", "-e4", "-n2", "set", dir];
                setProc.running = true;
                quickRefresh.restart();
            }
        }
    }
}
