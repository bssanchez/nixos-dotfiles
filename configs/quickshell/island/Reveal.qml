import QtQuick

// Fundido asimétrico: sale rápido para no verse recortado, entra suave.
Behavior {
    id: root

    NumberAnimation {
        duration: root.targetValue > 0 ? 220 : 70
        easing.type: Easing.OutCubic
    }
}
