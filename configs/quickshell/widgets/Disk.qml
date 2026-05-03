// @ pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "../components"

Item {
    id: diskWidget
    width: 140
    height: 34

    property bool popoverHovered: false
    property bool popoverVisible: false
    property string rootUsageText: "-- / --"
    property int rootUsedPercent: 0

    function showPopover() {
        hidePopoverTimer.stop();
        popoverVisible = true;
    }

    function schedulePopoverHide() {
        if (!hoverArea.containsMouse && !popoverHovered)
        hidePopoverTimer.restart();
    }

    function updatePartition(path, used, total, usedPercent, available) {
        for (let i = 0; i < partitionsModel.count; i++) {
            if (partitionsModel.get(i).mount === path) {
                partitionsModel.set(i, {
                    mount: path,
                    used: used,
                    total: total,
                    usedPercent: usedPercent,
                    freePercent: Math.max(0, 100 - usedPercent),
                    available: available
                });
                return;
            }
        }
    }

    ListModel {
        id: partitionsModel

        ListElement { mount: "/"; used: "--"; total: "--"; usedPercent: 0; freePercent: 100; available: false }
        ListElement { mount: "/tmp"; used: "--"; total: "--"; usedPercent: 0; freePercent: 100; available: false }
        ListElement { mount: "/srv"; used: "--"; total: "--"; usedPercent: 0; freePercent: 100; available: false }
        ListElement { mount: "/home"; used: "--"; total: "--"; usedPercent: 0; freePercent: 100; available: false }
    }

    Process {
        id: diskInfoProc
        command: [
            "sh",
            "-c",
            "for p in / /tmp /srv /home; do " +
            "if [ -e \"$p\" ]; then " +
            "df -hP \"$p\" | awk -v path=\"$p\" 'NR==2 {print path\"|\"$3\"|\"$2\"|\"$5}'; " +
            "else echo \"$p|N/A|N/A|N/A\"; " +
            "fi; " +
            "done"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n");

                for (let i = 0; i < lines.length; i++) {
                    const line = lines[i].trim();
                    if (line === "")
                    continue;

                    const parts = line.split("|");
                    if (parts.length < 4)
                    continue;

                    const mount = parts[0];
                    const used = parts[1];
                    const total = parts[2];
                    const percentValue = parseInt(parts[3].replace("%", ""));
                    const available = !isNaN(percentValue);
                    const usedPercent = available ? Math.max(0, Math.min(100, percentValue)) : 0;

                    diskWidget.updatePartition(mount, used, total, usedPercent, available);

                    if (mount === "/") {
                        diskWidget.rootUsageText = available ? (used + " / " + total) : "-- / --";
                        diskWidget.rootUsedPercent = usedPercent;
                    }
                }
            }
        }
    }

    Component.onCompleted: diskInfoProc.running = true

    Timer {
        id: hidePopoverTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (!hoverArea.containsMouse && !diskWidget.popoverHovered)
            diskWidget.popoverVisible = false;
        }
    }

    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                color: theme.colors.yellow || "black"
                text: ""
                font.pixelSize: 14
            }

            Text {
                text: diskWidget.rootUsageText
                font.pixelSize: 14
                color: theme.colors.text || "black"
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            onEntered: diskWidget.showPopover()
            onExited: diskWidget.schedulePopoverHide()
        }
    }

    PanelWindow {
        id: diskPopover

        anchors {
            top: true
            left: true
        }

        margins {
            left: 125
        }

        WlrLayershell.layer: WlrLayer.Overlay

        visible: diskWidget.popoverVisible
        implicitWidth: 400
        implicitHeight: diskWidget.popoverVisible ? 280 : 0
        color: "transparent"

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 80
                easing.type: Easing.OutCubic
            }
        }

        Popout {
            anchors.fill: parent
            alignment: 0
            asyncShapeLoad: false
            color: theme.colors.background || "black"
            radius: 20

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    diskWidget.popoverHovered = true;
                    diskWidget.showPopover();
                }
                onExited: {
                    diskWidget.popoverHovered = false;
                    diskWidget.schedulePopoverHide();
                }
            }

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 10
                width: parent.width * 90 / 100

                Text {
                    text: "Partitions"
                    color: theme.colors.mauve || "black"
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                GridLayout {
                    columns: 2
                    rowSpacing: 10
                    columnSpacing: 10
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Repeater {
                        model: partitionsModel

                        delegate: Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.minimumHeight: 95
                            radius: 12
                            color: theme.colors.surface0 || "black"

                            Column {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 4

                                Text {
                                    text: mount
                                    color: theme.colors.text || "black"
                                    font.bold: true
                                    font.pixelSize: 12
                                }

                                Row {
                                    spacing: 10

                                    Canvas {
                                        id: pieChart
                                        width: 56
                                        height: 56
                                        property int chartUsedPercent: usedPercent
                                        property bool chartAvailable: available

                                        onPaint: {
                                            const ctx = getContext("2d");
                                            const centerX = width / 2;
                                            const centerY = height / 2;
                                            const radius = Math.min(width, height) / 2 - 2;
                                            const start = -Math.PI / 2;
                                            const usedRatio = chartAvailable ? (chartUsedPercent / 100) : 0;
                                            const usedEnd = start + (Math.PI * 2 * usedRatio);

                                            ctx.reset();

                                            ctx.beginPath();
                                            ctx.moveTo(centerX, centerY);
                                            ctx.fillStyle = theme.colors.surface2 || "black";
                                            ctx.arc(centerX, centerY, radius, 0, Math.PI * 2, false);
                                            ctx.closePath();
                                            ctx.fill();

                                            if (chartAvailable && chartUsedPercent > 0) {
                                                ctx.beginPath();
                                                ctx.moveTo(centerX, centerY);
                                                ctx.fillStyle = chartUsedPercent > 80 ? (theme.colors.red || "black") : (chartUsedPercent > 50 ? (theme.colors.yellow || "black") : (theme.colors.green || "black"));
                                                ctx.arc(centerX, centerY, radius, start, usedEnd, false);
                                                ctx.closePath();
                                                ctx.fill();
                                            }

                                            ctx.beginPath();
                                            ctx.fillStyle = theme.colors.surface0 || "black";
                                            ctx.arc(centerX, centerY, radius * 0.52, 0, Math.PI * 2, false);
                                            ctx.closePath();
                                            ctx.fill();
                                        }

                                        Component.onCompleted: requestPaint()
                                        onChartAvailableChanged: requestPaint()
                                        onChartUsedPercentChanged: requestPaint()
                                    }

                                    Column {
                                        spacing: 2

                                        Text {
                                            text: available ? (usedPercent + "% used") : "No data"
                                            color: available ? (theme.colors.text  || "black") : (theme.colors.subtext1  || "black")
                                            font.pixelSize: 11
                                        }

                                        Text {
                                            text: available ? (freePercent + "% free") : "--"
                                            color: theme.colors.subtext0 || "black"
                                            font.pixelSize: 10
                                        }

                                        Text {
                                            text: available ? (used + " / " + total) : "Not mounted"
                                            color: theme.colors.subtext1 || "black"
                                            font.pixelSize: 10
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
}
