import QtQuick

import Quickshell.Services.SystemTray

import "../components"

// Burbuja satélite con el system tray; con clic derecho crece hacia abajo con el menú.
MorphSurface {
    id: root

    property bool menuOpen: false
    property var menuItem: null

    readonly property bool hasItems: SystemTray.items.values.length > 0
    readonly property real padX: 6
    readonly property real padTop: menuOpen ? 6 : 7
    readonly property real padBottom: menuOpen ? 12 : 7
    readonly property Item activeView: menuOpen ? menuView : row

    function openMenu(item) {
        menuItem = item;
        menuOpen = true;
        forceActiveFocus();
    }

    function closeMenu() {
        menuOpen = false;
    }

    visible: hasItems
    targetShoulder: menuOpen ? 20 : 14
    stage: menuOpen ? "menu:" + (menuItem?.id ?? "") : "icons"
    targetWidth: activeView.implicitWidth + 2 * (targetShoulder + padX)
    targetHeight: activeView.implicitHeight + padTop + padBottom

    Keys.onEscapePressed: menuView.goBack()

    Item {
        anchors.fill: parent
        anchors.leftMargin: root.padX
        anchors.rightMargin: root.padX
        anchors.topMargin: root.padTop

        TrayRow {
            id: row
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: root.revealed && !root.menuOpen ? 1 : 0
            enabled: !root.menuOpen
            Reveal on opacity {}
            onMenuRequested: item => root.openMenu(item)
        }

        TrayMenuView {
            id: menuView
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: 260
            width: implicitWidth
            menuHandle: root.menuOpen ? (root.menuItem?.menu ?? null) : null
            backAtRoot: true
            rootTitle: root.menuItem?.tooltipTitle || root.menuItem?.title || root.menuItem?.id || "Menú"
            opacity: root.revealed && root.menuOpen ? 1 : 0
            enabled: root.menuOpen
            Reveal on opacity {}
            onClosed: root.closeMenu()
        }
    }
}
