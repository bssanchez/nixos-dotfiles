//@ pragma Env QS_NO_RELOAD_POPUP=1
import QtQuick

import Quickshell
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
}
