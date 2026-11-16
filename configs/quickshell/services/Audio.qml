pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property bool ready: sink !== null && sink.ready
    readonly property int volume: ready ? Math.round(sink.audio.volume * 100) : 0
    readonly property bool muted: ready ? sink.audio.muted : false
    readonly property string sinkName: ready ? (sink.description || sink.nickname || sink.name) : ""

    signal osd()

    // Ignora los cambios del primer enlace con el sink para no disparar el OSD al arrancar.
    property bool _armed: false

    readonly property string icon: {
        if (muted || volume === 0) return "󰝟";
        if (volume < 34)           return "󰕿";
        if (volume < 67)           return "󰖀";
        return "󰕾";
    }

    function setVolume(percent) {
        if (!ready) return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(100, percent)) / 100;
    }

    function step(delta) {
        setVolume(volume + delta);
    }

    function toggleMute() {
        if (ready)
            sink.audio.muted = !sink.audio.muted;
    }

    function openMixer() {
        Quickshell.execDetached(["kitty", "-e", "wiremix"]);
    }

    PwObjectTracker {
        objects: root.sink ? [root.sink] : []
    }

    onSinkChanged: {
        _armed = false;
        armTimer.restart();
    }

    Timer {
        id: armTimer
        interval: 800
        running: true
        onTriggered: root._armed = true
    }

    onVolumeChanged: if (_armed) osd()
    onMutedChanged: if (_armed) osd()
}
