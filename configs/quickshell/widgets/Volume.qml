import QtQuick

import "../services"

Item {
    width: 78
    height: 34

    Rectangle {
        anchors.fill: parent
        color: theme.colors.crust || "black"
        radius: height / 2

        Row {
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: Audio.icon
                color: Audio.muted ? (theme.colors.overlay0 || "gray") : (theme.colors.sky || "white")
                font.family: theme.fontFamily
                font.pixelSize: 14
            }

            Text {
                text: Audio.muted ? "Mute" : (Audio.volume + "%")
                color: theme.colors.text || "black"
                font.pixelSize: 14
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            onClicked: mouse => mouse.button === Qt.RightButton ? Audio.openMixer() : Audio.toggleMute()
            onWheel: wheel => Audio.step(wheel.angleDelta.y > 0 ? 5 : -5)
        }
    }
}
