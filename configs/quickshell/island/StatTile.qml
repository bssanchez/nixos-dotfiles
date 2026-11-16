import QtQuick
import QtQuick.Layouts

// Anillo de uso (CPU/RAM/Disco) que abre su página de detalle.
Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property int percent: 0
    property color accent: theme.colors.mauve || "white"

    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 92
    radius: 16
    color: hover.hovered ? (theme.colors.surface1 || "gray") : (theme.colors.surface0 || "gray")

    Behavior on color { ColorAnimation { duration: 120 } }

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: root.clicked() }

    Canvas {
        id: ring
        width: 52
        height: 52
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10

        property real shown: root.percent
        Behavior on shown { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
        onShownChanged: requestPaint()

        onPaint: {
            const ctx = getContext("2d");
            const c = width / 2;
            const r = c - 4;
            ctx.reset();
            ctx.lineWidth = 5;
            ctx.lineCap = "round";
            ctx.strokeStyle = theme.colors.surface2 || "gray";
            ctx.beginPath();
            ctx.arc(c, c, r, 0, Math.PI * 2);
            ctx.stroke();
            if (shown > 0) {
                ctx.strokeStyle = root.accent;
                ctx.beginPath();
                ctx.arc(c, c, r, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * Math.min(1, shown / 100));
                ctx.stroke();
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.accent
            font.family: theme.fontFamily
            font.pixelSize: 16
        }
    }

    Text {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: ring.bottom
        anchors.topMargin: 4
        text: root.label + " " + root.percent + "%"
        color: theme.colors.text || "white"
        font.family: theme.fontFamily
        font.pixelSize: 11
    }
}
