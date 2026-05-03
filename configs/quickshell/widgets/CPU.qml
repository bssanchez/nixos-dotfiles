import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "../components"

Item {
    id: cpuWidget
    width: 80
    height: 34

    property bool popoverHovered: false
    property bool popoverVisible: false
    property int coreCount: 0

    property var lastIdle: []
    property var lastTotal: []

    property int totalCpu: 0
    property var coresUsage: []

    property string cpuName: "Unknown CPU"
    property string cpuModel: "Unknown"

    function showPopover() {
        hidePopoverTimer.stop();
        popoverVisible = true;
    }

    function schedulePopoverHide() {
        if (!hoverArea.containsMouse && !popoverHovered)
        hidePopoverTimer.restart();
    }

    Process {
        id: cpuInfoProc
        command: ["cat", "/proc/cpuinfo"]

        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim();
                if (text === "") return;

                let lines = text.split("\n");
                let modelName = "";
                let modelId = "";

                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();

                    if (modelName === "" && line.startsWith("model name")) {
                        let sep = line.indexOf(":");
                        if (sep !== -1) modelName = line.slice(sep + 1).trim();
                    }

                    if (modelId === "" && /^model\s*:/.test(line)) {
                        let sep = line.indexOf(":");
                        if (sep !== -1) modelId = line.slice(sep + 1).trim();
                    }

                    if (modelName !== "" && modelId !== "") break;
                }

                cpuWidget.cpuName = modelName !== "" ? modelName : "Unknown CPU";
                cpuWidget.cpuModel = modelId !== "" ? modelId : "Unknown";
            }
        }
    }

    Process {
        id: statProc
        command: ["cat", "/proc/stat"]

        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim();
                if (text === "") return;

                let lines = text.split("\n");
                let newCores = [];
                let currentTotal = 0;
                let coreIndex = 0;

                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i].trim();
                    if (!line.startsWith("cpu"))
                    continue;

                    let parts = line.replace(/\s+/g, " ").split(" ");
                    let name = parts[0];

                    let idle = parseInt(parts[4]) + parseInt(parts[5]);
                    let total = 0;
                    for (let j = 1; j < 9; j++)
                    total += parseInt(parts[j] || 0);

                    if (cpuWidget.lastTotal.length > coreIndex) {
                        let diffIdle = idle - cpuWidget.lastIdle[coreIndex];
                        let diffTotal = total - cpuWidget.lastTotal[coreIndex];
                        let usage = diffTotal > 0 ? ((diffTotal - diffIdle) / diffTotal) * 100 : 0;

                        if (name === "cpu")
                        currentTotal = Math.round(usage);
                        else
                        newCores.push(Math.round(usage));
                    }

                    cpuWidget.lastIdle[coreIndex] = idle;
                    cpuWidget.lastTotal[coreIndex] = total;
                    coreIndex++;
                }

                cpuWidget.coreCount = Math.max(coreIndex - 1, 0);

                if (cpuWidget.lastTotal.length > 0) {
                    cpuWidget.totalCpu = currentTotal;
                    cpuWidget.coresUsage = newCores;
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: statProc.running = true

        Component.onCompleted: {
            statProc.running = true;
            cpuInfoProc.running = true;
        }
    }

    Timer {
        id: hidePopoverTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (!hoverArea.containsMouse && !cpuWidget.popoverHovered)
            cpuWidget.popoverVisible = false;
        }
    }

    Rectangle {
        id: triggerPopup
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: ""
                color: theme.colors.red || "black"
                font.pixelSize: 16
            }

            Text {
                text: cpuWidget.totalCpu + "%"
                color: theme.colors.text || "black"
                font.pixelSize: 16
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: cpuWidget.showPopover()
            onExited: cpuWidget.schedulePopoverHide()
        }
    }

    PanelWindow {
        id: cpuPopover

        anchors {
            top: true
            left: true
        }

        margins {
            left: 20
        }

        WlrLayershell.layer: WlrLayer.Overlay

        visible: cpuWidget.popoverVisible
        implicitWidth: 350
        implicitHeight: cpuWidget.popoverVisible ? 250 : 0
        color: "transparent"

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 80
                easing.type: Easing.OutCubic
            }
        }

        Popout {
            id: popoverContent
            anchors.fill: parent
            alignment: 0
            asyncShapeLoad: false
            color: theme.colors.background || "black"
            radius: 20

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    cpuWidget.popoverHovered = true;
                    cpuWidget.showPopover();
                }
                onExited: {
                    cpuWidget.popoverHovered = false;
                    cpuWidget.schedulePopoverHide();
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4
                width: 325

                Text {
                    text: "Core Usage"
                    color: theme.colors.mauve || "black"
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 2
                }

                Text {
                    text: cpuWidget.cpuName
                    color: theme.colors.text || "black"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    font.pixelSize: 12
                }

                Text {
                    text: "Model " + cpuWidget.cpuModel + " | " + cpuWidget.coreCount + " cores"
                    color: theme.colors.subtext0 || "black"
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 11
                    Layout.bottomMargin: 8
                }

                Flickable {
                    id: equalizerView
                    Layout.fillWidth: true
                    Layout.preferredHeight: 150
                    contentWidth: barsContainer.width
                    contentHeight: barsContainer.height

                    Item {
                        id: barsContainer
                        width: Math.max(equalizerView.width, barsRow.implicitWidth)
                        height: equalizerView.height

                        Row {
                            id: barsRow
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 6
                            height: parent.height

                            Repeater {
                                model: cpuWidget.coreCount

                                delegate: Column {
                                    readonly property int coreUsage: cpuWidget.coresUsage[index] || 0
                                    spacing: 4

                                    Rectangle {
                                        width: 12
                                        height: 120
                                        radius: 6
                                        color: theme.colors.surface0 || "black"

                                        Rectangle {
                                            anchors.left: parent.left
                                            anchors.right: parent.right
                                            anchors.bottom: parent.bottom
                                            height: Math.max(3, parent.height * (coreUsage / 100))
                                            radius: 6
                                            color: coreUsage > 80 ? (theme.colors.red || "black") : (coreUsage > 50 ? (theme.colors.yellow || "black") : (theme.colors.green || "black"))

                                            Behavior on height {
                                                NumberAnimation {
                                                    duration: 300
                                                    easing.type: Easing.InOutQuad
                                                }
                                            }
                                        }
                                    }

                                    Text {
                                        text: index + 1
                                        color: theme.colors.subtext1 || "black"
                                        width: 12
                                        horizontalAlignment: Text.AlignHCenter
                                        font.pixelSize: 9
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
