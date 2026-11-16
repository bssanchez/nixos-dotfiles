import QtQuick

import Quickshell
import Quickshell.Wayland

// Popout de la barra clásica: se abre con clic y se mantiene mientras el cursor
// esté sobre el disparador o sobre el propio popout.
Item {
    id: root

    property bool triggerHovered: false
    property bool alignRight: false
    property int edgeMargin: 20
    property int extraHeight: 0
    property Component page

    property bool open: false
    property bool _hovered: false

    readonly property alias item: pageLoader.item

    function show() {
        hideTimer.stop();
        open = true;
    }

    function toggle() {
        if (open) open = false;
        else show();
    }

    function scheduleHide() {
        if (!triggerHovered && !_hovered)
            hideTimer.restart();
    }

    onTriggerHoveredChanged: if (!triggerHovered) scheduleHide()

    Timer {
        id: hideTimer
        interval: 140
        onTriggered: if (!root.triggerHovered && !root._hovered) root.open = false
    }

    PanelWindow {
        anchors {
            top: true
            left: !root.alignRight
            right: root.alignRight
        }

        margins {
            left: root.alignRight ? 0 : root.edgeMargin
            right: root.alignRight ? root.edgeMargin : 0
        }

        WlrLayershell.layer: WlrLayer.Overlay

        visible: root.open || wrapper.opacity > 0.01
        implicitWidth: (pageLoader.item?.pageWidth ?? 300) + 44
        implicitHeight: (pageLoader.item?.implicitHeight ?? 0) + 40 + root.extraHeight
        color: "transparent"

        Item {
            id: wrapper
            anchors.fill: parent
            transformOrigin: Item.Top
            opacity: root.open ? 1 : 0
            scale: root.open ? 1 : 0.92

            Behavior on opacity { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
            Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

            HoverHandler {
                onHoveredChanged: {
                    root._hovered = hovered;
                    if (hovered) root.show();
                    else root.scheduleHide();
                }
            }

            Popout {
                anchors.fill: parent
                alignment: 0
                asyncShapeLoad: false
                color: theme.colors.background || "black"
                radius: 20

                Loader {
                    id: pageLoader
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: root.extraHeight / 2
                    width: item?.pageWidth ?? 0
                    height: item?.implicitHeight ?? 0
                    active: root.open || wrapper.opacity > 0.01
                    sourceComponent: root.page
                }
            }
        }
    }
}
