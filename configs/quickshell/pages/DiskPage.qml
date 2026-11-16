import QtQuick
import QtQuick.Layouts

import "../services"

ColumnLayout {
    spacing: 10
    readonly property int pageWidth: 360

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

        Repeater {
            model: Disks.partitions

            delegate: Rectangle {
                required property var modelData

                Layout.fillWidth: true
                Layout.preferredHeight: 95
                radius: 12
                color: theme.colors.surface0 || "black"

                Column {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 4

                    Text {
                        text: modelData.mount
                        color: theme.colors.text || "black"
                        font.bold: true
                        font.pixelSize: 12
                    }

                    Row {
                        spacing: 10

                        Canvas {
                            width: 56
                            height: 56
                            property int usedPercent: modelData.usedPercent
                            property bool available: modelData.available

                            onPaint: {
                                const ctx = getContext("2d");
                                const cx = width / 2;
                                const cy = height / 2;
                                const r = Math.min(width, height) / 2 - 2;
                                const start = -Math.PI / 2;
                                const end = start + Math.PI * 2 * (available ? usedPercent / 100 : 0);

                                ctx.reset();
                                ctx.beginPath();
                                ctx.moveTo(cx, cy);
                                ctx.fillStyle = theme.colors.surface2 || "black";
                                ctx.arc(cx, cy, r, 0, Math.PI * 2, false);
                                ctx.fill();

                                if (available && usedPercent > 0) {
                                    ctx.beginPath();
                                    ctx.moveTo(cx, cy);
                                    ctx.fillStyle = usedPercent > 80 ? (theme.colors.red || "black") : (usedPercent > 50 ? (theme.colors.yellow || "black") : (theme.colors.green || "black"));
                                    ctx.arc(cx, cy, r, start, end, false);
                                    ctx.fill();
                                }

                                ctx.beginPath();
                                ctx.fillStyle = theme.colors.surface0 || "black";
                                ctx.arc(cx, cy, r * 0.52, 0, Math.PI * 2, false);
                                ctx.fill();
                            }

                            Component.onCompleted: requestPaint()
                            onAvailableChanged: requestPaint()
                            onUsedPercentChanged: requestPaint()
                        }

                        Column {
                            spacing: 2

                            Text {
                                text: modelData.available ? modelData.usedPercent + "% used" : "No data"
                                color: modelData.available ? (theme.colors.text || "black") : (theme.colors.subtext1 || "black")
                                font.pixelSize: 11
                            }

                            Text {
                                text: modelData.available ? modelData.freePercent + "% free" : "--"
                                color: theme.colors.subtext0 || "black"
                                font.pixelSize: 10
                            }

                            Text {
                                text: modelData.available ? modelData.used + " / " + modelData.total : "Not mounted"
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
