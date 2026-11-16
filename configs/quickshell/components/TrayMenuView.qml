import QtQuick
import QtQuick.Layouts

import Qt5Compat.GraphicalEffects

import Quickshell

// Vista de un menú dbus del tray con navegación por submenús.
Item {
    id: root

    property var menuHandle: null
    property var colors: theme.colors
    // Muestra la fila "atrás" también en el nivel raíz (la isla la usa para volver al dashboard).
    property bool backAtRoot: false
    property string rootTitle: ""

    property var currentOpener: sourceOpener
    readonly property int depth: pathModel.count

    // Se emite al activar una entrada o al retroceder desde la raíz.
    signal closed()
    signal activated()

    implicitWidth: 240
    implicitHeight: menuColumn.implicitHeight + 16

    onMenuHandleChanged: reset()

    function reset() {
        currentOpener = sourceOpener;
        pathModel.clear();
        highlight.active = false;
    }

    // Submenus are tracked by label/position instead of by object reference:
    // some apps (nm-applet) rebuild their whole dbusmenu with new ids, which
    // destroys the entry we were holding and left the menu empty.
    function enterSubmenu(entry, position) {
        highlight.active = false;
        pathModel.append({ label: entry.text || "", position: position });
        currentOpener = levels.objectAt(pathModel.count - 1);
    }

    function goBack() {
        if (pathModel.count === 0) {
            closed();
            return;
        }
        highlight.active = false;
        currentOpener = pathModel.count > 1 ? levels.objectAt(pathModel.count - 2) : sourceOpener;
        pathModel.remove(pathModel.count - 1);
    }

    function findEntry(opener, label, position) {
        if (!opener)
            return null;
        const items = opener.children.values;
        for (let i = 0; i < items.length; i++) {
            const e = items[i];
            if (e && e.hasChildren && e.text === label)
                return e;
        }
        const fallback = items[position];
        return fallback && fallback.hasChildren ? fallback : null;
    }

    ListModel {
        id: pathModel
    }

    QsMenuOpener {
        id: sourceOpener
        menu: root.menuHandle
    }

    // One opener per submenu level, so every parent stays loaded and each
    // level re-resolves itself when the app rebuilds its menu.
    Instantiator {
        id: levels

        model: pathModel
        onObjectAdded: (index, object) => {
            object.parentOpener = index === 0 ? sourceOpener : levels.objectAt(index - 1);
        }

        delegate: QsMenuOpener {
            required property string label
            required property int position
            property var parentOpener: null

            menu: root.findEntry(parentOpener, label, position)
        }
    }

    // Swallow clicks on the padding so they don't reach whatever is behind
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    }

    Rectangle {
        id: highlight

        property real targetY: 0
        property bool active: false

        x: 8
        y: menuColumn.y + targetY
        width: parent.width - 16
        height: 36
        radius: 8
        color: root.colors.crust
        opacity: active ? 0.15 : 0

        Behavior on y {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutBack
                easing.overshoot: 0.8
            }
        }

        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    Column {
        id: menuColumn

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.leftMargin: 8
        anchors.rightMargin: 8
        spacing: 2

        Item {
            id: backItem

            readonly property bool isHighlighted: highlight.active && highlight.targetY === backItem.y

            visible: root.depth > 0 || root.backAtRoot
            width: menuColumn.width
            height: visible ? 36 : 0

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 12

                Text {
                    Layout.preferredWidth: 20
                    horizontalAlignment: Text.AlignHCenter
                    text: ""
                    font.family: theme.fontFamily
                    font.pixelSize: 12
                    color: root.colors.text
                }

                Text {
                    text: root.depth > 0 ? pathModel.get(root.depth - 1).label : root.rootTitle
                    color: backItem.isHighlighted ? root.colors.text : root.colors.subtext0
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    font.pixelSize: 13
                    font.bold: true
                    font.letterSpacing: 0.2
                    verticalAlignment: Text.AlignVCenter
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    highlight.targetY = backItem.y;
                    highlight.active = true;
                }
                onClicked: root.goBack()
            }
        }

        Repeater {
            model: root.currentOpener ? root.currentOpener.children : null

            delegate: Item {
                id: menuItem

                required property var modelData
                required property int index

                property bool isSeparator: modelData.isSeparator
                property bool hasChildren: modelData.hasChildren
                readonly property bool isHighlighted: highlight.active && highlight.targetY === menuItem.y

                width: menuColumn.width
                height: isSeparator ? 12 : 36

                Rectangle {
                    visible: isSeparator
                    anchors.centerIn: parent
                    width: parent.width - 16
                    height: 1
                    color: root.colors.surface0
                    opacity: 0.5
                }

                Rectangle {
                    visible: !isSeparator && menuItem.isHighlighted
                    width: 3
                    height: 16
                    radius: 2
                    color: root.colors.mauve
                    anchors.left: parent.left
                    anchors.leftMargin: 4
                    anchors.verticalCenter: parent.verticalCenter
                }

                RowLayout {
                    visible: !isSeparator
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Item {
                        Layout.preferredWidth: 20
                        Layout.preferredHeight: 20

                        Image {
                            anchors.centerIn: parent
                            width: 16
                            height: 16
                            source: modelData.icon || ""
                            fillMode: Image.PreserveAspectFit
                            visible: modelData.icon !== undefined && modelData.icon !== ""
                            layer.enabled: true

                            layer.effect: ColorOverlay {
                                color: menuItem.isHighlighted ? root.colors.text : root.colors.subtext0
                            }
                        }
                    }

                    Text {
                        text: modelData.text || ""
                        color: menuItem.isHighlighted ? root.colors.text : root.colors.subtext0
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        font.pixelSize: 13
                        font.bold: true
                        font.letterSpacing: 0.2
                        verticalAlignment: Text.AlignVCenter
                    }

                    Text {
                        visible: (modelData.checkable && modelData.checked) || menuItem.hasChildren
                        text: menuItem.hasChildren ? "" : ""
                        font.family: theme.fontFamily
                        color: root.colors.text
                        font.pixelSize: 12
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    enabled: !isSeparator && modelData.enabled !== false
                    cursorShape: isSeparator ? Qt.ArrowCursor : Qt.PointingHandCursor
                    onEntered: {
                        highlight.targetY = menuItem.y;
                        highlight.active = true;
                    }
                    onClicked: {
                        if (modelData.hasChildren) {
                            root.enterSubmenu(modelData, menuItem.index);
                        } else {
                            modelData.triggered();
                            root.activated();
                            root.closed();
                        }
                    }
                }
            }
        }
    }
}
