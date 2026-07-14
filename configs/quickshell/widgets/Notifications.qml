import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Item {
    id: root
    width: 44
    height: 34

    property bool panelOpen: false
    property var items: []
    readonly property int count: items.length
    // mako no puede borrar su historial; ocultamos lo ya visto con este baseline.
    property int clearedBeforeId: 0

    function urgencyColor(u) {
        if (u === "critical") return theme.colors.red || "red";
        if (u === "low")      return theme.colors.overlay0 || "gray";
        return theme.colors.lavender || "white";
    }

    function refresh() {
        historyProc.running = true;
    }

    function togglePanel() {
        panelOpen = !panelOpen;
        if (panelOpen)
            refresh();
    }

    Process {
        id: historyProc
        command: ["makoctl", "history", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                const text = this.text.trim();
                if (text === "") {
                    root.items = [];
                    return;
                }
                try {
                    const data = JSON.parse(text);
                    const list = Array.isArray(data) ? data : (data.data || []);

                    // Detecta reinicio de mako (los ids vuelven a empezar): resetea baseline.
                    let maxId = 0;
                    for (const n of list)
                        if (n.id > maxId) maxId = n.id;
                    if (maxId < root.clearedBeforeId)
                        root.clearedBeforeId = 0;

                    // Más recientes primero, ocultando lo ya limpiado.
                    root.items = list
                        .filter(n => n.id > root.clearedBeforeId)
                        .reverse();
                } catch (e) {
                    root.items = [];
                }
            }
        }
    }

    // Proceso para acciones (limpiar / descartar).
    Process { id: actionProc }

    // Refresco mientras el panel está abierto, para ver notificaciones nuevas.
    Timer {
        interval: 2000
        repeat: true
        running: root.panelOpen
        onTriggered: root.refresh()
    }

    // Pastilla con la campana en la barra
    Rectangle {
        anchors.fill: parent
        color: root.panelOpen ? (theme.colors.surface0 || "black") : (theme.colors.crust || "black")
        radius: height / 2

        Text {
            anchors.centerIn: parent
            text: root.count > 0 ? "󰂚" : "󰂜"
            color: root.panelOpen ? (theme.colors.lavender || "white") : (theme.colors.text || "white")
            font.family: theme.fontFamily
            font.pixelSize: 16
        }

        // Badge con el conteo
        Rectangle {
            visible: root.count > 0
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.topMargin: 2
            anchors.rightMargin: 2
            width: 15
            height: 15
            radius: width / 2
            color: theme.colors.red || "red"

            Text {
                anchors.centerIn: parent
                text: root.count > 9 ? "9+" : root.count
                color: theme.colors.crust || "black"
                font.family: theme.fontFamily
                font.pixelSize: 9
                font.bold: true
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: root.togglePanel()
        }
    }

    // Panel lateral derecho con las notificaciones recientes
    PanelWindow {
        anchors {
            top: true
            right: true
            bottom: true
        }

        margins {
            top: 5
            right: 5
            bottom: 5
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-notifications"

        visible: root.panelOpen
        implicitWidth: root.panelOpen ? 400 : 0
        color: "transparent"

        Behavior on implicitWidth {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            anchors.fill: parent
            radius: 20
            color: theme.colors.background || "black"
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 18
                spacing: 14

                // Encabezado
                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: "Notificaciones"
                        color: theme.colors.lavender || "white"
                        font.family: theme.fontFamily
                        font.bold: true
                        font.pixelSize: 16
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.count + ""
                        color: theme.colors.subtext0 || "gray"
                        font.family: theme.fontFamily
                        font.pixelSize: 13
                    }

                    // Limpiar (descarta las visibles)
                    Rectangle {
                        width: 30
                        height: 30
                        radius: 8
                        color: clearHover.hovered ? (theme.colors.surface1 || "gray") : (theme.colors.surface0 || "gray")

                        Text {
                            anchors.centerIn: parent
                            text: "󰎟"
                            color: theme.colors.red || "red"
                            font.family: theme.fontFamily
                            font.pixelSize: 15
                        }

                        HoverHandler { id: clearHover }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                // Descarta las visibles y oculta el historial ya visto.
                                actionProc.command = ["makoctl", "dismiss", "--all"];
                                actionProc.running = true;
                                let maxId = 0;
                                for (const n of root.items)
                                    if (n.id > maxId) maxId = n.id;
                                root.clearedBeforeId = maxId;
                                root.items = [];
                            }
                        }
                    }

                    // Cerrar panel
                    Rectangle {
                        width: 30
                        height: 30
                        radius: 8
                        color: closeHover.hovered ? (theme.colors.surface1 || "gray") : (theme.colors.surface0 || "gray")

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: theme.colors.text || "white"
                            font.family: theme.fontFamily
                            font.pixelSize: 13
                        }

                        HoverHandler { id: closeHover }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.panelOpen = false
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 1
                    color: theme.colors.surface0 || "gray"
                }

                // Estado vacío
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.count === 0

                    Column {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "󰂛"
                            color: theme.colors.surface2 || "gray"
                            font.family: theme.fontFamily
                            font.pixelSize: 48
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: "Sin notificaciones"
                            color: theme.colors.subtext0 || "gray"
                            font.family: theme.fontFamily
                            font.pixelSize: 13
                        }
                    }
                }

                // Lista de notificaciones
                ListView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: root.count > 0
                    clip: true
                    spacing: 10
                    model: root.items
                    boundsBehavior: Flickable.StopAtBounds

                    delegate: Rectangle {
                        required property var modelData
                        width: ListView.view ? ListView.view.width : 0
                        height: cardCol.implicitHeight + 24
                        radius: 14
                        color: theme.colors.surface0 || "black"

                        // Barra de acento por urgencia
                        Rectangle {
                            width: 4
                            height: parent.height - 16
                            anchors.left: parent.left
                            anchors.leftMargin: 8
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 2
                            color: root.urgencyColor(modelData.urgency)
                        }

                        Column {
                            id: cardCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 24
                            anchors.rightMargin: 14
                            spacing: 4

                            Row {
                                width: parent.width
                                spacing: 6

                                Text {
                                    text: (modelData.app_name || "app").toString()
                                    color: root.urgencyColor(modelData.urgency)
                                    font.family: theme.fontFamily
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    width: Math.min(implicitWidth, parent.width)
                                }
                            }

                            Text {
                                width: parent.width
                                text: (modelData.summary || "").toString()
                                color: theme.colors.text || "white"
                                font.family: theme.fontFamily
                                font.pixelSize: 13
                                font.bold: true
                                wrapMode: Text.Wrap
                                visible: text !== ""
                            }

                            Text {
                                width: parent.width
                                text: (modelData.body || "").toString()
                                color: theme.colors.subtext1 || "gray"
                                font.family: theme.fontFamily
                                font.pixelSize: 12
                                wrapMode: Text.Wrap
                                visible: text !== ""
                            }
                        }
                    }
                }
            }
        }
    }
}
