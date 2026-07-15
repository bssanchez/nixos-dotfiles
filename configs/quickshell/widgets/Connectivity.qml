import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Io

import "../components"

Item {
    id: root
    width: 74
    height: 34

    property bool popoverHovered: false
    property bool popoverVisible: false

    // --- Estado de red (NetworkManager) ---
    property string wifiRadio: "disabled"   // enabled | disabled
    property string connName: ""             // nombre de la conexión activa
    property string connType: ""             // wifi | ethernet | ""
    property int wifiSignal: 0               // 0-100

    readonly property bool wifiOn: wifiRadio === "enabled"
    readonly property bool netConnected: connType !== ""

    // --- Estado de Bluetooth (bluez) ---
    property bool btPowered: false
    property var btDevices: []               // nombres de dispositivos conectados

    function netIcon() {
        if (connType === "ethernet") return "󰈁";
        if (!wifiOn)                 return "󰤮";
        if (!netConnected)           return "󰤟";
        if (wifiSignal >= 75)        return "󰤨";
        if (wifiSignal >= 50)        return "󰤥";
        if (wifiSignal >= 25)        return "󰤢";
        return "󰤟";
    }

    function netColor() {
        if (!wifiOn && connType !== "ethernet") return theme.colors.overlay0 || "gray";
        if (netConnected)                       return theme.colors.blue || "white";
        return theme.colors.yellow || "white";
    }

    function btIcon() {
        if (!btPowered)              return "󰂲";
        if (btDevices.length > 0)    return "󰂱";
        return "󰂯";
    }

    function btColor() {
        if (!btPowered)           return theme.colors.overlay0 || "gray";
        if (btDevices.length > 0) return theme.colors.sapphire || "white";
        return theme.colors.blue || "white";
    }

    function showPopover() {
        hidePopoverTimer.stop();
        popoverVisible = true;
        refresh();
    }

    function schedulePopoverHide() {
        if (!triggerHover.hovered && !popoverHovered)
            hidePopoverTimer.restart();
    }

    function refresh() {
        statusProc.running = true;
    }

    function runAction(cmd) {
        actionProc.command = cmd;
        actionProc.running = true;
        quickRefresh.restart();
    }

    // Lee el estado de red y bluetooth en un solo script parseable línea a línea.
    Process {
        id: statusProc
        command: ["sh", "-c",
            "radio=$(nmcli radio wifi 2>/dev/null); " +
            "active=$(nmcli -t -f NAME,TYPE connection show --active 2>/dev/null | grep -v ':loopback' | head -1); " +
            "name=$(printf '%s' \"$active\" | cut -d: -f1); " +
            "type=$(printf '%s' \"$active\" | cut -d: -f2); " +
            "signal=$(nmcli -t -f IN-USE,SIGNAL dev wifi 2>/dev/null | grep '^\\*' | cut -d: -f2 | head -1); " +
            "bt=$(bluetoothctl show 2>/dev/null | grep -m1 'Powered:' | awk '{print $2}'); " +
            "printf 'RADIO=%s\\n' \"$radio\"; " +
            "printf 'NAME=%s\\n' \"$name\"; " +
            "printf 'TYPE=%s\\n' \"$type\"; " +
            "printf 'SIGNAL=%s\\n' \"$signal\"; " +
            "printf 'BT=%s\\n' \"$bt\"; " +
            "bluetoothctl devices Connected 2>/dev/null | sed 's/^Device [0-9A-F:]* //' | while read -r d; do [ -n \"$d\" ] && printf 'BTDEV=%s\\n' \"$d\"; done"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.split("\n");
                let devs = [];
                let type = "";
                for (const line of lines) {
                    const i = line.indexOf("=");
                    if (i < 0) continue;
                    const key = line.substring(0, i);
                    const val = line.substring(i + 1).trim();
                    switch (key) {
                    case "RADIO":  root.wifiRadio = val || "disabled"; break;
                    case "NAME":   root.connName = val; break;
                    case "TYPE":
                        if (val.indexOf("wireless") !== -1) type = "wifi";
                        else if (val.indexOf("ethernet") !== -1) type = "ethernet";
                        else type = "";
                        break;
                    case "SIGNAL": root.wifiSignal = parseInt(val) || 0; break;
                    case "BT":     root.btPowered = (val === "yes"); break;
                    case "BTDEV":  if (val !== "") devs.push(val); break;
                    }
                }
                root.connType = type;
                root.btDevices = devs;
            }
        }
    }

    // Proceso para acciones (toggles, lanzar TUIs).
    Process { id: actionProc }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
        Component.onCompleted: root.refresh()
    }

    // Refresco rápido mientras el popout está abierto.
    Timer {
        interval: 1500
        repeat: true
        running: root.popoverVisible
        onTriggered: root.refresh()
    }

    // Refresco tras interactuar, para no esperar al poll.
    Timer {
        id: quickRefresh
        interval: 400
        repeat: false
        onTriggered: root.refresh()
    }

    Timer {
        id: hidePopoverTimer
        interval: 160
        repeat: false
        onTriggered: {
            if (!triggerHover.hovered && !root.popoverHovered)
                root.popoverVisible = false;
        }
    }

    // Pastilla en la barra: icono de red + icono de bluetooth.
    Rectangle {
        anchors.fill: parent
        color: root.popoverVisible ? (theme.colors.surface0 || "black") : (theme.colors.crust || "black")
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 10

            Text {
                text: root.netIcon()
                color: root.netColor()
                font.family: theme.fontFamily
                font.pixelSize: 16
            }

            Text {
                text: root.btIcon()
                color: root.btColor()
                font.family: theme.fontFamily
                font.pixelSize: 16
            }
        }

        HoverHandler {
            id: triggerHover
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: hovered ? root.showPopover() : root.schedulePopoverHide()
        }
    }

    // Popout con forma de burbuja (mismo estilo que CPU/MEM).
    PanelWindow {
        id: popover

        anchors {
            top: true
            right: true
        }

        margins {
            right: 275
        }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-connectivity"

        visible: root.popoverVisible
        implicitWidth: 380
        implicitHeight: root.popoverVisible ? (contentCol.implicitHeight + 40) : 0
        color: "transparent"

        Behavior on implicitHeight {
            NumberAnimation {
                duration: 110
                easing.type: Easing.OutCubic
            }
        }

        Item {
            anchors.fill: parent

            // Mantiene el popout abierto mientras el cursor está sobre él (incl. el borde).
            HoverHandler {
                id: popHover
                onHoveredChanged: {
                    root.popoverHovered = hovered;
                    if (hovered) root.showPopover();
                    else root.schedulePopoverHide();
                }
            }

            Popout {
                anchors.fill: parent
                alignment: 0
                asyncShapeLoad: false
                color: theme.colors.background || "black"
                radius: 20

                ColumnLayout {
                    id: contentCol
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    Text {
                        text: "Conexiones"
                        color: theme.colors.mauve || "white"
                        font.family: theme.fontFamily
                        font.bold: true
                        font.pixelSize: 15
                        Layout.alignment: Qt.AlignHCenter
                    }

                    // --- Tarjeta Red ---
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: netCol.implicitHeight + 24
                        radius: 14
                        color: theme.colors.surface0 || "black"

                        ColumnLayout {
                            id: netCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Text {
                                    text: root.netIcon()
                                    color: root.netColor()
                                    font.family: theme.fontFamily
                                    font.pixelSize: 22
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "Red"
                                        color: theme.colors.text || "white"
                                        font.family: theme.fontFamily
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: root.connType === "ethernet"
                                            ? "Ethernet — " + root.connName
                                            : (!root.wifiOn
                                                ? "WiFi apagado"
                                                : (root.netConnected
                                                    ? root.connName + " · " + root.wifiSignal + "%"
                                                    : "Sin conexión"))
                                        color: theme.colors.subtext0 || "gray"
                                        font.family: theme.fontFamily
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }
                                }

                                // Toggle WiFi on/off
                                Rectangle {
                                    width: 46
                                    height: 26
                                    radius: height / 2
                                    color: root.wifiOn ? (theme.colors.blue || "blue") : (theme.colors.surface2 || "gray")

                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: height / 2
                                        color: theme.colors.text || "white"
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: root.wifiOn ? parent.width - width - 3 : 3
                                        Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                    }

                                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                                    TapHandler {
                                        onTapped: root.runAction(["nmcli", "radio", "wifi", root.wifiOn ? "off" : "on"])
                                    }
                                }
                            }

                            // Botón: administrar red (nmtui)
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 10
                                color: netBtnHover.hovered ? (theme.colors.surface2 || "gray") : (theme.colors.surface1 || "gray")

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Text {
                                        text: "󰤨"
                                        color: theme.colors.blue || "white"
                                        font.family: theme.fontFamily
                                        font.pixelSize: 14
                                    }
                                    Text {
                                        text: "Administrar red (gazelle)"
                                        color: theme.colors.text || "white"
                                        font.family: theme.fontFamily
                                        font.pixelSize: 13
                                    }
                                }

                                HoverHandler { id: netBtnHover; cursorShape: Qt.PointingHandCursor }
                                TapHandler {
                                    onTapped: {
                                        Quickshell.execDetached(["kitty", "--class", "gazelle-float", "-e", "gazelle"]);
                                        root.popoverVisible = false;
                                    }
                                }
                            }
                        }
                    }

                    // --- Tarjeta Bluetooth ---
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: btCol.implicitHeight + 24
                        radius: 14
                        color: theme.colors.surface0 || "black"

                        ColumnLayout {
                            id: btCol
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 14
                            anchors.rightMargin: 14
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12

                                Text {
                                    text: root.btIcon()
                                    color: root.btColor()
                                    font.family: theme.fontFamily
                                    font.pixelSize: 22
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    Text {
                                        text: "Bluetooth"
                                        color: theme.colors.text || "white"
                                        font.family: theme.fontFamily
                                        font.pixelSize: 13
                                        font.bold: true
                                    }

                                    Text {
                                        Layout.fillWidth: true
                                        text: !root.btPowered
                                            ? "Apagado"
                                            : (root.btDevices.length > 0
                                                ? root.btDevices.length + " conectado(s)"
                                                : "Encendido · sin dispositivos")
                                        color: theme.colors.subtext0 || "gray"
                                        font.family: theme.fontFamily
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                    }
                                }

                                // Toggle Bluetooth on/off
                                Rectangle {
                                    width: 46
                                    height: 26
                                    radius: height / 2
                                    color: root.btPowered ? (theme.colors.sapphire || "blue") : (theme.colors.surface2 || "gray")

                                    Rectangle {
                                        width: 20
                                        height: 20
                                        radius: height / 2
                                        color: theme.colors.text || "white"
                                        anchors.verticalCenter: parent.verticalCenter
                                        x: root.btPowered ? parent.width - width - 3 : 3
                                        Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                                    }

                                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                                    TapHandler {
                                        onTapped: root.runAction(["bluetoothctl", "power", root.btPowered ? "off" : "on"])
                                    }
                                }
                            }

                            // Lista de dispositivos conectados
                            ColumnLayout {
                                Layout.fillWidth: true
                                Layout.leftMargin: 34
                                spacing: 4
                                visible: root.btDevices.length > 0

                                Repeater {
                                    model: root.btDevices
                                    delegate: Row {
                                        required property var modelData
                                        spacing: 8
                                        Text {
                                            text: "󰂱"
                                            color: theme.colors.sapphire || "white"
                                            font.family: theme.fontFamily
                                            font.pixelSize: 12
                                        }
                                        Text {
                                            text: modelData
                                            color: theme.colors.subtext1 || "gray"
                                            font.family: theme.fontFamily
                                            font.pixelSize: 12
                                        }
                                    }
                                }
                            }

                            // Botón: administrar bluetooth (bluetui)
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 34
                                radius: 10
                                color: btBtnHover.hovered ? (theme.colors.surface2 || "gray") : (theme.colors.surface1 || "gray")

                                Row {
                                    anchors.centerIn: parent
                                    spacing: 8
                                    Text {
                                        text: "󰂯"
                                        color: theme.colors.sapphire || "white"
                                        font.family: theme.fontFamily
                                        font.pixelSize: 14
                                    }
                                    Text {
                                        text: "Administrar Bluetooth (bluetui)"
                                        color: theme.colors.text || "white"
                                        font.family: theme.fontFamily
                                        font.pixelSize: 13
                                    }
                                }

                                HoverHandler { id: btBtnHover; cursorShape: Qt.PointingHandCursor }
                                TapHandler {
                                    onTapped: {
                                        Quickshell.execDetached(["kitty", "--class", "bluetui-float", "-e", "bluetui"]);
                                        root.popoverVisible = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
