// @ pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "../components"

Item {
    id: memWidget
    width: 100
    height: 34

    property bool popoverHovered: false
    property bool popoverVisible: false

    function showPopover() {
        hidePopoverTimer.stop();
        popoverVisible = true;
        topMemProc.running = true;
    }

    function togglePopover() {
        if (popoverVisible)
            popoverVisible = false;
        else
            showPopover();
    }

    function schedulePopoverHide() {
        if (!hoverArea.containsMouse && !popoverHovered)
            hidePopoverTimer.restart();
    }

    ListModel {
        id: topMemModel
    }

    Process {
        id: memInfoProc
        command: ["sh", "-c", "free -h | awk '/^Mem/ {print $3}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                memText.text = this.text.trim()
            }
        }
    }

    Process {
        id: topMemProc
        command: ["sh", "-c", "ps -eo pid,comm,%mem,rss --sort=-rss | head -n 11"]

        stdout: StdioCollector {
            onStreamFinished: {
                let text = this.text.trim();
                topMemModel.clear();
                if (text === "") return;

                let lines = text.split("\n");
                for (let i = 1; i < lines.length && topMemModel.count < 10; i++) {
                    let line = lines[i].trim();
                    if (line === "") continue;

                    let parts = line.split(/\s+/);
                    if (parts.length < 4) continue;

                    let rssKb = parseInt(parts[3]) || 0;
                    let rssMb = (rssKb / 1024).toFixed(1);

                    topMemModel.append({
                        pid: parts[0],
                        name: parts[1],
                        percent: parts[2],
                        rss: rssMb
                    });
                }
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            memInfoProc.running = true;
            topMemProc.running = true;
        }

        Component.onCompleted: {
            memInfoProc.running = true;
            topMemProc.running = true;
        }
    }

    Timer {
        id: hidePopoverTimer
        interval: 120
        repeat: false
        onTriggered: {
            if (!hoverArea.containsMouse && !memWidget.popoverHovered)
                memWidget.popoverVisible = false;
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
                color: theme.colors.sapphire || "black"
                text: ""
                font.pixelSize: 14
            }

            Text {
                id: memText
                text: "--"
                font.pixelSize: 14
                color: theme.colors.text || "black"
            }
        }

        MouseArea {
            id: hoverArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: memWidget.togglePopover()
            onExited: memWidget.schedulePopoverHide()
        }
    }

    PanelWindow {
        id: memPopover

        anchors {
            top: true
            left: true
        }

        margins {
            left: 20
        }

        WlrLayershell.layer: WlrLayer.Overlay

        visible: memWidget.popoverVisible || contentWrapper.opacity > 0.01
        implicitWidth: 380
        implicitHeight: 310
        color: "transparent"

        Item {
            id: contentWrapper
            anchors.fill: parent
            transformOrigin: Item.Top
            opacity: memWidget.popoverVisible ? 1 : 0
            scale: memWidget.popoverVisible ? 1 : 0.92

            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

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
                    memWidget.popoverHovered = true;
                    memWidget.showPopover();
                }
                onExited: {
                    memWidget.popoverHovered = false;
                    memWidget.schedulePopoverHide();
                }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Text {
                    text: "Top Memory Processes"
                    color: theme.colors.sapphire || "black"
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Top 10 por RSS (MB)"
                    color: theme.colors.subtext0 || "black"
                    font.pixelSize: 11
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 4
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: theme.colors.surface0 || "black"
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text { text: "#"; color: theme.colors.subtext1 || "black"; font.pixelSize: 11; Layout.preferredWidth: 24 }
                    Text { text: "PROC"; color: theme.colors.subtext1 || "black"; font.pixelSize: 11; Layout.fillWidth: true }
                    Text { text: "%MEM"; color: theme.colors.subtext1 || "black"; font.pixelSize: 11; Layout.preferredWidth: 50; horizontalAlignment: Text.AlignRight }
                    Text { text: "RSS"; color: theme.colors.subtext1 || "black"; font.pixelSize: 11; Layout.preferredWidth: 58; horizontalAlignment: Text.AlignRight }
                }

                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: topMemModel
                    spacing: 4
                    clip: true

                    delegate: RowLayout {
                        width: ListView.view.width
                        spacing: 8

                        Text {
                            text: (index + 1)
                            color: theme.colors.overlay1 || "black"
                            font.pixelSize: 11
                            Layout.preferredWidth: 24
                        }

                        Text {
                            text: model.name
                            color: theme.colors.text || "black"
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.percent
                            color: theme.colors.peach || "black"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 50
                        }

                        Text {
                            text: model.rss + " MB"
                            color: theme.colors.green || "black"
                            font.pixelSize: 11
                            horizontalAlignment: Text.AlignRight
                            Layout.preferredWidth: 58
                        }
                    }
                }
            }
        }
        }
    }
}
