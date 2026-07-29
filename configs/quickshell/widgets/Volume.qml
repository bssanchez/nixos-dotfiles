import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Io

Item {
    id: volumeWidget
    width: 78
    height: 34

    property int volume: 0
    property bool muted: false

    function volumeIcon() {
        if (muted || volume === 0) return "󰝟";
        if (volume < 34)          return "󰕿";
        if (volume < 67)          return "󰖀";
        return "󰕾";
    }

    Process {
        id: volumeProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]

        stdout: StdioCollector {
            onStreamFinished: {
                // Formato: "Volume: 0.25" o "Volume: 0.25 [MUTED]"
                const text = this.text.trim();
                const m = text.match(/Volume:\s*([0-9.]+)/);
                if (m)
                    volumeWidget.volume = Math.round(parseFloat(m[1]) * 100);
                volumeWidget.muted = text.indexOf("[MUTED]") !== -1;
            }
        }
    }

    Process { id: setProc }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: volumeProc.running = true
        Component.onCompleted: volumeProc.running = true
    }

    Timer {
        id: quickRefresh
        interval: 60
        repeat: false
        onTriggered: volumeProc.running = true
    }

    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: volumeWidget.volumeIcon()
                color: volumeWidget.muted ? (theme.colors.overlay0 || "gray") : (theme.colors.sky || "white")
                font.family: theme.fontFamily
                font.pixelSize: 15
            }

            Text {
                text: volumeWidget.muted ? "Mute" : (volumeWidget.volume + "%")
                color: theme.colors.text || "black"
                font.pixelSize: 15
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor

            onClicked: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    Quickshell.execDetached(["kitty", "-e", "wiremix"]);
                    return;
                }
                setProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"];
                setProc.running = true;
                quickRefresh.restart();
            }

            onWheel: (wheel) => {
                const dir = wheel.angleDelta.y > 0 ? "5%+" : "5%-";
                setProc.command = ["wpctl", "set-volume", "-l", "1", "@DEFAULT_AUDIO_SINK@", dir];
                setProc.running = true;
                quickRefresh.restart();
            }
        }
    }
}
