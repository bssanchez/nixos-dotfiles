import QtQuick

import Quickshell
import Quickshell.Wayland

// Marca de agua estilo "Activar Windows", pero de Linux. Vive en la capa de
// fondo como el visualizador: las ventanas la tapan y no recibe clics.
PanelWindow {
    id: watermark

    property var targetScreen
    screen: targetScreen

    anchors {
        right: true
        bottom: true
    }
    margins {
        right: 60
        bottom: 50
    }

    implicitWidth: textColumn.implicitWidth
    implicitHeight: textColumn.implicitHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-activate-linux"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    mask: Region {}

    Column {
        id: textColumn
        spacing: 2

        Text {
            text: "Activate Linux"
            font.pixelSize: 24
            color: Qt.rgba(1, 1, 1, 0.45)
        }

        Text {
            text: "Go to Settings to activate Linux."
            font.pixelSize: 14
            color: Qt.rgba(1, 1, 1, 0.45)
        }
    }
}
