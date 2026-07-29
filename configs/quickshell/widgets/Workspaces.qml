import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Rectangle {
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
            model: Hyprland.workspaces?.values?.length > 7 ? Hyprland.workspaces.values.length : 7;

            Item {
                width: 32
                height: 24

                property var workspace: Hyprland.workspaces.values.find(ws => ws.id === index + 1) ?? null
                property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                property bool hasWindows: workspace !== null

                Text {
                    anchors.centerIn: parent
                    text: isActive ? "󰮯" : (hasWindows ? "󰊠" : "")
                    font.pixelSize: isActive || hasWindows ? 18 : 10
                    color: isActive ? (theme.colors.yellow || "black"): (hasWindows ? (theme.colors.lavender || "black") : (theme.colors.mauve || "black"))

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    // Hyprland 0.55 (config Lua): dispatch interpreta código Lua.
                    onClicked: Hyprland.dispatch("hl.dsp.focus({ workspace = " + (index + 1) + " })")
                }
            }
        }
    }
}
