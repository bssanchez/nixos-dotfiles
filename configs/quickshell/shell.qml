//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "./modules"
import "./providers"

ShellRoot {
    id: root

    Theme { id: theme }

    Loader {
        active: true
        id: topBarLoader

        sourceComponent: TopBar { id: topBar }
    }

    Loader {
        active: true
        id: visualizerLoader

        sourceComponent: MediaVisualizer {}
    }

    IpcHandler {
        target: "visualizer"

        function toggle(): void { visualizerLoader.item?.toggle(); }
        function reveal(): void { if (visualizerLoader.item) visualizerLoader.item.overrideState = 1; }
        function hide(): void   { if (visualizerLoader.item) visualizerLoader.item.overrideState = 0; }
        function auto(): void   { if (visualizerLoader.item) visualizerLoader.item.overrideState = -1; }
    }
}
