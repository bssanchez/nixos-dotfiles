import QtQuick

import Quickshell
import Quickshell.Wayland

import "../services"

Scope {
    id: root

    required property var screen
    property alias island: body
    property bool autoHide: false

    // Alto que asoma de cada burbuja escondida; es también la zona de hover para mostrarla.
    readonly property int peek: 4

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
        exclusiveZone: root.autoHide ? 0 : 40
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

            readonly property bool wanted: expanded || moment !== "" || hovered || songPeek.running
            property bool shown: !root.autoHide || wanted || bodyLinger.running

            anchors.horizontalCenter: parent.horizontalCenter
            y: shown ? 0 : root.peek - height
            concealed: !shown
            monitorName: root.screen?.name ?? ""

            onWantedChanged: if (!wanted) bodyLinger.restart()
            Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
        }

        TraySatellite {
            id: satellite

            readonly property bool wanted: menuOpen || hovered
            property bool shown: !root.autoHide || wanted || satelliteLinger.running

            anchors.right: parent.right
            anchors.rightMargin: 12
            y: shown ? 0 : root.peek - height

            onWantedChanged: if (!wanted) satelliteLinger.restart()
            Behavior on y { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
        }

        Timer { id: bodyLinger; interval: 700 }
        Timer { id: satelliteLinger; interval: 700 }

        // Al cambiar de canción la isla asoma un momento con la carátula.
        Timer { id: songPeek; interval: 3000 }

        Connections {
            target: Media
            function onTitleChanged() { if (Media.playing && Media.title !== "") songPeek.restart(); }
        }
    }
}
