pragma Singleton
import QtQuick
import QtCore
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string statePath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.cache/idle_enabled"
    readonly property bool enabled: (stateFile.text() || "enabled").indexOf("disabled") === -1

    function toggle() {
        toggleProc.running = true;
    }

    FileView {
        id: stateFile
        path: root.statePath
        watchChanges: true
        blockLoading: true
        onFileChanged: this.reload()
    }

    Process {
        id: toggleProc
        command: ["sh", "-c", "~/.config/hypr/scripts/toggle_idle.sh"]
    }
}
