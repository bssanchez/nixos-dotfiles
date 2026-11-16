import QtQuick
import QtQuick.Layouts

import "../services"

ColumnLayout {
    spacing: 4
    readonly property int pageWidth: 325

    Text {
        text: "Core Usage"
        color: theme.colors.mauve || "black"
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
        Layout.bottomMargin: 2
    }

    Text {
        text: Cpu.name
        color: theme.colors.text || "black"
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        font.pixelSize: 12
    }

    Text {
        text: "Model " + Cpu.model + " | " + Cpu.coreCount + " cores"
        color: theme.colors.subtext0 || "black"
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 11
        Layout.bottomMargin: 8
    }

    Flickable {
        id: view
        Layout.fillWidth: true
        Layout.preferredHeight: 150
        contentWidth: bars.width
        contentHeight: bars.height
        clip: true

        Item {
            id: bars
            width: Math.max(view.width, barsRow.implicitWidth)
            height: view.height

            Row {
                id: barsRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                height: parent.height

                Repeater {
                    model: Cpu.coreCount

                    delegate: Column {
                        required property int index
                        readonly property int usage: Cpu.cores[index] || 0
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
                                height: Math.max(3, parent.height * (usage / 100))
                                radius: 6
                                color: usage > 80 ? (theme.colors.red || "black") : (usage > 50 ? (theme.colors.yellow || "black") : (theme.colors.green || "black"))

                                Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
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
