import QtQuick
import QtQuick.Effects

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Mpris

PanelWindow {
    id: visualizer

    anchors {
        left: true
        right: true
        bottom: true
    }

    implicitHeight: 190
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-visualizer"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // Click-through: empty input region
    mask: Region {}

    // ---- Mpris ----
    readonly property var players: Mpris.players.values
    readonly property MprisPlayer activePlayer:
        players.find(p => p.isPlaying) ?? (players.length > 0 ? players[0] : null)
    readonly property bool playing: activePlayer !== null && activePlayer.isPlaying

    // ---- Visibility state ----
    // -1 = auto (follow playback), 0 = forced hidden, 1 = forced shown
    property int overrideState: -1
    readonly property bool effectiveShown:
        overrideState === 0 ? false
        : overrideState === 1 ? true
        : playing

    // Cycles: auto -> forced opposite -> back to auto
    function toggle() {
        overrideState = (overrideState !== -1) ? -1 : (effectiveShown ? 0 : 1);
    }

    visible: content.opacity > 0.001

    // ---- cava data ----
    property int barCount: 48
    property var targetValues: new Array(barCount).fill(0)
    property var dispValues: []

    Process {
        id: cavaProc
        running: visualizer.effectiveShown && visualizer.playing
        command: ["sh", "-c",
            "cat > /tmp/quickshell-cava.conf << 'EOF'\n" +
            "[general]\n" +
            "framerate = 30\n" +
            "bars = " + visualizer.barCount + "\n" +
            "autosens = 1\n" +
            "[input]\n" +
            "method = pulse\n" +
            "[output]\n" +
            "method = raw\n" +
            "raw_target = /dev/stdout\n" +
            "data_format = ascii\n" +
            "ascii_max_range = 100\n" +
            "channels = mono\n" +
            "mono_option = average\n" +
            "[smoothing]\n" +
            "monstercat = 1\n" +
            "noise_reduction = 0.30\n" +
            "EOF\n" +
            "exec cava -p /tmp/quickshell-cava.conf"]

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const parts = data.split(";");
                const vals = [];
                for (let i = 0; i < parts.length; i++) {
                    if (parts[i] === "")
                        continue;
                    vals.push(Math.min(100, parseInt(parts[i], 10) || 0) / 100.0);
                }
                if (vals.length > 0)
                    visualizer.targetValues = vals;
            }
        }

        onRunningChanged: {
            if (!running) {
                visualizer.targetValues = new Array(visualizer.barCount).fill(0);
                waveCanvas.requestPaint();
            }
        }
    }

    FrameAnimation {
        running: visualizer.visible
        onTriggered: {
            const t = visualizer.targetValues;
            let d = visualizer.dispValues;
            if (d.length !== t.length)
                d = t.slice();
            let changed = false;
            for (let i = 0; i < t.length; i++) {
                const next = d[i] + (t[i] - d[i]) * 0.25;
                if (Math.abs(next - d[i]) > 0.0005)
                    changed = true;
                d[i] = next;
            }
            visualizer.dispValues = d;
            if (changed || wavePhase.running)
                waveCanvas.requestPaint();
        }
    }

    Item {
        id: content
        anchors.fill: parent
        opacity: visualizer.effectiveShown ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 450
                easing.type: Easing.InOutQuad
            }
        }

        Item {
            id: waveBox
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 150

            MultiEffect {
                anchors.fill: waveCanvas
                source: waveCanvas
                z: -1
                blurEnabled: true
                blur: 1.0
                blurMax: 48
                opacity: 0.55
            }

            Canvas {
                id: waveCanvas
                anchors.fill: parent
                renderStrategy: Canvas.Cooperative

                property real phase: 0
                NumberAnimation on phase {
                    id: wavePhase
                    from: 0
                    to: Math.PI * 2
                    duration: 4000
                    loops: Animation.Infinite
                    running: visualizer.effectiveShown
                }

                onPaint: {
                    const ctx = getContext("2d");
                    ctx.reset();
                    const w = width, h = height;
                    const src = visualizer.dispValues;
                    const n = src.length;
                    if (n === 0)
                        return;

                    const m = [];
                    for (let i = n - 1; i >= 0; i--)
                        m.push(src[i]);
                    for (let i = 0; i < n; i++)
                        m.push(src[i]);

                    const s = [];
                    for (let i = 0; i < m.length; i++) {
                        const a = m[Math.max(0, i - 1)];
                        const b = m[i];
                        const c = m[Math.min(m.length - 1, i + 1)];
                        s.push((a + b + c) / 3);
                    }

                    const maxAmp = h - 24;
                    const px = i => i * w / (s.length - 1);
                    const py = i => h - 2
                        - s[i] * maxAmp
                        - Math.sin(phase + i * 0.55) * 1.5;

                    function crest() {
                        ctx.beginPath();
                        ctx.moveTo(px(0), py(0));
                        for (let i = 1; i < s.length - 1; i++) {
                            const xc = (px(i) + px(i + 1)) / 2;
                            const yc = (py(i) + py(i + 1)) / 2;
                            ctx.quadraticCurveTo(px(i), py(i), xc, yc);
                        }
                        ctx.lineTo(px(s.length - 1), py(s.length - 1));
                    }

                    const mauve = Qt.color(theme.colors.mauve || "#cba6f7");
                    const lavender = Qt.color(theme.colors.lavender || "#b4befe");

                    crest();
                    ctx.lineTo(w, h);
                    ctx.lineTo(0, h);
                    ctx.closePath();
                    const grad = ctx.createLinearGradient(0, h - maxAmp - 20, 0, h);
                    grad.addColorStop(0.0, Qt.rgba(mauve.r, mauve.g, mauve.b, 0.55));
                    grad.addColorStop(0.55, Qt.rgba(lavender.r, lavender.g, lavender.b, 0.22));
                    grad.addColorStop(1.0, Qt.rgba(lavender.r, lavender.g, lavender.b, 0.04));
                    ctx.fillStyle = grad;
                    ctx.fill();

                    crest();
                    ctx.lineWidth = 2;
                    ctx.strokeStyle = Qt.rgba(lavender.r, lavender.g, lavender.b, 0.9);
                    ctx.stroke();
                }
            }
        }

        // Now playing
        Row {
            anchors {
                left: parent.left
                bottom: parent.bottom
                leftMargin: 22
                bottomMargin: 12
            }
            spacing: 8
            opacity: 0.75
            visible: visualizer.activePlayer !== null

            Item {
                width: 26
                height: 26
                anchors.verticalCenter: parent.verticalCenter

                Image {
                    id: art
                    anchors.fill: parent
                    source: visualizer.activePlayer?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                }

                Rectangle {
                    id: artMask
                    anchors.fill: parent
                    radius: 6
                    visible: false
                    layer.enabled: true
                }

                MultiEffect {
                    anchors.fill: parent
                    source: art
                    maskEnabled: true
                    maskSource: artMask
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                    visible: art.status === Image.Ready
                }

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: theme.colors.surface0 || "#313244"
                    visible: art.status !== Image.Ready

                    Text {
                        anchors.centerIn: parent
                        text: "󰎆"
                        font.family: theme.fontFamily
                        font.pixelSize: 14
                        color: theme.colors.mauve || "#cba6f7"
                    }
                }
            }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                width: Math.min(implicitWidth, visualizer.width * 0.4)
                elide: Text.ElideRight
                font.family: theme.fontFamily
                font.pixelSize: 12
                color: theme.colors.subtext1 || "#bac2de"
                style: Text.Raised
                styleColor: theme.colors.crust || "#11111b"
                text: {
                    const p = visualizer.activePlayer;
                    if (!p)
                        return "";
                    const t = p.trackTitle || "Unknown";
                    return p.trackArtist ? t + " — " + p.trackArtist : t;
                }
            }
        }
    }
}
