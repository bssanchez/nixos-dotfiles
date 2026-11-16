pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string basePath: "/sys/class/power_supply/BAT0"

    property int level: 0
    property string status: "Unknown"
    readonly property bool charging: status === "Charging" || status === "Full"
    readonly property bool discharging: status === "Discharging"

    property bool _warnedLow: false
    property bool _warnedCritical: false

    signal alert(string kind)

    readonly property string icon: {
        if (charging)     return "󰂄";
        if (level >= 90)  return "󰁹";
        if (level >= 60)  return "󰂀";
        if (level >= 40)  return "󰁾";
        if (level >= 15)  return "󰁼";
        return "󰁺";
    }

    // Nombre de color del tema, para que la UI lo resuelva con theme.colors[...].
    readonly property string colorName: {
        if (charging || level > 50) return "green";
        if (level > 20)             return "yellow";
        if (level > 15)             return "peach";
        return "red";
    }

    function evaluateAlerts() {
        if (!discharging) {
            _warnedLow = false;
            _warnedCritical = false;
            return;
        }
        if (level <= 5 && !_warnedCritical) {
            _warnedCritical = true;
            _warnedLow = true;
            alert("critical");
        } else if (level < 15 && !_warnedLow) {
            _warnedLow = true;
            alert("low");
        }
        if (level > 20) _warnedLow = false;
        if (level > 8)  _warnedCritical = false;
    }

    Process {
        id: batteryProc
        command: ["cat", root.basePath + "/capacity", root.basePath + "/status"]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/);
                if (parts[0])
                    root.level = parseInt(parts[0]) || 0;
                if (parts.length >= 2)
                    root.status = parts[1];
                root.evaluateAlerts();
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryProc.running = true
    }
}
