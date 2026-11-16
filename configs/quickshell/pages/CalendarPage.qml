import QtQuick
import QtQuick.Layouts

import "../services"

ColumnLayout {
    id: calendar

    property date currentDate: new Date()

    spacing: 14
    readonly property int pageWidth: 320

    Component.onCompleted: resetToToday()
    onCurrentDateChanged: Holidays.fetchMonth(currentDate, false)

    function resetToToday() {
        currentDate = new Date();
    }

    function shiftMonth(delta) {
        currentDate = new Date(currentDate.getFullYear(), currentDate.getMonth() + delta, 1);
    }

    function dateKey(y, m, d) {
        return y + "-" + String(m + 1).padStart(2, "0") + "-" + String(d).padStart(2, "0");
    }

    function holidayTitle(entry) {
        return entry.name_es || entry.name_en || entry.date || "Festivo";
    }

    function holidayDateLabel(entry) {
        const parts = (entry?.date || "").split("-");
        if (parts.length !== 3)
            return entry?.date || "";
        const months = ["ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"];
        return Number(parts[2]) + " " + months[Number(parts[1]) - 1];
    }

    function isToday(y, m, d) {
        const t = new Date();
        return t.getFullYear() === y && t.getMonth() === m && t.getDate() === d;
    }

    function isHoliday(y, m, d) {
        const key = dateKey(y, m, d);
        return Holidays.holidays.some(e => (typeof e === "string" ? e : e?.date) === key);
    }

    function monthModel() {
        const y = currentDate.getFullYear();
        const m = currentDate.getMonth();
        const offset = (new Date(y, m, 1).getDay() + 6) % 7;
        const total = new Date(y, m + 1, 0).getDate();
        const arr = [];
        for (let i = 0; i < offset; i++)
            arr.push({ day: 0 });
        for (let d = 1; d <= total; d++)
            arr.push({ day: d });
        return arr;
    }

    component NavButton: Text {
        signal clicked()
        color: theme.colors.red
        font.family: theme.fontFamily
        font.pixelSize: 14
        leftPadding: 8
        rightPadding: 8
        HoverHandler { cursorShape: Qt.PointingHandCursor }
        TapHandler { onTapped: parent.clicked() }
    }

    RowLayout {
        Layout.fillWidth: true

        NavButton { text: ""; onClicked: calendar.shiftMonth(-1) }

        Text {
            font.family: theme.fontFamily
            font.bold: true
            font.pixelSize: 15
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Qt.locale().toString(calendar.currentDate, "MMMM yyyy")
            color: theme.colors.red

            TapHandler { onTapped: calendar.resetToToday() }
        }

        NavButton { text: ""; onClicked: calendar.shiftMonth(1) }
    }

    GridLayout {
        columns: 7
        columnSpacing: 6
        rowSpacing: 6
        Layout.fillWidth: true

        Repeater {
            model: ["M", "T", "W", "T", "F", "S", "S"]

            Text {
                required property var modelData
                font.family: theme.fontFamily
                text: modelData
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: 11
                color: theme.colors.maroon
                opacity: 0.7
                Layout.fillWidth: true
            }
        }

        Repeater {
            model: calendar.monthModel()

            delegate: Rectangle {
                required property var modelData
                readonly property bool valid: modelData.day > 0
                readonly property bool today: valid && calendar.isToday(calendar.currentDate.getFullYear(), calendar.currentDate.getMonth(), modelData.day)
                readonly property bool holiday: valid && calendar.isHoliday(calendar.currentDate.getFullYear(), calendar.currentDate.getMonth(), modelData.day)

                Layout.fillWidth: true
                Layout.preferredHeight: 34
                radius: 10
                color: today ? theme.colors.peach : "transparent"

                Rectangle {
                    visible: parent.holiday
                    width: 5
                    height: 5
                    radius: width / 2
                    color: theme.colors.sky
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.topMargin: 6
                    anchors.rightMargin: 6
                }

                Text {
                    anchors.centerIn: parent
                    font.family: theme.fontFamily
                    text: parent.valid ? parent.modelData.day : ""
                    font.pixelSize: 12
                    color: parent.today ? theme.colors.crust : theme.colors.text
                }
            }
        }
    }

    ColumnLayout {
        visible: Holidays.loading || Holidays.error !== "" || Holidays.holidays.length > 0
        Layout.fillWidth: true
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: theme.colors.surface0
        }

        Text {
            visible: Holidays.holidays.length > 0 || Holidays.loading
            text: "Holidays"
            color: theme.colors.sky
            font.family: theme.fontFamily
            font.bold: true
            font.pixelSize: 13
        }

        Text {
            visible: Holidays.loading
            text: "Fetching..."
            color: theme.colors.subtext0
            font.family: theme.fontFamily
            font.pixelSize: 12
        }

        Text {
            visible: !Holidays.loading && Holidays.error !== ""
            text: Holidays.error
            color: theme.colors.red
            font.family: theme.fontFamily
            font.pixelSize: 12
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        Repeater {
            model: !Holidays.loading && Holidays.error === "" ? Holidays.holidays : []

            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    width: 7
                    height: 7
                    radius: width / 2
                    color: theme.colors.sky
                }

                Text {
                    Layout.preferredWidth: 48
                    text: calendar.holidayDateLabel(modelData)
                    color: theme.colors.subtext1
                    font.family: theme.fontFamily
                    font.pixelSize: 12
                }

                Text {
                    Layout.fillWidth: true
                    text: calendar.holidayTitle(modelData)
                    color: theme.colors.text
                    font.family: theme.fontFamily
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                }
            }
        }
    }
}
