import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland
import Quickshell.Io

Item {
    id: batteryWidget
    width: 74
    height: 34

    readonly property string basePath: "/sys/class/power_supply/BAT0"

    property int level: 0
    property string status: "Unknown"
    readonly property bool charging: status === "Charging" || status === "Full"
    readonly property bool discharging: status === "Discharging"

    // Control de avisos: se disparan una sola vez por cruce de umbral.
    property bool warnedLow: false
    property bool warnedCritical: false

    // Estado del banner de aviso.
    property string alertLevel: "low"
    property bool alertVisible: false

    function batteryColor() {
        if (charging)     return theme.colors.green || "white";
        if (level > 50)   return theme.colors.green || "white";
        if (level > 20)   return theme.colors.yellow || "white";
        if (level > 15)   return theme.colors.peach || "white";
        return theme.colors.red || "white";
    }

    function batteryIcon() {
        if (charging)     return "󰂄";
        if (level >= 90)  return "󰁹";
        if (level >= 60)  return "󰂀";
        if (level >= 40)  return "󰁾";
        if (level >= 15)  return "󰁼";
        return "󰁺";
    }

    function showAlert(kind) {
        alertLevel = kind;
        alertVisible = true;
        alertHideTimer.restart();
    }

    function evaluateAlerts() {
        // Mientras carga (o está lleno) no avisamos y reiniciamos los flags.
        if (!discharging) {
            warnedLow = false;
            warnedCritical = false;
            return;
        }

        if (level <= 5 && !warnedCritical) {
            warnedCritical = true;
            warnedLow = true;
            showAlert("critical");
        } else if (level < 15 && !warnedLow) {
            warnedLow = true;
            showAlert("low");
        }

        // Histéresis: al recuperar carga por encima del umbral, permite volver a avisar.
        if (level > 20) warnedLow = false;
        if (level > 8)  warnedCritical = false;
    }

    Process {
        id: batteryProc
        command: ["cat", batteryWidget.basePath + "/capacity", batteryWidget.basePath + "/status"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/);
                if (parts.length >= 1 && parts[0] !== "")
                    batteryWidget.level = parseInt(parts[0]) || 0;
                if (parts.length >= 2)
                    batteryWidget.status = parts[1];
                batteryWidget.evaluateAlerts();
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: batteryProc.running = true
        Component.onCompleted: batteryProc.running = true
    }

    Timer {
        id: alertHideTimer
        interval: 8000
        repeat: false
        onTriggered: batteryWidget.alertVisible = false
    }

    // Pastilla en la barra
    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: batteryWidget.batteryIcon()
                color: batteryWidget.batteryColor()
                font.family: theme.fontFamily
                font.pixelSize: 16
            }

            Text {
                text: batteryWidget.level + "%"
                color: theme.colors.text || "black"
                font.pixelSize: 14
            }
        }
    }

    // Banner de aviso (sin depender de notify-send / daemon de notificaciones)
    PanelWindow {
        anchors { top: true }
        margins { top: 50 }

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "quickshell-battery-alert"
        exclusionMode: ExclusionMode.Ignore

        visible: batteryWidget.alertVisible
        implicitWidth: 320
        implicitHeight: 64
        color: "transparent"

        Rectangle {
            anchors.centerIn: parent
            width: 300
            height: 52
            radius: 16
            color: theme.colors.crust || "black"
            border.width: 2
            border.color: batteryWidget.alertLevel === "critical"
                ? (theme.colors.red || "red")
                : (theme.colors.peach || "orange")

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "󰂃"
                    color: batteryWidget.alertLevel === "critical"
                        ? (theme.colors.red || "red")
                        : (theme.colors.peach || "orange")
                    font.family: theme.fontFamily
                    font.pixelSize: 24
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: batteryWidget.alertLevel === "critical" ? "¡Batería crítica!" : "Batería baja"
                        color: theme.colors.text || "white"
                        font.family: theme.fontFamily
                        font.bold: true
                        font.pixelSize: 14
                    }

                    Text {
                        text: "Conecta el cargador — " + batteryWidget.level + "%"
                        color: theme.colors.subtext0 || "gray"
                        font.family: theme.fontFamily
                        font.pixelSize: 12
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: batteryWidget.alertVisible = false
            }
        }
    }
}
