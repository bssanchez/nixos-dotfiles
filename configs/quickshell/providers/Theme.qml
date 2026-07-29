import QtQuick
import Quickshell
import Quickshell.Io
import QtCore

Item {
    id: theme

    readonly property string themePath: StandardPaths.writableLocation(StandardPaths.HomeLocation) + "/.local/state/theme/quickshell.json"

    property var colors: JSON.parse(jsonTheme.text() || "{}")

    readonly property string fontFamily: "FiraCode Nerd Font Mono"

    FileView {
        id: jsonTheme
        path: theme.themePath
        watchChanges: true
        blockLoading: true

        onFileChanged: this.reload()
    }
}
