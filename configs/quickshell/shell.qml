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

    readonly property var primaryScreen:
        Quickshell.screens.find(
            s => s.name.startsWith("eDP") || 
            s.name.startsWith("LVDS")
        ) ?? Quickshell.screens[0]

    Variants {
        model: Quickshell.screens

        TopBar {
            required property var modelData
            screen: modelData
        }
    }

    Loader {
        active: true
        id: visualizerLoader

        sourceComponent: MediaVisualizer {
            targetScreen: root.primaryScreen
        }
    }

    IpcHandler {
        target: "visualizer"

        function toggle(): void { visualizerLoader.item?.toggle(); }
        function reveal(): void { if (visualizerLoader.item) visualizerLoader.item.overrideState = 1; }
        function hide(): void   { if (visualizerLoader.item) visualizerLoader.item.overrideState = 0; }
        function auto(): void   { if (visualizerLoader.item) visualizerLoader.item.overrideState = -1; }
    }
}
