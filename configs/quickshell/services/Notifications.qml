pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var items: []
    readonly property int count: items.length
    // mako no puede borrar su historial; ocultamos lo ya visto con este baseline.
    property int clearedBeforeId: 0

    property int watchers: 0
    // La isla lo activa para enterarse de las notificaciones que mako no dibuja.
    property bool watchIncoming: false
    property int _lastSeenId: -1

    signal incoming(var notification)

    function urgencyColorName(u) {
        if (u === "critical") return "red";
        if (u === "low")      return "overlay0";
        return "lavender";
    }

    function refresh() {
        historyProc.running = true;
    }

    function clear() {
        actionProc.command = ["makoctl", "dismiss", "--all"];
        actionProc.running = true;
        let maxId = 0;
        for (const n of items)
            if (n.id > maxId) maxId = n.id;
        clearedBeforeId = maxId;
        items = [];
    }

    function invoke(id) {
        actionProc.command = ["makoctl", "invoke", "-n", String(id)];
        actionProc.running = true;
    }

    function parse(text) {
        if (text.trim() === "") return [];
        try {
            const data = JSON.parse(text);
            return Array.isArray(data) ? data : (data.data || []);
        } catch (e) {
            return [];
        }
    }

    Process {
        id: historyProc
        command: ["makoctl", "history", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                const list = root.parse(this.text);
                let maxId = 0;
                for (const n of list)
                    if (n.id > maxId) maxId = n.id;
                // mako reiniciado: los ids vuelven a empezar.
                if (maxId < root.clearedBeforeId)
                    root.clearedBeforeId = 0;
                root.items = list
                    .filter(n => n.id > root.clearedBeforeId)
                    .sort((a, b) => b.id - a.id);
            }
        }
    }

    Process {
        id: listProc
        command: ["makoctl", "list", "-j"]

        stdout: StdioCollector {
            onStreamFinished: {
                const list = root.parse(this.text).sort((a, b) => a.id - b.id);
                const first = root._lastSeenId < 0;
                for (const n of list) {
                    if (n.id <= root._lastSeenId)
                        continue;
                    root._lastSeenId = n.id;
                    if (!first)
                        root.incoming(n);
                }
                if (first)
                    root._lastSeenId = Math.max(0, root._lastSeenId);
            }
        }
    }

    Process { id: actionProc }

    Timer {
        interval: root.watchers > 0 ? 1000 : 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    Timer {
        interval: 800
        running: root.watchIncoming
        repeat: true
        triggeredOnStart: true
        onTriggered: listProc.running = true
    }
}
