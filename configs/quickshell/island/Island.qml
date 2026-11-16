import QtQuick

import Quickshell
import Quickshell.Wayland

Scope {
    id: root

    required property var screen
    property alias island: body

    // Reserva el hueco de la isla en reposo; layer-shell ignora la zona exclusiva
    // de una capa anclada a los 4 bordes como la ventana principal.
    PanelWindow {
        screen: root.screen
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 1
        exclusiveZone: 40
        color: "transparent"
        mask: Region {}
        WlrLayershell.namespace: "quickshell-island-reserve"
    }

    // Tamaño fijo: redimensionar la capa en cada frame de la animación produce saltos.
    // HyprlandFocusGrab se libera al instante en este Hyprland, así que el clic fuera
    // se detecta con un fondo que solo recibe input mientras la isla está abierta.
    PanelWindow {
        id: win
        screen: root.screen

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        exclusionMode: ExclusionMode.Ignore
        color: "transparent"

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "quickshell-island"
        readonly property bool modal: body.expanded || satellite.menuOpen

        WlrLayershell.keyboardFocus: modal ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        mask: Region {
            item: win.modal ? backdrop : body
            Region { item: win.modal ? null : satellite }
        }

        MouseArea {
            id: backdrop
            anchors.fill: parent
            enabled: win.modal
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            onClicked: {
                body.close();
                satellite.closeMenu();
            }
        }

        IslandBody {
            id: body
            anchors.horizontalCenter: parent.horizontalCenter
            y: 0
            monitorName: root.screen?.name ?? ""
        }

        TraySatellite {
            id: satellite
            anchors.right: parent.right
            anchors.rightMargin: 12
            y: 0
        }
    }
}
