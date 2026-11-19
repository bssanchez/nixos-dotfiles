//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick
import QtCore

import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

import "./island"
import "./modules"
import "./providers"
import "./services"

ShellRoot {
    id: root

    Theme { id: theme }

    readonly property var primaryScreen:
        Quickshell.screens.find(
            s => s.name.startsWith("eDP") ||
            s.name.startsWith("LVDS")
        ) ?? Quickshell.screens[0]

    // ---- Layout: "island" (por defecto) o "bar" ----
    readonly property string layout: (layoutFile.text() || "").trim() === "bar" ? "bar" : "island"

    function setLayout(name) {
        layoutFile.setText(name === "bar" ? "bar" : "island");
    }

    // Auto-ocultado de la isla: activo salvo que el archivo diga "off".
    readonly property bool autoHide: (autoHideFile.text() || "").trim() !== "off"

    function setAutoHide(on) {
        autoHideFile.setText(on ? "on" : "off");
    }

    FileView {
        id: autoHideFile
        path: StandardPaths.writableLocation(StandardPaths.GenericStateLocation) + "/quickshell-island-autohide"
        watchChanges: true
        blockLoading: true
        printErrors: false
        onFileChanged: this.reload()
    }

    FileView {
        id: layoutFile
        path: StandardPaths.writableLocation(StandardPaths.GenericStateLocation) + "/quickshell-layout"
        watchChanges: true
        blockLoading: true
        printErrors: false
        onFileChanged: this.reload()
    }

    // En modo isla mako no dibuja popups; la isla los muestra.
    onLayoutChanged: applyMakoMode()
    Component.onCompleted: applyMakoMode()

    function applyMakoMode() {
        Quickshell.execDetached(["makoctl", "mode", layout === "island" ? "-a" : "-r", "island"]);
        Notifications.watchIncoming = layout === "island";
    }

    Variants {
        id: screens
        model: Quickshell.screens

        Scope {
            id: screenScope
            required property var modelData

            readonly property var island: islandLoader.item?.island ?? null

            Loader {
                id: islandLoader
                active: root.layout === "island"
                sourceComponent: Island {
                    screen: screenScope.modelData
                    autoHide: root.autoHide
                }
            }

            Loader {
                active: root.layout === "bar"
                sourceComponent: TopBar {
                    screen: screenScope.modelData
                }
            }
        }
    }

    function focusedIsland() {
        const name = Hyprland.focusedMonitor?.name ?? "";
        const scopes = screens.instances;
        const scope = scopes.find(s => s.modelData.name === name) ?? scopes[0];
        return scope?.island ?? null;
    }

    Loader {
        active: true
        id: visualizerLoader

        sourceComponent: MediaVisualizer {
            targetScreen: root.primaryScreen
        }
    }

    ActivateLinux {
        targetScreen: root.primaryScreen
    }

    IpcHandler {
        target: "shell"

        function layout(name: string): void { root.setLayout(name); }
        function toggleLayout(): void       { root.setLayout(root.layout === "island" ? "bar" : "island"); }
        function toggleIsland(): void       { root.focusedIsland()?.toggle(); }
        function toggleAutoHide(): void     { root.setAutoHide(!root.autoHide); }
        function openIsland(page: string): void { root.focusedIsland()?.open(page); }
        function osd(kind: string): void    { if (kind === "brightness") Brightness.notifyChanged(); }
        function battery(kind: string): void { Battery.alert(kind); }
    }

    IpcHandler {
        target: "visualizer"

        function toggle(): void { visualizerLoader.item?.toggle(); }
        function reveal(): void { if (visualizerLoader.item) visualizerLoader.item.overrideState = 1; }
        function hide(): void   { if (visualizerLoader.item) visualizerLoader.item.overrideState = 0; }
        function auto(): void   { if (visualizerLoader.item) visualizerLoader.item.overrideState = -1; }
    }
}
