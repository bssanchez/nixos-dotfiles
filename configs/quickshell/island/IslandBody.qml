import QtQuick

import "../services"

// Isla: una sola forma que cambia de tamaño según el estado
// (reposo, música, momentos transitorios o abierta).
MorphSurface {
    id: root

    property string monitorName: ""
    property bool expanded: false

    property string moment: ""
    property string osdKind: "volume"
    property var notification: null
    property string batteryLevel: "low"

    readonly property bool music: Media.playing
    readonly property string mode: expanded ? "open" : (moment !== "" ? moment : (music ? "music" : "idle"))
    readonly property string shownMode: revealed ? mode : ""

    readonly property var momentPriority: ({ osd: 1, notif: 2, battery: 3 })
    readonly property var momentDuration: ({ osd: 1500, notif: 4500 })

    function open(page) {
        openView.page = page || "";
        expanded = true;
        moment = "";
        forceActiveFocus();
    }

    function close() {
        expanded = false;
    }

    function toggle() {
        if (expanded) close();
        else open("");
    }

    function showMoment(kind) {
        if (expanded)
            return;
        if (moment !== "" && momentPriority[moment] > momentPriority[kind])
            return;
        moment = kind;
        if (momentDuration[kind])
            momentTimer.restart();
        else
            momentTimer.stop();
    }

    Timer {
        id: momentTimer
        interval: root.momentDuration[root.moment] ?? 1500
        onTriggered: {
            if (bodyHover.hovered && root.moment === "notif")
                restart();
            else
                root.moment = "";
        }
    }

    Connections {
        target: Audio
        function onOsd() { root.osdKind = "volume"; root.showMoment("osd"); }
    }

    Connections {
        target: Brightness
        function onOsd() { root.osdKind = "brightness"; root.showMoment("osd"); }
    }

    Connections {
        target: Notifications
        function onIncoming(n) { root.notification = n; root.showMoment("notif"); }
    }

    Connections {
        target: Battery
        function onAlert(kind) { root.batteryLevel = kind; root.showMoment("battery"); }
        function onChargingChanged() { if (Battery.charging && root.moment === "battery") root.moment = ""; }
    }

    // ---- Geometría ----
    readonly property Item activeView: {
        switch (mode) {
        case "open": return openView;
        case "music": return musicView;
        case "osd": return osdView;
        case "notif": return notifView;
        case "battery": return batteryView;
        }
        return idleView;
    }

    readonly property real padX: expanded ? 22 : 14
    readonly property real padTop: expanded ? 18 : 7
    readonly property real padBottom: expanded ? 22 : 7

    targetShoulder: expanded ? 24 : 14
    stage: mode === "open" ? "open:" + openView.page : mode
    contentSettled: mode !== "open" || openView.shownPage === openView.page
    targetWidth: activeView.implicitWidth + 2 * (targetShoulder + padX)
    targetHeight: activeView.implicitHeight + padTop + padBottom

    Keys.onEscapePressed: openView.back()

    HoverHandler { id: bodyHover }

    TapHandler {
        enabled: !root.expanded
        onTapped: {
            if (root.mode === "notif") root.open("notifications");
            else if (root.mode === "battery") root.moment = "";
            else root.open("");
        }
    }

    Item {
        id: views
        anchors.fill: parent
        anchors.leftMargin: root.padX
        anchors.rightMargin: root.padX
        anchors.topMargin: root.padTop

        IdleView {
            id: idleView
            anchors.horizontalCenter: parent.horizontalCenter
            monitorName: root.monitorName
            opacity: root.shownMode === "idle" ? 1 : 0
            enabled: root.mode === "idle"
            Reveal on opacity {}
            onExpandRequested: root.open("")
        }

        IdleView {
            id: musicView
            anchors.horizontalCenter: parent.horizontalCenter
            monitorName: root.monitorName
            music: true
            opacity: root.shownMode === "music" ? 1 : 0
            enabled: root.mode === "music"
            Reveal on opacity {}
            onExpandRequested: root.open("")
            onMediaRequested: root.open("media")
        }

        OsdView {
            id: osdView
            anchors.horizontalCenter: parent.horizontalCenter
            kind: root.osdKind
            opacity: root.shownMode === "osd" ? 1 : 0
            Reveal on opacity {}
        }

        NotifView {
            id: notifView
            anchors.horizontalCenter: parent.horizontalCenter
            notification: root.notification
            opacity: root.shownMode === "notif" ? 1 : 0
            Reveal on opacity {}
        }

        BatteryView {
            id: batteryView
            anchors.horizontalCenter: parent.horizontalCenter
            level: root.batteryLevel
            opacity: root.shownMode === "battery" ? 1 : 0
            enabled: root.mode === "battery"
            Reveal on opacity {}
            onDismissed: root.moment = ""
        }

        OpenView {
            id: openView
            anchors.horizontalCenter: parent.horizontalCenter
            width: implicitWidth
            active: root.expanded
            opacity: root.shownMode === "open" ? 1 : 0
            enabled: root.mode === "open"
            Reveal on opacity {}
            onCloseRequested: root.close()
        }
    }
}
