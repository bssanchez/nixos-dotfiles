pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int total: 0
    property var cores: []
    property int coreCount: 0
    property string name: "Unknown CPU"
    property string model: "Unknown"

    property var _lastIdle: []
    property var _lastTotal: []

    Process {
        id: cpuInfoProc
        command: ["cat", "/proc/cpuinfo"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                let modelName = "";
                let modelId = "";
                for (const raw of this.text.split("\n")) {
                    const line = raw.trim();
                    if (modelName === "" && line.startsWith("model name"))
                        modelName = line.slice(line.indexOf(":") + 1).trim();
                    if (modelId === "" && /^model\s*:/.test(line))
                        modelId = line.slice(line.indexOf(":") + 1).trim();
                    if (modelName !== "" && modelId !== "")
                        break;
                }
                root.name = modelName || "Unknown CPU";
                root.model = modelId || "Unknown";
            }
        }
    }

    Process {
        id: statProc
        command: ["cat", "/proc/stat"]

        stdout: StdioCollector {
            onStreamFinished: {
                const newCores = [];
                let current = 0;
                let idx = 0;
                for (const raw of this.text.split("\n")) {
                    const line = raw.trim();
                    if (!line.startsWith("cpu"))
                        continue;
                    const parts = line.replace(/\s+/g, " ").split(" ");
                    const idle = parseInt(parts[4]) + parseInt(parts[5]);
                    let sum = 0;
                    for (let j = 1; j < 9; j++)
                        sum += parseInt(parts[j] || 0);

                    if (root._lastTotal.length > idx) {
                        const dIdle = idle - root._lastIdle[idx];
                        const dTotal = sum - root._lastTotal[idx];
                        const usage = dTotal > 0 ? Math.round((dTotal - dIdle) / dTotal * 100) : 0;
                        if (parts[0] === "cpu")
                            current = usage;
                        else
                            newCores.push(usage);
                    }
                    root._lastIdle[idx] = idle;
                    root._lastTotal[idx] = sum;
                    idx++;
                }
                root.coreCount = Math.max(idx - 1, 0);
                if (newCores.length > 0) {
                    root.total = current;
                    root.cores = newCores;
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: statProc.running = true
    }
}
