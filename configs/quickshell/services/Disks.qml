pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    // En NixOS / es tmpfs; los FS reales están en /nix (sistema), /home, /srv.
    readonly property var mounts: ["/nix", "/home", "/srv", "/boot"]

    property var partitions: mounts.map(m => ({ mount: m, used: "--", total: "--", usedPercent: 0, freePercent: 100, available: false }))
    property string rootText: "-- / --"
    property int rootPercent: 0

    Process {
        id: dfProc
        command: ["sh", "-c",
            "for p in " + root.mounts.join(" ") + "; do " +
            "if [ -e \"$p\" ]; then df -hP \"$p\" | awk -v path=\"$p\" 'NR==2 {print path\"|\"$3\"|\"$2\"|\"$5}'; " +
            "else echo \"$p|N/A|N/A|N/A\"; fi; done"]

        stdout: StdioCollector {
            onStreamFinished: {
                const next = [];
                for (const line of this.text.trim().split("\n")) {
                    const parts = line.trim().split("|");
                    if (parts.length < 4)
                        continue;
                    const pct = parseInt(parts[3].replace("%", ""));
                    const available = !isNaN(pct);
                    const usedPercent = available ? Math.max(0, Math.min(100, pct)) : 0;
                    next.push({
                        mount: parts[0],
                        used: parts[1],
                        total: parts[2],
                        usedPercent: usedPercent,
                        freePercent: 100 - usedPercent,
                        available: available
                    });
                    if (parts[0] === "/nix") {
                        root.rootText = available ? parts[1] + " / " + parts[2] : "-- / --";
                        root.rootPercent = usedPercent;
                    }
                }
                if (next.length > 0)
                    root.partitions = next;
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: dfProc.running = true
    }
}
