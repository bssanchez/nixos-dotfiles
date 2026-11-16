pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property MprisPlayer player:
        players.find(p => p.isPlaying) ?? (players.length > 0 ? players[0] : null)
    readonly property bool playing: player !== null && player.isPlaying

    readonly property string title: player?.trackTitle || ""
    readonly property string artist: player?.trackArtist || ""
    readonly property string artUrl: player?.trackArtUrl || ""

    // Barras compactas para la isla; cava solo corre mientras alguien las pide.
    readonly property int barCount: 12
    property int barWatchers: 0
    property var bars: new Array(barCount).fill(0)

    function togglePlaying() { if (player?.canTogglePlaying) player.togglePlaying(); }
    function next()          { if (player?.canGoNext) player.next(); }
    function previous()      { if (player?.canGoPrevious) player.previous(); }

    Process {
        running: root.playing && root.barWatchers > 0
        command: ["sh", "-c",
            "conf=${XDG_RUNTIME_DIR:-/tmp}/quickshell-island-cava.conf; " +
            "printf '[general]\\nframerate = 30\\nbars = " + root.barCount + "\\nautosens = 1\\n" +
            "[input]\\nmethod = pulse\\n" +
            "[output]\\nmethod = raw\\nraw_target = /dev/stdout\\ndata_format = ascii\\nascii_max_range = 100\\nchannels = mono\\nmono_option = average\\n" +
            "[smoothing]\\nmonstercat = 1\\nnoise_reduction = 0.35\\n' > \"$conf\"; " +
            "exec cava -p \"$conf\""]

        stdout: SplitParser {
            onRead: data => {
                const vals = data.split(";").filter(s => s !== "").map(s => Math.min(100, parseInt(s, 10) || 0) / 100);
                if (vals.length > 0)
                    root.bars = vals;
            }
        }

        onRunningChanged: if (!running) root.bars = new Array(root.barCount).fill(0)
    }
}
