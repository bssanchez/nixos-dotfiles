import QtQuick

import "../components"

// Burbuja pegada al borde superior que se transforma hacia un tamaño objetivo.
// Al cambiar de `stage` el contenido se oculta y solo se revela cuando la forma
// ya llegó a su tamaño, para que nunca se vea recortado a mitad de animación.
Item {
    id: root

    property real targetWidth: 0
    property real targetHeight: 0
    property real targetShoulder: 14
    // Los tamaños objetivo se calculan con targetShoulder: si dependieran del valor
    // animado, cada frame reiniciaría la animación de ancho/alto.
    property real shoulder: targetShoulder
    property string stage: ""
    // Falso mientras el contenido del nuevo stage aún no está montado.
    property bool contentSettled: true

    property string revealedStage: ""
    readonly property bool revealed: revealedStage === stage

    default property alias content: clipArea.data

    width: targetWidth
    height: targetHeight

    // Misma curva en ambos ejes para que crezca en diagonal, sin abrir primero un lado.
    Behavior on width { NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 0.8 } }
    Behavior on height { NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 0.8 } }
    Behavior on shoulder { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

    Component.onCompleted: revealedStage = stage

    onStageChanged: {
        revealedStage = "";
        revealTimer.restart();
    }

    Timer {
        id: revealTimer
        interval: 30
        repeat: true
        onTriggered: {
            // Revela durante el asentamiento del rebote, no al final exacto.
            const tol = (t) => Math.max(10, t * 0.08);
            const near = Math.abs(root.width - root.targetWidth) < tol(root.targetWidth)
                && Math.abs(root.height - root.targetHeight) < tol(root.targetHeight);
            if (root.contentSettled && near) {
                root.revealedStage = root.stage;
                stop();
            }
        }
    }

    Popout {
        anchors.fill: parent
        alignment: 0
        radius: root.shoulder
        asyncShapeLoad: false
        color: theme.colors.background || "black"
    }

    Item {
        id: clipArea
        anchors.fill: parent
        anchors.leftMargin: root.shoulder
        anchors.rightMargin: root.shoulder
        clip: true
    }
}
