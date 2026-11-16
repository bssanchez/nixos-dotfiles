import QtQuick
import QtQuick.Layouts

import "../services"

ColumnLayout {
    spacing: 8
    readonly property int pageWidth: 350

    Text {
        text: "Top Memory Processes"
        color: theme.colors.sapphire || "black"
        font.bold: true
        Layout.alignment: Qt.AlignHCenter
    }

    Text {
        text: "Top 10 por RSS (MB) · " + Memory.usedText + " / " + Memory.totalText
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
        Layout.preferredHeight: contentHeight
        model: Memory.top
        spacing: 4
        clip: true
        interactive: false

        delegate: RowLayout {
            required property var modelData
            required property int index
            width: ListView.view.width
            spacing: 8

            Text {
                text: index + 1
                color: theme.colors.overlay1 || "black"
                font.pixelSize: 11
                Layout.preferredWidth: 24
            }

            Text {
                text: modelData.name
                color: theme.colors.text || "black"
                font.pixelSize: 12
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: modelData.percent
                color: theme.colors.peach || "black"
                font.pixelSize: 11
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 50
            }

            Text {
                text: modelData.rss + " MB"
                color: theme.colors.green || "black"
                font.pixelSize: 11
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 58
            }
        }
    }
}
