pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string usedText: "--"
    property string totalText: "--"
    property int percent: 0
    property var top: []

    Process {
        id: memProc
        command: ["sh", "-c", "free -h | awk '/^Mem/ {print $3\"|\"$2}'; free | awk '/^Mem/ {printf \"%d\\n\", $3*100/$2}'"]

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split("\n");
                const parts = (lines[0] || "").split("|");
                root.usedText = parts[0] || "--";
                root.totalText = parts[1] || "--";
                root.percent = parseInt(lines[1]) || 0;
            }
        }
    }

    Process {
        id: topProc
        command: ["sh", "-c", "ps -eo pid,comm,%mem,rss --sort=-rss | head -n 11"]

        stdout: StdioCollector {
            onStreamFinished: {
                const rows = [];
                const lines = this.text.trim().split("\n");
                for (let i = 1; i < lines.length && rows.length < 10; i++) {
                    const parts = lines[i].trim().split(/\s+/);
                    if (parts.length < 4)
                        continue;
                    rows.push({
                        pid: parts[0],
                        name: parts[1],
                        percent: parts[2],
                        rss: ((parseInt(parts[3]) || 0) / 1024).toFixed(1)
                    });
                }
                root.top = rows;
            }
        }
    }

    function refresh() {
        memProc.running = true;
        topProc.running = true;
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }
}
