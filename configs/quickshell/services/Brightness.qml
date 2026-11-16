pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int level: 0
    property bool _osdPending: false

    signal osd()

    readonly property string icon: level < 34 ? "󰃞" : (level < 67 ? "󰃟" : "󰃠")

    function refresh() {
        readProc.running = true;
    }

    property string _pending: ""

    function set(target) {
        _pending = target;
        if (!setProc.running)
            _flush();
    }

    function _flush() {
        if (_pending === "")
            return;
        setProc.command = ["brightnessctl", "-e4", "-n2", "set", _pending];
        _pending = "";
        setProc.running = true;
        quickRefresh.restart();
    }

    function setPercent(p) {
        set(Math.max(1, Math.min(100, Math.round(p))) + "%");
    }

    // Llamado por IPC desde las teclas de brillo (sysfs no avisa de cambios).
    function notifyChanged() {
        _osdPending = true;
        refresh();
    }

    Process {
        id: readProc
        command: ["brightnessctl", "-m"]

        stdout: StdioCollector {
            onStreamFinished: {
                // "amdgpu_bl1,backlight,60000,92%,64764"
                const m = this.text.trim().match(/,(\d+)%,/);
                if (m)
                    root.level = parseInt(m[1]);
                if (root._osdPending) {
                    root._osdPending = false;
                    root.osd();
                }
            }
        }
    }

    Process {
        id: setProc
        onExited: root._flush()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        id: quickRefresh
        interval: 60
        onTriggered: root.refresh()
    }
}
