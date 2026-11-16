import QtQuick

import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool hasCurrent: false
    property int animLength: 400
    property var animCurve: [0.05, 0, 0.133, 0.06, 0.166, 0.4, 0.208, 0.82, 0.25, 1, 1, 1]
    property var colors: theme.colors

    property real menuX: 0
    property real menuY: 0

    function open(handle, x, y) {
        view.menuHandle = handle;
        view.reset();
        const width = 240;
        menuX = Math.max(8, Math.min(x - width / 2, Screen.width - width - 8));
        menuY = y - 32;
        hasCurrent = true;
    }

    function close() {
        hasCurrent = false;
        view.menuHandle = null;
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.hasCurrent ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // While open the whole screen takes input so clicking outside closes the
    // menu; while closed the mask is empty and clicks pass through.
    mask: Region {
        item: root.hasCurrent ? backdrop : null
    }

    MouseArea {
        id: backdrop

        anchors.fill: parent
        enabled: root.hasCurrent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: root.close()
    }

    Item {
        id: wrapper

        x: root.menuX
        y: root.menuY
        width: 240
        visible: height > 0
        clip: true
        focus: true
        implicitHeight: root.hasCurrent ? view.implicitHeight : 0

        Keys.onEscapePressed: view.goBack()

        Rectangle {
            anchors.fill: parent
            color: root.colors.base
            clip: true
            topLeftRadius: 0
            topRightRadius: 0
            bottomLeftRadius: 14
            bottomRightRadius: 14

            TrayMenuView {
                id: view
                width: parent.width
                colors: root.colors
                onClosed: root.close()
            }
        }

        Behavior on implicitHeight {
            NumberAnimation {
                duration: root.animLength
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.animCurve
            }
        }
    }
}
