import QtQuick
import QtQuick.Layouts

import Quickshell

import "../components"
import "../providers"
import "../services"

ColumnLayout {
    id: root

    signal navigate(string page)
    signal closeRequested()

    spacing: 12
    readonly property int pageWidth: 440

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 12
        columnSpacing: 12

        Tile {
            icon: Network.netIcon
            title: Network.connType === "ethernet" ? "Ethernet" : "WiFi"
            subtitle: Network.netLabel
            accent: theme.colors.blue || "blue"
            active: Network.wifiOn || Network.connType === "ethernet"
            iconToggles: true
            onIconClicked: Network.toggleWifi()
            onClicked: root.navigate("network")
        }

        Tile {
            icon: Network.btIcon
            title: "Bluetooth"
            subtitle: Network.btLabel
            accent: theme.colors.sapphire || "blue"
            active: Network.btPowered
            iconToggles: true
            onIconClicked: Network.toggleBluetooth()
            onClicked: root.navigate("network")
        }

        Tile {
            Layout.columnSpan: 2
            visible: Media.player !== null
            icon: Media.playing ? "󰏤" : "󰐊"
            title: Media.title || "Nada sonando"
            subtitle: Media.artist
            accent: theme.colors.mauve || "white"
            active: Media.playing
            iconToggles: true
            onIconClicked: Media.togglePlaying()
            onClicked: root.navigate("media")
        }
    }

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: sliders.implicitHeight + 20
        radius: 16
        color: theme.colors.surface0 || "gray"

        ColumnLayout {
            id: sliders
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            SliderRow {
                icon: Audio.icon
                value: Audio.volume
                dimmed: Audio.muted
                accent: theme.colors.sky || "white"
                onMoved: v => Audio.setVolume(v)
                onIconClicked: Audio.toggleMute()
                onIconRightClicked: { Audio.openMixer(); root.closeRequested(); }
            }

            SliderRow {
                icon: Brightness.icon
                value: Brightness.level
                accent: theme.colors.yellow || "white"
                onMoved: v => Brightness.setPercent(v)
                onIconClicked: Brightness.set("60%")
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: 12

        StatTile {
            icon: ""
            label: "CPU"
            percent: Cpu.total
            accent: theme.colors.red || "red"
            onClicked: root.navigate("cpu")
        }

        StatTile {
            icon: ""
            label: "RAM"
            percent: Memory.percent
            accent: theme.colors.sapphire || "blue"
            onClicked: root.navigate("memory")
        }

        StatTile {
            icon: ""
            label: "Disco"
            percent: Disks.rootPercent
            accent: theme.colors.yellow || "yellow"
            onClicked: root.navigate("disk")
        }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 2
        rowSpacing: 12
        columnSpacing: 12

        Tile {
            icon: "󰃰"
            title: Time.formatLocal("dddd d")
            subtitle: Time.formatLocal("MMMM yyyy")
            accent: theme.colors.peach || "orange"
            onClicked: root.navigate("calendar")
        }

        Tile {
            icon: Notifications.count > 0 ? "󰂚" : "󰂜"
            title: "Notificaciones"
            subtitle: Notifications.count > 0 ? Notifications.count + " recientes" : "Sin novedades"
            accent: theme.colors.lavender || "white"
            active: Notifications.count > 0
            onClicked: root.navigate("notifications")
        }
    }
}
