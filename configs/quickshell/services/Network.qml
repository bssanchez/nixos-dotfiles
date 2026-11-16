pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string wifiRadio: "disabled"
    property string connName: ""
    property string connType: ""
    property int wifiSignal: 0

    readonly property bool wifiOn: wifiRadio === "enabled"
    readonly property bool connected: connType !== ""

    property bool btPowered: false
    property var btDevices: []

    // Cuántas vistas abiertas piden refresco rápido.
    property int watchers: 0

    readonly property string netIcon: {
        if (connType === "ethernet") return "󰈁";
        if (!wifiOn)                 return "󰤮";
        if (!connected)              return "󰤟";
        if (wifiSignal >= 75)        return "󰤨";
        if (wifiSignal >= 50)        return "󰤥";
        if (wifiSignal >= 25)        return "󰤢";
        return "󰤟";
    }

    readonly property string netLabel: connType === "ethernet"
        ? "Ethernet — " + connName
        : (!wifiOn ? "WiFi apagado" : (connected ? connName + " · " + wifiSignal + "%" : "Sin conexión"))

    readonly property string btIcon: !btPowered ? "󰂲" : (btDevices.length > 0 ? "󰂱" : "󰂯")

    readonly property string btLabel: !btPowered
        ? "Apagado"
        : (btDevices.length > 0 ? btDevices.length + " conectado(s)" : "Encendido · sin dispositivos")

    function refresh() {
        statusProc.running = true;
    }

    function runAction(cmd) {
        actionProc.command = cmd;
        actionProc.running = true;
        quickRefresh.restart();
    }

    function toggleWifi() {
        runAction(["nmcli", "radio", "wifi", wifiOn ? "off" : "on"]);
    }

    function toggleBluetooth() {
        runAction(["bluetoothctl", "power", btPowered ? "off" : "on"]);
    }

    function openWifiManager() {
        Quickshell.execDetached(["kitty", "--class", "gazelle-float", "-e", "gazelle"]);
    }

    function openBluetoothManager() {
        Quickshell.execDetached(["kitty", "--class", "bluetui-float", "-e", "bluetui"]);
    }

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
                const devs = [];
                let type = "";
                for (const line of this.text.split("\n")) {
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

    Process { id: actionProc }

    Timer {
        interval: root.watchers > 0 ? 1500 : 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: quickRefresh
        interval: 400
        onTriggered: root.refresh()
    }
}
