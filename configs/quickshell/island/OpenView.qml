import QtQuick
import QtQuick.Layouts

import Quickshell

import "../components"
import "../pages"
import "../providers"
import "../services"

// Isla abierta: cabecera + dashboard o la página de un módulo.
ColumnLayout {
    id: root

    property bool active: false
    property string page: ""

    // La página montada cambia tras el fundido de salida, para no verla recortada.
    property string shownPage: ""
    readonly property bool live: active || opacity > 0

    signal closeRequested()

    readonly property var titles: ({
        network: "Conexiones",
        media: "Reproduciendo",
        cpu: "Procesador",
        memory: "Memoria",
        disk: "Almacenamiento",
        calendar: "Calendario",
        notifications: "Notificaciones"
    })

    function navigate(p) {
        page = p;
    }

    function back() {
        if (page !== "")
            page = "";
        else
            closeRequested();
    }

    onPageChanged: {
        if (active)
            swapTimer.restart();
        else
            shownPage = page;
    }

    Timer {
        id: swapTimer
        interval: 80
        onTriggered: root.shownPage = root.page
    }

    spacing: 16

    // ---- Cabecera ----
    RowLayout {
        id: header
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            visible: root.shownPage !== ""
            Layout.preferredWidth: 30
            Layout.preferredHeight: 30
            radius: 10
            color: backHover.hovered ? (theme.colors.surface1 || "gray") : (theme.colors.surface0 || "gray")

            Text {
                anchors.centerIn: parent
                text: "󰁍"
                color: theme.colors.text || "white"
                font.family: theme.fontFamily
                font.pixelSize: 15
            }

            HoverHandler { id: backHover; cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: root.back() }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                elide: Text.ElideRight
                text: root.shownPage === "" ? Time.format("hh:mm") : root.titles[root.shownPage]
                color: theme.colors.text || "white"
                font.family: theme.fontFamily
                font.bold: true
                font.pixelSize: root.shownPage === "" ? 26 : 16
            }

            Text {
                Layout.fillWidth: true
                visible: root.shownPage === ""
                text: Time.formatLocal("dddd, d 'de' MMMM")
                color: theme.colors.subtext0 || "gray"
                font.family: theme.fontFamily
                font.pixelSize: 12
            }
        }

        // Atajos fijos: batería, bloqueo de suspensión y energía.
        Text {
            text: Battery.icon + " " + Battery.level + "%"
            color: theme.colors[Battery.colorName] || "white"
            font.family: theme.fontFamily
            font.pixelSize: 12
            Layout.rightMargin: 4
        }

        component HeaderButton: Rectangle {
            property string icon
            property color iconColor: theme.colors.text || "white"
            signal clicked()

            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: 11
            color: hover.hovered ? (theme.colors.surface1 || "gray") : (theme.colors.surface0 || "gray")

            Text {
                anchors.centerIn: parent
                text: parent.icon
                color: parent.iconColor
                font.family: theme.fontFamily
                font.pixelSize: 15
            }

            HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
            TapHandler { onTapped: parent.clicked() }
        }

        HeaderButton {
            icon: Idle.enabled ? "󰒲" : "󰒳"
            iconColor: Idle.enabled ? (theme.colors.text || "white") : (theme.colors.peach || "orange")
            onClicked: Idle.toggle()
        }

        HeaderButton {
            icon: "󰐥"
            iconColor: theme.colors.red || "red"
            onClicked: {
                root.closeRequested();
                Quickshell.execDetached(["sh", "-c", "~/.config/hypr/scripts/powermenu.sh"]);
            }
        }
    }

    // ---- Cuerpo ----
    Item {
        id: body
        Layout.fillWidth: true
        implicitWidth: current?.pageWidth ?? current?.implicitWidth ?? 0
        implicitHeight: current?.implicitHeight ?? 0

        readonly property Item current: root.shownPage === "" ? dashLoader.item : pageLoader.item

        Loader {
            id: dashLoader
            width: parent.width
            active: root.live && root.shownPage === ""
            visible: active
            sourceComponent: Dashboard {
                onNavigate: p => root.navigate(p)
                onCloseRequested: root.closeRequested()
            }
        }

        Loader {
            id: pageLoader
            width: parent.width
            active: root.live && root.shownPage !== ""
            visible: active
            sourceComponent: {
                switch (root.shownPage) {
                case "network": return networkPage;
                case "media": return mediaPage;
                case "cpu": return cpuPage;
                case "memory": return memoryPage;
                case "disk": return diskPage;
                case "calendar": return calendarPage;
                case "notifications": return notificationsPage;
                }
                return null;
            }
        }
    }

    Component { id: networkPage; NetworkPage { showTitle: false; onRequestClose: root.closeRequested() } }
    Component { id: mediaPage; MediaPage {} }
    Component { id: cpuPage; CpuPage {} }
    Component { id: memoryPage; MemoryPage {} }
    Component { id: diskPage; DiskPage {} }
    Component { id: calendarPage; CalendarPage {} }
    Component { id: notificationsPage; NotificationsPage { showTitle: false; listHeight: 380 } }
}
