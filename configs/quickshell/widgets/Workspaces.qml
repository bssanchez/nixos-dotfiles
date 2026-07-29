import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: ws

    property string monitorName: ""
    readonly property int numWorkspaces: 10

    readonly property var mon:
        (Hyprland.monitors?.values ?? []).find(m => m.name === monitorName) ?? null

    readonly property var monWs:
        (Hyprland.workspaces?.values ?? [])
            .filter(w => w.id > 0 && w.monitor && w.monitor.name === monitorName)
            .map(w => ({ id: w.id, disp: ((w.id - 1) % numWorkspaces) + 1 }))

    readonly property int activeDisp:
        mon?.activeWorkspace ? (((mon.activeWorkspace.id - 1) % numWorkspaces) + 1) : -1

    readonly property int slotCount:
        Math.max(7, monWs.reduce((acc, w) => Math.max(acc, w.disp), 0))

    anchors.centerIn: parent

    width: wsRow.width + 16
    height: wsRow.height + 8

    color: theme.colors.crust || "black"
    radius: height / 2

    Row {
        id: wsRow
        anchors.centerIn: parent
        spacing: 4

        Repeater {
            model: ws.slotCount

            Item {
                width: 32
                height: 24

                property var workspace: ws.monWs.find(w => w.disp === index + 1) ?? null
                property bool isActive: ws.activeDisp === (index + 1)
                property bool hasWindows: workspace !== null

                Text {
                    anchors.centerIn: parent
                    text: parent.isActive ? "󰮯" : (parent.hasWindows ? "󰊠" : "●")
                    font.pixelSize: parent.isActive || parent.hasWindows ? 18 : 10
                    color: parent.isActive ? (theme.colors.yellow || "black") : (parent.hasWindows ? (theme.colors.lavender || "black") : (theme.colors.mauve || "black"))

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        Hyprland.dispatch("hl.dsp.focus({ monitor = \"" + ws.monitorName + "\" })");
                        Hyprland.dispatch("hs.dsp.focus({ workspace = " + (index + 1) + " })");
                    }
                }
            }
        }
    }
}
